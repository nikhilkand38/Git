#Requires -Version 5.0
<#
========================================================================================
 R CORE WINAMS UNIT TEST SCRIPT
========================================================================================
 Purpose
   Automates:
     1) CaseViewer project creation and hook code generation (CaseCommand.exe)
     2) Copying user sources into the CaseViewer project (robocopy)
     3) Building (cmake | make) with live console output
     4) Running WinAMS SST Manager (AMSCommand.exe) with per-run logs

 Audience
   Test Engineers building & executing unit/system tests for R-Core using WinAMS/CaseViewer.

 High-Level Flow
   --app <PROJ> <VOPT> <SRCLIST> <SPMC_CSV> <MODE> [mode-args...]
     STEP_X0: Create/analyze CaseViewer project + generate hook code
     STEP_X1: Copy user project into CaseViewer project & sync hook sources
     STEP_X2: Build (cmake or make)
     STEP_X3: Create SST project, import ELF, configure tests, run CSV

 Inputs (per app in command line)
   --app <PROJECT_FOLDER> <SETTINGS.vopt> <SOURCE_LIST.txt> <SPMC_DIR_LIST.csv> <MODE> ...
   MODE=make:
     <BUILD_PATH> <CSV_FILE> <SETTINGS_AMSO>
   MODE=cmake:
     <BUILD_PATH> <TOOLCHAIN_FILE> <CSV_FILE> <SETTINGS_AMSO>

 Outputs
   - CaseViewer project at: <PROJECT_FOLDER> (normalized to *_caseviewer)
   - Build artifacts inside: <BUILD_PATH> or <PROJECT_FOLDER>\<APP>\build
   - SST project at: <CV_PARENT>\<APP>_sstManager
   - Logs:
       CaseCommand logs: .\log_CaseCommand\
       Script run log  : .\log\<App>\{App_yyyymmdd_hhmmss}.log
       AMS/SST logs    : .\log_AMScommand\<App>\yyyyMMdd_HHmmss\
                         (ACmdErrorLog.txt, AmsErrorLog.txt, systemg.log, sx.log)

 Environment Variables (set/used)
   CASE_LOGDIR, CASECOMMAND_LOG  -> .\log_CaseCommand (CaseViewer silent CLI logs)
   AMSCOMMAND_LOG                -> .\log_AMScommand\<App>\yyyyMMdd_HHmmss (SST silent CLI logs)
   GAIO_SCLI_LOG_SAVE=1          -> preserve systemg.log / sx.log in AMS log folder

 Prerequisites
   - PowerShell 5+ on Windows
   - Internet access for first-time Chocolatey + build tools (auto-install)
   - Write permissions to the script directory and project/build directories

 Required Tools (auto-installed if missing)
   - cmake, ninja, make, arm-none-eabi-gcc (via Chocolatey)
   - WinAMS (AMSCommand.exe & CaseCommand.exe) — installer zip path will be asked if not present

 Notes
   - Robocopy output is suppressed (no console, no log). Failures (exit code >=8) still abort.
   - Build/CMake/Case/AMS outputs stream live to console and to the script log file.
========================================================================================
#>

param(
  [string]$WinAMSZip,
  [string]$GaioLicenseServer = "100.64.4.135",
  [int]$GaioLicensePort = 50001
)

function Ensure-GaioLicense {
    param(
        [string]$LicenseServer,
        [int]$Port,
        [string]$GaioBinPath   # folder containing en_GaioLicClient.exe
    )

    Write-Host "Configuring GAIO License..."

    # 1) Try to locate en_GaioLicClient.exe
    $licExe = $null
    $candidatePaths = @(
        $GaioBinPath,
        "C:\Program Files (x86)\gaio\CasePlayer2\bin",
        "C:\WinAMS\bin"
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($p in $candidatePaths) {
        $exe = Join-Path $p "en_GaioLicClient.exe"
        if (Test-Path $exe) { $licExe = $exe; break }
    }
    if (-not $licExe) {
        $cmd = Get-Command en_GaioLicClient.exe -ErrorAction SilentlyContinue
        if ($cmd) { $licExe = $cmd.Source }
    }

    # 2) ALWAYS: run the license client first (if present)
    if ($licExe) {
        Write-Host "[INFO] Running: $licExe /LicenseServer $LicenseServer /Port $Port"
        & "$licExe" /LicenseServer "$LicenseServer" /Port "$Port" 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[WARN] en_GaioLicClient.exe exit code $LASTEXITCODE (continuing to set env)."
        } else {
            Write-Host "[OK] License client executed."
        }
    } else {
        Write-Host "[WARN] en_GaioLicClient.exe not found. Proceeding to set env only."
    }

    # 3) Then set env variable (persist + current session)
    $envValue = "$Port@$LicenseServer"

    # Try Machine scope first; if it fails (non-admin), fallback to User
    & setx GAIOTEC_LICENSE_FILE $envValue /M | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] setx (Machine): GAIOTEC_LICENSE_FILE = $envValue"
    } else {
        Write-Host "[WARN] setx /M failed (exit=$LASTEXITCODE). Falling back to User scope..."
        & setx GAIOTEC_LICENSE_FILE $envValue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] setx (User): GAIOTEC_LICENSE_FILE = $envValue"
        } else {
            Write-Host "[ERROR] setx failed in both Machine and User scopes (exit=$LASTEXITCODE)."
        }
    }

    # Current session
    $env:GAIOTEC_LICENSE_FILE = $envValue
    Write-Host "[OK] Current session: GAIOTEC_LICENSE_FILE = $env:GAIOTEC_LICENSE_FILE"
}

function Test-CommandExists($cmd) {
  return Get-Command $cmd -ErrorAction SilentlyContinue
}

function Install-Choco {
  if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "[SETUP] Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
      'https://community.chocolatey.org/install.ps1'))
  }
}

function Ensure-BuildTools {
  Install-Choco

  Write-Host ""
  Write-Host "================================================"
  Write-Host "Checking build tools"
  Write-Host "================================================"

  # ---------------- CMAKE ----------------
  if (!(Test-CommandExists "cmake")) {
    Write-Host "[SETUP] Installing cmake..."
    choco install cmake -y --no-progress
  }
  $cmakeVer = & cmake --version 2>$null | Select-Object -First 1
  if ($cmakeVer) {
    Write-Host "[OK] $cmakeVer"
  } else {
    Write-Host "[WARN] cmake not detected in PATH"
  }

  # ---------------- NINJA ----------------
  if (!(Test-CommandExists "ninja")) {
    Write-Host "[SETUP] Installing ninja..."
    choco install ninja -y --no-progress
  }
  $ninjaVer = & ninja --version 2>$null
  if ($ninjaVer) {
    Write-Host "[OK] ninja version $ninjaVer"
  }

  # ---------------- MAKE ----------------
  if (!(Test-CommandExists "make")) {
    Write-Host "[SETUP] Installing make..."
    choco install make -y --no-progress

    # Refresh PATH in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
  }
  $makeVer = & make --version 2>$null | Select-Object -First 1
  if ($makeVer) {
    Write-Host "[OK] $makeVer"
  } else {
    Write-Host "[WARN] make not detected in PATH"
    Write-Host "[HINT] Try restarting PowerShell or run: choco install make"
  }

  # ---------------- ARM GCC ----------------
  if (!(Test-CommandExists "arm-none-eabi-gcc")) {
    Write-Host "[SETUP] Installing ARM GCC (arm-none-eabi-gcc)..."
    choco install arm-none-eabi-gcc -y --no-progress

    # Refresh PATH in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
  }
  $armVer = & arm-none-eabi-gcc --version 2>$null | Select-Object -First 1
  if ($armVer) {
    Write-Host "[OK] $armVer"
  } else {
    Write-Host "[WARN] ARM GCC not detected in PATH"
    Write-Host "[HINT] Restart PowerShell or check: choco install arm-none-eabi-gcc"
  }

  Write-Host "================================================"
  Write-Host "Build tool verification complete"
  Write-Host "================================================"
}

function Install-WinAMS {
  <#
    Enhancements:
      - Extract the outer en.zip to %TEMP%\winams_install
      - Detect & extract nested GaioLicenseClientInstaller_en_V2.0.zip under ...\en
      - Return the *bin folder* where en_GaioLicClient.exe is found (or $null)
  #>
  if (Get-Command "AMSCommand.exe" -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] winAMS already installed"
    return $null
  }

  if (-not $WinAMSZip) {
    Write-Host ""
    Write-Host "Enter path to winAMS en.zip :"
    $script:WinAMSZip = Read-Host
  }

  if (!(Test-Path $WinAMSZip)) {
    Write-Host "[FATAL] en.zip not found : $WinAMSZip"
    exit 1
  }

  $temp = "$env:TEMP\winams_install"
  if (Test-Path $temp) {
    Remove-Item $temp -Recurse -Force
  }
  New-Item -ItemType Directory -Path $temp | Out-Null

  Write-Host "[SETUP] Extracting winAMS..."
  Expand-Archive $WinAMSZip -DestinationPath $temp -Force

  # Detect nested zip under ...\en and extract it
  $innerZip = Get-ChildItem -Path (Join-Path $temp 'en') -Recurse -Filter *.zip -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -like 'GaioLicenseClientInstaller_en_*.zip'
  } | Select-Object -First 1

  $gaioBinPath = $null
  if ($innerZip) {
    Write-Host "[SETUP] Found nested zip: $($innerZip.FullName)"
    $innerDest = Join-Path $temp "en_inner"
    if (Test-Path $innerDest) { Remove-Item $innerDest -Recurse -Force }
    New-Item -ItemType Directory -Path $innerDest | Out-Null

    Write-Host "[SETUP] Extracting nested zip..."
    Expand-Archive -LiteralPath $innerZip.FullName -DestinationPath $innerDest -Force

    # Try to locate en_GaioLicClient.exe under the inner extraction
    $licExe = Get-ChildItem -Path $innerDest -Recurse -Filter en_GaioLicClient.exe -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($licExe) {
      $gaioBinPath = Split-Path -Parent $licExe.FullName
      Write-Host "[INFO] License client located in inner zip at: $gaioBinPath"
    }
  }

  # Proceed with installer from outer extraction
  $setup = Get-ChildItem $temp -Recurse -Filter *.exe -File | Where-Object { $_.Name -notlike 'en_GaioLicClient.exe' } | Select-Object -First 1
  if (-not $setup) {
    Write-Host "[FATAL] Installer EXE not found inside zip"
    exit 1
  }

  Write-Host "[SETUP] Installing winAMS..."
  Start-Process $setup.FullName -ArgumentList "/S" -Wait
  Write-Host "[SETUP] winAMS installation completed"

  # If we haven't found a bin path yet, try outer 'en' content
  if (-not $gaioBinPath) {
    $licExeOuter = Get-ChildItem -Path (Join-Path $temp 'en') -Recurse -Filter en_GaioLicClient.exe -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($licExeOuter) {
      $gaioBinPath = Split-Path -Parent $licExeOuter.FullName
      Write-Host "[INFO] License client located under outer 'en' at: $gaioBinPath"
    }
  }

  return $gaioBinPath
}

function Write-Blank { Write-Host "" }

function Show-Usage {
  Write-Host "  $([System.IO.Path]::GetFileName($PSCommandPath)) <PROJECT_FOLDER> <SETTINGS> <SOURCE_LIST_FILE> <SPMC_DIR_LIST> [BUILD_MODE] [BUILD_PATH] [TOOLCHAIN_FILE] [CSV_FILE] [SETTINGS_AMSO]"
  Write-Blank
  Write-Host "  Examples:"
  Write-Host "    MAKE :"
  Write-Host "      $([System.IO.Path]::GetFileName($PSCommandPath)) C:\src\proj C:\cfg\case_player.vopt C:\cfg\source_list.txt C:\cfg\spmc_dir_list.txt `"
  Write-Host "        make C:\caseviewer\proj_caseviewer\proj\build demo_func1.csv C:\cfg\AmsProjSave.amso"
  Write-Blank
  Write-Host "    CMAKE:"
  Write-Host "      $([System.IO.Path]::GetFileName($PSCommandPath)) C:\src\proj C:\cfg\case_player.vopt C:\cfg\source_list.txt C:\cfg\spmc_dir_list.txt `"
  Write-Host "        cmake C:\caseviewer\proj_caseviewer\proj\build ..\toolchain.cmake demo_func1.csv C:\cfg\AmsProjSave.amso"
}

function Exit-Err([int]$code) {
  Write-Blank
  Write-Host "================================================"
  Write-Host "[ERROR] Command failed with errorlevel $code"
  Write-Host "================================================"
  $e = New-Object System.Management.Automation.RuntimeException "RunFailed"
  $e.Data["ErrCode"] = $code
  throw $e
}

function Exec-Logged([string]$CommandLine, [string]$LogFile) {
  try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
  if ([string]::IsNullOrWhiteSpace($LogFile)) {
    & cmd.exe /c $CommandLine 2>&1 | Out-Host
  } else {
    & cmd.exe /c $CommandLine 2>&1 | Tee-Object -FilePath $LogFile -Append | Out-Host
  }
  $code = $LASTEXITCODE

  if ($code -ne 0) {
    $isAMS  = $CommandLine -match '(^|\s)AMSCommand\.exe\b'
    $isCase = $CommandLine -match '(^|\s)CaseCommand\.exe\b'

    if ($isAMS) {
      Write-Blank
      Write-Host "[ERROR] AMSCommand failed with errorlevel $code"
      if ($env:AMSCOMMAND_LOG) {
        Write-Host "[HINT] Check WinAMS SST logs at:"
        Write-Host ("       {0}" -f $env:AMSCOMMAND_LOG)
        Write-Host ("       ACmdErrorLog.txt : {0}" -f (Join-Path $env:AMSCOMMAND_LOG 'ACmdErrorLog.txt'))
        Write-Host ("       AmsErrorLog.txt  : {0}" -f (Join-Path $env:AMSCOMMAND_LOG 'AmsErrorLog.txt'))
        if ($env:GAIO_SCLI_LOG_SAVE -eq '1') {
          Write-Host "       (Preserved) systemg.log / sx.log are in the same folder"
        } else {
          Write-Host "       Tip: Set GAIO_SCLI_LOG_SAVE=1 to preserve simulator logs"
        }
      } else {
        Write-Host "       (No AMSCOMMAND_LOG set; ACmdErrorLog.txt is in current directory.)"
      }
    }

    if ($isCase) {
      Write-Blank
      Write-Host "[ERROR] CaseCommand failed with errorlevel $code"
      if ($env:CASECOMMAND_LOG) {
        Write-Host "[HINT] Check CaseViewer logs at:"
        Write-Host ("       {0}" -f $env:CASECOMMAND_LOG)
      } else {
        Write-Host "       (No CASECOMMAND_LOG set; CaseViewer log(s) are in current directory.)"
      }
    }

    Exit-Err $code
  }
}

function Exec-Logged-NoThrow([string]$CommandLine, [string]$LogFile) {
  try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
  if ([string]::IsNullOrWhiteSpace($LogFile)) {
    & cmd.exe /c $CommandLine 2>&1 | Out-Host
  } else {
    & cmd.exe /c $CommandLine 2>&1 | Tee-Object -FilePath $LogFile -Append | Out-Host
  }
  return $LASTEXITCODE
}

function Exec-RoboCopy([string]$Source, [string]$Dest, [string]$Args, [string]$LogFile) {
  try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
  $cmd = "robocopy `"$Source`" `"$Dest`" $Args"
  & cmd.exe /c $cmd 2>&1 | Out-Null

  $code = $LASTEXITCODE
  if ($code -ge 8) { Exit-Err $code }
}

function Remove-Directory-Safe([string]$PathToDelete, [string]$LabelForEcho) {
  if ([string]::IsNullOrWhiteSpace($PathToDelete)) {
    Write-Host "[FATAL] $LabelForEcho is empty. Abort delete."
    Exit-Err 1
  }
  $resolved = Resolve-Path -LiteralPath $PathToDelete -ErrorAction SilentlyContinue
  if ($resolved) {
    $root = [System.IO.Path]::GetPathRoot($resolved.Path)
    if ($root.TrimEnd('\') -eq $resolved.Path.TrimEnd('\')) {
      Write-Host "[FATAL] $LabelForEcho appears to be a drive root. Abort delete."
      Exit-Err 1
    }
  }
  if (Test-Path -LiteralPath $PathToDelete) {
    Write-Host "  [X] Deleting existing project folder:"
    Write-Host "      $PathToDelete"
    try {
      Get-ChildItem -LiteralPath $PathToDelete -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try { attrib -R -S -H $_.FullName 2>$null } catch {}
      }
      attrib -R -S -H $PathToDelete 2>$null
      Remove-Item -LiteralPath $PathToDelete -Recurse -Force -ErrorAction Stop
      Write-Host "  [OK] Deleted: $PathToDelete"
    } catch {
      Write-Host "  [ERROR] Failed to delete: $PathToDelete"
      Exit-Err 1
    }
  }
}

function Initialize-SSTLogging {
  param([string]$AppName)

  $SCRIPT_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
  $base = Join-Path $SCRIPT_DIR "log_AMScommand"
  $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
  $runDir = Join-Path (Join-Path $base $AppName) $stamp

  if (-not (Test-Path -LiteralPath $runDir)) {
    New-Item -ItemType Directory -Path $runDir -Force | Out-Null
  }

  $env:AMSCOMMAND_LOG = $runDir
  $env:GAIO_SCLI_LOG_SAVE = "1"

  [System.Environment]::SetEnvironmentVariable('AMSCOMMAND_LOG', $runDir, 'Process')
  [System.Environment]::SetEnvironmentVariable('GAIO_SCLI_LOG_SAVE', '1', 'Process')

  Write-Host "[LOG] AMSCOMMAND_LOG set to: $env:AMSCOMMAND_LOG"
  Write-Host "[LOG] GAIO_SCLI_LOG_SAVE=1 (systemg.log/sx.log preserved under this folder)"
  return $runDir
}

function RUN_SINGLE {
  param(
    [string]$PROJECT_FOLDER,
    [string]$SETTINGS,
    [string]$SOURCE_LIST_FILE,
    [string]$SPMC_DIR_LIST,
    [string]$BUILD_MODE,
    [string]$BUILD_PATH,
    [string]$TOOLCHAIN_FILE,
    [string]$SST_CSV_FILE,
    [string]$SST_SETTINGS_AMSO
  )
  try {
    Write-Blank
    Write-Host "=============================================================================="
    Write-Host "           R CORE WINAMS UNIT TEST SCRIPT"
    Write-Host "=============================================================================="

    # ===== Presence check for positional args =====
    if ([string]::IsNullOrWhiteSpace($PROJECT_FOLDER)) { Show-Usage; return 2 }
    if ([string]::IsNullOrWhiteSpace($SETTINGS)) { Show-Usage; return 2 }
    if ([string]::IsNullOrWhiteSpace($SOURCE_LIST_FILE)) { Show-Usage; return 2 }
    if ([string]::IsNullOrWhiteSpace($SPMC_DIR_LIST)) { Show-Usage; return 2 }
    if ($BUILD_MODE) {
      if ($BUILD_MODE -ieq 'cmake') {
        if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) { Show-Usage; return 2 }
        if ([string]::IsNullOrWhiteSpace($SST_CSV_FILE)) { Show-Usage; return 2 }
        if ([string]::IsNullOrWhiteSpace($SST_SETTINGS_AMSO)) { Show-Usage; return 2 }
      } elseif ($BUILD_MODE -ieq 'make') {
        if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) { Show-Usage; return 2 }
        if ([string]::IsNullOrWhiteSpace($SST_CSV_FILE)) { Show-Usage; return 2 }
        if ([string]::IsNullOrWhiteSpace($SST_SETTINGS_AMSO)) { Show-Usage; return 2 }
      } else {
        Show-Usage; return 2
      }
    }

    # ===================== SANITY CHECK =====================
    if (-not (Test-Path -LiteralPath $PROJECT_FOLDER)) {
      Write-Host "[FATAL] Project folder not found: $PROJECT_FOLDER"
      return 1
    }
    if (-not (Test-Path -LiteralPath $SETTINGS)) {
      Write-Host "[FATAL] CaseViewer settings (.vopt) not found: $SETTINGS"
      return 1
    }
    if (-not (Test-Path -LiteralPath $SOURCE_LIST_FILE)) {
      Write-Host "[FATAL] Source list file not found: $SOURCE_LIST_FILE"
      return 1
    }
    if (-not (Test-Path -LiteralPath $SPMC_DIR_LIST)) {
      Write-Host "[FATAL] SPMC dir list (.csv) not found: $SPMC_DIR_LIST"
      return 1
    }

    if ($BUILD_MODE) {
      if ($BUILD_MODE -ieq 'cmake') {
        if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) {
          Write-Host "[FATAL] BUILD_PATH not provided for cmake mode."
          return 1
        }
        if ($TOOLCHAIN_FILE) {
          if (-not (Test-Path -LiteralPath $TOOLCHAIN_FILE)) {
            Write-Host "[FATAL] Toolchain file not found: $TOOLCHAIN_FILE"
            return 1
          }
        }
      } elseif ($BUILD_MODE -ieq 'make') {
        if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) {
          Write-Host "[FATAL] BUILD_PATH not provided for make mode."
          return 1
        }
      } else {
        Write-Host "[FATAL] BUILD_MODE must be ""cmake"" or ""make"". Got: $BUILD_MODE"
        return 1
      }

      if ([string]::IsNullOrWhiteSpace($SST_CSV_FILE)) {
        Write-Host "[FATAL] SST_CSV_FILE not provided."
        return 1
      }
      if ([string]::IsNullOrWhiteSpace($SST_SETTINGS_AMSO)) {
        Write-Host "[FATAL] SETTINGS_AMSO not provided."
        return 1
      }
    }

    Write-Host "----------------------------------------------------------------------"
    Write-Host "  Project folder : $PROJECT_FOLDER"
    Write-Host "  Settings file  : $SETTINGS"
    Write-Host "  Source list    : $SOURCE_LIST_FILE"
    Write-Host "  SPMC dir list  : $SPMC_DIR_LIST"
    Write-Host "  Build mode     : $BUILD_MODE"
    Write-Host "  Build path     : $BUILD_PATH"
    if ($BUILD_MODE -ieq 'cmake') { Write-Host "  Toolchain file : $TOOLCHAIN_FILE" }
    Write-Host "  SST CSV file   : $SST_CSV_FILE"
    Write-Host "  Settings (.amso): $SST_SETTINGS_AMSO"
    Write-Host "----------------------------------------------------------------------"
    Write-Blank

    # ===================== ENV & LOGS =====================
    $env:PATH = "$env:PATH;C:\Program Files (x86)\gaio\CasePlayer2\bin"
    $SCRIPT_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

    $LOG_ROOT = Join-Path $SCRIPT_DIR "log_CaseCommand"
    if (-not (Test-Path $LOG_ROOT)) { New-Item -ItemType Directory -Path $LOG_ROOT | Out-Null }
    $env:CASE_LOGDIR     = $LOG_ROOT
    $env:CASECOMMAND_LOG = $LOG_ROOT

    # Normalize
    if ($PROJECT_FOLDER.EndsWith("\")) { $PROJECT_FOLDER = $PROJECT_FOLDER.TrimEnd('\') }
    $USER_SRC_ROOT = $PROJECT_FOLDER

    # Extract app name and parent from the given path
    $APP_NAME   = Split-Path -Path $PROJECT_FOLDER -Leaf
    $PARENT_DIR = Split-Path -Path $PROJECT_FOLDER -Parent

    # Normalize to *_caseviewer
    if ($APP_NAME -like '*_caseviewer') {
      # Already a caseviewer folder
    } else {
      $PROJECT_FOLDER = Join-Path $PARENT_DIR ("{0}_caseviewer" -f $APP_NAME)
      Write-Host "[Info] Treating input as user source root. Derived CaseViewer project:"
      Write-Host ("       APP_NAME      : {0}" -f $APP_NAME)
      Write-Host ("       PROJECT_FOLDER: {0}" -f $PROJECT_FOLDER)
      Write-Blank
    }

    # ------------------- LOG FILE SETUP -------------------
    $D = (Get-Date).ToString('yyyyMMdd')
    $T = (Get-Date).ToString('HHmmss')
    $LOG_DIR  = Join-Path $SCRIPT_DIR ("log\{0}" -f $APP_NAME)
    if (-not (Test-Path $LOG_DIR)) { New-Item -ItemType Directory -Path $LOG_DIR | Out-Null }
    $LOG_FILE = Join-Path $LOG_DIR ("{0}_{1}_{2}.log" -f $APP_NAME, $D, $T)
    Write-Host ('Logging to: "{0}"' -f $LOG_FILE)
    Write-Blank

    Write-Host "-------------------------------------------------------"
    Write-Host "===================== STEP X.0 HOOK CODE GENERATION WITH CASECOMMAND ====================="

    # ===================== DERIVE .vproj FROM PROJECT_FOLDER =====================
    if ($PROJECT_FOLDER.EndsWith("\")) { $PROJECT_FOLDER = $PROJECT_FOLDER.TrimEnd('\') }
    $PROJECT_NAME = Split-Path -Path $PROJECT_FOLDER -Leaf
    $VPROJ = Join-Path $PROJECT_FOLDER ("{0}.vproj" -f $PROJECT_NAME)
    Write-Host "----------------------------------------------------------------------"
    Write-Host "  Project (.vproj) : $VPROJ"
    Write-Host "  Settings (.vopt) : $SETTINGS"
    Write-Host "  Source list      : $SOURCE_LIST_FILE"
    Write-Host "  SPMC dir list    : $SPMC_DIR_LIST"
    Write-Host "----------------------------------------------------------------------"

    STEP_X0 -PROJECT_FOLDER $PROJECT_FOLDER -SETTINGS $SETTINGS -SOURCE_LIST_FILE $SOURCE_LIST_FILE -SPMC_DIR_LIST $SPMC_DIR_LIST -VPROJ $VPROJ -LOG_FILE $LOG_FILE -LOG_ROOT $LOG_ROOT
    STEP_X1 -PROJECT_FOLDER $PROJECT_FOLDER -APP_NAME $APP_NAME -USER_SRC_ROOT $USER_SRC_ROOT -SPMC_DIR_LIST $SPMC_DIR_LIST -LOG_FILE $LOG_FILE
    STEP_X2 -BUILD_MODE $BUILD_MODE -BUILD_PATH $BUILD_PATH -TOOLCHAIN_FILE $TOOLCHAIN_FILE -TARGET_ROOT (Join-Path $PROJECT_FOLDER $APP_NAME) -LOG_FILE $LOG_FILE
    STEP_X3 -PROJECT_FOLDER $PROJECT_FOLDER -APP_NAME $APP_NAME -BUILD_PATH $BUILD_PATH -SST_CSV_FILE $SST_CSV_FILE -SST_SETTINGS_AMSO $SST_SETTINGS_AMSO -LOG_FILE $LOG_FILE

    return 0
  }
  catch {
    $code = 1
    if ($_.Exception -and $_.Exception.Data.Contains("ErrCode")) {
      $code = [int]$_.Exception.Data["ErrCode"]
    }
    return $code
  }
}

function STEP_X0 {
  param(
    [string]$PROJECT_FOLDER,[string]$SETTINGS,[string]$SOURCE_LIST_FILE,[string]$SPMC_DIR_LIST,
    [string]$VPROJ,[string]$LOG_FILE,[string]$LOG_ROOT
  )

  Exec-Logged "CaseCommand.exe -endCP2" $LOG_FILE

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 1: Create project from settings (with license-safe retry)"
  if (Test-Path -LiteralPath $PROJECT_FOLDER) {
    Write-Host "----------------------------------------------------------------------"
    Write-Host "[X] Deleting existing project folder:"
    Write-Host "    $PROJECT_FOLDER"
    Write-Host "----------------------------------------------------------------------"
    Remove-Directory-Safe -PathToDelete $PROJECT_FOLDER -LabelForEcho "PROJECT_FOLDER"
  }

  Write-Host "  Command: CaseCommand.exe -crtprojimport $SETTINGS $PROJECT_FOLDER"
  $code = Exec-Logged-NoThrow "CaseCommand.exe -crtprojimport `"$SETTINGS`" `"$PROJECT_FOLDER`"" $LOG_FILE
  if ($code -ne 0) {
    Write-Host "[WARN] CaseViewer init/profile step failed - attempting to kill and retry once..."
    & taskkill /IM CaseViewer.exe /F /T 2>$null | Out-Null
    Start-Sleep -Seconds 3
    $code = Exec-Logged-NoThrow "CaseCommand.exe -crtprojimport `"$SETTINGS`" `"$PROJECT_FOLDER`"" $LOG_FILE
    if ($code -ne 0) {
      Write-Host "[FATAL] Retry failed again. Aborting CaseViewer initialization."
      if ($env:CASECOMMAND_LOG) {
        Write-Host "[HINT] Check CaseViewer logs at:"
        Write-Host ("       {0}" -f $env:CASECOMMAND_LOG)
      } else {
        Write-Host "       (No CASECOMMAND_LOG set; CaseViewer log(s) are in current directory.)"
      }
      Exit-Err $code
    }
  }
  Write-Host "  Result : Project created and CPU/Compiler profile set."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 2: Set CPU and compiler profile (CortexR52 + armclang)"
  Write-Host "Command: CaseCommand.exe -cpucpl CortexR52 armclang $VPROJ"
  Exec-Logged "CaseCommand.exe -cpucpl CortexR52 armclang `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : CPU/Compiler profile set."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 3: Clear registered sources/headers"
  Write-Host "Command: CaseCommand.exe -clr $VPROJ"
  Exec-Logged "CaseCommand.exe -clr `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Sources cleared."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 4: Register sources from list"
  Write-Host "Command: CaseCommand.exe -a $SOURCE_LIST_FILE $VPROJ"
  Exec-Logged "CaseCommand.exe -a `"$SOURCE_LIST_FILE`" `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Sources registered from list."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 5: Run analysis / create document"
  Write-Host "Command: CaseCommand.exe -r $VPROJ"
  Exec-Logged "CaseCommand.exe -r `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Analysis completed / document created."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 6: Generate dummy functions for undefined references"
  Write-Host "Command: CaseCommand.exe -putdmyfunc $VPROJ"
  Exec-Logged "CaseCommand.exe -putdmyfunc `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Dummy functions generated."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 7: Enable hook code flags (SPMC_OUTCODE, SPMC_AUTOCOPY)"
  Write-Host "Command: CaseCommand.exe -set_rev ""SPMC_OUTCODE=1;SPMC_AUTOCOPY=1"" $VPROJ"
  Exec-Logged "CaseCommand.exe -set_rev `"SPMC_OUTCODE=1;SPMC_AUTOCOPY=1`" `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Hook code flags enabled."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 8: Mark all files as SPMC targets"
  Write-Host "Command: CaseCommand.exe -allspmc $VPROJ"
  Exec-Logged "CaseCommand.exe -allspmc `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : All files marked for SPMC."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 9: Configure SPMC directory list"
  Write-Host "Command: CaseCommand.exe -spmcDir $SPMC_DIR_LIST $VPROJ"
  Exec-Logged "CaseCommand.exe -spmcDir `"$SPMC_DIR_LIST`" `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : SPMC directory list configured."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 10: Copy SPMC environment"
  Write-Host "Command: CaseCommand.exe -spmcCopy $VPROJ"
  Exec-Logged "CaseCommand.exe -spmcCopy `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : SPMC environment copied."
  Write-Blank

  Write-Host "STEP 11: ReRun analysis / Recreate document"
  Write-Host "Command: CaseCommand.exe -r $VPROJ"
  Exec-Logged "CaseCommand.exe -r `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Analysis completed / document created."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 12: Build hook code (m then H)"
  Write-Host "Command: CaseCommand.exe -m $VPROJ"
  Exec-Logged "CaseCommand.exe -m `"$VPROJ`"" $LOG_FILE
  Write-Host "Command: CaseCommand.exe -H $VPROJ"
  Exec-Logged "CaseCommand.exe -H `"$VPROJ`"" $LOG_FILE
  Write-Host "Result : Hook code build completed."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "FINAL: End silent Case session"
  Write-Host "Command: CaseCommand.exe -endCP2"
  Exec-Logged "CaseCommand.exe -endCP2" $LOG_FILE
  Write-Host "Result : Silent session closed."
  Write-Blank
  Write-Host "================================================"
  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP X.0 Completed: HOOK CODE GENERATION WITH CASECOMMAND finished"
  Write-Host "----------------------------------------------------------------------"
  Write-Host "  Project: $PROJECT_FOLDER"
  Write-Host "  VProj  : $VPROJ"
  Write-Host "  Logs   : $LOG_ROOT"
  Write-Host "================================================"
  Write-Blank
}

function STEP_X1 {
  param(
    [string]$PROJECT_FOLDER,[string]$APP_NAME,[string]$USER_SRC_ROOT,[string]$SPMC_DIR_LIST,[string]$LOG_FILE
  )

  $TARGET_ROOT = Join-Path $PROJECT_FOLDER $APP_NAME

  Write-Host "======================================================================"
  Write-Host " STEP X.1: Copy user project into CaseViewer project"
  Write-Host "======================================================================"
  Write-Host "Source : $USER_SRC_ROOT"
  Write-Host "Target : $TARGET_ROOT"

  if (-not (Test-Path -LiteralPath $TARGET_ROOT)) {
    try { New-Item -ItemType Directory -Path $TARGET_ROOT | Out-Null } catch {}
  }

  # 1) Full project copy (silent)
  Exec-RoboCopy `
    -Source $USER_SRC_ROOT `
    -Dest   $TARGET_ROOT `
    -Args   "/E /R:1 /W:1 /COPY:DAT /DCOPY:DAT /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP" `
    -LogFile $LOG_FILE

  Write-Host "Copy done."

  # --- Post-copy assurance for src dir (silent) ---
  $srcSrcDir    = Join-Path $USER_SRC_ROOT "src"
  $targetSrcDir = Join-Path $TARGET_ROOT   "src"

  if (Test-Path -LiteralPath $srcSrcDir) {
    $srcHasCode    = @(Get-ChildItem -Path $srcSrcDir -Recurse -Include *.c,*.h -File -ErrorAction SilentlyContinue).Count -gt 0
    $targetHasCode = @(Get-ChildItem -Path $targetSrcDir -Recurse -Include *.c,*.h -File -ErrorAction SilentlyContinue).Count -gt 0

    if ($srcHasCode -and -not $targetHasCode) {
      Exec-RoboCopy `
        -Source $srcSrcDir `
        -Dest   $targetSrcDir `
        -Args   "/E /R:1 /W:1 /COPY:DAT /DCOPY:DAT /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP" `
        -LogFile $LOG_FILE
    }
  }

  # 1a) Ensure Makefile if make build expected
  $targetMake = Join-Path $TARGET_ROOT "build\Makefile"
  if (-not (Test-Path -LiteralPath $targetMake)) {
    $srcBuild = Join-Path $USER_SRC_ROOT "build"
    if (Test-Path -LiteralPath $srcBuild) {
      Exec-RoboCopy `
        -Source $srcBuild `
        -Dest   (Join-Path $TARGET_ROOT "build") `
        -Args   "/E /R:1 /W:1 /COPY:DAT /DCOPY:DAT /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP" `
        -LogFile $LOG_FILE
    }
  }

  # 2) Resolve HOOK_SRC_DIR from SPMC CSV (tokens=2, delims=,)
  $HOOK_SRC_DIR = ""
  if (Test-Path -LiteralPath $SPMC_DIR_LIST) {
    $firstLine = (Get-Content -LiteralPath $SPMC_DIR_LIST | Select-Object -First 1)
    if ($firstLine) {
      $parts = $firstLine -split ','
      if ($parts.Count -ge 2) {
        $HOOK_SRC_DIR = $parts[1].Trim('"')
      }
    }
  }

  Write-Host "Hook Source: $HOOK_SRC_DIR"
  if (-not (Test-Path -LiteralPath $HOOK_SRC_DIR)) {
    Write-Host "[ERROR] Hook source path does not exist: $HOOK_SRC_DIR"
    Write-Host "STEP X.1 Completed."
    Write-Host "======================================================================"
    Write-Blank
    return
  }

  # Ensure <TARGET_ROOT>\src exists
  $targetSrc = Join-Path $TARGET_ROOT "src"
  if (-not (Test-Path -LiteralPath $targetSrc)) {
    try { New-Item -ItemType Directory -Path $targetSrc | Out-Null } catch {}
  }

  # 3) Replace matching .c files by filename
  Write-Host "Replacing .c files..."
  Get-ChildItem -Path $TARGET_ROOT -Recurse -Filter *.c -File -ErrorAction SilentlyContinue | ForEach-Object {
    $destFile = $_.FullName
    $name = $_.Name
    $hooks = Get-ChildItem -Path $HOOK_SRC_DIR -Recurse -Filter $name -File -ErrorAction SilentlyContinue
    foreach ($h in $hooks) {
      try { attrib -R -S -H $destFile 2>$null } catch {}
      Exec-Logged "copy /Y `"$($h.FullName)`" `"$destFile`"" $LOG_FILE
    }
  }

  # 4) Replace matching .h files by filename
  Write-Host "Replacing .h files..."
  Get-ChildItem -Path $TARGET_ROOT -Recurse -Filter *.h -File -ErrorAction SilentlyContinue | ForEach-Object {
    $destFile = $_.FullName
    $name = $_.Name
    $hooks = Get-ChildItem -Path $HOOK_SRC_DIR -Recurse -Filter $name -File -ErrorAction SilentlyContinue
    foreach ($h in $hooks) {
      try { attrib -R -S -H $destFile 2>$null } catch {}
      Exec-Logged "copy /Y `"$($h.FullName)`" `"$destFile`"" $LOG_FILE
    }
  }

  # 5) Copy winAMS_Spmc* into <target>\src
  Write-Host "Copying winAMS_Spmc* files..."
  Get-ChildItem -Path $HOOK_SRC_DIR -Recurse -Filter "winAMS_Spmc*" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $dest = Join-Path $targetSrc $_.Name
    Exec-Logged "copy /Y `"$($_.FullName)`" `"$dest`"" $LOG_FILE
  }

  Write-Host "STEP X.1 Completed."
  Write-Host "======================================================================"
  Write-Blank
}

function STEP_X2 {
  param(
    [string]$BUILD_MODE,[string]$BUILD_PATH,[string]$TOOLCHAIN_FILE,[string]$TARGET_ROOT,[string]$LOG_FILE
  )

  Write-Host "======================================================================"
  Write-Host "STEP X.2: Build"
  Write-Host "  MODE : $BUILD_MODE"
  Write-Host "  PATH : $BUILD_PATH"
  if ($BUILD_MODE -ieq 'cmake') { Write-Host "  TOOL : $TOOLCHAIN_FILE" }
  Write-Blank

  if ([string]::IsNullOrWhiteSpace($BUILD_MODE)) {
    Write-Host "[INFO] No build args passed. Skipping STEP X.2."
    Write-Host "======================================================================"
    Write-Blank
    return
  }

  if ($BUILD_MODE -ieq 'cmake') {
    if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) { Write-Host "[ERROR] CMake BUILD_PATH required"; Exit-Err 1 }
    if ([string]::IsNullOrWhiteSpace($TOOLCHAIN_FILE)) { $TOOLCHAIN_FILE = "..\toolchain.cmake" }

    if (-not (Test-Path -LiteralPath $BUILD_PATH)) { New-Item -ItemType Directory -Path $BUILD_PATH | Out-Null }
    Push-Location $BUILD_PATH
    Write-Host "cmake .. -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE"
    Exec-Logged "cmake .. -DCMAKE_TOOLCHAIN_FILE=`"$TOOLCHAIN_FILE`"" $LOG_FILE

    Write-Host "cmake --build ."
    Exec-Logged "cmake --build ." $LOG_FILE

    Pop-Location
    Write-Host "[CMAKE] Done."
    Write-Host "======================================================================"
    Write-Blank
    return
  }

  if ($BUILD_MODE -ieq 'make') {
    if ([string]::IsNullOrWhiteSpace($BUILD_PATH)) { Write-Host "[ERROR] MAKE PATH required"; Exit-Err 1 }

    if (-not (Test-Path -LiteralPath (Join-Path $BUILD_PATH 'Makefile'))) {
      Write-Host "[ERROR] Makefile not found in $BUILD_PATH"
      Exit-Err 1
    }

    Push-Location $BUILD_PATH
    Write-Host "make"
    Exec-Logged "make" $LOG_FILE
    Pop-Location

    Write-Host "[MAKE] Done."
    Write-Host " .elf file Generated Successfully !"
    Write-Blank
    Write-Host "======================================================================"
    return
  }

  Write-Host '[ERROR] BUILD_MODE must be "cmake" or "make"'
  Exit-Err 1
}

function STEP_X3 {
  param(
    [string]$PROJECT_FOLDER,[string]$APP_NAME,[string]$BUILD_PATH,[string]$SST_CSV_FILE,[string]$SST_SETTINGS_AMSO,[string]$LOG_FILE
  )

  Write-Host "======================================================================"
  Write-Host "STEP X.3: SST Manager (AMSCommand)"

  Write-Host "Stopping SST Manager..."
  & taskkill.exe /IM SSTManager.exe /F /T 2>$null | Out-Null
  Write-Host "Process killed successfully."

  $SSTLogRunDir = Initialize-SSTLogging -AppName $APP_NAME

  $CV_PARENT = Split-Path -Parent $PROJECT_FOLDER
  if ($CV_PARENT.EndsWith("\")) {
    $SST_PROJECT_FOLDER = "$CV_PARENT$APP_NAME`_sstManager"
  } else {
    $SST_PROJECT_FOLDER = Join-Path $CV_PARENT ("{0}_sstManager" -f $APP_NAME)
  }
  $SST_AMSY = Join-Path $SST_PROJECT_FOLDER ("{0}_sstManager.amsy" -f $APP_NAME)

  Write-Host "  Derived SST project folder : $SST_PROJECT_FOLDER"
  Write-Host "  Derived .amsy              : $SST_AMSY"
  Write-Host "  CSV_FILE                   : $SST_CSV_FILE"
  Write-Host "  SETTINGS_AMSO              : $SST_SETTINGS_AMSO"
  Write-Blank

  if ([string]::IsNullOrWhiteSpace($SST_CSV_FILE)) { Write-Host "[ERROR] CSV_FILE missing for SST"; Exit-Err 1 }
  if ([string]::IsNullOrWhiteSpace($SST_SETTINGS_AMSO)) { Write-Host "[ERROR] SETTINGS_AMSO missing - expected .amso"; Exit-Err 1 }

  # Find ELF
  $ELF_PATH = $null
  if ($BUILD_PATH) {
    $found = Get-ChildItem -Path $BUILD_PATH -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $ELF_PATH = $found.FullName }
  }
  if (-not $ELF_PATH) {
    $found = Get-ChildItem -Path (Join-Path $PROJECT_FOLDER $APP_NAME) -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $ELF_PATH = $found.FullName }
  }
  if (-not $ELF_PATH) {
    $found = Get-ChildItem -Path (Join-Path (Join-Path $PROJECT_FOLDER $APP_NAME) 'build') -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $ELF_PATH = $found.FullName }
  }
  if (-not $ELF_PATH) {
    Write-Host "[ERROR] No .elf found for SST Manager"
    Exit-Err 1
  }
  Write-Host "Using ELF: $ELF_PATH"

  $env:PATH = "$env:PATH;C:\WinAMS\bin"
  AMSCommand.exe -endAMS | Out-Null

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 1: Create SST Project Folder"

  if (Test-Path -LiteralPath $SST_PROJECT_FOLDER) {
    Write-Host "----------------------------------------------------------------------"
    Write-Host "[X] Deleting existing SST project folder:"
    Write-Host "    $SST_PROJECT_FOLDER"
    Write-Host "----------------------------------------------------------------------"
    Remove-Directory-Safe -PathToDelete $SST_PROJECT_FOLDER -LabelForEcho "SST_PROJECT_FOLDER"
  }

  Write-Host "Command: AMSCommand.exe -crtprojimport $SST_SETTINGS_AMSO $SST_PROJECT_FOLDER"
  Exec-Logged "AMSCommand.exe -crtprojimport `"$SST_SETTINGS_AMSO`" `"$SST_PROJECT_FOLDER`"" $LOG_FILE
  Write-Host "Result : SST project folder ready."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 2: Prepare TestCsv directory (auto copy CSV by filename or path)"
  $TESTCSV_DIR = Join-Path $SST_PROJECT_FOLDER 'TestCsv'
  Write-Host "Command: mkdir `"$TESTCSV_DIR`""
  if (-not (Test-Path -LiteralPath $TESTCSV_DIR)) { New-Item -ItemType Directory -Path $TESTCSV_DIR | Out-Null }

  # Accept CSV list separated by commas, semicolons, or whitespace (also supports wildcards)
  $csvTokens = ($SST_CSV_FILE -split '\s*[;,]\s*|\s+') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

  if ($csvTokens.Count -eq 0) {
    Write-Host "[FATAL] No CSV file names provided in SST_CSV_FILE."
    Exit-Err 1
  }

  $SCRIPT_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
  $SEARCH_BASES = @($SCRIPT_DIR, (Get-Location).Path)

  function Resolve-CsvToken([string]$token) {
    if ([System.IO.Path]::IsPathRooted($token)) {
      if (Test-Path -LiteralPath $token) { return ,(Get-Item -LiteralPath $token) }
      return @()
    }

    $items = @()
    foreach ($base in $SEARCH_BASES) {
      try {
        $match = Get-ChildItem -LiteralPath $base -Filter $token -File -ErrorAction SilentlyContinue
        if ($match) { $items += $match }
      } catch {}
    }

    # If no wildcard match and no * or ? present, probe as relative names
    if (($items.Count -eq 0) -and ($token -notmatch '[\*\?]')) {
      foreach ($base in $SEARCH_BASES) {
        $candidate = Join-Path $base $token
        if (Test-Path -LiteralPath $candidate) {
          return ,(Get-Item -LiteralPath $candidate)
        }
      }
    }

    return $items
  }

  $CsvSources = New-Object System.Collections.Generic.List[System.IO.FileInfo]
  foreach ($tok in $csvTokens) {
    $resolved = Resolve-CsvToken -token $tok
    if ($resolved.Count -eq 0) {
      Write-Host "[ERROR] CSV not found for token: $tok"
      Write-Host "        Checked absolute path, then under: $($SEARCH_BASES -join '; ')"
      Exit-Err 1
    }
    foreach ($f in $resolved) { $CsvSources.Add($f) }
  }

  foreach ($src in $CsvSources) {
    $dst = Join-Path $TESTCSV_DIR $src.Name
    Write-Host "Command: copy `"$($src.FullName)`" `"$dst`""
    Exec-Logged "copy `"$($src.FullName)`" `"$dst`"" $LOG_FILE
  }

  $TESTCSV_FILES = $CsvSources | Select-Object -ExpandProperty Name -Unique
  Write-Host "Result : Copied $($TESTCSV_FILES.Count) CSV file(s) to TestCsv."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 3: Defensive AMS close"
  Write-Host "Command: AMSCommand.exe -endAMS"
  AMSCommand.exe -endAMS | Out-Null
  Write-Host "Result : AMS closed (safe)"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 4: Import ELF (normal)"
  Write-Host "Command: AMSCommand.exe -obj $ELF_PATH $SST_AMSY"
  Exec-Logged "AMSCommand.exe -obj `"$ELF_PATH`" `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : ELF imported (.obj)"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 5: Import ELF (SPMC)"
  Write-Host "Command: AMSCommand.exe -objspmc $ELF_PATH $SST_AMSY"
  Exec-Logged "AMSCommand.exe -objspmc `"$ELF_PATH`" `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : ELF imported for SPMC"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 6: Set end address (main)"
  Write-Host "Command: AMSCommand.exe -iendaddr main $SST_AMSY"
  Exec-Logged "AMSCommand.exe -iendaddr main `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : End address (main) set"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 7: Set end address SPMC (main)"
  Write-Host "Command: AMSCommand.exe -iendaddrspmc main $SST_AMSY"
  Exec-Logged "AMSCommand.exe -iendaddrspmc main `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : End address SPMC (main) set"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 7.A: Auto-generate Startup Command File (post-OBJ/-SPMC/-iendaddr)"
  Write-Host "Command: AMSCommand.exe -crtStartupCom $SST_AMSY"
  $crtCode = Exec-Logged-NoThrow "AMSCommand.exe -crtStartupCom `"$SST_AMSY`"" $LOG_FILE
  if ($crtCode -eq 0) {
    Write-Host "Result : Startup command file generated."
  } else {
    Write-Host "[WARN] -crtStartupCom failed (code=$crtCode). Creating a minimal SS_STARTUP.txt fallback."
    $fallback = @(
      '; Auto-generated fallback startup file (minimal)'
      '; Device: Cortex-R52 - adjust if your device differs.'
      'START LOG/ALL systemg.log'
      '; OPTION -nosem   ; (Uncomment if required by your model)'
      '; Add XAIL etc. if your tests require memory assigns.'
    )
    $fallbackPath = Join-Path $SST_PROJECT_FOLDER 'SS_STARTUP.txt'
    Set-Content -LiteralPath $fallbackPath -Value $fallback -Encoding ASCII
    if (Test-Path -LiteralPath $fallbackPath) {
      Write-Host "[OK] Fallback startup created: $fallbackPath"
    } else {
      Write-Host "[ERROR] Could not create fallback startup at: $fallbackPath"
      Exit-Err 1
    }
  }
  Write-Blank

  $StartupDetected = Get-ChildItem -LiteralPath $SST_PROJECT_FOLDER -Filter 'SS_STARTUP.*' -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $StartupDetected) {
    Write-Host "[ERROR] Startup file not present after -crtStartupCom/fallback."
    Exit-Err 1
  }
  $StartRel = '.\' + $StartupDetected.Name
  Write-Host "[INFO] Using startup file: $StartRel"

  $CaseViewerProjName = Split-Path -Leaf $PROJECT_FOLDER
  $Cp2ProjAbs = Join-Path $PROJECT_FOLDER ("{0}.vproj" -f $CaseViewerProjName)

  function Get-RelativePath([string]$baseDir, [string]$targetPath) {
    try {
      $baseUri   = New-Object System.Uri((Resolve-Path -LiteralPath $baseDir).Path + [IO.Path]::DirectorySeparatorChar)
      $targetUri = New-Object System.Uri((Resolve-Path -LiteralPath $targetPath).Path)
      return $baseUri.MakeRelativeUri($targetUri).ToString().Replace('/', '\')
    } catch { return $targetPath }
  }

  $Cp2ProjRel = if (Test-Path -LiteralPath $Cp2ProjAbs) {
    Get-RelativePath -baseDir $SST_PROJECT_FOLDER -targetPath $Cp2ProjAbs
  } else {
    '.\CaseProj\CaseProj.vproj'
  }

  Write-Host "Command: AMSCommand.exe -set_system_g ""Cp2Proj=$Cp2ProjRel"" $SST_AMSY"
  Exec-Logged "AMSCommand.exe -set_system_g `"Cp2Proj=$Cp2ProjRel`" `"$SST_AMSY`"" $LOG_FILE

  Write-Host "Command: AMSCommand.exe -set_system_g ""Start=$StartRel"" $SST_AMSY"
  Exec-Logged "AMSCommand.exe -set_system_g `"Start=$StartRel`" `"$SST_AMSY`"" $LOG_FILE

  Write-Host "Result : [System_G] Cp2Proj/Start updated."
  Write-Blank

  Write-Host "Command: AMSCommand.exe -set_system_g2spm $SST_AMSY"
  Exec-Logged "AMSCommand.exe -set_system_g2spm `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : Coverage Hook Code target settings updated."
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 8: Configure test-to-SPM mapping"
  Write-Host "Command: AMSCommand.exe -set_test2spm $SST_AMSY"
  Exec-Logged "AMSCommand.exe -set_test2spm `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : Mapping configured"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 9: Set input directory"
  Write-Host "Command: AMSCommand.exe -set_test InDir=$TESTCSV_DIR $SST_AMSY"
  Exec-Logged "AMSCommand.exe -set_test InDir=`"$TESTCSV_DIR`" `"$SST_AMSY`"" $LOG_FILE
  Write-Host "Result : Input directory set"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 10: Run tests on CSV file(s)"
  # With InDir set, -all will execute all CSVs in TestCsv; a single run is enough.
  $cmd = "AMSCommand.exe -b -all `"$SST_AMSY`""
  Exec-Logged $cmd $LOG_FILE
  Write-Host "Result : All CSV test(s) executed successfully"
  Write-Blank

  Write-Host "----------------------------------------------------------------------"
  Write-Host "STEP 11: End AMS session"
  Write-Host "Command: AMSCommand.exe -endAMS"
  AMSCommand.exe -endAMS | Out-Null
  Write-Host "Result : AMS session closed"
  Write-Blank

  Write-Host "STEP X.3 Completed."
  Write-Host "======================================================================"
  Write-Blank

  # ===================== FINAL EXECUTION SUMMARY =====================
  if (-not $ELF_PATH -and $BUILD_PATH) {
    $f = Get-ChildItem -Path $BUILD_PATH -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) { $ELF_PATH = $f.FullName }
  }
  if (-not $ELF_PATH) {
    $f = Get-ChildItem -Path (Join-Path (Join-Path $PROJECT_FOLDER $APP_NAME) 'build') -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) { $ELF_PATH = $f.FullName }
  }
  if (-not $ELF_PATH) {
    $f = Get-ChildItem -Path (Join-Path $PROJECT_FOLDER (Join-Path $APP_NAME 'build')) -Recurse -Filter *.elf -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) { $ELF_PATH = $f.FullName }
  }

  $OUT_DIR = $null
  $latestOut = Get-ChildItem -Path $SST_PROJECT_FOLDER -Directory -Filter "Out*" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($latestOut) { $OUT_DIR = $latestOut.FullName }

  $REPORT_HTML = $null
  if ($OUT_DIR) {
    $rep = Get-ChildItem -Path $OUT_DIR -Recurse -Filter *.html -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($rep) { $REPORT_HTML = $rep.FullName }
  }

  Write-Host "========================================================================"
  Write-Host "  EXECUTION SUMMARY"
  Write-Host "========================================================================"
  Write-Host "  Application     : $APP_NAME   (ELF: $ELF_PATH)"
  if ($SST_AMSY) { Write-Host "  Project (.amsy) : $SST_AMSY" }
  Write-Host "  Project Folder  : $PROJECT_FOLDER"
  if ($TESTCSV_DIR -and $SST_CSV_FILE) {
    Write-Host "  Test CSV Source : $TESTCSV_DIR"
    Write-Host "  CSV Pattern(s)  : $SST_CSV_FILE"
  }
  if ($OUT_DIR) { Write-Host "  Latest Output   : $OUT_DIR" } else { Write-Host "  Latest Output   : (not detected; WinAMS may write results later)" }
  if ($REPORT_HTML) { Write-Host "  Report (HTML)   : $REPORT_HTML" } else { Write-Host "  Report (HTML)   : (not detected in newest Out* folder)" }
  if ($env:AMSCOMMAND_LOG) {
    Write-Host "  AMS Logs        : $env:AMSCOMMAND_LOG"
    Write-Host ("  ACmdErrorLog    : {0}" -f (Join-Path $env:AMSCOMMAND_LOG 'ACmdErrorLog.txt'))
    Write-Host ("  AmsErrorLog     : {0}" -f (Join-Path $env:AMSCOMMAND_LOG 'AmsErrorLog.txt'))
  }
  Write-Host "========================================================================"
  Write-Blank
}

# ========================================================================================
# ================================= MAIN (multi-app loop) =================================
# ========================================================================================

Write-Host "=============================================================================="
Write-Host "R CORE WINAMS UNIT TEST SCRIPT"
Write-Host "=============================================================================="

# --- 1) Ensure build tools are present (Chocolatey-based) ---
try {
  Ensure-BuildTools
} catch {
  Write-Host "[WARN] Ensure-BuildTools failed: $($_.Exception.Message)"
  Write-Host "      Continuing; make sure cmake/make/arm-none-eabi-gcc are in PATH."
}

# --- 2) Install WinAMS if not already installed (and get license bin path) ---
$gaioExtractBin = $null
try {
  $gaioExtractBin = Install-WinAMS
} catch {
  Write-Host "[WARN] Install-WinAMS failed: $($_.Exception.Message)"
  Write-Host "      Continuing; ensure CaseCommand.exe/AMSCommand.exe are available."
}

# --- 3) GAIO License setup (run client first, then set env) ---
try {
  Ensure-GaioLicense -LicenseServer $GaioLicenseServer -Port $GaioLicensePort -GaioBinPath $gaioExtractBin
} catch {
  Write-Host "[WARN] Ensure-GaioLicense failed: $($_.Exception.Message)"
  Write-Host "      Continuing; Case/AMS may fail later if license is not configured."
}

$SUM_COUNT = 0
$Summary   = New-Object System.Collections.Generic.List[string]

# We require --app
if ($args.Count -eq 0 -or $args[0] -ne '--app') {
  Write-Blank
  Write-Host "[ERROR] Expected --app but got ""$($args[0])"""
  exit 1
}

# Argument loop
$i = 0
while ($i -lt $args.Length) {
  if ($args[$i] -ne '--app') {
    Write-Blank
    Write-Host "[ERROR] Expected --app but got ""$($args[$i])"""
    exit 1
  }
  $i++  # consume --app

  # Common parameters
  $PROJ = $args[$i]; $i++
  $VOPT = $args[$i]; $i++
  $SRCL = $args[$i]; $i++
  $SPMC = $args[$i]; $i++
  $MODE = $args[$i]; $i++

  $APP_LABEL = [System.IO.Path]::GetFileNameWithoutExtension($PROJ)

  if ([string]::IsNullOrWhiteSpace($MODE)) {
    Write-Host "[ERROR] Missing BUILD_MODE for $PROJ"
    exit 2
  }

  if ($MODE -ieq 'make') {
    $BUILD = $args[$i]; $i++
    $CSV   = $args[$i]; $i++
    $AMSO  = $args[$i]; $i++

    Write-Blank
    $rc = RUN_SINGLE -PROJECT_FOLDER $PROJ -SETTINGS $VOPT -SOURCE_LIST_FILE $SRCL -SPMC_DIR_LIST $SPMC `
                     -BUILD_MODE 'make' -BUILD_PATH $BUILD -TOOLCHAIN_FILE $null -SST_CSV_FILE $CSV -SST_SETTINGS_AMSO $AMSO

    if ($rc -eq 0) {
      $SUM_COUNT++; $Summary.Add("$APP_LABEL : Executed")
    } else {
      $SUM_COUNT++; $Summary.Add("$APP_LABEL : Failed (skipped)")
    }
    continue
  }

  if ($MODE -ieq 'cmake') {
    $BUILD = $args[$i]; $i++
    $TOOL  = $args[$i]; $i++
    $CSV   = $args[$i]; $i++
    $AMSO  = $args[$i]; $i++

    Write-Blank
    $rc = RUN_SINGLE -PROJECT_FOLDER $PROJ -SETTINGS $VOPT -SOURCE_LIST_FILE $SRCL -SPMC_DIR_LIST $SPMC `
                     -BUILD_MODE 'cmake' -BUILD_PATH $BUILD -TOOLCHAIN_FILE $TOOL -SST_CSV_FILE $CSV -SST_SETTINGS_AMSO $AMSO

    if ($rc -eq 0) {
      $SUM_COUNT++; $Summary.Add("$APP_LABEL : Executed")
    } else {
      $SUM_COUNT++; $Summary.Add("$APP_LABEL : Failed (skipped)")
    }
    continue
  }

  Write-Blank
  Write-Host "[ERROR] BUILD_MODE must be make or cmake]"
  exit 3
}

Write-Blank
Write-Host "=============================================================================="
Write-Host "ALL APPLICATIONS COMPLETED"
Write-Host "=============================================================================="
foreach ($line in $Summary) { Write-Host $line }
exit 0