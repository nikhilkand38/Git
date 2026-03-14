@echo off
setlocal enableextensions

rem ===================== USAGE ======================
rem solution_sst.bat [ELF] [AMSY] [SOURCELIST] [CSV_DIR] [CSV_FILE] [PROJECT_FOLDER] [SETTINGS_AMSO]
rem Example:
rem solution_sst.bat C:\winams1\script\cortex_r52_demo_elf\build\safety_controller.elf C:\winams1\script\sst_manager1\sst_manager1.amsy C:\winams1\script\source_list_sst_manager.txt C:\winams1\script\sst_manager\TestCsv demo_func1.csv C:\winams1\script\sst_manager1 C:\winams1\script\AmsProjSave.amso
rem ==================================================

set "PATH=%PATH%;C:\WinAMS\bin"

rem ---- Gather inputs (positional args) with defaults if missing ----
set "ELF=%~1"
set "AMSY=%~2"
set "SOURCELIST=%~3"
set "CSV_DIR=%~4"
set "CSV_FILE=%~5"
set "PROJECT_FOLDER=%~6"
set "SETTINGS=%~7"

rem ---- Fallback defaults (customize as you like) ----
@REM if not defined ELF set "ELF=C:\winams1\script\cortex_r52_demo_elf\build\safety_controller.elf"
@REM if not defined AMSY set "AMSY=C:\winams1\script\sst_manager1\sst_manager1.amsy"
@REM if not defined SOURCELIST set "SOURCELIST=C:\winams1\script\source_list_sst_manager.txt"
@REM if not defined CSV_DIR set "CSV_DIR=C:\winams1\script\sst_manager\TestCsv"
@REM if not defined CSV_FILE set "CSV_FILE=demo_func1.csv"
@REM if not defined PROJECT_FOLDER set "PROJECT_FOLDER=C:\winams1\script\sst_manager1"
@REM if not defined SETTINGS set "SETTINGS=C:\winams1\script\AmsProjSave.amso"

rem ---- Sanity checks (no quotes to keep AMSCommand happy later) ----
if not exist %ELF% echo [FATAL] ELF not found: "%ELF%" & exit /b 1
if not exist %SOURCELIST% echo [FATAL] Source list missing: "%SOURCELIST%" & exit /b 1
if not exist %CSV_DIR%\%CSV_FILE% echo [FATAL] CSV missing: "%CSV_DIR%\%CSV_FILE%" & exit /b 1
if not exist %PROJECT_FOLDER% mkdir %PROJECT_FOLDER%

rem ---- Echo resolved inputs ----
echo ELF          : "%ELF%"
echo AMSY         : "%AMSY%"
echo SOURCELIST   : "%SOURCELIST%"
echo CSV_DIR      : "%CSV_DIR%"
echo CSV_FILE     : "%CSV_FILE%"
echo PROJECT_FOLDER: "%PROJECT_FOLDER%"
echo SETTINGS     : "%SETTINGS%"

echo create project
AMSCommand.exe -crtprojimport %SETTINGS% %PROJECT_FOLDER%

rem Optional: ensure project TestCsv exists and contains CSV
set "TESTCSV_DIR=%PROJECT_FOLDER%\TestCsv"
if not exist "%TESTCSV_DIR%" mkdir "%TESTCSV_DIR%"
copy "%CSV_DIR%\%CSV_FILE%" "%TESTCSV_DIR%" >nul
echo done copying

rem Close AMS to avoid project locks
AMSCommand.exe -endAMS

rem ---- WinAMS calls (NO quotes in args; your environment paths have no spaces) ----
AMSCommand.exe -obj %ELF% %AMSY% || goto :err
echo .elf set
echo.

AMSCommand.exe -objspmc %ELF% %AMSY% || goto :err
echo .elf set spmc
echo.

AMSCommand.exe -iendaddr main %AMSY% || goto :err
echo end address set
echo.

AMSCommand.exe -iendaddrspmc main %AMSY% || goto :err
echo end address set spmc
echo.

AMSCommand.exe -set_test2spm %AMSY% || goto :err
echo end test spmc set
echo.


rem Use absolute paths for tests (no quotes)
AMSCommand.exe -set_test InDir=%TESTCSV_DIR% %AMSY% || goto :err
AMSCommand.exe -b -testCsv %TESTCSV_DIR%\%CSV_FILE% %AMSY% || goto :err
echo coverage generated

echo [OK] All steps succeeded
AMSCommand.exe -endAMS
exit /b 0

:err
echo [ERROR] Command failed with errorlevel %errorlevel%
exit /b %errorlevel%