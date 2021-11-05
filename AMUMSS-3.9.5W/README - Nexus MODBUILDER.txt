IMPORTANT NOTES:
This tool works as long as MBINCompiler can compile/decompile the MBIN touched by the scripts
NEW version does requires .NET 5 Desktop to be installed (MBINCompiler.exe requirement)
Note: Sometimes, your anti-virus may detect some component of AMUMSS and block/quarantine it.
  Be assure it is not a virus but its behavior may be interpreted as such by some anti-virus.
  Please make sure to create an exception in your anti-virus when this happens.
  Also a reboot may be required as some anti-virus do not correctly register the exception when created.

Always use NexusMODS for the latest version: https://www.nexusmods.com/nomanssky/mods/957

-> AMUMSS LUA MOD SCRIPT ARCHIVE? <-

UPDATE: NMSPE (NMS PCBANKS Explorer) is now UPDATED to v.2.0.1.1 BETA
If the Nexus file is still in 'quarantine', you can go to Discord's "No Man's Sky Modding" channel and look into the pins of the #mod-amumss room!
   (Download the latest pinned NMSPE and place into AMUMSS folder (replacing the one there).
          Make sure you have 'Unblocked' the file in its properties if you are on Windows.)

Revolutionary No Man's Sky AMUMSS (auto modbuilder-updater with MOD script definition system)
Fully automatic mod builder that automates every step of NMS modding and provides an easy to use lua script mod definition system.
NEXUSMODS: https://www.nexusmods.com/nomanssky/mods/957

How to use ?  SEE BELOW
What does this tool do ? SEE BELOW
What are the possibilities for modders ? SEE BELOW
How to Create your own lua mod definition scripts ? SEE BELOW
How to Create a Patch for an existing MOD PAK ? SEE BELOW
How to Distribute you mod script lua definition file ? SEE BELOW
SCRIPT MOD LIST (included), SEE BELOW

NOW FOR THE GOOD STUFF!
	[*] ALWAYS READ THE 'SCRIPT_RULES.txt' FILE

[*]Installation:
   * De-compress the zip file to its own folder (like C:\AMUMSS)
     Making the path to AMUMSS main folder short helps prevent bumping against windows path length limit (in rare cases)	 
   * No accented or special characters in the path
   * Always de-compress in a new folder on any drive, never in any system or game folder
   * Since AMUMSS queries the internet for MBINCompiler updates, you may have to create
      an exception in your security to allow \MODBUILDER\MBINCompilerDownloader\curl.exe to access it
   * If the cmd windows closes immediately (or is blank) when double-clicking BUILDMOD.BAT:
      it could be your internet security is blocking it (try creating an exception and reboot),
      or it could be you are on windows 7.  Try renaming 'OPT_Colors_ON.txt' to 'xOPT_Colors_ON.txt'
   * You can copy/paste these folders from the previous version of AMUMSS
      if you would like to preserve previous work...
            + 'ModScript'
            + 'ModExtraFilesToInclude'
            + 'Builds'
            + 'SavedSections'
            + 'UNPACKED_DECOMPILED_PAKs'

NEW in Version 3.9.5.1W:
[*]IMPROVED: detection/reporting of INTEGER_TO_FLOAT conversion
[*]REMOVED: false-positive detection of FLOAT that are in fact INTEGER
[*]CORRECTED: false-positive NOTICE that PRECEDING_KEY_WORDS found multiple sections
[*]ADDED: reporting of failed scripts at end of REPORT.lua
[*]ADDED: to *.pak_content.txt file when such a file is created
		Original information:
		   MOD FILENAME: ThisMaster.pak
			 MOD AUTHOR: Ignacio
			 LUA AUTHOR: Unknown
		MOD DESCRIPTION: is the original requester for this added information
			NMS VERSION: 3+
[*]IMPROVED: 'REPORT.txt' renamed to 'REPORT.lua' with collapsable sections for each script processed and the Conflict section
[*]CORRECTED: using LINE_OFFSET, the wrong keyword line was used as the base line when PRECEDING_KEY_WORDS were used after SPECIAL_KEY_WORDS
[*]CORRECTED: using ["ADD_OPTION"] = "ADDafterLINE", the found line was never used

Version 3.9.4W:
[*]CORRECTED: no created pak after using one pak and one lua to make a patch
[*]CORRECTED: stopped creation of empty folders in UNPACKED_DECOMPILED_PAKs\pakname
[*]CORRECTED: bug that prevented a patch to have the original changes of the pak when making a patch mod
[*]ADDED: GLOBAL_INTEGER_TO_FLOAT, see 'README - Script_Rules.txt' for usage
[*]ADDED: anything in 'ModScript\Disabled scripts and paks' folder is DISABLED

Version 3.9.3W:
[*]CORRECTED: handling of MapFileTree FORCED re-creation
[*]UPDATED: MapFileTree format (MapFileTree files will reset to new format)
[*]ADDED: OPTION -IndividualModPakType: 'PLAIN or P' --(default) Name of Mod pak is MOD_FILENAME
	or 'DATETIME or D' --Name of Mod pak is MOD_FILENAME + current DATE-TIME suffix
[*]UPDATED: 'README - OPTIONS DEFINITIONS.txt'
[*]IMPROVED: BUILDMOD_AUTO.bat, easier setup of OPTIONS
[*]IMPROVED: NO mod pak creation when there is 'nothing' to pak (ex.: no more pak with only the lua script!)
[*]ADDED: OPTION to ONLY check for conflicts in MODS (no script processing done)
[*]ADDED: OPTION to never check for Conflicts
[*]CORRECTED: NMSPE would overwrite user configuration of BUILDMOD_AUTO.bat

Version 3.9.2W:
[*]CORRECTED: bug when using "ADD" (thanks Discord@PuffedSmoke for reporting)
[*]CORRECTED: script 'LearnMoreWords.lua'
[*]ADDED: 'ModScript\Disabled scripts and paks' folder where you can move scripts and paks that you do  not want to currently process
[*]UPDATED: 'What to do when NMS is updated.txt' with current AMUMSS usage

Version 3.9.1W :
[*]USER OPTIONS: Only change 'BUILDMOD_AUTO.bat' (NOT BUILDMOD.bat as it can be overwritten)
[*]USER OPTIONS: found in BUILDMOD_AUTO.bat are preserved when unzipping AMUMSS update to previous version folder
[*]ADDED: file 'README - OPTIONS DEFINITIONS.txt' in main folder
[*]CORRECTED: auto detection of NMS folder path on GOG (hopefully)
[*]CORRECTED: missing 'ASK' question in one instance where there are many Conflict files to process
[*]CORRECTED: rare bug where a NMS MBIN could not be found
[*]CORRECTED: switched type of mod in OPTIONS Definitions

Version 3.9.0W :
[*]AUTO-HANDLING of MBINCompiler.exe version required by 'Public' or 'Experimental',
	no more need to use 'OPT_CustomMBINCompiler.txt' unless you are using an older version of NMS files
[*]CHANGED: AMUMSS will automatically check and ask before updating to the latest version of MBINCompiler.exe 
[*]REMOVED: File 'xOPT_CustomMBINCompiler.txt' - depricated due to above change
[*]OPTIMIZED: Conflicts detection speed x10
[*]ADDED: AMUMSS will now decompile MBIN files to ModScript\EXMLFILES_PAK when put in ModScript
[*]ADDED: Handling of .EXML files in MBIN_FILE_SOURCE (reading them as .MBIN instead)
[*]ADDED: Decompiled PAK and MBIN files will have the current EXML files in ModScript\EXMLFILES_CURRENT
	to help modders in comparing with the current version of EXMLs
[*]ADDED: WARNING when VALUE_CHANGE_TABLE looks like a malformed table of tables
[*]ADDED: Renaming of EXTERNAL_FILE_SOURCE using FILE_DESTINATION (path+filename) in ADD_FILES (see README - Script_Rules.txt))
[*]ADDED: REPLACE_TYPE option ADDafterLINE to ADD text after the current LINE (default behavior)
[*]ADDED: REPLACE_TYPE option ADDatLINE to ADD text at the current LINE and automatically overwriting it (no need to REMOVE the line)
[*]REMOVED: WARNING about files not being from NMS PCBANKS paks when already in MODBUILDER\MOD folder
[*]UPDATED: EXTERNAL_FILE_SOURCE can now be a 'full path' or a path 'relative' to the ModScript folder in ADD_FILES (see README - Script_Rules.txt))
[*]UPDATED: MODBUILDER\Extras\MBINCompiler_OldVersions folder
[*]UPDATED: Lines with a value like a filename (???.MBIN or ???.xml for example) are now accepted as SPECIAL_KEY_WORDS
[*]UPDATED: Lines with a value like 'True', 'False' or a number are now accepted as SPECIAL_KEY_WORDS
	Note: These types SHOULD be used with EXTREME CAUTION, HG could easily change the value!!!
[*]UPDATED: 'NMSPE' (NMS PCBANKS Explorer / Unpacker), a tool to UNPACK any file in any pak of NMS PCBANKS to your chosen UNPACK folder AND browser of libMBIN.dll
[*]ADDED: NOTE about path to AMUMSS folder that should not 'feature' accented characters.  They should be REMOVED for proper operation
	Best practice is to use an AMUMSS folder like X:\AMUMSS
[*]IMPROVED: Handling of failure to clean some working folders: providing feedback to the user instead of becoming unresponsive
[*]ADDED: Option to append MOD_AUTHOR at end of pak file (when MOD_AUTHOR starts with a '+') (Gumsk's request)
[*]ADDED: LUA_AUTHOR (no other use then specifying who created the script)
[*]ADDED: Handling of AMUMSS folder path containing "()" and "+"
[*]ADDED: Handling of 'long' mod path
[*]EXCLUDED: .txt files from Conflict Reporting
[*]ADDED: file '_DateTimeFormat.txt' in AMUMSS main folder to allow re-defining DateTime formatting
	Note: that the DateTime format will be 'sanitized' when used in a file name as per Windows convention!
[*]CHANGED: Some 'WARNING's are now 'NOTICE's

This tool can unpack/decompile current and older mods ?
   Put the pak in the ModScript folder and execute BuildmOd.bat

What does this tool do ?
1. Downloads the latest MBINCompiler from github (needs Internet connection)
2. Reads especially made mod script lua files (NMS version independent modding)
3. Extracts the necessary .pak files from your NMS game folder
4. Decompiles the needed MBIN files to EXML files
5. Applies the changes defined in the lua mod script files to the decompiled .exml files 
6. Compresses the .exml files back to .pak (all *.MBIN,*.BIN,*.H,*.DDS,*.PC,*.WEM,*.TTF,*.TTC,*.TXT,*.XML files)
7. Copies the mods to: A) NMS mods folder (optional), B) CreatedModPAKs folder of this tool and C) Builds folder 
8. Creates incremental builds in numbered order in Builds/IncrementalBuilds
9. Check for conflicts between Scripts that modify the same files and reports findings so you can choose to combine them 
    if you want to get the full effect of each script/mod 

How to use:
0. Unzip download into a folder like C:\AMUMSS (not under any OS controlled folder)
1. Choose/Copy a script from the ModScriptCollection folder or from anywhere else or create one yourself
2. Paste it into the ModScript folder
3. Start (double-click) BuildMod.bat
4. If asked, put your No Man's Sky game folder path into NMS_FOLDER.txt, otherwise the tool will find the game files
5. Answer a few questions and the tool will do its processing, let it finish (review the REPORT.lua file if necessary)
6. Copy the mod that gets created in the CreatedModPAKs folder to your game folder if you haven't made that choice at the start of processing
    Note: You can combine multiple mods and even make PATCH mods (see below on how to do this)

What are the possibilities for modders ?
     See the learning examples and the Script Rules explained in the file Script_Rules.txt included.
You have many convenient ways to change, replace or add/remove values or code. E.g. you can multiply all values of a certain type with ease,
replace all values that match a certain type or value and much more. You can also add code, add new files either by defining the code
in the lua script file itself or by external source.

How to Create your own lua mod definition scripts ?
	Look at the scripts in the ModScriptCollection and LearningExamples + Commented folders.
Just copy one of them and adapt it for your mod.  Note multiple {...} entries need to be separated with a comma.
     +++++  Script Rules are explained in the file Script_Rules.txt included  +++++
For mods that depend on multiple pak sources and MBINs see Multi_PAK_Multi_MBIN_Example_Mod.lua to see how to do the correct nesting.
The real revolution is the mod script lua definition system that enables every modder to easily convert their mods to these scripts and 
finally become mostly independent of manual mod updates.

How to Create a Patch for an existing MOD PAK ?
	See the file 'README - Creating a Patch for existing MOD PAKs.txt'
	
How to Distribute your mod script lua definition file ?
0. Just create a mod from your .lua script, it is automatically included
1. or Upload it plain to nexusmods with a link to a download
2. or Upload your mod into the NMS modding discord server (mod releases 
    channel or mod discussion), mention @Mjjstral if you want that I add it 
    to the project for future releases
3. or Post a link to the commentary section on nexus

SCRIPT MOD LIST: You can find over 80 .lua scripts in 'ModScriptCollection' included with AMUMSS
(Note: Some Mods here are for demonstration purposes only, they may require changes to values or even logic of what is changed.
            But most are perfectly functional.  Test them on a new save when in doubt!)

[*]One or more PAK can be unpacked and decompiled automatically
	AMUMSS will use the right version of MBINCompiler, if it cannot use the current one
	Just put one or more PAK (old and new) in ModScript and execute BuildMod.bat
	Under folder 'UNPACKED_DECOMPILED_PAKs', AMUMSS will create a new folder for each PAK
	with the unpack MBINs, decompiled EXMLs and any other files in the pak

[*]REGEX search/replace operation on the EXML involved BEFORE and/or AFTER script processing

[*]You can check conflicts in the MODS folder (still at the MBIN file level) by just running the tool
     Even if you don't have any script in ModScript folder

[*]Using the script MapFileTree_UPDATER.lua, you can create all the MapFileTrees you want...
     By default, the script is already preloaded with all the "GLOBALS".  
	 Just add / remove any MBIN you are interested in from the list and process the script.
	 Remember that MapFileTree files are automatically created / updated each time you run a script

[*]MapFileTree file are automaticaly created in MapFileTrees folder which can GREATLY help a modder find the right 
   SPECIAL_KEY_WORDS and PRECEDING_KEY_WORDS as well as understand the structure of an EXML
	
	Here is a Sample:
		 TYPE = 'P'receding, 'S'pecial, 'U'nique
		 TYPE:FILELINE:LEVEL     KEYWORDS
		{[   :       3: 0]GcNGuiLayerData --Do not use, NOT a KEYWORD
		{[PS :       4: 1]  "ElementData" / {"ElementData","GcNGuiElementData.xml",},
		 [ SU:       5: 2]  | {"ID","TABTITLE",},
		 [ S :       7: 2]  | {"IsHidden","False",},
		{[PS :       8: 2]  | "Layout" / {"Layout","GcNGuiLayoutData.xml",},
		 [ SU:       9: 3]  | | {"PositionX","-150.79997",},
		 [ SU:      10: 3]  | | {"PositionY","-5",},
		 [ SU:      11: 3]  | | {"Width","100",},
		 [ SU:      12: 3]  | | {"WidthPercentage","True",},
		 [ S :      13: 3]  | | {"Height","100",},
		 [ S :      14: 3]  | | {"HeightPercentage","True",},

[*]Saving a pakname_content.txt file with the created pak when a COMBINED MOD is created
   The content file is also copied to MODS along with the pak when the user request it (thanks Lo2k for suggestion)
[*]ModExtraFilesToInclude folder where you, the modder, can put ANY extra files to be INCLUDED in the created PAK
[*]EXML_Helper folder containing copies of the original and modified files so modders can view and compare the EXML files during script development
[*]To start developping a NEW script for a mod, just fill-in the "MOD_FILENAME", "PAK_FILE_SOURCE" and "MBIN_FILE_SOURCE" fields
   using the script "TEMPLATE.lua" in ModScriptCollection\LearningExamples
[*]The tool generates NMS_pak_list.txtPretty.lua containing ALL file names content of the paks in the NMS PCBANKS folder
[*]NMS MODS paks Conflict Detection at the file level in the generated REPORT.lua file
   so you can see which of the scripts AND paks in MODS need to be combined with others.   
[*]Lua script themselves are saved in the generated paks for reference.
[*]An example script showing the use of For-Loops in the scripts.  See ADD_REMOVE_FORLOOP_usage-Recipes.lua
   in the ModScriptCollection\LearningExamples\Advanced folder.

Many thanks to monkeyman192 for his huge efforts toward the NMS community and his work on the MBIN compiler.
Many thanks to Wbertro (aka TheBossBoy) for much further improvements.
Many thanks to current collaborators: Lo2k, Gumsk, Ignacio, Entoarox and others on Discord
Many thanks to clampi, Erikin84, Fuklebark, Marbrook, petrik, Seekker and many others for bug reporting, further improvements and for sharing scripts.

Original idea by Mjjstral (aka MetaIdea)
Further ideas by Wbertro (aka TheBossBoy)
Copyright MIT license
Contact: MetaIdea7@gmail.com or Wbertro@gmail.com