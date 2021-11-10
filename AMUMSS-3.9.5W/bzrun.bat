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
	REM set _zWHITEonYELLOW=[93;43m[1m
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
	echo.[ERROR] Please do NOT "Run as administrator", AMUMSS will not work^!
	pause
	goto :eof
)

set _bMyPath=
set _bSystem32=
set _bADMIN=
rem -------------  end testing for administrator  -------------------------------

rem goto Start-up (AMUMSS) folder
rem could remove the need for testing for administrator ???
cd /D "%~dp0"

set "_bMASTER_FOLDER_PATH=%~dp0"

rem -------------  testing for AMUMSS path  -------------------------------
set "_search=("
CALL set "_testPath=%%_bMASTER_FOLDER_PATH:%_search%=%%"
if /i NOT ["%_testPath%"]==["%_bMASTER_FOLDER_PATH%"] set _found=Y
if defined _found (
	echo. %_zRED%%_bB% Path to AMUMSS contains parenthesis ^(^), please remove them and retry%_zDEFAULT%
	pause
	exit
)
rem -------------  END: testing for AMUMSS path  -------------------------------

SET "_bDateTimeStart=  %DATE% %TIME% AMUMSS starting^!"
echo.!_bDateTimeStart!

rem *********************  NOW IN AMUMSS folder  *******************

if exist WOPT_SERIALIZING.txt (set _mSERIALIZING=Y)
if exist WOPT_DEBUG.txt (set _mDEBUG=y)
if exist WOPT_debugS.txt (set _mdebugS=y)
if exist WOPT_ISxxx.txt (set _mISxxx=Y)
if exist WOPT_PAUSE.txt (set _mPAUSE=y)
if exist WOPT_VERBOSE_BATCH.txt (set _mVERBOSE=y)
if exist WOPT_Wbertro.txt (set _mWbertro=y)

REM no required anymore
REM if exist WOPT_SIMPLE.txt (set _mSIMPLE=y)

SET /p _mMasterVersion=<"MODBUILDER\AMUMSSMasterVersion.txt"
SET /p _mCurrentVersion=<"MODBUILDER\AMUMSSVersion.txt"

if [!_mMasterVersion!]==[] set "_mMasterVersion=_mCurrentVersion"

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
	set _bCreateMapFileTree=1
)

if [%-MAPFILETREEFORCE%]==[Y] (
	set _bAllowMapFileTreeCreator=N	
)

REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "ProductName=%%~b"
REM for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion') do set "CurrentVersion=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"

if not [%_bWinNum%]==[8] (
	for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v UBR') do set "UBRHEX=%%~b"
) else (
	set "UBRHEX=0"
)

set /a _bCurrentBuildDec=%CurrentBuildHex%
set /a _bUBRDEC=%UBRHEX%
rem --------------  end Installed OS_1   -----------------------------

rem --------------   Installed OS_2: get Lua.exe  -----------------------------
rem since MBINCompiler can only be used on x64 now
if exist "!CD!\MODBUILDER\Extras\lua_x64\bin\lua.exe" set "_mLUA=Extras\lua_x64\bin\lua.exe"
if exist "!CD!\MODBUILDER\Extras\lua_x64\bin\lua - Copy.exe" set "_mLUA=Extras\lua_x64\bin\lua - Copy.exe"
set "_mLUAC=Extras\lua_x64\bin\luac.exe"

rem --------------  end Installed OS_2: get Lua.exe   -----------------------------
  
rem **********************  start Active code page check  *************************
rem Active code page: 850, 437 are ok
chcp >MODBUILDER\ActiveCodePage.txt

FOR /F "tokens=*" %%A IN ('CHCP') DO FOR %%B IN (%%~A) DO SET _CodePage=%%B

rem remove end dot for some version of German Windows XP and 7
if %_CodePage:~-1%==. (
	set _CodePage=%_CodePage:~0,-1%
)

REM if %_CodePage%==850 (
	REM REM echo.CodePage is OK!
REM ) else (
	REM if %_CodePage%==437 (
		REM REM echo.CodePage is OK!
	REM ) else (
		echo.
		echo.  %_zINVERSE%%_zRED%                                                                                   %_zDEFAULT%
		echo.  %_zINVERSE% ^>^>^> Note: Please make sure you do not have any accented characters in AMUMSS path %_zDEFAULT%
		echo.  %_zINVERSE%%_zRED%                                                                                   %_zDEFAULT%
	REM )
REM )
rem **********************  end Active code page check  *************************

rem change to 1250 can throw problems (tested with lMonk)
REM CHCP 1250 1>nul 2>nul

echo.
if defined _updateDone (
	echo.%_zRED%  AMUMSS UPDATED to v%_mCurrentVersion%%_zDEFAULT%
) else (
	echo.%_zGREEN%  AMUMSS v%_mCurrentVersion%%_zDEFAULT%
)
MODBUILDER\%_mLUA% -e print(_VERSION)>temp.txt
set /p _bVersionLua=<temp.txt
echo.%_zGREEN%  %_bVersionLua%%_zDEFAULT%
Del /f /q "temp.txt" 1>NUL 2>NUL

if %_bOS_bitness%==64 (
	echo.%_zGREEN%  %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
) else (
	echo.%_zGREEN%  %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs ^(cp%_CodePage%^)%_zDEFAULT%
)

REM echo.

rem DO NOT REMOVE
set "_bB="

if defined _mVERBOSE set "_bB=BuildMod.bat:"

if defined _mVERBOSE (
	echo.
	echo.^>^>^>     In BuildMod.bat
)

echo.
echo.^>^>^> %_bB% Starting in !CD!

rem remove old report.txt
Del /f /q "REPORT.txt" 1>NUL 2>NUL

rem we are using this now
Del /f /q "REPORT.lua" 1>NUL 2>NUL

rem **********************  start of NMS_FOLDER DISCOVERY section  *************************
rem try to find the NMS folder path
rem if the user gave a path, try to use it first
echo.
echo.^>^>^> %_bB% Checking Path to NMS_FOLDER...

rem *****************************************************
if not exist "NMS_FOLDER.txt" (
	rem we need to re-create it
	echo.
	echo.^>^>^>      Re-creating missing NMS_FOLDER.txt...
	copy /V /Y /B "MODBUILDER\NMS_FOLDER.txt" ".\NMS_FOLDER.txt" >nul
)
rem *****************************************************

set /p _bNMS_FOLDER=<NMS_FOLDER.txt 1>NUL 2>NUL
echo !_bNMS_FOLDER!>test.txt
REM echo. A- [!_bNMS_FOLDER!]

set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"
REM echo. 0- [%_bNMS_PCBANKS_FOLDER%]

REM set "_ExistSig=N"
REM echo.==^> %_ExistSig%
REM CALL :CheckBankSignatures _ExistSig "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"
REM echo.==^> %_ExistSig%
REM if [%_ExistSig%]==[Y] echo. FOUND

if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	echo. Current path does not work...
	for %%G in (1,2,3) do (
		if not defined _bFoundNMS (
			if %%G EQU 1 (
				rem NMS on Steam
				echo.   Trying NMS on Steam using registry
				set _bREGKEY="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 275850"
				set _bREGVAL="InstallLocation"
			)
			if %%G EQU 2 (
				rem NMS on GOG on 32bit, may not be required anymore
				echo.   Trying NMS on GOG on 32bit using registry
				set _bREGKEY="HKLM\SOFTWARE\GOG.com\Games\1446213994"
				set _bREGVAL="path"
			)
			if %%G EQU 3 (
				rem NMS on GOG on 64bit
				echo.   Trying NMS on GOG on 64bit using registry
				set _bREGKEY="HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1446213994"
				set _bREGVAL="path"
			)
			rem see https://www.robvanderwoude.com/type.php for more info
			rem CHCP 1252
			
			rem for DEBUG
			REM REG QUERY !_bREGKEY! /v !_bREGVAL!
			set _bvalue=
			FOR /F "usebackq skip=2 tokens=1,2*" %%A IN (`REG QUERY !_bREGKEY! /v !_bREGVAL!`) DO (
				set "_bvalue=%%C"
			)
			REM echo. E- !_bvalue!
			ECHO !_bvalue!>test.txt
			
			set /p _bNMS_FOLDER=<test.txt
			REM echo. B- [!_bNMS_FOLDER!]
			set "_bNMS_PCBANKS_FOLDER=!_bNMS_FOLDER!\GAMEDATA\PCBANKS\"
			REM echo. 1- [!_bNMS_PCBANKS_FOLDER!]
			if exist "!_bNMS_PCBANKS_FOLDER!BankSignatures.bin" (
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
	echo.^>^>^> %_bB% Still looking to locate path to NMS_FOLDER...
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
	echo.   Looking for Libraries in: [!_bvalue!]
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
set "_bNMS_PCBANKS_FOLDER=%_bNMS_FOLDER%\GAMEDATA\PCBANKS\"
 
REM set "_ExistSig=N"
REM echo.==^> %_ExistSig%
REM CALL :CheckBankSignatures _ExistSig "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"
REM echo.==^> %_ExistSig%
REM if [%_ExistSig%]==[Y] echo. FOUND

if not exist "%_bNMS_PCBANKS_FOLDER%BankSignatures.bin" (
	echo.********************* PLEASE correct your path in NMS_FOLDER.txt, NMS game files not found ********************
	echo. Bad Path to: ["%_bNMS_PCBANKS_FOLDER%BankSignatures.bin"]
	echo. Found this PATH in [NMS_FOLDER.txt] "%_bNMS_FOLDER%"
	echo.%_zRED% ^>^>^> Your PATH in [NMS_FOLDER.txt] should be pointing to the folder containing 'GAMEDATA' %_zDEFAULT%
	echo.***** Terminating batch until corrected...
	pause
	exit
) else (
	echo. %_zBLACKonYELLOW%%_bB% Path to NMS_FOLDER is ^>^>^> GOOD ^<^<^< game files found %_zDEFAULT%
)
cd /D "%~dp0"

echo.
echo.^>^>^> %_bB% Updating NMS_FOLDER.txt
copy /y /v "NMS_FOLDER.txt" "MODBUILDER\NMS_FOLDER.txt*" >NUL
echo.   "%_bNMS_FOLDER%"
rem **********************  end of NMS_FOLDER DISCOVERY section  *************************

rem ************************************  SOME FOLDER preparation  ***********************
if not exist "!CD!\ModScript" (
	mkdir "!CD!\ModScript\" 2>NUL
)

set "_DisableFolder=Disabled scripts and paks"
if not exist "!CD!\ModScript\%_DisableFolder%" (
	mkdir "!CD!\ModScript\%_DisableFolder%" 2>NUL
)

if not exist "!CD!\ModScriptCheck" (
	mkdir "!CD!\ModScriptCheck\" 2>NUL
)

if not exist "!CD!\SavedSections" (
	mkdir "!CD!\SavedSections\" 2>NUL
)

if not exist "!CD!\UNPACKED_DECOMPILED_PAKs" (
	mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\" 2>NUL
)

if exist "MODBUILDER\MBINCompiler.current.exe" (
	copy /V /Y /B "MODBUILDER\MBINCompiler.current.exe" "MODBUILDER\MBINCompiler.exe" >nul
	del /F /Q "MODBUILDER\MBINCompiler.current.exe" >nul
)

if exist "MODBUILDER\MBINCompiler.exe" (
	Del /f /q /s "MODBUILDER\MBINCompilerVersion.txt" 1>NUL 2>NUL
	.\MODBUILDER\MBINCompiler.exe version -q >>MODBUILDER\MBINCompilerVersion.txt
	set /p _bMBINCompilerVersion=<MODBUILDER\MBINCompilerVersion.txt
)

if not exist "!CD!\MapFileTrees" (
	mkdir "!CD!\MapFileTrees\" 2>NUL
)

if not exist "MODBUILDER\ResetMapFileTreeDone.txt" (
	rem to force the re-creation of all MapFileTree files
	rem when format changed
	Del /f /q /s "!CD!\MapFileTrees\*.*" 1>NUL 2>NUL
	ECHO >.\MODBUILDER\ResetMapFileTreeDone.txt
)

if not exist "!CD!\ModExtraFilesToInclude" (
	mkdir "!CD!\ModExtraFilesToInclude\" 2>NUL
)

if not exist "!CD!\Builds" (
	mkdir "!CD!\Builds\" 2>NUL
)

if not exist "!CD!\Builds\IncrementalBuilds" (
	mkdir "!CD!\Builds\IncrementalBuilds\" 2>NUL
)

rem ******************  Check for BUILDMOD_AUTO.bat  ***********************************
if not exist "BUILDMOD_AUTO.bat" (
	rem we need to re-create it
	echo.
	echo.^>^>^>      Re-created missing BUILDMOD_AUTO.bat...
	copy /V /Y /B "MODBUILDER\buildmod_auto.backup" ".\BUILDMOD_AUTO.bat" >nul
)
REM if not exist "BUILDMOD_AMUMSS.bat" (
	REM rem we need to re-create it
	REM echo.
	REM echo.^>^>^>      Re-created missing BUILDMOD_AMUMSS.bat...
	REM copy /V /Y /B "MODBUILDER\buildmod_auto.backup" ".\BUILDMOD_AMUMSS.bat" >nul
REM )
rem *****************************************************

rem **********************  Check for updates  *******************************************
if not exist "!CD!\MODBUILDER\UPDATE" (
	mkdir "!CD!\MODBUILDER\UPDATE\" 2>NUL
)

if not defined _mWbertro goto :StepOverTest
echo.
echo.                     xxxxx TEST xxxxx
cd /D "!CD!\ModScript"
for /D %%G in ("Disabled*") do (
	echo.                     found %%~nxG
)
cd /D "%~dp0"

echo.                     xxxxx END TEST xxxxx
:StepOverTest
rem *****************************************************

rem *********************  NOW IN ModScript  *******************
cd ModScript

rem removing old stuff
if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK
if exist EXMLFILES_CURRENT CALL :Cleaning_EXMLFILES_CURRENT
Del /f /q /s "REPORT_*.txt" 1>NUL 2>NUL

rem *********************  NOW IN AMUMSS folder  *******************
cd ..
rem ********************************  end SOME FOLDER preparation  ***********************

set "_INFO=^[INFO] "
set "_INFO="

rem ----------------------------------  Start REPORTing  -----------------------------------------------
echo|set /p=!_bDateTimeStart!>>"REPORT.lua" & echo.>>"REPORT.lua"
echo.>>"REPORT.lua"
if defined _updateDone (
	echo|set /p="%_INFO% AMUMSS UPDATED to v%_mCurrentVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"
) else (
	echo|set /p="%_INFO% AMUMSS v%_mCurrentVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"
)
echo|set /p="%_INFO% using %_bVersionLua%">>"REPORT.lua" & echo.>>"REPORT.lua"

if %_bOS_bitness%==64 (
	echo|set /p="%_INFO% on %_bWinVer% 64bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs (cp%_CodePage%)">>"REPORT.lua" & echo.>>"REPORT.lua"
) else (
	echo|set /p="%_INFO% on %_bWinVer% 32bit, Build: %_bCurrentBuildDec%.%_bUBRDEC% with %NUMBER_OF_PROCESSORS% logical CPUs (cp%_CodePage%)">>"REPORT.lua" & echo.>>"REPORT.lua"
)

if defined _bMBINCompilerVersion (
	echo|set /p="%_INFO% with MBINCompiler v%_bMBINCompilerVersion%">>"REPORT.lua" & echo.>>"REPORT.lua"
)
echo.>>"REPORT.lua"

REM ADDED message to check 'open files' in xxx preventing AMUMSS to work
echo.
echo.%_zRED% ============================================================================%_zDEFAULT%
echo. %_zINVERSE%[NOTE] EXCEPT when saying: 'Opening User Lua Script, Please wait...'        %_zDEFAULT%
echo. %_zINVERSE%       When AMUMSS seems to freeze and stop processing for ^> 60 seconds     %_zDEFAULT%
echo. %_zINVERSE%       probably means it cannot delete some files in a working directories. %_zDEFAULT%
echo. %_zINVERSE%    Please 'close' all AMUMSS files you have opened in other apps           %_zDEFAULT%
echo. %_zINVERSE%   (Files opened in Notepad++, for example, will not cause this problem)    %_zDEFAULT%
echo.%_zRED% ============================================================================%_zDEFAULT%
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
	echo. %_zBLACKonYELLOW% ^>^>^>   [INFO]  NO user .lua Mod Script found in ModScript... %_zDEFAULT%
	echo.              You may want to put some .lua Mod script in the ModScript folder and retry...
	
	echo|set /p="%_INFO% NO user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
	echo.>>"REPORT.lua"
	
	set _bNoScript=y
	REM echo.  Trying to clean _TEMP folder...
	CALL :Cleaning_TEMP
) else (
	SET _bBuildMODpak=y
	REM echo.  Trying to clean EXML_Helper folder...
	CALL :Cleaning_EXML_Helper
)
rem --------------  end Check # of scripts present ------------------------------

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER

if [%-MAPFILETREE%]==[TXT] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[TXTPLUS] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[LUA] goto :SelectMapFileTree
if [%-MAPFILETREE%]==[LUAPLUS] goto :SelectMapFileTree

echo.==^> BAD OPTION VALUE for '-MAPFILETREE' [%-MAPFILETREE%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause
REM set to DEFAULT
set -MAPFILETREE=LUA

:SelectMapFileTree
rem Used by CreateMapFileTree.lua to select type of output file
Del /f /q USE_TXT_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_LUA_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_TXTPLUS_MAPFILETREE.txt 1>NUL 2>NUL
Del /f /q USE_LUAPLUS_MAPFILETREE.txt 1>NUL 2>NUL

if [%-MAPFILETREE%]==[TXT] ECHO >USE_TXT_MAPFILETREE.txt
if [%-MAPFILETREE%]==[TXTPLUS] ECHO >USE_TXT_MAPFILETREE.txt
if [%-MAPFILETREE%]==[TXTPLUS] ECHO >USE_TXTPLUS_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUA] ECHO >USE_LUA_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUAPLUS] ECHO >USE_LUA_MAPFILETREE.txt
if [%-MAPFILETREE%]==[LUAPLUS] ECHO >USE_LUAPLUS_MAPFILETREE.txt

Del /f /q MapFileTreeRunner.lua 1>NUL 2>NUL
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

del /f /q MODS_MBIN_list.txt 1>NUL 2>NUL
echo|set /p="">MODS_MBIN_list.txt

Del /f /q "FailedScriptList.txt" 1>NUL 2>NUL

cd ..
rem ******   NOW IN AMUMSS folder   ********

rem ------------ Test for good option value --------------------------------
if [%-IncludeLuaScriptInPak%]==[ASK] goto :TestOptionValueDone
if [%-IncludeLuaScriptInPak%]==[] goto :TestOptionValueDone
if [%-IncludeLuaScriptInPak%]==[Y] goto :TestOptionValueDone
if [%-IncludeLuaScriptInPak%]==[N] goto :TestOptionValueDone

echo.
echo.==^> BAD OPTION VALUE for '-IncludeLuaScriptInPak' [%-IncludeLuaScriptInPak%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:TestOptionValueDone
rem ------------ END: Test for good option value --------------------------------

rem --------------  Check # of PAKs or MBINs present ------------------------------
SET _bNumberPAKs=0
SET _bNumberMBINs=0
set _uOldMBINCompilerFlag=N
SET _uOldMBIN=N

SET _bGNumberFiles=0
SET _bGNumberFilesDecompiled=0
SET _bGNumberFilesMissing=0
SET _bGNumberFilesNoVersionInfo=0
SET _bNumberFilesCouldNotDecompile=0
SET _bGNumScriptsInPak=0

REM for Check mod Conflicts
SET _bGConflictLines=0

rem Check if some mod PAK also exist in ModScript
REM       with /r we look into sub-folders also
REM FOR /r "%~dp0\ModScript" %%G in (*.pak.*) do ( 
FOR %%G in ("%~dp0\ModScript\*.pak.*") do ( 
	SET /A _bNumberPAKs=_bNumberPAKs+1
	REM SET _bPAKname=%%~nG
)

rem Check if some MBIN also exist in ModScript
rem /r recurse sub-folders
FOR /r "%~dp0\ModScript" %%G in (*.MBIN) do ( 
   (Echo "%%G" | FIND /I "Disabled scripts and paks" 1>NUL) || (
		echo. ======^> "%%G"
		SET /A _bNumberMBINs=_bNumberMBINs+1
   )
)

if %_bNumberPAKs% GTR 0 (
	SET _bPAK_MBIN=Y
) else (
	if %_bNumberMBINs% GTR 0 (
		SET _bPAK_MBIN=Y
	)
)
rem here if _bPAK_MBIN is defined, at least one PAK or MBIN is present in ModScript

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER
rem *************  Check MBINCompiler  *********************

REM echo.  Checking MBINCompiler...
CALL :MBINCompilerUPDATE

rem ******   NOW IN AMUMSS folder   ********
cd ..

if DEFINED _bPAK_MBIN (
	if %_bNumberScripts% GTR 0 (
		CALL :CHECK_ExtraFilesToInclude
	)

	rem *********************  NOW IN MODBUILDER  *******************
	cd MODBUILDER

	CALL :CONFLICTDETECTION
	
	if !_bCheckMODSconflicts! NEQ 2 (
		if !_bCheckMODSconflicts! EQU 1 (
			REM get list paks in NMS MODS folder
			CALL PSARC_LIST_PAKS_MODS.BAT
		)
		if !_bCheckMODSconflicts! EQU 3 (
			REM get list paks in NMS MODS folder
			CALL PSARC_LIST_PAKS_MODS.BAT
		)
	)

	CALL :PAK_LISTsCREATION
	
	rem ******   NOW IN AMUMSS folder   ********
	cd ..

	echo.
	echo.-----------------------------------------------------------
	if %_bNumberPAKs% GTR 1 (
		echo. %_zBLACKonYELLOW% ^>^>^> Detected %_bNumberPAKs% user PAKs in ModScript... %_zDEFAULT%
		echo.

		echo|set /p="%_INFO% Detected %_bNumberPAKs% user PAKs in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
	) else (
		if %_bNumberPAKs% GTR 0 (
			echo. %_zBLACKonYELLOW% ^>^>^> Detected 1 user PAK in ModScript... %_zDEFAULT%
			echo.

			echo|set /p="%_INFO% Detected 1 user PAK in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
		)
	)
	if %_bNumberMBINs% GTR 1 (
		echo. %_zBLACKonYELLOW% ^>^>^> Detected %_bNumberPAKs% user MBINs in ModScript... %_zDEFAULT%
		echo.

		echo|set /p="%_INFO% Detected %_bNumberPAKs% user MBINs in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
	) else (
		if %_bNumberMBINs% GTR 0 (
			echo. %_zBLACKonYELLOW% ^>^>^> Detected 1 user MBIN in ModScript... %_zDEFAULT%
			echo.

			echo|set /p="%_INFO% Detected 1 user MBIN in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
		)
	)
	
	rem *********************  NOW IN MODBUILDER  *******************
	cd MODBUILDER

	rem ****************  Get list of paks in ModScript  ****************
	if %_bNumberPAKs% GTR 0 (
		CALL PSARC_LIST_ModScriptPAKS.BAT
		echo.
		echo.>>"REPORT.lua"
	)
	
	if %_bNumberMBINs% GTR 0 (
		CALL LIST_ModScriptMBINs.BAT
		echo.
		echo.>>"REPORT.lua"
	)
	
	if !_bCheckMODSconflicts! EQU 3 (
		set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
		if not defined _bStartTime (
			Call :LuaEndedOkREMOVE
			SET _bStartTime=Y
			%_mLUA% StartTime.lua "..\\" ""
			Call :LuaEndedOk
		)

		goto :START_CONFLICT_DETECTION
	) else (
		set "_fileToCheck=MODS_pak_list.txt"
		CALL :HOW_MANY_LINES
	)
	
	echo.
	
	rem ******   NOW IN AMUMSS folder   ********
	cd ..
		
	if %_bNumberScripts% EQU 0 (
		echo. %_zBLACKonYELLOW%                                                                             %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] Placing one or more paks/mbins in Modscript, without a .lua script,  %_zDEFAULT%
		echo. %_zBLACKonYELLOW%              will unpack and decompile them...                              %_zDEFAULT%
		echo. %_zBLACKonYELLOW%     When possible, the current MBINCompiler will be used                    %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                             %_zDEFAULT%
		echo. 
		if %_bNumberPAKs% GTR 1 (
			echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile them now...
		) else (
			if %_bNumberPAKs% GTR 0 (
				echo.^>^>^>   [INFO] AMUMSS is going to unpack and decompile it now...
			)
		)
		if %_bNumberMBINs% GTR 1 (
			echo.^>^>^>   [INFO] AMUMSS is going to decompile them now...
		) else (
			if %_bNumberMBINs% GTR 0 (
				echo.^>^>^>   [INFO] AMUMSS is going to decompile it now...
			)
		)
		echo.

		echo|set /p="[NOTE] Placing one or more paks/mbins in Modscript, without a .lua script will unpack and decompile them">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE] When possible, the current MBINCompiler will be used...">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	) else (
		echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] One or more paks with at least one .lua script to apply over them             %_zDEFAULT%
		echo. %_zBLACKonYELLOW%             will create a PATCH pak ^(the COMBINED pak^)                               %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        And if the same mbin file is present in any of the .pak and edited by the     %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        .lua script, only the one in the last pak will contribute to the COMBINED pak %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        As always, the natural NMS load order will dictate its effects...             %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        FOR THIS TO WORK, the pak^(s^) MUST be fully updated to the current NMS files   %_zDEFAULT%
		echo. %_zBLACKonYELLOW%        since the MBIN files in the pak are used to create the patch                  %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                      %_zDEFAULT%
		echo. 
		echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
		echo. %_zBLACKonYELLOW% [NOTE] Remember that a PATCH must be used WITH the original .pak ^(in most cases^)  %_zDEFAULT%
		echo. %_zBLACKonYELLOW%             to get the full effect of the original + your script                  %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                   %_zDEFAULT%
		echo.

		echo.>>"REPORT.lua"
		echo|set /p="[NOTE] One or more paks with at least one .lua script to apply over them">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE]   will create a PATCH pak (the COMBINED pak) ">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE] When the same mbin file is present in any of the .pak and edited by the">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE]   .lua script, only the one in the last pak will contribute to the COMBINED pak">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE] As always, the natural NMS load order will dictate its effects...">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo|set /p="[NOTE] FOR THIS TO WORK, the pak(s) MUST be fully updated to the current NMS files">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE]   since the MBIN files in the pak are used to create the patch">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo|set /p="[NOTE] Remember that a PATCH must be used with the original .pak (in most cases)">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE]   to get the full effect of the original + your script">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	)
		
	if %_bNumberScripts% GTR 0 (
		echo.^>^>^>      A GENERIC COMBINED MOD pak may be created...
		echo.^>^>^>      If you choose to COPY to your game folder, the PAKs will ALSO be copied there...
		SET _bCOMBINE_MODS=1
		SET _bCOPYtoNMS=NONE
		SET _bPATCH=1

		REM       with /r we look into sub-folders also
		REM FOR /r "%~dp0\ModScript" %%G in (*.pak.*) do ( 
		FOR %%G in ("%~dp0\ModScript\*.pak.*") do ( 
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
	if DEFINED _bPAK_MBIN (
		rem one or more paks or mbins, no script. Extracting ALL files
		
		REM rem ------  START of automatic processing: start the clock  -----------------------

		REM if %_bNumberPAKs% GTR 1 (
			if not defined _bStartTime (
				Call :LuaEndedOkREMOVE
				SET _bStartTime=Y
				MODBUILDER\%_mLUA% "MODBUILDER\StartTime.lua" ".\\" ".\\MODBUILDER\\"
				Call :LuaEndedOk
			)
		REM )
		
		if not exist "!CD!\UNPACKED_DECOMPILED_PAKs" (
			mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\" 2>NUL
		)
		
		REM       with /r we look into sub-folders also
		REM FOR /r "%~dp0\ModScript" %%G in (*.pak.*) do ( 
		FOR %%G in ("%~dp0\ModScript\*.pak.*") do ( 
			echo.
			SET _bPAKname=%%~nG
			echo. %_zBLACKonYELLOW% **** Unpacking/decompiling !_bPAKname! **** %_zDEFAULT%
			echo|set /p="%_INFO% **** Unpacking/decompiling !_bPAKname! ****">>"REPORT.lua" & echo.>>"REPORT.lua"
			if not exist "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" (
				mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" 2>NUL
			)
			
			rem copy PAK to its folder
			xcopy /y /h /v "%%G" "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*" 1>NUL 2>NUL

			if not exist "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK" (
				mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK" 2>NUL
			)

			if not exist "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" (
				mkdir "!CD!\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" 2>NUL
			)

			cd ModScript
			rem ******   NOW IN ModScript   ********
			if exist EXTRACTED_PAK CALL :Cleaning_EXTRACTED_PAK
			if exist EXMLFILES_PAK CALL :Cleaning_EXMLFILES_PAK

			set _bPaknamePATH=%%G
			CALL ..\MODBUILDER\ExtractMODfromPAK.bat
			rem the PAKs are now unpacked to UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXTRACTED_PAK
			rem and the last PAK is also unpacked to ModScript\EXTRACTED_PAK

			REM CALL :GET_CURRENT_EXML_for_COMPARISON
			
			set _bDoingPAk=Y
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
						REM echo.

						if [%-UseLuaScriptInPak%]==[ASK] SET _bUseLuaInPak=
						if [%-UseLuaScriptInPak%]==[] SET _bUseLuaInPak=
						if [%-UseLuaScriptInPak%]==[Y] SET _bUseLuaInPak=Y
						if [%-UseLuaScriptInPak%]==[N] SET _bUseLuaInPak=N

						if not defined _UseLuaInPak (
							CHOICE /c:YN /m ".      %_zBLACKonYELLOW% ??? Do you want to rebuild the MOD pak(s) using this script %_zDEFAULT%"
							if !ERRORLEVEL! EQU 2 SET _bUseLuaInPak=N & echo.
							if !ERRORLEVEL! EQU 1 SET _bUseLuaInPak=Y
						)
						
						if !_bUseLuaInPak!==Y (
							echo.   Copying script to ModScript...
							set _bNoScript=
							SET _bBuildMODpak=y
							SET _bBuildMODpakFromPakScript=y
							
							REM we use the scripts as normal scripts
							xcopy /s /y /h /v "ModScript\EXTRACTED_PAK\*.lua" "Modscript\*"	1>NUL 2>NUL
						)
					)
				)
			)
		)

		if %_bNumberMBINs% GTR 0 (
			cd ModScript
			rem ******   NOW IN ModScript   ********
			if not exist EXTRACTED_PAK (
				mkdir EXTRACTED_PAK 2>NUL
			) else (
				CALL :Cleaning_EXTRACTED_PAK
				mkdir EXTRACTED_PAK 2>NUL
			)

			if not exist EXMLFILES_PAK (
				mkdir EXMLFILES_PAK 2>NUL
			) else (
				CALL :Cleaning_EXMLFILES_PAK
				mkdir EXMLFILES_PAK 2>NUL
			)

			copy /y /v "*.MBIN" "EXTRACTED_PAK\" >NUL
			
			set _bDoingPAk=
			call :UNPACKEDtoEXML
			set _bUNPACKED_DECOMPILED=y
			
			cd ..
			rem ******   NOW IN AMUMSS folder   ********
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
	set _bNoScript=y
) else (
	SET _bBuildMODpak=y
	CALL :CHECK_ExtraFilesToInclude
)

CALL :Cleaning_EXML_Helper

if %_uOldMBINCompilerFlag%==Y (
	echo.    %_zBLACKonYELLOW% [NOTICE] Older MBINCompiler used %_zDEFAULT%
	REM echo.

	echo.>>"REPORT.lua"
	echo|set /p=".   [NOTICE] Older MBINCompiler used">>"REPORT.lua" & echo.>>"REPORT.lua"

	REM script, if any, may need updating.  Not processing
	goto :ENDING
)

if %_bNumberScripts% EQU 0 set _bNoScript=y

rem -------- user options start here -----------
rem on 0, treat as INDIVIDUAL mods
rem on 1, treat as a generic combined mod with a NUMERIC suffix
rem on 2, treat as a DISTINCT combined mod with the current DATE-TIME
rem on 3, treat as an INDIVIDUAL mod, the name being like Mod1+Mod2+Mod3.pak, a COMPOSITE mod

rem default = INDIVIDUAL
SET _bCOMBINE_MODS=0

rem default = PLAIN
SET _bINDIVIDUAL_MODS=1

rem default = NONE copied to MODS
SET _bCOPYtoNMS=NONE
CALL :DOPAUSE	

if defined _bNoScript goto :EXECUTE

REM if defined _mSIMPLE goto :SIMPLE_MODE 
if %_bNumberScripts% EQU 1 goto :INDIVIDUAL_SELECTED

if [%-CombineModPak%]==[ASK] goto :AskCombineModPak
if [%-CombineModPak%]==[] goto :AskCombineModPak
if [%-CombineModPak%]==[Y] goto :WhatTypeOfCombinedMod
if [%-CombineModPak%]==[N] goto :INDIVIDUAL_SELECTED

echo.==^> BAD OPTION VALUE for '-CombineModPak' [%-CombineModPak%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:AskCombineModPak
echo.
echo.^>^>^> INDIVIDUAL PAKs may or may not work together depending on the EXML files they change
echo.    If they modify the same original EXML files, the last one loaded will win and the other changes will be lost...
echo.
echo.    You may use INDIVIDUAL PAKs when they don't interfere with each other
echo.
echo.^>^>^> COMBINED PAKs will try to keep, as much as possible, all changes made to a particular EXML file by re-using it during PAK creation
echo.    Only changes made to the same exact values of an EXML will reflect only the last mod
echo.

if [%-CombineModPak%]==[N] goto :INDIVIDUAL_SELECTED
if [%-CombineModPak%]==[Y] goto :WhatTypeOfCombinedMod

CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to create a COMBINED mod[Y] or INDIVIDUAL mod(s)[N] %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 goto :INDIVIDUAL_SELECTED

rem =============== COMBINED ==============
:WhatTypeOfCombinedMod
if [%-CombinedModType%]==[ASK] goto :AskCombinedModType
if [%-CombinedModType%]==[] goto :AskCombinedModType
if [%-CombinedModType%]==[1] (
	SET _bCOMBINE_MODS=1	
	goto :SIMPLE_MODE
)
if [%-CombinedModType%]==[2] (
	SET _bCOMBINE_MODS=2	
	goto :SIMPLE_MODE
)
if [%-CombinedModType%]==[3] (
	SET _bCOMBINE_MODS=3
	goto :SIMPLE_MODE
)

echo.==^> BAD OPTION VALUE for '-CombinedModType' [%-CombinedModType%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:AskCombinedModType
echo.
echo.^>^>^> A COMPOSITE combined MOD name has a length limit of less than %_bMaxPakNameLength% characters (excess will be truncated)
set /p _bCompositeName=<"MODBUILDER\Composite_MOD_FILENAME.txt"
echo.    It would be...
echo.      "%_bCompositeName%"
echo.               ...in this case
CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to use a COMPOSITE combined MOD named just like that %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 goto :COMBINEDTYPE
if %ERRORLEVEL% EQU 1 SET _bCOMBINE_MODS=3
goto :SIMPLE_MODE

:COMBINEDTYPE
echo.
echo.^>^>^> A COMBINED MOD name can be like CombinedMod_(x).pak (where x is 0 to 9)
echo.                         ...or like CombinedMod_DATE-TIME.pak...
echo.
CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to use a NUMERIC suffix[Y] or the current DATE-TIME[N] to differentiate your mod name %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET _bCOMBINE_MODS=1
if %ERRORLEVEL% EQU 1 SET _bCOMBINE_MODS=2
goto :SIMPLE_MODE

rem here _bCOMBINE_MODS is set
rem =============== END: COMBINED ==============

rem =============== INDIVIDUAL ==============
:INDIVIDUAL_SELECTED
if [%-IndividualModPakType%]==[ASK] goto :ASKIndividualModPakType
if [%-IndividualModPakType%]==[] goto :ASKIndividualModPakType
if [%-IndividualModPakType%]==[PLAIN] (
	SET _bINDIVIDUAL_MODS=2
	goto :SIMPLE_MODE
)
if [%-IndividualModPakType%]==[P] (
	SET _bINDIVIDUAL_MODS=2
	goto :SIMPLE_MODE
)
if [%-IndividualModPakType%]==[DATETIME] (
	SET _bINDIVIDUAL_MODS=1
	goto :SIMPLE_MODE
)
if [%-IndividualModPakType%]==[D] (
	SET _bINDIVIDUAL_MODS=1
	goto :SIMPLE_MODE
)

echo.==^> BAD OPTION VALUE for '-IndividualModPakType' [%-IndividualModPakType%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:ASKIndividualModPakType
rem _bINDIVIDUAL_MODS=1 the name of the script
rem _bINDIVIDUAL_MODS=2 the name of the script + date-time
echo.
echo.^>^>^> Making individual MODs named like MyMod.pak
echo.                           ...or like MyMod_DATE-TIME.pak...
echo.
CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to add the current DATE-TIME[Y] to your mod name %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET _bINDIVIDUAL_MODS=2
if %ERRORLEVEL% EQU 1 SET _bINDIVIDUAL_MODS=1
rem =============== END: INDIVIDUAL ==============

:SIMPLE_MODE

if %_bNumberScripts% EQU 1 goto :SIMPLE_MODE_ONE_SCRIPT


if [%-CopyToGamefolder%]==[ASK] goto :COPYSOMEALL
if [%-CopyToGamefolder%]==[] goto :COPYSOMEALL
if [%-CopyToGamefolder%]==[NONE] goto :CopyToGamefolder
if [%-CopyToGamefolder%]==[N] goto :CopyToGamefolder
if [%-CopyToGamefolder%]==[SOME] goto :CopyToGamefolder
if [%-CopyToGamefolder%]==[ALL] goto :CopyToGamefolder
if [%-CopyToGamefolder%]==[Y] goto :CopyToGamefolder

echo.==^> BAD OPTION VALUE for '-CopyToGamefolder' [%-CopyToGamefolder%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause
goto :COPYSOMEALL

:CopyToGamefolder
SET _bCOPYtoNMS=%-CopyToGamefolder%
goto :EXECUTE

:COPYSOMEALL
echo.
CHOICE /c:NSA /m " %_zBLACKonYELLOW% ??? Would you like or [N]ot to COPY [S]ome or [A]ll Created Mod PAKs to your game folder and DELETE [DISABLEMODS.TXT] %_zDEFAULT%"
if %ERRORLEVEL% EQU 3 SET _bCOPYtoNMS=ALL
if %ERRORLEVEL% EQU 2 SET _bCOPYtoNMS=SOME
if %ERRORLEVEL% EQU 1 SET _bCOPYtoNMS=NONE

goto :EXECUTE

:SIMPLE_MODE_ONE_SCRIPT
if [%-CopyToGamefolder%]==[ASK] goto :ASK_COPYTOMODS
if [%-CopyToGamefolder%]==[] goto :ASK_COPYTOMODS

SET _bCOPYtoNMS=NONE
if [%-CopyToGamefolder%]==[NONE] goto :EXECUTE
if [%-CopyToGamefolder%]==[N] goto :EXECUTE

SET _bCOPYtoNMS=ALL
if [%-CopyToGamefolder%]==[SOME] goto :EXECUTE
if [%-CopyToGamefolder%]==[ALL] goto :EXECUTE
if [%-CopyToGamefolder%]==[Y] goto :EXECUTE

echo.==^> BAD OPTION VALUE for '-CopyToGamefolder' [%-CopyToGamefolder%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:ASK_COPYTOMODS
if %_bNumberScripts% EQU 0 goto :EXECUTE

echo.
CHOICE /c:YN /m " %_zBLACKonYELLOW% ??? Would you like to COPY the created Mod PAKs to your game folder and DELETE [DISABLEMODS.TXT] %_zDEFAULT%"
if %ERRORLEVEL% EQU 2 SET _bCOPYtoNMS=NONE
if %ERRORLEVEL% EQU 1 SET _bCOPYtoNMS=ALL
rem -------- user options end here -----------

:EXECUTE
rem EXECUTE --------------------------------------------
if not exist "!CD!\CreatedModPAKs" (
	mkdir "!CD!\CreatedModPAKs\" 2>NUL
)
Del /f /q /s ".\CreatedModPAKs\*.*" 1>NUL 2>NUL

Del /f /q "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOk.txt" 1>NUL 2>NUL

Del /f /q "TempScript.lua" 1>NUL 2>NUL
Del /f /q "TempTable.lua" 1>NUL 2>NUL

rem *********************  NOW IN MODBUILDER  *******************
cd MODBUILDER
pushd "!CD!"

echo|set /p="%~dp0">MASTER_FOLDER_PATH.txt

rem always Cleaning _TEMP at the start of a new run
CALL :Cleaning_TEMP

if defined _mVERBOSE (
	echo.
	echo.^>^>^> %_bB% Changed to !CD!
)

del /f /q OnlyOneScript.txt 1>NUL 2>NUL

if %_bNumberScripts% EQU 1 (
	echo|set /p="">OnlyOneScript.txt
)

if not DEFINED _bPAK_MBIN (
REM if %_bNumberPAKs% EQU 0 (
	CALL :CONFLICTDETECTION
	
	if !_bCheckMODSconflicts! EQU 1 (
		REM get list paks in NMS MODS folder
		CALL PSARC_LIST_PAKS_MODS.BAT
	)
	if !_bCheckMODSconflicts! EQU 3 (
		REM get list paks in NMS MODS folder
		CALL PSARC_LIST_PAKS_MODS.BAT
	)

	if !_bCheckMODSconflicts! EQU 3 (
		set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
		if not defined _bStartTime (
			Call :LuaEndedOkREMOVE
			SET _bStartTime=Y
			%_mLUA% StartTime.lua "..\\" ""
			Call :LuaEndedOk
		)

		goto :START_CONFLICT_DETECTION
	) else (
		set "_fileToCheck=MODS_pak_list.txt"
		CALL :HOW_MANY_LINES
	)
	
	CALL :PAK_LISTsCREATION
)

REM rem **************************  MapFileTrees creation choice section  ********************************
if [%-ReCreateMapFileTree%]==[ASK] goto :AskReCreateMapFileTree
if [%-ReCreateMapFileTree%]==[] goto :AskReCreateMapFileTree
if [%-ReCreateMapFileTree%]==[Y] goto :START
if [%-ReCreateMapFileTree%]==[N] goto :START

echo.==^> BAD OPTION VALUE for '-ReCreateMapFileTree' [%-ReCreateMapFileTree%], please correct!
echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
pause

:AskReCreateMapFileTree
echo.
if defined _bNMSUpdated (
	echo.^>^>^> There was a NMS update, it is recommended to recreate the MapFileTrees files
	echo.
	echo.^>^>^> Some of your MapFileTrees files may be outdated
	echo.^>^>^>    You can recreate them using the script MapFileTree_UPDATER.lua
	echo.^>^>^>    To update a specific file, add it to the script
	echo.^>^>^> All other MapFileTrees will be updated as you process other scripts
)

echo.
CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to FORCE (RE)CREATE the MapFileTrees files DURING script processing %_zDEFAULT%"
if %ERRORLEVEL% EQU 1 (set -ReCreateMapFileTree=Y)
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
		echo|set /p="%_INFO%   A GENERIC COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		if defined _bExtraFilesInPAK (
			echo.^>^>^>      Extra Files in ModExtraFilesToInclude will be included
			echo|set /p="%_INFO%   Extra Files in ModExtraFilesToInclude will be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		) else (
			if !_bExtraFiles! GTR 0 (
				echo.^>^>^>      Extra Files in ModExtraFilesToInclude will NOT be included
				echo|set /p="%_INFO%   Extra Files in ModExtraFilesToInclude will NOT be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			)
		)
		if %_bCOPYtoNMS%==NONE (
			echo.^>^>^>      It will NOT be copied to NMS MOD folder
			echo|set /p="%_INFO%   It will NOT be copied to NMS MOD folder">>"..\REPORT.lua"
		)
		if %_bCOPYtoNMS%==ALL (
			if %_bNumberPAKs% GTR 1 (
				echo.^>^>^>      and will be copied with the user PAKs to NMS MOD folder
				echo|set /p="%_INFO%   and will be copied with the user PAKs to NMS MOD folder">>"..\REPORT.lua"
			) else (
				echo.^>^>^>      and will be copied with the user PAK to NMS MOD folder
				echo|set /p="%_INFO%   and will be copied with the user PAK to NMS MOD folder">>"..\REPORT.lua"
			)
		)
	)
	echo.>>"..\REPORT.lua"
	echo.>>"..\REPORT.lua"
) else (
	if defined _bNoScript goto :SIMPLE_MODE2
	echo.
	echo.---------------------------------------------------------
	if %_bCOMBINE_MODS% EQU 0 (
		echo.^>^>^> So, we are making INDIVIDUAL MOD PAKs...
		echo|set /p="%_INFO%   INDIVIDUAL MOD PAKs will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
	if %_bCOMBINE_MODS% EQU 1 (
		echo.^>^>^> So, we are making a GENERIC COMBINED MOD PAK...	
		echo|set /p="%_INFO%   A GENERIC COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
	if %_bCOMBINE_MODS% EQU 2 (
		echo.^>^>^> So, we are making one or more DISTINCT COMBINED MOD PAK...	
		echo|set /p="%_INFO%   One or more DISTINCT COMBINED MOD PAK will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
	if %_bCOMBINE_MODS% EQU 3 (
		echo.^>^>^> So, we are making a COMPOSITE-NAME COMBINED MOD PAK...	
		echo|set /p="%_INFO%   A COMPOSITE-NAME COMBINED MOD will be created...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
	if defined _bExtraFilesInPAK (
		echo.^>^>^>      Extra Files in ModExtraFilesToInclude will be included
		echo|set /p="%_INFO%   Extra Files in ModExtraFilesToInclude will be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	) else (
		if !_bExtraFiles! GTR 0 (
			echo.^>^>^>      Extra Files in ModExtraFilesToInclude will NOT be included
			echo|set /p="%_INFO%   Extra Files in ModExtraFilesToInclude will NOT be included">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		)
	)
	if %_bCOPYtoNMS%==NONE (
		echo.^>^>^>      and NONE will be copied to NMS MOD folder
		echo|set /p="%_INFO%   and NONE will be copied to NMS MOD folder">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
	if %_bCOPYtoNMS%==ALL (
		echo.^>^>^>      and ALL will be copied to NMS MOD folder
		echo|set /p="%_INFO%   and ALL will be copied to NMS MOD folder">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	)
)
echo.---------------------------------------------------------

REM if defined _mSIMPLE goto :SIMPLE_MODE2 
REM if defined _min_subprocess goto :SIMPLE_MODE2 

REM if not defined _mSKIP_USER_PAUSE (
	REM REM echo.Waiting 3 sec...
	REM timeout /T 3 /NOBREAK
REM )

rem *********************  STILL IN MODBUILDER  *******************
:SIMPLE_MODE2 
if not defined _bBuildMODpak goto :ENDING

Del /f /q "..\SerializedScript.lua" 1>NUL 2>NUL

echo.
echo.^>^>^> %_bB% Number of scripts to build: %_bNumberScripts%

rem Let MapFileTreeCreator know it can run if requested
echo|set /p="">MapFileTreeCreatorRun.txt

rem ###################################################################
rem --------  processing only if scripts are present -------------
rem ###################################################################
	rem reset counter of processed scripts
	echo|set /p="">ScriptCounter.txt

	Call :LuaEndedOkREMOVE
	%_mLUA% LoadAndExecuteModScript.lua
	Call :LuaEndedOk
	
	rem get # of processed script
	SET /p _bScriptCounter=<ScriptCounter.txt
	
	IF EXIST "LoadScriptAndFilenamesERROR.txt" (
		set _bErrorLoadingScript=y
	)
		
	REM CALL :DOPAUSE
	IF DEFINED _bErrorLoadingScript (
		echo|set /p="    [ENDED THIS SCRIPT PROCESSING] ========================================================================================">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		echo.
	)
	set _bErrorLoadingScript=
	del /f /q LoadScriptAndFilenamesERROR.txt 1>NUL 2>NUL

rem ##########################################################################
rem --------  END: processing only if scripts are present -------------
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
	echo.^>^>^> %_bB% Updating EXML_Helper\MODDED...

	echo.>>"REPORT.lua"
	echo|set /p="%_INFO% Updated EXML_Helper\MODDED">>"REPORT.lua" & echo.>>"REPORT.lua"

	if %_bNumberScripts% GTR 1 (
		echo.^>^>^> %_bB%     Note that the MODDED files ARE based on the last processed script if individual mods were created
		echo|set /p="%_INFO%     --Note that the MODDED files ARE based on the last processed script if individual mods were created">>"REPORT.lua" & echo.>>"REPORT.lua"
	)
	
	REM allow all file types, except the .lua script
	echo|set /p=".lua">>"exclude.txt"
	xcopy /f /s /y /h /e /v /i /j /c "MODBUILDER\MOD\*.*" "EXML_Helper\MODDED\" /EXCLUDE:MODBUILDER\xcopy_exclude.txt 1>NUL 2>NUL
	del exclude.txt
	
	echo.^>^>^> %_bB% Updating EXML_Helper\ORG_EXML and/or EXTRACTED...
	echo|set /p="%_INFO% Updated EXML_Helper\ORG_EXML">>"REPORT.lua" & echo.>>"REPORT.lua"

	REM allow all file types
	xcopy /s /y /h /e /v /i /j /c "MODBUILDER\_TEMP\DECOMPILED\*.*" "EXML_Helper\ORG_EXML\" 1>NUL 2>NUL

	REM exclude the .EXML files
	echo|set /p=".EXML">>"exclude.txt"
	xcopy /s /y /h /e /v /i /j /c "MODBUILDER\_TEMP\EXTRACTED\*.*" "EXML_Helper\EXTRACTED\" 1>NUL 2>NUL
	del exclude.txt
)

echo.
echo.%_zDARKGRAY%-----------------------------------------------------%_zDEFAULT%
echo.   %_zBLACKonYELLOW% ^>^>^>        AMUMSS v%_mCurrentVersion% finished        ^<^<^< %_zDEFAULT%
echo.%_zDARKGRAY%-----------------------------------------------------%_zDEFAULT%
echo.

if defined _bNoScript (
	if %_bNumberPAKs% EQU 0 (
		echo. %_zBLACKonYELLOW% ^>^>^>   [NOTICE] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
		echo.              You may want to put some .lua Mod script in the ModScript folder and retry...

		echo|set /p=".   [NOTICE] No user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="%_INFO% You may want to put some .lua Mod script in the ModScript folder and retry...">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	) else (
		if %_bNumberScripts% EQU 0 (
			echo. %_zBLACKonYELLOW% ^>^>^>   [NOTICE] NO user .lua Mod Script found in ModScript... %_zDEFAULT%
			
			echo|set /p=".   [NOTICE] NO user .lua Mod Script found in ModScript...">>"REPORT.lua" & echo.>>"REPORT.lua"
			echo.>>"REPORT.lua"
		)
	)
) else (
	if not defined _bErrorLoadingScript (
		echo.>>"REPORT.lua"
		echo.^>^>^> Created PAKs are in local folder ^>^>^> CreatedModPAKs ^<^<^<
		echo.^>^>^> Backups in ^>^>^> Builds ^<^<^< and ^>^>^> Builds\IncrementalBuilds ^<^<^<

		echo|set /p="%_INFO% Created PAKs are in local folder >>> CreatedModPAKs <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="%_INFO% Backups in >>> Builds <<< and >>> Builds\IncrementalBuilds <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo|set /p="%_INFO% END OF PROCESSING">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="%_INFO% Total scripts processed: %_bScriptCounter%">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	)
)

.\MODBUILDER\%_mLUA% ".\MODBUILDER\ReportFailedScript.lua" ".\\" ".\\MODBUILDER\\"

Call :LuaEndedOkREMOVE

if !_bCheckMODSconflicts! EQU 1 set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
if !_bCheckMODSconflicts! EQU 3 set "_fileToCheck=MODBUILDER\MODS_pak_list.txt"
if !_bCheckMODSconflicts! EQU 4 set "_fileToCheck=MODBUILDER\MBIN_PAKS.txt"

:START_CONFLICT_DETECTION
rem ******   NOW IN AMUMSS folder   ********
cd "%~dp0"

if !_bCheckMODSconflicts! NEQ 2 (
	CALL :HOW_MANY_LINES
	
	if !_bGConflictLines! GTR 0 (
		echo.
		echo.^>^>^> Conflict Detection starting...
		if !_bCheckMODSconflicts! EQU 3 (
			echo|set /p="%_INFO% Only checking conflicts in MODS, at user request (no script processed)">>"REPORT.lua" & echo.>>"REPORT.lua"
		)
		
		if !_bCheckMODSconflicts! EQU 4 (
			echo|set /p="%_INFO% Only checking conflicts in ModScript, at user request">>"REPORT.lua" & echo.>>"REPORT.lua"
		)
		
		.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckCONFLICTLOG.lua" ".\\" ".\\MODBUILDER\\" "" %_bCheckMODSconflicts%
		Call :LuaEndedOk
	) else (
		echo.
		echo.  %_zGREEN%No conflicting files to process%_zDEFAULT%
		echo.
	)
) else (
	echo.
	echo.%_zGREEN%^>^>^> Skipped Conflict Detection at user request%_zDEFAULT%
	echo.
	echo|set /p="%_INFO% Skipped Conflict Detection at user request">>"REPORT.lua" & echo.>>"REPORT.lua"
)

echo.              %_zBLACKonYELLOW% ^>^>^> FINAL REPORT ^<^<^< %_zDEFAULT%
echo.            %_zBLACKonYELLOW% ^>^>^> See "REPORT.lua" ^<^<^< %_zDEFAULT%

echo.>>"REPORT.lua"
echo|set /p="%_INFO%                 >>> FINAL REPORT  <<<">>"REPORT.lua" & echo.>>"REPORT.lua"

if defined _bErrorLoadingScript (
	echo.
	echo.  %_zBLACKonYELLOW% ^>^>^>  INTERRUPTED / INCOMPLETE PROCESSING  ^<^<^< %_zDEFAULT%

	echo.>>"REPORT.lua"
	echo|set /p="%_INFO%     >>>  INTERRUPTED / INCOMPLETE PROCESSING  <<<">>"REPORT.lua" & echo.>>"REPORT.lua"
)

Call :LuaEndedOkREMOVE
.\MODBUILDER\%_mLUA% ".\MODBUILDER\CheckREPORTLOG.lua" ".\\" ".\\MODBUILDER\\" !_bCheckMODSconflicts!
Call :LuaEndedOk

echo.            %_zBLACKonYELLOW% ^>^>^> See "REPORT.lua" ^<^<^< %_zDEFAULT%

if %_uOldMBINCompilerFlag%==Y (
	if %_bNumberScripts% GTR 0 (
		echo.
		echo.%_zRED%============================================================================%_zDEFAULT%
		echo. %_zINVERSE%[NOTE] Some PAKs could not be decompiled by the current MBINCompiler      %_zDEFAULT%
		echo. %_zINVERSE%       Processing of .lua scripts is halted until those PAKs are removed  %_zDEFAULT%
		echo. %_zINVERSE%       from ModScript                                                     %_zDEFAULT%
		echo.%_zRED%============================================================================%_zDEFAULT%

		echo|set /p="[NOTE] Some PAKs could not be decompiled by the current MBINCompiler">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE] Processing of .lua scripts is halted until those PAKs are removed">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p="[NOTE] from ModScript">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	)
)

if defined _bUNPACKED_DECOMPILED (
	echo.
	echo.%_zRED%      %_bNumberMBINs% MBIN^(s^) processed%_zDEFAULT%
	echo.%_zRED%      %_bGNumScriptsInPak% Script^(s^) found in PAK^(s^)%_zDEFAULT%
	echo.%_zRED%      %_bNumberPAKs% PAK^(s^)/MBIN^(s^) processed%_zDEFAULT%
	echo.%_zRED%      	%_bGNumberFiles% file^(s^) found in PAK^(s^)/MBIN^(s^)%_zDEFAULT%
	
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

	echo.>>"REPORT.lua"
	echo|set /p="%_INFO% %_bNumberMBINs% MBIN(s) processed">>"REPORT.lua" & echo.>>"REPORT.lua"
	echo|set /p="%_INFO% %_bGNumScriptsInPak% Script(s) found in PAK(s)">>"REPORT.lua" & echo.>>"REPORT.lua"
	echo|set /p="%_INFO% %_bNumberPAKs% PAK(s)/MBIN(s) processed">>"REPORT.lua" & echo.>>"REPORT.lua"
	echo|set /p="%_INFO%   %_bGNumberFiles% file(s) found in PAK(s)/MBIN(s)">>"REPORT.lua" & echo.>>"REPORT.lua"
	
	if %_bGNumberFilesNoVersionInfo% GTR 0 (
		echo|set /p="%_INFO%   %_bGNumberFilesNoVersionInfo% file(s) having NO Version information">>"REPORT.lua" & echo.>>"REPORT.lua"
	)
	echo|set /p="%_INFO%   %_bGNumberFilesDecompiled% file(s) decompiled">>"REPORT.lua" & echo.>>"REPORT.lua"
	if %_bNumberFilesCouldNotDecompile% GTR 0 (
		echo|set /p="%_INFO%   %_bNumberFilesCouldNotDecompile% file(s) could not be decompiled by any MBINCompiler version">>"REPORT.lua" & echo.>>"REPORT.lua"
	)
	if %_bGNumberFilesMissing% GTR 0 (
		echo|set /p="%_INFO%   %_bGNumberFilesMissing% file(s) missing the right MBINCompiler">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p=".   [WARNING]     Please report missing VERSION to AMUMSS developper, thanks.">>"REPORT.lua" & echo.>>"REPORT.lua"
	)
	echo.>>"REPORT.lua"

	if %_uOldMBIN%==Y (
		echo.
		echo.   %_zRED%========================================================%_zDEFAULT%
		echo.    %_zINVERSE%[NOTE] An older version of MBINCompiler was used      %_zDEFAULT%
		echo.    %_zINVERSE%      or the MBIN file was never compiled             %_zDEFAULT%
		echo.    %_zINVERSE%      or the right MBINCompiler could not be found.   %_zDEFAULT%
		echo.    %_zINVERSE%      It means that one or more EXML are most likely  %_zDEFAULT%
		echo.    %_zINVERSE%      not compatible with the current version of NMS. %_zDEFAULT%
		if %_bNumberScripts% GTR 0 (
			echo. %_zINVERSE%      No PAK will be produced^^!                      %_zDEFAULT%
		)
		echo.   %_zRED%========================================================%_zDEFAULT%
		
		echo.>>"REPORT.lua"
		echo|set /p=".   [NOTE] An older version of MBINCompiler was used">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p=".   [NOTE] or the MBIN file was never compiled">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p=".   [NOTE] or the right MBINCompiler could not be found.">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p=".   [NOTE] It means that one or more EXML are most likely">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo|set /p=".   [NOTE] not compatible with the current version of NMS.">>"REPORT.lua" & echo.>>"REPORT.lua"
		if %_bNumberScripts% GTR 0 (
			echo|set /p=".   [NOTE] No PAK will be produced^!">>"REPORT.lua" & echo.>>"REPORT.lua"
		)
		echo.>>"REPORT.lua"
	)

	echo.
	if %_bNumberPAKs% GTR 0 (
		echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%
		echo. %_zBLACKonYELLOW% ^>^>^> You can examine the content of the PAKs in the UNPACKED_DECOMPILED_PAKs folder under the PAK name %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%
		echo. %_zBLACKonYELLOW% ^>^>^> The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders        %_zDEFAULT%
		echo. %_zBLACKonYELLOW%                                                                                                       %_zDEFAULT%

		echo|set /p="%_INFO% You can examine the content of the PAKs in the UNPACKED_DECOMPILED_PAKs folder under the PAK name">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
		echo|set /p="%_INFO% The content of the LAST PAK is also in ModScript's EXTRACTED_PAK and EXMLFILES_PAK folders">>"REPORT.lua" & echo.>>"REPORT.lua"
		echo.>>"REPORT.lua"
	)
)

REM get time to process
if defined _bStartTime (
	Call :LuaEndedOkREMOVE
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\EndTime.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk

	Call :LuaEndedOkREMOVE
	.\MODBUILDER\%_mLUA% ".\MODBUILDER\DiffTime.lua" ".\\" ".\\MODBUILDER\\"
	Call :LuaEndedOk
)

if defined _min_subprocess (
	echo.################ IN DEBUG MODE ################
	echo.
	if defined _mDEBUG (
		set _
		echo.%_zDEFAULT%
		echo. ********* Ran with these arguments *********
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
:PROBLEM_FOLDER
	echo.   - Make sure no file are in use in that folder...
	echo.   - Try to delete the folder yourself...
	echo.   - Close AMUMSS cmd window and re-try...
	pause
	EXIT

rem --------------------------------------------
:Cleaning_EXML_Helper
	set _bCount=0
	:RETRY4
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem cleaning folder 'EXML_Helper' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "EXML_Helper\*.*" 1>NUL 2>NUL
	if exist "EXML_Helper" (
		rd /s /q "EXML_Helper" 2>NUL
		goto :RETRY4
	)
	mkdir "EXML_Helper"
	mkdir "EXML_Helper\MODDED"
	mkdir "EXML_Helper\ORG_EXML"
	mkdir "EXML_Helper\EXTRACTED"
	EXIT /B
	
rem --------------------------------------------
:Cleaning_TEMP
	set _bCount=0
	:RETRY5
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem cleaning folder 'MODBUILDER\_TEMP' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "_TEMP\*.*" 1>NUL 2>NUL
	if exist "_TEMP" (
		rd /s /q "_TEMP" 2>NUL
		goto :RETRY5
	)
	rem DO NOT create _TEMP
	EXIT /B
	
rem --------------------------------------------
:Cleaning_EXTRACTED_PAK
	set _bCount=0
	:RETRY7
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem cleaning folder 'ModScript\EXTRACTED_PAK' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "EXTRACTED_PAK\*.*" 1>NUL 2>NUL
	if exist "EXTRACTED_PAK" (
		rd /s /q "EXTRACTED_PAK" 1>NUL 2>NUL
		goto :RETRY7
	)
	rem DO NOT create ModScript\EXTRACTED_PAK
	EXIT /B

rem --------------------------------------------
:Cleaning_EXMLFILES_PAK
	set _bCount=0
	:RETRY8
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXMLFILES_PAK' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "EXMLFILES_PAK\*.*" 1>NUL 2>NUL
	if exist "EXMLFILES_PAK" (
		rd /s /q "EXMLFILES_PAK" 1>NUL 2>NUL
		goto :RETRY8
	)
	rem DO NOT create ModScript\EXMLFILES_PAK
	EXIT /B

rem --------------------------------------------
:Cleaning_EXMLFILES_CURRENT
	set _bCount=0
	:RETRY9
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXMLFILES_CURRENT' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "EXMLFILES_CURRENT\*.*" 1>NUL 2>NUL
	if exist "EXMLFILES_CURRENT" (
		rd /s /q "EXMLFILES_CURRENT" 1>NUL 2>NUL
		goto :RETRY9
	)
	rem DO NOT create ModScript\EXMLFILES_CURRENT
	EXIT /B

rem --------------------------------------------
:Cleaning_EXTRACTED_SOURCE
	set _bCount=0
	:RETRY10
	if !_bCount! GTR 1000 (
		echo.   xxxxx [WARNING] Problem Cleaning folder 'ModScript\EXTRACTED_SOURCE' xxxxx
		goto :PROBLEM_FOLDER
	)
	
	SET /A _bCount=_bCount+1
	Del /f /q /s "EXTRACTED_SOURCE\*.*" 1>NUL 2>NUL
	if exist "EXTRACTED_SOURCE" (
		rd /s /q "EXTRACTED_SOURCE" 1>NUL 2>NUL
		goto :RETRY10
	)
	rem DO NOT create ModScript\EXTRACTED_SOURCE
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
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.    [BUG] lua.exe generated an [ERROR]... Please report ALL scripts AND this file to NMS Discord: "No Man's Sky Modding" channel, "mod-amumss-lua" room:>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.           https://discord.gg/22ZAU9H>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
		echo.>>"%_bMASTER_FOLDER_PATH%REPORT.lua"
	)
	EXIT /B
	
rem --------------------------------------------
:LuaEndedOkREMOVE
	Del /f /q /s "%_bMASTER_FOLDER_PATH%MODBUILDER\LuaEndedOK.txt" 1>NUL 2>NUL
	EXIT /B
	
rem --------------------------------------------
:MBINCompilerUPDATE
	rem ****************************  start MBINCompiler.exe update section  ******************************
	rem ******   Currently IN MODBUILDER   ********
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

	if [%-AutoUpdateMBinCompiler%]==[N] goto :END_MBINCompilerUPDATE

	REM in case this is a new install over an existing older one, force update
	if not exist "MBINCompiler.previous.exe" (
		Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
		echo.^>^>^> Fetching MBINCompiler on the web...
		goto :RETRY_MBINCompiler
	)

	if [%-AutoUpdateMBinCompiler%]==[ASK] goto :AskUpdateMBinCompiler
	if [%-AutoUpdateMBinCompiler%]==[] goto :AskUpdateMBinCompiler
	if [%-AutoUpdateMBinCompiler%]==[Y] goto :RETRY_MBINCompiler
	if [%-AutoUpdateMBinCompiler%]==[N] goto :END_MBINCompilerUPDATE
	
	echo.==^> BAD OPTION VALUE for '-AutoUpdateMBinCompiler' [%-AutoUpdateMBinCompiler%], please correct!
	echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
	pause

	:AskUpdateMBinCompiler
	echo.
	CHOICE /c:yn /t 30 /d y /m " %_zBLACKonYELLOW% ??? Do you want to UPDATE MBINCompiler.exe, if it is available, (default Y in 30 seconds) %_zDEFAULT%"
	if %ERRORLEVEL% EQU 2 goto :END_MBINCompilerUPDATE

	REM :SIMPLE_MODE1
	REM echo.
	REM REM echo.^>^>^> %_bB% Calling MBINCompilerDownloader.bat: getting latest MBINCompiler from Web
	REM echo.^>^>^> Getting latest MBINCompiler from Web...

	:RETRY_MBINCompiler
	CALL MBINCompilerDownloader.bat

	REM :CONTINUE_EXECUTION2
	if not exist "MBINCompiler.exe" (
		REM Del /f /q /s ".\MBINCompilerDownloader\URLPrevious.txt" 1>NUL 2>NUL
		REM goto :RETRY_MBINCompiler
		echo.***** MISSING MBINCompiler.exe: AMUMSS cannot work.  Terminating batch until corrected.
		echo.***** Possible cause: anti-virus, make exception
		echo.***** Possible cause: problem with internet
		pause
		exit
	)
	
	Del /f /q /s "MBINCompilerVersion.txt" 1>NUL 2>NUL
	MBINCompiler.exe version -q >>"MBINCompilerVersion.txt"
	set /p _bMBINCompilerVersion=<MBINCompilerVersion.txt

	if [%_bMBINCompilerVersion%]==[] (
		echo.
		echo.^>^>^> [ERROR] MBINCompiler.exe cannot execute.  Most probable cause: anti-virus, make exception%_zDEFAULT%
		echo|set /p="[ERROR] MBINCompiler.exe cannot execute.  Most probable cause: anti-virus, make exception">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		echo.>>"..\REPORT.lua"
		pause
		exit
	)
	
	if NOT "%_bMBINCompilerVersionOLD%"=="%_bMBINCompilerVersion%" (
		echo.
		echo.^>^>^> Your new MBINCompiler is version: %_zGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
		echo|set /p="%_INFO% Your new MBINCompiler is version: %_bMBINCompilerVersion%">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
		echo.>>"..\REPORT.lua"
	REM ) else (
		REM echo.
		REM echo.^>^>^> MBINCompiler is still version: %_zGREEN%%_bMBINCompilerVersion%%_zDEFAULT%
	)
	rem ****************************  end MBINCompiler.exe update section  ******************************

	:END_MBINCompilerUPDATE
	EXIT /B

rem --------------------------------------------
:CHECK_ExtraFilesToInclude
	rem --------------  Check if ExtraFilesToInclude are present ------------------------------
	SET _bExtraFiles=0

	FOR /r "%~dp0\ModExtraFilesToInclude" %%G in (*.*) do ( 
		SET /A _bExtraFiles=_bExtraFiles+1
	)
	if %_bExtraFiles% EQU 0 goto :NO_EXTRAFILES

	if [%-UseExtraFilesInPAK%]==[ASK] goto :AskUseExtraFilesInPAK
	if [%-UseExtraFilesInPAK%]==[] goto :AskUseExtraFilesInPAK
	if [%-UseExtraFilesInPAK%]==[Y] (
		SET _bExtraFilesInPAK=y
		goto :
	)
	if [%-UseExtraFilesInPAK%]==[N] goto :NO_EXTRAFILES

	echo.==^> BAD OPTION VALUE for '-UseExtraFilesInPAK' [%-UseExtraFilesInPAK%], please correct!
	echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
	pause

	:AskUseExtraFilesInPAK
	echo.
	echo.^>^>^> There are Extra Files in the ModExtraFilesToInclude folder.  If you INCLUDE them...
	echo.^>^>^>      *****  Remember, these files will OVERWRITE any existing ones in the created PAK  *****

	CHOICE /c:YN /m " %_zBLACKonYELLOW% ??? Do you want to include them in the created PAK %_zDEFAULT%"
	echo.
	if %ERRORLEVEL% EQU 2 goto :NO_EXTRAFILES
	if %ERRORLEVEL% EQU 1 SET _bExtraFilesInPAK=y

	echo|set /p="%_INFO% Extra Files in the ModExtraFilesToInclude folder will be included in the PAK">>"REPORT.lua" & echo.>>"REPORT.lua"
	echo.>>"REPORT.lua"

	:NO_EXTRAFILES
	EXIT /B

rem --------------------------------------------
:PAK_LISTsCREATION
	rem **************************  start PAK_LISTs creation section  ********************************
	echo.
	echo.^>^>^> Checking NMS PCBANKS PAK file list existence...

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
	
	if [%-RecreatePAKList%]==[ASK] goto :PAK_LISTsCREATION_2
	if [%-RecreatePAKList%]==[] goto :PAK_LISTsCREATION_2
	if [%-RecreatePAKList%]==[N] (
		set _bRecreatePAKList=2
		goto :NoNeedToAsk
	)
	if [%-RecreatePAKList%]==[Y] (
		set _bRecreatePAKList=1
		goto :NoNeedToAsk
	)
	
	echo.==^> BAD OPTION VALUE for '-RecreatePAKList' [%-RecreatePAKList%], please correct!
	echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
	pause
	
	:PAK_LISTsCREATION_2
	echo.
	REM echo.^>^>^> If there was a NMS update, it is recommended to recreate this list
	CHOICE /c:yn /m " %_zBLACKonYELLOW% ??? Do you want to RECREATE the NMS PAK file list %_zDEFAULT%"
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
	rem ******   In UNPACKEDtoEXML: Currently IN ModScript   ********
	echo.
	set "_bCurrentPath=%_bMASTER_FOLDER_PATH%ModScript\EXTRACTED_PAK\"
	
	REM echo._bDoingPAk is %_bDoingPAk%
	
	if DEFINED _bDoingPAk Del /f /q /s "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
	if DEFINED _bDoingPAk echo|set /p="REPORT for !_bPAKname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
	
	set _bNumberFilesNoVersionInfo=0
	SET _bNumberFiles=0
	FOR /r ".\EXTRACTED_PAK\" %%G in (*.mbin.*) do (
		REM echo.With current MBINCompiler: %%G
		SET /A _bNumberFiles=_bNumberFiles+1
		set "_bG=%%G"
		set "_bNMSname=!_bG:%_bCurrentPath%=!"
		set _gMBINVersion=
		Del /f /q /s ".\EXTRACTED_PAK\bMBINVersion.txt" 1>NUL 2>NUL
		rem get MBINCompiler version that compiled this MBIN
		..\MODBUILDER\MBINCompiler.exe version -q "%%G">>".\EXTRACTED_PAK\bMBINVersion.txt"
		set /p _gMBINVersion=<".\EXTRACTED_PAK\bMBINVersion.txt"
		Del /f /q /s ".\EXTRACTED_PAK\bMBINVersion.txt" 1>NUL 2>NUL
		if "!_gMBINVersion!"=="0.0.0.0" (
			SET /A _bNumberFilesNoVersionInfo=_bNumberFilesNoVersionInfo+1
			echo.----- %_zRED%[NO VERSION INFO]%_zDEFAULT%    Never compiled: !_bNMSname!
			echo|set /p=".   [NO VERSION INFO]    Never compiled: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [NO VERSION INFO]    Never compiled: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			if "!_gMBINVersion!"=="" (
				echo.----- %_zRED%[NO VERSION INFO]%_zDEFAULT%    Could not check version: !_bNMSname!
				echo|set /p=".   [NO VERSION INFO]    Could not check version: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
				if DEFINED _bDoingPAk echo|set /p=".   [NO VERSION INFO]    Could not check version: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			) else (
				echo.----- [INFO] Compiled with version !_gMBINVersion!: !_bNMSname!
				echo|set /p="%_INFO%     Compiled with version !_gMBINVersion!: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
				if DEFINED _bDoingPAk echo|set /p="%_INFO%     Compiled with version !_gMBINVersion!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			)
		)
	)
	echo.
	echo.%_zGREEN%^>^>^> %_bB% Trying to decompile .mbin...%_zDEFAULT%
	echo.>>"..\REPORT.lua"
	echo|set /p="%_INFO%   Trying to decompile .mbin...">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	if DEFINED _bDoingPAk echo|set /p="%_INFO%   Trying to decompile .mbin...">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

	rem First we try our current MBINCompiler, extracting ALL to folder EXTRACTED_PAK
	REM THIS USED TO WORK
	REM ..\MODBUILDER\mbincompiler.exe convert -y -f -oEXML -d".\EXTRACTED_PAK" --exclude=";" --include="*.MBIN;*.MBIN.PC" ".\EXTRACTED_PAK" 1>NUL 2>NUL

	REM THIS CURRENTLY WORKS
	..\MODBUILDER\mbincompiler.exe convert -y -f -oEXML -d".\EXTRACTED_PAK" --include="*.MBIN;*.MBIN.PC" ".\EXTRACTED_PAK" 1>NUL 2>NUL

	FOR /r ".\EXTRACTED_PAK\" %%G in (*.mbin.*) do (
		set "_bG=%%G"
		set "_bNMSname=!_bG:%_bCurrentPath%=!"

		set _gMBIN_FILE=%%G
		set _gMBIN_FILE=!_gMBIN_FILE:.MBIN.PC=.MBIN!
		set _gEXML_FILE=!_gMBIN_FILE:.MBIN=.EXML!
		
		if not exist !_gEXML_FILE! (
			REM echo. ====^> Not found file: !_gEXML_FILE!
			rem Then we try to extracts to folder EXTRACTED_PAK with the other MBINCompiler
			REM echo.     ====^> using Previous MBINCOMPILER with %%G
			..\MODBUILDER\MBINCompiler.previous.exe "%%G" 1>NUL 2>NUL
		)
	)

	SET _uOldMBIN=N

	SET _bNumberFilesDecompiled=0
	SET _bNumberFilesMissing=0
	SET _bNumberFilesCouldNotDecompile=0

	FOR /r ".\EXTRACTED_PAK\" %%G in (*.mbin.*) do (
		echo.For !_bNMSname!
		set "_bG=%%G"
		set "_bNMSname=!_bG:%_bCurrentPath%=!"

		set _gMBIN_FILE=%%G
		set _gMBIN_FILE=!_gMBIN_FILE:.MBIN.PC=.MBIN!
		set _gEXML_FILE=!_gMBIN_FILE:.MBIN=.EXML!
		
		if exist !_gEXML_FILE! (
			echo.      [SUCCESS] Decompiled with current %_zGREEN%MBINCompiler.%_bMBINCompilerVersion%%_zDEFAULT%
			echo|set /p="%_INFO%     SUCCESS: Decompiled with current MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p="%_INFO%     SUCCESS: Decompiled with current MBINCompiler.%_bMBINCompilerVersion%: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			SET /A _bNumberFilesDecompiled=_bNumberFilesDecompiled+1
		) else (
			REM we need to try all MBINCompiler.exe
			REM maybe we will get lucky
			REM echo.With other MBINCompilers: %%G
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
				echo.%_zUpOneLineErase%!_zUOLE!      [SUCCESS] Decompiled with ------^> %_zRED%!_bCurrentCompiler!%_zDEFAULT%
				echo|set /p="%_INFO%     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
				if DEFINED _bDoingPAk echo|set /p="%_INFO%     SUCCESS: Decompiled with ------> !_bCurrentCompiler!: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
				SET /A _bNumberFilesDecompiled=_bNumberFilesDecompiled+1
			) else (
				SET /A _bNumberFilesCouldNotDecompile=_bNumberFilesCouldNotDecompile+1
				echo.%_zUpOneLineErase%!_zUOLE!%_zRED%      [SORRY] No MBINCompiler could decompile this file%_zDEFAULT%
				echo|set /p="%_INFO%       SORRY:                 No MBINCompiler could decompile this file: !_bNMSname!">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
				if DEFINED _bDoingPAk echo|set /p="%_INFO%       SORRY:                 No MBINCompiler could decompile this file: !_bNMSname!">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
			)
			set _zUOLE=
			
			Del /f /q /s "..\MODBUILDER\Extras\MBINCompiler_OldVersions\*.log" 1>NUL 2>NUL				
			REM )
		)
	)
	
	echo.
	echo.%_zGREEN%^>^>^> Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files%_zDEFAULT%
	
	echo|set /p="%_INFO%   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
	if DEFINED _bDoingPAk echo|set /p="%_INFO%   Decompiled %_bNumberFilesDecompiled% / %_bNumberFiles% files">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"

	rem calculate the number of scripts in this pak
	SET _bNumScriptsInPak=0
	FOR %%G in ("..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\*.lua") do ( 
		SET /A _bNumScriptsInPak=_bNumScriptsInPak+1
	)

	if %_bNumScriptsInPak% GTR 0 (
		if %_bNumScriptsInPak% EQU 1 (
			echo.%_zGREEN%^>^>^> Copied one script file %_zDEFAULT%
			echo|set /p="%_INFO%   Copied one script file">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p="%_INFO%   Copied one script file">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zGREEN%^>^>^> Copied %_bNumScriptsInPak% script files %_zDEFAULT%
			echo|set /p="%_INFO%   Copied %_bNumScriptsInPak% script files">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p="%_INFO%   Copied %_bNumScriptsInPak% script files">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)
	
	if not exist ".\EXMLFILES_PAK" (
		mkdir "EXMLFILES_PAK" 2>NUL
	)

	if %_bNumberFilesMissing% GTR 0 (
		if %_bNumberFilesMissing% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report%_zDEFAULT%
			
			echo|set /p=".   [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesMissing% files are missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file is missing the right version of MBINCompiler, please report%_zDEFAULT%
			
			echo|set /p=".   [WARNING] One file is missing the right version of MBINCompiler, please report">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file is missing the right version of MBINCompiler, please report">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)

	if %_bNumberFilesCouldNotDecompile% GTR 0 (
		if %_bNumberFilesCouldNotDecompile% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler%_zDEFAULT%
			
			echo|set /p=".   [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesCouldNotDecompile% cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file cannot be decompiled using any MBINCompiler%_zDEFAULT%
			
			echo|set /p=".   [WARNING] One file cannot be decompiled using any MBINCompiler">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file cannot be decompiled using any MBINCompiler">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	)
	
	if %_bNumberFilesNoVersionInfo% GTR 0 (
		REM echo.
		if %_bNumberFilesNoVersionInfo% GTR 1 (
			echo.%_zRED%^>^>^> [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information%_zDEFAULT%
			
			echo|set /p=".   [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] %_bNumberFilesNoVersionInfo% files have NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		) else (
			echo.%_zRED%^>^>^> [WARNING] One file has NO version information%_zDEFAULT%
			
			echo|set /p=".   [WARNING] One file has NO version information">>"..\REPORT.lua" & echo.>>"..\REPORT.lua"
			if DEFINED _bDoingPAk echo|set /p=".   [WARNING] One file has NO version information">>"REPORT_!_bPAKname!.txt" & echo.>>"REPORT_!_bPAKname!.txt"
		)
	) else (
		echo.>>"..\REPORT.lua"	
	)

	rem *******************  if any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
	echo.
	echo.%_zGREEN%^>^>^> Moving EXML to EXMLFILES_PAK folders...%_zDEFAULT%
	FOR /r "EXTRACTED_PAK" %%G in (*.exml) do (
		set _gEXML_FILE=%%G
		set _gEXML_FILE=!_gEXML_FILE:EXTRACTED_PAK=EXMLFILES_PAK!
		rem NOTE: move command did not work
		xcopy /y /h /v "%%G" "!_gEXML_FILE!*" 1>NUL 2>NUL
	)

	echo.
	echo.^>^>^> Saving extracted files to UNPACKED_DECOMPILED_PAKs folder...

	rem doing it in two step so we can use the pak info in ModScript with a .lua
	rem when one exist (inside the pak or from the user)
	if DEFINED _bDoingPAk ROBOCOPY /e /j "EXMLFILES_PAK" "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!\EXMLFILES_PAK" 1>NUL 2>NUL

	if DEFINED _bDoingPAk ROBOCOPY /j "EXTRACTED_PAK" "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" "*.lua" 1>NUL 2>NUL
	Del /f /q /s ".\EXTRACTED_PAK\*.exml" 1>NUL 2>NUL
	rem *******************  END: any EXML files in EXTRACTED_PAK, move them to EXMLFILES_PAK
	
	rem copy this pak report to its folder
	if DEFINED _bDoingPAk ROBOCOPY /j "." "..\UNPACKED_DECOMPILED_PAKs\!_bPAKname!" "REPORT_!_bPAKname!.txt" 1>NUL 2>NUL
	
	SET /A _bGNumberFiles=_bGNumberFiles+!_bNumberFiles!
	SET /A _bGNumberFilesDecompiled=_bGNumberFilesDecompiled+!_bNumberFilesDecompiled!
	SET /A _bGNumberFilesNoVersionInfo=_bGNumberFilesNoVersionInfo+!_bNumberFilesNoVersionInfo!
	SET /A _bGNumberFilesMissing=_bGNumberFilesMissing+!_bNumberFilesMissing!
	SET /A _bGNumScriptsInPak=_bGNumScriptsInPak+!_bNumScriptsInPak!
	
	EXIT /B

rem --------------------------------------------
:GET_CURRENT_EXML_for_COMPARISON
	rem ******   Currently IN ModScript   ********
	REM @echo on
	echo.

	if not exist EXMLFILES_CURRENT (
		mkdir EXMLFILES_CURRENT 2>NUL
	) else (
		CALL :Cleaning_EXMLFILES_CURRENT
		mkdir EXMLFILES_CURRENT 2>NUL
	)
	
	rem ******   Currently IN ModScript\EXMLFILES_CURRENT   ********
	cd EXMLFILES_CURRENT
	
	echo.%_zRED%=============================%_zDEFAULT%
	FOR /r "%~dp0\ModScript\EXTRACTED_PAK" %%G in (*.MBIN) do ( 
		echo.Getting current EXML for %%~nxG

		set _gMBIN_FILE=%%G
		set _gMBIN=!_gMBIN_FILE:.MBIN.PC=.MBIN!
		set _gEXML_FILE=!_gMBIN:.MBIN=.EXML!
		if not exist "!_gEXML_FILE!" (
			mkdir "ModScript\EXTRACTED_SOURCE"

			rem ******   Currently IN MODBUILDER   ********
			cd ..\..\MODBUILDER
			
			CALL :EXTRACT_this !_gMBIN_FILE!
			
			rem ******   Currently IN ModScript   ********
			cd ..\ModScript
			
			echo.^>^>^> %_gG% MBINCompiler working...
			echo.----- [INFO] %%G
			..\MODBUILDER\MBINCompiler.exe "!CD!\EXTRACTED_SOURCE\%%G" -y -f -d "!CD!\EXMLFILES_CURRENT\%%G\.." 1>NUL 2>NUL
			Call :LuaEndedOkREMOVE
			..\MODBUILDER\%_mLUA% ..\MODBUILDER\CheckMBINCompilerLOG.lua "..\\" "..\\MODBUILDER\\" "Decompiling"
			Call :LuaEndedOk
			echo.
			REM echo."!CD!\DECOMPILED\!_gEXML_FILE!"
			REM echo."..\MOD\!_gEXML_FILE!*"
			REM xcopy /s /y /h /v "!CD!\DECOMPILED\!_gEXML_FILE!" "..\MOD\!_gEXML_FILE!*" 1>NUL 2>NUL
		)
	)
	echo.%_zRED%=============================%_zDEFAULT%
	
	rem ******   Currently IN ModScript   ********
	cd..
	CALL :Cleaning_EXTRACTED_SOURCE
	
	EXIT /B

rem --------------------------------------------
:EXTRACT_this
	rem ******   Currently IN MODBUILDER   ********
	
	Call :LuaEndedOkREMOVE
	%_mLUA% LocateMOD_PAK_SOURCE.lua %1
	Call :LuaEndedOk

	FOR /F "tokens=*" %%H in (..\ModScript\MOD_PAK_SOURCE.txt) do (
		if not exist "..\ModScript\EXTRACTED_SOURCE\%%H" (
			REM echo.
			echo.^>^>^> Getting %%H from NMS PCBANKS folder. Please wait...
			xcopy /s /y /h /v "%_bNMS_PCBANKS_FOLDER%%%H" "%_bMASTER_FOLDER_PATH%\ModScript\EXTRACTED_SOURCE\" >NUL
		)
		REM echo.^>^>^> Looking to Extract required MBIN/EXML from %%H...
		..\psarc.exe extract "%_bNMS_PCBANKS_FOLDER%%%H" "%1" --to="%_bMASTER_FOLDER_PATH%\ModScript\EXTRACTED_SOURCE" -y 1>NUL 2>NUL
		if exist "%_bMASTER_FOLDER_PATH%\ModScript\EXTRACTED_SOURCE\%1" (
			echo.^>^>^> Extracted MBIN/EXML from %%H...
			REM echo.^>^>^> %_gG% Found required MBIN
			goto :ENDEXTRACT
		)
	)
	:ENDEXTRACT_this
	EXIT /B
	
rem --------------------------------------------
:CheckBankSignatures
	echo. [%~2]
	echo. [%1] [!%1!]
	if exist "%~2" (
		echo. Does exist
		set "%1=Y"
	) else (
		echo. Does not exist
	)
	:ENDCheckBankSignatures
	exit /B
	
rem --------------------------------------------
:HOW_MANY_LINES
	REM check how many lines to process for Conflict Detection
	SET /a _Lines=0
	REM echo._fileToCheck = %_fileToCheck%
	For /f %%j in ('Find "" /v /c ^<%_fileToCheck%') Do set /a _Lines=%%j
	
	REM if !_bCheckMODSconflicts! EQU 1 goto :SkipSubtract
	REM if !_bCheckMODSconflicts! EQU 3 SET _subtractOne=Y
	if !_bCheckMODSconflicts! EQU 4 SET _subtractOne=Y
	
	if defined _subtractOne (
		rem one less for MODS
		set /a "_Lines=_Lines-1"
	)
	SET _subtractOne=
	
	REM if defined _subtractTwo (
		REM rem two less for SCRIPTS
		REM set /a "_Lines=_Lines-2"
	REM )
	REM SET _subtractTwo=
	
	:SkipSubtract
	if !_Lines! GTR 10000 (
		echo.
		echo.  %_zGREEN%We have !_Lines! Conflict lines to process, it could add a few minutes to complete...%_zDEFAULT%
		CHOICE /c:ynms /m " %_zBLACKonYELLOW% ??? Do you really want to check your NMS MODS for conflicts ('Y'es, 'N'o, in 'M'ODS or Mod'S'cripts)?%_zDEFAULT%"
		if %ERRORLEVEL% EQU 4 set _bCheckMODSconflicts=4
		if %ERRORLEVEL% EQU 3 set _bCheckMODSconflicts=3
		if !ERRORLEVEL! EQU 2 SET _bCheckMODSconflicts=2
		if !ERRORLEVEL! EQU 1 SET _bCheckMODSconflicts=1	
	) else (
		if !_Lines! GTR 0 (
			echo.
			if !_Lines! GTR 1 (
				echo.  %_zGREEN%We will process !_Lines! possible conflicting files%_zDEFAULT%
			) else (
				echo.  %_zGREEN%We will process !_Lines! possible conflicting file%_zDEFAULT%
			)
		)
	)
	SET /A _bGConflictLines=_bGConflictLines+!_Lines!
	:END_HOW_MANY_LINES
	exit /B

rem --------------------------------------------
:CONFLICTDETECTION
	rem -------------   Conflict detection or not?  -------------
	if [%-CheckForModConflicts%]==[ASK] goto :ASK_CONFLICTDETECTION
	if [%-CheckForModConflicts%]==[] goto :ASK_CONFLICTDETECTION
	if [%-CheckForModConflicts%]==[N] (
		set _bCheckMODSconflicts=2
		goto :ENDCONFLICTDETECTION
	)
	if [%-CheckForModConflicts%]==[Y] (
		set _bCheckMODSconflicts=1
		goto :ENDCONFLICTDETECTION
	)
	if [%-CheckForModConflicts%]==[MODS] (
		set _bCheckMODSconflicts=3
		goto :ENDCONFLICTDETECTION
	)
	if [%-CheckForModConflicts%]==[M] (
		set _bCheckMODSconflicts=3
		goto :ENDCONFLICTDETECTION
	)
	if [%-CheckForModConflicts%]==[SCRIPTS] (
		set _bCheckMODSconflicts=4
		goto :ENDCONFLICTDETECTION
	)
	if [%-CheckForModConflicts%]==[S] (
		set _bCheckMODSconflicts=4
		goto :ENDCONFLICTDETECTION
	)

	echo.==^> BAD OPTION VALUE for '-CheckForModConflicts' [%-CheckForModConflicts%], please correct!
	echo.==^> see 'README - OPTIONS DEFINITIONS.txt' for proper OPTION definitions
	pause

	:ASK_CONFLICTDETECTION
	echo.
	CHOICE /c:ynms /m " %_zBLACKonYELLOW% ??? Would you like to check your NMS MODS for conflict ('Y'es, 'N'o, in 'M'ODS folder or 'S'cripts folder only)? %_zDEFAULT%"
	if %ERRORLEVEL% EQU 4 set _bCheckMODSconflicts=4
	if %ERRORLEVEL% EQU 3 set _bCheckMODSconflicts=3
	if %ERRORLEVEL% EQU 2 set _bCheckMODSconflicts=2
	if %ERRORLEVEL% EQU 1 set _bCheckMODSconflicts=1
	:ENDCONFLICTDETECTION
	EXIT /B

rem --------------------------------------------
