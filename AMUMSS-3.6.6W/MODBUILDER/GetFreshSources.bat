@echo off
if defined _mVERBOSE (
	echo.^>^>^>     In GetFreshSources.bat
)
rem FOR PSEUDO CODE, see GetFreshSources_LOGIC.txt

rem All defined variables in GetFreshSources.bat start with _g (except FOR loop first parameter)
rem so we can easily list them all like this on error, if needed: set _g

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

set "_gG="
if defined _mVERBOSE set "_gG=GetFreshSources.bat:"

rem *************************   WE ARE IN MODBUILDER   ************************

set /p _gNMS_FOLDER=<NMS_FOLDER.txt
set _gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS\

if not exist "%CD%\_TEMP" (
	mkdir "%CD%\_TEMP\"
) else (
	if defined _mVERBOSE (
		echo.
		echo.^>^>^> %_gG% Folder _TEMP already exist
	)
)

rem ********************************  WE ARE GOING INTO _TEMP  ****************************
cd _TEMP

echo.
FOR /F "tokens=*" %%A in (..\MOD_MBIN_SOURCE.txt) do (
	set _gMBIN_FILE=%%A
	set _gMBIN=!_gMBIN_FILE:.MBIN.PC=.MBIN!
	set _gEXML_FILE=!_gMBIN:.MBIN=.EXML!
	if not exist "..\MOD\!_gEXML_FILE!" (
		echo.^>^>^> !_gEXML_FILE! does not exist in MOD
		set _gFound=
		if %_bNumberPAKs% GTR 0 (
			if not defined _bBuildMODpakFromPakScript (
				rem getting the EXML from the last PAK, if possible
				FOR /r "..\..\ModScript\" %%G in (*.pak) do (
					echo.
					echo.^>^>^> Looking to Extract %%A from "%%~nxG"
					REM START /wait "" /B /MIN ..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "%%A" 1>NUL 2>NUL
					..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "%%A" 1>NUL 2>NUL
					if not exist "..\ModScript\EXTRACTED_PAK\%%A" (
						rem sometimes there is an extra / as the first character!!! (never seen that in NMS PAKs, in user PAK yes!)
						REM START /wait "" /B /MIN ..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "/%%A" 1>NUL 2>NUL
						..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "/%%A" 1>NUL 2>NUL
						if not exist "..\..\ModScript\EXTRACTED_PAK\%%A" (
							echo. INFO: Could not find "%%A"
						) else (
							echo|set /p="[INFO]: Found %%A in %%~nxG using [/]">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
							echo. INFO: ***** Found %%A in "%%~nxG" using "/"
							set _gFound=y
						)
					) else (
						echo|set /p="[INFO]: Found %%A in %%~nxG">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
						echo. INFO: ***** Found %%A in "%%~nxG"
						set _gFound=y
					)
					if defined _gFound (
						set _gFound=
						echo.
						echo.^>^>^> Decompiling %%A
						echo.----- [INFO] %%A
						
						Del /f /q /s "..\MBINVersion.txt" 1>NUL 2>NUL
						..\MBINCompiler.exe version -q "..\..\ModScript\EXTRACTED_PAK\%%A">>"..\MBINVersion.txt"
						set /p _gMBINVersion=<..\MBINVersion.txt
						echo.----- [INFO] was compiled using version !_gMBINVersion!
						
						..\MBINCompiler.exe "..\..\ModScript\EXTRACTED_PAK\%%A" -y -f -d "..\..\ModScript\EXMLFILES_PAK\%%A\.." 1>NUL 2>NUL
						Call :LuaEndedOkREMOVE
						..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Decompiling"
						Call :LuaEndedOk
						REM echo.-----
						
						rem -- we will copy it to MOD only if it was, at a minimum, created by the same MBINCompiler version initially
						rem -- and we should check for added lines in the NMS EXML vs this one...
						
						rem -- if later it does not compile, that will generate an error (which is ok)
						rem -- we don't want to stop AMUMSS from trying at least
						
						echo.
						echo.^>^>^> Copying PAK's !_gMBIN_FILE! to MOD folder...
						xcopy /s /y /h /v "..\..\ModScript\EXMLFILES_PAK\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!\..\" 1>NUL 2>NUL
					)
				)
			)
		)
	) else (
		echo|set /p="[INFO]: !_gEXML_FILE! already exist in MOD and will be COMBINED">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
		echo.^>^>^> !_gEXML_FILE! already exist in MOD and will be COMBINED
	)
	rem re-checking in case it was not found in a pak
	if not exist "..\MOD\!_gEXML_FILE!" (
		echo|set /p="[INFO]: Getting !_gMBIN_FILE! from NMS source PAKs">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
		echo.
		echo.^>^>^> Getting !_gMBIN_FILE! from NMS source PAKs
		if not exist "%cd%\EXTRACTED\%%A" (
			CALL :EXTRACT
		)
		if "%%~xA"==".BIN" (
			xcopy /s /y /h /v "%cd%\EXTRACTED\%%A" "..\MOD\%%A*" 1>NUL 2>NUL
		) else (
			REM echo.^>^>^> %_gG% Decompiling only required MBIN Sources to MOD folder
			echo.^>^>^> %_gG% MBINCompiler working...
			echo.----- [INFO] %%A
			..\MBINCompiler.exe "%cd%\EXTRACTED\%%A" -y -f -d "%cd%\DECOMPILED\%%A\.." 1>NUL 2>NUL
			Call :LuaEndedOkREMOVE
			..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Decompiling"
			Call :LuaEndedOk
			echo.
			REM echo."%cd%\DECOMPILED\!_gEXML_FILE!"
			REM echo."..\MOD\!_gEXML_FILE!*"
			xcopy /s /y /h /v "%cd%\DECOMPILED\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!*" 1>NUL 2>NUL
		)
	)
)
if defined _mVERBOSE (
	echo.----------------------------------------
)

rem ********************************  WE ARE BACK IN MODBUILDER  ****************************
cd ..

REM Del /f /q "GetFreshSource.txt" 1>NUL 2>NUL

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
rem --------------------------------------------
:EXTRACT
	FOR /F "tokens=*" %%H in (..\MOD_PAK_SOURCE.txt) do (
		if not exist "PAK_SOURCES\%%H" (
			REM echo.
			echo.^>^>^> %_gG% Getting %%H from NMS PCBANKS folder. Please wait...
			xcopy /s /y /h /v "%_gNMS_PCBANKS_FOLDER%%%H" "%CD%\PAK_SOURCES\" >NUL
		)
		REM echo.^>^>^> %_gG% Looking to Extract required MBIN/EXML from %%H...
		..\psarc.exe extract "PAK_SOURCES\%%H" "%%A" --to="%cd%\EXTRACTED" -y 1>NUL 2>NUL
		if exist "%cd%\EXTRACTED\%%A" (
			echo.^>^>^> %_gG% Extracted MBIN/EXML from %%H...
			REM echo.^>^>^> %_gG% Found required MBIN
			goto :ENDEXTRACT
		)
	)
	:ENDEXTRACT
	EXIT /B
	
rem --------------------------------------------
rem --------------------------------------------
:DOPAUSE
	if defined _mPAUSE (
		echo.******
		pause
		echo.******
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOk
	if not EXIST  "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" (
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
		echo.    [BUG]: lua.exe generated an ERROR... Please report ALL scripts AND this file to Nexus page>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.txt"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q /s "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
