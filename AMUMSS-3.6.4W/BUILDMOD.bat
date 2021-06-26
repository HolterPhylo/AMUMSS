@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

set _mOK=Y

rem https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing/8162578#8162578
rem let us set default options value here
rem the order of definition is irrelevant
set "options=-CopyToGamefolder:"" -UpdateMBinCompiler:"Y" -CombinedModPak:"" -CheckForModConflicts:"" -ReCreateMapFileTree:"" -UseLuaInPak:"" -CombinedModType:"""

for %%O in (%options%) do (for /f "tokens=1,* delims=:" %%A in ("%%O") do (set "%%A=%%~B"))
:loop
if not "%~1"=="" (
  set "test=!options:*%~1:=! "
  if "!test!"=="!options! " (
      echo. Error: Invalid option %~1
  ) else if "!test:~0,1!"==" " (
      set "%~1=1"
  ) else (
      setlocal disableDelayedExpansion
      set "val=%~2"
      call :escapeVal
      setlocal enableDelayedExpansion
      for /f delims^=^ eol^= %%A in ("!val!") do endlocal&endlocal&set "%~1=%%A" !
      shift /1
  )
  shift /1
  goto :loop
)
goto :endArgs
:escapeVal
set "val=%val:^=^^%"
set "val=%val:!=^!%"
exit /b
:endArgs

if exist WOPT_Wbertro.txt (
	set -
	echo.
)

rem To get the value of a single parameter, just remember to include the `-`
REM echo The value of -CopyToGamefolder is: !-CopyToGamefolder!
REM pause


rem For win 7 to use colors also
if exist OPT_Colors_ON.txt (set _mCOLORS=y)

if defined _mCOLORS (
	REM enable color output
	
	rem NOT USED, won't work on win 7, use ansicon.exe
	rem reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f 1>NUL 2>NUL
	
	.\MODBUILDER\ansicon_x64\ansicon.exe -p 1>NUL 2>NUL

	set _zRED=[1;31m[1m
	set _zGREEN=[1;32m[1m
	set _zYELLOW=[1;33m[1m
	set _zBLACKonYELLOW=[7;93m
	set _zDARKGRAY=[1;90m[1m
	set _zINVERSE=[7m
	set _zDEFAULT=[0m
	
	set _zUpOneLineErase=[F[K
)
rem end For win 7 to use colors also

Del /f /q /s "log.txt" 1>NUL 2>NUL
bzrun.bat 2>&1 | MODBUILDER\wtee.exe log.txt
