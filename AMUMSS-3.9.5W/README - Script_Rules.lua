{***************************  'Script_Rules.txt Content'  ***************************************
	- Script Members Description
	- Advanced Script Rules / Tips
	- DEPRICATED (do not use)

	- See 'README - General Information on AMUMSS.txt' for more information about AMUMSS
	
	- NOTE: we are using LUA 5.3
		Can be used in the script:
			- All the standard lua syntax (section 3 of https://www.lua.org/manual/5.3/),
			- All available standard functions in {string, math, table}
			- Also io.open, io.input, io.type, io.read, io.lines and io.close
			- And os.clock, os.date, os.difftime, os.getenv, os.time, os.tmpname
			- Plus {assert, pairs, ipairs, print, tonumber, tostring, type}

	- Some definitions/comments:
		- in this document, "==" means: "is equal to"
		- EXML files are closely related to XML files but are not the same
		- the TOP level is always <Data template="something"> AND this value is NOT used by the tool
		- Each level ends with </Property> except the TOP level which ends with </Data>
		- Every new level (SECTION) starts with a line ending in [">] (never with a line ending in [" />])
		- a SECTION is defined as "all the lines" from the beginning [">] to the ending </Property> line
			(so a SECTION is at least 3 lines long)
		- a SECTION can have one or more sub-SECTIONs

	- Generally using the "ModScriptCollection\LearningExamples\StandardSchemeExtended.lua" script
		in the ModScriptCollection\LearningExamples folder as an example.
}

***************************  'Script Members Description'  ****************************

{Simplified hierarchy of the 'NMS_MOD_DEFINITION_CONTAINER':

		NMS_MOD_DEFINITION_CONTAINER
			MOD_FILENAME
			MOD_AUTHOR
			LUA_AUTHOR
			MOD_DESCRIPTION
			NMS_VERSION
			MOD_BATCHNAME
			GLOBAL_INTEGER_TO_FLOAT
			ADD_FILES
				FILE_DESTINATION
				EXTERNAL_FILE_SOURCE
				FILE_CONTENT
			MODIFICATIONS
				MBIN_CHANGE_TABLE
					MBIN_FILE_SOURCE
					REGEXBEFORE
					REGEXAFTER
					EXML_CHANGE_TABLE
						SPECIAL_KEY_WORDS
						SECTION_UP_SPECIAL
						PRECEDING_FIRST
						PRECEDING_KEY_WORDS
						SECTION_UP
						SECTION_ACTIVE
						WHERE_IN_SECTION
						WHERE_IN_SUBSECTION
						SAVE_SECTION_TO
						KEEP_SECTION
						ADD_NAMED_SECTION
						EDIT_SECTION
						MATH_OPERATION
						INTEGER_TO_FLOAT
						REPLACE_TYPE
						VALUE_MATCH
						VALUE_MATCH_TYPE
						LINE_OFFSET
						VALUE_CHANGE_TABLE
						FOREACH_SPECIAL_KEY_WORDS
						ADD_OPTION
						ADD
						REMOVE
}
						
{   >>> 'NMS_MOD_DEFINITION_CONTAINER':
	- Always REQUIRED
	- a table containing one or many tables
	- The Master Table (it defines the script that will be processed by this tool)
	- the order of members is not important
	- members of NMS_MOD_DEFINITION_CONTAINER are:
      - MOD_FILENAME		              REQUIRED	- a STRING
      - MOD_AUTHOR		                OPTIONAL	- a STRING
      - LUA_AUTHOR		                OPTIONAL	- a STRING
      - MOD_DESCRIPTION	              OPTIONAL	- a STRING
      - NMS_VERSION		                OPTIONAL	- a STRING
NEW		- MOD_BATCHNAME		              OPTIONAL	- a STRING
NEW		- GLOBAL_INTEGER_TO_FLOAT       OPTIONAL	- a STRING
      - ADD_FILES			          see below	- a table
      - MODIFICATIONS		        see below	- a table containing one or many tables
}

{   >>> 'MOD_FILENAME':
	- Always REQUIRED
	- if MOD_FILENAME is not found, it will default to 'GENERIC.pak' and a WARNING will be issued
	- a member of NMS_MOD_DEFINITION_CONTAINER
	- a STRING, the name of the pak file created by the tool
		ex.: 	["MOD_FILENAME"] 		= "some.pak",
		(unless a combined mod is created, then the name may not be used)
	- maximum name length is 106 char + .pak
}}

{   >>> 'MOD_AUTHOR, LUA_AUTHOR, MOD_DESCRIPTION and NMS_VERSION':
	- These members are all OPTIONAL
	- members of NMS_MOD_DEFINITION_CONTAINER
	- a STRING
		ex.: 	["MOD_AUTHOR"] 			= "ItIsMe",
				["LUA_AUTHOR"] 			= "OrMe",
				["MOD_DESCRIPTION"]		= "anything goes",
				["NMS_VERSION"]			= "1.77",
	- Used for reference only
}

{   >>> 'MOD_BATCHNAME':
	- is OPTIONAL
NEW	- it supersedes the standard AMUMSS name when more than one .lua scripts are present
	- if MOD_BATCHNAME is not found, it will default to AMUMSS name generation
	- a member of NMS_MOD_DEFINITION_CONTAINER
	- a STRING, the name of the pak file created by the tool
		ex.: 	["MOD_BATCHNAME"] 		= "someBatchName.pak",
	- maximum name length is 106 char + .pak
}}

{   >>> 'GLOBAL_INTEGER_TO_FLOAT':
	- is OPTIONAL
	- is a member of NMS_MOD_DEFINITION_CONTAINER
	- a STRING

	***** USE 'GLOBAL_INTEGER_TO_FLOAT' ONLY if you know that changing all INTEGERs to FLOAT is right
		when the math operation results in a FLOAT
	
	- Note: INTEGER_TO_FLOAT will supersede GLOBAL_INTEGER_TO_FLOAT if present

	- WARNING: even if you use this option to silence the AMUMSS WARNING/NOTICE's, MBINCompiler may still refuse
		to compile the EXML when the underlying value is 'really' an INTEGER.

	- [WARNING] ORIGINAL and NEW number value have mismatched types (INTEGER vs FLOAT or STRING vs NUMBER)
		You may see this WARNING in the REPORT. 
		This WARNING only tells you that the script is changing an INTEGER "0" to a FLOAT "0.75"
			or a STRING to a NUMBER or a NUMBER to a STRING.
		If the EXML compiles fines with MBINCompiler then it is alright, 
			otherwise it may be the case why MBINCompiler fails to compile the EXML.  
		So it is an AID to you in finding a possible problem.
	
	- can have one of these values: {nil, "", "FORCE", "PRESERVE"}
	- default value is ""
	- ["GLOBAL_INTEGER_TO_FLOAT"] = "FORCE", will change the INTEGER value to a FLOAT if necessary
	- ["GLOBAL_INTEGER_TO_FLOAT"] = "PRESERVE", will keep the same type of value as before the operation
		and hide: "WARNING: ORIGINAL value below is INTEGER." 
		>> A FLOAT will still be a FLOAT
		>> An INTEGER will still be an INTEGER (rounding up the value if necessary)	
}}}}}}

{   >>> 'MODIFICATIONS':
	- a member of NMS_MOD_DEFINITION_CONTAINER
	- a table containing one or many tables
	- can be used with or without ADD_FILES
	- is OPTIONAL when ADD_FILES is used

	- the order of members is not important
	- members of MODIFICATIONS are:
		- PAK_FILE_SOURCE	OPTIONAL and NO LONGER REQUIRED
		- MBIN_CHANGE_TABLE	REQUIRED	- a table or many tables
}

{   >>> 'PAK_FILE_SOURCE':
	*** OBSOLETE - DEPRICATED
	- IS NO LONGER REQUIRED
	- a member of MODIFICATIONS
	- (VERY OPTIONAL NOW) the NMS PAK "path and name" involved as a STRING
	- always an original name from the NMS/PCBANKS folder
	- the PAK_FILE_SOURCE "path and name" will be provided (and displayed) by this tool
}

{   >>> 'MBIN_CHANGE_TABLE':
	- a member of MODIFICATIONS
	- a table of MBIN_FILE_SOURCE(s) and EXML_CHANGE_TABLE(s)
		to apply to the MBIN_FILE_SOURCE file(s)

	- the order of members is not important
	- members of MBIN_CHANGE_TABLE are:
		- MBIN_FILE_SOURCE	REQUIRED	  - string or table or table of tables
		- REGEXBEFORE		OPTIONAL	      - table of (two STRINGs)table(s)
		- EXML_CHANGE_TABLE	REQUIRED	  - table of table(s) and STRINGs
		- REGEXAFTER		OPTIONAL	      - table of (two STRINGs)table(s)
}

{   >>> 'MBIN_FILE_SOURCE':
	- is REQUIRED
	- is a member of MBIN_CHANGE_TABLE
	- alternate syntax #1: a NMS MBIN path STRING, as in [[METADATA\SIMULATION\SCENE\EXPERIENCESPAWNTABLE.MBIN]],
		- used to work on this one file

	- alternate syntax #2: a table of NMS MBIN path STRINGS,
		- as in {
				[[METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENHQOBJECTSFULL.MBIN]],
				[[METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENOBJECTSDEAD.MBIN]],
				[[METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENOBJECTSFULL.MBIN]],
				...
			  },
		- used to work on all those files from top to bottom

	- alternate syntax #3: a table of tables of NMS_MBIN_PATH_FILENAMES STRINGS and NEW_PATH_FILENAMES STRINGS
		see NEW_PathFilename.lua for an example of use,
		as in {
				{[[METADATA\SIMULATION\SOLARSYSTEM\BIOMES\PLACEMENTVALUES\SPAWNDENSITYLIST.MBIN]], [[NEWPATH\temp1\temp2\My.GLOBALS.MBIN]], Optional_Flag},
				...
			  },
		- this allows you to create a new MBIN file (My.GLOBALS.MBIN) in any folder you like (NEWPATH\temp1\temp2\)
		BASED on an original NMS pak file (SPAWNDENSITYLIST.MBIN)

		Note #1: The create/rename part happens before processing the whole MBIN_FILE_SOURCE section
			- the My.GLOBALS.MBIN file will be identical to the original SPAWNDENSITYLIST.MBIN file
			- the SPAWNDENSITYLIST.MBIN file will be modified by the content of the enclosed EXML_CHANGE_TABLE
			- if you want to modify the new My.GLOBALS.MBIN file, you need to add a new section in MBIN_CHANGE_TABLE
			  with MBIN_FILE_SOURCE now referencing the new My.GLOBALS.MBIN file (see NEW_PathFilename.lua for an example of use)

		Note #2: Optional_Flag can be omitted or ""
			- if Optional_Flag is "REMOVE" then the original file ..\SPAWNDENSITYLIST.MBIN will NOT be included in the mod pak
}}}

{   >>> 'REGEXBEFORE':
	- is OPTIONAL
	- is a member of MBIN_CHANGE_TABLE
	- is a table of (two STRINGs)table(s)
	- if use, will invoque a regex utility to process the EXML file BEFORE any script processing
	- the table is of the form {{"ToFindRegex","ToReplaceRegex"},...},
		ex.: ["REGEXBEFORE"] =
						{
							{[[((.*Unknown.*)(True))]],[[\2False]]},
							...
						},
	- sed regex rules apply (see https://www.gnu.org/software/sed/)
}}

{   >>> 'REGEXAFTER':
	- is OPTIONAL
	- same as REGEXBEFORE, see above
	- if use, will invoque a regex utility to process the EXML file AFTER script processing
	- the table is of the form {{"ToFindRegex","ToReplaceRegex"},...},
		ex.: ["REGEXAFTER"] =
						{
							{[[((.*Unknown.*)(True))]],[[\2False]]},
							...
						},
	- sed regex rules apply (see https://www.gnu.org/software/sed/)
}}

{   >>> 'EXML_CHANGE_TABLE':
	- is REQUIRED (except in very rare occasions, see MapFileTree_UPDATER.lua)
	- is a member of MBIN_CHANGE_TABLE
	- a TABLE of tables containing some/all of the following members (table(s) and STRINGs)

	- the order of members inside the sub-table is not important
	- members of EXML_CHANGE_TABLE tables are:
		- SPECIAL_KEY_WORDS			  OPTIONAL	- a TABLE of (one or multiple) two STRINGs
NEW		- SECTION_UP_SPECIAL          OPTIONAL	- a number
		- PRECEDING_FIRST       	  OPTIONAL	- a STRING
		- PRECEDING_KEY_WORDS		  OPTIONAL	- a STRING or (TABLE of STRINGs)
NOT USED		- FIND_ALL_SECTIONS			OPTIONAL	- a STRING
	*	- SECTION_UP            	  OPTIONAL	- a number
NEW	*	- SECTION_ACTIVE        	  OPTIONAL	- a TABLE of NUMBERs
	*	- WHERE_IN_SECTION      	  OPTIONAL	- a TABLE of (two STRINGs) table(s)
NEW	*	- WHERE_IN_SUBSECTION   	  OPTIONAL	- a TABLE of (two STRINGs) table(s)
NEW		- SAVE_SECTION_TO			  OPTIONAL	- a STRING
NEW		- KEEP_SECTION		 		  OPTIONAL	- a STRING
NEW		- ADD_NAMED_SECTION   		  OPTIONAL	- a STRING
NEW		- EDIT_SECTION   			  OPTIONAL	- a STRING
		- MATH_OPERATION			  OPTIONAL	- a STRING
		- INTEGER_TO_FLOAT			  OPTIONAL	- a STRING
		- REPLACE_TYPE				  OPTIONAL	- a STRING
		- VALUE_MATCH				  OPTIONAL	- a STRING
		- VALUE_MATCH_TYPE			  OPTIONAL	- a STRING
		- LINE_OFFSET				  OPTIONAL	- a STRING
		- VALUE_CHANGE_TABLE		  OPTIONAL	- a table of (two STRINGs)table(s)
		- FOREACH_SPECIAL_KEY_WORDS	  OPTIONAL	- a table of (two STRINGs)table(s)
NEW		- ADD_OPTION				  OPTIONAL	- a STRING
		- ADD						  OPTIONAL	- a STRING or [[long multi-line string]]
		- REMOVE					  OPTIONAL	- a STRING
}

{   >>> 'SPECIAL_KEY_WORDS':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a TABLE of (one or multiple) two STRINGs
	- "", or {}, or {"",}, have no effect ==> all these mean: no SPECIAL_KEY_WORDS to search (the whole file is used if nothing else selects a section)
			ex.: ["SPECIAL_KEY_WORDS"] = {"PropertyName1","value1","PropertyName2","value2",...},
			
	- {"Propertyname1","value1",}, ==> SPECIAL_KEY_WORDS pair #1
		that will be used (optionally with the PRECEDING_KEY_WORDS) to help define the SECTION
		we are looking for
	- One or more pairs can be used of the form {"Propertyname1","value1","Propertyname2","value2",...},
	- "Propertyname1","value1" defined a SECTION then "Propertyname2","value2" defined a sub-SECTION of SECTION and so on
		until the final sub-Section is found
	- "PropertynameX" and/or "valueX" can be "IGNORE" if that helps selecting the right section (use with care!)
	- "value2" here (or the last of the "values" when multiple pairs are used) can be "IGNORE" (useful in the case where NMS changes that value later)
		see the script LearnMoreWords.lua as an example...
	- If the line pointed to by the SPECIAL_KEY_WORDS pair(s) is found, it will be used by LINE_OFFSET (if any)

	- WHAT ARE CONSIDERED SPECIAL_KEY_WORDS?
		* any line with a 'Property' AND a 'value'
		* where the value is NOT ""
		* lines with a value like a filename (???.MBIN or ???.xml for example) are now accepted as SPECIAL_KEY_WORDS
			**** be warned that filenames like ???.MBIN can change more often and render your script obsolete!
		* lines with a value like 'True', 'False' or a number are now accepted as SPECIAL_KEY_WORDS
			**** be warned that these types SHOULD be used with EXTREME CAUTION, HG could easily change the value!!!
	
	- Works alone or with PRECEDING_KEY_WORDS (see OPTIONAL use below and MiningLaserSpeed.lua for example)
	- If SPECIAL_KEY_WORDS are used, they are processed BEFORE the PRECEDING_KEY_WORDS unless [PRECEDING_FIRST] = "TRUE"
}}}

{   >>> 'PRECEDING_FIRST':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
	- DEFAULT value is "FALSE"
	- can have one of these values: {nil, "", "TRUE", "FALSE"}
			ex.: ["PRECEDING_FIRST"] = "TRUE",
	- "TRUE" means: PRECEDING_KEY_WORDS will be processed 'before' SPECIAL_KEY_WORDS
	- nil, "" or "FALSE" means: PRECEDING_KEY_WORDS will be processed 'after' SPECIAL_KEY_WORDS (the default behavior)
}

{   >>> 'PRECEDING_KEY_WORDS':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING or (TABLE of STRINGs)
	- "", or {}, or {"",}, have no effect ==> all these mean: no PRECEDING_KEY_WORDS to search (the whole file is used if nothing else selects a section)
	
	- {"key1","key2","key3",...}, ==> are a list of key_words inside an EXML (the 'Property name=' or  'Property value=' only)
			ex.: ["PRECEDING_KEY_WORDS"] = {"PropertyNameORPropertyValue1","PropertyNameORPropertyValue2",...},
			
	- LEVEL 0 being the whole EXML file SECTION
	- LEVEL key1, key2, ... defined sub-SECTION heads (SECTIONs) in the EXML file hierarchy (the line that ends in [">] )
	
	- Skipping one or more LEVEL can work, specially if you want to specify many sections (see REPLACE_TYPE)
	- works alone and with SPECIAL_KEY_WORDS
	
	- UNLESS used like in 'ALTERNATE USE' below, PRECEDING_KEY_WORDS are ALWAYS a LEVEL key (the line ends in [">] )
	
	- Normally, when using SPECIAL_KEY_WORDS, you use multiple PRECEDING_KEY_WORDS to further refine
		the sub-section to look for inside the SECTION defined by the SPECIAL_KEY_WORDS.
		
		If all these PRECEDING_KEY_WORDS are not found inside the SPECIAL_KEY_WORDS's SECTION, 
		the whole SPECIAL_KEY_WORDS's SECTION will be used (but your script has a problem and should be corrected)
		
	- 'ALTERNATE USE' of PRECEDING_KEY_WORDS (when SPECIAL_KEY_WORDS are processed first): 
			A single PRECEDING_KEY_WORDS can be used to try locating a particular line inside
			that previously found SPECIAL_KEY_WORDS's SECTION.
			
			The sub-SECTION containing that line then becomes the found SECTIO
			
				Note: It is like using ["VALUE_CHANGE_TABLE"] = {{"Property name","IGNORE",},}, to locate a particular line
					  but leaves VALUE_CHANGE_TABLE free to be used for changing values inside the found SECTION
			
			This single PRECEDING_KEY_WORDS can be any 'name' or 'value' inside that SPECIAL_KEY_WORDS's SECTION
			(much better if UNIQUE in that SECTION)
			(see MiningLaserSpeed.lua or Multi_PAK_Multi_MBIN_Example_Mod.lua for example)

			If the single "preceding_key_word" word is not found in the SPECIAL_KEY_WORDS's SECTION,
			the whole SPECIAL_KEY_WORDS's SECTION will be used
			(but, again, you probably have a problem with you script at this point!)

********  'Simplified' example EXML with LEVELs and possible keys:
				NOTE: when NOT in 'ALTERNATE USE' (see above)
				
<Data template="GcRewardTable">               	--The LEVEL 0 key (no need to use it)
	<Property name="GenericTable">            		--a LEVEL 1 key (could be the start of a SECTION, this one has no sub-section)
	<Property value="GcGenericReward.xml">          	    --another LEVEL 1 key, start of a SECTION with sub-section(s)
		<Property name="Id" value="VEHICLE_SCAN" />   	    	--is a child, possible SPECIAL_KEY_WORDS pair, NEVER a PRECEDING_KEY_WORDS
		<Property name="Common" value="Gc...List.xml">	    --a LEVEL 2 key, start of a SECTION with sub-section(s), possible SPECIAL_KEY_WORDS pair or a PRECEDING_KEY_WORDS
			<Property name="Reward" value="GiveAll" />      	--is a child, possible SPECIAL_KEY_WORDS pair, NEVER a PRECEDING_KEY_WORDS
			<Property name="Count" value="Vector2f.xml">    --a LEVEL 3 key, start of a SECTION with a sub-section, possible SPECIAL_KEY_WORDS pair or a PRECEDING_KEY_WORDS
				<Property name="x" value="1" />			    	--is a child, NEVER a PRECEDING_KEY_WORDS
				<Property name="y" value="1" />			    	--is a child, NEVER a PRECEDING_KEY_WORDS
			</Property>									    --end of a LEVEL /3 SECTION
			<Property name="List" />                        	--is a child, NEVER a SPECIAL_KEY_WORDS or PRECEDING_KEY_WORDS
		</Property>                                   	    --end of a LEVEL /2 SECTION
	</Property>											    --end of a LEVEL /1 SECTION
</Data>                                             	    --end of LEVEL /0

******* End of 'Simplified' example

	- "key2" is allways at the same or a higher level than "key1" in the EXML file hierarchy and so on...
		if (keyi LEVEL) == x; (keyi+1 LEVEL) == x + (0 or more); (keyi+2) LEVEL == (keyi+1 LEVEL) + (0 or more); ...

	- taken together, these key_words 'always' define only one SECTION of lines inside the EXML file

	- ONLY <"start of a level"> line's <"Property name" or "Property value"> info can be used as key_words
		***** see 'ALTERNATE USE' above for "preceding_key_word" exception

	- REMEMBER: Every level starts with a line ending in [">] (never with a line ending in [" />])

	- PRECEDING_KEY_WORDS rarely define a single line in the EXML file
		but the start line of the SECTION found can be used as the base for LINE_OFFSET

	- If that is not enough to narrow down the search for the right SECTION,
		we can use a <SPECIAL_KEY_WORDS pair> to help define the SECTION we are looking for

		- These SPECIAL_KEY_WORDS are defined in SPECIAL_KEY_WORDS (see above)

		- Using NMS_REALITY_GCPRODUCTTABLE.EXML as an example:
			This EXML is madeof a big bunch of SECTIONs all starting with <Property value="GcProductData.xml">
				They are all inside the <Property name="Table"> SECTION
				So "GcProductData.xml" is NOT a good key_word to use here
				but in the next line or so there is <Property name="Id" value="CASING" /> (and some other lines)
				that can help define the SECTION where we want to make the changes to the EXML
				This is were the SPECIAL_KEY_WORDS "Id" and "CASING" come in play, we add them as SPECIAL_KEY_WORDS
				and this tool will find the line SECTION 5-81 to be where we want to make changes

			AND we can use multiple PRECEDING_KEY_WORDS or a single PRECEDING_KEY_WORDS to specify a value to look for
			inside the SECTION defined by the SPECIAL_KEY_WORDS
			(see 'ALTERNATE USE' above for PRECEDING_KEY_WORDS exception)
			(see also MiningLaserSpeed.lua or Multi_PAK_Multi_MBIN_Example_Mod.lua for example)

			- Note that you can specify as many other key_words as REQUIRED to help narrow down
				the SECTION (like "Table") in the case where this EXML file had more than
				one major SECTION ("Table" here)
}}}}}}

************************  THIS IS NOT USED  **********************
{   >>> 'FIND_ALL_SECTIONS':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
	- DEFAULT value is "FALSE"
	- can have one of these values: {nil, "", "TRUE", "FALSE"}
	- "TRUE" will force AMUMSS to find ALL sections based on the KEY_WORDS
	- nil, "" or "FALSE" means that AMUMSS will use its current rules to find one or more sections as usual
	  (preserving backward compatibility)
************************  END: THIS IS NOT USED  **********************}

{   >>> 'SECTION_UP':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a number between 0 and the number of levels in the current EXML
		ex.: ["SECTION_UP"] = 0, --(means: stay in the selection section) (the default value)
		     ["SECTION_UP"] = 1, --(means: select one level up from the current level)
		     ["SECTION_UP"] = 2, --(means: select two level up from the current level)
			 ...
	- SECTION_UP is processed AFTER both SPECIAL_KEY_WORDS and PRECEDING_KEY_WORDS sections are found
	- default value is 0 (means: stay in the selection section)
}

{   >>> 'SECTION_UP_SPECIAL':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a number between 0 and the number of levels in the current EXML
		ex.: ["SECTION_UP_SPECIAL"] = 0, --(means: stay in the selected section) (the default value)
		     ["SECTION_UP_SPECIAL"] = 1, --(means: select one level up from the current level)
		     ["SECTION_UP_SPECIAL"] = 2, --(means: select two level up from the current level)
			 ...
	- SECTION_UP_SPECIAL is processed AFTER SPECIAL_KEY_WORDS sections are found
	- default value is 0 (means to stay in the selected section)
}


************************  THIS IS NOT USED, NOT NEEDED  **********************
*********  The same result can always be achieved by removing anything number
*********  of PRECEDING_KEY_WORDS from the last keyword of the list
{   >>> 'SECTION_UP_PRECEDING':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a number between 0 and the number of levels in the current EXML
		ex.: ["SECTION_UP_PRECEDING"] = 0, --(means: stay in the selected section) (the default value)
		     ["SECTION_UP_PRECEDING"] = 1, --(means: select one level up from the current level)
		     ["SECTION_UP_PRECEDING"] = 2, --(means: select two level up from the current level)
			 ...
	- SECTION_UP_PRECEDING is processed AFTER PRECEDING_KEY_WORDS sections are found
	- default value is 0 (means: stay in the selected section)

************************  END: THIS IS NOT USED, NOT NEEDED  **********************}

{{{   >>> 'SECTION_ACTIVE':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- one number or a table of NUMBERS (in no particular order)
	- 0, "", {}, "0", {0,}, {"",}, or {"0",},: all these have no effect ==> all these mean: keep all selected sections) (the default value)
	- any string that cannot be converted to a number will be discarded: {5,"abc","3",6} will select sections 3, 5 and 6 only
	- numbers don't need to be ordered
	
	- IMPORTANT: SECTION_ACTIVE should be used only in case where other methods do not work!!!
		If you can achieve to point to the right section(s) by other means, please consider using them first
		as they will probably survive more surely changes made to the files by NMS
	
	- a list of numbers between 0 and the number of sections found with the current KEY_WORDS
		ex.: ["SECTION_ACTIVE"] = {0,}, --(means: keep all selected sections) (the default value)
		     ["SECTION_ACTIVE"] = {1,}, --(means: select the 1st section only)
		     ["SECTION_ACTIVE"] = {2,}, --(means: select the 2nd section only)
			 ...
		     ["SECTION_ACTIVE"] = 8, --(means: select the 8th section only)
		     ["SECTION_ACTIVE"] = {5,2,3,}, --(means: select sections 2, 3 and 5 only) (again, order is not important)
			 ...
	- default value is '0'(zero) (means: keep all selected sections)
}}}

{{{{   >>> 'WHERE_IN_SECTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a table of (two STRINGs) table(s)
		ex.: 	["WHERE_IN_SECTION"] =
				{
					{"Property name/value1","WhereValue1",},
					{"Property name/value2","WhereValue2",},
					...
				},
	- a table containing one / many "two string" table describing:
		a "Property name" / "Property value" we want to check the value of
		and a "WhereValue" that will be compared to the original one in the EXML file
	
	- 2 Cases:	
		For each section specified KEY_WORDS:
	
		A) IF no "Property name/value" with that "WhereValue" is found in the section 
        - that SECTION is skipped/ignored
		B) IF a "Property name/value" has that "WhereValue" 'in' the section 
        - that SECTION will be used by the script to update the EXML

	- WHERE_IN_SUBSECTION is processed after WHERE_IN_SECTION when also present
			
	- "IGNORE" can be used in place of one / both strings
	- an example use can be found in the script RewardTable_Test.lua
}}}}

{{{{{{{   >>> 'WHERE_IN_SUBSECTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a table of (two STRINGs) table(s)
		ex.: 	["WHERE_IN_SUBSECTION"] =
				{
					{"Property name/value1","WhereValue1",},
					{"Property name/value2","WhereValue2",},
					...
				},
	- a table containing one / many "two string" table describing:
		a "Property name" / "Property value" we want to check the value of
		and a "WhereValue" that will be compared to the original one in the EXML file
	
	- WHERE_IN_SUBSECTION is similar to WHERE_IN_SECTION but can specify a sub-section down
	
	- 3 Cases:	
		For each section specified by SPECIAL_KEY_WORDS / PRECEDING_KEY_WORDS:
	
		A) IF no "Property name/value" with that "WhereValue" is found in the section 
        - that SECTION is skipped/ignored
		B) IF a "Property name/value" has that "WhereValue" 'in' the section 
        - unless C) applies: that SECTION will be used by the script to update the EXML
		C) IF a "Property name/value" has that "WhereValue" 'in' a SUB-SECTION of the section 
        - that SUB-SECTION will be used by the script to update the EXML 
			  instead of the original SECTION
		
	- WHERE_IN_SECTION is processed first if also present

	- "IGNORE" can be used in place of one / both strings
}}}}}}}

************************  THIS IS STILL IN DEVELOPMENT  **********************
{   >>> 'SAVE_SECTION_TO':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- "" or a STRING
		ex.: 	["SAVE_SECTION_TO"] = "user_name_of_section",
	- user_name_of_section is the name the user will insert in the script to refer to the SECTION content
		The SECTION content will be a STRING
	- it instruct AMUMSS to copy that section for future use in the script
	- Only the first section of multiple sections returned by the keywords is saved
}

************************  THIS IS STILL IN DEVELOPMENT  **********************
{   >>> 'KEEP_SECTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- "" or a STRING
	- DEFAULT value is "FALSE"
	- can have one of these values: {nil, "", "TRUE", "FALSE"}
	- nil, "" or "FALSE" instruct AMUMSS to record this section ONLY for the current script
	- "TRUE" instruct AMUMSS to create a permanent record of this section
		that can be used by the current script AND any other scripts in ModScript
}

************************  THIS IS STILL IN DEVELOPMENT  **********************
{   >>> 'ADD_NAMED_SECTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- "" or a STRING
		ex.: 	["ADD_NAMED_SECTION"] = "user_name_of_section",
	- user_name_of_section is the name the user will insert in the script to refer to the SECTION content
		The SECTION content will be a STRING
	- it instruct AMUMSS to paste that previously SAVEd section into the current EXML at the current position
}

************************  THIS IS STILL IN DEVELOPMENT  **********************
{   >>> 'EDIT_SECTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- "" or a STRING
		ex.: 	["EDIT_SECTION"] = "user_name_of_section",
	- user_name_of_section is the name the user will insert in the script to refer to the SECTION content
		The SECTION content will be a STRING
	- it instruct AMUMSS to allow editing that previously SAVEd section using AMUMSS other commands like it was
		a regular EXML file
}

{   >>> 'MATH_OPERATION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- "" or a STRING composed of
	- == "$" + one of {+, -, *, /} + (a SUFFIX and an endString)(OPTIONAL) OR (a SUFFIX and NUMBER_OF_LINES)(OPTIONAL)
		ex.: 	["MATH_OPERATION"] 	= "*",
			or	["MATH_OPERATION"] 	= "*F:MaxAmount",
			or	["MATH_OPERATION"] 	= "*$L:5",
			or	["MATH_OPERATION"] 	= "$-",

	- After retrieving the LINE pointed to by the keywords (AND possibly redirected by LINE_OFFSET):

	- "$" when used, commutes the order of the operands so that, for example, (3 - 5 = -2) becomes (5 - 3 = 2)

	- {+, -, *, /} used alone will apply the math operation between the VALUE at that LINE and the script "newvalue". Then use it as the mod "newvalue"

	- with SUFFIX == one of {F:, FB:} AND
		endString == "IGNORE" or a Property Name STRING (like [MaxAmount] here: <Property name="MaxAmount" value="300" />)
		  Note: the value pointed to MUST be a numerical value (NOT a text string like [ALLOY1] here <Property name="Value" value="ALLOY1" />)

		F: == Fetch Forward from the LINE for endString and get the value on that new line
		FB: == Fetch Backward from the LINE for endString and get the value on that new line

		now apply the math operation between this value and the script "newvalue".  Then use it as the mod "newvalue"

	- WARNING If you can avoid using {L:, LB:}, it is better. A one line added/removed by NMS <<in between>> would kill the script
	- with SUFFIX == one of {L:, LB:} AND NUMBER_OF_LINES
		L: == Lookup Forward from the LINE PLUS NUMBER_OF_LINES and get the value on that new line
		LB: == Lookup Backward from the LINE MINUS NUMBER_OF_LINES and get the value on that new line

		now apply the math operation between this value and the script "newvalue".  Then use it as the mod "newvalue"
}

{   >>> 'INTEGER_TO_FLOAT':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING

	- WARNING: even if you use this option to silence the AMUMSS WARNING's, MBINCompiler may still refuse
		to compile the EXML when the underlying value is 'really' an INTEGER.
		USE 'INTEGER_TO_FLOAT' if you know that what you are doing is right

	- [WARNING] ORIGINAL and NEW number value have mismatched types (INTEGER vs FLOAT or STRING vs NUMBER)
		You may see this WARNING in the REPORT . 
		This WARNING only tells you that the script is changing an INTEGER "0" to a FLOAT "0.75"
			or a STRING to a NUMBER or a NUMBER to a STRING.
		If the EXML compiles fines with MBINCompiler then it is alright, 
			otherwise it may be the case why MBINCompiler fails to conpile the EXML.  
		So it is an AID to you in finding a possible problem.
	
	- can have one of these values: {nil, "", "FORCE", "PRESERVE"}
	- default value is ""
	- ["INTEGER_TO_FLOAT"] = "FORCE", will change the INTEGER value to a FLOAT if necessary
	- ["INTEGER_TO_FLOAT"] = "PRESERVE", will keep the same type of value as before the operation
		and hide: "WARNING: ORIGINAL value below is INTEGER." 
		>> A FLOAT will still be a FLOAT
		>> An INTEGER will still be an INTEGER (rounding up the value if necessary)
}}}}}

{   >>> 'REPLACE_TYPE':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING (case is not important)
	- can have one of these values: {nil, "", "ALL", "ALLFOLLOWING", "RAW"}
		ex.: 	["REPLACE_TYPE"] 	= "ALL",
	- == if missing or nil or "": it will replace only the first line that match the key_words in the found sections
	
	- OBSOLETE - DEPRICATED: Using ["REPLACE_TYPE"] = "ADDafterSECTION", is now 'OBSOLETE' (but kept for backward compatibility)
				please use ADD_OPTION, described below, in all new scripts
					
	- == "ALLFOLLOWING" will replace ALL lines that match the VALUE_CHANGE_TABLE pairs FOLLOWING
		the most recent replaced line (after the first replacement obviously)

	- == "ALL" will replace ALL lines that match the VALUE_CHANGE_TABLE pairs
	
	- == "ALL" with "some key_words" will replace ALL lines that match the VALUE_CHANGE_TABLE pairs
		INSIDE the SECTION(s) defined by the key_words

	- == RAW replaces property with value on ALL lines where property is found
		SPECIAL_KEY_WORDS / PRECEDING_KEY_WORDS and other options can be use to limit the SECTION
		
		RAW implies that ALL was used as well

		NOTE: each RAW only targets one line of the EXML at the time
				It is possible to replace the line with another one or with multiple lines
				if the replacement string is properly crafted...  (line breaks and all)

		WARNING: RAW IS POWERFULL AND DANGEROUS, EVEN DESTRUCTIVE IF NOT USED CORRECTLY
		***** USE WITH GREAT CARE *****

		>>> see the "RAW_REPLACEMENT.lua" script in the ModScriptCollection\LearningExamples\Commented
			folder for some more details <<<
}}}

{   >>> 'VALUE_MATCH':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
		ex.: 	["VALUE_MATCH"] 	= "Snow",
			or	["VALUE_MATCH"] 	= "5",
	- a literal value (a string or a number) from the EXML file that
		matches exactly the "original value" we want to change
		like if we want to change only values when the "original value" is "5" or "Snow" or "False"
	- can be useful when the tool has difficulty finding the right one
	- see CreatureSizeAndSpawnRateIncrease.lua and MoreScreenFilters.lua as examples
}}

{   >>> 'VALUE_MATCH_OPTIONS':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
		ex.: 	["VALUE_MATCH_OPTIONS"] 	= "~=",
	- IF VALUE_MATCH value is "" or does not exist, VALUE_MATCH_OPTIONS have no effect
	- forces the tool to match this options for the "newvalue"
		when searching for the "Property name/value" (see VALUE_CHANGE_TABLE below)
	- If VALUE_MATCH is a STRING:
		- To replace the VALUE on ALL lines defined by the keywords:
			- that MATCH VALUE_MATCH,                  use "=" (default option)
			- that DO NOT MATCH VALUE_MATCH,           use "~="
	- If VALUE_MATCH is a NUMBER:
		- To replace the VALUE on ALL lines defined by the keywords:
			- that MATCH VALUE_MATCH,                  use "=" (default option)
			- that DO NOT MATCH VALUE_MATCH,           use "~="
			- that is less than VALUE_MATCH,           use "<"
			- that is les or equal to VALUE_MATCH,     use "<="
			- that is greater than VALUE_MATCH,        use ">"
			- that is greater or equal to VALUE_MATCH, use ">="
}

{   >>> 'VALUE_MATCH_TYPE':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
		ex.: 	["VALUE_MATCH_TYPE"] 	= "NUMBER",
	- IF VALUE_MATCH value is "" or does not exist, VALUE_MATCH_TYPE have no effect
	- can be "NUMBER" or "STRING" only
	- forces the tool to match this type for the "newvalue"
		when searching for the "Property name/value" (see VALUE_CHANGE_TABLE below)
}

{   >>> 'LINE_OFFSET':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	
	- WARNING: In most circumstances, if you can avoid LINE_OFFSET, it is better.
		A one line added/removed by NMS in between could kill the script.
		- Some exceptions to this WARNING include:
			- You want to ADD something at the end of a SECTION and you used ["ADD_OPTION"] = "ADDafterSECTION",
				Here ["LINE_OFFSET"] = "-1" will always be a valid choice
			- Where a list of lines like <Property value="4" /> (as in GCFLEETGLOBALS.GLOBAL.EXML) are used and you want
				to alter some particular line or lines
				- For a script example see LodDistanceScale.lua or TerrainEditorMod.lua

	- a STRING representing a number
		ex.: 	["LINE_OFFSET"] 	= "-15",
	- "" or (if used) +/- a STRING integer number of lines from the found line like "+15"
	- If a line is found using the SPECIAL_KEY_WORDS, it is used as the starting point
	- Otherwise, the start line of the SECTION found using the PRECEDING_KEY_WORDS will be used
	- NOTE: with ADD, the line used to ADD is the NEXT line
	- NOTE: with REMOVE, the line used (to define the SECTION or the LINE to REMOVE) is the line found
	- a LINE_OFFSET of '0' is the same as no LINE_OFFSET at all
}}

{   >>> 'VALUE_CHANGE_TABLE':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a table of (two STRINGs)table(s)
		ex.:
			["VALUE_CHANGE_TABLE"] 	= {
					{"Property name/value1","newvalue1",},
					...
			},
	- {"Property name/value1","newvalue1",}, {"Property name/value2","newvalue2",}, ...
	- a table containing one or many "two string" tables describing:
		- a "Property name" or "Property value" we want to change the value of
		- and a "newvalue" that will replace the original one in the EXML file
		- one or the other can be "IGNORE" in some cases (like when we use LINE_OFFSET)
		- syntax examples:  {"A","IGNORE",}, or  {"IGNORE","IGNORE",}, or  {"IGNORE","A",},
	- a newvalue == "IGNORE" will make the tool SKIP that line,
		doing NO exchange at all and continuing processing the next Property name/value
	- to update a group of numerical 'Property value=' using (for example) a [MATH_OPERATION] = "*"
		and ["VALUE_CHANGE_TABLE"] = {{"IGNORE","1.5"},},
		to multiply << each >> value by 1.5 without the need for [LINE_OFFSET]
}

************************  THIS IS STILL IN DEVELOPMENT  **********************
{   >>> 'FOREACH_SPECIAL_KEY_WORDS':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a table of (two STRINGs)table(s)
		ex.:	["FOREACH_SPECIAL_KEY_WORDS"] 	=
				{
					{"Property name1","value1",},
					{"Property name2","value2",},
					...
				},
	- {"Property name1","value1",}, ==> special_key_word pair #1
	  that will be used to point to SECTION #1 we are looking for
	- {"Property name2","value2",}, ==> special_key_word pair #2
	  that will be used to point to SECTION #2 we are looking for
	- ...
	
	- FOREACH of these SECTIONs, AMUMSS will attempt to apply the other directives in the current
	  EXML_CHANGE_TABLE sub-table
	  
	- Example (from Lo2k proposal):
			["EXML_CHANGE_TABLE"] 	= 
			{
			  { -- Where, for each pair, the section is REMOVED
				["FOREACH_SPECIAL_KEY_WORDS_PAIR"] = {
					{"Unlockable", "W_GDOOR_D",},
					{"Unlockable", "W_SDOOR",},
				},
				["REMOVE"] 	= "SECTION",
			  },
			},
}

{   >>> 'ADD_OPTION':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING (case is not important)
	- used to alter ADD behavior and should be used instead of REPLACE_TYPE
	
NEW	- can have one of these values: {nil, "", "REPLACEatLINE", "ADDafterLINE", "ADDafterSECTION"}
		ex.: 	["ADD_OPTION"] 	= "REPLACEatLINE",
			or	["ADD_OPTION"] 	= "ADDafterLINE", -- default
			or	["ADD_OPTION"] 	= "ADDafterSECTION",
				
	- == if missing or nil or "": "ADDafterLINE" is the default behavior

NEW	- == "REPLACEatLINE" : used with ADD, specifies to replace that line with TEXT_TO_ADD 'at' the LINE
		specified by the SPECIAL_KEY_WORDS / PRECEDING_KEY_WORDS and the VALUE_CHANGE_TABLE property

NEW	- == "ADDafterLINE": used with ADD, specifies to add TEXT_TO_ADD AFTER the LINE
		pointed to by the SPECIAL_KEY_WORDS / PRECEDING_KEY_WORDS and the VALUE_CHANGE_TABLE property

NEW	- == "ADDafterSECTION": When used with ADD, specifies to add TEXT_TO_ADD AFTER the SECTION
		pointed to by the SPECIAL_KEY_WORDS / PRECEDING_KEY_WORDS and the VALUE_CHANGE_TABLE property
}}

{   >>> 'ADD':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- Can be of type "string" or [[long string]] or a user named variable of those types (like TEXT_TO_ADD)
		ex.:	["ADD"] = "a short string",
			or	["ADD"] = [[a
								multi-line
									string]],
			or	["ADD"] = MY_USER_NAME_VARIABLE,
	- Used to ADD lines or SECTION inside the EXML file
	- Can be used with a user named variable defined before the opening MODIFICATIONS SECTION
	- See the ADD_REMOVE_TEXT_EXAMPLE.lua example in "ModScriptCollection\LearningExamples\Commented\" folder
	- See also the LearnMoreWords.lua script in "ModScriptCollection" folder
	- Can be used with SPECIAL_KEY_WORDS, SECTION_UP_SPECIAL, PRECEDING_KEY_WORDS, SECTION_UP, LINE_OFFSET,
		VALUE_MATCH, VALUE_MATCH_TYPE and ADD_OPTION
	- The TEXT_TO_ADD is added EXACTLY AFTER the line found
	- Used with LINE_OFFSET, the TEXT_TO_ADD is added EXACTLY AFTER the line found +/- the LINE_OFFSET
		WARNING: if you can avoid LINE_OFFSET, it is better. A one line added/removed by NMS in between would kill the script
	
	- Used with ADD_OPTION == "ADDafterLINE", will use the current LINE to ADD the TEXT_TO_ADD after
		**** NOTE: This is the default behavior
	
	- Used with ADD_OPTION == "ADDatLINE", will use the current LINE to ADD the TEXT_TO_ADD overwriting that line
		**** NOTE: That means you don't need to REMOVE the current LINE in this case
	
	- Used with ADD_OPTION == "ADDafterSECTION", will find the end of the SECTION and then ADD the TEXT_TO_ADD
	
	- "Property name/value1" of VALUE_CHANGE_TABLE can be used to specify a sub-SECTION of the SPECIAL_KEY_WORDS + PRECEDING_KEY_WORDS SECTION

	NOTE:
	  - PLEASE remember that if you use both ADD and REMOVE inside the same EXML_CHANGE_TABLE table
	    the respective TEXT will be "added" first AND then the "removed" (the LINE or the SECTION) done after
}}

{   >>> 'REMOVE':
	- is OPTIONAL
	- is a member of EXML_CHANGE_TABLE
	- a STRING
		ex.:	["REMOVE"] = "SECTION",
	- "", or {}, or {"",}, ==> all these mean: no REMOVE to use
	
	- == "SECTION", the SECTION will be REMOVEd
	- == "LINE", the line will be REMOVEd
	
	- SPECIAL_KEY_WORDS, PRECEDING_KEY_WORDS, LINE_OFFSET
		with VALUE_MATCH, VALUE_MATCH_TYPE and REPLACE_TYPE can be use
	- with LINE_OFFSET, the REMOVE action happens AT the line found for LINE or AT the top of the SECTION

		WARNING: REMOVE IS POWERFULL AND DANGEROUS, EVEN DESTRUCTIVE IF NOT USED CORRECTLY
		USE WITH GREAT CARE

	NOTE:
	  - PLEASE remember that if you use both ADD and REMOVE inside the same EXML_CHANGE_TABLE table
	    the respective TEXT will be "added" first AND then the "removed" done (the LINE or the SECTION)
}}

{   >>> 'ADD_FILES':
	- is OPTIONAL when MODIFICATIONS is used
	- a member of NMS_MOD_DEFINITION_CONTAINER

	- can be used with or without MODIFICATIONS
	- see Add_FIle_Example_-_GFloor.lua or (StandardSchemeExtended.lua and ADD_NEW_FILES_EXAMPLE.lua) scripts for more details

	- the order of members is not important
	- members of ADD_FILES are:
		- FILE_DESTINATION		REQUIRED
			> the NMS path where this file will be located so that the referencing file will find it
			> If the FILE_DESTINATION includes a filename,
			  that filename will be used to rename the EXTERNAL_FILE_SOURCE filename
		
		- EXTERNAL_FILE_SOURCE or FILE_CONTENT must be used

			- EXTERNAL_FILE_SOURCE
				> the path AND filename of the file to be 'ADD'ed
				  can be a 'full path' (D:\something\...) or a 'relative path' to ModScript folder
			
			- FILE_CONTENT
				> a long string representation of the binary content of the FILE_DESTINATION filename
				> FILE_DESTINATION must specify the filename
}

{***************************  ADVANCED SCRIPT RULES / TIPS  ****************************
Tip #1:
[[-In a loop, it is much faster to use a table to store strings and do a table.concat()
	  than to concatenate strings.  As an example:

	  function UsingConcatenation() -- may take 50 sec to complete
		  local NbIteration = 200000
		  print("NbIteration = "..NbIteration)
		  local a = "MyString"
		  local b = a
		  for i=1,NbIteration do
			b = b..a
		  end
		  print(#b)
	  end

	  function UsingTable()       -- takes only less than 1 sec to complete for the same result
		  local NbIteration = 200000
		  print("NbIteration = "..NbIteration)
		  local a = "MyString"
		  local T = {}
		  T[1] = a
		  for i=1,NbIteration do
			T[#T+1] = a
		  end
		  b = table.concat(T)
		  print(#b)
	  end
]]

Tip #2:
[[-About Conflicts:
	
	Conflicts may come from the fact that a pak (from a .lua script) is already in your MODS folder 
	AND you asked AMUMSS to also check Conflicts against the MODS folder.
	
	Since AMUMSS cannot know if this pak is in fact from this .lua script 
	(the pak name could have been renamed by the user), it flags it as 'in conflict'.  
	
	But since you know this is not the case, you can safely disregard these conflicts in this case.
]]

{***************************  DEPRICATED (do not use)  ****************************
REPLACE_AFTER_ENTRY = {
	- NOT USED ANYMORE - XXXXX depricated XXXXX
	- is an older version of PRECEDING_KEY_WORDS (left for backward compatibility)
}}}

{OBSOLETE  *********  NOT USED ANYMORE (AMUMSS ALWAYS DO ONLY ONE PASS NOW)  **************

	What to do when your script spends a lot of time in BUILDMOD.bat at the line:
	">>> B: Executing Lua with LoadScriptAndFilenames.lua, Please wait..."

	Your script probably does a LOT of pre-processing before the NMS_MOD_DEFINITION_CONTAINER definition.
	You can add these code lines in your script
	to skip the long executing code and still load the container:

	--top of example script (see SkippingLongFirstPass.lua in folder ModScriptCollection\LearningExamples\Advanced)
}}

--===============================================================================
{   *********  NOT USED ANYMORE (AMUMSS ALWAYS DO ONLY ONE PASS NOW)  **************
--at the top of the script:
--add these lines to bypass the first pass evaluation of the script
DoFirstPass = (os.getenv("SkipScriptFirstCheck") ~= nil)
--this line is used to jump over all the lengthy code BEFORE the NMS_MOD_DEFINITION_CONTAINER
if not DoFirstPass then
--===============================================================================

  local function sleep(s)
	if s==nil then s=1 end
	local i=os.clock()+s
	print("        waiting for " .. s .. " seconds ...")
	while(os.clock()<i) do
	  --print("wait for " .. i-clock() .. " seconds")
	end
	print("         finished waiting for " .. s .. " seconds")
  end

	--example of long execution code here
	--this will wait for 30 seconds, simulating a long time to execute
	sleep(30)

	ANIM_TEMPLATE_ALL = ""  			--used in the CONTAINER
	ACTION_TRIGGER_COMPONENT = ""		--used in the CONTAINER
	QUICK_ACTION_BUTTON_ALL = ""		--used in the CONTAINER
    SUPER_USER_VARIABLE = ""        --not used in container, no need to duplicate below
	--end of example of long execution code here

--===============================================================================
   *********  NOT USED ANYMORE (AMUMSS ALWAYS DO ONLY ONE PASS NOW)  **************
--Add these lines just before the NMS_MOD_DEFINITION_CONTAINER
else  --if not DoFirstPass then
  print("     Skipping first pass check!")

  --here create ALL "empty user variables" used in EXML_CHANGE_TABLE
  --in order for the script to be valid
  ANIM_TEMPLATE_ALL = ""  			--this user variable is used in the CONTAINER
  ACTION_TRIGGER_COMPONENT = ""		--this user variable is used in the CONTAINER
  QUICK_ACTION_BUTTON_ALL = ""		--this user variable is used in the CONTAINER
  --...                               --as many as there are in CONTAINER
end  --if not DoFirstPass then
--===============================================================================

	NMS_MOD_DEFINITION_CONTAINER =
	{
	["MOD_FILENAME"] 			= "SkippingLongFirstPass.pak",
	["MOD_AUTHOR"]				= "Wbertro",
	["MOD_DESCRIPTION"]			= "",
	["NMS_VERSION"]				= "2.0+",
	["MODIFICATIONS"] 			=
		{
			{
				["MBIN_CHANGE_TABLE"] =
				{
					{
						["MBIN_FILE_SOURCE"] 	= [[MODELS\COMMON\PLAYER\PLAYERCHARACTER\PLAYERCHARACTER\ENTITIES\PLAYERCHARACTER.ENTITY.MBIN]],
						["EXML_CHANGE_TABLE"] =
						{
							{
								["PRECEDING_KEY_WORDS"] = {"Anims"},
								["LINE_OFFSET"] 		= "+0",
								["ADD"] 				= ANIM_TEMPLATE_ALL, --a user variable
							},
							{
								["PRECEDING_KEY_WORDS"] = {"LodDistances"},
								["LINE_OFFSET"] 		= "-2",
								["ADD"] 				= ACTION_TRIGGER_COMPONENT, --a user variable
							}
						}
					},
					{
						["MBIN_FILE_SOURCE"] 	= [[METADATA\UI\EMOTEMENU.MBIN]],
						["EXML_CHANGE_TABLE"] 	=
						{
							{
								["PRECEDING_KEY_WORDS"] = {"Emotes"},
								["LINE_OFFSET"] 		= "+0",
								["ADD"] 				= QUICK_ACTION_BUTTON_ALL, --a user variable
							}
						}
					},
				}
			},
		}
	}
	--NOTE: ANYTHING NOT in table NMS_MOD_DEFINITION_CONTAINER IS IGNORED AFTER THE SCRIPT IS LOADED
	--IT IS BETTER TO ADD THINGS AT THE TOP IF YOU NEED TO
	

	--end of example script
   *********  NOT USED ANYMORE (AMUMSS ALWAYS DO ONLY ONE PASS NOW)  **************
}}
