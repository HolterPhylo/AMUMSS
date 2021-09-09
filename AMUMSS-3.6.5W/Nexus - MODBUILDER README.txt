Revolutionary No Man's Sky AMUMSS (auto modbuilder-updater with MOD script definition system)
Fully automatic mod builder that automates every step of NMS modding and provides an easy to use lua script mod definition system.
NEXUSMODS: https://www.nexusmods.com/nomanssky/mods/957: https://www.nexusmods.com/nomanssky/mods/957

How to use ?  SEE BELOW
What does this tool do ? SEE BELOW
What are the possibilities for modders ? SEE BELOW
How to Create your own lua mod definition scripts ? SEE BELOW
How to Create a Patch for an existing MOD PAK ? SEE BELOW
How to Distribute you mod script lua definition file ? SEE BELOW
SCRIPT MOD LIST (included), SEE BELOW

IMPORTANT NOTE:

 * This tool works as long as MBINCompiler can compile/decompile the MBIN touched by the scripts

     NOW FOR THE GOOD STUFF! 
[*]            ALWAYS READ THE SCRIPT_RULES.txt FILE
[*]            ALWAYS INSTALL IN A NEW FOLDER (you can copy/paste some folders from the previous version)

NEW in Version 3.6.0W :
[*]IMPROVED: Handling of PAK decompiling and REPORTING
[*]REMOVED: The need for the user to 'Press Any Key...' when some older MBINCompilers are run to decompile a PAK
[*]ADDED: 'NMS PCBANKS Explorer / Unpacker', a tool to UNPACK any files in any pak of NMS PCBANKS to your chosen UNPACK folder

Version 3.5.9W :
[*]GREATLY REWORKED: Script_Rules.txt information
[*]ADDED: 'General Information on AMUMSS.txt' to answer many questions...
[*]BEWARE: The order of some of the starting questions has changed before processing begin.
[*]ADDED: AMUMSS, when trying to unpack/decompile a pak, will try to find the right MBINCompiler
	when a MBIN file is NOT showing any version info, starting from most recent to older versions.
	In other words, it will (most probably) even decompile MBINs that were modified by hand.
	(Note: some old MBINCompiler will require you to 'Press any key to continue...', you will be notified if this happens)
[*]CHANGE: AMUMSS will no longer ask if you want to update MBINCompiler, it will decide by itself...
[*]ADDED: File 'OPT_CustomMBINCompiler.txt', if present in AMUMSS main folder, 
	prevents AMUMSS from updating to the latest version of MBINCompiler.exe and
	use the current MBINCompiler.exe in MODBUILDER
[*]ADDED: File 'OPT_SKIP_USER_PAUSE.txt', if present in AMUMSS main folder, 
	instructs AMUMSS to skip a pause before processing begins to allow users to read some information
[*]ADDED: File 'OPT_SKIP_SERIALIZING.txt', if present in AMUMSS main folder, 
	instructs AMUMSS to skip the creation of the SerializedScript.lua file
	after the User script is loaded but before processing begins,
	thus reducing the time needed to start executing scripts.
[*]CHANGE: The maximum length of a pak filename (including .pak) is now set at 110 characters (limited by NMS)
	Thanks Lo2k for feedback.
[*]IMPROVED: Reporting of Multi-pak scripts processing
[*]New WARNING: When EXML_CHANGE_TABLE is a 'string' instead of a 'table'

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
5. Answer a few questions and the tool will do its processing, let it finish (review the REPORT.txt file if necessary)
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
	See the file 'Creating a Patch for existing MOD PAKs.txt'
	
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

Main changes in Previous Versions : 
[*]One or more PAK can be unpacked and decompiled automatically
	AMUMSS will use the right version of MBINCompiler, if it cannot use the current one
	Just put one or more PAK (old and new) in ModScript and execute BuildMod.bat
	Under folder 'UNPACKED_DECOMPILED_PAKs', AMUMSS will create a new folder for each PAK
	with the unpack MBINs, decompiled EXMLs and any other files in the pak
[*]AUGMENTED BEHAVIOR: - ALTERNATE USE of PRECEDING_KEY_WORDS:
	when using SPECIAL_KEY_WORDS, you can use multiple PRECEDING_KEY_WORDS to further refine
	the sub-section to look for inside the SECTION defined by the SPECIAL_KEY_WORDS.
	
	If these PRECEDING_KEY_WORDS are not found inside the SECTION then
		the last PRECEDING_KEY_WORDS will be used to try locate a line inside that SECTION.
		This single PRECEDING_KEY_WORDS can be any name or value inside that SECTION (much better if UNIQUE in that SECTION)
		(see MiningLaserSpeed.lua or Multi_PAK_Multi_MBIN_Example_Mod.lua for example)

	If the single "preceding_key_word" word is not found in that SECTION, the whole SECTION will be used
[*]REGEX search/replace operation on the EXML involved BEFORE and/or AFTER script processing
[*]You can check conflicts in the MODS folder (still at the MBIN file level) by just running the tool
     Even if you don't have any script in ModScript folder
[*]Using the script MapFileTree_UPDATER.lua, you can create all the MapFileTrees you want...
     By default, the script is already preloaded with all the "GLOBALS".  
	 Just add / remove any MBIN you are interested in from the list and process the script.
	 Remember that MapFileTree files are automatically created / updated each time you run a script
[*]Added MapFileTree file automatic creation in MapFileTrees folder which can GREATLY help a modder find the right 
   SPECIAL_KEY_WORDS and PRECEDING_KEY_WORDS as well as understand the structure of an EXML
	
	Here is a Sample:
      MapFileTree: METADATA\SIMULATION\ECOSYSTEM\ROLEDESCRIPTIONTABLES\AIR\AIRTABLECOMMON.EXML
         LINE   LEVEL
      [       3] [ 0]["GcCreatureRoleDescriptionTable"]
      [       4] [ 1]  ["RoleDescription"]
      [       5] [ 2]    ["GcCreatureRoleDescription.xml"]
      [       6] [ 3]      ["CreatureRole"]
      [       7] [ 4]        [SPECIALNAME: {"CreatureRole","Bird"},]
      [       9] [ 3]      ["CreatureType"]
      [      10] [ 4]        [SPECIALNAME: {"CreatureType","None"},]
      [      24] [ 2]    ["GcCreatureRoleDescription.xml"]
      [      25] [ 3]      ["CreatureRole"]
      [      26] [ 4]        [SPECIALNAME: {"CreatureRole","Bird"},]
      [      28] [ 3]      ["CreatureType"]
      [      29] [ 4]        [SPECIALNAME: {"CreatureType","None"},]
      [      46] [ 1]  ["TileType"]
      [      47] [ 2]    [SPECIALNAME: {"TileType","Base"},]
      [      49] [ 1]  ["LifeLevel"]
      [      50] [ 2]    [SPECIALNAME: {"LifeSetting","Dead"},]
      [      52] [ 0][/Data]

[*]Saving a pakname_content.txt file with the created pak when a COMBINED MOD is created
   The content file is also copied to MODS along with the pak when the user request it (thanks Lo2k for suggestion)
[*]ModExtraFilesToInclude folder where you, the modder, can put ANY extra files to be INCLUDED in the created PAK
[*]EXML_Helper folder containing copies of the original and modified files so modders can view and compare the EXML files during script development
[*]To start developping a NEW script for a mod, just fill-in the "MOD_FILENAME", "PAK_FILE_SOURCE" and "MBIN_FILE_SOURCE" fields
   using the script "TEMPLATE.lua" in ModScriptCollection\LearningExamples
[*]The tool generates NMS_pak_list.txtPretty.lua containing ALL file names content of the paks in the NMS PCBANKS folder
[*]NMS MODS paks Conflict Detection at the file level in the generated REPORT.txt file
   so you can see which of the scripts AND paks in MODS need to be combined with others.   
[*]Lua script themselves are saved in the generated paks for reference.
[*]An example script showing the use of For-Loops in the scripts.  See ADD_REMOVE_FORLOOP_usage-Recipes.lua
   in the ModScriptCollection\LearningExamples\Advanced folder.

Many thanks to monkeyman192 for his huge efforts toward the NMS community and his work on the MBIN compiler.
Many thanks to Wbertro (aka TheBossBoy) for much further improvements.
Many thanks to current collaborators: Lo2k, Gumsk, Ignacio, Entoarox on Discord
Many thanks to clampi, Erikin84, Fuklebark, Marbrook, petrik, Seekker and many others for bug reporting, further improvements and for sharing scripts.

Original idea by Mjjstral aka MetaIdea
Copyright MIT license
Contact: MetaIdea7@gmail.com or Wbertro@gmail.com