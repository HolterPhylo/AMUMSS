@echo off
if not defined _mOK (
	echo.  Please use BuildMod.bat...
	pause
	EXIT
)
if exist WOPT_DEBUG.txt (
	if not defined _min_subprocess ((cmd /k set _min_subprocess=y ^& %0 %*) & exit )
	echo.################ IN DEBUG MODE ################
	echo.
)

rem All defined variables in BuildMod.bat start with _b (except FOR loop first parameter)
rem so we can easily list them all like this on error, if needed: set _b

rem Bugs: https://ss64.com/nt/goto.html
rem Using GOTO within parenthesis - including FOR and IF commands - will break their context

rem remarks with :: do not work in FOR loops

rem FOR REFERENCE ONLY
	REM set _zRED=[1;31m[1m
	REM set _zGREEN=[1;32m[1m
	REM set _zYELLOW=[1;33m[1m
	REM set _zBLACKonYELLOW=[7;93m
	REM set _zDARKGRAY=[1;90m[1m
	REM set _zINVERSE=[7m
	REM set _zDEFAULT=[0m
	
	REM set _zUpOneLineErase=[F[K

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

rem -------------  testing for administrator  -------------------------------
set _bMyPath=%CD%
set _bSystem32=%SYSTEMROOT%\system32
if "%_bMyPath%" == "%_bSystem32%" set _bADMIN=1

if DEFINED _bADMIN (
	echo.ERROR: Please do NOT "Run as administrator", AMUMSS will not work^!
	pause
	goto :eof
) else (
	SET "_bDateTimeStart=  %DATE% %TIME% We are good^!"
	echo.!_bDateTimeStart!
)

set _bMyPath=
set _bSystem32=
set _bADMIN=
rem -------------  end testing for administrator  -------------------------------

rem goto Start-up (AMUMSS) folder
rem could remove the need for testing for administrator ???
cd /D "%~dp0"

set "_bMASTER_FOLDER_PATH=%~dp0"

rem *********************  NOW IN AMUMSS folder  *******************

REM if exist OPT_Colors_ON.txt (set _mCOLORS=y)
if exist OPT_CustomMBINCompiler.txt (set _mCUSTOM_MBINCOMPILER=y)
if not exist OPT_NoScriptInPAK.txt (set _mScriptInPAK=y)
if exist OPT_SKIP_SERIALIZING.txt (set _mSKIP_SERIALIZING=y)
if exist OPT_SKIP_USER_PAUSE.txt (set _mSKIP_USER_PAUSE=y)
if exist WOPT_DEBUG.txt (set _mDEBUG=y)
if exist WOPT_debugS.txt (set _mdebugS=y)
if exist WOPT_ISxxx.txt (set _mISxxx=Y)
if exist WOPT_PAUSE.txt (set _mPAUSE=y)
if exist WOPT_ShowSections.txt (set _mSHOWSECTIONS=y)
if exist WOPT_SIMPLE.txt (set _mSIMPLE=y)
if exist WOPT_VERBOSE_BATCH.txt (set _mVERBOSE=y)
if exist WOPT_Wbertro.txt (set _mWbertro=y)

SET /p _mMasterVersion=<MODBUILDER\AMUMSSVersion.txt

rem --------------   Installed OS_1   -----------------------------
FOR /F "usebackq tokens=3,4,5" %%i IN (`REG query "hklm\software\microsoft\windows NT\CurrentVersion" /v ProductName`) DO (
	set "_bWinVer=%%i %%j %%k"
	set "_bWinNum=%%j"
)

Set _bOS_bitness=64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set _bOS_bitness=32
  )

set _bCPU=%NUMBER_OF_PROCESSORS%
set _bMinCPU=3

if %_bCPU% gtr %_bMinCPU% (
	set _bAllowMapFileTreeCreator=Y
	set _bRecreateMapFileTrees=1
)

REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "ProductName=%%~b"
REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion') do set "CurrentVersion=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v UBR') do set "UBRHEX=%%~b"
set /a _bCurrentBuildDec=%CurrentBuildHex%
set /a _bUBRDEC=%UBRHEX%
rem --------------  end Installed OS_1   -----------------------------

rem --------------   Installed OS_2 get Lua.exe  -----------------------------
if %_bOS_bitness%==64 (
	REM need to bring in lua_x64
	xcopy /s /y /h /v ".\MODBUILDER\Extras\lua-lfs.5.3.5_x64\*.*" ".\MODBUILDER\*" 1>NUL 2>NUL
) else (
	REM need to bring in lua_x86
	xcopy /s /y /h /v ".\MODBUILDER\Extras\lua-lfs.5.3.5_x86\*.*" ".\MODBUILDER\*" 1>NUL 2>NUL
)

set "_mLUA=lua-lfs.exe"

rem --------------  end Installed OS_2 get Lua.exe   -----------------------------
  
echo.
echo.%_zGREEN%  AMUMSS v%_mMasterVersion%%_zDEFAULT%
MODBUILDER\%_mLUA% -e print(_VERSION)>temp.txt
set /p _bVersionLua=<temp.txt
echo.%_zGREEN%  %_bVersionLua%%_zDEFAULT%
Del /f /q "temp.txt" 1>NUL 2>NUL

if %_bOS_bitness%==64 (
	echo.%_zGREEN%  %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs%_zDEFAULT%
) else (
	echo.%_zGREEN%  %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs%_zDEFAULT%
)

REM echo.
set "_bB="
if defined _mVERBOSE set "_bB=BuildMod.bat:"

if defined _mVERBOSE (
	echo.
	echo.^>^>^>     In BuildMod.bat
)

echo.
echo.^>^>^> %_bB% Starting in %CD%

Del /f /q "REPORT.txt" 1>NUL 2>NUL

rem **********************  start of NMS_FOLDER DISCOVERY section  *************************
rem try to find the NMS folder path
rem if the user gave a path, try to use it first
echo.
echo.^>^>^> %_bB% Checking Path to NMS_FOLDER...

set /p _bNMS_FOLDER=<NMS_FOLDER.txt 1>NUL 2>NUL
set _bNMS_PCBANKS_FOLDER="%_bNMS_FOLDER%"\GAMEDATA\PCBANKS\

if not exist %_bNMS_PCBANKS_FOLDER%\BankSignatures.bin (
	for %%G in (1,2,3) do (
		if not defined _bFoundNMS (
			if %%G EQU 1 (
				rem NMS on Steam
				echo.   Trying NMS on Steam using registry
				set _bREGKEY="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 275850"
				set _bREGVAL="InstallLocation"
			)
			if %%G EQU 2 (
				rem NMS on GOG on 32bit
				echo.   Trying NMS on GOG on 32bit using registry
				set _bREGKEY="HKLM\SOFTWARE\GOG.com\Games\1446213994"
				set _bREGVAL="PATH"
			)
			if %%G EQU 3 (
				rem NMS on GOG on 64bit
				echo.   Trying NMS on GOG on 64bit using registry
				set _bREGKEY="HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1446213994"
				set _bREGVAL="PATH"
			)
			rem see https://www.robvanderwoude.com/type.php for more info
			rem CHCP 1252
			
			rem REG QUERY !_bREGKEY! /v !_bREGVAL!
			FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
				set _bvalue=%%A %%B
			)
			ECHO !_bvalue!>test.txt
			
			set /p _bNMS_FOLDER=<test.txt
			set _bNMS_PCBANKS_FOLDER="!_bNMS_FOLDER!"\GAMEDATA\PCBANKS\
			if exist !_bNMS_PCBANKS_FOLDER!BankSignatures.bin (
				echo.
				echo.%_bB% Found Path to NMS_FOLDER...
				set _bFoundNMS=y
				goto :REG_EXPLORATION_DONE
			) else (
				echo.      not here...
			)
		)
	)
	echo.   Registry research done...
) else (
	set _bFoundNMS=y
)

:REG_EXPLORATION_DONE
echo.
if defined _bFoundNMS (
	copy /y /v "test.txt" "NMS_FOLDER.txt*" >NUL
) else (
	rem then NMS must be in a Library folder
	echo.Still looking to locate path to NMS_FOLDER...
	echo.
	set _bvalue=
	
	set _bREGKEY="HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
	set _bREGVAL="InstallPath"
	FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
		set _bvalue=%%A %%B
	)
	rem returns F:\Program Files (x86)\Steam
	REM echo.   Found Steam install folder: !_bvalue!	
	REM echo.   Looking for Libraries in !_bvalue!\steamapps\libraryfolders.vdf
	echo.   Looking for Libraries:
	echo.
	
	Call :LuaEndedOkREMOVE
	MODBUILDER\%_mLUA% MODBUILDER\GetNMSFolder.lua "!_bvalue!" ".\\MODBUILDER\\"
	Call :LuaEndedOk
)
Del /f /q "test.txt" 1>NUL 2>NUL

set _bREGKEY=
set _bREGVAL=
set _bvalue=
set _bFoundNMS=

set /p _bNMS_FOLDER=<NMS_FOLDER.txt
set _bNMS_PCBANKS_FOLDER="%_bNMS_FOLDER%"\GAMEDATA\PCBANKS\

if not exist %_bNMS_PCBANKS_FOLDER%BankSignatures.bin (
	echo.********************* PLEASE correct your path in NMS_FOLDER.txt, NMS game files not found ********************
	echo.Found this PATH in [NMS_FOLDER.txt]: "%_bNMS_FOLDER%"
	echo.***** Terminating batch until corrected...
	pause
	exit
) else (
	echo.%_zRED%%_bB% Path to NMS_FOLDER is ^>^>^> GOOD ^<^<^<, game files found%_zDEFAULT%
)

echo.
echo.^>^>^> %_bB% Copying NMS_FOLDER.txt to update NMS folder path
copy /y /v "NMS_FOLDER.txt" "MODBUILDER\NMS_FOLDER.txt*" >NUL
echo.   "%_bNMS_FOLDER%"
rem **********************  end of NMS_FOLDER DISCOVERY section  *************************

rem ************************************  SOME FOLDER preparation  ***********************
if not exist "%CD%\ModScript" (
	mkdir "%CD%\ModScript\" 2>NUL
)

if not exist "%CD%\SavedSections" (
	mkdir "%CD%\SavedSections\" 2>NUL
)

if not exist "!CD!\UNPACKED_DECOMPILED_PAKs" (
	mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\" 2>NUL
)

if exist "MODBUILDER\MBINCompiler.exe" (
	Del /f /q /s "MODBUILDER\MBINCompilerVersion.txt" 1>NUL 2>NUL
	.\MODBUILDER\MBINCompiler.exe version -q >>MODBUILDER\MBINCompilerVersion.txt
	set /p _bMBINCompilerVersion=<MODBUILDER\MBINCompilerVersion.txt
)

if not exist "%CD%\MapFileTrees" (
	mkdir "%CD%\MapFileTrees\" 2>NUL
)

if not exist "%CD%\ModExtraFilesToInclude" (
	mkdir "%CD%\ModExtraFilesToInclude\" 2>NUL
)

if not exist "%CD%\Builds" (
	mkdir "%CD%\Builds\" 2>NUL
)

if not exist "%CD%\Builds\IncrementalBuilds" (
	mkdir "%CD%\Builds\IncrementalBuilds\" 2>NUL
)
rem *********************  NOW IN ModScript  *******************
cd ModScript

if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK

rem *********************  NOW IN AMUMSS folder  *******************
cd ..
rem ********************************  end SOME FOLDER preparation  ***********************

rem ----------------------------------  Start REPORTing  -----------------------------------------------
echo|set /p=!_bDateTimeStart!>>"REPORT.txt" & echo.>>"REPORT.txt"
echo.>>"REPORT.txt"
echo|set /p="[INFO]: AMUMSS v%_mMasterVersion%">>"REPORT.txt" & echo.>>"REPORT.txt"
echo|set /p="[INFO]: using %_bVersionLua%">>"REPORT.txt" & echo.>>"REPORT.txt"

if %_bOS_bitness%==64 (
	echo|set /p="[INFO]: on %_bWinVer% 64bit with %NUMBER_OF_PROCESSORS% logical CPUs">>"REPORT.txt" & echo.>>"REPORT.txt"
) else (
	echo|set /p="[INFO]: on %_bWinVer% 32bit with %NUMBER_OF_PROCESSORS% logical CPUs">>"REPORT.txt" & echo.>>"REPORT.txt"
)

if defined _bMBINCompilerVersion (
	echo|set /p="[INFO]: with MBINCompiler v%_bMBINCompilerVersion%">>"REPORT.txt" & echo.>>"REPORT.txt"
)
echo.>>"REPORT.txt"

REM ADDED message to check 'open files' in xxx preventing AMUMSS to work
echo.
echo.%_zRED%============================================================================%_zDEFAULT%
echo. %_zINVERSE%[NOTE] EXCEPT when saying: 'Opening User Lua Script, Please wait...'        %_zDEFAULT%
echo. %_zINVERSE%       When AMUMSS seems to freeze and stop processing for ^> 60 seconds     %_zDEFAULT%
echo. %_zINVERSE%       probably means it cannot delete some files in a working directories. %_zDEFAULT%
echo. %_zINVERSE%    Please 'close' all AMUMSS files you have opened in other apps           %_zDEFAULT%
echo. %_zINVERSE%   (Files opened in Notepad++, for example, will not cause this problem)    %_zDEFAULT%
echo.%_zRED%============================================================================%_zDEFAULT%
rem -------------------------------  end Start REPORTing  -----------------------------------------------

rem --------------  Check # of scripts present ------------------------------
SET _bNumberScripts=0

rem --------------  and Create a Composite MOD name  ---------------------------------
rem Create a Composite MOD name file while counting how many scripts to run
rem and prepare a CONTENT_LIST file
Del /f /q "MODBUILDER\COMBINED_CONTENT_LIST.txt" 1>NUL 2>NUL
echo|set /p="This mod contains:">"MODBUILDER\COMBINED_CONTENT_LIST.txt"
echo.>>"MODBUILDER\COMBINED_CONTENT_LIST.txt"

SET _bMyTemp2=
FOR %%G in ("%~dp0\ModScript\*.lua") do ( 
	SET /A _bNumberScripts=_bNumberScripts+1
	SET _bMyTemp1=%%~nG
	SET _bMyTemp2=!_bMyTemp2!!_bMyTemp1!+
	echo|set /p="- !_bMyTemp1!">>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
	echo.>>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
)

rem Windows accepts a max of 260 char for drive/path/filename/ext length
rem NMS accepts only 110 char + .pak = 114
rem we need to leave room for '_(9)' so 110-4 = 106 + .pak
SET _bMaxPakNameLength=106

rem  remove last "+"
SET _bMyTemp2=!_bMyTemp2:~0,-1!
SET _bMyTemp2=!_bMyTemp2:~0,%_bMaxPakNameLength%!.pak
echo.%_bMyTemp2%>"MODBUILDER\Composite_MOD_FILENAME.txt"
SET "_bMyTemp1="
SET "_bMyTemp2="
rem --------------  end Create a Composite MOD name  ---------------------------------

if %_bNumberScripts% EQU 0 (
	echo.
	echo.^>^>^>   [INFO] NO user .lua Mod Script found in ModScript...
	echo.^>^>^>   You may want to put some .lua Mod script in the ModScript folder and retry...
	
	echo|set /p="[INFO]: NO user .lua Mod Script found in ModScript...">>"REPORT.txt" & echo.>>"REPORT.txt"
	echo.>>"REPORT.txt"
	
	set _bNoMod=y
	CALL :Cleaning_TEMP
) else (
	SET _bBuildMODpak=y
	CALL :Cleaning_EXML_Helper
)
rem --------------  end Check # of scripts present ------------------------------

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

Del /f /q MapFileTreeCreatorRun.txt 1>NUL 2>NUL
Del /f /q MapFileTreeRequested.txt 1>NUL 2>NUL

del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL

del /f /q MOD_BATCHNAME.txt 1>NUL 2>NUL
echo|set /p="">MOD_BATCHNAME.txt

del /f /q MBIN_PAKS.txt 1>NUL 2>NUL
echo|set /p="">MBIN_PAKS.txt
echo.>>"MBIN_PAKS.txt"

del /f /q MODS_pak_list.txt 1>NUL 2>NUL
echo|set /p="">MODS_pak_list.txt
cd ..
rem ******   NOW IN AMUMSS folder   ********

rem --------------  Check # of PAKs present ------------------------------
SET _bNumberPAKs=0
set _uOldMBINCompilerFlag=N
SET _uOldMBIN=N

SET _bGNumberFiles=0
SET _bGNumberFilesDecompiled=0
SET _bGNumberFilesMissing=0
SET _bGNumberFilesNoVersionInfo=0
SET _bNumberFilesCouldNotDecompile=0

SET _bCheckMODSconflicts=0

rem Check if some mod PAK also exist in ModScript
FOR /r "%~dp0\ModScript" %%G in (*.pak) do ( 
	SET /A _bNumberPAKs=_bNumberPAKs+1
	SET _bPAKname=%%~nG
)

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER
rem *************  Check MBINCompiler  *********************
CALL :MBINCompilerUPDATE

rem ******   NOW IN AMUMSS folder   ********
cd ..

if %_bNumberPAKs% GTR 0 (
	if %_bNumberScripts% GTR 0 (
		CALL :CHECK_ExtraFilesToInclude
	)

	rem *********************  NOW IN MODBUILDER  *******************
	cd MODBUILDER

	CALL :CONFLICTDETECTION
	REM get list of files in paks in MODS folder
	if !_bCheckMODSconflicts! EQU 1 (
		echo.get list of files in paks in MODS folder
		CALL PSARC_LIST_PAKS_MODS.BAT
	)
	
	CALL :PAK_LISTsCREATION
	
	rem ******   NOW IN AMUMSS folder   ********
	cd ..

	echo.
	echo.-----------------------------------------------------------
	if %_bNumberPAKs% GTR 1 (
		echo.%_zRED%^>^>^> Detected %_bNumberPAKs% user PAKs in ModScript...%_zDEFAULT%
		echo.

		echo|set /p="[INFO]: Detected %_bNumberPAKs% user PAKs in ModScript...">>"REPORT.txt" & echo.>>"REPORT.txt"
	) else (
		echo.%_zRED%^>^>^> Detected 1 user PAK in ModScript...%_zDEFAULT%
		echo.

		echo|set /p="[INFO]: Detected 1 user PAK in ModScript...">>"REPORT.txt" & echo.>>"REPORT.txt"
	)
	
	rem *********************  NOW IN MODBUILDER  *******************
	cd MODBUILDER

	rem ****************  Get list of paks in ModScript  ****************
	CALL PSARC_LIST_ModScriptPAKS.BAT
	echo.
	echo.>>"REPORT.txt"
	
	rem ******   NOW IN AMUMSS folder   ********
	cd ..
		
	if %_bNumberScripts% EQU 0 (
		echo. %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] Placing one or more paks in Modscript, without a .lua script, %_zDEFAULT%
		echo. %_zBLACKonYELLOW%             will unpack and decompile them                           %_zDEFAULT%
		echo. %_zBLACKonYELLOW%    When possible, the current MBINCompiler will be used...           %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                      %_zDEFAULT%
		echo. 
		if %_bNumberPAKs% GTR 1 (
			echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile them now...
		) else (
			echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile it now...
		)
		echo.

		echo|set /p="[NOTE]: Placing one or more paks in Modscript, without a .lua script will unpack and decompile them">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]: When possible, the current MBINCompiler will be used...">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	) else (
		echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] One or more paks with at least one .lua script to apply over them             %_zDEFAULT%
		echo. %_zBLACKonYELLOW%             will create a PATCH pak ^(the COMBINED pak^)                               %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        And if the same mbin file is present in any of the .pak and edited by the     %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        .lua script, only the one in the last pak will contribute to the COMBINED pak %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        As always, the natural NMS load order will dictate its effects...             %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
		echo. 
		echo. %_zBLACKonYELLOW%                                                                                  %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] Remember that a PATCH must be used WITH the original .pak ^(in most cases^) %_zDEFAULT%
		echo. %_zBLACKonYELLOW%             to get the full effect of the original + your script                 %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                  %_zDEFAULT%
		echo.

		echo.>>"REPORT.txt"
		echo|set /p="[NOTE]: One or more paks with at least one .lua script to apply over them">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]:   will create a PATCH pak (the COMBINED pak) ">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]: And if the same mbin file is present in any of the .pak and edited by the">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]:   .lua script, only the one in the last pak will contribute to the COMBINED pak">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]: As always, the natural NMS load order will dictate its effects...">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
		echo|set /p="[NOTE]: Remember that a PATCH must be used with the original .pak (in most cases)">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE]:   to get the full effect of the original + your script">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	)
		
	if %_bNumberScripts% GTR 0 (
		echo.^>^>^>      A GENERIC COMBINED MOD pak may be created...
		echo.^>^>^>      If you choose to COPY to your game folder, the PAKs will ALSO be copied there...
		SET _bCOMBINE_MODS=1
		SET _bCOPYtoNMS=NONE
		SET _bPATCH=1

		FOR /r "%~dp0\ModScript" %%G in (*.pak) do ( 
			SET _bPAKname=%%~nG
			echo|set /p="- a patch to be used with %%~nG.pak">>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
			echo.>>"MODBUILDER\COMBINED_CONTENT_LIST.txt"
		)
		goto :SIMPLE_MODE
	)
)
rem --------------  end Check # of PAKs present ------------------------------

rem *************************   check if pak in ModScript, no script   ************************
rem *************************  UNPACK and DECOMPILE paks to UNPACKED_DECOMPILED_PAKs  ******************
if %_bNumberScripts% EQU 0 (
	if %_bNumberPAKs% GEQ 1 (
		rem one or more paks, no script. Extracting ALL files
		
		REM rem ------  START of automatic processing: start the clock  -----------------------

		if %_bNumberPAKs% GTR 1 (
			if not defined _bStartTime (
				Call :LuaEndedOkREMOVE
				SET _bStartTime=Y
				MODBUILDER\%_mLUA% "MODBUILDER\StartTime.lua" ".\\" ".\\MODBUILDER\\"
				Call :LuaEndedOk
			)
		)
		
		if not exist "%CD%\UNPACKED_DECOMPILED_PAKs" (
			mkdir "%CD%\UNPACKED_DECOMPILED_PAKs\" 2>NUL
		)
		
		REM echo.
		FOR /r "%~dp0\ModScript" %%G in (*.pak) do ( 
			SET _bPAKname=%%~nG
			echo. %_zBLACKonYELLOW% **** Unpacking/decompiling !_bPAKname! **** %_zDEFAULT%
			echo|set /p="[INFO]: **** Unpacking/decompiling !_bPAKname! ****">>"REPORT.txt" & echo.>>"REPORT.txt"
			if not exist "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" (
				mkdir "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" 2>NUL
			)
			
			rem copy PAK to its folder
			xcopy /y /h /v "%%G" "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*" 1>NUL 2>NUL

			if not exist "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK" (
				mkdir "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK" 2>NUL
			)

			if not exist "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" (
				mkdir "%CD%\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" 2>NUL
			)

			cd ModScript
			rem ******   NOW IN ModScript   ********
			if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
			if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK

			set _bPaknamePATH=%%G
			CALL ..\MODBUILDER\ExtractMODfromPAK.bat
			rem the PAKs are now unpacked to UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK
			rem and the last PAK is also unpacked to ModScript\EXTRACTED_PAK

			call :UNPACKEDtoEXML
			rem the MBINs are now decompiled to UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK, if it was possible
			rem and the last PAK is also decompiled to ModScript\EXMLFILES_PAK
			set _bUNPACKED_DECOMPILED=y
			
			cd ..
			rem ******   NOW IN AMUMSS folder   ********

			if %_bNumberPAKs% EQU 1 (
				if !_uOldMBINCompilerFlag!==N (
					echo.
					FOR /r "%~dp0\ModScript\EXTRACTED_PAK" %%G in (*.lua) do ( 
						echo.Found script in this PAK: %%~nxG			
						SET _bUseLuaInPak=%_UseLuaInPak%			

						echo.
						if not defined _UseLuaInPak (
							CHOICE /c:YN /m "%_zRED%??? Do you want to rebuild the MOD pak(s) using this script %_zDEFAULT%"
							if !ERRORLEVEL! EQU 2 SET _bUseLuaInPak=N
							if !ERRORLEVEL! EQU 1 SET _bUseLuaInPak=Y
						)
						
						if !_bUseLuaInPak!==Y (
							echo.   Copying script to ModScript...
							set _bNoMod=
							SET _bBuildMODpak=y
							SET _bBuildMODpakFromPakScript=y
							
							REM we use the scripts as normal scripts
							xcopy /s /y /h /v "ModScript\EXTRACTED_PAK\*.lua" "Modscript\*"	1>NUL 2>NUL
						)
					)
				)
			)
		)
	)
)
rem *************************  end UNPACK and DECOMPILE paks to UNPACKED_DECOMPILED_PAKs  ******************

rem ******   NOW IN AMUMSS folder   ********

rem re-calculate the number of scripts in ModScript
SET _bNumberScripts=0
FOR %%G in ("%~dp0\ModScript\*.lua") do ( 
	SET /A _bNumberScripts=_bNumberScripts+1
)

if %_bNumberScripts% EQU 0 (
	set _bNoMod=y
) else (
	SET _bBuildMODpak=y
	CALL :CHECK_ExtraFilesToInclude
)

CALL :Cleaning_EXML_Helper

if %_uOldMBINCompilerFlag%==Y goto :ENDING
if %_bNumberScripts% EQU 0 set _bNoMod=y

rem -------- user options start here -----------
rem on 0, treat as INDIVIDUAL mods
rem on 1, treat as a generic combined mod
rem on 2, treat as a DISTINCT combined mod
rem on 3, treat as an INDIVIDUAL mod, the name being like Mod1+Mod2+Mod3.pak, a COMPOSITE mod
SET _bCOMBINE_MODS=0
SET _bCOPYtoNMS=NONE
CALL :DOPAUSE	

if defined _bNoMod goto :EXECUTE
if defined _mSIMPLE goto :SIMPLE_MODE 
if %_bNumberScripts% EQU 1 goto :SIMPLE_MODE

if defined -CombinedModPak (
	if !-CombinedModPak!==N (
		goto :CONTINUE_EXECUTION1
	) else (
		goto :WhatTypeOfCombinedMod
	)
)

echo.
echo.^>^>^> INDIVIDUAL PAKs may or may not work together depending on the EXML files they change
echo.    If they modify the same original EXML files, the last one loaded will win and the other changes will be lost...
echo.
echo.    You may use INDIVIDUAL PAKs when they don't interfere with each other
echo.
echo.^>^>^> COMBINED PAKs will try to keep, as much as possible, all changes made to a particular EXML file by re-using it during PAK creation
echo.    Only changes made to the same exact values of an EXML will reflect only the last mod
echo.

CHOICE /c:yn /m "%_zRED%??? Do you want to create a COMBINED mod[Y] or INDIVIDUAL mod(s)[N] %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 goto :CONTINUE_EXECUTION1

:WhatTypeOfCombinedMod
echo.
echo.^>^>^> A COMPOSITE combined MOD name has a length limit of less than 178 characters (excess will be truncated)
set /p _bCompositeName=<"MODBUILDER\Composite_MOD_FILENAME.txt"
echo.    It would be...
echo.      "%_bCompositeName%"
echo.               ...in this case
CHOICE /c:yn /m "%_zRED%??? Do you want to use a COMPOSITE combined MOD named just like that %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 goto :COMBINEDTYPE
if %ERRORLEVEL% EQU 1 SET _bCOMBINE_MODS=3
goto :SIMPLE_MODE

:COMBINEDTYPE
echo.
echo.^>^>^> A COMBINED MOD name can be like ZZZCombinedMod_(x).pak (where x is 0 to 9)
echo.                         ...or like ZZZCombinedMod_DATE-TIME.pak...
echo.
CHOICE /c:yn /m "%_zRED%??? Do you want to use a NUMERIC suffix[Y] or the current DATE-TIME[N] to differentiate your mod name %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET _bCOMBINE_MODS=1
if %ERRORLEVEL% EQU 1 SET _bCOMBINE_MODS=2
goto :SIMPLE_MODE

:CONTINUE_EXECUTION1
echo.
CHOICE /c:NSA /m "%_zRED%??? Would you like or [N]ot to COPY [S]ome or [A]ll Created Mod PAKs to your game folder and DELETE [DISABLEMODS.TXT] %_zDEFAULT%"
if %ERRORLEVEL% EQU 3 SET _bCOPYtoNMS=ALL
if %ERRORLEVEL% EQU 2 SET _bCOPYtoNMS=SOME
if %ERRORLEVEL% EQU 1 SET _bCOPYtoNMS=NONE

goto :EXECUTE

:SIMPLE_MODE
if %_bNumberScripts% EQU 0 goto :EXECUTE

echo.
CHOICE /c:YN /m "%_zRED%??? Would you like to COPY the created Mod PAKs to your game folder and DELETE [DISABLEMODS.TXT] %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET _bCOPYtoNMS=NONE
if %ERRORLEVEL% EQU 1 SET _bCOPYtoNMS=ALL
rem -------- user options end here -----------

:EXECUTE

rem EXECUTE --------------------------------------------
if not exist "%CD%\CreatedModPAKs" (
	mkdir "%CD%\CreatedModPAKs\" 2>NUL
)
Del /f /q /s ".\CreatedModPAKs\*.*" 1>NUL 2>NUL

Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOk.txt" 1>NUL 2>NUL

Del /f /q "TempScript.lua" 1>NUL 2>NUL
Del /f /q "TempTable.lua" 1>NUL 2>NUL

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER
pushd "%CD%"

echo|set /p="%~dp0">MASTER_FOLDER_PATH.txt

rem always Cleaning _TEMP at the start of a new run
CALL :Cleaning_TEMP

if defined _mVERBOSE (
	echo.
	echo.^>^>^> %_bB% Changed to %CD%
)

del /f /q OnlyOneScript.txt 1>NUL 2>NUL

if %_bNumberScripts% EQU 1 (
	echo|set /p="">OnlyOneScript.txt
)

if %_bNumberPAKs% EQU 0 (
	CALL :CONFLICTDETECTION
	
	REM get list of files in paks in MODS folder
	if !_bCheckMODSconflicts! EQU 1 CALL PSARC_LIST_PAKS_MODS.BAT

	CALL :PAK_LISTsCREATION
)

REM rem **************************  MapFileTrees creation choice section  ********************************
if not defined _bRecreateMapFileTrees (
	echo.
	if defined _bNMSUpdated (
		echo.^>^>^> There was a NMS update, it is recommended to recreate the MapFileTrees files
		echo.
		echo.^>^>^> Some of your MapFileTrees files may be outdated
		echo.^>^>^>    You can recreate them using the script MapFileTree_UPDATER.lua
		echo.^>^>^>    To update a specific file, add it to the script
		echo.^>^>^> All other MapFileTrees will be updated as you process other scripts
	)

	if defined _mWbertro (
		set _bRecreateMapFileTrees=1
		goto :START
	)

	echo.
	CHOICE /c:yn /m "%_zRED%??? Do you want to (RE)CREATE the MapFileTrees files DURING script processing %_zDEFAULT%"
	if %ERRORLEVEL% EQU 1 (set _bRecreateMapFileTrees=1)
)
rem **************************  end MapFileTrees creation choice section  ********************************

:START
rem ------  START of automatic processing: start the clock  -----------------------
if not defined _bStartTime (
	Call :LuaEndedOkREMOVE
	SET _bStartTime=Y
	%_mLUA% StartTime.lua "..\\" ""
	Call :LuaEndedOk
)

if %_bNumberPAKs% GTR 0 (
	echo.
	if %_bNumberScripts% GTR 0 (
		echo.---------------------------------------------------------
		echo.^>^>^> So, we are making a GENERIC COMBINED MOD PAK...	
		echo|set /p="[INFO]:   A GENERIC COMBINED MOD will be created...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
		if defined _bExtraFilesInPAK (
			echo.^>^>^>      Extra Files in ModExtraFilesToInclude will be included
			echo|set /p="[INFO]:   Extra Files in ModExtraFilesToInclude will be included">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
		) else (
			if !_bExtraFiles! GTR 0 (
				echo.^>^>^>      Extra Files in ModExtraFilesToInclude will NOT be included
				echo|set /p="[INFO]:   Extra Files in ModExtraFilesToInclude will NOT be included">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			)
		)
		if %_bCOPYtoNMS%==NONE (
			echo.^>^>^>      It will NOT be copied to NMS MOD folder
			echo|set /p="[INFO]:   It will NOT be copied to NMS MOD folder">>"..\REPORT.txt"
		)
		if %_bCOPYtoNMS%==ALL (
			if %_bNumberPAKs% GTR 1 (
				echo.^>^>^>      and will be copied with the user PAKs to NMS MOD folder
				echo|set /p="[INFO]:   and will be copied with the user PAKs to NMS MOD folder">>"..\REPORT.txt"
			) else (
				echo.^>^>^>      and will be copied with the user PAK to NMS MOD folder
				echo|set /p="[INFO]:   and will be copied with the user PAK to NMS MOD folder">>"..\REPORT.txt"
			)
		)
	)
	echo.>>"..\REPORT.txt"
	echo.>>"..\REPORT.txt"
) else (
	if defined _bNoMod goto :SIMPLE_MODE2
	echo.
	echo.---------------------------------------------------------
	if %_bCOMBINE_MODS% EQU 0 (
		echo.^>^>^> So, we are making INDIVIDUAL MOD PAKs...
		echo|set /p="[INFO]:   INDIVIDUAL MOD PAKs will be created...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
	if %_bCOMBINE_MODS% EQU 1 (
		echo.^>^>^> So, we are making a GENERIC COMBINED MOD PAK...	
		echo|set /p="[INFO]:   A GENERIC COMBINED MOD will be created...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
	if %_bCOMBINE_MODS% EQU 2 (
		echo.^>^>^> So, we are making one or more DISTINCT COMBINED MOD PAK...	
		echo|set /p="[INFO]:   One or more DISTINCT COMBINED MOD PAK will be created...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
	if %_bCOMBINE_MODS% EQU 3 (
		echo.^>^>^> So, we are making a COMPOSITE-NAME COMBINED MOD PAK...	
		echo|set /p="[INFO]:   A COMPOSITE-NAME COMBINED MOD will be created...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
	if defined _bExtraFilesInPAK (
		echo.^>^>^>      Extra Files in ModExtraFilesToInclude will be included
		echo|set /p="[INFO]:   Extra Files in ModExtraFilesToInclude will be included">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	) else (
		if !_bExtraFiles! GTR 0 (
			echo.^>^>^>      Extra Files in ModExtraFilesToInclude will NOT be included
			echo|set /p="[INFO]:   Extra Files in ModExtraFilesToInclude will NOT be included">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
		)
	)
	if %_bCOPYtoNMS%==NONE (
		echo.^>^>^>      and NONE will be copied to NMS MOD folder
		echo|set /p="[INFO]:   and NONE will be copied to NMS MOD folder">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
	if %_bCOPYtoNMS%==ALL (
		echo.^>^>^>      and ALL will be copied to NMS MOD folder
		echo|set /p="[INFO]:   and ALL will be copied to NMS MOD folder">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	)
)
echo.---------------------------------------------------------

if defined _mSIMPLE goto :SIMPLE_MODE2 
if defined _min_subprocess goto :SIMPLE_MODE2 

if not defined _mSKIP_USER_PAUSE (
	REM echo.Waiting 3 sec...
	timeout /T 3 /NOBREAK
)

rem *********************  STILL IN MODBUILDER  *******************
:SIMPLE_MODE2 
if not defined _bBuildMODpak goto :ENDING

Del /f /q "..\SerializedScript.lua" 1>NUL 2>NUL

echo.
echo.^>^>^> %_bB% Number of scripts to build: %_bNumberScripts%

rem Let MapFileTreeCreator know it can run if requested
echo|set /p="">MapFileTreeCreatorRun.txt

rem ###################################################################
rem --------  processing loop only if scripts are present -------------
rem ###################################################################

	Call :LuaEndedOkREMOVE
	%_mLUA% LoadAndExecuteModScript.lua
	Call :LuaEndedOk
	
	IF EXIST "LoadScriptAndFilenamesERROR.txt" (
		set _bErrorLoadingScript=y
	)
		
	REM CALL :DOPAUSE
	IF DEFINED _bErrorLoadingScript (
		echo|set /p="    [ENDED THIS SCRIPT PROCESSING]: ========================================================================================">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
		echo.
	)
	set _bErrorLoadingScript=
	del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL

rem ##########################################################################
rem --------  end of processing loop only if scripts are present -------------
rem ##########################################################################

rem Let MapFileTreeCreator know it can terminate if it has completed its works
Del /f /q MapFileTreeCreatorRun.txt 1>NUL 2>NUL

:ENDING
echo.
echo.^>^>^>  Ending phase...

rem ******   NOW IN AMUMSS folder   ********
cd "%~dp0"

if %_bNumberScripts% GTR 0 (
	echo.
	echo.^>^>^> %_bB% Updating EXML_Helper\MOD_EXML...

	echo.>>"REPORT.txt"
	echo|set /p="[INFO]: Updated EXML_Helper\MOD_EXML">>"REPORT.txt" & echo.>>"REPORT.txt"

	if %_bNumberScripts% GTR 1 (
		echo.^>^>^> %_bB%     Note that the MOD_EXML files ARE based on the last processed script if individual mods were created
		echo|set /p="[INFO]:     Note that the MOD_EXML files ARE based on the last processed script if individual mods were created">>"REPORT.txt" & echo.>>"REPORT.txt"
	)
	
	xcopy /f /s /y /h /e /v /i /j /c "MODBUILDER\MOD\*.EXML" "EXML_Helper\MOD_EXML\" 1>NUL 2>NUL

	echo.^>^>^> %_bB% Updating EXML_Helper\ORG_EXML...
	echo|set /p="[INFO]: Updated EXML_Helper\ORG_EXML">>"REPORT.txt" & echo.>>"REPORT.txt"

	xcopy /s /y /h /e /v /i /j /c "MODBUILDER\_TEMP\DECOMPILED\*.EXML" "EXML_Helper\ORG_EXML\" 1>NUL 2>NUL
)

echo.
echo.%_zDARKGRAY%-----------------------------------------%_zDEFAULT%
echo.%_zRED%^>^>^> %_bB% AMUMSS finished%_zDEFAULT%
echo.%_zDARKGRAY%-----------------------------------------%_zDEFAULT%
echo.

if defined _bNoMod (
	if %_bNumberPAKs% EQU 0 (
		echo.^>^>^>   [WARNING] No user .lua Mod Script found in ModScript...
		echo.^>^>^>   You may want to put some .lua Mod script in the ModScript folder and retry...

		echo|set /p=".   [WARNING]: No user .lua Mod Script found in ModScript...">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[INFO]: You may want to put some .lua Mod script in the ModScript folder and retry...">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	) else (
		echo.^>^>^>   [INFO] NO user .lua Mod Script to found in ModScript...
		echo.^>^>^>   You may want to put some .lua Mod script in the ModScript folder and retry...
		
		echo|set /p="[INFO]: NO user .lua Mod Script to found in ModScript...">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	)
) else (
	if not defined _bErrorLoadingScript (
		echo.>>"REPORT.txt"
		echo.^>^>^> Created PAKs are in local folder ^>^>^> CreatedModPAKs ^<^<^<
		echo.^>^>^> Backups in ^>^>^> Builds ^<^<^< and ^>^>^> Builds\IncrementalBuilds ^<^<^<

		echo|set /p="[INFO]: Created PAKs are in local folder >>> CreatedModPAKs <<<">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[INFO]: Backups in >>> Builds <<< and >>> Builds\IncrementalBuilds <<<">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
		echo|set /p="[INFO]: END OF PROCESSING">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[INFO]: Total scripts processed: %_bNumberScripts%">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	)
)

Call :LuaEndedOkREMOVE
.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckCONFLICTLOG.lua" ".\\" ".\\MODBUILDER\\" "" %_bCheckMODSconflicts%
Call :LuaEndedOk

echo.              ^>^>^> FINAL REPORT  ^<^<^<
echo.            ^>^>^> See "REPORT.txt"  ^<^<^<

echo.>>"REPORT.txt"
echo|set /p="[INFO]:                 >>> FINAL REPORT  <<<">>"REPORT.txt" & echo.>>"REPORT.txt"

if defined _bErrorLoadingScript (
	echo.
	echo.  ^>^>^>  INTERRUPTED / INCOMPLETE PROCESSING  ^<^<^<

	echo.>>"REPORT.txt"
	echo|set /p="[INFO]:     >>>  INTERRUPTED / INCOMPLETE PROCESSING  <<<">>"REPORT.txt" & echo.>>"REPORT.txt"
)

Call :LuaEndedOkREMOVE
.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckREPORTLOG.lua" ".\\" ".\\MODBUILDER\\"
Call :LuaEndedOk

echo.            ^>^>^> See "REPORT.txt"  ^<^<^<

REM get time to process
if defined _bStartTime (
	Call :LuaEndedOkREMOVE
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\EndTime.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk

	Call :LuaEndedOkREMOVE
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\DiffTime.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk
)

if %_uOldMBINCompilerFlag%==Y (
	if %_bNumberScripts% GTR 0 (
		echo.
		echo.%_zRED%============================================================================%_zDEFAULT%
		echo. %_zINVERSE%[NOTE] Some PAKs could not be decompiled by the current MBINCompiler      %_zDEFAULT%
		echo. %_zINVERSE%       Processing of .lua scripts is halted until those PAKs are removed  %_zDEFAULT%
		echo. %_zINVERSE%       from ModScript                                                     %_zDEFAULT%
		echo.%_zRED%============================================================================%_zDEFAULT%

		echo|set /p="[NOTE] Some PAKs could not be decompiled by the current MBINCompiler">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE] Processing of .lua scripts is halted until those PAKs are removed">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p="[NOTE] from ModScript">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo.>>"REPORT.txt"
	)
)

if defined _bUNPACKED_DECOMPILED (
	echo.
	echo.%_zRED%      %_bNumberPAKs% PAK^(s^) processed%_zDEFAULT%
	echo.%_zRED%      	%_bGNumberFiles% file^(s^) found in PAK^(s^)%_zDEFAULT%
	if %_bGNumberFilesNoVersionInfo% GTR 0 (
		echo.%_zRED%      	%_bGNumberFilesNoVersionInfo% file^(s^) having NO Version information%_zDEFAULT%
	)
	echo.%_zRED%      	%_bGNumberFilesDecompiled% file^(s^) decompiled%_zDEFAULT%
	if %_bNumberFilesCouldNotDecompile% GTR 0 (
		echo.%_zRED%      	%_bNumberFilesCouldNotDecompile% file^(s^) could not be decompiled by any MBINCompiler version%_zDEFAULT%
	)
	if %_bGNumberFilesMissing% GTR 0 (
		echo.%_zRED%      	%_bGNumberFilesMissing% file^(s^) missing the right MBINCompiler%_zDEFAULT%
		echo.          %_zBLACKonYELLOW%    Please report missing VERSION to AMUMSS developper, thanks.    %_zDEFAULT%
	)

	echo.>>"REPORT.txt"
	echo|set /p="[INFO]: %_bNumberPAKs% PAK(s) processed">>"REPORT.txt" & echo.>>"REPORT.txt"
	echo|set /p="[INFO]:   %_bGNumberFiles% file(s) found in PAK(s)">>"REPORT.txt" & echo.>>"REPORT.txt"
	if %_bGNumberFilesNoVersionInfo% GTR 0 (
		echo|set /p="[INFO]:   %_bGNumberFilesNoVersionInfo% file(s) having NO Version information">>"REPORT.txt" & echo.>>"REPORT.txt"
	)
	echo|set /p="[INFO]:   %_bGNumberFilesDecompiled% file(s) decompiled">>"REPORT.txt" & echo.>>"REPORT.txt"
	if %_bNumberFilesCouldNotDecompile% GTR 0 (
		echo|set /p="[INFO]:   %_bNumberFilesCouldNotDecompile% file(s) could not be decompiled by any MBINCompiler version">>"REPORT.txt" & echo.>>"REPORT.txt"
	)
	if %_bGNumberFilesMissing% GTR 0 (
		echo|set /p="[INFO]:   %_bGNumberFilesMissing% file(s) missing the right MBINCompiler">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p=".   [WARNING]:     Please report missing VERSION to AMUMSS developper, thanks.">>"REPORT.txt" & echo.>>"REPORT.txt"
	)
	echo.>>"REPORT.txt"

	if %_uOldMBIN%==Y (
		echo.
		echo.   %_zRED%========================================================%_zDEFAULT%
		echo.    %_zINVERSE%NOTE: An older version of MBINCompiler was used       %_zDEFAULT%
		echo.    %_zINVERSE%      or the MBIN file was never compiled             %_zDEFAULT%
		echo.    %_zINVERSE%      or the right MBINCompiler could not be found.   %_zDEFAULT%
		echo.    %_zINVERSE%      It means that one or more EXML are most likely  %_zDEFAULT%
		echo.    %_zINVERSE%      not compatible with the current version of NMS. %_zDEFAULT%
		if %_bNumberScripts% GTR 0 (
			echo. %_zINVERSE%      No PAK will be produced^^!                      %_zDEFAULT%
		)
		echo.   %_zRED%========================================================%_zDEFAULT%
		
		echo.>>"REPORT.txt"
		echo|set /p=".   [NOTE]: An older version of MBINCompiler was used">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p=".   [NOTE]: or the MBIN file was never compiled">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p=".   [NOTE]: or the right MBINCompiler could not be found.">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p=".   [NOTE]: It means that one or more EXML are most likely">>"REPORT.txt" & echo.>>"REPORT.txt"
		echo|set /p=".   [NOTE]: not compatible with the current version of NMS..">>"REPORT.txt" & echo.>>"REPORT.txt"
		if %_bNumberScripts% GTR 0 (
			echo|set /p=".   [NOTE]: No PAK will be produced^!">>"REPORT.txt" & echo.>>"REPORT.txt"
		)
		echo.>>"REPORT.txt"
	)

	echo.
	echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%
	echo. %_zBLACKonYELLOW% ^>^>^> You can examine the content of the PAKs in the UNPACKED_DECOMPILED_PAKs folder under the PAK name %_zDEFAULT%
	echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%
	echo. %_zBLACKonYELLOW% ^>^>^> The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders        %_zDEFAULT%
	echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%

	echo|set /p="[INFO]: You can examine the content of the PAKs in the UNPACKED_DECOMPILED_PAKs folder under the PAK name">>"REPORT.txt" & echo.>>"REPORT.txt"
	echo.>>"REPORT.txt"
	echo|set /p="[INFO]: The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders">>"REPORT.txt" & echo.>>"REPORT.txt"
	echo.>>"REPORT.txt"
)

if defined _min_subprocess (
	echo.################ IN DEBUG MODE ################
	echo.
	if defined _mDEBUG (
		set _
		echo.%_zDEFAULT%
		echo. ********* OPTIONS *********
		set -
	)
	echo.%_zDEFAULT%
)

If defined _mWbertro (
	Call :LuaEndedOkREMOVE
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckGlobalReplacements.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk
)

REM cleanup %_mLUA% errors
del /f /q .\MODBUILDER\LuaEndedOk.txt 1>NUL 2>NUL
REM end cleanup %_mLUA% errors

if not defined _mDEBUG (
	REM echo.Pause before exit
	pause
)

rem ****seekker*****************************************************
rem *********************************************************
If defined _mdebugS goto :eof 
rem ---- only runs if _mdebugS not present

rem --- delete created folders
rmdir /s /q .\MODBUILDER\_TEMP 1>NUL 2>NUL
rmdir /s /q .\MODBUILDER\MOD 1>NUL 2>NUL


rem --- delete created temp text file
del /f /q .\MODBUILDER\Composite_MOD_FILENAME.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\CurrentModScript.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\input.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MASTER_FOLDER_PATH.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MBIN_PAKS.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MBINCompiler.log 1>NUL 2>NUL
del /f /q .\MODBUILDER\MOD_FILENAME.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MOD_MBIN_SOURCE.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MOD_PAK_SOURCE.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\MODS_pak_list.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\NMS_FOLDER.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\pak_listDateTime.txt 1>NUL 2>NUL
del /f /q .\MODBUILDER\Times.txt 1>NUL 2>NUL
REM ---- full clean up added by seekker
rem ****/seekker*****************************************************
rem *********************************************************

goto :eof
rem *****************************************************************************************
rem               --------------------- WE ARE DONE ---------------------
rem *****************************************************************************************

rem --------------------------------------------
rem subroutine section starts below

rem --------------------------------------------
:Cleaning_EXML_Helper
	:RETRY4
	Del /f /q /s "EXML_Helper\*.*" 1>NUL 2>NUL
	if exist "EXML_Helper" (
		rd /s /q "EXML_Helper" 2>NUL
		goto :RETRY4
	)
	mkdir "EXML_Helper"
	mkdir "EXML_Helper\MOD_EXML"
	mkdir "EXML_Helper\ORG_EXML"
	EXIT /B
	
rem --------------------------------------------
:Cleaning_TEMP
	:RETRY5
	Del /f /q /s "_TEMP\*.*" 1>NUL 2>NUL
	if exist "_TEMP" (
		rd /s /q "_TEMP" 2>NUL
		goto :RETRY5
	)
	rem DO NOT create _TEMP
	EXIT /B
	
rem --------------------------------------------
:Cleaning_EXTRACTED_PAK
	:RETRY7
	Del /f /q /s "EXTRACTED_PAK\*.*" 1>NUL 2>NUL
	if exist "EXTRACTED_PAK" (
		rd /s /q "EXTRACTED_PAK" 1>NUL 2>NUL
		goto :RETRY7
	)
	rem DO NOT create ModScript\EXTRACTED_PAK
	EXIT /B

rem --------------------------------------------
:Cleaning_EXMLFILES_PAK
	:RETRY8
	Del /f /q /s "EXMLFILES_PAK\*.*" 1>NUL 2>NUL
	if exist "EXMLFILES_PAK" (
		rd /s /q "EXMLFILES_PAK" 1>NUL 2>NUL
		goto :RETRY8
	)
	rem DO NOT create ModScript\EXMLFILES_PAK
	EXIT /B

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
:MBINCompilerUPDATE
	rem ****************************  start MBINCompiler.exe update section  ******************************
	echo.
	if not exist "MBINCompiler.exe" (
		Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
		echo.^>^>^> Fetching MBINCompiler on the web...
		goto :RETRY_MBINCompiler
	)

	Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
	MBINCompiler.exe version -q >>MBINCompilerVersion.txt
	set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt
	echo.^>^>^> Your current MBINCompiler is version: %_zGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
	set /p _bMBINCompilerVersionOLD=<MBINCompilerVersion.txt

	if defined _mCUSTOM_MBINCOMPILER goto :END_MBINCompilerUPDATE
	REM echo.
	REM CHOICE /c:yn /t 30 /d y /m "%_zRED%??? Do you need to UPDATE MBINCompiler.exe, (default Y in 30 seconds) %_zDEFAULT%"
	REM if %ERRORLEVEL% EQU 2 goto :CONTINUE_EXECUTION2

	REM :SIMPLE_MODE1
	REM echo.
	REM REM echo.^>^>^> %_bB% Calling MBINCompilerDownloader.bat: getting latest MBINCompiler from Web
	REM echo.^>^>^> Getting latest MBINCompiler from Web...

	:RETRY_MBINCompiler
	CALL MBINCompilerDownloader.bat

	:CONTINUE_EXECUTION2
	if not exist "MBINCompiler.exe" (
		Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
		goto :RETRY_MBINCompiler
	)
	
	Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
	MBINCompiler.exe version -q >>"MBINCompilerVersion.txt"
	set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt

	if NOT "%_bMBINCompilerVersionOLD%"=="%_bMBINCompilerVersion%" (
		echo.
		echo.^>^>^> Your new MBINCompiler is version: %_zGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
		echo|set /p="[INFO]: Your new MBINCompiler is version: %_bMBINCompilerVersion%">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
		echo.>>"..\REPORT.txt"
	REM ) else (
		REM echo.
		REM echo.^>^>^> MBINCompiler is still version: %_zGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
	)
	rem ****************************  end MBINCompiler.exe update section  ******************************

	:END_MBINCompilerUPDATE
	EXIT /B

rem --------------------------------------------
:CONFLICTDETECTION
	rem -------------   Conflict detection or not?  -------------
	echo.
	CHOICE /c:yn /m "%_zRED%??? Would you like to check your NMS MODS for conflict? %_zDEFAULT%"
	if %ERRORLEVEL% EQU 2 set _bCheckMODSconflicts=2
	if %ERRORLEVEL% EQU 1 set _bCheckMODSconflicts=1
	EXIT /B

rem --------------------------------------------
:CHECK_ExtraFilesToInclude
	rem --------------  Check if ExtraFilesToInclude are present ------------------------------
	SET _bExtraFiles=0

	FOR /r "%~dp0\ModExtraFilesToInclude" %%G in (*.*) do ( 
		SET /A _bExtraFiles=_bExtraFiles+1
	)
	if %_bExtraFiles% EQU 0 goto :NO_EXTRAFILES

	echo.
	echo.^>^>^> There are Extra Files in the ModExtraFilesToInclude folder.  If you INCLUDE them...
	echo.^>^>^>      *****  Remember, these files will OVERWRITE any existing ones in the created PAK  *****

	CHOICE /c:YN /m "%_zRED%??? Do you want to include them in the created PAK %_zDEFAULT%"
	echo.
	if %ERRORLEVEL% EQU 2 goto :NO_EXTRAFILES
	if %ERRORLEVEL% EQU 1 SET _bExtraFilesInPAK=y

	echo|set /p="[INFO]: Extra Files in the ModExtraFilesToInclude folder will be included in the PAK">>"REPORT.txt" & echo.>>"REPORT.txt"
	echo.>>"REPORT.txt"

	:NO_EXTRAFILES
	EXIT /B

rem --------------------------------------------
:PAK_LISTsCREATION
	rem **************************  start PAK_LISTs creation section  ********************************
	echo.
	echo.^>^>^> Checking NMS PCBANKS PAK file lists existence...

	REM check if we need to re-create the list
	CALL GetDateTimePCBANKS.bat

	if exist "pak_list.txt" SET _gPAKlistExist=y

	if defined _gPAKlistExist goto :Ask

	echo.
	echo.^>^>^> [INFO] NMS PCBANKS was updated...
	echo.
	set _bNMSUpdated=1

	:DoUpdate
	CALL PSARC_LIST_PAKS.BAT
	REM if defined _mVERBOSE (
		REM Call :LuaEndedOkREMOVE
		REM %_mLUA% FormatPAKlist.lua
		REM Call :LuaEndedOk
	REM )

	goto :NoNeedToAsk

	:Ask
	if NOT exist "..\NMS_FULL_pak_list.txt" goto :DoUpdate

	if NOT defined _mDEBUG goto :NoNeedToAsk
	echo.
	REM echo.^>^>^> If there was a NMS update, it is recommended to recreate this list
	CHOICE /c:yn /m "%_zRED%??? Do you want to RECREATE the NMS PAK file list %_zDEFAULT%"
	if %ERRORLEVEL% EQU 2 set _bRecreatePAKList=2
	if %ERRORLEVEL% EQU 1 set _bRecreatePAKList=1

	if %_bRecreatePAKList% EQU 1 (
		echo.
		CALL PSARC_LIST_PAKS.BAT
		REM if defined _mVERBOSE (
			REM Call :LuaEndedOkREMOVE
			REM %_mLUA% FormatPAKlist.lua
			REM Call :LuaEndedOk
			REM )
	)

	:NoNeedToAsk
	SET _gPAKlistExist=
	SET _bRecreatePAKList=
	rem **************************  end PAK_LISTs creation section  ********************************
	EXIT /B

rem --------------------------------------------
:UNPACKEDtoEXML
	rem ******   Currently IN ModScript   ********
	REM @echo on
	echo.
	set "_bCurrentPath=%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_PAK\"
	
	Del /f /q /s "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
	echo|set /p="REPORT for !_bPAKname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
	
	set _bNumberFilesNoVersionInfo=0
	SET _bNumberFiles=0
	FOR /r ".\EXTRACTED_PAK\" %%G in (*.mbin.*) do (
		REM echo.With current MBINCompiler: %%G
		SET /A _bNumberFiles=_bNumberFiles+1
		set "_bG=%%G"
		set _bNMSname=!_bG:%_bCurrentPath%=!
		set _gMBINVersion=
		Del /f /q /s ".\EXTRACTED_PAK\MBINVersion.txt" 1>NUL 2>NUL
		rem get MBINCompiler version that compiled this MBIN
		..\MODBUILDER\MBINCompiler.exe version -q "%%G">>".\EXTRACTED_PAK\MBINVersion.txt"
		set /p _gMBINVersion=<".\EXTRACTED_PAK\MBINVersion.txt"
		REM Del /f /q /s ".\EXTRACTED_PAK\MBINVersion.txt" 1>NUL 2>NUL
		if "!_gMBINVersion!"=="0.0.0.0" (
			SET /A _bNumberFilesNoVersionInfo=_bNumberFilesNoVersionInfo+1
			echo.----- %_zRED%[NO VERSION INFO]%_zDEFAULT%    Never compiled: !_bNMSname!
			echo|set /p=".   [NO VERSION INFO]:    Never compiled: !_bNMSname!">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			echo|set /p=".   [NO VERSION INFO]:    Never compiled: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.----- [INFO] Compiled with version !_gMBINVersion!: !_bNMSname!
			echo|set /p="[INFO]:     Compiled with version !_gMBINVersion!: !_bNMSname!">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			echo|set /p="[INFO]:     Compiled with version !_gMBINVersion!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)
	echo.
	echo.%_zGREEN%^>^>^> %_bB% Trying to decompile .mbin...%_zDEFAULT%
	echo.>>"..\REPORT.txt"
	echo|set /p="[INFO]:   Trying to decompile .mbin...">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	echo|set /p="[INFO]:   Trying to decompile .mbin...">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

	rem First we try our current MBINCompiler, extracting ALL to folder EXTRACTED_PAK
	..\MODBUILDER\mbincompiler.exe convert -y -f -oEXML -d".\EXTRACTED_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" ".\EXTRACTED_PAK" 1>NUL 2>NUL

	SET _uOldMBIN=N

	SET _bNumberFilesDecompiled=0
	SET _bNumberFilesMissing=0
	SET _bNumberFilesCouldNotDecompile=0

	FOR /r ".\EXTRACTED_PAK\" %%G in (*.mbin.*) do (
		REM echo.With other MBINCompilers: %%G
		echo.For !_bNMSname!
		set "_bG=%%G"
		set _bNMSname=!_bG:%_bCurrentPath%=!

		set _gMBIN_FILE=%%G
		set _gMBIN_FILE=!_gMBIN_FILE:.MBIN.PC=.MBIN!
		set _gEXML_FILE=!_gMBIN_FILE:.MBIN=.EXML!
		
		if exist !_gEXML_FILE! (
			REM we already tried to use current MBINCompiler
			REM echo.%_zGREEN%   Trying MBINCompiler.%_bMBINCompilerVersion%%_zDEFAULT%
			echo.      [INFO] SUCCESS: Decompiled with current %_zGREEN%MBINCompiler.%_bMBINCompilerVersion%%_zDEFAULT%
			echo|set /p="[INFO]:     SUCCESS: Decompiled with current MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			echo|set /p="[INFO]:     SUCCESS: Decompiled with current MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			SET /A _bNumberFilesDecompiled=_bNumberFilesDecompiled+1
		) else (
			REM we need to try all MBINCompiler.exe
			REM maybe we will get lucky
			echo.
			SET _uFound=N
			SET _bBadCompiler=N
			SET _bCurrentCompiler=""
			for /f "tokens=*" %%H in ('dir /b /O:-N "..\MODBUILDER\Extras\MBINCompiler_OldVersions\*.exe"') do (
				if exist !_gEXML_FILE! (
					if !_uOldMBINCompilerFlag!==N (
						set _uOldMBINCompilerFlag=Y
						set _uOldMBIN=Y
					)
					if !_uFound!==N (
						SET _uFound=Y
						if !_bBadCompiler!==Y (
							set _zUOLE=%_zUpOneLineErase%
						)
						SET _bBadCompiler=N
						REM echo.----- [INFO] SUCCESS: Decompiled with !_bCurrentCompiler!
						REM SET /A _bNumberFilesDecompiled=_bNumberFilesDecompiled+1
					)
				) else (
					SET _bCurrentCompiler=%%~nH
					
					if !_bBadCompiler!==Y (
						echo.%_zUpOneLineErase%%_zUpOneLineErase%%_zGREEN%   Trying %%~nH%_zDEFAULT%
					) else (
						echo.%_zUpOneLineErase%%_zGREEN%   Trying %%~nH%_zDEFAULT%
					)
					SET _gMBINVersion=%%~nH
					SET _gMBINVersion=!_gMBINVersion:MBINCompiler.=!
					REM echo.----- [INFO] version [!_gMBINVersion!]
					
					rem these do not return MBINCompiler version info
					rem and ask to press a key
					SET _bBadCompiler=N
					if "!_gMBINVersion!"=="1.58.0" SET _bBadCompiler=Y
					if "!_gMBINVersion!"=="1.57.0" SET _bBadCompiler=Y
					if "!_gMBINVersion!"=="1.55.0" SET _bBadCompiler=Y
					if "!_gMBINVersion!"=="1.53.0" SET _bBadCompiler=Y
					if "!_gMBINVersion!"=="1.52.0" SET _bBadCompiler=Y
					if "!_gMBINVersion!"=="1.38.0" SET _bBadCompiler=Y
					
					if !_bBadCompiler!==Y (
						rem echo.%_zRED%Sorry, this version of MBINCompiler requires you to press any key...%_zDEFAULT%
						rem trying to extracts to folder EXTRACTED_PAK
						echo. & echo.|..\MODBUILDER\Extras\MBINCompiler_OldVersions\%%~nH "%%G" 1>NUL 2>NUL
					) else (
						rem trying to extracts to folder EXTRACTED_PAK
						..\MODBUILDER\Extras\MBINCompiler_OldVersions\%%~nH "%%G" 1>NUL 2>NUL
					)
				)
			)
			if !_uFound!==Y (
				echo.%_zUpOneLineErase%!_zUOLE!      [INFO] SUCCESS: Decompiled with ------^> %_zGREEN%!_bCurrentCompiler!%_zDEFAULT%
				echo|set /p="[INFO]:     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
				echo|set /p="[INFO]:     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
				SET /A _bNumberFilesDecompiled=_bNumberFilesDecompiled+1
			) else (
				SET /A _bNumberFilesCouldNotDecompile=_bNumberFilesCouldNotDecompile+1
				echo.%_zUpOneLineErase%!_zUOLE!%_zRED%      [INFO] SORRY: Could not decompile this file%_zDEFAULT%
				echo|set /p="[INFO]:       SORRY:                 Could not decompile this file: !_bNMSname!">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
				echo|set /p="[INFO]:       SORRY:                 Could not decompile this file: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			)
			set _zUOLE=
			
			Del /f /q /s "..\MODBUILDER\Extras\MBINCompiler_OldVersions\*.log" 1>NUL 2>NUL				
			REM )
		)
	)
	
	echo.
	echo.%_zGREEN%^>^>^> Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files%_zDEFAULT%
	
	echo|set /p="[INFO]:   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
	echo|set /p="[INFO]:   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

	if not exist ".\EXMLFILES_PAK" (
		mkdir "EXMLFILES_PAK" 2>NUL
	)

	if %_bNumberFilesMissing% GTR 0 (
		REM echo.
		if %_bNumberFilesMissing% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file is missing the right version of MBINCompiler, please report%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: One file is missing the right version of MBINCompiler, please report">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: One file is missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)

	if %_bNumberFilesCouldNotDecompile% GTR 0 (
		REM echo.
		if %_bNumberFilesCouldNotDecompile% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			REM echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file cannot be decompiled using any MBINCompiler%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: One file cannot be decompiled using any MBINCompiler">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			REM echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: One file cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)
	
	if %_bNumberFilesNoVersionInfo% GTR 0 (
		REM echo.
		if %_bNumberFilesNoVersionInfo% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: %_bNumberFilesNoVersionInfo% files have NO version information">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			REM echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: %_bNumberFilesNoVersionInfo% files have NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file has NO version information%_zDEFAULT%
			
			echo|set /p=".   [WARNING]: One file has NO version information">>"..\REPORT.txt" & echo.>>"..\REPORT.txt"
			REM echo.>>"..\REPORT.txt"
			echo|set /p=".   [WARNING]: One file has NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	) else (
		echo.>>"..\REPORT.txt"	
	)

	rem *******************  any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
	echo.
	echo.%_zGREEN%^>^>^> Moving EXML to EXMLFILES_PAK folders...%_zDEFAULT%
	FOR /r "EXTRACTED_PAK" %%G in (*.exml) do (
		set _gEXML_FILE=%%G
		set _gEXML_FILE=!_gEXML_FILE:EXTRACTED_PAK=EXMLFILES_PAK!
		rem NOTE: move command did not work
		xcopy /y /h /v "%%G" "!_gEXML_FILE!*" 1>NUL 2>NUL
		REM xcopy /y /h /v /s "%%G" "%_bMASTER_FOLDER_PATH%UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK\" 1>NUL 2>NUL
	)

	rem doing it in two step so we can use the pak info in ModScript with a .lua
	rem when one exist (inside the pak or from the user)
	xcopy /y /h /v /s "EXMLFILES_PAK" "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK\" 1>NUL 2>NUL

	xcopy /y /h /v "EXTRACTED_PAK\*.lua" "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*" 1>NUL 2>NUL
	
	Del /f /q /s ".\EXTRACTED_PAK\*.exml" 1>NUL 2>NUL
	rem *******************  END: any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
	
	rem copy this pak report to its folder
	xcopy /y /h /v "REPORT_!_bPAKname!.txt" "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*" 1>NUL 2>NUL

	Del /f /q /s "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
	
	SET /A _bGNumberFiles=_bGNumberFiles+!_bNumberFiles!
	SET /A _bGNumberFilesDecompiled=_bGNumberFilesDecompiled+!_bNumberFilesDecompiled!
	SET /A _bGNumberFilesNoVersionInfo=_bGNumberFilesNoVersionInfo+!_bNumberFilesNoVersionInfo!
	SET /A _bGNumberFilesMissing=_bGNumberFilesMissing+!_bNumberFilesMissing!
	
	EXIT /B

rem --------------------------------------------
