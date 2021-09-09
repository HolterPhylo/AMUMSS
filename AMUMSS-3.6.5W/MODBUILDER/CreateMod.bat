@echo off
if defined _mVERBOSE (
	echo.^>^>^>     In CreateMod.bat
)
rem All defined variables in CreateMod.bat start with _c (except FOR loop first parameter)
rem so we can easily list them all like this on error, if needed: set _c

SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS

set "_cC="
if defined _mVERBOSE set "_cC=CreateMod.bat:"

set /p _cDateTime=<DateTime.txt

REM Test if a MOD name exist
set /p _cMOD_FILENAME=<MOD_FILENAME.txt

if [] == [!_cMOD_FILENAME!] (
	echo.
	echo.^>^>^> No MOD filename. Not creating pak file for this script.
	goto :ENDIT
) else (
	REM echo.^>^>^> Found the MOD filename
)

REM Test if a MOD BATCHNAME exist
set /p _cMOD_BATCHNAME=<MOD_BATCHNAME.txt

set _BatchName=Y
if [] == [!_cMOD_BATCHNAME!] (
	set _BatchName=N
)

set _cName=ZZZCombinedMod_
if defined _bPATCH (set _cName=PatchMod)
rem on 0, treat as an Individual mod
rem on 1, treat as a generic combined mod
rem on 2, treat as a distinct combined mod
rem on 3, the name being like Mod1+Mod2+Mod3.pak, treat it as an Individual mod 
if %_bCOMBINE_MODS% EQU 0 ( set /p _cMOD_FILENAME=<MOD_FILENAME.txt )

if %_BatchName%==N (
	if %_bCOMBINE_MODS% EQU 1 ( set _cMOD_FILENAME=%_cName%_%_cDateTime%.pak)
	if %_bCOMBINE_MODS% EQU 2 ( set _cMOD_FILENAME=%_cName%.pak)
	if %_bCOMBINE_MODS% EQU 3 ( set /p _cMOD_FILENAME=<Composite_MOD_FILENAME.txt )
) else (
	if %_bNumberScripts% GTR 1 (
		if defined _bPATCH (set _cName=PatchMod)
		set _cMOD_FILENAME=%_cMOD_BATCHNAME%
	) else (
		if %_bCOMBINE_MODS% EQU 1 ( set _cMOD_FILENAME=%_cName%_%_cDateTime%.pak)
		if %_bCOMBINE_MODS% EQU 2 ( set _cMOD_FILENAME=%_cName%.pak)
		if %_bCOMBINE_MODS% EQU 3 ( set /p _cMOD_FILENAME=<Composite_MOD_FILENAME.txt )
	)
)

set /p _cNMS_FOLDER=<NMS_FOLDER.txt
set "_cNMS_PCBANKS_FOLDER=%_cNMS_FOLDER%\GAMEDATA\PCBANKS\"
set "_cNMS_MODS_FOLDER=%_cNMS_PCBANKS_FOLDER%\MODS\"

rem **********************  WE ARE IN MODBUILDER  *********************************
if defined _mVERBOSE (
	echo.^>^>^> %_cC% Starting directory
	echo.%CD%
)
if %_bCOMBINE_MODS% GTR 0 (
	echo.>>"..\REPORT.txt"
)

rem *******************   Copying to MODBUILDER\MOD ModExtraFilesToInclude content  ********************
if not defined _bExtraFilesInPAK goto :NO_EXTRAFILES
echo.
echo.^>^>^> %_cC% Copying to MODBUILDER\MOD ModExtraFilesToInclude content...
echo.>>"..\REPORT.txt"
echo|set /p="[INFO]: Copying to MODBUILDER\MOD ModExtraFilesToInclude content...">>"..\REPORT.txt"
echo.>>"..\REPORT.txt"
xcopy /s /y /h /v /j "..\ModExtraFilesToInclude\*.*" "MOD" 1>NUL 2>NUL
rem *******************  end Copying to MODBUILDER\MOD ModExtraFilesToInclude content  ********************

:NO_EXTRAFILES
REM echo.>>"..\REPORT.txt"
echo|set /p="[INFO]: Starting final MBINCompiler and PAK phase...">>"..\REPORT.txt"
echo.>>"..\REPORT.txt"

rem ########################################################
rem ############### Compile EXML to MBIN ###################
rem ########################################################

rem **********************  WE ARE GOING INTO MOD  *********************************
if defined _mVERBOSE (
	echo.
	echo.^>^>^> %_cC% Changing to directory MOD
)
cd MOD
if defined _mVERBOSE (
	echo.%CD%
)

echo.
echo.^>^>^> %_cC% Compiling EXML file(s) in MOD folder
echo.^>^>^> MBINCompiler working...

rem otherwise the first echo is output twice for long paths (strange)
set _cEmpty= 
FOR /r %%G in (*.exml) do (
	echo.----- [INFO] %%G
	echo|..\MBINCompiler.exe -y -f "%%G" 1>NUL 2>NUL
	Call :LuaEndedOkREMOVE
	..\%_mLUA% ..\CheckMBINCompilerLOG.lua "..\\..\\" "..\\" "Compiling %%G"
	Call :LuaEndedOk
)

rem ########################################################
rem ############### Compress to pak file ###################
rem ########################################################

echo.----------------------------------------
echo.
echo.^>^>^> %_cC% Compressing MBIN (and possibly other) file(s) to PAK(s)

set "_cDestination=..\..\Builds\IncrementalBuilds"
set "_cFilename=%_cMOD_FILENAME:.pak=_%"

rem ****seekker*****************************************************
rem ---->>>> set working directory for the max 10 paks loop
set "tempDel=%_cDestination%"

rem this will check if there are 10 pak already stored
If exist "%tempDel%\%_cFilename%(9).pak" goto :clearOld
goto :preLoop rem if less than 10 goes to preloop function

rem this function is intended to keep paks under 10 but still keep the last 5 paks
:clearOld
REM rem loop 0-4 in 1 step increments
REM FOR /L %%G IN (0,1,4) do del "%tempDel%\%_cFilename%(%%G).pak" 1>NUL 2>NUL

del "%tempDel%\%_cFilename%(0).pak" 1>NUL 2>NUL

rem loop 1-9 in 1 step increments -- renames paks 1-9 to 0-8
FOR /L %%A in (1,1,9) do (
	SET /a "C=%%A"
    SET /a "B=%%A-1"
	rem "cmd.exe /c" is required to make some commands work when local bat launched from another /bat file /script or /program (in this case it could not find file without it)
	cmd.exe /c ren "%tempDel%\%_cFilename%(%%C%%).pak" "%_cFilename%(%%B%%).pak" 1>NUL 2>NUL
    REM call ECHO "%tempDel%\%_cFilename%(%%B%%).pak"
)
rem ****/seekker*****************************************************

:preLoop
rem find how many Builds we have done already for this mod
set _ca=0
:loop
if exist "%_cDestination%\%_cFilename%(%_ca%).pak" set /a _ca+=1 && goto :loop

FOR /L %%G in (1 1 500) do if "!__cd__:~%%G,1!" neq "" set /a "_cLen=%%G+1"

setlocal DisableDelayedExpansion
(FOR /r . %%G in (*.BIN,*.H,*.DDS,*.FNT,*.JSON,*.lua,*.MBIN,*.mbin,*.MXML,*.PC,*.PNG,*.TTC,*.TTF,*.TXT,*.XML,*.WEM) do (
  @echo off
  set "_cAbsPath=%%G"
  setlocal EnableDelayedExpansion
  set "_cRelPath=!_cAbsPath:~%_cLen%!"
  echo(!_cRelPath!
  endlocal
)) > ..\"input.txt"

rem just in case...
setlocal EnableDelayedExpansion

rem ########################################################
rem ############### Create Incremental Builds ##############
rem ########################################################

echo.
echo|..\psarc.exe create --overwrite --skip-missing-files --inputfile=..\input.txt --output="%_cDestination%\%_cFilename%(%_ca%).pak"
echo.

rem ########################################################
rem ############### Copy Mod to NMS Mod and root folder ####
rem ########################################################

rem if xcopy is asking "File or Directory?"  The "*" at the end makes it default to a file without asking

rem ******************************************************************************************************
rem Windows File Paths Limit is 260 characters including terminating null character
rem     (without editing Group Policy, it may not work on all version)
rem ******************************************************************************************************

rem on 0, treat as Individual mods
rem on 1, treat as a generic combined mod
rem on 2, treat as a distinct combined mod
rem on 3, a combined mod treated as an Individual mod, the name being like Mod1+Mod2+Mod3.pak
if %_bCOMBINE_MODS% EQU 2 ( goto :COMBINEDDISTINCTMODS )
		
rem Individual or combined mods type 0, 1 or 3
xcopy /s /y /h /v /j "%_cDestination%\%_cFilename%(%_ca%).pak" "..\..\Builds\%_cMOD_FILENAME%*" 1>NUL 2>NUL
xcopy /s /y /h /v /j "%_cDestination%\%_cFilename%(%_ca%).pak" "..\..\CreatedModPAKs\%_cMOD_FILENAME%*"

if %_bCOMBINE_MODS% EQU 0 (goto :NEXTSTEP)

rem case %_bCOMBINE_MODS% EQU 1
rem case %_bCOMBINE_MODS% EQU 3

REM Mod pak content required if generic combined
xcopy /s /y /h /v /j "..\COMBINED_CONTENT_LIST.txt" "..\..\Builds\%_cMOD_FILENAME%_content.txt*" 1>NUL 2>NUL
xcopy /s /y /h /v /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedModPAKs\%_cMOD_FILENAME%_content.txt*"

goto :NEXTSTEP

:COMBINEDDISTINCTMODS
rem distinct combined mods: 2
xcopy /s /y /h /v /j "%_cDestination%\%_cFilename%(%_ca%).pak" "..\..\Builds\%_cFilename%(%_ca%).pak*" 1>NUL 2>NUL
xcopy /s /y /h /v /j "%_cDestination%\%_cFilename%(%_ca%).pak" "..\..\CreatedModPAKs\%_cFilename%(%_ca%).pak*"

REM Mod pak content required if distinct combined
xcopy /s /y /h /v /j "..\COMBINED_CONTENT_LIST.txt" "..\..\Builds\%_cFilename%(%_ca%).pak_content.txt*" 1>NUL 2>NUL
xcopy /s /y /h /v /j "..\COMBINED_CONTENT_LIST.txt" "..\..\CreatedModPAKs\%_cFilename%(%_ca%).pak_content.txt*"

rem all above code passes thru here
:NEXTSTEP

if %_bCOPYtoNMS%==ALL goto :COPYALLtoNMS
if %_bCOPYtoNMS%==SOME goto :COPYSOMEtoNMS

rem case where %_bCOPYtoNMS%==NONE
goto :ENDIT

:COPYSOMEtoNMS
echo.
REM CHOICE /c:yn /m "%_zRED%??? Would you like to copy the created pak to your game folder and delete [DISABLEMODS.TXT] %_zDEFAULT%"
REM if %ERRORLEVEL% EQU 2 goto :ENDIT
REM CALL :MYCHOICE
CALL ..\MyChoice.bat
if defined _cChoice goto :ENDIT

echo.
echo.^>^>^> Copying this PAK to NMS MOD folder...
echo|set /p="[INFO]: Copied this PAK to NMS MOD folder">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"

rem in case it does not exist
mkdir "%_cNMS_MODS_FOLDER%" 2>NUL

rem enable MODS in NMS
del "%_cNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" 1>NUL 2>NUL

if %_bCOMBINE_MODS% EQU 2 ( goto :CopyCOMBINEDDISTINCTMODS )

xcopy /s /y /h /v /j "..\..\CreatedModPAKs\%_cMOD_FILENAME%" "%_cNMS_MODS_FOLDER%*" 	
xcopy /s /y /h /v /j "..\..\CreatedModPAKs\%_cMOD_FILENAME%_content.txt" "%_cNMS_MODS_FOLDER%*" 	

goto :ENDIT

:CopyCOMBINEDDISTINCTMODS
rem in case it does not exist
mkdir "%_cNMS_MODS_FOLDER%" 2>NUL

rem enable MODS in NMS
del "%_cNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" 1>NUL 2>NUL

xcopy /s /y /h /v /j "..\..\CreatedModPAKs\%_cFilename%(%_ca%).pak" "%_cNMS_MODS_FOLDER%*" 	
xcopy /s /y /h /v /j "..\..\CreatedModPAKs\%_cFilename%(%_ca%).pak_content.txt" "%_cNMS_MODS_FOLDER%*" 	

goto :ENDIT

:COPYALLtoNMS
rem in case it does not exist
mkdir "%_cNMS_MODS_FOLDER%" 2>NUL

rem enable MODS in NMS
del "%_cNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" 1>NUL 2>NUL

mkdir "%_cNMS_MODS_FOLDER%" 2>NUL
del "%_cNMS_PCBANKS_FOLDER%DISABLEMODS.TXT" 1>NUL 2>NUL
xcopy /s /y /h /v /j "..\..\CreatedModPAKs\*.*" "%_cNMS_MODS_FOLDER%*" 	

if %_bNumberPAKs% GTR 0 (
	xcopy /s /y /h /v /j "..\..\ModScript\*.pak" "%_cNMS_MODS_FOLDER%*"
)

if %_bCOMBINE_MODS% EQU 0 (
	echo.
rem	echo.%_zGREEN%^>^>^> Done building ALL scripts%_zDEFAULT%
	echo.%_zGREEN%^>^>^> Copying PAK to NMS MOD folder...%_zDEFAULT%

REM rem	echo|set /p="[INFO]: Done building ALL scripts">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
	REM echo|set /p="[INFO]: Copied PAK to NMS MOD folder...">>"..\..\REPORT.txt" & echo.>>"..\..\REPORT.txt"
	REM echo.>>"..\..\REPORT.txt"
)

echo.-----------------------------------------------------------
:ENDIT	
set _cChoice=

rem ****************************  WE ARE GOING BACK TO MODBUILDER  ****************************
cd ..

goto :eof
rem ---------- WE ARE DONE ---------------------

rem --------------------------------------------
rem subroutine section starts below
:MYCHOICE
	CHOICE /c:yn /m "%_zRED%??? Would you like to copy the created pak to your game folder and delete [DISABLEMODS.TXT] %_zDEFAULT%"
	if %ERRORLEVEL% EQU 2 set _cChoice="N"
	EXIT /B

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

EXIT