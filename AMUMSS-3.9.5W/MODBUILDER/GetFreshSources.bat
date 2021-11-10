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

set "_INFO=^[INFO] "
set "_INFO="

rem *************************   WE ARE IN MODBUILDER   ************************

set /p _gNMS_FOLDER=<NMS_FOLDER.txt
set _gNMS_PCBANKS_FOLDER=%_gNMS_FOLDER%\GAMEDATA\PCBANKS\

if not exist "!CD!\_TEMP" (
	mkdir "!CD!\_TEMP\"
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
	
	rem in case the user script references .EXML files instead of .MBIN files
	set _gMBIN=!_gMBIN_FILE:.EXML=.MBIN!
	
	set _gMBIN=!_gMBIN_FILE:.MBIN.PC=.MBIN!
	set _gEXML_FILE=!_gMBIN:.MBIN=.EXML!
	
	if not exist "..\MOD\!_gEXML_FILE!" (
		echo.^>^>^> !_gEXML_FILE! does not yet exist in MODBUILDER\MOD
		set _gFound=
		if %_bNumberPAKs% GTR 0 (
			if not defined _bBuildMODpakFromPakScript (
				rem getting the EXML from the last PAK, if possible
				rem        with /r we get also .pak in sub-folders
				REM FOR /r "..\..\ModScript\" %%G in (*.pak.*) do (
				FOR %%G in ("..\..\ModScript\*.pak.*") do (
					echo.
					echo.^>^>^> Looking to Extract %%A from "%%~nxG"
					REM START /wait "" /B /MIN ..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "%%A" 1>NUL 2>NUL
					..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "%%A" 1>NUL 2>NUL
					if not exist "..\ModScript\EXTRACTED_PAK\%%A" (
						rem sometimes there is an extra / as the first character!!! (never seen that in NMS PAKs, in user PAK yes!)
						REM START /wait "" /B /MIN ..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "/%%A" 1>NUL 2>NUL
						..\psarc.exe extract "..\..\ModScript\%%~nxG" --to="..\..\ModScript\EXTRACTED_PAK" -y "/%%A" 1>NUL 2>NUL
						if not exist "..\..\ModScript\EXTRACTED_PAK\%%A" (
							echo.    [INFO] Could not find "%%A" in pak
						) else (
							echo|set /p="%_INFO%Found %%A in %%~nxG using [/]">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
							echo.    [INFO] ***** Found %%A in "%%~nxG" using "/"
							set _gFound=y
						)
					) else (
						echo|set /p="%_INFO%Found %%A in %%~nxG">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
						echo.    [INFO] ***** Found %%A in "%%~nxG"
						set _gFound=y
					)
					if defined _gFound (
						set _gFound=
						echo.
						echo.^>^>^> Decompiling %%A
						echo.----- [INFO] %%A
						
						Del /f /q /s "..\cMBINVersion.txt" 1>NUL 2>NUL
						..\MBINCompiler.exe version -q "..\..\ModScript\EXTRACTED_PAK\%%A">>"..\cMBINVersion.txt"
						set /p _gMBINVersion=<..\cMBINVersion.txt
						echo.----- [INFO] was compiled using version !_gMBINVersion!
						Del /f /q /s "..\cMBINVersion.txt" 1>NUL 2>NUL
						
						..\MBINCompiler.exe "..\..\ModScript\EXTRACTED_PAK\%%A" -y -f -d "..\..\ModScript\EXMLFILES_PAK\%%A\.." 1>NUL 2>NUL

						if NOT [%-AutoUpdateMBinCompiler%]==[N] (
							if not exist "..\..\ModScript\EXMLFILES_PAK\!_gEXML_FILE!" (
								REM try to other compiler
								CALL :SWITCH_COMPILER
								..\MBINCompiler.exe "..\..\ModScript\EXTRACTED_PAK\%%A" -y -f -d "..\..\ModScript\EXMLFILES_PAK\%%A\.." 1>NUL 2>NUL
							)
						)
						
						Call :LuaEndedOkREMOVE
						..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Decompiling"
						Call :LuaEndedOk
						REM echo.-----
						
						rem -- we will copy it to MOD only if it was, at a minimum, created by the same MBINCompiler version initially
						rem -- and we should check for added lines in the NMS EXML vs this one...
						
						rem -- if later it does not compile, that will generate an error (which is ok)
						rem -- we don't want to stop AMUMSS from trying at least
						
						echo.
						echo.^>^>^> Copying PAK's !_gEXML_FILE! to MOD folder...
						xcopy /s /y /h /v "..\..\ModScript\EXMLFILES_PAK\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!\..\" 1>NUL 2>NUL
					)
				)
			)
		)
	) else (
		echo|set /p="%_INFO%!_gEXML_FILE! already exist in MODBUILDER\MOD and will be COMBINED">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
		echo.^>^>^> !_gEXML_FILE! already exist in MOD and will be COMBINED
	)
	rem re-checking in case it was not found in a pak
	if not exist "..\MOD\!_gEXML_FILE!" (
		echo|set /p="%_INFO%Getting !_gMBIN_FILE! from NMS source PAKs">>"..\..\REPORT.lua" & echo.>>"..\..\REPORT.lua"
		echo.
		echo.   ^>^>^> Getting !_gMBIN_FILE! from NMS source PAKs
		if not exist "!CD!\EXTRACTED\%%A" (
			CALL :EXTRACT %%A
		)
		if "%%~xA"==".BIN" (
			xcopy /s /y /h /v "!CD!\EXTRACTED\%%A" "..\MOD\%%A*" 1>NUL 2>NUL
		) else (
			REM echo.^>^>^> %_gG% Decompiling only required MBIN Sources to MOD folder
			echo.   ^>^>^> %_gG% MBINCompiler working...
			echo.        [INFO] %%A
			..\MBINCompiler.exe "!CD!\EXTRACTED\%%A" -y -f -d "!CD!\DECOMPILED\%%A\.." 1>NUL 2>NUL

			if NOT [%-AutoUpdateMBinCompiler%]==[N] (
				if not exist "!CD!\DECOMPILED\!_gEXML_FILE!" (
					REM try to other compiler
					CALL :SWITCH_COMPILER
					..\MBINCompiler.exe "!CD!\EXTRACTED\%%A" -y -f -d "!CD!\DECOMPILED\%%A\.." 1>NUL 2>NUL
				)
			)
			
			Call :LuaEndedOkREMOVE
			..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Decompiling"
			Call :LuaEndedOk

			echo.
			REM echo."!CD!\DECOMPILED\!_gEXML_FILE!"
			REM echo."..\MOD\!_gEXML_FILE!*"
			xcopy /s /y /h /v "!CD!\DECOMPILED\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!*" 1>NUL 2>NUL
			
			if not exist "..\_TEMP_MAP\!_gEXML_FILE!" (
				REM echo. copy it also for MapFileTree
				xcopy /s /y /h /v "!CD!\DECOMPILED\!_gEXML_FILE!" "..\_TEMP_MAP\!_gEXML_FILE!*" 1>NUL 2>NUL
			)
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
		REM echo. for [%%H]
		REM echo. and [%1]
		..\psarc.exe extract "%_gNMS_PCBANKS_FOLDER%%%H" "%1" --to="!CD!\EXTRACTED" -y 1>NUL 2>NUL
		
		if exist "!CD!\EXTRACTED\%1" (
			REM echo.^>^>^> %_gG% Extracted MBIN/EXML from %%H...
			REM echo.^>^>^> %_gG% Found required MBIN
			goto :ENDEXTRACT
		)
	)
	echo.%_zRED%^>^>^> [WARNING] Could not EXTRACT %1 %_zDEFAULT%
	:ENDEXTRACT
	EXIT /B
	
rem --------------------------------------------
:SWITCH_COMPILER
	if not exist "..\MBINCompiler.current.exe" (
		echo.      Switching to the other compiler...
		ren "..\MBINCompiler.exe" "MBINCompiler.current.exe" >nul
		copy /V /Y /B "..\MBINCompiler.previous.exe" "..\MBINCompiler.exe" >nul
	) else (
		echo.      Switching to the main compiler...
		copy /V /Y /B "..\MBINCompiler.current.exe" "..\MBINCompiler.exe" >nul
		del /F /Q "..\MBINCompiler.current.exe" >nul
	)
	:ENDSWITCH_COMPILER
	popd
	
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
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an ERROR... Please report ALL scripts AND this file to NMS Discord: "No Man's Sky Modding" channel, "mod-amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q /s "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
