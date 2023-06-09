@echo off

rem -------- We are in MODBUILDER  -------------
set "_pMODS_MBIN_LIST=MODS_MBIN_list.txt"
set _pMODBUILDERDirectory=!CD!

rem -------- We are in Modscript  -------------
cd ..\Modscript
REM echo.^>^>^> Changed to !CD!

echo.^>^>^> Getting list of files from ModScript MBIN file(s), Please wait...

echo|set /p="FROM ModScript">> "%_pMODBUILDERDirectory%\%_pMODS_MBIN_LIST%"
echo. >> "%_pMODBUILDERDirectory%\%_pMODS_MBIN_LIST%"

for %%I in ("*.MBIN") do (
	echo.  - %%~nxI
	echo|set /p="[INFO]   - %%~nxI">>"%_bMASTER_FOLDER_PATH%REPORT.txt" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
	echo. %%~nxI >> "%_pMODBUILDERDirectory%\%_pMODS_MBIN_LIST%"
	echo. >> "%_pMODBUILDERDirectory%\%_pMODS_MBIN_LIST%"
)

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
		echo.    [BUG] lua.exe generated an [ERROR]... Please report ALL scripts AND this file to NMS Discord: "No Man's Sky Modding" channel, "mod-amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.txt" & echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
	REM ) else (
		REM if defined _mDEBUG (
			REM echo.        LuaEndedOK
		REM )
	)
	EXIT /B
	
rem --------------------------------------------
