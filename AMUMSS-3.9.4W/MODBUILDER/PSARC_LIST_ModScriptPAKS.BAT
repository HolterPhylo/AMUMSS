@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem -------- We are in MODBUILDER  -------------
set "_pMODS_PAK_LIST=MODS_pak_list.txt"
set _pMODBUILDERDirectory=!CD!

rem -------- We are in Modscript  -------------
cd ..\Modscript
REM echo.^>^>^> Changed to !CD!

echo.^>^>^> Getting list of files from ModScript PAK file(s), Please wait...

echo|set /p="FROM ModScript">> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
echo. >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"

for %%I in ("*.pak.*") do (
	echo.  - %%~nxI
	echo|set /p="[INFO]   - %%~nxI">>"%_bMASTER_FOLDER_PATH%REPORT.txt" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
	"%_pMODBUILDERDirectory%\psarc.exe" list "..\ModScript\%%~nxI" >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
	echo. >> "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%"
)

REM if not exist "%_pMODBUILDERDirectory%\%_pMODS_PAK_LIST%" (
  REM echo. "!CD!" does not contain any pak files.
  REM goto :DONE
REM )

REM :DONE
rem -------- We are in MODBUILDER  -------------
cd ..\MODBUILDER
REM echo.^>^>^> Changed to !CD!

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
		echo.    [BUG] lua.exe generated an ERROR... Please report ALL scripts AND this file to NMS Discord: "No Man's Sky Modding" channel, "mod-amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.txt" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
	REM ) else (
		REM if defined _mDEBUG (
			REM echo.        LuaEndedOK
		REM )
	)
	EXIT /B
	
rem --------------------------------------------

ENDLOCAL
