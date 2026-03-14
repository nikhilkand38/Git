@echo off
setlocal EnableDelayedExpansion
 
echo ==============================================================================
echo R CORE WINAMS UNIT TEST SCRIPT
echo ==============================================================================
 
set "SUM_COUNT=0" 
:LOOP
 
REM Stop when no arguments remain
if "%~1"=="" goto DONE
 
REM Each block must start with --app
if /I not "%~1"=="--app" (
    echo.
    echo [ERROR] Expected --app but got "%~1"
    exit /b 1
)
 
shift
 
REM Common parameters
set "PROJ=%~1"
set "VOPT=%~2"
set "SRCL=%~3"
set "SPMC=%~4"
set "MODE=%~5"

for %%I in ("!PROJ!") do set "APP_LABEL=%%~nI"
 
if "!MODE!"=="" (
    echo [ERROR] Missing BUILD_MODE for !PROJ!
    exit /b 2
)
 
REM =====================================
REM MAKE MODE
REM =====================================
if /I "!MODE!"=="make" (
 
    set "BUILD=%~6"
    set "CSV=%~7"
    set "AMSO=%~8"
 
    echo.
    echo ----------------------------------------------------------
    echo Running MAKE project
    echo PROJ  = !PROJ!
    echo BUILD = !BUILD!
    echo CSV   = !CSV!
    echo ----------------------------------------------------------
 
    call :RUN_SINGLE ^
    "!PROJ!" "!VOPT!" "!SRCL!" "!SPMC!" make "!BUILD!" "!CSV!" "!AMSO!"

    REM === ADDED (summary): record outcome for console summary ===
    set "RC=!errorlevel!"
    if "!RC!"=="0" (
      set /a SUM_COUNT+=1
      set "SUM_!SUM_COUNT!=!APP_LABEL! : executed"
    ) else (
      set /a SUM_COUNT+=1
      set "SUM_!SUM_COUNT!=!APP_LABEL! : failed (skipped)"
    )
 
    shift
    shift
    shift
    shift
    shift
    shift
    shift
    shift
 
    goto LOOP
)
 
REM =====================================
REM CMAKE MODE
REM =====================================
if /I "!MODE!"=="cmake" (
 
    set "BUILD=%~6"
    set "TOOL=%~7"
    set "CSV=%~8"
    set "AMSO=%~9"
 
    echo.
    echo ----------------------------------------------------------
    echo Running CMAKE project
    echo PROJ  = !PROJ!
    echo BUILD = !BUILD!
    echo TOOL  = !TOOL!
    echo CSV   = !CSV!
    echo ----------------------------------------------------------
 
    call :RUN_SINGLE ^
    "!PROJ!" "!VOPT!" "!SRCL!" "!SPMC!" cmake "!BUILD!" "!TOOL!" "!CSV!" "!AMSO!"

    REM === ADDED (summary): record outcome for console summary ===
    set "RC=!errorlevel!"
    if "!RC!"=="0" (
      set /a SUM_COUNT+=1
      set "SUM_!SUM_COUNT!=!APP_LABEL! : executed"
    ) else (
      set /a SUM_COUNT+=1
      set "SUM_!SUM_COUNT!=!APP_LABEL! : failed (skipped)"
    )
 
    shift
    shift
    shift
    shift
    shift
    shift
    shift
    shift
    shift
 
    goto LOOP
)
 
echo.
echo [ERROR] BUILD_MODE must be make or cmake
exit /b 3
 
 
:DONE
echo.
echo ==============================================================================
echo ALL APPLICATIONS COMPLETED
echo ==============================================================================
for /L %%i in (1,1,%SUM_COUNT%) do call echo %%SUM_%%i%%
exit /b 0


REM ==============================================================================
REM =============  INTEGRATED SINGLE-APP FLOW (WITH FUNCTIONS)  ==================
REM ==============================================================================
:RUN_SINGLE
@echo off
setlocal enableextensions

REM =========================================================================
REM  R-Core WinAMS UT Script: CaseViewer (X.0) → Copy/Replace (X.1) → Build (X.2) → SST (X.3)
REM  Usage: winams_silent.bat <PROJECT_FOLDER> <SETTINGS.vopt> <SOURCE_LIST.txt> <SPMC_DIR_LIST.csv> [cmake|make] <BUILD_PATH> [TOOLCHAIN_FILE|CSV_DIR] [CSV_FILE] [SETTINGS_AMSO]
REM  cmake:  %5=cmake  %6=BUILD_PATH  %7=TOOLCHAIN_FILE  %8=CSV_DIR  %9=CSV_FILE  %10=SETTINGS_AMSO
REM  make :  %5=make   %6=BUILD_PATH  %7=CSV_DIR         %8=CSV_FILE %9=SETTINGS_AMSO
REM  Outputs: VPROJ in _caseviewer, copied sources in TARGET_ROOT, ELF in BUILD_PATH, SST Out* + HTML
REM  Requires: CaseCommand.exe, AMSCommand.exe, and make/cmake (per mode)
REM  Notes: SPMC CSV format "orig_src","hook_src_dir",0; hooks replace .c/.h by filename; SST project = <parent>\APP_sstManager
REM =========================================================================

REM ===================== START BANNER =====================
echo.
echo ==============================================================================
echo            R CORE WINAMS UNIT TEST SCRIPT 
echo ==============================================================================

REM ===================== USAGE & ARGS =====================
REM Usage:
REM   winams_silent.bat <PROJECT_FOLDER> <SETTINGS> <SOURCE_LIST_FILE> <SPMC_DIR_LIST>
REM Example:
REM   
REM ================Define Variable============
set "PROJECT_FOLDER=%~1"
set "SETTINGS=%~2"
set "SOURCE_LIST_FILE=%~3"
set "SPMC_DIR_LIST=%~4"
set "BUILD_MODE=%~5"
set "BUILD_PATH=%~6"
set "TOOLCHAIN_FILE=%~7"
if /I "%BUILD_MODE%"=="cmake" (
  set "SST_CSV_FILE=%~8"
  set "SST_SETTINGS_AMSO=%~9"
) else (
  set "SST_CSV_FILE=%~7"
  set "SST_SETTINGS_AMSO=%~8"
)

REM ===== Presence check for positional args =====
if "%PROJECT_FOLDER%"=="" goto :usage
if "%SETTINGS%"=="" goto :usage
if "%SOURCE_LIST_FILE%"=="" goto :usage
if "%SPMC_DIR_LIST%"=="" goto :usage
if "%PROJECT_FOLDER%"=="" goto :usage
if "%SETTINGS%"=="" goto :usage
if "%SOURCE_LIST_FILE%"=="" goto :usage
if "%SPMC_DIR_LIST%"=="" goto :usage
if not "%BUILD_MODE%"=="" (
  if /I "%BUILD_MODE%"=="cmake" (
    if "%BUILD_PATH%"=="" goto :usage
    REM TOOLCHAIN_FILE optional; default later if empty
    if "%SST_CSV_FILE%"=="" goto :usage
    if "%SST_SETTINGS_AMSO%"=="" goto :usage
  ) else if /I "%BUILD_MODE%"=="make" (
    if "%BUILD_PATH%"=="" goto :usage
    if "%SST_CSV_FILE%"=="" goto :usage
    if "%SST_SETTINGS_AMSO%"=="" goto :usage
  ) else (
    goto :usage
  )
)


REM ===================== SANITY CHECK =====================
if not exist "%PROJECT_FOLDER%" (
  echo [FATAL] Settings file not found: %USER_SRC_ROOT%
  goto :err
)
if not exist "%SETTINGS%" (
  echo [FATAL] Settings file not found: %SETTINGS%
  goto :err
)
if not exist "%SOURCE_LIST_FILE%" (
  echo [FATAL] Source list not found: %SOURCE_LIST_FILE%
  goto :err
)
if not exist "%SPMC_DIR_LIST%" (
  echo [FATAL] SPMC dir list not found: %SPMC_DIR_LIST%
  goto :err
)
if defined BUILD_MODE (

  if "%SST_CSV_FILE%"=="" (
    echo [FATAL] SST_CSV_FILE not provided.
    goto :err
  )

  if "%SST_SETTINGS_AMSO%"=="" (
    echo [FATAL] SETTINGS_AMSO not provided.
    goto :err
  )

)

echo ----------------------------------------------------------------------
echo   Project folder : %PROJECT_FOLDER%
echo   Settings file  : %SETTINGS%
echo   Source list    : %SOURCE_LIST_FILE%
echo   SPMC dir list  : %SPMC_DIR_LIST%
echo   Build mode     : %BUILD_MODE%
echo   Build path     : %BUILD_PATH%
if /I "%BUILD_MODE%"=="cmake" echo   Toolchain file : %TOOLCHAIN_FILE%
echo   SST CSV file   : %SST_CSV_FILE%
echo   Settings (.amso): %SST_SETTINGS_AMSO%
echo ----------------------------------------------------------------------
echo.

REM ===================== ENV & LOGS =====================
set "PATH=%PATH%;C:\Program Files (x86)\gaio\CasePlayer2\bin"
set "SCRIPT_DIR=%~dp0"
set "LOG_ROOT=%SCRIPT_DIR%log_caseviewer"
if not exist "%LOG_ROOT%" mkdir "%LOG_ROOT%" >nul 2>&1
set "CASE_LOGDIR=%LOG_ROOT%"
set "CASECOMMAND_LOG=%LOG_ROOT%"

REM ===== If arg #1 is the user source code, derive a CV project path =====
REM Rule: PROJECT_FOLDER becomes <parent-of-arg1>\<appname>_caseviewer
REM       appname = last folder name of the user source root
REM       We only change PROJECT_FOLDER here; your existing VPROJ derivation will follow it.
REM Normalize (remove trailing backslash)
set "USER_SRC_ROOT=%~1"
if "%PROJECT_FOLDER:~-1%"=="\" set "PROJECT_FOLDER=%PROJECT_FOLDER:~0,-1%"

REM Extract app name and parent from the given path
for %%I in ("%PROJECT_FOLDER%") do (
  set "APP_NAME=%%~nI"
  set "PARENT_DIR=%%~dpI"
)

REM Trim trailing backslash from parent
if "%PARENT_DIR:~-1%"=="\" set "PARENT_DIR=%PARENT_DIR:~0,-1%"

REM If the provided folder name does NOT already end with _caseviewer, treat it as user src root
set "APP_SUFFIX=%APP_NAME:~-10%"
if /I "%APP_SUFFIX%"=="_caseviewer" (
  REM already a caseviewer folder; do nothing
) else (
  set "PROJECT_FOLDER=%PARENT_DIR%\%APP_NAME%_caseviewer"
  echo [Info] Treating input as user source root. Derived CaseViewer project:
  echo        APP_NAME      : %APP_NAME%
  echo        PROJECT_FOLDER: %PROJECT_FOLDER%
  echo.
)

echo ------------------- LOG FILE SETUP -------------------
for /f "tokens=1-3 delims=/.- " %%a in ("%date%") do set "D=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set "T=%%a%%b%%c"
set "T=%T: =0%"
set "LOG_DIR=%SCRIPT_DIR%log\%APP_NAME%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
set "LOG_FILE=%LOG_DIR%\%APP_NAME%_%D%_%T%.log"
set "R=>>"%LOG_FILE%" 2>>&1"
echo Logging to: "%LOG_FILE%"
echo.
echo -------------------------------------------------------
echo ===================== STEP X.0 HOOK CODE GENERATION WTIH CASECOMMAND =====================

REM ===================== DERIVE .vproj FROM PROJECT_FOLDER =====================
if "%PROJECT_FOLDER:~-1%"=="\" set "PROJECT_FOLDER=%PROJECT_FOLDER:~0,-1%"
for %%I in ("%PROJECT_FOLDER%") do set "PROJECT_NAME=%%~nI"
set "VPROJ=%PROJECT_FOLDER%\%PROJECT_NAME%.vproj"
echo ----------------------------------------------------------------------
echo   Project (.vproj) : %VPROJ%
echo   Settings (.vopt) : %SETTINGS%
echo   Source list      : %SOURCE_LIST_FILE%
echo   SPMC dir list    : %SPMC_DIR_LIST%
echo ----------------------------------------------------------------------

REM ===================== FUNCTION CALLS (no echo changes) =====================
call :STEP_X0 || goto :err
call :STEP_X1 || goto :err
call :STEP_X2 || goto :err
call :STEP_X3 || goto :err

exit /b 0


REM ================================== STEP X.0 =================================
:STEP_X0
CaseCommand.exe -endCP2 %R% || goto :err REM If CaseCommand.exe is running in background it will end it ... 
echo ----------------------------------------------------------------------
echo STEP 1: Create project from settings (with license-safe retry)
if exist "%PROJECT_FOLDER%\" (
  echo ----------------------------------------------------------------------
  echo [X] Deleting existing project folder:
  echo     %PROJECT_FOLDER%
  echo ----------------------------------------------------------------------
  if "%PROJECT_FOLDER%"=="" (
    echo [FATAL] PROJECT_FOLDER is empty. Abort delete.
    goto :err
  )
  for %%D in ("%PROJECT_FOLDER%") do (
    if "%%~pD"=="\" (
      echo [FATAL] PROJECT_FOLDER appears to be a drive root. Abort delete.
      goto :err
    )
  )
  attrib -R -S -H "%PROJECT_FOLDER%" /S /D 2>nul
  rmdir /S /Q "%PROJECT_FOLDER%"
  if exist "%PROJECT_FOLDER%\" (
    echo [ERROR] Failed to delete: %PROJECT_FOLDER%
    goto :err
  ) else (
    echo [OK] Deleted: %PROJECT_FOLDER%
  )
)

set "CV_INIT_RETRIED="
:x0_cv_init_try
  echo Command: CaseCommand.exe -crtprojimport %SETTINGS% %PROJECT_FOLDER%
  CaseCommand.exe -crtprojimport %SETTINGS% %PROJECT_FOLDER% %R% || goto :x0_cv_init_fail
  echo Result : Project created and CPU/Compiler profile set.
  goto :x0_cv_init_ok

:x0_cv_init_fail
  echo [WARN] CaseViewer init/profile step failed - attempting to kill and retry once...
  taskkill /IM CaseViewer.exe /F /T >nul 2>&1
  timeout /t 3 >nul
  if defined CV_INIT_RETRIED (
    echo [FATAL] Retry failed again. Aborting CaseViewer initialization.
    goto :err
  )
  set "CV_INIT_RETRIED=1"
  goto :x0_cv_init_try

:x0_cv_init_ok
echo.

echo ----------------------------------------------------------------------
echo STEP 2: Set CPU and compiler profile (CortexR52 + armclang)
echo Command: CaseCommand.exe -cpucpl CortexR52 armclang %VPROJ%
CaseCommand.exe -cpucpl CortexR52 armclang %VPROJ% %R% || goto :err
echo Result : CPU/Compiler profile set.
echo.

echo ----------------------------------------------------------------------
echo STEP 3: Clear registered sources/headers
echo Command: CaseCommand.exe -clr %VPROJ%
CaseCommand.exe -clr %VPROJ% %R% || goto :err
echo Result : Sources cleared.
echo.

echo ----------------------------------------------------------------------
echo STEP 4: Register sources from list
echo Command: CaseCommand.exe -a %SOURCE_LIST_FILE% %VPROJ%
CaseCommand.exe -a %SOURCE_LIST_FILE% %VPROJ% %R% || goto :err
echo Result : Sources registered from list.
echo.

echo ----------------------------------------------------------------------
echo STEP 5: Run analysis / create document
echo Command: CaseCommand.exe -r %VPROJ%
CaseCommand.exe -r %VPROJ% %R% || goto :err
echo Result : Analysis completed / document created.
echo.

echo ----------------------------------------------------------------------
echo STEP 6: Generate dummy functions for undefined references
echo Command: CaseCommand.exe -putdmyfunc %VPROJ%
CaseCommand.exe -putdmyfunc %VPROJ% %R% || goto :err
echo Result : Dummy functions generated.
echo.

echo ----------------------------------------------------------------------
echo STEP 7: Enable hook code flags (SPMC_OUTCODE, SPMC_AUTOCOPY)
echo Command: CaseCommand.exe -set_rev "SPMC_OUTCODE=1;SPMC_AUTOCOPY=1" %VPROJ%
CaseCommand.exe -set_rev "SPMC_OUTCODE=1;SPMC_AUTOCOPY=1" %VPROJ% %R% || goto :err
echo Result : Hook code flags enabled.
echo.

echo ----------------------------------------------------------------------
echo STEP 8: Mark all files as SPMC targets
echo Command: CaseCommand.exe -allspmc %VPROJ%
CaseCommand.exe -allspmc %VPROJ% %R% || goto :err
echo Result : All files marked for SPMC.
echo.

echo ----------------------------------------------------------------------
echo STEP 9: Configure SPMC directory list
echo Command: CaseCommand.exe -spmcDir %SPMC_DIR_LIST% %VPROJ%
CaseCommand.exe -spmcDir %SPMC_DIR_LIST% %VPROJ% %R% || goto :err
echo Result : SPMC directory list configured.
echo.

echo ----------------------------------------------------------------------
echo STEP 10: Copy SPMC environment
echo Command: CaseCommand.exe -spmcCopy %VPROJ% || goto :err
CaseCommand.exe -spmcCopy %VPROJ% %R%
echo Result : SPMC environment copied.
echo.

echo STEP 11: ReRun analysis / Recreate document
echo Command: CaseCommand.exe -r %VPROJ%
CaseCommand.exe -r %VPROJ% %R% || goto :err
echo Result : Analysis completed / document created.
echo.

echo ----------------------------------------------------------------------
echo STEP 12: Build hook code (m then H)
echo Command: CaseCommand.exe -m %VPROJ%
CaseCommand.exe -m %VPROJ% %R% || goto :err
echo Command: CaseCommand.exe -H %VPROJ%
CaseCommand.exe -H %VPROJ% %R% || goto :err
echo Result : Hook code build completed.
echo.

echo ----------------------------------------------------------------------
echo FINAL: End silent Case session
echo Command: CaseCommand.exe -endCP2
CaseCommand.exe -endCP2 %R% || goto :err
echo Result : Silent session closed.
echo.
echo ================================================================
echo ----------------------------------------------------------------------
echo STEP X.0 Completed: HOOK CODE GENERATION WTIH CASECOMMAND finished
echo ----------------------------------------------------------------------
echo  Project: %PROJECT_FOLDER%
echo  VProj  : %VPROJ%
echo  Logs   : %LOG_ROOT%
echo ================================================================
echo.
exit /b 0


REM ================================== STEP X.1 =================================
:STEP_X1
set "TARGET_ROOT=%PROJECT_FOLDER%\%APP_NAME%"
echo ======================================================================
echo  STEP X.1: Copy user project into CaseViewer project 
echo ======================================================================

set "TARGET_ROOT=%PROJECT_FOLDER%\%APP_NAME%"
echo Source : %USER_SRC_ROOT%
echo Target : %TARGET_ROOT%

robocopy "%USER_SRC_ROOT%" "%TARGET_ROOT%" /E /NFL /NDL /NJH /NJS /NC /NS /NP %R%
echo Copy done.

set "HOOK_SRC_DIR="
for /f "usebackq tokens=2 delims=," %%A in ("%SPMC_DIR_LIST%") do (
    set "HOOK_SRC_DIR=%%~A"
    goto :x1_hook_found
)
:x1_hook_found
set "HOOK_SRC_DIR=%HOOK_SRC_DIR:"=%"
echo Hook Source: %HOOK_SRC_DIR%
if not exist "%HOOK_SRC_DIR%" (
    echo [ERROR] Hook source path does not exist: %HOOK_SRC_DIR%
    goto :x1_done
)

if not exist "%TARGET_ROOT%\src" mkdir "%TARGET_ROOT%\src" %R% 2>nul

echo Replacing .c files...
for /R "%TARGET_ROOT%" %%F in (*.c) do (
    for /f "delims=" %%S in ('dir /b /s /a:-d "%HOOK_SRC_DIR%\%%~nxF" 2^>nul') do (
        attrib -R -S -H "%%F" 2>nul
        copy /Y "%%S" "%%F" %R% >nul
    )
)

echo Replacing .h files...
for /R "%TARGET_ROOT%" %%F in (*.h) do (
    for /f "delims=" %%S in ('dir /b /s /a:-d "%HOOK_SRC_DIR%\%%~nxF" 2^>nul') do (
        attrib -R -S -H "%%F" 2>nul
        copy /Y "%%S" "%%F" %R% >nul
    )
)

echo Copying winAMS_Spmc* files...
for /f "delims=" %%W in ('dir /b /s /a:-d "%HOOK_SRC_DIR%\winAMS_Spmc*" 2^>nul') do (
    copy /Y "%%~fW" "%TARGET_ROOT%\src\%%~nxW" %R% >nul
)

:x1_done
echo STEP X.1 Completed.
echo ======================================================================
echo.
exit /b 0


REM ================================== STEP X.2 =================================
:STEP_X2
echo ======================================================================
echo STEP X.2: Build
echo   MODE : %BUILD_MODE%
echo   PATH : %BUILD_PATH%
if /I "%BUILD_MODE%"=="cmake" echo   TOOL : %TOOLCHAIN_FILE%
echo.
if "%BUILD_MODE%"=="" (
  echo [INFO] No build args passed. Skipping STEP X.2.
  goto :x2_after_build
)

if /I "%BUILD_MODE%"=="cmake" (
  if "%BUILD_PATH%"==""  ( echo [ERROR] CMake BUILD_PATH required & goto :err )
  if "%TOOLCHAIN_FILE%"=="" set "TOOLCHAIN_FILE=..\toolchain.cmake"

  if not exist "%BUILD_PATH%" mkdir "%BUILD_PATH%" %R% 2>&1
  pushd "%BUILD_PATH%" || ( echo [ERROR] Cannot cd to %BUILD_PATH% & goto :err )

  echo cmake .. -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN_FILE%
  cmake .. -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN_FILE% %R% || ( popd & goto :err )

  echo cmake --build .
  cmake --build . %R% || ( popd & goto :err )

  popd
  echo [CMAKE] Done.
  goto :x2_after_build
)

if /I "%BUILD_MODE%"=="make" (
  if "%BUILD_PATH%"=="" ( echo [ERROR] MAKE PATH required & goto :err )
  if not exist "%BUILD_PATH%\Makefile" (
    echo [ERROR] Makefile not found in %BUILD_PATH%
    goto :err
  )
  pushd "%BUILD_PATH%" || ( echo [ERROR] Cannot cd to %BUILD_PATH% & goto :err )
  echo make
  make %R% || ( popd & goto :err )
  popd
  echo [MAKE] Done.
  echo .elf file Generated Successfully !
  echo.
  echo ======================================================================
  goto :x2_after_build
)

echo [ERROR] BUILD_MODE must be "cmake" or "make"
goto :err

:x2_after_build
exit /b 0


REM ================================== STEP X.3 =================================
:STEP_X3
echo ======================================================================
echo STEP X.3: SST Manager (AMSCommand)

for %%P in ("%PROJECT_FOLDER%") do set "CV_PARENT=%%~dpP"
if "%CV_PARENT:~-1%"=="\" (
  set "SST_PROJECT_FOLDER=%CV_PARENT%%APP_NAME%_sstManager"
) else (
  set "SST_PROJECT_FOLDER=%CV_PARENT%\%APP_NAME%_sstManager"
)
set "SST_AMSY=%SST_PROJECT_FOLDER%\%APP_NAME%_sstManager.amsy"

echo   Derived SST project folder : %SST_PROJECT_FOLDER%
echo   Derived .amsy              : %SST_AMSY%
echo   CSV_FILE                   : %SST_CSV_FILE%
echo   SETTINGS_AMSO              : %SST_SETTINGS_AMSO%
echo.

if "%SST_CSV_FILE%"=="" ( echo [ERROR] CSV_FILE missing for SST & goto :err )
if "%SST_SETTINGS_AMSO%"=="" ( echo [ERROR] SETTINGS_AMSO missing - expected .amso & goto :err )

set "ELF_PATH="
if not "%BUILD_PATH%"=="" (
  for /f "delims=" %%E in ('dir /b /s /a:-d "%BUILD_PATH%\*.elf" 2^>nul') do (
    set "ELF_PATH=%%~fE"
    goto :x3_sst_got_elf
  )
)
for /f "delims=" %%E in ('dir /b /s /a:-d "%TARGET_ROOT%\build\*.elf" 2^>nul') do (
  set "ELF_PATH=%%~fE"
  goto :x3_sst_got_elf
)
for /f "delims=" %%E in ('dir /b /s /a:-d "%PROJECT_FOLDER%\%APP_NAME%\build\*.elf" 2^>nul') do (
  set "ELF_PATH=%%~fE"
  goto :x3_sst_got_elf
)

:x3_sst_got_elf
if "%ELF_PATH%"=="" (
  echo [ERROR] No .elf found for SST Manager
  goto :err
)
echo Using ELF: %ELF_PATH%

set "PATH=%PATH%;C:\WinAMS\bin"

echo ----------------------------------------------------------------------
echo STEP 1: Create SST Project Folder

if exist "%PROJECT_FOLDER%\" (
  echo ----------------------------------------------------------------------
  echo [X] Deleting existing project folder:
  echo     %PROJECT_FOLDER%
  echo ----------------------------------------------------------------------

  if "%SST_PROJECT_FOLDER%%"=="" (
    echo [FATAL] PROJECT_FOLDER is empty. Abort delete.
    goto :err
  )
  for %%D in ("%SST_PROJECT_FOLDER%") do (
    if "%%~pD"=="\" (
      echo [FATAL] PROJECT_FOLDER appears to be a drive root. Abort delete.
      goto :err
    )
  )

  attrib -R -S -H "%SST_PROJECT_FOLDER%" /S /D 2>nul
  rmdir /S /Q "%SST_PROJECT_FOLDER%"
  if exist "%SST_PROJECT_FOLDER%\" (
    echo [ERROR] Failed to delete: %SST_PROJECT_FOLDER%
    goto :err
  ) else (
    echo [OK] Deleted: %SST_PROJECT_FOLDER%
  )
)

echo Command: AMSCommand.exe -crtprojimport %SST_SETTINGS_AMSO% %SST_PROJECT_FOLDER%
AMSCommand.exe -crtprojimport %SST_SETTINGS_AMSO% %SST_PROJECT_FOLDER% || goto :err
echo Result : SST project folder ready.
echo.

echo ----------------------------------------------------------------------
echo STEP 2: Prepare TestCsv directory (auto copy CSV by filename)
set "TESTCSV_DIR=%SST_PROJECT_FOLDER%\TestCsv"

echo Command: mkdir "%TESTCSV_DIR%"
if not exist "%TESTCSV_DIR%" mkdir "%TESTCSV_DIR%" %R% 2>&1

set "CSV_SOURCE=%SCRIPT_DIR%"
if not exist "%CSV_SOURCE%\" (
  echo [FATAL] Missing CSV source folder: %CSV_SOURCE%
  echo Create this folder and place your CSV files inside it.
  goto :err
)

set "CSV_FULL=%CSV_SOURCE%\%SST_CSV_FILE%"
if not exist "%CSV_FULL%" (
  echo [FATAL] CSV file not found: %CSV_FULL%
  goto :err
)

echo Command: copy "%CSV_FULL%" "%TESTCSV_DIR%"
copy "%CSV_FULL%" "%TESTCSV_DIR%" %R% || goto :err

set "TESTCSV_FILE=%SST_CSV_FILE%"
echo Result : CSV copied to TestCsv
echo.

echo ----------------------------------------------------------------------
echo STEP 3: Defensive AMS close
echo Command: AMSCommand.exe -endAMS
AMSCommand.exe -endAMS
echo Result : AMS closed (safe)
echo.

echo ----------------------------------------------------------------------
echo STEP 4: Import ELF (normal)
echo Command: AMSCommand.exe -obj %ELF_PATH% %SST_AMSY%
AMSCommand.exe -obj %ELF_PATH% %SST_AMSY% || goto :err
echo Result : ELF imported (.obj)
echo.

echo ----------------------------------------------------------------------
echo STEP 5: Import ELF (SPMC)
echo Command: AMSCommand.exe -objspmc %ELF_PATH% %SST_AMSY%
AMSCommand.exe -objspmc %ELF_PATH% %SST_AMSY% || goto :err
echo Result : ELF imported for SPMC
echo.

echo ----------------------------------------------------------------------
echo STEP 6: Set end address (main)
echo Command: AMSCommand.exe -iendaddr main %SST_AMSY%
AMSCommand.exe -iendaddr main %SST_AMSY% || goto :err
echo Result : End address (main) set
echo.

echo ----------------------------------------------------------------------
echo STEP 7: Set end address SPMC (main)
echo Command: AMSCommand.exe -iendaddrspmc main %SST_AMSY%
AMSCommand.exe -iendaddrspmc main %SST_AMSY% || goto :err
echo Result : End address SPMC (main) set
echo.

echo ----------------------------------------------------------------------
echo STEP 8: Configure test-to-SPM mapping
echo Command: AMSCommand.exe -set_test2spm %SST_AMSY%
AMSCommand.exe -set_test2spm %SST_AMSY% || goto :err
echo Result : Mapping configured
echo.

echo ----------------------------------------------------------------------
echo STEP 9: Set input directory
echo Command: AMSCommand.exe -set_test InDir=%TESTCSV_DIR% %SST_AMSY%
AMSCommand.exe -set_test InDir=%TESTCSV_DIR% %SST_AMSY% || goto :err
echo Result : Input directory set
echo.

echo ----------------------------------------------------------------------
echo STEP 10: Run tests on CSV
echo Command: AMSCommand.exe -b -testCsv %TESTCSV_DIR%\%SST_CSV_FILE% %SST_AMSY%
AMSCommand.exe -b -testCsv %TESTCSV_DIR%\%SST_CSV_FILE% %SST_AMSY% || goto :err
echo Result : Test executed successfully
echo.

echo ----------------------------------------------------------------------
echo STEP 11: End AMS session
echo Command: AMSCommand.exe -endAMS
AMSCommand.exe -endAMS
echo Result : AMS session closed
echo.

echo STEP X.3 Completed.
echo ======================================================================
echo.

:x3_end_sst

REM ===================== FINAL EXECUTION SUMMARY =====================
if "%ELF_PATH%"=="" (
  for /f "delims=" %%E in ('dir /b /s /a:-d "%BUILD_PATH%\*.elf" 2^>nul') do set "ELF_PATH=%%~fE"
)
if "%ELF_PATH%"=="" (
  for /f "delims=" %%E in ('dir /b /s /a:-d "%TARGET_ROOT%\build\*.elf" 2^>nul') do set "ELF_PATH=%%~fE"
)
if "%ELF_PATH%"=="" (
  for /f "delims=" %%E in ('dir /b /s /a:-d "%PROJECT_FOLDER%\%APP_NAME%\build\*.elf" 2^>nul') do set "ELF_PATH=%%~fE"
)

set "OUT_DIR="
for /f "delims=" %%D in ('dir /ad /b /o:-d "%SST_PROJECT_FOLDER%\Out*" 2^>nul') do (
  set "OUT_DIR=%SST_PROJECT_FOLDER%\%%D"
  goto :x3_got_outdir_summary
)
:x3_got_outdir_summary

set "REPORT_HTML="
if defined OUT_DIR (
  for /f "delims=" %%R in ('dir /s /b /o:-d "%OUT_DIR%\*.html" 2^>nul') do (
    set "REPORT_HTML=%%R"
    goto :x3_got_html_summary
  )
)
:x3_got_html_summary

echo ========================================================================
echo   EXECUTION SUMMARY
echo ========================================================================
echo   Application     : %APP_NAME%   (ELF: %ELF_PATH%)
if defined SST_AMSY      echo   Project (.amsy) : %SST_AMSY%
echo   Project Folder  : %PROJECT_FOLDER%
if defined TESTCSV_DIR if defined SST_CSV_FILE echo   Test CSV Used   : %TESTCSV_DIR%\%SST_CSV_FILE%
if defined OUT_DIR      echo   Latest Output   : %OUT_DIR%
if not defined OUT_DIR  echo   Latest Output   : (not detected; WinAMS may write results later)
if defined REPORT_HTML  echo   Report (HTML)  : %REPORT_HTML%
if not defined REPORT_HTML echo   Report (HTML)  : (not detected in newest Out* folder)
echo ========================================================================
echo.
exit /b 0


:usage
  echo   %~nx0 ^<PROJECT_FOLDER^> ^<SETTINGS^> ^<SOURCE_LIST_FILE^> ^<SPMC_DIR_LIST^> [BUILD_MODE] [BUILD_PATH] [TOOLCHAIN_FILE] [CSV_FILE] [SETTINGS_AMSO]
  echo.
  echo Examples:
  echo   MAKE :
  echo     %~nx0 C:\src\proj C:\cfg\case_player.vopt C:\cfg\source_list.txt C:\cfg\spmc_dir_list.txt ^
  make C:\caseviewer\proj_caseviewer\proj\build demo_func1.csv C:\cfg\AmsProjSave.amso
  echo.
  echo   CMAKE:
  echo     %~nx0 C:\src\proj C:\cfg\case_player.vopt C:\cfg\source_list.txt C:\cfg\spmc_dir_list.txt ^
  cmake C:\caseviewer\proj_caseviewer\proj\build ..\toolchain.cmake demo_func1.csv C:\cfg\AmsProjSave.amso
exit /b 2

:err
echo.
echo ================================================================
echo [ERROR] Command failed with errorlevel %errorlevel%
echo ================================================================
exit /b %errorlevel%