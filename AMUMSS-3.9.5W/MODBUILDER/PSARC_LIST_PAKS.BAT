@echo off

echo.^>^>^> Creating NMS PAK file lists. Please wait...

REM we are already in MODBUILDER
set "_pPAK_LIST=pak_list.txt"
set "_pPAK_Dir=pak_Dir.txt"
set _pCurrentDirectory=!CD!
set _pMODBUILDERDirectory=!CD!

set /p _gNMS_FOLDER=<NMS_FOLDER.txt
set _gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS

if exist "%_pPAK_LIST%" (
	del /f /q "%_pPAK_LIST%" 1>NUL 2>NUL
	del /f /q "%_pPAK_Dir%" 1>NUL 2>NUL
	del /f /q "PAK_LIST_CREATED.txt" 1>NUL 2>NUL
)

pushd "%_gNMS_PCBANKS_FOLDER%"
echo.^>^>^> Changed to !CD!

for %%I in ("*.pak.*") do (
  echo. %%~nxI
  "%_pMODBUILDERDirectory%\psarc.exe" list "%%~nxI" >> "%_pMODBUILDERDirectory%\%_pPAK_LIST%"
  echo. >> "%_pMODBUILDERDirectory%\%_pPAK_LIST%"
)

popd
REM Back in MODBUILDER

if not exist "%_pPAK_LIST%" (
  echo. "!CD!" does not contain any pak files.
  goto :DONE
)

REM to have a SMALL file with the same datetime that we can use later to check if we need to re-create pak_list.txt
echo.> "PAK_LIST_CREATED.txt"

echo.
echo.Created "NMS_%_pPAK_LIST%Pretty.lua"
Call :LuaEndedOkREMOVE
%_mLUA% FormatPAKlist.lua
Call :LuaEndedOk
echo.Created "NMS_%_pPAK_Dir%Pretty.lua"

REM copy them to AMUMSS folder for user
xcopy /s /y /h /v /j "%_pPAK_LIST%Pretty.lua" "..\NMS_%_pPAK_LIST%Pretty.lua*" 1>NUL 2>NUL
del /f /q "%_pPAK_LIST%Pretty.lua" 1>NUL 2>NUL
xcopy /s /y /h /v /j "%_pPAK_Dir%Pretty.lua" "..\NMS_%_pPAK_Dir%Pretty.lua*" 1>NUL 2>NUL
del /f /q "%_pPAK_Dir%Pretty.lua" 1>NUL 2>NUL

rem Here copy the FULL NMS PCBANKS pak list
xcopy /s /y /h /v /j "Full_%_pPAK_LIST%" "..\NMS_FULL_%_pPAK_LIST%*" 1>NUL 2>NUL

rem make a smaller version of _pPAK_LIST for faster search
Call :LuaEndedOkREMOVE
%_mLUA% CleanPAKlist.lua
Call :LuaEndedOk

REM echo.
REM echo.^>^>^> Extracting MBIN(s) from PAK file(s), Please wait...
REM for %%G in ("..\Modscript\*.pak") do (
	REM echo.%%G
	REM "%_pCurrentDirectory%\psarc.exe" extract "%%G" --to="." -y 1>NUL 2>NUL
REM )

REM del /f /q "..\Modscript\MBIN_VersionList.txt" 1>NUL 2>NUL

REM rem to find version used to re=create an MBIN
REM for /R "..\Modscript\" %%G in ("*.MBIN") do (
	REM echo."%%G" >> "..\Modscript\MBIN_VersionList.txt"
	REM "%_pCurrentDirectory%\mbincompiler.exe" version -q "%%G" >> "..\Modscript\MBIN_VersionList.txt"
REM )

:DONE

REM echo.^>^>^> Changed to !CD!
echo off

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an ERROR... Please report ALL scripts AND this file to NMS Discord: "No Man's Sky Modding" channel, "mod-amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	REM ) else (
		REM if defined _mDEBUG (
			REM echo.        LuaEndedOK
		REM )
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q /s "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
