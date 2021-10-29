@echo off
rem *****************  we are in MODBUILDER  ***********
REM echo.^>^>^>     In MBINCompilerDownloader.bat
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem used only if in standalone mode for debug
if not defined _mLUA (set "_mLUA=Extras\lua_x64\bin\lua.exe")

rem *****************  we are in MBINCompilerDownloader  ***********
cd MBINCompilerDownloader

:TRYAGAIN
set /A "retry_count+=1"
if %retry_count% GTR 2 (
	echo.
	echo.%_zRED% ====================================================================================%_zDEFAULT%
	echo. %_zINVERSE% [WARNING] Problem fetching from Web, using your current version if possible      %_zDEFAULT%
	echo.%_zRED% ====================================================================================%_zDEFAULT%
	echo|set /p=".   [WARNING] Problem fetching MBINCompiler.exe from Web, using your current version if possible">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
	goto :ENDING
)

curl -s "https://github.com/monkeyman192/MBINCompiler/releases" > RAW.txt
REM curl -s "https://github.com/HolterPhylo/MBINCompiler-preNET5/releases" > RAW.txt
REM set /p RAW=<RAW.txt

..\%_mLUA% ExtractLink.lua
set /p _URL_1=<temp1.txt

if exist "URLPrevious.txt" (
	set /p _URLPrevious=<URLPrevious.txt
)

if "%_URL_1%"=="%_URLPrevious%" (
	echo.        %_zGREEN% ==^> is up-to-date!%_zDEFAULT%
	rem ********************  we are in MODBUILDER  *********************
	cd ..
) else (
	echo.
	echo.^>^>^> Getting latest MBINCompiler.exe from Web...
	curl -LO %_URL_1%
	
	if exist "MBINCompiler.exe" (
		echo|set /p="%_URL_1%">URLPrevious.txt
		xcopy /y /h /v "MBINCompiler.exe" "..\" 1>nul 2>nul
		REM in case this is a 'release'
		xcopy /y /h /v "MBINCompiler.exe" "..\MBINCompiler.previous.exe*" 1>nul 2>nul
		Del /f /q /s "MBINCompiler.exe" 1>NUL 2>NUL

		rem ********************  we are in MODBUILDER  *********************
		cd ..
		Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
		MBINCompiler.exe version -q >>MBINCompilerVersion.txt
		set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
		echo.
		echo.^>^>^> Added %_zGREEN%MBINCompiler.!_bMBINCompilerVersion!.exe%_zDEFAULT% to Extras\MBINCompiler_OldVersions folder...
		echo.
		xcopy /y /h /v "MBINCompiler.exe" "!CD!\Extras\MBINCompiler_OldVersions\MBINCompiler.!_bMBINCompilerVersion!.exe*" 1>nul 2>nul

		rem *****************  we are in MBINCompilerDownloader  ***********
		cd MBINCompilerDownloader
		
		echo.^>^>^> Getting latest libMBIN.dll from Web...

		REM REM ********** this is for .net5 version
		REM set _libMBIN_URL=%_URL_1:MBINCompiler.exe=libMBIN.dll%
		REM REM echo.!_libMBIN_URL!
		REM curl -LO !_libMBIN_URL!

		REM xcopy /y /h /v "libMBIN.dll" "..\" 1>nul 2>nul

		REM REM in case this is a 'release'
		REM xcopy /y /h /v "libMBIN.dll" "..\libMBIN.previous.dll*" 1>nul 2>nul

		REM xcopy /y /h /v "libMBIN.dll" "..\..\" 1>nul 2>nul

		REM REM in case this is a 'release'
		REM xcopy /y /h /v "libMBIN.dll" "..\..\libMBIN.previous.dll*" 1>nul 2>nul

		REM Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL

		REM ************ this is for .net4 version
		set _libMBIN_URL=%_URL_1:MBINCompiler.exe=libMBIN-dotnet4.dll%
		REM echo.!_libMBIN_URL!
		curl -LO !_libMBIN_URL!

		Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
		ren libMBIN-dotnet4.dll libMBIN.dll 1>nul 2>nul
		xcopy /y /h /v "libMBIN.dll" "..\" 1>nul 2>nul

		REM in case this is a 'release'
		xcopy /y /h /v "libMBIN.dll" "..\libMBIN.previous.dll*" 1>nul 2>nul

		xcopy /y /h /v "libMBIN.dll" "..\..\" 1>nul 2>nul

		REM in case this is a 'release'
		xcopy /y /h /v "libMBIN.dll" "..\..\libMBIN.previous.dll*" 1>nul 2>nul

		Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL

		REM *************  get previous release
		set /p _URL_2=<temp2.txt
		REM echo !_URL_2!

		if NOT [%_URL_1%]==[!_URL_2!] (		
			curl -LO !_URL_2!
			
			if exist "MBINCompiler.exe" (
				Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
				MBINCompiler.exe version -q >>MBINCompilerVersion.txt
				set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
				echo.
				echo.^>^>^> Added %_zGREEN%MBINCompiler.!_bMBINCompilerVersion!.exe%_zDEFAULT% to Extras\MBINCompiler_OldVersions folder...
				echo.
				xcopy /y /h /v "MBINCompiler.exe" "..\Extras\MBINCompiler_OldVersions\MBINCompiler.!_bMBINCompilerVersion!.exe*" 1>nul 2>nul			
				
				xcopy /y /h /v "MBINCompiler.exe" "..\MBINCompiler.previous.exe*" 1>nul 2>nul
				Del /f /q /s "MBINCompiler.exe" 1>NUL 2>NUL
				Del /f /q /s "MBINCompiler.log" 1>NUL 2>NUL

				echo.^>^>^> Getting latest libMBIN.dll from Web...

				REM REM ********* this is for .net5 version
				REM set _libMBIN_URL=%_URL_2:MBINCompiler.exe=libMBIN.dll%
				REM REM echo.!_libMBIN_URL!
				REM curl -LO !_libMBIN_URL!

				REM xcopy /y /h /v "libMBIN.dll" "..\libMBIN.previous.dll*" 1>nul 2>nul
				REM xcopy /y /h /v "libMBIN.dll" "..\..\libMBIN.previous.dll*" 1>nul 2>nul
				REM Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL

				REM ********* this is for .net4 version
				set _libMBIN_URL=%_URL_2:MBINCompiler.exe=libMBIN-dotnet4.dll%
				REM echo.!_libMBIN_URL!
				curl -LO !_libMBIN_URL!

				Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
				ren libMBIN-dotnet4.dll libMBIN.dll 1>nul 2>nul
				xcopy /y /h /v "libMBIN.dll" "..\libMBIN.previous.dll*" 1>nul 2>nul
				xcopy /y /h /v "libMBIN.dll" "..\..\libMBIN.previous.dll*" 1>nul 2>nul
				Del /f /q /s "libMBIN.dll" 1>NUL 2>NUL
			)
		)
		
		rem ********************  we are in MODBUILDER  *********************
		cd ..
	
	) else (
		echo. %_zBLACKonYELLOW%^>^>^> Could not download current version of MBINCompiler.exe%_zDEFAULT%
		echo. %_zBLACKonYELLOW%^>^>^> Check your internet connection, retrying...%_zDEFAULT%
		ping -n 5 127.0.0.1>nul
		goto :TRYAGAIN
	)
)

:ENDING
rem ********************  we are in MODBUILDER  *********************
@echo off