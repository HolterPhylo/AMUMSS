-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function HandleModScript(MOD_DEF,Multi_pak,global_integer_to_float)
  pv(THIS.."From HandleModScript()")
  
  if Multi_pak == nil then Multi_pak = false end

  local file = ""
  local FullPathFile = ""
  local AtLeastOne_EXML_CHANGE_TABLE = false
  
  local NumReplacements = 0
  local NumFilesAdded = 0
  
  local UserScriptName = LoadFileData("CurrentModScript.txt")
  UserScriptName = string.sub(UserScriptName,string.len(gMASTER_FOLDER_PATH..[[ModScript\]])+1)
  
  --***************************************************************************************************  
  local function ExecuteREGEX(From,Command)
    -- print("")
    local spacer = "      "
    if _bOS_bitness == "64" then
      print(spacer..From..": Using 64bit version")
      Report("","  "..From.."  : Using 64bit version")
      os.execute([[sed-4.7-x64.exe ]]..Command)
    else
      print(spacer..From..": Using 32bit version")
      Report("","  "..From.."  : Using 32bit version")
      os.execute([[sed-4.7.exe ]]..Command)
    end
    print(spacer..From..": "..Command)
    Report("","  "..From.."  : "..Command)
  end
  --***************************************************************************************************  

  local say = LoadFileData("CurrentModScript.txt")
  -- because string.gsub pattern does not work with all folder names (ex.: ".")
  if string.find(say,gMASTER_FOLDER_PATH..[[ModScript\]],1,true) ~= nil then
    local start = string.find(say,gMASTER_FOLDER_PATH..[[ModScript\]],1,true)
    say = string.sub(say,1,start - 1)..string.sub(say,string.len(gMASTER_FOLDER_PATH..[[ModScript\]]) + start)
  end
  Report(say,">>>>>>> Loaded script")
  
  --***************************************************************************************************  
  local function EXMLtoMBIN(s)
    return string.gsub(s,".EXML",".MBIN")
  end
  --***************************************************************************************************  
  
  if MOD_DEF["MODIFICATIONS"]~=nil then
    for n=1,#MOD_DEF["MODIFICATIONS"] do
      local EXML_CHANGE_TABLE_fields_IsNil = false
      local EXML_CHANGE_TABLE_fields_IsString = false
      
      if MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"] ~= nil then
        pv([[==> type(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"]) = ]]..type(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"]))
        pv([[==> #MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"] = ]]..#MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"])

        for m=1,#MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"] do
          -- print([[;;; MBIN_CHANGE_TABLE ]]..m)
          -- for k,v in pairs(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"]) do
            -- print(k,type(v))
          -- end
          -- print(";;;")
        
          -- print([[;;; MBIN_CHANGE_TABLE ]]..m)
          -- for i=1,#MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m] do
            -- print(i,type(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m][i]))
          -- end
          -- print(";;;")
        
          -- print(";;; MBIN_CHANGE_TABLE["..m.."]")
          -- for k,v in pairs(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]) do
            -- print(k,type(v))
          -- end
          -- print(";;;")
        
          local NEW_FILEPATH_AND_NAME = {}
          local REMOVE_FLAG = {}
          local mbin_file_source = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["MBIN_FILE_SOURCE"]
          
          --=================== Test which mbin_file_source alt syntax is used ========================
          if type(mbin_file_source) ~= "table" then
            --alternate syntax #1
            pv("alt syntax #1: only a string.  Make it a table, we want a table!")
            mbin_file_source = {}            
            mbin_file_source[1] = EXMLtoMBIN(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["MBIN_FILE_SOURCE"])
            NEW_FILEPATH_AND_NAME[#NEW_FILEPATH_AND_NAME+1] = ""
            REMOVE_FLAG[#REMOVE_FLAG+1] = ""
            
            --for Conflicts
            if mbin_file_source[1] == nil then mbin_file_source[1] = "" end
            pv("#1 [a String] "..mbin_file_source[1]..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"])
            WriteToFileAppend(mbin_file_source[1]..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"].."\n", "MBIN_PAKS.txt")
          else
            local tempTable = {}
            local tempConflicts = {}
            for i=1,#mbin_file_source do
              if type(mbin_file_source[i]) == "table" then
                --alternate syntax #3
                --handle MBIN_FILE_SOURCE as a table of tables
                pv("alt syntax #3: Convert mbin_file_source to a simple table")
                tempTable[#tempTable+1] = EXMLtoMBIN(mbin_file_source[i][1])
                
                --and save info for NEW_FILEPATH_AND_NAME
                NEW_FILEPATH_AND_NAME[#NEW_FILEPATH_AND_NAME+1] = EXMLtoMBIN(mbin_file_source[i][2])
                if mbin_file_source[i][3] == nil then
                  REMOVE_FLAG[#REMOVE_FLAG+1] = ""
                else
                  REMOVE_FLAG[#REMOVE_FLAG+1] = mbin_file_source[i][3]
                end
                
                --for Conflicts
                if REMOVE_FLAG[#REMOVE_FLAG] == "" then
                  pv("#3.1: Adding to tempConflicts "..EXMLtoMBIN(mbin_file_source[i][1]))
                  tempConflicts[#tempConflicts+1] = EXMLtoMBIN(mbin_file_source[i][1])
                else
                  pv("["..REMOVE_FLAG[#REMOVE_FLAG].."]")
                  --let us remove any sign of mbin_file_source[i][1] in tempConflicts
                  for tC=#tempConflicts,-1 do
                    if tempConflicts[tC] == EXMLtoMBIN(mbin_file_source[i][1]) then
                      table.remove(tempConflicts,tC)
                    end
                  end
                end
                pv("#3.2 [T of T] "..EXMLtoMBIN(mbin_file_source[i][2])..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"])
                WriteToFileAppend(EXMLtoMBIN(mbin_file_source[i][2])..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"].."\n", "MBIN_PAKS.txt")
              
              else
                --alternate syntax #2
                pv("alt syntax #2: Handle MBIN_FILE_SOURCE as a table only")
                tempTable[#tempTable+1] = EXMLtoMBIN(mbin_file_source[i])
                NEW_FILEPATH_AND_NAME[#NEW_FILEPATH_AND_NAME+1] = ""
                REMOVE_FLAG[#REMOVE_FLAG+1] = ""
                
                --for Conflicts
                pv("#2 [T of String(s)] "..EXMLtoMBIN(mbin_file_source[i])..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"])
                WriteToFileAppend(EXMLtoMBIN(mbin_file_source[i])..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"].."\n", "MBIN_PAKS.txt")
              end            
            end

            --if some were left, register them
            pv("#tempConflicts = "..#tempConflicts)
            for tC=1,#tempConflicts do
              pv("#3.1 [T of T] "..tempConflicts[tC]..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"])
              WriteToFileAppend(tempConflicts[tC]..", "..UserScriptName..": "..MOD_DEF["MOD_FILENAME"].."\n", "MBIN_PAKS.txt")
            end
            
            mbin_file_source = tempTable
          end
          --=================== end: Test which mbin_file_source alt syntax is used ========================
          
          for u=1,#mbin_file_source do
            --change MBIN.PC/MBIN to EXML
            file = string.gsub(mbin_file_source[u],[[%.MBIN%.PC]],[[.MBIN]])
            file = string.gsub(file,[[%.MBIN]],[[.EXML]])
            
            file = string.gsub(file,[[/]],[[\]])
            file = string.gsub(file,[[\\]],[[\]])
            
            FullPathFile = gMASTER_FOLDER_PATH..gLocalFolder..file
            print("--------------------------------------------------------------------------------------")
            print("\n".._zRED..">>> " .. file.._zDEFAULT)
            Report("",">>> " .. file)
            
            --MBINCompiler handles:
            --    *.MBIN -> *.EXML -> *.MBIN  
            --    *.GEOMETRY.MBIN.PC -> *.GEOMETRY.EXML -> *.GEOMETRY.MBIN.PC  
            --    *.GEOMETRY.DATA.MBIN.PC -> *.GEOMETRY.DATA.EXML -> *.GEOMETRY.DATA.MBIN.PC
            
            if #NEW_FILEPATH_AND_NAME > 0 and NEW_FILEPATH_AND_NAME[u] ~= nil and NEW_FILEPATH_AND_NAME[u] ~= "" then
              --user asked to create a new file
              --try to change all / to \
              NEW_FILEPATH_AND_NAME[u] = NormalizePath(NEW_FILEPATH_AND_NAME[u])
              -- print()
              print("    => Copying/renaming this file to ["..NEW_FILEPATH_AND_NAME[u].."]")
              Report("","=> Copying/renaming this file to ["..NEW_FILEPATH_AND_NAME[u].."]")
              --change MBIN.PC/MBIN to EXML
              NEW_FILEPATH_AND_NAME[u] = string.gsub(NEW_FILEPATH_AND_NAME[u],[[%.MBIN%.PC]],[[.MBIN]])
              NEW_FILEPATH_AND_NAME[u] = string.gsub(NEW_FILEPATH_AND_NAME[u],[[%.MBIN]],[[.EXML]])
              --xcopy original file to its new folder in MOD with new name
              local FilePathSource = [[MOD\]]..file
              local FilePathDestination = [[MOD\]]..NEW_FILEPATH_AND_NAME[u]..[[*]]
              -- print("*** ["..FilePathSource.."]")
              -- print("*** ["..FilePathDestination.."]")
              local cmd = [[xcopy /y /h /v /i "]]..FilePathSource..[[" "]]..FilePathDestination..[[" 1>NUL 2>NUL]]
              NewThread(cmd)
              
              if REMOVE_FLAG[u] == "REMOVE" then
                --delete original file from its folder
                print("    => Removing this file")
                Report("","=> Removing this file")
                os.remove(FilePathSource)
                --remove original empty folder(s), if any
                local FolderPath = [[MOD\]]..GetFolderPathFromFilePath(file)
                -- print("["..FolderPath.."]")
                repeat
                  --to remove all empty folders in the path
                  local cmd = [[rd /q "]]..FolderPath..[[" 1>NUL 2>NUL]]
                  NewThread(cmd)
                  FolderPath = GetFolderPathFromFilePath(FolderPath)
                  -- print("["..FolderPath.."]")
                until FolderPath == ""
              end
            end
            
            --=================== REGEXBEFORE ========================
            if MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["REGEXBEFORE"] ~= nil then
              local regexbefore = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["REGEXBEFORE"]
              if type(regexbefore) ~= "table" then
                print("")
                print(_zRED..">>> [ERROR] REGEXBEFORE is not a table, please correct your script".._zDEFAULT)
                Report("","REGEXBEFORE is not a table, please correct your script","ERROR")
              end
              for i=1,#regexbefore do
                local ToFindRegex = string.gsub(regexbefore[i][1],[[\\]],[[\]])
                ToFindRegex = string.gsub(regexbefore[i][1],[["]],[[\"]])
                local ToReplaceRegex = string.gsub(regexbefore[i][2],[[\\]],[[\]])
                ToReplaceRegex = string.gsub(regexbefore[i][2],[["]],[[\"]])
                if ToFindRegex == nil or ToReplaceRegex == nil then
                  print("")
                  print(_zRED..">>> [ERROR] missing REGEXBEFORE member, please correct your script".._zDEFAULT)
                  Report("","missing REGEXBEFORE member, please correct your script","ERROR")
                else
                  if ToFindRegex ~= "" then
                    local From = "REGEXBEFORE"
                    local Command = [[-i -r "s/]]..ToFindRegex..[[/]]..ToReplaceRegex..[[/" "]]..FullPathFile..[["]]
                    --for debug purposes
                    -- Command = string.sub(Command,4)..[[ > "]]..From..[[_output.txt"]]
                    ExecuteREGEX(From,Command)
                  end
                end
              end
            end
            --=================== end REGEXBEFORE ========================
            
            --=================== XLST ========================
            if MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["XLST"] ~= nil then
              local xlst = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["XLST"]
              local tempXslFileName = os.tmpname()
              local tempXslFile = io.open(tempXslFileName, "w")
              tempXslFile:write(xlst)
              io.close(tempXslFile)
              os.execute([[powershell.exe .\transform-xml.ps1 ]]..tempXslFileName..[[ ]]..FullPathFile)
              os.remove(tempXslFileName)
            end
            --=================== end XLST ========================

            print("     *** Opening file...")
            TextFileTable = ParseTextFileIntoTable(FullPathFile) --the EXML file in MOD
            
            if #TextFileTable == 0 then
              if REMOVE_FLAG[u] ~= "REMOVE" then
                --this file does not exist, skip it
                print(_zRED..">>> [ERROR] file does not exist! See above for source...".._zDEFAULT)
                Report("","file does not exist! See above for source...","ERROR")
              end
            else
              
              --=================== create MapFileTrees of original EXML only... ========================
              local src = [[.\_TEMP\DECOMPILED\]]..file
              if IsFileExist(src) then
                if _bCreateMapFileTree ~= nil then
                  if _bReCreateMapFileTree == "Y" then
                    local tmpMFT = "..\\MapFileTrees\\"..string.gsub(file,[[\]],[[.]])
                    pv("tmpMFT = ["..tmpMFT.."]")
                    os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..tmpMFT..[[.txt" 1>NUL 2>NUL]])
                    os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..tmpMFT..[[.lua" 1>NUL 2>NUL]])
                  end
                  
                  if _bAllowMapFileTreeCreator == "Y" then
                    print("    MapFileTree creation/update on 2nd thread...")
                    Report("","    MapFileTree creation/update done by 2nd thread")
                    
                    --copy it to a temp folder for processing
                    --because it may be removed later before creation is started/completed
                    local src = [[.\_TEMP\DECOMPILED\]]..file
                    local dest = [[.\_TEMP_MAP\]]..file
                    CopyFile(src,dest)
                    
                    if IsFileExist([[MapFileTreeSharedList.txt]]) then
                      WriteToFileAppend(file.."\n",[[MapFileTreeSharedList.txt]])
                    else
                      WriteToFile(file.."\n",[[MapFileTreeSharedList.txt]])
                    end
                    
                  else
                    --MAIN thread processing
                    DisplayMapFileTreeEXT(ParseTextFileIntoTable([[.\_TEMP\DECOMPILED\]]..file),file)
                  end
                  
                else
                  print("    Skipping MapFileTree creation/update")
                  -- Report("","    Skipping MapFileTree creation/update")
                end
                
              else
                print("    Skipping MapFileTree creation/update, comes from a PAK")
                Report("","    Skipping MapFileTree creation/update, comes from a PAK")
              end
              --=================== end create MapFileTrees ========================
              
              local ReplaceNumber = 0
              local ADDNumber = 0
              local REMOVENumber = 0
              
              if MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"] ~= nil then
                AtLeastOne_EXML_CHANGE_TABLE = true
                MissingCurlyBracketsWarning = false
                if type(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][1]) ~= "table" then
                  MissingCurlyBracketsWarning = true
                end
              
                local EXML_CHANGE_TABLE = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"]

                -- print(";;; EXML_CHANGE_TABLE "..n..", "..m)
                -- for k,v in pairs(EXML_CHANGE_TABLE) do
                  -- print(k,type(v))
                -- end
                -- print(";;;")

                if EXML_CHANGE_TABLE ~= nil then
                  if type(EXML_CHANGE_TABLE) == "string" then
                    print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE entry is a STRING, verify your script]].._zDEFAULT)
                    Report("",[[>>> EXML_CHANGE_TABLE entry is a STRING, verify your script]],"WARNING")          
                    EXML_CHANGE_TABLE_fields_IsString = true
                    break
                  else
                    if type(EXML_CHANGE_TABLE) ~= "table" then
                      -- print("EXML_CHANGE_TABLE = "..type(EXML_CHANGE_TABLE))
                      print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]].._zDEFAULT)
                      Report("",[[>>> EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]],"WARNING")
                      break
                    else
                      if #EXML_CHANGE_TABLE == 0 then
                        print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]].._zDEFAULT)
                        Report("",[[>>> EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]],"WARNING")          
                      end
                    end
                  end
                
                end
                
                for i=1,#EXML_CHANGE_TABLE do
                  -- print("In EXML_CHANGE_TABLE for loop #"..i)
                  --local EXML_CHANGE_TABLE_fields = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]

                  local EXML_CHANGE_TABLE_fields = EXML_CHANGE_TABLE[i]
                  
                  EXML_CHANGE_TABLE_fields_IsTableOfTables = true
                  if EXML_CHANGE_TABLE_fields == nil then
                    print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE entry is NIL, verify your script]].._zDEFAULT)
                    Report("",[[>>> EXML_CHANGE_TABLE entry is NIL, verify your script]],"WARNING")          
                    EXML_CHANGE_TABLE_fields_IsNil = true
                    break
                  else

                    -- print(";;; EXML_CHANGE_TABLE "..n..", "..m..", "..i)
                    -- for k,v in pairs(EXML_CHANGE_TABLE_fields) do
                      -- print(k,type(v))
                    -- end
                    -- print(";;;")

                    -- print("EXML_CHANGE_TABLE_fields = "..type(EXML_CHANGE_TABLE_fields))
                    if type(EXML_CHANGE_TABLE_fields) ~= "table" then
                      print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]].._zDEFAULT)
                      Report("",[[>>> EXML_CHANGE_TABLE entry is not a TABLE of TABLES, verify your script]],"WARNING")          
                      EXML_CHANGE_TABLE_fields_IsTableOfTables = false
                    else
                      pv(" ==> type(EXML_CHANGE_TABLE_fields) = "..type(EXML_CHANGE_TABLE_fields))
                      pv(" ==> #EXML_CHANGE_TABLE_fields = "..#EXML_CHANGE_TABLE_fields)
                    end
                  end

                  pv("     ===>> before ExchangePropertyValue(): #TextFileTable = "..#TextFileTable)
                  local moddedFileTable,ReplNumber,ADDcount,REMOVEcount = ExchangePropertyValue(
                        i,
                        FullPathFile,
                        TextFileTable,
                        EXML_CHANGE_TABLE_fields["VALUE_CHANGE_TABLE"],
                        EXML_CHANGE_TABLE_fields["SPECIAL_KEY_WORDS"],
                        EXML_CHANGE_TABLE_fields["PRECEDING_KEY_WORDS"],
                        EXML_CHANGE_TABLE_fields["PRECEDING_FIRST"],
                        EXML_CHANGE_TABLE_fields["FIND_ALL_SECTIONS"],
                        EXML_CHANGE_TABLE_fields["SECTION_UP"],
                        EXML_CHANGE_TABLE_fields["SECTION_UP_SPECIAL"],
                        EXML_CHANGE_TABLE_fields["SECTION_UP_PRECEDING"],
                        EXML_CHANGE_TABLE_fields["SECTION_ACTIVE"],
                        EXML_CHANGE_TABLE_fields["WHERE_IN_SECTION"],
                        EXML_CHANGE_TABLE_fields["WHERE_IN_SUBSECTION"],
                        EXML_CHANGE_TABLE_fields["SAVE_SECTION_TO"],
                        EXML_CHANGE_TABLE_fields["KEEP_SECTION"],
                        EXML_CHANGE_TABLE_fields["ADD_NAMED_SECTION"],
                        EXML_CHANGE_TABLE_fields["EDIT_SECTION"],
                        EXML_CHANGE_TABLE_fields["MATH_OPERATION"],
                        EXML_CHANGE_TABLE_fields["INTEGER_TO_FLOAT"],
                        global_integer_to_float,
                        EXML_CHANGE_TABLE_fields["VALUE_MATCH"],
                        EXML_CHANGE_TABLE_fields["REPLACE_TYPE"],
                        EXML_CHANGE_TABLE_fields["VALUE_MATCH_TYPE"],
                        EXML_CHANGE_TABLE_fields["VALUE_MATCH_OPTIONS"],
                        EXML_CHANGE_TABLE_fields["LINE_OFFSET"],
                        EXML_CHANGE_TABLE_fields["ADD_OPTION"],
                        EXML_CHANGE_TABLE_fields["ADD"],
                        EXML_CHANGE_TABLE_fields["REMOVE"],
                        EXML_CHANGE_TABLE_fields["FOREACH_SPECIAL_KEY_WORDS_PAIR"],
                        EXML_CHANGE_TABLE_fields_IsTableOfTables,
                        MissingCurlyBracketsWarning
                      )					
                  pv("     ===>> after ExchangePropertyValue(): #moddedFileTable = "..#moddedFileTable)
                  TextFileTable = moddedFileTable --update TextFileTable for next iteration

                  ReplaceNumber = ReplaceNumber + ReplNumber
                  ADDNumber = ADDNumber + ADDcount
                  REMOVENumber = REMOVENumber + REMOVEcount
                end
                
                if EXML_CHANGE_TABLE_fields_IsNil or EXML_CHANGE_TABLE_fields_IsString then
                  break
                end
                
                print("")
                print(_zGREEN.."   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =".._zDEFAULT)
                print(_zGREEN.."                Ended processing of MODIFICATIONS["..n.."]["..m.."]".._zDEFAULT)

                if ADDNumber > 0 then
                  Report(ADDNumber.." ADD(s) made","  Ended processing with")
                  print("    >>>>> "..ADDNumber.." ADD(s) made")
                end

                if REMOVENumber > 0 then
                  Report(REMOVENumber.." REMOVE(s) made","  Ended processing with")
                  print("    >>>>> "..REMOVENumber.." REMOVE(s) made")
                end

                if (ADDNumber > 0 or REMOVENumber > 0 ) and ReplaceNumber > 0 then
                  Report(ReplaceNumber.." CHANGE(s) made","  Ended processing with")
                  print("    >>>>> "..ReplaceNumber.." CHANGE(s) made")
                end

                Report(file,"  File ")
                Report("","  Ended with a total of "..(ReplaceNumber + ADDNumber + REMOVENumber).." action(s) made")
                print("    >>>>> Ended with a total of "..(ReplaceNumber + ADDNumber + REMOVENumber).." action(s) made\n")
                NumReplacements = NumReplacements + ReplaceNumber + ADDNumber + REMOVENumber

                if THIS == "In TestReCreatedScript: " then CheckReCreatedEXMLAgainstOrg(file) end
              -- else
                -- NoEXML_CHANGE_TABLE = true
                -- -- print("[INFO] [\"MODIFICATIONS\"] has no [\"EXML_CHANGE_TABLE\"]")
                -- -- Report("","[\"MODIFICATIONS\"] has no [\"EXML_CHANGE_TABLE\"]")
              end
              -- print("   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            end
            
            --=================== REGEXAFTER ========================
            if MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["REGEXAFTER"] ~= nil then
              local regexafter = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["REGEXAFTER"]
              if type(regexafter) ~= "table" then
                print("")
                print(_zRED..">>> [ERROR] REGEXAFTER is not a table, please correct your script".._zDEFAULT)
                Report("","REGEXAFTER is not a table, please correct your script","ERROR")
              end
              for i=1,#regexafter do
                local ToFindRegex = string.gsub(regexafter[i][1],[[\\]],[[\]])
                ToFindRegex = string.gsub(regexafter[i][1],[["]],[[\"]])
                local ToReplaceRegex = string.gsub(regexafter[i][2],[[\\]],[[\]])
                ToReplaceRegex = string.gsub(regexafter[i][2],[["]],[[\"]])
                if ToFindRegex == nil or ToReplaceRegex == nil then
                  print("")
                  print(_zRED..">>> [ERROR] missing REGEXAFTER member, please correct your script".._zDEFAULT)
                  Report("","missing REGEXAFTER member, please correct your script","ERROR")
                else
                  if ToFindRegex ~= "" then
                    print("")
                    local From = "REGEXAFTER"
                    local Command = [[-i -r "s/]]..ToFindRegex..[[/]]..ToReplaceRegex..[[/" "]]..FullPathFile..[["]]
                    --for debug purposes
                    -- Command = string.sub(Command,4)..[[ > "]]..From..[[_output.txt"]]
                    ExecuteREGEX(From,Command)
                  end
                end
              end
            end
            --=================== end REGEXAFTER ========================
          end --for u=1,#mbin_file_source do
        end --for m=1,#MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"] do
      end
      
      if EXML_CHANGE_TABLE_fields_IsNil or EXML_CHANGE_TABLE_fields_IsString then
        break
      end
      
    end --for n=1,#MOD_DEF["MODIFICATIONS"] do
  end --if MOD_DEF["MODIFICATIONS"]~=nil then

	--Add new files
	if MOD_DEF["ADD_FILES"]~=nil then
    print("")
    print(">>> Adding files:")
    Report("")
    Report("",">>> Adding files:")
		for i=1,#MOD_DEF["ADD_FILES"] do
      local ShortFilenamePath = NormalizePath(MOD_DEF["ADD_FILES"][i]["FILE_DESTINATION"])
      --ShortFilenamePath = string.upper(string.gsub(ShortFilenamePath,[[/]],[[\]]))
--print("1: ShortFilenamePath=["..ShortFilenamePath.."]")
      local FolderPath = gMASTER_FOLDER_PATH .. gLocalFolder .. GetFolderPathFromFilePath(ShortFilenamePath)..[[\]]
--print("2:        FolderPath=["..FolderPath.."]")
			local FilePath = gMASTER_FOLDER_PATH .. gLocalFolder .. ShortFilenamePath
--print("3:          FilePath=["..FilePath.."]")

      local _,count = string.gsub(ShortFilenamePath,[[\]],"")	
			if count > 0 then
        if not FolderExists(string.gsub(FolderPath,[[\]],[[\\]])) then
          print("      create folder: " .. FolderPath)
          Report("","      create folder: " .. FolderPath)
          FolderPath = string.gsub(FolderPath,[[\]],[[\\]])
          CreateFolder(FolderPath)
        end
			end
      
			if MOD_DEF["ADD_FILES"][i]["EXTERNAL_FILE_SOURCE"]==nil or MOD_DEF["ADD_FILES"][i]["EXTERNAL_FILE_SOURCE"]=="" then
        print("     create file in: "..FilePath)
        Report("","     create file in: "..[["]]..FilePath..[["]])
        FilePath = string.gsub(FilePath,[[\]],[[\\]])
				local FileData = MOD_DEF["ADD_FILES"][i]["FILE_CONTENT"]
				WriteToFile(string.gsub(FileData,"\n","",1), FilePath)
        
			else
        local FilePathSource = ""
        if string.sub(MOD_DEF["ADD_FILES"][i]["EXTERNAL_FILE_SOURCE"],2,2) == ":" then
          --we have a complete path
          FilePathSource = MOD_DEF["ADD_FILES"][i]["EXTERNAL_FILE_SOURCE"]
        else
          --path is relative to ModScript folder
          FilePathSource = GetFolderPathFromFilePath(LoadFileData("CurrentModScript.txt")) .. [[\]] .. MOD_DEF["ADD_FILES"][i]["EXTERNAL_FILE_SOURCE"]
        end
        
        FilePathSource = NormalizePath(FilePathSource,[[/]],[[\]])
--print("4: ["..FilePathSource.."]")

        --local newFilename = string.upper(GetFilenameFromFilePath(MOD_DEF["ADD_FILES"][i]["FILE_DESTINATION"]))
        local newFilename = GetFilenameFromFilePath(ShortFilenamePath)
        
        if newFilename == nil or newFilename == "" then
          --use current name
          local currentFilename = GetFilenameFromFilePath(FilePathSource)
          local currentFilenamePath = string.gsub(FolderPath..[[\]]..currentFilename,[[\\]],[[\]])
          print("        create file: "..currentFilenamePath)
          Report("","        create file: "..[["]]..currentFilenamePath..[["]])
--print("currentFilename = ["..currentFilename.."]")
          local cmd = [[xcopy /y /h /v /i "]]..FilePathSource..[[" "]]..FolderPath..[[*"]]
          NewThread(cmd)
        else
          --use new destination filename
          local newFilenamePath = string.gsub(FolderPath..[[\]]..newFilename,[[\\]],[[\]])
          print("        create file: "..newFilenamePath)
          Report("","        create file: "..[["]]..newFilenamePath..[["]])
--print("newFilename = ["..newFilename.."]")
          local cmd = [[xcopy /y /h /v /i "]]..FilePathSource..[[" "]]..newFilenamePath..[[*"]]
          NewThread(cmd)
        end
			end
			NumFilesAdded=NumFilesAdded+1
		end
    print("\n    >>>>> Ended with "..NumFilesAdded .. " files added <<<<<\n")
    Report("","\n    >>>>> Ended with "..NumFilesAdded .. " files added <<<<<\n")
	end
  
  if AtLeastOne_EXML_CHANGE_TABLE and MOD_DEF["MODIFICATIONS"]~=nil and NumReplacements == 0 then
    print(_zRED..">>> [WARNING] No replacement done. Please verify your script, if not intended".._zDEFAULT)
    Report(say," No replacement done. Please verify your script, if not intended","WARNING")
  end
  if MOD_DEF["ADD_FILES"]~=nil and NumFilesAdded == 0 then
    if #MOD_DEF["ADD_FILES"] >= 1 and MOD_DEF["ADD_FILES"][1]["FILE_DESTINATION"] ~= "" then
      print(_zRED..">>> [WARNING] No file added. Please verify your script".._zDEFAULT)
      Report(say," No file added. Please verify your script","WARNING")
    end
  end
  
  if AtLeastOne_EXML_CHANGE_TABLE then
    if Multi_pak then
      Report(NumReplacements.." action(s), "..NumFilesAdded .. " files added","Ended sub-script processing with")
    else
      Report(NumReplacements.." action(s), "..NumFilesAdded .. " files added","Ended script processing with")
    end
    
    print("\n*************************************************************************")
    print("    >>>>> Ended all with "..NumReplacements.." action(s) made and "..NumFilesAdded .. " files added <<<<<")
    print("*************************************************************************\n")
  end
  
  pv(THIS.."From end of HandleModScript()")
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function CheckReCreatedEXMLAgainstOrg(file)
  -- now we can compare the ORIG_MOD with this ReCreated_MOD
  --if the SAME then SUCCESS
  --else report FAILURE
  pv(THIS.."From CheckReCreatedEXMLAgainstOrg()")
  print("")
  -- Report("")
  -- *file (ORG EXML)        gMASTER_FOLDER_PATH..[[\SCRIPTBUILDER\MOD\]]..string.gsub(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["MBIN_FILE_SOURCE"],"%.MBIN",".EXML"),
  local temp = gMASTER_FOLDER_PATH..gLocalFolder..file
  -- temp = string.gsub(temp,[[\]],[[\\]]) --no need to do this replacement
  
  local say = temp
  -- because string.gsub pattern does not work with all folder names (ex.: ".")
  if string.find(say,gMASTER_FOLDER_PATH,1,true) ~= nil then
    local start = string.find(say,gMASTER_FOLDER_PATH,1,true)
    say = string.sub(say,1,start - 1)..string.sub(say,string.len(gMASTER_FOLDER_PATH) + start)
  end
  print("           "..say)
  -- Report("","           "..say,"")
  
  local ORIG_MOD = LoadFileData(temp)
  print("  Original MOD is "..string.len(ORIG_MOD).." long")
  Report("","  Original MOD is "..string.len(ORIG_MOD).." long")
  
  temp = string.gsub(temp,gLocalFolder,[[\Modified_PAK\DECOMPILED\]])

  local say = temp
  -- because string.gsub pattern does not work with all folder names (ex.: ".")
  if string.find(say,gMASTER_FOLDER_PATH,1,true) ~= nil then
    local start = string.find(say,gMASTER_FOLDER_PATH,1,true)
    say = string.sub(say,1,start - 1)..string.sub(say,string.len(gMASTER_FOLDER_PATH) + start)
  end
  print("     "..say)
  -- Report("","     "..say,"")
  
  local ReCreated_MOD = LoadFileData(temp)
  print("Re-Created MOD is "..string.len(ReCreated_MOD).." long")
  Report("","Re-Created MOD is "..string.len(ReCreated_MOD).." long")
  
  ResultsCreatingScript[#ResultsCreatingScript + 1] = {}
  ResultsCreatingScript[#ResultsCreatingScript][1] = file

  if ReCreated_MOD == ORIG_MOD then
    ResultsCreatingScript[#ResultsCreatingScript][2] = "Success"
    print("\n      ********************************************************************************")
    print("\n      >>>>>>>>>>>>  Script MOD creation SUCCEEDED, BOTH FILES IDENTICAL!  <<<<<<<<<<<<")
    print("\n      ********************************************************************************")
    Report("",">>>>>>>>>>>>  Script MOD creation SUCCEEDED, BOTH FILES IDENTICAL!  <<<<<<<<<<<<","SUCCESS")
  else
    ResultsCreatingScript[#ResultsCreatingScript][2] = "Failure"
    print("\n      --------------------------------------------------------")
    print("\n      XXXXXXXXXXXX  Script MOD creation FAILURE!  XXXXXXXXXXXX")
    print("\n      --------------------------------------------------------")
    Report("","XXXXXXXXXXXX  Script MOD creation FAILURE!  XXXXXXXXXXXX","ERROR")
  end
  print()
  Report("")
  pv(THIS.."From end of CheckReCreatedEXMLAgainstOrg()")
end

--***************************************************************************************************
function GetSpecKeyWordsInfo(spec_key_words)
  local Info = ""
  for i=1,#spec_key_words,2 do
    Info = Info.."(["..spec_key_words[i].."],["..spec_key_words[i+1].."]), "
  end
  Info = string.sub(Info,1,-3)
  return Info
end

--***************************************************************************************************
function GetPrecKeyWordsInfo(prec_key_words)
  local Info = ""
  for i=1,#prec_key_words do
    Info = Info.."["..prec_key_words[i].."], "
  end
  return string.sub(Info,1,#Info - 2)
end

--***************************************************************************************************
function GetWhereInSectionInfo(WhereKeyWords)
  local Info = ""
  for i=1,#WhereKeyWords,2 do
    Info = Info.."(["..WhereKeyWords[i][1].."],["..WhereKeyWords[i][2].."]), "
  end
  Info = string.sub(Info,1,-3)
  return Info
end
--***************************************************************************************************

--***************************************************************************************************
function GetWhereInSubSectionInfo(SubWhereKeyWords)
  local Info = ""
  for i=1,#SubWhereKeyWords,2 do
    Info = Info.."(["..SubWhereKeyWords[i][1].."],["..SubWhereKeyWords[i][2].."]), "
  end
  Info = string.sub(Info,1,-3)
  return Info
end
--***************************************************************************************************

--***************************************************************************************************
function GoUPToOwnerStart(TextFileTable,lineInSection)
  local level = 0
  local OwnerStartLine = 0
  for i=lineInSection-1,1,-1 do
    local Orgline = TextFileTable[i]
    if string.find(Orgline,[[/>]],1,true) ~= nil then
      --skip this line, never an owner
    else
      if string.find(Orgline,[[">]],1,true) ~= nil then
        level = level - 1
      elseif string.find(Orgline,[[/Property>]],1,true) ~= nil then
        --always the end of a group
        level = level + 1
      end
      if level == -1 then
        --owner start line found
        OwnerStartLine = i
        break
      end
    end
  end
  -- pv("   U.OwnerStartLine = "..OwnerStartLine)
  return OwnerStartLine
end
--***************************************************************************************************

--***************************************************************************************************
function GoDownToOwnerEnd(TextFileTable,lineInSection)
  local level = 0
  local OwnerEndLine = 0
  -- pv("      D.lineInSection = "..lineInSection)
  for i=lineInSection,#TextFileTable do
    local Orgline = TextFileTable[i]
    if string.find(Orgline,[[/>]],1,true) ~= nil then
      --skip this line, never an owner
    else
      if string.find(Orgline,[[/Property>]],1,true) ~= nil then
        --always the end of a group
        level = level - 1
      elseif string.find(Orgline,[[">]],1,true) ~= nil then
        level = level + 1
      end
      if level == -1 then
        --owner end line found
        OwnerEndLine = i
        break
      end
    end
  end
  -- pv("      D.OwnerEndLine = "..OwnerEndLine)
  assert(OwnerEndLine ~= nil,"FindGroup:GoDownToOwnerEnd:OwnerEndLine == nil")
  if OwnerEndLine == 0 then OwnerEndLine = #TextFileTable end
  return OwnerEndLine
end
--***************************************************************************************************

--***************************************************************************************************
function MapFileTreeSharedListPING()
  if IsFileExist([[MapFileTreeSharedList.txt]]) then
    WriteToFileAppend("PING".."\n",[[MapFileTreeSharedList.txt]])
  end
end

-- *************************************** handles generic SECTION_UP *******************************************
function Process_SectionUP(FileTable,GroupStartLine,GroupEndLine,KeyWordLine,section_up)
  -- pv("")
  -- pv([[D ]]..#GroupStartLine..[[ ]]..#GroupEndLine..[[ ]])
  if section_up > 0 then
    -- pv("Processing SECTION_UP = "..section_up)
    for n =1,#GroupStartLine do
      local Section_UP = section_up
      local currentLine = GroupStartLine[n]
      -- pv("  SECTION_UP: Current line = "..currentLine)
      repeat
        GroupStartLine[n] = GoUPToOwnerStart(FileTable,currentLine)
        GroupEndLine[n] = GoDownToOwnerEnd(FileTable,GroupStartLine[n]+1)
        KeyWordLine[n] = KeyWordLine[n] --stays the same
        currentLine = GroupStartLine[n]
        Section_UP = Section_UP - 1
      until Section_UP == 0 
    end          
  end
  return GroupStartLine,GroupEndLine,KeyWordLine
end 
-- *************************************** END: handles generic SECTION_UP **************************************
    
--ExchangePropertyValue(...
--[=[
ExchangePropertyValue(
*item                       ,i
*file (ORG EXML)            ,FullPathFile, aka: gMASTER_FOLDER_PATH..gLocalFolder..string.gsub(MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["MBIN_FILE_SOURCE"],".MBIN",".EXML")
*FileTable                  ,the TextFileTable 'table' containing the file above
*value_change_table         ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["VALUE_CHANGE_TABLE"]
*special_key_words          ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SPECIAL_KEY_WORDS"]
*preceding_key_words        ,PRECEDING_KEY_WORDS_SUB [==]PRECEDING_KEY_WORDS_SUB = MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["PRECEDING_KEY_WORDS"][==]

preceding_first             ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["PRECEDING_FIRST"]
find_all_sections           ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["FIND_ALL_SECTIONS"]
section_up                  ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SECTION_UP"]
section_up_special          ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SECTION_UP_SPECIAL"]
section_up_preceding        ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SECTION_UP_PRECEDING"]
section_active              ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SECTION_ACTIVE"]
where_key_words             ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["WHERE_IN_SECTION"]
subwhere_key_words          ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["WHERE_IN_SUBSECTION"]

save_section_to             ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["SAVE_SECTION_TO"]
keep_section                ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["KEEP_SECTION"]
add_named_section                 ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["ADD_NAMED_SECTION"]
edit_section                ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["EDIT_SECTION"]

math_operation              ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["MATH_OPERATION"]
integer_to_float            ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["INTEGER_TO_FLOAT"]
global_integer_to_float     ,global_integer_to_float

value_match                 ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["VALUE_MATCH"]
replace_type                ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["REPLACE_TYPE"]
value_match_type            ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["VALUE_MATCH_TYPE"]
value_match_options         ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["VALUE_MATCH_OPTIONS"]

line_offset                 ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["LINE_OFFSET"]
add_option                  ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["ADD_OPTION"]
text_to_add                 ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["ADD"]
to_remove                   ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["REMOVE"]
foreach_SKWP                ,MOD_DEF["MODIFICATIONS"][n]["MBIN_CHANGE_TABLE"][m]["EXML_CHANGE_TABLE"][i]["FOREACH_SPECIAL_KEY_WORDS_PAIR"]

EXML_CHANGE_TABLE_fields_IsTableOfTables        ,EXML_CHANGE_TABLE_fields_IsTableOfTables
MissingCurlyBracketsWarning ,MissingCurlyBracketsWarning
)
* = needed for SCRIPTBUILDER script.lua					
--]=]

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--called each time with all property/value combo in value_change_table
function ExchangePropertyValue(item,file,FileTable,value_change_table,special_key_words,preceding_key_words
          ,preceding_first,find_all_sections,section_up,section_up_special,section_up_preceding,section_active,where_key_words,subwhere_key_words
          ,save_section_to,keep_section,add_named_section,edit_section
          ,math_operation,integer_to_float,global_integer_to_float
          ,value_match,replace_type,value_match_type,value_match_options
          ,line_offset,add_option,text_to_add,to_remove,foreach_SKWP
          ,EXML_CHANGE_TABLE_fields_IsTableOfTables,MissingCurlyBracketsWarning)

  print("")
  print(_zGREEN.."   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -".._zDEFAULT)
  print(_zGREEN.."                processing EXML_CHANGE_TABLE["..item.."], please wait...".._zDEFAULT)
  
  if not EXML_CHANGE_TABLE_fields_IsTableOfTables then
    pv("WBERTRO: THIS SHOULD BE INVESTIGATED")
    print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE first entry is a 'table of tables' instead of a simple table: probably too many {} in your script"]].._zDEFAULT)
    print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
    Report("",[[>>> EXML_CHANGE_TABLE first entry is a 'table of tables' instead of a simple table: probably too many {} in your script]],"WARNING")
    Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
  end
          
  if MissingCurlyBracketsWarning then
    print(_zRED..[[>>> [WARNING] EXML_CHANGE_TABLE first entry is Missing Curly Brackets, in your script"]].._zDEFAULT)
    print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
    Report("",[[>>> EXML_CHANGE_TABLE first entry is Missing Curly Brackets, in your script]],"WARNING")
    Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
  end
          
  -- *****************   IsMath_Operation section   ********************
  local IsMath_Operation = false
  if math_operation == nil then math_operation = "" end
  if string.len(math_operation) > 0 then
    IsMath_Operation = true
  end
  --***************************************************************************************************  
  
  -- *****************   value_change_table section   ********************
  local val_change_table = {{"",""}}
  local IsChangeTable = false
  
  if value_change_table == nil then
    val_change_table[1][1] = "IGNORE"
    val_change_table[1][2] = "IGNORE"
  else 
    if type(value_change_table) ~= "table" then
      --not a table, just one word
      if value_change_table == "" then
        val_change_table[1][1] = "IGNORE"
        val_change_table[1][2] = "IGNORE"
      else
        --Make it a table, we want a table!
        val_change_table[1][1] = value_change_table
        val_change_table[1][2] = value_change_table
      end
    else
      --already a table, use it
      if type(value_change_table[1]) ~= "table" then
        --problem, not a table of tables
        print(_zRED..[[>>> [WARNING] this VALUE_CHANGE_TABLE entry is NOT a 'table of tables': check your script"]].._zDEFAULT)
        print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
        Report("",[[>>> this VALUE_CHANGE_TABLE entry is NOT a 'table of tables': check your script]],"WARNING")
        Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
        value_change_table = nil
      else
        val_change_table = value_change_table
      end      
    end
  end
  
  if (#val_change_table > 0) and (val_change_table[1] ~= "" or val_change_table[2] ~= "") then
    IsChangeTable = true
  end

  for i=1,#val_change_table do
    val_change_table[i][1] = tostring(val_change_table[i][1])
    pv(val_change_table[i][1])
    if val_change_table[i][1] == "nil" then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] In your script, a VALUE_CHANGE_TABLE "Property name/value" below is NIL, please correct!]].._zDEFAULT)
      print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
      Report("",[[>>> In your script, a VALUE_CHANGE_TABLE "Property name/value" below is NIL, please correct!]],"ERROR")
      Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
      if IsMath_Operation then
        val_change_table[i][1] = "0" --to prevent a crash
      else
        val_change_table[i][1] = "NIL" --to prevent a crash
      end
    end
    val_change_table[i][2] = tostring(val_change_table[i][2])
    pv(val_change_table[i][2])
    if val_change_table[i][2] == "nil" then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] In your script, VALUE_CHANGE_TABLE "newvalue" (for "]]..val_change_table[i][1]..[[" below) is NIL, please correct!]].._zDEFAULT)
      print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
      Report("",[[>>> In your script VALUE_CHANGE_TABLE "newvalue" (for "]]..val_change_table[i][1]..[[" below) is NIL, please correct!]],"ERROR")
      Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
      if IsMath_Operation then
        val_change_table[i][2] = "NIL" --to prevent a crash
      else
        val_change_table[i][2] = "NIL" --to prevent a crash
      end
    end
    val_change_table[i][1] = string.gsub(val_change_table[i][1],[[\\]],[[\]])
    val_change_table[i][2] = string.gsub(val_change_table[i][2],[[\\]],[[\]])
  end
  
  --  *******************************************************
  -- FROM HERE ON [value_change_table] is know as [val_change_table] (a table)
  --  *******************************************************
  
  -- *****************   integer_to_float section   ********************
  if integer_to_float == nil  or integer_to_float == "" then
    integer_to_float = global_integer_to_float
  end
  integer_to_float = string.upper(integer_to_float)
  
  local IsInteger_to_floatDeclared = (integer_to_float ~= "")
  local IsInteger_to_floatPRESERVE = (integer_to_float == "PRESERVE")
  local IsInteger_to_floatFORCE = (integer_to_float == "FORCE")
  if IsInteger_to_floatDeclared and not (IsInteger_to_floatPRESERVE or IsInteger_to_floatFORCE) then
    print(_zRED..[[>>> [WARNING] INTEGER_TO_FLOAT value is incorrect, should be "", "FORCE" or "PRESERVE"]].._zDEFAULT)
    Report(integer_to_float,[[>>> INTEGER_TO_FLOAT value is incorrect, should be "", "FORCE" or "PRESERVE"]],"WARNING")
  end
    
    -- *****************   save_section_to section   ********************
  if save_section_to == nil then
    save_section_to = "" 
  end
  local IsSaveSectionTo = (save_section_to ~= "")
  if save_section_to ~= "" and tonumber(save_section_to) ~= nil then 
    print(_zRED..[[>>> [WARNING] SAVE_SECTION_TO is not a valid user_name_of_section STRING, it won't be used!]].._zDEFAULT)
    Report(save_section_to,[[>>> SAVE_SECTION_TO is not a valid user_name_of_section STRING, it won't be used!]],"WARNING")
    save_section_to = ""
  end
  
  if IsSaveSectionTo then
    gSaveSectionName[#gSaveSectionName+1] = save_section_to
    gSaveSectionContent[#gSaveSectionContent+1] = ""
  end
  
  -- *****************   keep_section section   ********************
  if keep_section == nil then
    keep_section = "" 
  end
  keep_section = string.upper(keep_section)
  
  local IsKeepSection = (keep_section ~= "")
  local IsKeepSectionTRUE = (keep_section == "TRUE")
  local IsKeepSectionFALSE = (keep_section == "FALSE")
  if IsKeepSection and not (IsKeepSectionTRUE or IsKeepSectionFALSE) then
    print(_zRED..[[>>> [WARNING] KEEP_SECTION value is incorrect, should be "", "TRUE" or "FALSE"]].._zDEFAULT)
    Report(keep_section,[[>>> KEEP_SECTION value is incorrect, should be "", "TRUE" or "FALSE"]],"WARNING")
  end
  
  IsKeepSection = IsKeepSectionTRUE
  
  -- *****************   add_named_section section   ********************
  if add_named_section == nil then
    add_named_section = "" 
  end
  local IsUseSection = (add_named_section ~= "")
  if add_named_section ~= "" and tonumber(add_named_section) ~= nil then 
    print(_zRED..[[>>> [WARNING] ADD_NAMED_SECTION is not a valid user_name_of_section STRING, it won't be used!]].._zDEFAULT)
    Report(add_named_section,[[>>> ADD_NAMED_SECTION is not a valid user_name_of_section STRING, it won't be used!]],"WARNING")
    add_named_section = ""
  end
  
  if IsUseSection then
    --check if this section name already exist in internal gUseSectionName list
    local SectionAlreadyExist = false
    for m=1,#gUseSectionName do
      if gUseSectionName[m] == add_named_section then
        --nothing more to do right now
        print("@@@@@ Found add_named_section in internal gUseSectionName list")
        SectionAlreadyExist = true
        break
      end
    end
    
    if not SectionAlreadyExist then        
      --check if it is in the internal SAVE_SECTION_TO list
      local found = false
      for m=1,#gSaveSectionName do
        if gSaveSectionName[m] == add_named_section then
          --retrieve the section
          print("@@@@@ Found add_named_section in the internal SAVE_SECTION_TO list")
          gUseSectionName[#gUseSectionName+1] = add_named_section
          gUseSectionContent[#gUseSectionContent+1] = gSaveSectionContent[m]
          found = true
          break
        end
      end
      
      if not found then
        --try to read back the lines from a file in the SavedSections folder using the ADD_NAMED_SECTION name.txt
        if IsFileExist(gMASTER_FOLDER_PATH..[[SavedSections\]]..add_named_section..[[.txt]]) then
          print("@@@@@ Found add_named_section in a file in the SavedSections folder using the ADD_NAMED_SECTION name.txt")
          gUseSectionName[#gUseSectionName+1] = add_named_section
          gUseSectionContent[#gUseSectionContent+1] = LoadFileData(gMASTER_FOLDER_PATH..[[SavedSections\]]..add_named_section..[[.txt]])
        else
          --no such named section exist
          print("@@@@@ DID NOT find specified ADD_NAMED_SECTION: BAD NAME?")
          gUseSectionName[#gUseSectionName+1] = add_named_section
          gUseSectionContent[#gUseSectionContent+1] = ""
        end
      end
    end
  end
  -- *****************  END: add_named_section section   ********************
  
  -- *****************   edit_section section   ********************
  if edit_section == nil then
    edit_section = "" 
  end
  local IsEditSection = (edit_section ~= "")
  if edit_section ~= "" and tonumber(edit_section) ~= nil then 
    print(_zRED..[[>>> [WARNING] EDIT_SECTION is not a valid user_name_of_section STRING, it won't be used!]].._zDEFAULT)
    Report(edit_section,[[>>> EDIT_SECTION is not a valid user_name_of_section STRING, it won't be used!]],"WARNING")
    edit_section = ""
  end
  
  if IsEditSection then
    --check if this section name already exist in internal gUseSectionName list
    local SectionAlreadyExist = false
    for m=1,#gUseSectionName do
      if gUseSectionName[m] == edit_section then
        --nothing more to do right now
        print("@@@@@ Found edit_section in internal gUseSectionName list")
        SectionAlreadyExist = true
        break
      end
    end
    
    if not SectionAlreadyExist then        
      --check if it is in the internal SAVE_SECTION_TO list
      local found = false
      for m=1,#gSaveSectionName do
        if gSaveSectionName[m] == edit_section then
          --retrieve the section
          print("@@@@@ Found edit_section in the internal SAVE_SECTION_TO list")
          gUseSectionName[#gUseSectionName+1] = edit_section
          gUseSectionContent[#gUseSectionContent+1] = gSaveSectionContent[m]
          found = true
          break
        end
      end
      
      if not found then
        --try to read back the lines from a file in the SavedSections folder using the ADD_NAMED_SECTION name.txt
        if IsFileExist(gMASTER_FOLDER_PATH..[[SavedSections\]]..edit_section..[[.txt]]) then
          print("@@@@@ Found edit_section in a file in the SavedSections folder using the EDIT_SECTION name.txt")
          gUseSectionName[#gUseSectionName+1] = edit_section
          gUseSectionContent[#gUseSectionContent+1] = LoadFileData(gMASTER_FOLDER_PATH..[[SavedSections\]]..edit_section..[[.txt]])
        else
          --no such named section exist
          print("@@@@@ DID NOT find specified EDIT_SECTION: BAD NAME?")
          gUseSectionName[#gUseSectionName+1] = edit_section
          gUseSectionContent[#gUseSectionContent+1] = ""
          
          --even it it was requested, we cannot edit this named section
          IsEditSection = false
        end
      end
    end
  end
  -- *****************  END: edit_section section   ********************
  
  -- *****************   text_to_add section   ********************
  if text_to_add == nil then
    text_to_add = "" 
  end
  text_to_add = string.gsub(text_to_add,[[\\]],[[\]])
  local IsTextToAdd = (text_to_add ~= "")
  -- *****************  END: text_to_add section   ********************
  
  -- *****************   to_remove section   ********************
  if to_remove == nil then
    to_remove = "" 
  end

  to_remove = string.upper(to_remove)
  
  local IsToRemove = (to_remove ~= "")
  local IsToRemoveLINE = (to_remove == "LINE")
  local IsToRemoveSECTION = (to_remove == "SECTION")
  if IsToRemove and not (IsToRemoveLINE or IsToRemoveSECTION) then
    print(_zRED..[[>>> [WARNING] REMOVE value is incorrect, should be "", "LINE" or "SECTION"]].._zDEFAULT)
    Report(to_remove,[[>>> REMOVE value is incorrect, should be "", "LINE" or "SECTION"]],"WARNING")
  elseif IsTextToAdd and IsToRemove then
    print(_zRED..[[>>> [WARNING] BOTH ADD and REMOVE are used in this EXML_CHANGE_TABLE section]].._zDEFAULT)
    Report("",[[>>> BOTH ADD and REMOVE are used in this EXML_CHANGE_TABLE section]],"WARNING")
  end
  -- *****************  END: to_remove section   ********************
    
  -- *****************   preceding_first section   ********************
  if preceding_first == nil then
    preceding_first = "" 
  end
  preceding_first = string.upper(preceding_first)
  
  local IsPrecedingFirst = (preceding_first ~= "")
  
  local IsPrecedingFirstTRUE = (preceding_first == "TRUE")
  local IsPrecedingFirstFALSE = (preceding_first == "FALSE")
  if IsPrecedingFirst and not (IsPrecedingFirstTRUE or IsPrecedingFirstFALSE) then
    print(_zRED..[[>>> [WARNING] PRECEDING_FIRST value is incorrect, should be "", "TRUE" or "FALSE"]].._zDEFAULT)
    Report(preceding_first,[[>>> PRECEDING_FIRST value is incorrect, should be "", "TRUE" or "FALSE"]],"WARNING")
  end

  -- *****************   find_all_sections section   ********************
  if find_all_sections == nil then
    find_all_sections = "" 
  end
  find_all_sections = string.upper(find_all_sections)
  
  local IsFindAllSections = (find_all_sections ~= "")
  
  local IsFindAllSectionsTRUE = (find_all_sections == "TRUE")
  local IsFindAllSectionsFALSE = (find_all_sections == "FALSE")
  if IsFindAllSections and not (IsFindAllSectionsTRUE or IsFindAllSectionsFALSE) then
    print(_zRED..[[>>> [WARNING] FIND_ALL_SECTIONS value is incorrect, should be "", "TRUE" or "FALSE"]].._zDEFAULT)
    Report(find_all_sections,[[>>> FIND_ALL_SECTIONS value is incorrect, should be "", "TRUE" or "FALSE"]],"WARNING")
  end

  -- *****************   replace_type section   ********************
  if replace_type == nil then
    replace_type = "" 
  end
  replace_type = string.upper(replace_type)

  -- WBERTRO
  local tmpIsADDAFTERSECTION = false
  if replace_type == "ADDAFTERSECTION" then
    tmpIsADDAFTERSECTION = true
    replace_type = ""
  end

  local IsReplaceALL = (replace_type == "ALL")
  local IsReplaceALLFOLLOWING = (replace_type == "ALLFOLLOWING")
  local IsReplaceRAW = (replace_type == "RAW")
  
  if IsReplaceRAW then
    -- when using RAW, it implies that ALL is used also
    IsReplaceALL = true
  end
  
  -- local IsReplaceADDAFTERSECTION = (replace_type == "ADDAFTERSECTION") and IsTextToAdd
  -- local IsReplaceADDAFTERLINE = (replace_type == "ADDAFTERLINE") and IsTextToAdd
  -- local IsReplaceADDATLINE = (replace_type == "ADDATLINE") and IsTextToAdd

  -- if IsReplaceADDATLINE then
    -- IsToRemove = true
    -- IsToRemoveLINE = true
    -- print([[>>> [INFO] Turning ON automatic current line removal]])
    -- Report(replace_type,[[>>> Turning ON automatic current line removal]],"INFO")    
  -- end

  --Wbertro: ALLFOLLOWING may not be working yet?
  if IsReplaceALLFOLLOWING then
    print(_zRED..[[>>> [NOTICE] REPLACE_TYPE value of "ALLFOLLOWING" may not be working yet]].._zDEFAULT)
    Report(replace_type,[[>>> REPLACE_TYPE value of "ALLFOLLOWING" may not be working yet]],"NOTICE")    
  end
  
  local IsReplace = (replace_type ~= "")
  if IsReplace then
    if not IsTextToAdd and not (IsReplaceALL or IsReplaceALLFOLLOWING or IsReplaceRAW) then
      print(_zRED..[[>>> [WARNING] REPLACE_TYPE value is incorrect, should only be "", "ALL", "ALLFOLLOWING" or "RAW"]].._zDEFAULT)
      Report(replace_type,[[>>> REPLACE_TYPE value is incorrect, should only be "", "ALL", "ALLFOLLOWING" or "RAW"]],"WARNING")
      IsReplace = false
    end
    -- if IsTextToAdd and not (IsReplaceADDAFTERSECTION or IsReplaceADDAFTERLINE or IsReplaceADDATLINE) then
      -- print(_zRED..[[>>> [WARNING] REPLACE_TYPE value is incorrect, should only be "", "ADDatLINE", "ADDafterLINE" or "ADDafterSECTION"]].._zDEFAULT)
      -- Report(replace_type,[[>>> REPLACE_TYPE value is incorrect, should only be "", "ADDatLINE", "ADDafterLINE" or "ADDafterSECTION"]],"WARNING")
    -- end
  end
  
  -- *****************   add_option section   ********************
-- WBERTRO
  if add_option == nil then
    add_option = "" 
  end
  add_option = string.upper(add_option)
  
  if IsTextToAdd then
    if add_option == "" then
      if tmpIsADDAFTERSECTION then
        --for backward compatibility from REPLACE_TYPE
        add_option = "ADDAFTERSECTION"
      else
        --default option
        add_option = "ADDAFTERLINE"
      end
    end
  end
  
  local IsReplaceADDAFTERSECTION = (add_option == "ADDAFTERSECTION") and IsTextToAdd
  local IsReplaceADDAFTERLINE = (add_option == "ADDAFTERLINE") and IsTextToAdd
  local IsReplaceADDATLINE = (add_option == "ADDATLINE") and IsTextToAdd
  
  if IsReplaceADDATLINE then
    IsToRemove = true
    IsToRemoveLINE = true
    print([[>>> [INFO] Turning ON automatic current line removal]])
    Report(replace_type,[[>>> Turning ON automatic current line removal]],"INFO")    
  end

  local IsAddOption = (add_option ~= "")
  if IsAddOption then
    if IsTextToAdd and not (IsReplaceADDAFTERSECTION or IsReplaceADDAFTERLINE or IsReplaceADDATLINE) then
      print(_zRED..[[>>> [WARNING] REPLACE_TYPE value is incorrect, should only be "", "ADDatLINE", "ADDafterLINE" or "ADDafterSECTION"]].._zDEFAULT)
      Report(replace_type,[[>>> REPLACE_TYPE value is incorrect, should only be "", "ADDatLINE", "ADDafterLINE" or "ADDafterSECTION"]],"WARNING")
      IsAddOption = false
    end
  end

  -- *****************   value_match section   ********************
  if value_match == nil then
    value_match = "" 
  end
  value_match = string.gsub(value_match,[[\\]],[[\]])
  local IsValueMatch = (value_match ~= "")
  
  local IsNumberValue_Match, IsIntegerValue_Match = CheckValueType(value_match,IsInteger_to_floatFORCE)
  
  -- *****************   value_match_type section   ********************
  if value_match_type == nil then
    value_match_type = "" 
  end
  value_match_type = string.upper(value_match_type)
  
  local IsValueMatchType = (value_match_type ~= "")
  local IsValueMatchTypeNumber = (value_match_type == "NUMBER")
  local IsValueMatchTypeString = (value_match_type == "STRING")

  if IsValueMatch and IsValueMatchType and not (IsValueMatchTypeNumber or IsValueMatchTypeString) then
    print(_zRED..[[>>> [WARNING] VALUE_MATCH_TYPE value is incorrect, should be "", "NUMBER" or "STRING"]].._zDEFAULT)
    Report(value_match_type,[[>>> VALUE_MATCH_TYPE value is incorrect, should be "", "NUMBER" or "STRING"]],"WARNING")
    IsValueMatchType = false
  end
  
  -- *****************   value_match_options section   ********************
  if value_match_options == nil or value_match_options == "" then
    value_match_options = "=" 
  end
  value_match_options = string.upper(value_match_options)
  
  local IsValueMatchOptions = (value_match_options ~= "")
  local IsValueMatchOptionsMatch = (value_match_options == "=")
  local IsValueMatchOptionsNoMatch = (value_match_options == "~=")
  local IsValueMatchOptionsLSS = (value_match_options == "<")
  local IsValueMatchOptionsLEQ = (value_match_options == "<=")
  local IsValueMatchOptionsGTR = (value_match_options == ">")
  local IsValueMatchOptionsGEQ = (value_match_options == ">=")

  if IsValueMatch and IsValueMatchOptions 
      and not (IsValueMatchOptionsMatch 
            or IsValueMatchOptionsNoMatch
            or IsValueMatchOptionsLSS
            or IsValueMatchOptionsLEQ
            or IsValueMatchOptionsGTR
            or IsValueMatchOptionsGEQ) then
    print(_zRED..[[>>> [WARNING] VALUE_MATCH_OPTIONS value is incorrect, should be "", "=", "~=", "<", "<=", ">" or ">="]].._zDEFAULT)
    Report(IsValueMatchOptions,[[>>> VALUE_MATCH_OPTIONS value is incorrect, should be "", "=", "~=", "<", "<=", ">" or ">="]],"WARNING")
    IsValueMatchOptions = false
  end
  if not IsNumberValue_Match and (
               IsValueMatchOptionsLSS
            or IsValueMatchOptionsLEQ
            or IsValueMatchOptionsGTR
            or IsValueMatchOptionsGEQ) then
    print(_zRED..[[>>> [WARNING] Incorrect value of VALUE_MATCH_OPTIONS used with VALUE_MATCH, should be "", "=" or "~="]].._zDEFAULT)
    Report(IsValueMatchOptions,[[>>> Incorrect value of VALUE_MATCH_OPTIONS used with VALUE_MATCH, should be "", "=" or "~="]],"WARNING")
    IsValueMatchOptions = false
  end
  
  --***************************************************************************************************  
  local function CheckValueMatchOptions(value_match,value)
    local result = false
    local valueIsNumber, valueIsInteger = CheckValueType(value,false)
    local value_matchIsNumber, value_matchIsInteger = CheckValueType(value_match,false)
    
    local IsNumber = false
    local IsString = false
    if valueIsNumber and value_matchIsNumber then
      --ok to compare as NUMBER
      IsNumber = true
      if not valueIsInteger then
        value = string.round(value)
        value_match = string.round(value_match)        
      end
    elseif not valueIsNumber and not value_matchIsNumber then
      --ok to compare as STRING
      IsString = true
    end
    
    if IsString then
      if IsValueMatchOptionsMatch then
        result = (value == value_match)
      elseif IsValueMatchOptionsNoMatch then
        result = (value ~= value_match)
      end
    elseif IsNumber then
      if IsValueMatchOptionsMatch then
        result = (tonumber(value) == tonumber(value_match))
      elseif IsValueMatchOptionsNoMatch then
        result = (tonumber(value) ~= tonumber(value_match))
      elseif IsValueMatchOptionsLSS then
        result = (tonumber(value) < tonumber(value_match))
      elseif IsValueMatchOptionsLEQ then
        result = (tonumber(value) <= tonumber(value_match))
      elseif IsValueMatchOptionsGTR then
        result = (tonumber(value) > tonumber(value_match))
      elseif IsValueMatchOptionsGEQ then
        result = (tonumber(value) >= tonumber(value_match))
      end
    end
    return result
  end

  -- *****************   IsLineOffset section   ********************
  local IsLineOffset = (line_offset ~= nil and line_offset ~= "")
  local line_offsetNumber = (tonumber(line_offset) or math.huge)
  if IsLineOffset and line_offsetNumber == math.huge then
    print(_zRED..[[>>> [WARNING] LINE_OFFSET value type is incorrect, should be "" or "+/- a number"]].._zDEFAULT)
    Report(line_offset,[[>>> LINE_OFFSET value type is incorrect, should be "" or "+/- a number"]],"WARNING")
  end
  
  local offset = 0
  local offset_sign = "+"
  if IsLineOffset then
    if line_offsetNumber < 0 then
      offset_sign = "-"
    end
    offset = math.abs(math.tointeger(line_offsetNumber))
  end
  if offset == 0 then
    IsLineOffset = false
  end
  
  -- *****************   foreach_SKWP section   ********************
  --make sure it is well formed
  --WBERTRO
  
  --  *******************************************************
  -- FROM HERE ON [foreach_SKWP] is know as [foreach_skwp] (a table)
  --  *******************************************************
  
  -- *****************   special_key_words section   ********************
  local IsWholeFileSearch = false
  local IsPrecedingKeyWords = false
  local IsOneWordOnly = false
  local FirstNotEmptyWord = 0

  local spec_key_words = {}
  local IsSpecialKeyWords = false
  local DoEmptyTest = true
  
  local special_key_wordsBadTable = false
  if special_key_words == nil then
    pv("special_key_words is nil")
    spec_key_words[1] = ""
    spec_key_words[2] = ""
    DoEmptyTest = false
  else 
    if type(special_key_words) ~= "table" then
      pv("special_key_words is not a table")
      if special_key_words == "" then
        --nothing to do
        DoEmptyTest = false
      else
        --Not a table AND only one value: problem
        pv("special_key_words == Only one value, problem!")
        spec_key_words[1] = special_key_words
      end
    else
      if type(special_key_words[1]) == "table" then
        --problem
        special_key_wordsBadTable = true

      else
        --already a simple table, use it
        pv("special_key_words is a table")
        spec_key_words = special_key_words
      end
    end
  end
  
  -- --to remove empty words
  -- local tempTable = {}
  -- for i=1,#spec_key_words do
    -- if spec_key_words[i] ~= "" then
      -- tempTable[i] = string.gsub(spec_key_words[i],[[\\]],[[\]])
    -- end
  -- end
  -- spec_key_words = tempTable
  
  if special_key_wordsBadTable then
    print()
    print(_zRED..[[>>> [WARNING] SPECIAL_KEY_WORDS first entry is a table, in your script"]].._zDEFAULT)
    print(_zRED..[[>>>          Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]].._zDEFAULT)
    Report("",[[>>> SPECIAL_KEY_WORDS first entry is a table, in your script]],"WARNING")
    Report("",[[>>> Check SerializedScript.lua (if it was generated) to see how your script shows to AMUMSS]],"WARNING")
  end

  if DoEmptyTest and #spec_key_words > 0 then
    if (#spec_key_words >= 2 and #spec_key_words%2 == 0) then
      IsSpecialKeyWords = true
    end
    
    if #spec_key_words == 1 then
      --only one spec_key_words: problem
      print()
      print(_zRED..">>> [WARNING] SPECIAL_KEY_WORDS will be IGNORED: ONLY ONE (name or value).  Please correct your script!".._zDEFAULT)
      Report("","SPECIAL_KEY_WORDS will be IGNORED: ONLY ONE (name or value).  Please correct your script!","WARNING")
    end
    
    if #spec_key_words%2 ~= 0 then
      --odd number of spec_key_words: problem
      print()
      print(_zRED..">>> [WARNING] SPECIAL_KEY_WORDS will be IGNORED: ODD number of (name or value).  Please correct your script!".._zDEFAULT)
      Report("","SPECIAL_KEY_WORDS will be IGNORED: ODD number of (name or value).  Please correct your script!","WARNING")
    end
    
    -- if IsSpecialKeyWords and (spec_key_words[1] == "" or spec_key_words[2] == "") then
      -- --one or both keywords are empty
      -- print()
      -- print(_zRED..">>> [WARNING] SPECIAL_KEY_WORDS will be IGNORED: empty string found.  Please correct your script!".._zDEFAULT)
      -- Report("","SPECIAL_KEY_WORDS will be IGNORED: empty string found.  Please correct your script!","WARNING")
    -- end

    if DoEmptyTest then
      local EmptyWord = false
      for i=1,#spec_key_words do
        if spec_key_words[i] == "" then
          EmptyWord = true
          break
        end
      end
      
      if IsSpecialKeyWords and EmptyWord then
        --at least one keyword is empty
        print()
        print(_zRED..">>> [WARNING] SPECIAL_KEY_WORDS may be IGNORED: at least one empty string found.  Please correct your script!".._zDEFAULT)
        Report("","SPECIAL_KEY_WORDS may be IGNORED: at least one empty string found.  Please correct your script!","WARNING")
        spec_key_words = {"",""}
        IsSpecialKeyWords = false
      end
    end
    
  end
  
  local EmptySpecialKeyWords = ""
  if DoEmptyTest then
    EmptySpecialKeyWords = " empty words"
  end
  pv("# spec_key_words = "..#spec_key_words..EmptySpecialKeyWords)
  pv(GetSpecKeyWordsInfo(spec_key_words))
  
  --  *******************************************************
  -- FROM HERE ON [special_key_words] is know as [spec_key_words] (a table)
  --  *******************************************************
  
  -- *****************   preceding_key_words section   ********************
  if preceding_key_words == nil then preceding_key_words = "" end
  local prec_key_words = {}
  if type(preceding_key_words) ~= "table" then
    --not a table, just one word
    --Make it a table, we want a table!
    prec_key_words[1] = preceding_key_words
    IsOneWordOnly = true

    if prec_key_words[1] == "" then 
      IsOneWordOnly = false
      IsPrecedingKeyWords = false
    else
      IsPrecedingKeyWords = true
      FirstNotEmptyWord = 1
    end

  else
    --already a table, use it
    prec_key_words = preceding_key_words

    --to remove empty words
    local tempTable = {}
    for i=1,#prec_key_words do
      if prec_key_words[i] ~= "" then
        tempTable[i] = string.gsub(prec_key_words[i],[[\\]],[[\]])
      end
    end
    prec_key_words = tempTable
    
    --one or many words
    --maybe empty or not
    if #prec_key_words > 1 then
      IsOneWordOnly = false
      FirstNotEmptyWord = 1
      IsPrecedingKeyWords = true
    elseif #prec_key_words == 1 then
      --only one word
      IsOneWordOnly = true
      IsPrecedingKeyWords = true
      FirstNotEmptyWord = 1
    else
      IsPrecedingKeyWords = false
      prec_key_words[1] = ""
    end
  end
  
  pv("# prec_key_words = "..#prec_key_words)
  pv(GetPrecKeyWordsInfo(prec_key_words))
  
  --  *******************************************************
  -- FROM HERE ON [preceding_key_words] is know as [prec_key_words] (a table)
  --  *******************************************************
  
  -- *****************   section_up section   ********************
  if section_up == nil then
    section_up = 0
  else
    if type(section_up) ~= "number" then
      print(_zRED..">>> [WARNING] SECTION_UP is not a proper number, please correct your script!".._zDEFAULT)
      Report("",">>> SECTION_UP is not a proper number, please correct your script!","WARNING")
      section_up = 0
    end
  end
  section_up = math.tointeger(math.abs(tonumber(section_up)))
  pv("section_up = "..section_up)
  -- ***************** END: section_up section   ********************
  
  -- *****************   section_up_special section   ********************
  if section_up_special == nil then
    section_up_special = 0
  else
    if type(section_up_special) ~= "number" then
      print(_zRED..">>> [WARNING] SECTION_UP_SPECIAL is not a proper number, please correct your script!".._zDEFAULT)
      Report("",">>> SECTION_UP_SPECIAL is not a proper number, please correct your script!","WARNING")
      section_up = 0
    end
  end
  section_up_special = math.tointeger(math.abs(tonumber(section_up_special)))
  pv("section_up_special = "..section_up_special)
  -- ***************** END: section_up_special section   ********************
  
  -- *****************   section_up_preceding section   ********************
  if section_up_preceding == nil then
    section_up_preceding = 0
  else
    if type(section_up_preceding) ~= "number" then
      print(_zRED..">>> [WARNING] SECTION_UP_PRECEDING is not a proper number, please correct your script!".._zDEFAULT)
      Report("",">>> SECTION_UP_PRECEDING is not a proper number, please correct your script!","WARNING")
      section_up = 0
    end
  end
  section_up_preceding = math.tointeger(math.abs(tonumber(section_up_preceding)))
  pv("section_up_preceding = "..section_up_preceding)
  -- ***************** END: section_up_preceding section   ********************
  
  -- *****************   where_key_words section   ********************
  local WhereKeyWords = {{"",""}}
  local IsWhereKeyWords = false
  
  if where_key_words == nil or where_key_words == "" then
    WhereKeyWords[1][1] = "IGNORE"
    WhereKeyWords[1][2] = "IGNORE"
  else 
    if type(where_key_words) ~= "table" then
      --not a table, make it a table
      print(_zRED..">>> [WARNING] WHERE_IN_SECTION is not a proper table of tables, please correct your script!".._zDEFAULT)
      Report("",">>> WHERE_IN_SECTION is not a proper table of tables, please correct your script!","WARNING")
      WhereKeyWords[1][1] = "IGNORE"
      WhereKeyWords[1][2] = "IGNORE"
    else
      --already a table, use it
      local NotTableOfTables = false
      local NotTwoItems = false
      for i=1,#where_key_words do
        if type(where_key_words[i]) ~= "table" then
          NotTableOfTables = true
          break
        elseif #where_key_words[i] ~= 2 then
          NotTwoItems = true
          break
        end
      end
      if NotTableOfTables then
        print(_zRED..">>> [WARNING] WHERE_IN_SECTION is not a proper table of tables, please correct your script!".._zDEFAULT)
        Report("",">>> WHERE_IN_SECTION is not a proper table of tables, please correct your script!","WARNING")        
      end
      if NotTwoItems then
        print(_zRED..">>> [WARNING] WHERE_IN_SECTION tables should have two items each, please correct your script!".._zDEFAULT)
        Report("",">>> WHERE_IN_SECTION tables should have two items each, please correct your script!","WARNING")        
      end
      if not NotTableOfTables and not NotTwoItems then
        --we can use it
        WhereKeyWords = where_key_words
      else
        WhereKeyWords[1][1] = "IGNORE"
        WhereKeyWords[1][2] = "IGNORE"
      end
    end
  end
  
  for i=1,#WhereKeyWords do
    if WhereKeyWords[i][1] == nil then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] A WHERE_IN_SECTION "Property name/value" is nil, please correct your script!]].._zDEFAULT)
      Report("",[[>>> A WHERE_IN_SECTION "Property name/value" is nil, please correct your script!]],"ERROR")
      WhereKeyWords[i][1] = "IGNORE" --to prevent a crash
    end
    if WhereKeyWords[i][2] == nil then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] A WHERE_IN_SECTION "newvalue" is nil, please correct your script!]].._zDEFAULT)
      Report("",[[>>> A WHERE_IN_SECTION "newvalue" is nil, please correct your script!]],"ERROR")
      WhereKeyWords[i][2] = "IGNORE" --to prevent a crash
    end
    WhereKeyWords[i][1] = string.gsub(WhereKeyWords[i][1],[[\\]],[[\]])
    WhereKeyWords[i][2] = string.gsub(WhereKeyWords[i][2],[[\\]],[[\]])
  end
  
  if (#WhereKeyWords > 0) and (WhereKeyWords[1][1] ~= "IGNORE" or WhereKeyWords[1][2] ~= "IGNORE") then
    IsWhereKeyWords = true
  end

  --  *******************************************************
  -- FROM HERE ON [where_key_words] is know as [WhereKeyWords] (a table of tables)
  --  *******************************************************

  -- *****************   subwhere_key_words section   ********************
  local SubWhereKeyWords = {{"",""}}
  local IsSubWhereKeyWords = false
  
  if subwhere_key_words == nil or subwhere_key_words == "" then
    SubWhereKeyWords[1][1] = "IGNORE"
    SubWhereKeyWords[1][2] = "IGNORE"
  else 
    if type(subwhere_key_words) ~= "table" then
      --not a table, make it a table
      print(_zRED..">>> [WARNING] WHERE_IN_SUBSECTION is not a proper table of tables, please correct your script!".._zDEFAULT)
      Report("",">>> WHERE_IN_SUBSECTION is not a proper table of tables, please correct your script!","WARNING")
      SubWhereKeyWords[1][1] = "IGNORE"
      SubWhereKeyWords[1][2] = "IGNORE"
    else
      --already a table, use it
      local NotTableOfTables = false
      local NotTwoItems = false
      for i=1,#subwhere_key_words do
        if type(subwhere_key_words[i]) ~= "table" then
          NotTableOfTables = true
          break
        elseif #subwhere_key_words[i] ~= 2 then
          NotTwoItems = true
          break
        end
      end
      if NotTableOfTables then
        print(_zRED..">>> [WARNING] WHERE_IN_SUBSECTION is not a proper table of tables, please correct your script!".._zDEFAULT)
        Report("",">>> WHERE_IN_SUBSECTION is not a proper table of tables, please correct your script!","WARNING")        
      end
      if NotTwoItems then
        print(_zRED..">>> [WARNING] WHERE_IN_SUBSECTION tables should have two items each, please correct your script!".._zDEFAULT)
        Report("",">>> WHERE_IN_SUBSECTION tables should have two items each, please correct your script!","WARNING")        
      end
      if not NotTableOfTables and not NotTwoItems then
        --we can use it
        SubWhereKeyWords = subwhere_key_words
      end
    end
  end
  
  for i=1,#SubWhereKeyWords do
    if SubWhereKeyWords[i][1] == nil then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] A WHERE_IN_SUBSECTION "Property name/value" is nil, please correct your script!]].._zDEFAULT)
      Report("",[[>>> A WHERE_IN_SUBSECTION "Property name/value" is nil, please correct your script!]],"ERROR")
      SubWhereKeyWords[i][1] = "IGNORE" --to prevent a crash
    end
    if SubWhereKeyWords[i][2] == nil then
      --we have a problem, should not be nil
      print(_zRED..[[>>> [ERROR] A WHERE_IN_SUBSECTION "newvalue" is nil, please correct your script!]].._zDEFAULT)
      Report("",[[>>> A WHERE_IN_SUBSECTION "newvalue" is nil, please correct your script!]],"ERROR")
      SubWhereKeyWords[i][2] = "IGNORE" --to prevent a crash
    end
    SubWhereKeyWords[i][1] = string.gsub(SubWhereKeyWords[i][1],[[\\]],[[\]])
    SubWhereKeyWords[i][2] = string.gsub(SubWhereKeyWords[i][2],[[\\]],[[\]])
  end
  
  if (#SubWhereKeyWords > 0) and (SubWhereKeyWords[1][1] ~= "IGNORE" or SubWhereKeyWords[1][2] ~= "IGNORE") then
    IsSubWhereKeyWords = true
  end

  --  *******************************************************
  -- FROM HERE ON [subwhere_key_words] is know as [SubWhereKeyWords] (a table of tables)
  --  *******************************************************

  -- *****************   section_active section   ********************
  local SectionActive = {}
  local IsSectionActive = false
  local badEntry = false
  
  if section_active == nil or #section_active == 0 then
    --nothing to do
  else
    if type(section_active) == "number" then
      if section_active > 0 then
        table.insert(SectionActive,section_active)
        IsSectionActive = true
      end
    elseif type(section_active) == "table" then
      for i=1,#section_active do
        if type(section_active[i]) == "number" then
          if section_active[i] > 0 then
            SectionActive[i] = section_active[i]
            IsSectionActive = true
          end
          
        elseif type(section_active[i]) == "string" then
          local sa = math.tointeger(math.abs(tonumber(section_active[i])))
          if sa ~= nil then
            if sa > 0 then
              SectionActive[i] = sa
              IsSectionActive = true
            end
          else
            badEntry = true
            break
          end
        else
          badEntry = true
          break
        end
      end
    elseif type(section_active) ~= "number" or type(section_active) == "string" or type(section_active) == "boolean" then
      badEntry = true
    end
  end
  
  if badEntry then
    print(_zRED..">>> [WARNING] SECTION_ACTIVE is not a proper number or table of numbers, please correct your script!".._zDEFAULT)
    Report("",">>> SECTION_ACTIVE is not a proper number or table of numbers, please correct your script!","WARNING")
    SectionActive = {}
    IsSectionActive = false
  end
  
  local so = ""
  for i=1,#SectionActive do
    so = so..SectionActive[i]..","
  end
  pv("SECTION_ACTIVE = ["..string.sub(so,1,-2).."] "..tostring(IsSectionActive))

  --  *******************************************************
  -- FROM HERE ON [section_active] is know as [SectionActive] (a table of numbers)
  --  *******************************************************

  --***************************************************************************************************  
  local function ShowKeyWordInfo()
    print()

    if IsPrecedingFirstTRUE then
      if IsPrecedingKeyWords then
        local Info = GetPrecKeyWordsInfo(prec_key_words)
        Report("","-- Based on PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
        print("\nBased on PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
            
        if IsSpecialKeyWords then
          local Info = GetSpecKeyWordsInfo(spec_key_words)
          Report("","    and SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
          print(" and SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
        end
      else
        if IsSpecialKeyWords then
          local Info = GetSpecKeyWordsInfo(spec_key_words)
          Report("","-- Based on SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
          print("\nBased on SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
        end
      end

    else
      if IsSpecialKeyWords then
        local Info = GetSpecKeyWordsInfo(spec_key_words)
        Report("","-- Based on SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
        print("\nBased on SPECIAL_KEY_WORDS pairs: >>> "..Info.." <<< ")
      
        if IsPrecedingKeyWords then
          local Info = GetPrecKeyWordsInfo(prec_key_words)
          Report("","            and PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
          print("         and PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
        end
      else
        if IsPrecedingKeyWords then
          local Info = GetPrecKeyWordsInfo(prec_key_words)
          Report("","-- Based on PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
          print("\nBased on PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
        end
      end
    end    
  end
  --***************************************************************************************************  

  -- *****************   ISxxx section   ********************
  local IsReplaceAllInGroup = ((IsReplaceRAW or IsReplaceALL) and ((IsPrecedingKeyWords and (not IsOneWordOnly)) or IsSpecialKeyWords))
  IsWholeFileSearch = (not IsPrecedingKeyWords and not IsSpecialKeyWords) or ((IsReplaceRAW or IsReplaceALL) and not IsReplaceAllInGroup)

  -- if IsReplaceRAW or (IsReplaceALL and not IsReplaceAllInGroup) then
    -- IsWholeFileSearch = true
  -- end
  
  if _mISxxx ~= nil then
    print("")
    print(" + [Key_words Info]".."                               IsReplaceRAW: ["..tostring(IsReplaceRAW).."]")
    print(" +      IsPrecedingKeyWords: ["..tostring(IsPrecedingKeyWords).."]          IsSpecialKeyWords: "..tostring(IsSpecialKeyWords).."]")
    print(" +            IsOneWordOnly: ["..tostring(IsOneWordOnly).."]          IsWholeFileSearch: ["..tostring(IsWholeFileSearch).."]")
    print(" +        FirstNotEmptyWord: ["..FirstNotEmptyWord.."]         IsReplaceALLFOLLOWING: ["..tostring(IsReplaceALLFOLLOWING).."]")
    print(" +              IsTextToAdd: ["..tostring(IsTextToAdd)
              .."], IsReplaceADDAFTERSECTION: ["..tostring(IsReplaceADDAFTERSECTION)
              .."], IsReplaceADDAFTERLINE: ["..tostring(IsReplaceADDAFTERLINE)
              .."], IsReplaceADDATLINE: ["..tostring(IsReplaceADDATLINE).."]")
    print(" +      IsReplaceAllInGroup: ["..tostring(IsReplaceAllInGroup).."]              IsReplaceALL: ["..tostring(IsReplaceALL).."]")
    print(" +      IsValueMatchOptions: ["..tostring(IsValueMatchOptions).."]        value_match_options: ["..value_match_options.."]")
    print(" +          IsWhereKeyWords: ["..tostring(IsWhereKeyWords).."]")
  end
  
  -- *****************   SCRIPTBUILDERscript section   ********************
  local ScriptType = "User"
  if gSCRIPTBUILDERscript then
    --treat this script as a SCRIPTBUILDER script
    ScriptType = "SCRIPTBUILDER"
  end

  -- *****************   main section   ********************
  -- local TextFileTable = TextFileTable -- a local copy of TextFileTable = ParseTextFileIntoTable(file) --the EXML file in a table --for speed
  
  local size = GetFileSize(file)
  pv("size of "..file.." is "..size)

  local WholeTextFile = LoadFileData(file) --the EXML file as one text, for speed searching for uniqueness

  --returns ALL the Tree without SpecialKeyWords
  --do it only once
  -- local FILE_LINE,TREE_LEVEL,KEY_WORDS = MapFileTree(TextFileTable)
  
  local GroupStartLine = {}
  local GroupEndLine = {}
  local SpecialKeyWordLine = {}
  local SectionsTable = {}
  
  local Group_Found = false  
  local LastResort = false
  
  local k = 1 --to iterate thru GroupStartLine/GroupEndLine values
    
  -- if gVerbose then Report(prec_key_words,"from user lua script","INFO") end
  
  --Note: all property/value combo in val_change_table use the Same_KEY_WORDS
  
  if IsPrecedingKeyWords or IsSpecialKeyWords then

    --#####################################################################################################################
    --********************  FINDGROUP (processing spec_key_words and prec_key_words) **************************************
    --find group(s) where key_words lead
    local FileName = string.sub(file,#gMASTER_FOLDER_PATH + #gLocalFolder + 1)
    
    Group_Found,GroupStartLine,GroupEndLine,SpecialKeyWordLine,LastResort,SectionsTable,IsOnlyOnePreceding
            = FindGroup(FileName,FileTable,WholeTextFile,prec_key_words,IsPrecedingFirstTRUE
                       ,IsSpecialKeyWords,spec_key_words,section_up_special,section_up_preceding)
                       
    pv("FindGroup returned as first group: "..GroupStartLine[1].."-"..GroupEndLine[1]..", found "..#GroupStartLine.." group(s) with SpecialKeyWordLine as "..tostring(SpecialKeyWordLine[1]))
    
    if IsOnlyOnePreceding then
      pv("Only 'one' PRECEDING_KEY_WORDS detected")
      IsStayInSection = true
    end
    
    if not Group_Found then
      ShowKeyWordInfo()

      print()
      print(_zRED..">>> [WARNING] Some KEY_WORDS not found, script result may be wrong!, see REPORT.txt".._zDEFAULT)
      Report(Info,"Some KEY_WORDS not found, script result may be wrong!","WARNING")
    end
    --********************  END: FINDGROUP (processing spec_key_words and prec_key_words) **************************************
    --#####################################################################################################################
    
  else
    --no key_words to search =>> use the whole file
    GroupStartLine = {3}
    GroupEndLine = {#FileTable}
    SpecialKeyWordLine = {""}
    SectionsTable = {"Using "..GroupStartLine[1].." - "..GroupEndLine[1]}
    Group_Found = true
  end

  -- AFTER any/all spec_key_words and prec_key_words were processed
  
  local RememberNumberOfGroups = 0
  local FoundNum = #GroupStartLine
  
  --recreate Group List and remove duplicates
  GroupStartLine,GroupEndLine,SpecialKeyWordLine = RemoveDuplicateGroups(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
  RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"Using ",SectionsTable)
  
  --**************************************** handles WHERE_IN_SECTION ***********************************    
  local function ProcessWHERE_IN_SECTION(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
    local UsingSections,OtherSections = GetUSINGsections(SectionsTable)
    RememberNumberOfGroups = #UsingSections
    if Group_Found and IsWhereKeyWords then
      pv("")
      pv("\n   In Group_Found and IsWhereKeyWords\n")
      -- print("#GroupStartLine = "..#GroupStartLine)
      local GroupState = {}
      for i=#OtherSections,#GroupStartLine do
        --for each group
        pv("   In Group "..i)
        local FoundInSection = true
        local WhereKeyWordsState = {}
        for k=1,#WhereKeyWords,2 do
          --for each pair of WhereKeyWords
          --check if WhereKeyWords are found in this group
          pv("      looking for ["..WhereKeyWords[k][1].."],["..WhereKeyWords[k][2].."]")
          WhereKeyWordsState[k] = false
          for j=GroupStartLine[i],GroupEndLine[i] do
            --for each line in this group
            local text = FileTable[j]
            if (string.find(text,[[="]]..WhereKeyWords[k][1]..[["]],1,true) or WhereKeyWords[k][1] == "IGNORE")
                  and (string.find(text,[[value="]]..WhereKeyWords[k][2]..[["]],1,true) or WhereKeyWords[k][2] == "IGNORE") then
              -- print("At group #"..i..", WhereKeyWords["..k.."] is found")
              pv("      Found")
              WhereKeyWordsState[k] = true
              break
            end
          end
          if not WhereKeyWordsState[k] then
            --word 'k' not found in this group
            pv("      NOT Found")
            FoundInSection = false
            break
          end
        end
        
        GroupState[i] = FoundInSection      
      end
        
      --clean unwanted groups
      for i=#GroupStartLine,1,-1 do
        if not GroupState[i] then
          table.remove(GroupStartLine,i)
          table.remove(GroupEndLine,i)
          table.remove(SpecialKeyWordLine,i)
        end
      end

      FoundNum = #GroupStartLine
      Group_Found = (FoundNum > 0)
      
      if not Group_Found then
        ShowKeyWordInfo() -- the SPECIAL and PRECEDING keywords

        local spacer = 11
        local Info = GetWhereInSectionInfo(WhereKeyWords)
        local msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SECTION "..Info.." to restrict search..."
        Report("",msg0)
        print(msg0)
        msg0 = string.rep(" ",spacer).."    >>> Evaluated "..RememberNumberOfGroups.." sections against WHERE_IN_SECTION keywords..."
        Report("",msg0)
        print(msg0)
        
        print()
        print(_zRED..">>> [WARNING] KEY_WORDS not found, skipping this change!, see REPORT.txt".._zDEFAULT)
        Report(Info,"KEY_WORDS not found, skipping this change!","WARNING")
      -- else
        -- local spacer = 11
        -- local Info = GetWhereInSectionInfo(WhereKeyWords)
        -- local msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SECTION "..Info.." to restrict search..."
        -- -- Report("",msg0)
        -- print(msg0)
      end
    end
    return GroupStartLine,GroupEndLine,SpecialKeyWordLine
  end
  --**************************************** END: handles WHERE_IN_SECTION ***********************************    

  --**************************************** handles WHERE_IN_SUBSECTION ***********************************    
  local function ProcessWHERE_IN_SUBSECTION(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
    local UsingSections,OtherSections = GetUSINGsections(SectionsTable)
    RememberNumberOfGroups = #UsingSections
    
    local newGSL = {}
    local newGEL = {}
    local newSKWL = {}
    
    if Group_Found and IsSubWhereKeyWords then
      pv("")
      pv("\nIn Group_Found and IsSubWhereKeyWords\n")
      -- print("#GroupStartLine = "..#GroupStartLine)
      local GroupState = {}
      for i=#OtherSections,#GroupStartLine do
        --for each group with "Using"
        local FoundInSection = true
        local SubWhereKeyWordsState = {}
        for k=1,#SubWhereKeyWords,2 do
          --for each pair of WhereKeyWords
          --check if SubWhereKeyWords are found in this group
          SubWhereKeyWordsState[k] = false
          for j=GroupStartLine[i],GroupEndLine[i] do
            --for each line in this group
            local text = FileTable[j]
            if (string.find(text,[[="]]..SubWhereKeyWords[k][1]..[["]],1,true) or SubWhereKeyWords[k][1] == "IGNORE")
                  and (string.find(text,[[value="]]..SubWhereKeyWords[k][2]..[["]],1,true) or SubWhereKeyWords[k][2] == "IGNORE") then
              pv("At group #"..i.." line "..j..", SubWhereKeyWords["..k.."] is found")
              SubWhereKeyWordsState[k] = true
              table.insert(newGSL,GoUPToOwnerStart(FileTable,j))
              table.insert(newGEL,GoDownToOwnerEnd(FileTable,j))
              table.insert(newSKWL,j)
              break
            end
          end
          if not SubWhereKeyWordsState[k] then
            --word 'k' not found in this group
            FoundInSection = false
            break
          end
        end
        
        for m=1,#SubWhereKeyWordsState do
          -- print(SubWhereKeyWordsState[m])
          FoundInSection = (FoundInSection and SubWhereKeyWordsState[m])
        end
        pv("FoundInSection "..i.." is "..tostring(FoundInSection))
        GroupState[i] = FoundInSection      
      end
        
      for i=1,#newGSL do
        pv(newGSL[i].."-"..newGEL[i].."("..newSKWL[i]..")")
      end

      --recreate Group List and remove duplicates
      GroupStartLine,GroupEndLine,SpecialKeyWordLine = RemoveDuplicateGroups(newGSL,newGEL,newSKWL)

      for i=1,#GroupStartLine do
        pv(GroupStartLine[i].."-"..GroupEndLine[i].."("..SpecialKeyWordLine[i]..")")
      end

      FoundNum = #GroupStartLine
      Group_Found = (FoundNum > 0)
      
      if not Group_Found then
        ShowKeyWordInfo()

        local spacer = 11
        local Info = GetWhereInSubSectionInfo(SubWhereKeyWords)
        local msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SUBSECTION "..Info.." to restrict search..."
        Report("",msg0)
        print(msg0)
        msg0 = string.rep(" ",spacer).."    >>> Evaluated "..RememberNumberOfGroups.." sections against WHERE_IN_SUBSECTION keywords..."
        Report("",msg0)
        print(msg0)
        
        print()
        print(_zRED..">>> [WARNING] KEY_WORDS not found, skipping this change!, see REPORT.txt".._zDEFAULT)
        Report(Info,"KEY_WORDS not found, skipping this change!","WARNING")
      -- else
        -- local spacer = 11
        -- local Info = GetWhereInSubSectionInfo(SubWhereKeyWords)
        -- local msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SUBSECTION "..Info.." to restrict search..."
        -- -- Report("",msg0)
        -- print(msg0)
      end
    end
    return GroupStartLine,GroupEndLine,SpecialKeyWordLine
  end
  --**************************************** END: handles WHERE_IN_SUBSECTION ***********************************    

--START: the next 4 handlers sequence should be programmable !!!
  
  --**************************************** process SECTION_UP ***********************************    
  if section_up > 0 then
    pv("   Found SECTION_UP = "..section_up)
    GroupStartLine,GroupEndLine,SpecialKeyWordLine = Process_SectionUP(FileTable,GroupStartLine,GroupEndLine,SpecialKeyWordLine,section_up)
    RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"U",SectionsTable)    
  end
  --**************************************** end: process SECTION_UP ***********************************    

  --**************************************** process SECTION_ACTIVE ******************************************
  if IsSectionActive then
    print("   Found "..#SectionActive.." SECTION_ACTIVE section(s)")
          ShowSections(SectionsTable)        
    SectionsTable = ProcessSECTION_ACTIVE(SectionsTable,SectionActive)
    GroupStartLine,GroupEndLine,SpecialKeyWordLine = SectionsTableToLines(SectionsTable)
          ShowSections(SectionsTable)        
    
    -- RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SA",SectionsTable)    
  end
  --**************************************** end: process SECTION_ACTIVE *************************************

  --**************************************** process WHERE_IN_SECTION ***********************************    
  if IsWhereKeyWords then
    pv("   Found "..#WhereKeyWords.." WHERE_IN_SECTION word pair(s), looking...")
    GroupStartLine,GroupEndLine,SpecialKeyWordLine = ProcessWHERE_IN_SECTION(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
    RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"WiSec",SectionsTable)    
  end
  --**************************************** end: process WHERE_IN_SECTION ***********************************    

  --**************************************** process WHERE_IN_SUBSECTION ***********************************    
  if IsSubWhereKeyWords then
    pv("   Found "..#SubWhereKeyWords.." WHERE_IN_SUBSECTION word pair(s), looking...")
    GroupStartLine,GroupEndLine,SpecialKeyWordLine = ProcessWHERE_IN_SUBSECTION(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
    RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"WiSub",SectionsTable)    
  end
  --**************************************** end: process WHERE_IN_SUBSECTION ***********************************    

--END: the next 4 handlers sequence should be programmable !!!

  --recreate Group List and remove duplicates
  GroupStartLine,GroupEndLine,SpecialKeyWordLine = RemoveDuplicateGroups(GroupStartLine,GroupEndLine,SpecialKeyWordLine)
  RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"Using ",SectionsTable)
  
  --DONT DO THIS
  -- Group_Found = (#GroupStartLine > 0)
  --************************************************************ end: FINDGROUP **********************************
  
  --===================================================
        --   FROM NOW ON, THE GROUPS ARE DEFINED
  --===================================================
  
  pv("Found "..#GroupStartLine.." group(s)")  
  
  local ReplNumber = 0
  local ADDcount = 0
  local REMOVEcount = 0
  
  if Group_Found then
    pv("Entering Group_Found...")
    
    --used by ALLFOLLOWING
    local LastReplacementLine = GroupStartLine[1] - 1
    
    local AtLeastOneReplacementDone = false

    --we have val_change_table that has all {property, value} to be changed with these prec_key_words
    local j = 0 --to iterate the val_change_table
    
    while j <= (#val_change_table - 1) do
      MapFileTreeSharedListPING()
      
      --point to next property/value combo
      j = j + 1
      local property = val_change_table[j][1]
      local value = val_change_table[j][2]
      
--#########################################
--  BUGGY BUGGY section
--Wbertro: RETHINK this IGNORE handling

  IsUSED = true -- REMOVED 2021-08-31 ==> we keep the IGNORE values, it will break some scripts
--#########################################

      if string.upper(property) == "IGNORE" and string.upper(value) == "IGNORE" then
        pv([[In property="IGNORE" and value="IGNORE"]])
        if IsSpecialKeyWords then
          pv("   with SPECIAL_KEY_WORDS")

          if #prec_key_words == 1 and IsPrecedingKeyWords then
            pv("      and one PRECEDING_KEY_WORDS")
            if IsUSED then property = prec_key_words[1] end -- REMOVED 2021-08-31
          else  
            if IsUSED then property = spec_key_words[#spec_key_words-1] end -- REMOVED 2021-08-31
          end
          
          ShowKeyWordInfo()
          
        elseif #prec_key_words > 2 then
          --TODO: works with text_to_add, we could check
          pv("   with PRECEDING_KEY_WORDS > 2")
          if IsUSED then property = prec_key_words[#prec_key_words - 1] end -- REMOVED 2021-08-31
          if IsUSED then value = prec_key_words[#prec_key_words] end -- REMOVED 2021-08-31
        
          ShowKeyWordInfo()

        elseif #prec_key_words >= 1 then                --bertro change 2019-05-23
          pv("   with PRECEDING_KEY_WORDS >= 1")
          if IsUSED then property = prec_key_words[#prec_key_words] end    --bertro change 2019-05-23 -- REMOVED 2021-08-31

          ShowKeyWordInfo()
        end
        
      elseif string.upper(property) == "IGNORE" then
        pv([[In property="IGNORE"]])
        if IsSpecialKeyWords then
          pv("   with SPECIAL_KEY_WORDS")
          if IsUSED then property = spec_key_words[#spec_key_words-1] end -- REMOVED 2021-08-31
        
          ShowKeyWordInfo()
          
        elseif #prec_key_words >= 1 and prec_key_words[1] ~= "" then
          --TODO: probably using a math_operation, we could check
          if IsMath_Operation then
            --keep the "IGNORE" property
          else
            pv("   with PRECEDING_KEY_WORDS >= 1")
            if IsUSED then property = prec_key_words[#prec_key_words] end --use the last PRECEDING_KEY_WORDS -- REMOVED 2021-08-31

            ShowKeyWordInfo()
          end
        end
        
--#########################################
-- END: BUGGY BUGGY section
--Wbertro: RETHINK this IGNORE handling
--#########################################

      elseif j == 1 and not LastResort then --only the first time
      -- elseif j == 1 then --only the first time
        pv("First time and not LastResort")
        if IsSpecialKeyWords then
          pv("   with SPECIAL_KEY_WORDS")
          -- local ThreeDots = ""
          -- if #spec_key_words > 2 then ThreeDots = "... " end
          -- local Info = ThreeDots.."["..spec_key_words[#spec_key_words-1].."], ["..spec_key_words[#spec_key_words].."]"

          ShowKeyWordInfo()

          if #spec_key_words%2 ~= 0 then
            --not an even number of spec_key_words: problem
            -- print()
            print(_zRED..">>> [WARNING] SPECIAL_KEY_WORDS: NOT an even number of (name/value).  LAST entry will be IGNORED.  Please correct your script!".._zDEFAULT)
            Report("","SPECIAL_KEY_WORDS: NOT an even number of (name/value).  LAST entry will be IGNORED.  Please correct your script!","WARNING")
          end
          
          -- if IsPrecedingKeyWords then
            -- local Info = GetPrecKeyWordsInfo(prec_key_words)
            -- Report("","            and PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
            -- print("         and PRECEDING_KEY_WORDS: >>> "..Info.." <<< ")
          -- end
          
        elseif IsPrecedingKeyWords then
          pv("   with SomeKeyWords")

          ShowKeyWordInfo()

        else --no key_words
          pv("   without KeyWords")
          Report("","-- No key_word specified, using whole file...")
          print("\nNo key_word specified, using whole file...")
        end      
      end
      
      if j == 1 then
        if IsPrecedingFirstTRUE then
          if section_up_preceding > 0 then
            if section_up_preceding == 1 then
              Report("","    -- Going UP "..section_up_preceding.." parent section after PRECEDING_KEY_WORDS...")
              print("    -- Going UP "..section_up_preceding.." parent section after PRECEDING_KEY_WORDS...")
            else
              Report("","    -- Going UP "..section_up_preceding.." parent sections after PRECEDING_KEY_WORDS...")
              print("    -- Going UP "..section_up_preceding.." parent sections after PRECEDING_KEY_WORDS...")
            end
          end

          if section_up_special > 0 then
            if section_up_special == 1 then
              Report("","    -- Going UP "..section_up_special.." parent section after SPECIAL_KEY_WORDS...")
              print("    -- Going UP "..section_up_special.." parent section after SPECIAL_KEY_WORDS...")
            else
              Report("","    -- Going UP "..section_up_special.." parent sections after SPECIAL_KEY_WORDS...")
              print("    -- Going UP "..section_up_special.." parent sections after SPECIAL_KEY_WORDS...")
            end
          end
          
        else
          if section_up_special > 0 then
            if section_up_special == 1 then
              Report("","    -- Going UP "..section_up_special.." parent section after SPECIAL_KEY_WORDS...")
              print("    -- Going UP "..section_up_special.." parent section after SPECIAL_KEY_WORDS...")
            else
              Report("","    -- Going UP "..section_up_special.." parent sections after SPECIAL_KEY_WORDS...")
              print("    -- Going UP "..section_up_special.." parent sections after SPECIAL_KEY_WORDS...")
            end
          end
          
          if section_up_preceding > 0 then
            if section_up_preceding == 1 then
              Report("","    -- Going UP "..section_up_preceding.." parent section after PRECEDING_KEY_WORDS...")
              print("    -- Going UP "..section_up_preceding.." parent section after PRECEDING_KEY_WORDS...")
            else
              Report("","    -- Going UP "..section_up_preceding.." parent sections after PRECEDING_KEY_WORDS...")
              print("    -- Going UP "..section_up_preceding.." parent sections after PRECEDING_KEY_WORDS...")
            end
          end
        end
        
        if section_up > 0 then
          if section_up == 1 then
            Report("","    -- Going UP "..section_up.." parent section after all keywords...")
            print("    -- Going UP "..section_up.." parent section after all keywords...")
          else
            Report("","    -- Going UP "..section_up.." parent sections after all keywords...")
            print("    -- Going UP "..section_up.." parent sections after all keywords...")
          end
        end
        
        if IsSaveSectionTo then
          --save the first section to a file in the SavedSections folder using the SAVE_SECTION_TO name.txt
          --we overwrite any existing file with that name
          local section = ""
          for m=GroupStartLine[1],GroupEndLine[1] do
            local line = FileTable[m]
            section = section..line.."\n"
          end
          
          print("@@@@@ Writing save_section_to a file in the SavedSections folder")
          WriteToFile(section,gMASTER_FOLDER_PATH..[[SavedSections\]]..save_section_to..[[.txt]])
          
          for m=1,#gSaveSectionName do
            if gSaveSectionName[m] == save_section_to then
              --save it internally
              print("@@@@@ Saving save_section_to in the internal SAVE_SECTION_TO list")
              gSaveSectionContent[m] = Section
              break
            end
          end
        end
      end
      
      pv("USING these: property=["..property.."] ".."value=["..value.."]")
      local newIsValueMatchType = IsValueMatchType
      if not IsValueMatchType then
        --none specified by the user
        --let us force it to be of the same type as the new value
        local ValueTypeIsNumber, ValueIsInteger = CheckValueType(value,false)
        if ValueTypeIsNumber then
          value_match_type = "NUMBER"
        else
          value_match_type = "STRING"
        end
        newIsValueMatchType = true
      end
            
      local spacer = 0
      do --prepare info to inform user
        local msg0 = ""
        local msg1 = ""
        local msg2 = ""
        local msg3 = ""
        local msg4 = ""
        local msg5 = ""
        
        if IsMath_Operation then
          msg1 = "Math_operation "
          msg2 = "("..math_operation..")"
        end
        
        if IsValueMatch then
          if IsValueMatchOptionsMatch then
            msg3 = " matching ["..value_match.."]"
          else
            msg3 = " not matching ["..value_match.."]"
          end
        end
        
        if newIsValueMatchType then
          msg3 = msg3.." of type ["..value_match_type.."]"
        end
        
        if IsLineOffset then
          if IsSpecialKeyWords then
            local ThreeDots = ""
            if #spec_key_words > 2 then ThreeDots = "... " end
            msg5 = " at "..ThreeDots.."["..spec_key_words[#spec_key_words-1].."] and ["..spec_key_words[#spec_key_words].."]"
          else
            msg5 = " at ["..prec_key_words[#prec_key_words].."]"
          end
          msg4 = " with a LINE_OFFSET of ["..line_offset.."]"
        end
        
        if IsTextToAdd then
          if IsReplaceADDAFTERLINE then
            Report("","    Looking to >>> add some text <<< after LINE with Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> add some text <<< after LINE with Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          -- else
            -- Report("","    Looking to >>> add some text <<< after Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            -- print("\n    Looking to >>> add some text <<< after Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            -- spacer = 11
          -- end
          elseif IsReplaceADDAFTERSECTION then
            Report("","    Looking to >>> add some text <<< after SECTION with Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> add some text <<< after SECTION with Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          else
            Report("","    Looking to >>> add some text <<< after Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> add some text <<< after Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          end
          
        elseif IsToRemove then
          if IsToRemoveLINE then
            Report("","    Looking to >>> remove LINE <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> remove LINE <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          elseif IsToRemoveSECTION then
            Report("","    Looking to >>> remove SECTION <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> remove SECTION <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          else
            Report("","    Looking to >>> remove some text <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            print("\n    Looking to >>> remove some text <<< at Property name ["..property.."] and value ["..value.."]"..msg3..msg4)
            spacer = 11
          end
          
        else
          Report("","    Looking for >>> ["..property.."] New value will be >>> "..msg1.."["..msg2..value.."]"..msg3..msg4..msg5)
          print("\n    Looking for >>> ["..property.."] New value will be >>> "..msg1.."["..msg2..value.."]"..msg3..msg4..msg5)
          spacer = 12
        end
        
        if IsWhereKeyWords then
          local Info = GetWhereInSectionInfo(WhereKeyWords)
          msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SECTION "..Info.." to restrict search..."
          Report("",msg0)
          print(msg0)
          msg0 = string.rep(" ",spacer).."    >>> Evaluated "..RememberNumberOfGroups.." sections against WHERE_IN_SECTION keywords..."
          Report("",msg0)
          print(msg0)
        end

        if IsSubWhereKeyWords then
          local Info = GetWhereInSubSectionInfo(SubWhereKeyWords)
          msg0 = string.rep(" ",spacer).."    >>> using WHERE_IN_SUBSECTION "..Info.." to restrict search..."
          Report("",msg0)
          print(msg0)
          msg0 = string.rep(" ",spacer).."    >>> Evaluated "..RememberNumberOfGroups.." sections against WHERE_IN_SUBSECTION keywords..."
          Report("",msg0)
          print(msg0)
        end

        if IsReplace then
          -- if IsReplaceADDAFTERSECTION then
            -- msg0 = string.rep(" ",spacer).."    >>> Replace operation is ["..replace_type.."]"
            -- if IsPrecedingKeyWords then
              -- msg0 = msg0.." based on ".."["..prec_key_words[#prec_key_words].."]"
            -- end
          -- else
            msg0 = string.rep(" ",spacer).."    >>> Replace operation is ["..replace_type.."]"
            if IsPrecedingKeyWords then
              local Info = GetPrecKeyWordsInfo(prec_key_words)
              -- local Info = ""
              -- for i = 1,#prec_key_words do
                -- Info = Info.."["..prec_key_words[i].."], "
              -- end
              -- Info = string.sub(Info,1,#Info - 2)
              msg0 = msg0.." based on key_words: "..Info
            end
          -- end
          Report("",msg0)
          print(msg0)
        end        
      end
      
      if tonumber(value) ~= nil and tonumber(value) > 99999999 then
        --MBINCompiler may produce a problematic MBIN that once decompiled will have a value of "1.0E+7"
        print(_zRED..[[>>> [NOTICE] MBINCompiler may generate a MBIN that once decompiled will have a value like "1E+09"]].._zDEFAULT)
        print(_zRED..[[         xxxxx Your script contains a value over "99999999" xxxxx]].._zDEFAULT)
        print(_zRED..[[         A value like "100000123" will become "100000120", (it won't be exact)]].._zDEFAULT)
        print(_zRED..[[         Bigger values may become like "1E+09"]].._zDEFAULT)
        print(_zRED..[[         That could prevent NMS from using the mod]].._zDEFAULT)
        Report("",[[MBINCompiler may generate a MBIN that once decompiled will have a value like "1E+09"]],"NOTICE")
        Report("",[[       xxxxx Your script contains a value over "99999999" xxxxx]],"")
        Report("",[[       A value like "100000123" will become "100000120", (it won't be exact)]],"")
        Report("",[[       Bigger values may become like "1E+09"]],"")
        Report("",[[       That could prevent NMS from using the mod]],"")
      end
      
      if FoundNum > 0 then
        if FoundNum > 1 then
          Report("","    --                    >>>>> Found "..FoundNum.." valid candidate instances.")
          print("        >>>>> Found "..FoundNum.." valid candidate instances.")
          if IsReplaceALL then
            Report("","    --                    >>>>> ALL valid instances where requested to be processed <<<<<")
            print("\n    --                    >>>>> ALL valid instances where requested to be processed <<<<<")
          else
            Report("",[[    --     >>>>> REPLACE_TYPE = "]]..replace_type..[[": Only FIRST instance will be processed <<<<<]])
            print("\n"..[[    --     >>>>> REPLACE_TYPE = "]]..replace_type..[[": Only FIRST instance will be processed <<<<<]])
            GroupStartLine = {GroupStartLine[1]}
            GroupEndLine = {GroupEndLine[1]}
            SpecialKeyWordLine = {SpecialKeyWordLine[1]}
          end
          -- Report("","You may want to check your [\"PRECEDING_KEY_WORDS\" and/or \"SPECIAL_KEY_WORDS\"] if the replacements are faulty!","WARNING")
          -- print(_zRED.."    -- >>> [WARNING] You may want to check your [\"PRECEDING_KEY_WORDS\" and/or \"SPECIAL_KEY_WORDS\"] if the replacements are faulty!".._zDEFAULT)
        end
      end

      k = 0 --to iterate thru GroupStartLine/GroupEndLine values
      
      if #GroupStartLine > 1 and (IsTextToAdd or IsToRemove) then
        --reversing the order of the Groups
        --so that we add or remove from the bottom up
        Report("","    --                    >>>>> Processing Groups in reverse order for ADD/REMOVE <<<<<")
        print("\n    --                    >>>>> Processing Groups in reverse order for ADD/REMOVE <<<<<")

        local Gs = {}
        local Ge = {}
        local Gl = {}
        for i=#GroupStartLine,1,-1 do
          Gs[#Gs+1] = GroupStartLine[i]
          Ge[#Ge+1] = GroupEndLine[i]
          Gl[#Gl+1] = SpecialKeyWordLine[i]
        end
        GroupStartLine = Gs
        GroupEndLine = Ge
        SpecialKeyWordLine = Gl
        
        RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"RO",SectionsTable)
      end
      
      ShowSections(SectionsTable)        
      
      while k <= #GroupStartLine - 1 do
        MapFileTreeSharedListPING()
        
        --go explore next group for the current property/value combo
        k = k + 1
        pv(">>> Entering outer while at group #"..k)
        pv("GroupEndLine[k] = "..GroupEndLine[k])
        local i = GroupStartLine[k] - 1
        
        if IsSpecialKeyWords and IsLineOffset then
          -- i = SpecialKeyWordLine[k] - 1 --this is the line to offset from
          -- print("                >>> LINE_OFFSET forces line "..i..[[ as base...]])
          -- Report("","                >>> LINE_OFFSET forces line "..i..[[ as base...]])

        elseif IsReplaceALLFOLLOWING then
          pv("LastReplacementLine: "..LastReplacementLine)
          i = LastReplacementLine
          print("                >>> ALLFOLLOWING forces line "..i..[[ as base...]])
          Report("","                >>> ALLFOLLOWING forces line "..i..[[ as base...]])

        elseif IsStayInSection then
          pv("LastReplacementLine: "..LastReplacementLine)
          i = LastReplacementLine
          print("                >>> Only one PRECEDIND_KEY_WORDS forces line "..i..[[ as base...]])
          Report("","                >>> Only one PRECEDIND_KEY_WORDS forces line "..i..[[ as base...]])
        end
        
        local CurrentLine = i --used with text_to_add and to_remove
        local InWhile = false

        --using while because we can change the value of i and GroupEndLine
        --that is useful with line_offset, text_to_add and maybe other manipulations

        if IsTextToAdd or IsToRemove then
          --respect end of section
          pv("IsTextToAdd or IsToRemove: respecting end of section")
        elseif (not IsReplaceAllInGroup) and IsReplaceAll then
          --we need to replace more than in that group
          pv("(not IsReplaceAllInGroup) and IsReplaceAll: continuing to eof")
          GroupEndLine[k] = #FileTable
        elseif IsReplaceALLFOLLOWING and not IsStayInSection then
          --we need to replace ALL that follow, even outside the bottom of the section
          pv("IsReplaceALLFOLLOWING: continuing to eof")
          GroupEndLine[k] = #FileTable
        end
        
        local EndLine = GroupEndLine[k] --to remember the section end

        local SearchGroupRange = tostring(i + 1).." to "..tostring(GroupEndLine[k])
        pv("SearchGroupRange = "..SearchGroupRange)
        
        if not IsTextToAdd and not IsToRemove then
          print("                >>> Searching in lines "..SearchGroupRange..[[...]])
          Report("","                >>> Searching in lines "..SearchGroupRange..[[...]])
        end

        -- print("Just before the BIG INNER WHILE: ["..property.."] ["..value.."], about to process line "..i + 1)
        while i <= (GroupEndLine[k] - 1) do
          if not InWhile then
            pv(">>> Entering inner while...")
            InWhile = true
          end
          
          local repl_done = false
          i = i + 1 --next line
          CurrentLine = i
          
          local line = FileTable[i]
          -- print(line)
          if line == nil then
            print(_zRED..">>> [WARNING] Problem with [current line] being nil".._zDEFAULT)            
            Report("","Problem with [current line] being nil","WARNING")
            break
          end
          
          -- if IsOneWordOnly and IsWholeFileSearch then
            -- --only one prec_key_words is supplied
            -- if StripInfo(line,[[<Property name="]],[["]]) == prec_key_words[1] then
              -- --found a SoS 
            -- end
          -- end
          
          if IsReplaceRAW then
            if string.find(line,property,1,true) ~= nil then 
              -- print("Found a line at "..i..": "..property)
              --we found A line containing the property string
              --it is "anything goes here", free for all!
              --if we searched [[oper]], it will find [[Property]] ==> all lines
              print("RAW replacement of: [" .. property .. "] with: [" .. value.."]")
              
              --fix-up pattern first to prevent side-effects
              pattern = string.gsub (property, "[%%%]%^%-$().[*+?]", "%%%1")
              
              FileTable[i] = string.gsub(line,pattern,value) 
              repl_done = true
            end
          else --replace_type ~= "RAW"
            -- pv("Entering not IsReplaceRAW...")
            -- pv("B: property=["..property.."] ".."value=["..value.."]")
            -- pv(line)
            --(i == 2) is a special case where the whole EXML content was removed
            if (i == 2) 
                  or StripInfo(line,[[<Property name="]],[["]]) == property 
                  or StripInfo(line,[[<Property value="]],[["]]) == property 
                  or (property == "IGNORE" and (IsTextToAdd or IsToRemove))
                  or (property == "IGNORE" and IsMath_Operation) then
              
              pv("Found << THE >> line at "..i..": "..property)
              
              local exstring = StripInfo(line,[[value="]],[["]])
              
              --why do this, value CAN be ""
              -- if exstring == nil or exstring == "" then
                -- --retrieve the name= instead of the value=
                -- --TODO: is it ok to do this? In what circumstances?
                -- pv("   >>>  [INFO] Using StripInfo(line,[[name=\"]],[[\"]]) to get in...")
                -- exstring = StripInfo(line,[[name="]],[["]])
              -- end
              pv("(Before value_match)                  Line "..i..": value=["..exstring.."] ["..line.."], Property=\""..property.."\", Value=\""..value.."\"")
              
              if not IsTextToAdd and not IsToRemove then
                --process line_offset stuff
                if IsLineOffset then
                  print("                >>> Current line is "..i)
                  Report("","                >>> Current line is "..i)
                  if offset_sign == "+" then 
                    if #FileTable >= i + offset then
                      line=FileTable[i + offset] 
                      i=i + offset --we go forward in the file
                    else
                      Report("","Problem with [current line + offset] being after the end of file","WARNING")
                    end
                  elseif offset_sign == "-" then 
                    line=FileTable[i - offset]
                    if i-offset >= 1 then
                      line=FileTable[i - offset]
                      --i=i - offset --we do not backtrack in the file
                    else
                      Report("","Problem with [current line - offset] being before the beginning of file","WARNING")                      
                    end
                  end
                  
                  print("                >>> LINE_OFFSET of ["..line_offset.."] forces to look starting at line "..i)
                  Report("","                >>> LINE_OFFSET of ["..line_offset.."] forces to look starting at line "..i)

                  --we get the new value from offset line
                  exstring = StripInfo(line,[[value="]],[["]])
                  
                  if exstring == nil or exstring == "" then
                    --TODO: is it ok to always do this? In what circumstances?
                    pv("   >>>  [INFO] Using StripInfo(line,[[name=\"]],[[\"]]) after applying offset...")
                    exstring = StripInfo(line,[[name="]],[["]])
                  end
                  pv("(After offset)                        Line "..i..": value=["..exstring.."] ["..line.."], Property=\""..property.."\", Value=\""..value.."\"")
                end
              end
              
              if not IsValueMatch or (IsValueMatchOptions and CheckValueMatchOptions(value_match,exstring)) then
                    -- or (IsValueMatchOptionsMatch and exstring == value_match) 
                    -- or (IsValueMatchOptionsNoMatch and exstring ~= value_match) then
                if not newIsValueMatchType 
                      or (value_match_type == "NUMBER" and type(tonumber(exstring)) == string.lower(value_match_type)) 
                      or (value_match_type == "STRING" and type(exstring) == string.lower(value_match_type)) then 
                  
                  if not IsTextToAdd and not IsToRemove then
                    pv("(After value_match, value_match_type) Line "..i..": value=["..exstring.."] ["..line.."], Property=\""..property.."\", Value=\""..value.."\"")
                    local NewValue = nil --could be a number OR a string
                    local tmpNewValue = nil --to be able to evaluate it before IntegerIntegrity()
                    
                    local OrgValueTypeIsNumber, OrgValueIsInteger = CheckValueType(exstring,IsInteger_to_floatFORCE)
                    
                    if IsMath_Operation then
                      local currentValue = value
                      local scriptValue = exstring
                      local scriptmath_operation = math_operation
                      
                      if string.find(math_operation,"$",1,true) then
                        --swap order of math operation
                        currentValue,scriptValue = scriptValue,currentValue
                        --remove the "$"
                        scriptmath_operation = string.gsub(scriptmath_operation,"%$","")
                      end
                      
                      if string.len(scriptmath_operation) == 1 then -- {+, -, *, /} only
                        tmpNewValue = ExecuteMathOperation(
                                        scriptmath_operation,
                                        tonumber(scriptValue), --does scriptValue - currentValue
                                        tonumber(currentValue)
                                      )
                        NewValue =  IntegerIntegrity(tmpNewValue,OrgValueIsInteger)

                      elseif string.find(string.sub(scriptmath_operation, 2, 3),"F:") then --"*F:endString"
                        tmpNewValue = ExecuteMathOperation(
                                        string.sub(scriptmath_operation, 1, 1),
                                        tonumber(
                                          TranslateMathOperatorCommandAndGetValue(
                                            FileTable,
                                            string.sub(scriptmath_operation, 4), --currentValue to look for
                                            i, --from this line
                                            "forward"
                                          )
                                        ),
                                        tonumber(currentValue)
                                      )
                        NewValue =  IntegerIntegrity(tmpNewValue,OrgValueIsInteger)
                      
                      elseif string.find(string.sub(scriptmath_operation, 2, 4),"FB:") then
                        tmpNewValue = ExecuteMathOperation(
                            string.sub(scriptmath_operation, 1, 1)
                            ,tonumber(TranslateMathOperatorCommandAndGetValue(FileTable, string.sub(scriptmath_operation, 5), i, "backward"))
                            ,tonumber(currentValue))	
                        NewValue =  IntegerIntegrity(tmpNewValue,OrgValueIsInteger)
                      
                      elseif string.find(string.sub(scriptmath_operation, 2, 3),"L:") then 
                        tmpNewValue = ExecuteMathOperation(
                                        string.sub(scriptmath_operation, 1, 1),
                                        tonumber(
                                          StripInfo(FileTable[i+tonumber(string.sub(scriptmath_operation, 4))],[[value="]],[["]])
                                        ),
                                        tonumber(currentValue)
                                      )
                        NewValue =  IntegerIntegrity(tmpNewValue,OrgValueIsInteger)
                      
                      elseif string.find(string.sub(scriptmath_operation, 2, 4),"LB:") then 
                        tmpNewValue = ExecuteMathOperation(
                            string.sub(scriptmath_operation, 1, 1)
                            ,tonumber(StripInfo(FileTable[i-tonumber(string.sub(scriptmath_operation, 5))],[[value="]],[["]]))
                            ,tonumber(currentValue))
                        NewValue =  IntegerIntegrity(tmpNewValue,OrgValueIsInteger)
                      
                      else
                        --not a valid math_operation, keep original value
                        print(_zRED..[[>>> [WARNING] INVALID MATH_OPERATION: ]]..math_operation.._zDEFAULT)            
                        Report("",[[INVALID MATH_OPERATION: ]]..math_operation,"WARNING")
                       tmpNewValue = currentValue
                       NewValue = currentValue
                      end
                    else  
                      --no math_operation, keep original value
                      tmpNewValue = value
                      NewValue = value
                    end
                    
                    local tmpNewValueTypeIsNumber, tmpNewValueIsInteger = CheckValueType(tmpNewValue,IsInteger_to_floatFORCE)
                    local NewValueTypeIsNumber, NewValueIsInteger = CheckValueType(NewValue,IsInteger_to_floatFORCE)

                    -- if i == 104 then
                      -- print("line "..i..": OrgValue["..tostring(exstring).."] Number["..tostring(OrgValueTypeIsNumber).."] Integer["..tostring(OrgValueIsInteger).."] "..tostring(math.type(tonumber(exstring))))
                      -- print("line "..i..": tmpValue["..tostring(tmpNewValue).."] Number["..tostring(tmpNewValueTypeIsNumber).."] Integer["..tostring(tmpNewValueIsInteger).."] "..tostring(math.type(tonumber(tmpNewValue))))
                      -- print("line "..i..": NewValue["..tostring(NewValue).."] Number["..tostring(NewValueTypeIsNumber).."] Integer["..tostring(NewValueIsInteger).."] "..tostring(math.type(tonumber(NewValue))))
                    -- end
                    
                    if IsMath_Operation then
                      --we only care about an INTEGER number becoming a FLOAT
                      if OrgValueTypeIsNumber and OrgValueIsInteger and not tmpNewValueIsInteger and (not IsInteger_to_floatDeclared or (IsInteger_to_floatDeclared and not IsInteger_to_floatPRESERVE)) then
                        print(_zRED..[[>>> [NOTICE] ORIGINAL value below is INTEGER.  To override, use ["INTEGER_TO_FLOAT"] = "FORCE" or "PRESERVE"]].._zDEFAULT)            
                        Report("",[[ORIGINAL value below is INTEGER.  To override, use ["INTEGER_TO_FLOAT"] = "FORCE",]],"NOTICE")
                      end              
                    else
                      --when not a Math_Operation
                      --  we only care about a change from
                          -- (number to string)
                          -- (string to integer)
                          -- INTEGER number becoming a FLOAT
                      --and we DON'T preserve INTEGERs when not in a MATH_OPERATION
                      if (OrgValueTypeIsNumber ~= NewValueTypeIsNumber) or (OrgValueTypeIsNumber and OrgValueIsInteger and not NewValueIsInteger) then
                        print(_zRED..[[>>> [WARNING] ORIGINAL and NEW number value have mismatched types (INTEGER->FLOAT) or (STRING vs NUMBER)]].._zDEFAULT)            
                        Report("",[[ORIGINAL and NEW number value have mismatched types (INTEGER->FLOAT) or (STRING vs NUMBER)]],"WARNING")
                      end
                    end

                    pv("(After math_operation) Line "..i..": value=["..tostring(NewValue).."] ["..line.."], Property=\""..property.."\", Value=\""..value.."\"")                    
                    -- if value ~= "IGNORE" then
                    if NewValue ~= "IGNORE" then
                      local Ending = [[" />]]
                      if string.sub(line,-2) == [[">]] then
                        Ending = [[">]]
                      end
                      -- we CANNOT use gsub here because it could replace at wrong places like:
                      -- <Property name="_3rdPersonAngleSpeedRangePitch" value="3" />
                      -- when replacing such a value (3 with 8) it becomes:
                      -- <Property name="_8rdPersonAngleSpeedRangePitch" value="8" />
                      
                      if string.find(line,[[<Property name=]],1,true) ~= nil and string.find(line,[[value=]],1,true) ~= nil then
                        --standard value replacement on a line with the property
                        --a line with BOTH name AND value, value could be EMPTY
                        --like: <Property name="Filename" value="MODELS/PLANETS/BIOMES/BARREN/HQ/TREES/DRACAENA.SCENE.MBIN" />
                        --like: <Property name="ProceduralTexture" value="TkProceduralTextureChosenOptionList.xml">
                        
                        FileTable[i] = string.sub(line,1,string.find(line,[[value="]],1,true)-1)..[[value="]]..tostring(NewValue)..Ending
                        repl_done = true
                      elseif string.find(line,[[Property value=]],1,true) ~= nil then
                        -- lines with value only, CANNOT BE EMPTY
                        -- like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
                        -- could be a SIGNIFICANT KEY_WORD
                        FileTable[i] = string.sub(line,1,string.find(line,[[value="]],1,true)-1)..[[value="]]..tostring(NewValue)..Ending
                        repl_done = true
                      elseif string.find(line,[[Property name=]],1,true) ~= nil then
                        -- lines with name only, CANNOT BE EMPTY
                        -- like: <Property name="GenericTable">
                        -- like: <Property name="List" />
                        -- could be a SIGNIFICANT KEY_WORD
                        FileTable[i] = string.sub(line,1,string.find(line,[[name="]],1,true)-1)..[[name="]]..tostring(NewValue)..Ending
                        repl_done = true
                      else
                        print(_zRED..">>> [WARNING] XXX At "..i..": Found an Un-handled line type ["..line.."], check your script".._zDEFAULT)
                        Report(line,"XXX At "..i..": Check your script, found an Un-handled line type:","WARNING")
                      end
                      pv("(After replacement) Line "..i..": FileTable[i] = ["..FileTable[i].."]")
                    else
                      pv("(value is IGNORE) Line "..i..": FileTable[i] = ["..FileTable[i].."]")
                    end
                    
                  else --text_to_add and/or to_remove has a value
                    if IsTextToAdd then
                      pv("Preparing to ADD some text...")
                      
                      if IsReplaceADDATLINE then
                        pv("    -- Adding text at(and replacing) line: "..i)
                        --we take care of removing the line in IsToRemove below
                        IsToRemove = true
                        IsToRemoveLINE = true
                        -- i = i --no need to change i
                      else
                        if IsReplaceADDAFTERSECTION then
                          local bottom = GroupEndLine[k]
                          i = bottom
                        else --if IsReplaceADDAFTERLINE then
                          --this is the default
                          -- i = i                        
                        end
                        
                        pv("    -- Adding text after line/section: " .. i)
                      end
                      
                      if IsLineOffset then
                        pv("    -- line before offset: " .. i)
                        if offset_sign == "+" then
                          i = i + offset
                          if i > #FileTable then
                            i = #FileTable - 1
                          end
                        elseif offset_sign == "-" then
                          i = i - offset
                          if i < 3 then
                            i = 3 --it must be after the header at least
                          end
                        end
                        pv("    -- line after offset: " .. i)
                      end	

                      local _,linecount = string.gsub(text_to_add,"\n","")
                      if linecount == 0 then
                        linecount = 1
                      end
                      pv("text_to_add: linecount = "..linecount)
                      -- CurrentLine = i --so we remember
                      local textmod = table.concat(FileTable,"\n",1,i)
                      textmod = textmod.."\n"..text_to_add.."\n"
                      -- if IsReplaceADDATLINE then
                        -- textmod = textmod..table.concat(FileTable,"\n",i+2,#FileTable)
                      -- else
                        textmod = textmod..table.concat(FileTable,"\n",i+1,#FileTable)
                      -- end
                      WriteToFile(string.gsub(textmod,"\n\n","\n"), file)

                      FileTable = ParseTextFileIntoTable(file) --reload the EXML file

                      WholeTextFile = LoadFileData(file) --the EXML file as one text, for speed searching for uniqueness

                      print("    -- Lines "..(i + 1).." - "..(i + linecount).." ADDED using text in [\"ADD\"]")
                      Report("","    -- Lines "..(i + 1).." - "..(i + linecount).." ADDED using text in [\"ADD\"]")

                      --in case we have to replace ALL
                      GroupEndLine[k] = #FileTable --make sure we get to the new last line of the file
                      ADDcount = ADDcount + 1
                      repl_done = true
                      
                      i = i + linecount -- - 1 --point to the last line inserted
                      
                    end --if IsTextToAdd then

                    if IsToRemove then
                      if IsLineOffset then
                        --we offset from the line found by the keywords
                        pv("    -- line before offset: " .. i)
                        if offset_sign == "+" then
                          i = i + offset
                          if i > #FileTable then
                            i = #FileTable - 1
                          end
                        elseif offset_sign == "-" then
                          i = i - offset
                          if i < 3 then
                            i = 3 --it must be after the header at least
                          end
                        end
                        pv("    -- line after offset: " .. i)
                      
                      else
                        pv("    -- line NO offset: " .. i)
                        i = GroupStartLine[k] --because no offset: the top of this section
                      end	

                      local tmpAtLine = i
                      pv("    -- Removing at line: " .. i)
                      CurrentLine = i --so we remember
                      
                      if IsToRemoveSECTION then
                        pv("    -- Removing at line: " .. i)
                        -- print(FileTable[CurrentLine])

                        local top = i
                        local bottom = GroupEndLine[k]
                        
                        -- local top = GoUPToOwnerStart(FileTable,CurrentLine)
                        -- local bottom = GoDownToOwnerEnd(FileTable,CurrentLine)

                        -- print(top.."-"..bottom)
                        --delete section from exml
                        for m=bottom,top,-1 do
                          if #FileTable >= m then
                            table.remove(FileTable,m)
                          else
                            print(_zRED..">>> [WARNING] Remove operation aborted, line "..m.." is out of range!".._zDEFAULT)
                            Report("","Remove operation aborted, line "..m.." is out of range!","WARNING")
                            break
                          end
                        end
                        -- local linecount = bottom - top
                        print("    -- Lines "..top.." - "..bottom.." REMOVED")
                        Report("","    -- Lines "..top.." - "..bottom.." REMOVED")
                      
                      elseif IsToRemoveLINE then
                        if IsReplaceADDATLINE then
                          --we need to adjust older i
                          i = tmpAtLine
                          print("    -- Original Line "..i.." REMOVED")
                          Report("","    -- Original Line "..i.." REMOVED")
                        else
                          print("    -- Line "..i.." REMOVED")
                          Report("","    -- Line "..i.." REMOVED")
                        end
                        
                        --delete line i from exml
                        if #FileTable >= i then
                          table.remove(FileTable,i)
                        else
                          print(_zRED..">>> [WARNING] Remove operation aborted, line "..i.." is out of range!".._zDEFAULT)
                          Report("","Remove operation aborted, line "..i.." is out of range!","WARNING")
                          break
                        end
                      end
                      
                      i = CurrentLine --point to the next line to process
                      
                      
                      --Wbertro: is this always ok? >>> NO.........
                      --or should we do it bottom up!
                      
                      GroupEndLine[k] = #FileTable --make sure we get to the new last line of the file
                      REMOVEcount = REMOVEcount + 1
                      repl_done = true
                    end --if IsToRemove then
                  end --if not IsTextToAdd and not IsToRemove then
                  
                else
                  --no match_type
                  --REMARKED to reduce clutter in output
                  -- Report("","Line "..i..", ["..property.."] with a value of ["..exstring.."] does not match a ["..value_match_type..
                            -- "] like ["..value.."], XXXXX this value not replaced XXXXX","WARNING")
                  -- print("    -- Line "..i..", ["..exstring.."] type does not match a ["..value_match_type
                      -- .."],                           XXXXX this value not replaced >>> [WARNING]")
                end --value_match_type == type(value) or empty
              end --value_match == value or empty
            end --we found THE line in the EXML file
          end --if IsReplaceRAW then
          
          if repl_done then
            AtLeastOneReplacementDone = true
            if not (IsTextToAdd or IsToRemove) then
              if value == "IGNORE" then
                local spacer = "    "
                local part1 = "-- On line "..i..", SKIPPED this value"
                Report("",spacer..part1)
                print(spacer..part1)              
              else
                local spacer = "      "
                local spacer1 = "    "
                local spacer2 = spacer1
                local part1 = "-- On line "..i..", exchanged:" .. spacer1 .. "[" .. trim(line) .. "]"
                if string.len(part1) < 86 then spacer1 = string.rep(" ",86 - string.len(part1) + string.len(spacer1)) end
                Report("",spacer..part1 .. spacer1 .. "with: " .. spacer2 .. "[" .. trim(FileTable[i]) .. "]")
                print(spacer..part1 .. spacer1 .. "with: " .. spacer2 .. "[" .. trim(FileTable[i]) .. "]")
                
                if i > EndLine then
                  print()
                  print(_zRED..">>> [NOTICE] -???- The replacement is outside of the search group: "..SearchGroupRange..".  Could be Ok, you decide... -???-".._zDEFAULT)
                  Report("","Replacement on line "..i.." is outside of the search group: "..SearchGroupRange..".  Could be Ok, you decide...","NOTICE")
                end
                
                ReplNumber = ReplNumber + 1
              end
            
              --here we decide if we continue down the file or break for a new val_change_table combo
              -- if (not IsPrecedingKeyWords and IsReplaceALL) or IsReplaceAllInGroup or IsReplaceRAW then
              if IsReplaceALL or IsReplaceAllInGroup or IsReplaceRAW then
                --because we want to continue replacing values down the file until GroupEndLine[k]
                --Note: if ADD was used, we already point to the last line inserted
                pv("Looping to continue replacing values down the file until GroupEndLine[k] = "..GroupEndLine[k])
              elseif IsReplaceALLFOLLOWING then
                LastReplacementLine = i
                pv("Looping to continue replacing values down the file from "..LastReplacementLine.." until GroupEndLine[k] = "..GroupEndLine[k])
                -- pv("break on IsReplaceALLFOLLOWING")
                -- break
              elseif IsStayInSection then
                LastReplacementLine = i
                pv("Break to continue replacing values down the file from "..LastReplacementLine.." until GroupEndLine[k] = "..GroupEndLine[k])
                break
              elseif not IsReplaceALL then
                --our replacement is done, we exit this group
                pv("break on not IsReplaceALL")
                break
              else
                --not an approved word for replace_type maybe
                --or no more property/value combo to process
                --ANYWAY, we are done for this bunch
                pv("break on not an approved word")
                break
              end
            else --IsTextToAdd or IsToRemove
              --get to next section
              break
            end

          else --not repl_done 
            if IsSpecialKeyWords and IsOneWordOnly then
              --lets go down until we find VALUE_CHANGE_TABLE, even outside the bottom of the section
              pv("on line "..i..": No repl_done, but IsSpecialKeyWords and IsOneWordOnly, so continuing down...")
              
              if i == GroupEndLine[k] and not AtLeastOneReplacementDone then
                --we are at the end of the group and did not find a replacement
                --we can try to go down to the end of file
                
                --Wbertro: this could instead go up one level in the EXML
                
                pv("reached end of group and No repl_done, so setting GroupEndLine[k] to #FileTable...")
                GroupEndLine[k] = #FileTable
              end
            end
          end --if repl_done then     
        end --while i <= (GroupEndLine[k] - 1) do
        
        pv("GroupEndLine[k] = "..GroupEndLine[k])
        pv(">>> Exiting inner while...")
        
      end --while k <= #GroupStartLine - 1 do
    end --while j <= (#val_change_table - 1) do
    
    if not AtLeastOneReplacementDone then
      --replacement NOT done
      print("")
      print(_zRED..">>> [WARNING] No action done!".._zDEFAULT)
      Report("","No action done!","WARNING")
    else 
      -- if ReplNumber > 0 or ADDcount > 0 or REMOVEcount > 0 then
      pv("Saving changes to "..file)
      WriteToFile(ConvertLineTableToText(FileTable), file)	
    end
    
  else
    Report(property,"Could not find PRECEDING_KEY_WORDS or SPECIAL_KEY_WORDS!","WARNING")
  end
  
  return FileTable, ReplNumber, ADDcount, REMOVEcount
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--***************************************************************************    
function GetUSINGsections(SectionsTable)
  --all "Using" sections
  local UsingSections = {}
  
  --all other sections
  local OtherSections = {}
  
  for j=1,#SectionsTable do
    if string.find(SectionsTable[j],"Using",1,true) ~= nil then
      --lines with "Using"
      table.insert(UsingSections,SectionsTable[j])
    else
      --lines without "Using"
      table.insert(OtherSections,SectionsTable[j])
    end
  end
  return UsingSections,OtherSections
end
--***************************************************************************    

-- *************************************** handles SECTION_ACTIVE ***********************************
function ProcessSECTION_ACTIVE(SectionsTable,section_active)
  --================================================================
  local function SortList(one,two)
    return (one < two)
  end
  --================================================================
  
  if #section_active == 0 then
    return SectionsTable
  end
  
  --sort ascending
  table.sort(section_active,SortList)
  
  local UsingSections,OtherSections = GetUSINGsections(SectionsTable)
  
  for i=1,#section_active do
    if section_active[i] <= #UsingSections then
      -- print("Z ["..UsingSections[section_active[i]].."]")
      --add back lines with "Using" that are Active
      table.insert(OtherSections,UsingSections[section_active[i]])
    end
  end

  return OtherSections
end
-- *************************************** END: handles SECTION_ACTIVE ******************************

--**************************************** FindGroup() ***********************************    
function FindGroup(FileName,TextFileTable,WholeTextFile,prec_key_words,IsPrecedingFirstTRUE
                  ,IsSpecialKeyWords,spec_key_words,section_up_special,section_up_preceding)
  
  local SectionStartLine = {}
  local SectionEndLine = {}
  local PrecKeyWordLine = {}
    
  --***************************************************************************************************
  --template only
  local function A()
  end
  --***************************************************************************************************

  --***************************************************************************************************
  local function IsPrec_key_wordsExist(prec_key_words)
    local SearchPrec = false
    for i=1,#prec_key_words do
      if prec_key_words[i] ~= nil and prec_key_words[i] ~= "" then
        SearchPrec = true
        break
      end
    end
    return SearchPrec
  end

  --***************************************************************************************************
  --locate all Sections pointed to by PrecedingKeywords inside given section recursively
  local function LocatePrecKeywordsInSection(TextFileTable,prec_key_words,index,StartLine,EndLine,level,groupId)
    pv("\n  Entering LocatePrecKeywordsInSection()")
    if groupId == nil then groupId = "" end
    local currentLevel = level
    
    pv()
    pv("*** IN values for groupSection #"..groupId)
    pv("    level = "..level)
    pv("StartLine = "..StartLine)
    pv("  EndLine = "..EndLine)
    pv("    index = "..index..", looking for ["..prec_key_words[index].."]")
    pv()
    
    --we quit if we get into negative levels, we should have quit when past EndLine (unless the file is malformed)

    --we start at StartLine: the first line inside this section
    for n = StartLine,EndLine do
      local line = string.upper(TextFileTable[n])
      -- pv("   Looking at: "..n..", ["..line.."]")
      
      if string.find(line,[[">]],1,true) ~= nil then
        --a StartOfSection line
        --let us find ALL sections at level
        level = level + 1
          
        if level >= currentLevel then
          local j = index
          if string.find(line,[["]]..string.upper(prec_key_words[j])..[["]],1,true) ~= nil then
            pv("      Found SOS: ["..string.upper(prec_key_words[j]).."] at line "..n)
            --found a line inside this section
            --record Section Start/End lines --and level
            if j == #prec_key_words then
              --we found the last prec_key_words in this section
              --this is a GOOD section pointed by these prec_key_words
              pv("      found LAST PK word: ["..prec_key_words[j].."] at line "..n)

              local SectionNum = #PrecKeyWordLine + 1
              PrecKeyWordLine[SectionNum] = n
              SectionStartLine[SectionNum] = n
              SectionEndLine[SectionNum]   = GoDownToOwnerEnd(TextFileTable,n+1)
              pv("         *** OUT values: "..SectionStartLine[SectionNum].." - "..SectionEndLine[SectionNum].." ("..PrecKeyWordLine[SectionNum]..")")

              -- could there be other sub-sections meeting the prec_key_words?
              index = 1 -- reset to first keyword
            else
              --not the last word, continue searching using the next keyword
              
              j = j + 1 --point to the next keyword
              pv("      index is now = "..j)
              pv("\n  continuying search recursively...")
              LocatePrecKeywordsInSection(TextFileTable,prec_key_words,j,n+1,EndLine,level,groupId)
              index = 1
            end            
          end
        else
          --skip it, wrong level
        end
        
      elseif string.find(line,[[y>]],1,true) ~= nil then
        --this is a </Property> line
        level = level - 1
        
      else
        --not a StartOfSection line, just a regular <Property name="NumStatsMin" value="1" /> line
        --skip it
      end
    end
    
    pv("\n  Leaving LocatePrecKeywordsInSection()")
    return SectionStartLine,SectionEndLine,PrecKeyWordLine
  end

  --***************************************************************************************************
  local function ReportLPKISresults(tStartLine,tEndLine,tSpecialLine,numRecord)
    pv("")
    if #tStartLine == 0 then
      pv("  >>> XXXX No section found XXXX")
      --return the whole file
      SectionStartLine[1] = tStartLine[1]
      SectionEndLine[1] = tEndLine[1]
      PrecKeyWordLine[1] = 0
    else
      pv("  >>> "..#tStartLine.." section(s) found so far")
      pv("  *** this section FINAL values ***")
      for i=numRecord + 1,#tStartLine do
        pv("  *** "..tStartLine[i].." - "..tEndLine[i].." ("..tSpecialLine[i]..")")
      end
      pv("")
    end    
  end
  --***************************************************************************************************

  --********************************* PrecKeywordsSections() *******************************************
  --locate all Sections pointed to by ALL PREC_KEY_WORDS inside these groups
  local function PrecKeywordsSections(TextFileTable,prec_key_words,GroupStartLine,GroupEndLine)
    pv("\n  Entering PrecKeywordsSections()")
    local GroupStartLine = GroupStartLine --a table
    local GroupEndLine = GroupEndLine --a table
    local PrecKeyWordLine = {0}
    
    local tempStartLine = {}
    local tempEndLine = {}
    local tempSpecialLine = {}
    
    pv("\n  #PK-GROUPS = "..#GroupStartLine)
    for i=1,#GroupStartLine do
      --try to find the sections pointed to by the PREC_KEY_WORDS in this GroupSection
      local index = 1 --we start with the first PREC_KEY_WORDS
      local level = 0 --we say this GroupSection is at level 0

      local numRecord = #tempStartLine
      
      local tStartLine,tEndLine,tSpecialLine = 
            LocatePrecKeywordsInSection(TextFileTable,prec_key_words,index,GroupStartLine[i]+1,GroupEndLine[i],level,i)
      
      ReportLPKISresults(tStartLine,tEndLine,tSpecialLine,numRecord)
      pv(" LPKIS-RESULTS #= "..#tStartLine.." for PK-group #"..i)
      
      for k=numRecord + 1,#tStartLine do
        tempStartLine[#tempStartLine+1] = tStartLine[k]
        tempEndLine[#tempEndLine+1] = tEndLine[k]
        tempSpecialLine[#tempSpecialLine+1] = tSpecialLine[k]
      end        
    end
      
    pv("")
    pv("  All PK-GROUPS RESULTS #= "..#tempStartLine)
    for i=1,#tempStartLine do
      pv("  >>> "..tempStartLine[i].." - "..tempEndLine[i].." ("..tempSpecialLine[i]..")")
    end
    
    if #tempStartLine == 0 then
      pv("  >>> No sections found")
      -- tempStartLine = {3}
      -- tempEndLine = {#TextFileTable}
      -- tempSpecialLine = {0}          
    end
    pv("  END RESULTS for PrecKeywordsSections()")
    pv("")
    
    return tempStartLine,tempEndLine,tempSpecialLine
  end
  --********************************* END: PrecKeywordsSections() *******************************************

  --***************************************************************************************************  
  local function FindKeywordsInLine(text)
    local KeywordsInLineTable = {}

    if string.find(text,[[me="]],1,true) ~= nil and string.find(text,[[ue=]],1,true) ~= nil then
      --a line like <Property name="" value="" /> 
      --"name" is a potential special_keyword
      local value = StripInfo(text,[[ue="]],[["]])
      -- if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil and string.find(value,".",1,true) == nil then
      -- if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
      if value ~= "" then
        local name = StripInfo(text,[[me="]],[["]])
        KeywordsInLineTable[#KeywordsInLineTable+1] = {}
        KeywordsInLineTable[#KeywordsInLineTable][1] = string.upper(name)
        KeywordsInLineTable[#KeywordsInLineTable][2] = string.upper(value)
      end
    end --if string.find(
    
    return KeywordsInLineTable
  end
  --*********************************** END: FindKeywordsInRange() *************************************  

  --***************************************************************************************************
  --locate all Sections pointed to by SpecialKeywords at index, index+1
  local function LocateSpecialKeywordsSections(TextFileTable,index,spec_key_words,StartLine,EndLine)
    local SectionNum = 0
    local SectionStartLine = {}
    local SectionEndLine = {}
    local SpecialKeyWordLine = {}
    pv("\n  LSKS: index = "..index..", ["..spec_key_words[index].."],["..spec_key_words[index+1].."] ("..StartLine.."-"..EndLine..")")

    for n = StartLine,EndLine do
      local line = TextFileTable[n]
      local KeywordsInLineTable = FindKeywordsInLine(line)
      if #KeywordsInLineTable > 0 then
        -- pv("  ["..KeywordsInLineTable[1][1].."]  ["..KeywordsInLineTable[1][2].."]")
        if (string.upper(spec_key_words[index]) == KeywordsInLineTable[1][1] or spec_key_words[index] == "IGNORE")
              and (string.upper(spec_key_words[index+1]) == KeywordsInLineTable[1][2] or spec_key_words[index+1] == "IGNORE") then
          --found a requested SpecialKeywords line, 
          --record Section Start/End lines --and level
          SectionNum = SectionNum + 1
          SpecialKeyWordLine[SectionNum] = n
          if string.sub(trim(line),-2) == [[">]] then
            --this is the start of a section
            SectionStartLine[SectionNum] = n
            --let us find the end of this section, not its parent
            SectionEndLine[SectionNum]   = GoDownToOwnerEnd(TextFileTable,n+1)
          else
            --let us find the start of the section
            SectionStartLine[SectionNum] = GoUPToOwnerStart(TextFileTable,n)
            SectionEndLine[SectionNum]   = GoDownToOwnerEnd(TextFileTable,n)
          end
        end
      end
    end          

    if SectionNum == 0 then
      pv("  >>> XXXX No section found XXXX")
      --no Section found for requested pair
      --return the whole file
      SectionStartLine[1] = StartLine
      SectionEndLine[1] = EndLine
      SpecialKeyWordLine[1] = 0
    else
      pv("  >>> "..SectionNum.." section(s) found")
    end
    
    for i=1,#SectionStartLine do
      pv("   "..SectionStartLine[i].." - "..SectionEndLine[i].." ("..SpecialKeyWordLine[i]..")")
    end

    return SectionStartLine,SectionEndLine,SpecialKeyWordLine
  end

  --***************************************************************************************************
  --locate all Sections pointed to by ALL SPECIAL_KEY_WORDS
  local function SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
    local GroupStartLine = GroupStartLine --a table
    local GroupEndLine = GroupEndLine --a table
    local SpecialKeyWordLine = {0}
    
    --each pair of SPECIAL_KEY_WORDS
    for j=1,#spec_key_words,2 do      
      local tempStartLine = {}
      local tempEndLine = {}
      local tempSpecialLine = {}
      
      pv("\nSK-GROUPS #= "..#GroupStartLine)
      for i=1,#GroupStartLine do
        local StartLine,EndLine,SpecialLine = 
              LocateSpecialKeywordsSections(TextFileTable,j,spec_key_words,GroupStartLine[i],GroupEndLine[i])
        pv(" LSKS-RESULTS #= "..#StartLine.." for SK-group "..j)
        for k=1,#StartLine do
          -- if SpecialLine[k] ~= nil and SpecialLine[k] > 0 then
            -- --keep new section
            -- -- pv(">>> Keep section")
            tempStartLine[#tempStartLine+1] = StartLine[k]
            tempEndLine[#tempEndLine+1] = EndLine[k]
            tempSpecialLine[#tempSpecialLine+1] = SpecialLine[k]
          -- end
        end        
      end
      
      GroupStartLine = {}
      GroupEndLine = {}
      SpecialKeyWordLine = {}
      -- pv("B-RESULTS #= "..#tempStartLine)
      for k=1,#tempStartLine do
        -- pv("tempSpecialLine["..k.."] = "..tempSpecialLine[k])
        if tempSpecialLine[k] > 0 then
          -- pv(">>> Keep section")
          GroupStartLine[#GroupStartLine+1] = tempStartLine[k]
          GroupEndLine[#GroupEndLine+1] = tempEndLine[k]
          SpecialKeyWordLine[#SpecialKeyWordLine+1] = tempSpecialLine[k]
        end
      end        
    end
    
    pv("All SK-GROUPS RESULTS #= "..#GroupStartLine)
    for i=1,#GroupStartLine do
      pv("   "..GroupStartLine[i].." - "..GroupEndLine[i].." ("..SpecialKeyWordLine[i]..")")
    end
    
    if #GroupStartLine == 0 then
      pv(">>> No sections found in SpecialKeywordsSections()")
      GroupStartLine = {3}
      GroupEndLine = {#TextFileTable}
      SpecialKeyWordLine = {0}          
    end
    pv("END RESULTS for SpecialKeywordsSections()")
    pv("")
    
    return GroupStartLine,GroupEndLine,SpecialKeyWordLine
  end
    
  --***************************************************************************************************
  --for each section in reverse order (because we remove unwanted ones)
  --remove overlapping ones
  local function PurgeOverlappingSections(GroupStartLine,GroupEndLine,KeyWordLine,KeepOuterSections)
    for i=#GroupStartLine,2,-1 do
      if KeepOuterSections then
        --keep outer sections only
        if GroupStartLine[i] <= GroupEndLine[i-1] then
          --section i is inside section i-1
          --remove section i
          table.remove(GroupStartLine,i)
          table.remove(GroupEndLine,i)
          table.remove(KeyWordLine,i)
        end
      else
        --keep inner sections only
        if GroupStartLine[i] <= GroupEndLine[i-1] then
          --section i is inside section i-1
          --remove section i-1
          table.remove(GroupStartLine,i-1)
          table.remove(GroupEndLine,i-1)
          table.remove(KeyWordLine,i-1)
        end
      end
    end
    
    return GroupStartLine,GroupEndLine,KeyWordLine
  end

  --#####################################  Start of main FindGroup() code  ##############################################################
  pv("\n    >>> Starting FindGroup()\n")
  
  local KeepOuterSections = true --we will see if this needs to be an option in the future
  local LastResort = false
  
  -- local FoundNum = 0
  
  local GroupStartLine = {3}
  local GroupEndLine = {#TextFileTable}
  local SpecialKeyWordLine = {0}
  local SectionsTable = {}
  
  local All_Words_Found = false
  local All_SpecialWords_Found = false
  local All_PrecedingWords_Found = false

  -- local done_All_Words = false
  -- local ReturnInfo = false
  
  local IsPrec_key_words = IsPrec_key_wordsExist(prec_key_words)

  pv("IsPrecedingFirstTRUE = "..tostring(IsPrecedingFirstTRUE))
  pv("IsSpecialKeyWords = "..tostring(IsSpecialKeyWords))
  pv("IsPrec_key_words = "..tostring(IsPrec_key_words))
  
  if not IsSpecialKeyWords then
    --let us do as if IsPrecedingFirstTRUE was true
    IsPrecedingFirstTRUE = true
    pv("   >>> no SpecialKeywords so: IsPrecedingFirstTRUE is now = "..tostring(IsPrecedingFirstTRUE))
  end
  
  if not IsPrecedingFirstTRUE then
    --*******************  process SpecialKeyWords FIRST if any  *********************************
    if IsSpecialKeyWords then
      local Info = GetSpecKeyWordsInfo(spec_key_words)
      pv("\n"..[[  SK     >>> Trying to locate Group Start/End lines based on SPECIAL_KEY_WORDS ]]..Info.."\n")

      --Check Uniqueness
      local s = [[<Property name="]]..spec_key_words[1]..[[" value="]]..spec_key_words[2]..[["]] --the end could be [[ />]] or [[>]]
      -- pv("["..s.."]")
      --fastest way!!! --gsub and gmatch take too long
      local firstPosStart,firstPosEnd = string.find(WholeTextFile,s,1,true)
      local secondPos = nil
      if firstPosEnd ~= nil then
        secondPos = string.find(WholeTextFile,s,firstPosEnd+1,true)
        if secondPos == nil then
          count = 1
          pv("CheckUniqueness: Unique")
        else
          count = 2
          pv("CheckUniqueness: More than one")
        end
      else
        count = 0
        pv("CheckUniqueness: Not found")     
      end
      --end Check Uniqueness

      if count == 1 then
        --count = 1 >>> unique, good (SCRIPTBUILDER guaranties uniqueness, user do not)
        --    record range info
        pv("\n  SK     >>> count = 1, Looking for SPECIAL_KEY_WORDS between lines "..GroupStartLine[1].." and "..GroupEndLine[1].."\n")
        GroupStartLine,GroupEndLine,SpecialKeyWordLine = SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
        
        RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SK1",SectionsTable)
        
        --**************************************** handle SECTION_UP_SPECIAL ***********************************    
        if section_up_special > 0 then
          pv("   Found SECTION_UP_SPECIAL = "..section_up_special)
          GroupStartLine,GroupEndLine,SpecialKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,SpecialKeyWordLine,section_up_special)
          RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"US",SectionsTable)    
        end
        --**************************************** end: handle SECTION_UP_SPECIAL ***********************************    
        
        -- pv(type(SpecialKeyWordLine))
        -- pv(#SpecialKeyWordLine)
        -- pv(type(SpecialKeyWordLine[1]))
        if SpecialKeyWordLine[1] > 0 then        
          -- FoundNum = FoundNum + 1
          -- All_Words_Found = true
          All_SpecialWords_Found = true
          pv("\n  SK     count = 1, Found SPECIAL_KEY_WORDS between lines "..GroupStartLine[1].." and "..GroupEndLine[1].."\n")
        end
        
        if All_SpecialWords_Found then
          if IsPrec_key_words then
            pv("\n  SKPK     >>> count = 1, Now looking for PREC_KEY_WORDS\n")
            --lets try with all the PREC_KEY_WORDS
            --here: only 1 section to search

            TopLine,BottomLine,PrecKeyWordLine = PrecKeywordsSections(TextFileTable,prec_key_words,GroupStartLine,GroupEndLine)
            All_PrecedingWords_Found = (#TopLine > 0)

            --All_PrecedingWords_Found,TopLine,BottomLine = LocatePrecKeywordsWithTreeMap(FILE_LINE,TREE_LEVEL,KEY_WORDS,GroupStartLine[1],GroupEndLine[1])
            
            if All_PrecedingWords_Found then
              GroupStartLine = TopLine
              GroupEndLine = BottomLine
              SpecialKeyWordLine = PrecKeyWordLine

              RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKPK1",SectionsTable)
              pv("\n  SKPK     >>> count = 1, Found PREC_KEY_WORDS between lines "..GroupStartLine[1].." and "..GroupEndLine[1].."\n")
            
            else
              if #prec_key_words == 1 and prec_key_words[#prec_key_words] ~= "" then
                pv("\n  SKPK     >>> count = 1, Only one PREC_KEY_WORDS and not found in section")
                --we have a single PRECEDING_KEY_WORDS
                --let us try to find it in the current section
                
                -- look for the last prec_key_words line in the SpecialWords range
                for n = GroupStartLine[1], GroupEndLine[1] do
                  local line = TextFileTable[n]
                  if string.find(line,[["]]..prec_key_words[#prec_key_words]..[["]],1,true) then
                    --found the line, replace the Group Start/End lines
                    SpecialKeyWordLine[1] = n -- 'the' line
                    GroupStartLine[1] = GoUPToOwnerStart(TextFileTable,n)
                    GroupEndLine[1] = GoDownToOwnerEnd(TextFileTable,GroupStartLine[1]+1)
                    pv("\n  SKPK     >>> count = 1, Found last PREC_KEY_WORDS "..[["]]..prec_key_words[#prec_key_words]..[["]].." at line "..SpecialKeyWordLine[1].."\n")
                    All_PrecedingWords_Found = true
                    
                    IsOnlyOnePreceding = true
                    
                    break
                  end
                end
              
                RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKPKL",SectionsTable)
                
                if not All_PrecedingWords_Found then
                  print("")
                  print(_zRED..">>> [WARNING] PRECEDING_KEY_WORDS ".."["..prec_key_words[#prec_key_words].."] NOT found in the current section, IGNORING IT".._zDEFAULT)
                  Report("","PRECEDING_KEY_WORDS ".."["..prec_key_words[#prec_key_words].."] NOT found in the current section, IGNORING IT","WARNING")
                  
                  -- --let us just do as if prec_key_words was not there
                  -- All_PrecedingWords_Found = true
                end
                
              else --multiple prec_key_words NOT FOUND
                print("")
                print(_zRED..">>> [WARNING] PRECEDING_KEY_WORDS NOT found in the current section, IGNORING THEM".._zDEFAULT)
                Report("","PRECEDING_KEY_WORDS NOT found in the current section, IGNORING THEM","WARNING")
              end
            end
            
            --**************************************** handle SECTION_UP_PRECEDING ***********************************    
            if section_up_preceding > 0 then
              pv("   Found SECTION_UP_PRECEDING = "..section_up_preceding)
              GroupStartLine,GroupEndLine,PrecKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,PrecKeyWordLine,section_up_preceding)
              RecordSections(GroupStartLine,GroupEndLine,PrecKeyWordLine,"aUP",SectionsTable)    
            end
            --**************************************** end: handle SECTION_UP_PRECEDING ***********************************    

          end
          
          --return range info
          -- ReturnInfo = true
          
        else
          local Info = GetSpecKeyWordsInfo(spec_key_words)      
          Report("",[[Should have found SPECIAL_KEY_WORDS: ]]..Info,"WARNING")
          print(_zRED.."\n"..[[>>> [WARNING] Should have found SPECIAL_KEY_WORDS: ]]..Info.._zDEFAULT)
          -- ReturnInfo = true
        end

      elseif count > 1 then
        --count > 1 >>> not unique, maybe good or bad (not a SCRIPTBUILDER script)
        pv("\n  SK     >>> count > 1, SPECIAL_KEY_WORDS ["..spec_key_words[1].."] and ["..spec_key_words[2].."] are not unique in file!\n")

        -- local Done = false
        
        GroupStartLine,GroupEndLine,SpecialKeyWordLine = SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
        pv([[A ]]..#GroupStartLine..[[ ]]..#GroupEndLine..[[ ]]..#SpecialKeyWordLine)
        GroupStartLine,GroupEndLine,SpecialKeyWordLine = PurgeOverlappingSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,KeepOuterSections)
        
        RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKx",SectionsTable)
        -- ShowSections(SectionsTable)        
        
        --**************************************** handle SECTION_UP_SPECIAL ***********************************    
        if section_up_special > 0 then
          pv("   Found SECTION_UP_SPECIAL = "..section_up_special)
          GroupStartLine,GroupEndLine,SpecialKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,SpecialKeyWordLine,section_up_special)
          RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"bUS",SectionsTable)    
        end
        --**************************************** end: handle SECTION_UP_SPECIAL ***********************************    
        
        -- --here we have all the sections (or the whole file) pointed by the spec_key_words
        -- pv(">>> BASED on SPECIAL_KEY_WORDS, #Sections = "..#GroupStartLine)          
        -- for i=1,#GroupStartLine do
          -- pv("   "..i..": "..GroupStartLine[i].."-"..GroupEndLine[i]..", "..SpecialKeyWordLine[i])
        -- end
        
        if SpecialKeyWordLine[1] > 0 then        
          -- FoundNum = #SpecialKeyWordLine
          -- All_Words_Found = true
          All_SpecialWords_Found = true

          if IsPrec_key_words then
            local tmpGroupStartLine = {}
            local tmpGroupEndLine = {}
            local tmpSpecialKeyWordLine = {}
            
            All_PrecedingWords_Found = false

            --lets try with all the PREC_KEY_WORDS
            TopLine,BottomLine,PrecKeyWordLine = PrecKeywordsSections(TextFileTable,prec_key_words,GroupStartLine,GroupEndLine)
            All_PrecedingWords_Found = (#TopLine > 0)

            --All_PrecedingWords_Found,TopLine,BottomLine = LocatePrecKeywordsWithTreeMap(FILE_LINE,TREE_LEVEL,KEY_WORDS,GroupStartLine[i],GroupEndLine[i])
            
            if All_PrecedingWords_Found then
              for j=1,#TopLine do
                table.insert(tmpSpecialKeyWordLine,PrecKeyWordLine[j])
                table.insert(tmpGroupStartLine,TopLine[j])
                table.insert(tmpGroupEndLine,BottomLine[j])
                -- pv("  SKPK     >>> count > 1, Found PREC_KEY_WORDS between lines "..tmpGroupStartLine[j].." and "..tmpGroupEndLine[j])
              end
              
              RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKxPKx",SectionsTable)
              
            else
              if #prec_key_words == 1 and prec_key_words[#prec_key_words] ~= "" then
                --look for the last prec_key_words line in that range
                --for all sections found
                for i=1,#GroupStartLine do
                  for n = GroupStartLine[i], GroupEndLine[i] do
                    local line = TextFileTable[n]
                    if string.find(line,[["]]..prec_key_words[#prec_key_words]..[["]],1,true) then
                      --found the line, save the Group Start/End lines
                      table.insert(tmpSpecialKeyWordLine,n) -- 'the' line
                      table.insert(tmpGroupStartLine,GoUPToOwnerStart(TextFileTable,n))
                      table.insert(tmpGroupEndLine,GoDownToOwnerEnd(tmpGroupStartLine(#tmpGroupStartLine))) --the end of the section defined by SPECIAL_KEYWORDS
                      All_PrecedingWords_Found = true
                      pv("  SKPK     >>> count > 1, Found last PREC_KEY_WORDS "..[["]]..prec_key_words[#prec_key_words]..[["]].." at line "..tmpGroupStartLine[1])
                      
                      IsOnlyOnePreceding = true
                      
                      break
                    end
                  end
                end --for i=1,#GroupStartLine do
                
                RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKxPKL",SectionsTable)
                
                if All_PrecedingWords_Found then
                  --at least one section was found
                else
                  RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKPKx",SectionsTable)
                  ShowSections(SectionsTable)        
                  
                  print(_zRED..">>> [WARNING] PRECEDING_KEY_WORDS NOT found in any section, IGNORING THEM".._zDEFAULT)
                  Report("","PRECEDING_KEY_WORDS NOT found in any section, IGNORING THEM","WARNING")
                end
                
              else
                RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"SKPKy",SectionsTable)
                ShowSections(SectionsTable)        
                
                print("")
                print(_zRED..">>> [WARNING] ALL PRECEDING_KEY_WORDS NOT found in any section, IGNORING THEM".._zDEFAULT)
                Report("","ALL PRECEDING_KEY_WORDS NOT found in any section, IGNORING THEM","WARNING")
              end
            end
              
            -- GroupStartLine,GroupEndLine,SpecialKeyWordLine = SectionsTableToLines(SectionsTable)
            
            -- ReturnInfo = true -- return range info
            
            if #tmpSpecialKeyWordLine > 0 then
              --remove old sections
              for j=1,#SpecialKeyWordLine do
                table.remove(SpecialKeyWordLine)
                table.remove(GroupStartLine)
                table.remove(GroupEndLine)            
              end
              
              --these tables are now empty
              
              --add the new sections
              for j=1,#tmpSpecialKeyWordLine do
                table.insert(SpecialKeyWordLine,tmpSpecialKeyWordLine[j])
                table.insert(GroupStartLine,tmpGroupStartLine[j])
                table.insert(GroupEndLine,tmpGroupEndLine[j])            
              end
            else
              --just keep the old tables
            end
            
            --**************************************** handle SECTION_UP_PRECEDING ***********************************    
            if section_up_preceding > 0 then
              pv("   Found SECTION_UP_PRECEDING = "..section_up_preceding)
              GroupStartLine,GroupEndLine,PrecKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,PrecKeyWordLine,section_up_preceding)
              RecordSections(GroupStartLine,GroupEndLine,PrecKeyWordLine,"bUP",SectionsTable)    
            end
            --**************************************** end: handle SECTION_UP_PRECEDING ***********************************    

          end --if IsPrec_key_words then
          
        else
          if #SpecialKeyWordLine == 0 then
            Report("",[[Should have found all SPECIAL_KEY_WORDS]],"ERROR")
            print(_zRED.."\n"..[[>>> [ERROR] Should have found all SPECIAL_KEY_WORDS]].._zDEFAULT)
            -- ReturnInfo = true
          end
        end
        
      else --count = 0 >>> not found, problem (not a SCRIPTBUILDER script)
        --    user has a problem with his/her script spec_key_words (SCRIPTBUILDER guaranties it can be found)
        --    Report WARNING, skip this change
        Report("","SPECIAL_KEY_WORDS cannot be found.  Skipping this change!","WARNING")
        print(_zRED.."\n>>> [WARNING] SPECIAL_KEY_WORDS cannot be found.  Skipping this change!".._zDEFAULT)
        All_SpecialWords_Found = false
        -- ReturnInfo = true
      end --if count...
    end
    
  else -- PRECEDING_FIRST = "True"
    --*******************  process PrecedingKeyWords FIRST if any  *********************************
    if IsPrec_key_words then
      pv("\n  PK     >>> INTO: PRECEDING_FIRST: find all SECTIONs with ALL PRECEDING_KEY_WORDS...\n")
      -- --find the SECTION using TreeMap
      -- pv("     >>> INTO: find the first SECTION with ALL PRECEDING_KEY_WORDS using TreeMap...")
      
      -- local LocateSectionWithPrecKeywords()
      
      --lets try with all the PREC_KEY_WORDS
      TopLine,BottomLine,PrecKeyWordLine = PrecKeywordsSections(TextFileTable,prec_key_words,GroupStartLine,GroupEndLine)
      All_PrecedingWords_Found = (#TopLine > 0)

      if All_PrecedingWords_Found then
        -- FoundNum = FoundNum + 1
        -- GroupStartLine[FoundNum] = TopLine[1]
        -- GroupEndLine[FoundNum] = BottomLine[1]
        GroupStartLine = TopLine
        GroupEndLine = BottomLine
        SpecialKeyWordLine = PrecKeyWordLine
        
      else
        --let us just do as if prec_key_words was not there
        print("")
        print(_zRED..">>> [WARNING] NOT found ALL PRECEDING_KEY_WORDS ".."["..prec_key_words[#prec_key_words].."] in the current section, IGNORING IT".._zDEFAULT)
        Report("","NOT found ALL PRECEDING_KEY_WORDS ".."["..prec_key_words[#prec_key_words].."] in the current section, IGNORING IT","WARNING")
        
        -- --we should check if this PrecedingKeyWord points to a range that includes our SpecialKeyWords
        -- --if yes we can ignore it
        -- --if not we should report it to the user as a WARNING
        -- All_Words_Found = true
      end
      
      RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"PK",SectionsTable)
      -- GroupStartLine,GroupEndLine,SpecialKeyWordLine = SectionsTableToLines(SectionsTable)
      
      --we could have multiple sections pointed to by PRECEDING_KEY_WORDS
      if #GroupStartLine > 1 then
        Report("","PRECEDING_KEY_WORDS located more than one section!","NOTICE")
        print(_zRED.."\n>>> [NOTICE] PRECEDING_KEY_WORDS located more than one section!".._zDEFAULT)
      
      -- elseif FoundNum == 1 and IsSpecialKeyWords then
        -- --found the PRECEDING_KEY_WORDS section
        -- --now look for SPECIAL_KEY_WORDS in it
        -- GroupStartLine,GroupEndLine,SpecialKeyWordLine = SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
        -- pv([[B ]]..#GroupStartLine..[[ ]]..#GroupEndLine..[[ ]]..#SpecialKeyWordLine)
        
        -- GroupStartLine,GroupEndLine,SpecialKeyWordLine = PurgeOverlappingSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,KeepOuterSections)
        
        -- --here we have all the sections (or the whole file) pointed by the spec_key_words
        -- pv(">>> BASED on SPECIAL_KEY_WORDS, #Sections = "..#GroupStartLine)          
        -- for i=1,#GroupStartLine do
          -- pv("   "..GroupStartLine[i].."-"..GroupEndLine[i]..", "..SpecialKeyWordLine[i])
        -- end
      end
      
      if not All_PrecedingWords_Found then
        local Info = GetPrecKeyWordsInfo(prec_key_words)
        Report("","    -- >>>>> Could not find [\"PRECEDING_KEY_WORDS\"] = "..Info.." <<<<<")
        print(">>> [NOTICE] -- >>>>> Could not find [\"PRECEDING_KEY_WORDS\"] = "..Info.." <<<<<".._zDEFAULT)
      end
      
      --**************************************** handle SECTION_UP_PRECEDING ***********************************    
      if section_up_preceding > 0 then
        pv("   Found SECTION_UP_PRECEDING = "..section_up_preceding)
        GroupStartLine,GroupEndLine,PrecKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,PrecKeyWordLine,section_up_preceding)
        RecordSections(GroupStartLine,GroupEndLine,PrecKeyWordLine,"UP",SectionsTable)    
      end
      --**************************************** end: handle SECTION_UP_PRECEDING ***********************************    

    end
    
    if All_PrecedingWords_Found then
      if IsSpecialKeyWords then
        --now find the SpecialKeyWords inside that Section pointed to by the PRECEDING_KEY_WORDS
        local Info = GetSpecKeyWordsInfo(spec_key_words)
        pv("\n"..[[  PKSK     >>> From PRECEDING_KEY_WORDS section, trying to locate Group Start/End lines based on SPECIAL_KEY_WORDS ]]..Info.."\n")

        --Check Uniqueness
        local s = [[<Property name="]]..spec_key_words[1]..[[" value="]]..spec_key_words[2]..[["]] --the end could be [[ />]] or [[>]]
        -- pv("["..s.."]")
        
        --create a file sub-set
        local subsetTextFile = ""
        for i=GroupStartLine[1],GroupEndLine[1] do
          subsetTextFile = subsetTextFile..TextFileTable[i]
        end
        
        --fastest way!!! --gsub and gmatch take too long
        local firstPosStart,firstPosEnd = string.find(subsetTextFile,s,1,true)
        local secondPos = nil
        if firstPosEnd ~= nil then
          secondPos = string.find(subsetTextFile,s,firstPosEnd+1,true)
          if secondPos == nil then
            count = 1
            pv("CheckUniqueness: Unique")
          else
            count = 2
            pv("CheckUniqueness: More than one")
          end
        else
          count = 0
          pv("CheckUniqueness: Not found")     
        end
        --end Check Uniqueness

        if count == 1 then
          --count = 1 >>> unique, good (SCRIPTBUILDER guaranties uniqueness, user do not)
          --    record range info
          pv("\n  PKSK    >>> count = 1, Looking for SPECIAL_KEY_WORDS between lines "..GroupStartLine[1].." and "..GroupEndLine[1].."\n")
          GroupStartLine,GroupEndLine,SpecialKeyWordLine = SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
          
          RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"PKSK1",SectionsTable)
          --GroupStartLine,GroupEndLine,SpecialKeyWordLine = SectionsTableToLines(SectionsTable)
          
          -- pv(type(SpecialKeyWordLine))
          -- pv(#SpecialKeyWordLine)
          -- pv(type(SpecialKeyWordLine[1]))
          if SpecialKeyWordLine[1] > 0 then        
            -- FoundNum = FoundNum + 1
            -- All_Words_Found = true
            All_SpecialWords_Found = true
            pv("  PKSK    >>> count = 1, Found SPECIAL_KEY_WORDS between lines "..GroupStartLine[1].." and "..GroupEndLine[1])
          end
          
          if not All_SpecialWords_Found then
            local Info = GetSpecKeyWordsInfo(spec_key_words)      
            Report("",[[Should have found SPECIAL_KEY_WORDS: ]]..Info,"WARNING")
            print(_zRED.."\n"..[[>>> [WARNING] Should have found SPECIAL_KEY_WORDS: ]]..Info.._zDEFAULT)
          end
          
          --**************************************** handle SECTION_UP_SPECIAL ***********************************    
          if section_up_special > 0 then
            pv("   Found SECTION_UP_SPECIAL = "..section_up_special)
            GroupStartLine,GroupEndLine,SpecialKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,SpecialKeyWordLine,section_up_special)
            RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"aUS",SectionsTable)    
          end
          --**************************************** end: handle SECTION_UP_SPECIAL ***********************************    
          
          -- ReturnInfo = true

        elseif count > 1 then
          --count > 1 >>> not unique, maybe good or bad (not a SCRIPTBUILDER script)
          pv("\n  PKSK    >>> count > 1, SPECIAL_KEY_WORDS ["..spec_key_words[1].."] and ["..spec_key_words[2].."] are not unique in file!\n")

          GroupStartLine,GroupEndLine,SpecialKeyWordLine = SpecialKeywordsSections(TextFileTable,spec_key_words,GroupStartLine,GroupEndLine)
          pv([[A ]]..#GroupStartLine..[[ ]]..#GroupEndLine..[[ ]]..#SpecialKeyWordLine)
          GroupStartLine,GroupEndLine,SpecialKeyWordLine = PurgeOverlappingSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,KeepOuterSections)
          
          RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"PKSKx",SectionsTable)
          --GroupStartLine,GroupEndLine,SpecialKeyWordLine = SectionsTableToLines(SectionsTable)
          
          --here we have all the sections (or the whole file) pointed by the spec_key_words
          pv("  PKSK    >>> BASED on SPECIAL_KEY_WORDS, #Sections = "..#GroupStartLine)          
          for i=1,#GroupStartLine do
            pv("   "..GroupStartLine[i].."-"..GroupEndLine[i].." ("..SpecialKeyWordLine[i]..")")
          end
          
          if SpecialKeyWordLine[1] > 0 then        
            -- FoundNum = #SpecialKeyWordLine
            -- All_Words_Found = true
            All_SpecialWords_Found = true

          else
            if #SpecialKeyWordLine == 0 then
              Report("",[[Should have found all SPECIAL_KEY_WORDS]],"ERROR")
              print(_zRED.."\n"..[[>>> [ERROR] Should have found all SPECIAL_KEY_WORDS]].._zDEFAULT)
              -- ReturnInfo = true
            end
          end
          
          --**************************************** handle SECTION_UP_SPECIAL ***********************************    
          if section_up_special > 0 then
            pv("   Found SECTION_UP_SPECIAL = "..section_up_special)
            GroupStartLine,GroupEndLine,SpecialKeyWordLine = Process_SectionUP(TextFileTable,GroupStartLine,GroupEndLine,SpecialKeyWordLine,section_up_special)
            RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"bUS",SectionsTable)    
          end
          --**************************************** end: handle SECTION_UP_SPECIAL ***********************************    
          
        else
          --count = 0 >>> not found, problem (not a SCRIPTBUILDER script)
          --    user has a problem with his/her script spec_key_words (SCRIPTBUILDER guaranties it can be found)
          --    Report WARNING, skip this change
          Report("","SPECIAL_KEY_WORDS cannot be found.  Skipping this change!","WARNING")
          print(_zRED.."\n>>> [WARNING] SPECIAL_KEY_WORDS cannot be found.  Skipping this change!".._zDEFAULT)
          -- ReturnInfo = true
        end --if count...
      end --if IsSpecialKeyWords then
    end --if All_PrecedingWords_Found then
  end --if not IsPrecedingFirstTRUE then
  
  pv("")
  pv([[FindGroup() "ending", Sanity check: ]]..#GroupStartLine..[[ ]]..#GroupEndLine..[[ ]]..#SpecialKeyWordLine..[[ ]])
  GroupStartLine,GroupEndLine,SpecialKeyWordLine = PurgeOverlappingSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,KeepOuterSections)
  
  -- RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,"Using ",SectionsTable)
  
  All_Words_Found = false
  if IsSpecialKeyWords then
    if All_SpecialWords_Found then
      if IsPrec_key_words then
        if All_PrecedingWords_Found then
          All_Words_Found = true
        end
      else
        All_Words_Found = true
      end
    end
  else
    if IsPrec_key_words and All_PrecedingWords_Found then
      All_Words_Found = true
    end
  end
  
  if TestNoNil("FindGroup()",All_Words_Found,GroupStartLine[1],GroupEndLine[1],SpecialKeyWordLine[1]) then
    pv("")
    pv("Found all Key_Words: "..tostring(All_Words_Found)..", First line: "..GroupStartLine[1]..", Last line: "..GroupEndLine[1])
    pv("Found all SPECIAL_KEY_WORDS: "..tostring(All_SpecialWords_Found))
    pv("Found all PRECEDING_KEY_WORDS: "..tostring(All_PrecedingWords_Found))
  end
  
  pv("\n"..THIS.."Ending FindGroup()\n")
  return All_Words_Found, GroupStartLine, GroupEndLine, SpecialKeyWordLine, LastResort, SectionsTable, IsOnlyOnePreceding                 
end
--**************************************** END: FindGroup() ***********************************    

--***************************** RemoveDuplicateGroups() **********************************************  
--recreate Group List and remove duplicates
function RemoveDuplicateGroups(newGSL,newGEL,newSKWL)
  GroupStartLine = {}
  GroupEndLine = {}
  SpecialKeyWordLine = {}
  for i=1,#newGSL do
    if i > 1 then
      if newGSL[i] ~= newGSL[i-1] then
        table.insert(GroupStartLine,newGSL[i])
        table.insert(GroupEndLine,newGEL[i])
        table.insert(SpecialKeyWordLine,newSKWL[i])
      end
    else
      table.insert(GroupStartLine,newGSL[i])
      table.insert(GroupEndLine,newGEL[i])
      table.insert(SpecialKeyWordLine,newSKWL[i])
    end
  end
  return GroupStartLine,GroupEndLine,SpecialKeyWordLine
end
--***************************** END: RemoveDuplicateGroups() **********************************************  
      
--**********************************  ShowSections()  **************************************  
--prints SectionsTable to cmd window if option is ON
function ShowSections(SectionsTable)
  -- print("_mSHOWSECTIONS = ".._mSHOWSECTIONS)
  if _mSHOWSECTIONS == "Y" then
    if #SectionsTable ~= 0 then
      -- local j = 1
      
      -- -- print("_mSHOWEXTRASECTIONS = ".._mSHOWEXTRASECTIONS)
      -- if _mSHOWEXTRASECTIONS == "N" then
        -- --let us filter out those EXTRA, keep only the Using lines at the end
        -- for i=1,#SectionsTable do
          -- local st = trim(SectionsTable[i])
          -- if string.find(st,"Using",1,true) == nil then
            -- --skip this line
            -- j = j + 1
          -- end
        -- end
      -- end
      
      local stripUSING = ""
      local spacer = ""
      -- if j > 1 then
        stripUSING = "Using "
        spacer = "      "
      -- end
      
      local sinfo = ""
      --sinfo = string.gsub(SectionsTable[j],"Using ","")
      print("    Section(s) found: ")
      
      for i=1,#SectionsTable-1 do
        local st = trim(SectionsTable[i])
        if string.find(st,"Using",1,true) == nil then
          if _mSHOWEXTRASECTIONS == "Y" then
            print("X:                "..spacer..st)
          end
        else
          sinfo = string.gsub(st,stripUSING,"")
          print("N:                "..spacer..sinfo)
        end
      end
      sinfo = string.gsub(SectionsTable[#SectionsTable],stripUSING,"")
      print("                  "..spacer..sinfo)
    end
  end
end
--**********************************  END: ShowSections()  **************************************  

--**************************************** SectionsTableToLines() ***********************************    
--extracts GroupStartLine,GroupEndLine from SectionsTable
function SectionsTableToLines(SectionsTable)
  pv("In SectionsTableToLines()")
  local GroupStartLine = {}
  local GroupEndLine = {}
  local KeyWordLine = {}
  
  for i=1,#SectionsTable do
    local st = trim(SectionsTable[i])
    --now remove any text before the number
    while string.sub(st,1,1) ~= " " do
      st = string.sub(st,2)
    end
    
    st = trim(st)
    pv("["..st.."]")
    
    local gsl = tonumber(string.sub(st,1,string.find(st," - ",1,true)-1))
    local gel = tonumber(string.sub(st,string.find(st," - ",1,true)+3,string.find(st,"(",1,true)-1))
    local KWL = tonumber(string.sub(st,string.find(st,"(",1,true)+1,string.find(st,")",1,true)-1))
    table.insert(GroupStartLine,gsl)
    table.insert(GroupEndLine,gel)
    table.insert(KeyWordLine,KWL)
  end
  
  return GroupStartLine,GroupEndLine,KeyWordLine
end
--**************************************** END: SectionsTableToLines() ***********************************    

--************************************ RecordSections() **************************************
--updates SectionsTable with "Tag GroupStartLine - GroupEndLine"
function RecordSections(GroupStartLine,GroupEndLine,SpecialKeyWordLine,Tag,SectionsTable)
  pv("In RecordSections()")
  if Tag == nil then Tag = "" end
  if GroupStartLine[1] ~= nil or GroupStartLine[1] ~= "" then
    -- local GroupRange = GroupStartLine[1].." - "..GroupEndLine[1]
    -- print("    Current section(s): "..Tag..GroupRange)
    for i=1,#GroupStartLine do
      GroupRange = GroupStartLine[i].." - "..GroupEndLine[i].." ("..SpecialKeyWordLine[i]..")"
      pv("                        ".."  "..GroupRange)
      table.insert(SectionsTable,Tag..string.rep(" ",7-string.len(Tag)).." "..GroupRange)
    end
  end
end
--************************************ END: RecordSections() **************************************

function LocatePAK(filename)
  pv("In LocatePAK()")

  local Pak_FileName = ""
  
  filename = string.gsub(filename,[[%.EXML]],[[.MBIN]])
  filename = string.gsub(filename,[[\]],[[/]])
  -- pv("["..filename.."]")
  local pak_listTable = gpak_listTable
  -- pv(#pak_listTable.." lines")
  for i=1,#pak_listTable,1 do
		local line = pak_listTable[i]
		if (line ~= nil) then
      if string.find(line,"Listing ",1,true) ~= nil then
        local start,stop = string.find(line,"Listing ",1,true)
        --remember Pak_FileName for when we find the filename
        Pak_FileName = string.sub(line, stop+1)
        -- pv("["..Pak_FileName.."]")
      else
        if string.find(line,filename,1,true) ~= nil then
          break
        end
      end
		end
	end
  return Pak_FileName
end

--DO NOT DELETE: kept here to execute for #CPU < 4 and DEBUG
--Only used to create MapFileTree files in HandleModScript()
--MapFileTree files are ALWAYS based on the original EXML
function DisplayMapFileTreeEXT(EXML,filename,Debug,Show)
  --******************************************************************
  --NOT THE SAME AS TestReCreatedScript.lua -> MapFileTree()
  --NOT THE SAME AS LoadAndExecuteModScript.lua -> MapFileTree()
  --this DisplayMapFileTree must only recreate all KEY_WORDS to display them in a tree
  --******************************************************************
  if Debug == nil then Debug = false end
  if Show == nil then Show = false end
  
  local KEY_WORDS = {}
  local TREE_LEVEL = {}
  local FILE_LINE = {}
  local COMMENT = {}
  local level = 0
  
  if type(EXML) ~= "table" or #EXML <= 1 then return FILE_LINE,TREE_LEVEL,KEY_WORDS end

  --***************************************************************************************************  
  local function FindKeywordsInLine(TextFile,i)
    local KeywordsInRange = ""
    local text = TextFile[i]
    
    if string.find(text,[[me=]],1,true) ~= nil and string.find(text,[[ue=]],1,true) ~= nil then
      --a line like <Property name="" value="" /> 
      --"name" is a potential special_keyword
      local value = StripInfo(text,[[ue="]],[["]])
      -- if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil and string.find(value,".",1,true) == nil then
      -- if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
      if value ~= "" then
        local name = StripInfo(text,[[me="]],[["]])
        KeywordsInRange = "[*"..string.format("%8u",i)..[[: ]]..name..[[="]]..value.."\"]"
      end
    end --if string.find(
    
    return KeywordsInRange
  end
  --***************************************************************************************************  

  local Pak_FileName = LocatePAK(filename)
  local Pak_FileNamePath = gNMS_PCBANKS_FOLDER_PATH..Pak_FileName
  local fileInfo = string.gsub(filename,[[\]],[[.]])
  local filepathname = "..\\MapFileTrees\\"..fileInfo
   
  if _mUSE_TXT_MAPFILETREE then
    filepathname = filepathname..".txt"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".lua"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    local cmd = [[Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]]
    NewThread(cmd)

  elseif _mUSE_LUA_MAPFILETREE then
    filepathname = filepathname..".lua"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".txt"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    local cmd = [[Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]]
    NewThread(cmd)

  else --set default
    _mUSE_TXT_MAPFILETREE = true
    filepathname = filepathname..".txt"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".lua"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    local cmd = [[Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]]
    NewThread(cmd)
  end
  
  if IsFile2Newest(Pak_FileNamePath,filepathname) then
    --the MapFileTree file is newest than the NMS pak file
    --no need to update
    print("      MapFileTree is up-to-date!")
    Report("","      MapFileTree is up-to-date!")
    return FILE_LINE,TREE_LEVEL,KEY_WORDS
  end
  
  print("      Creating MapFileTree...")
  -- print("XYZ = "..filename)
  local WholeTextFile = LoadFileData([[MOD\]]..filename) --the EXML file as one text, for speed searching for uniqueness
  
  --skipping a few lines at start
  local j = 0
  repeat
    j = j + 1
    if EXML[j] == nil then break end
  until string.find(EXML[j],[[<Data template=]],1,true) ~= nil
  
  for i=j,#EXML do
    local text = EXML[i]
    
    if string.find(text,[[/>]],1,true) ~= nil then
      local Name = ""
      if string.find(text,[[<Property name=]],1,true) ~= nil and string.find(text,[[value=]],1,true) ~= nil then
        Name = StripInfo(text,[[<Property name="]],[[" value=]])
      end
      if Name ~= "" then
        local result = FindKeywordsInLine(EXML,i)
        if result ~= "" then --like [*       6: Id="VEHICLE_SCAN"]
          --print("            Line "..i.." Name is ["..Name.."]")
          --like: <Property name="Filename" value="MODELS/PLANETS/BIOMES/BARREN/HQ/TREES/DRACAENA.SCENE.MBIN" />
          --like: <Property name="Id" value="DRONE" />
          --like: <Property name="CreatureType" value="Walker" />
          --like: ...
          --usually could be a SIGNIFICANT KEY_WORD
          table.insert(FILE_LINE,i)
          table.insert(TREE_LEVEL,level+1)

          --check for uniqueness and report
          local s = trim(text)
          --fastest way!!! --gsub and gmatch take too long
          local firstPosStart,firstPosEnd = string.find(WholeTextFile,s,1,true)
          local secondPos = string.find(WholeTextFile,s,firstPosEnd+1,true)
          
          value = StripInfo(result,[[=]],"]")
          
          local UniqueMsg = [[.S.]]
          if secondPos == nil then
            -- UniqueMsg = " UNIQUE"
            UniqueMsg = [[.SU]]
            if value == [["True"]] or value == [["False"]] or tonumber(string.sub(value,2,-2)) ~= nil then
              UniqueMsg = [[.su]]
            end
          
          elseif value == [["True"]] or value == [["False"]] or tonumber(string.sub(value,2,-2)) ~= nil then
            UniqueMsg = [[.s.]]
          end
          -- table.insert(KEY_WORDS, [[SPECIALNAME: "]]..Name..[[", ]]..StripInfo(text,[[" value=]],[[ />]])) --remembers name and value
          table.insert(KEY_WORDS, [[{"]]..StripInfo(result,[[: ]],[[=]])..[[",]]..value..[[,},]]) --remembers name and value
          -- table.insert(COMMENT, [[ --SPECIAL]]..UniqueMsg)
          table.insert(COMMENT, UniqueMsg)
        else
          --like: <Property name="Seed" value="0" />
          --skip it
        end
      end
      
    --from here, no lines with />
    elseif string.find(text,[[</Property>]],1,true) ~= nil then
      --like: </Property>
      --NOT a KEY_WORD but should remove preceding KEY_WORD
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level+1)
      table.insert(KEY_WORDS, "<<<") --remembers end of section
      table.insert(COMMENT, [[   ]])
      level = level - 1
      
    elseif string.find(text,[[<Property name=]],1,true) ~= nil and string.find(text,[[value=]],1,true) ~= nil then
      --like: <Property name="ProceduralTexture" value="TkProceduralTextureChosenOptionList.xml">
      --usually NOT a KEY_WORD but may be needed to match </Property> removing a KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      
      local name = StripInfo(text,[[<Property name=]],[[ value=]]) --remembers name
      local specialName = ""
      
      --this could also be a SPECIALNAME
      --like: <Property name="Rarity" value="GcRarity.xml">
      local value = StripInfo(text,[[value="]],[["]])
      local UniqueMsg = [[PS.]]
      if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
        --check for uniqueness and report
        local s = trim(text)
        --fastest way!!! --gsub and gmatch take too long
        local firstPosStart,firstPosEnd = string.find(WholeTextFile,s,1,true)
        local secondPos = string.find(WholeTextFile,s,firstPosEnd+1,true)
        if secondPos == nil then
          -- UniqueMsg = " UNIQUE"
          UniqueMsg = [[PSU]]
          if value == "True" or value == "False" or tonumber(value) ~= nil then
            UniqueMsg = [[Psu]]
          end
        end
        specialName = [[ / {]]..name..[[,"]]..value..[[",},]]
      elseif value == "True" or value == "False" or tonumber(value) ~= nil then
        UniqueMsg = [[Ps.]]
      end

      table.insert(KEY_WORDS, name..specialName)
      
      if specialName ~= "" then
        -- table.insert(COMMENT, [[ --PRECEDING or SPECIAL]]..UniqueMsg)
        table.insert(COMMENT, UniqueMsg)
      else
        table.insert(COMMENT, [[   ]])
      end
      
    elseif string.find(text,[[Property name=]],1,true) ~= nil then
      --like: <Property name="Landmarks">
      --this is usually a SIGNIFICANT KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[Property name=]],[[>]])) --remembers name
      table.insert(COMMENT, [[P..]])
      
    elseif string.find(text,[[Property value=]],1,true) ~= nil then
      --like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
      --could be a SIGNIFICANT KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[Property value=]],[[>]])) --remembers value
      table.insert(COMMENT, [[P..]])
      
    elseif string.find(text,[[<Data template=]],1,true) ~= nil then
      --like: <Data template="GcExternalObjectList">
      --encountered only once at first line
      --NEVER a KEY_WORD
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[<Data template=]],[[>]])) --remembers template
      table.insert(COMMENT, [[   ]])
      
    elseif string.find(text,[[</Data>]],1,true) ~= nil then
      --like: </Data>
      --encountered only once at end of file
      --NEVER a KEY_WORD
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, "/Data") --remembers "/Data"
      table.insert(COMMENT, [[   ]])
      
    end
  end  

  local info = {}
  if _mUSE_LUA_MAPFILETREE then
    --pre-process info to LUA format
    local previousLevel = -1
    -- local comment = ""
    for i=1,#KEY_WORDS do
      if KEY_WORDS[i] ~= "<<<" then
        local line = string.format("%8u",FILE_LINE[i])
        local level = string.format("%2u",TREE_LEVEL[i])
        local comment = COMMENT[i]
        
        local nLevel = tonumber(level)
        if i > 1 then
          if nLevel > previousLevel then
            info[#info] = "{"..string.sub(info[#info],2)
          end
          if nLevel < previousLevel then
            info[#info] = info[#info].." #"..string.rep("}",previousLevel - nLevel)
          end

          -- info[#info] = info[#info]..comment
        end
                
        previousLevel = nLevel
        
        local INFO = " ["..comment..":"..line..":"..level.."]"
        if TREE_LEVEL[i] > 1 then
          info[#info+1] = INFO.."  "..string.rep("| ",TREE_LEVEL[i]-1)..KEY_WORDS[i]
        else
          if i == 1 then
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..string.sub(KEY_WORDS[i],2,-2).." --Do not use, NOT a KEYWORD"
          elseif i == #KEY_WORDS then
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i].." --Do not use, NOT a KEYWORD"
          else
            info[#info+1] = INFO..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i]
          end
        end
        -- comment = COMMENT[i]
      end
    end
  else --if _mUSE_TXT_MAPFILETREE then
    --default
  end

  --os.remove([["]]..filepathname..[["]])  --don't use, can get stuck
  local cmd = [[Del /f /q /s "]]..filepathname..[[" 1>NUL 2>NUL]]
  NewThread(cmd)

  local filehandle = WriteToFileEXT(filepathname)
  if filehandle ~= nil then
    filehandle:write("MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(_mDateTimeFormat).."\n")
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique".."\n")    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    

    if _mUSE_LUA_MAPFILETREE then
      for i=1,#info do
        filehandle:write(info[i].."\n")
      end
    elseif _mUSE_TXT_MAPFILETREE then
      for i=1,#KEY_WORDS do
        if KEY_WORDS[i] ~= "<<<" then
          local line = string.format("%8u",FILE_LINE[i])
          local level = string.format("%2u",TREE_LEVEL[i])
          local info = "["..COMMENT[i]..":"..line..":"..level.."]"..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i]
          filehandle:write(info.."\n")
        end
      end
    end
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique".."\n")    
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write("MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(_mDateTimeFormat).."\n")
    filehandle:close()
  end

  print("                             done!")
  Report("","    Created MapFileTree")

  return FILE_LINE,TREE_LEVEL,KEY_WORDS
end

function TranslateMathOperatorCommandAndGetValue(TextFileTable, SearchKeyProperty, pos, direction)
	if direction == "forward" then
		for k=pos,#TextFileTable,1 do
    if (string.find(TextFileTable[k], [["]]..SearchKeyProperty..[["]]) or (SearchKeyProperty == "IGNORE")) then
				return StripInfo(TextFileTable[k],[[value="]],[["]])
			end
		end
	elseif direction == "backward" then
		for k=pos,1,-1 do
			if (string.find(TextFileTable[k], [["]]..SearchKeyProperty..[["]]) or (SearchKeyProperty == "IGNORE")) then
				return StripInfo(TextFileTable[k],[[value="]],[["]])
			end
		end		
	end
end

function CheckValueType(value,IsInteger_to_floatFORCE)
  local ValueTypeIsNumber = (type(tonumber(value)) == "number")
  local ValueIsInteger = false
  if not IsInteger_to_floatFORCE and ValueTypeIsNumber then
    ValueIsInteger = (string.find(value,".",1,true) == nil)
  end
  return ValueTypeIsNumber, ValueIsInteger
end

function IntegerIntegrity(number,valueIsInteger)
  --this needs MAINTENANCE !!!
	--if string.find(property,"Amount") or string.find(property,"Cost") or string.find(property,"Time") then return math.floor(number+0.5)

  --this one: no maintenance
  if valueIsInteger then
    return math.floor(number+0.5)
  end
	return number
end

function ExecuteMathOperation(math_operation,operand1,operand2)
	pv("foundValue["..tostring(operand1).."]")
	pv("currentValue=["..tostring(operand2).."]")
  if operand1 == nil then
    --subtitute 0, error was already reported
    operand1 = 0
  end
  if operand2 == nil then
    --subtitute 0, error was already reported
    operand2 = 0
  end
  if math_operation == "*" then 
		return tonumber(operand1)*tonumber(operand2)
	elseif math_operation == "+" then 
		return tonumber(operand1)+tonumber(operand2)			
	elseif math_operation == "-" then 
		return tonumber(operand1)-tonumber(operand2)			
	elseif math_operation == "/" then 
		return tonumber(operand1)/tonumber(operand2)
	-- elseif math_operation == "=" then 
		-- return tonumber(operand2)
	else
    Report(math_operation,"Unknown MATH_OPERATION.  Please check your script!","WARNING")
    print(_zRED..">>> [WARNING] Unknown MATH_OPERATION: ["..math_operation.."]  Please check your script!".._zDEFAULT)
		return 1
	end
end

--################  BELOW: USERSCRIPT PROCESSING  ###############################

--***************************************************************************************************  
function SerializeScript(object,multiline,name)
  local r = serializeObject(object,multiline,0,name) --from Loadhelpers
  
  local t = {}
  for w in string.gmatch(r,"[^\n]+") do
    table.insert(t,w)
  end

  --cleanup strings
  for i=1,#t do
    local text = t[i]
    if trim(text) == "" then
      --remove empty lines
      t[i] = ""
    end
    --remove trailing whitespace
    t[i] = rtrim(text)
  end

  local w = {}
  for i=1,#t do
    if t[i] ~= "" then
      table.insert(w,t[i])
    end
  end
  t = w
  --end cleanup strings
  
  local i = 1
  repeat
    -- print(i.."["..t[i].."]")
    if string.find(t[i],"VALUE_CHANGE_TABLE",1,true) ~= nil then
      -- print(i.."A["..t[i].."]")
      i = i + 2
      while trim(t[i]) ~= "}," do
        -- print(i.."B["..t[i].."]")
        t[i] = t[i]..trim(t[i+1])..trim(t[i+2])..trim(t[i+3])
        t[i+1] = ""
        t[i+2] = ""
        t[i+3] = ""
        i = i + 4
      end
      i = i + 1
    elseif string.find(t[i],"SPECIAL_KEY_WORDS",1,true) ~= nil then
      if trim(t[i+1]) == "{" then
        --a table
        local anchorLine = i
        t[anchorLine] = t[anchorLine].." "..trim(t[anchorLine+1])
        t[anchorLine+1] = ""
        local pointer = 2
        repeat
          t[anchorLine] = t[anchorLine]..trim(t[anchorLine+pointer])
          t[anchorLine+pointer] = ""
          pointer = pointer + 1
        until trim(t[anchorLine+pointer]) == "},"
        t[anchorLine] = t[anchorLine]..trim(t[anchorLine+pointer])
        t[anchorLine+pointer] = ""
        i = i + pointer
      end
      i = i + 1
    elseif string.find(t[i],"PRECEDING_KEY_WORDS",1,true) ~= nil then
      if trim(t[i+1]) == "{" then
        --a table
        local anchorLine = i
        t[anchorLine] = t[anchorLine].." "..trim(t[anchorLine+1])
        t[anchorLine+1] = ""
        local pointer = 2
        repeat
          t[anchorLine] = t[anchorLine]..trim(t[anchorLine+pointer])
          t[anchorLine+pointer] = ""
          pointer = pointer + 1
        until trim(t[anchorLine+pointer]) == "},"
        t[anchorLine] = t[anchorLine]..trim(t[anchorLine+pointer])
        t[anchorLine+pointer] = ""
        i = i + pointer
      end
      i = i + 1
    else
      i = i + 1
    end
  until i > #t
    
  r = {}
  for i=1,#t do
    if t[i] ~= "" then
      r[#r+1] = t[i]
    end
  end
  
  return r
end

--***************************************************************************************************  
function AnalyzeScript(script,scriptFilename,scriptFilenamePath)
  local problemFound = false
  local possibleProblemFound = False
  
  print()
  print("   @@@ **********  Analysing script... **********")
  
  if script == nil then return true end
  
  --_mLUAC
  print()
  print("   @@@ Checking script using LUAC.exe...")
  local tmpScriptLUACFileName = "LUAC_"..scriptFilename
  local resultFileName = "CheckScriptResults_LUAC.lua"
  local scriptLUAC = string.gsub(script,[[\\]],[[/]]) -- just to prevent luac from complaining about bad escape sequences
  
  WriteToFileAppend(scriptLUAC,tmpScriptLUACFileName) --script to the tmp file

  local cmd = [[]].._mLUAC..[[ -p "]]..tmpScriptLUACFileName..[["2>"]]..resultFileName..[["]]
  -- print("["..cmd.."]")
  local r,s,n = NewThread(cmd)

  local LUACerrorTable = ParseTextFileIntoTable(resultFileName)
  
  problemFound = (#LUACerrorTable > 0)

  for i=1,#LUACerrorTable do
    local text = string.gsub(LUACerrorTable[i],_mLUAC,"")
    text = string.sub(text,8)
    firstPos = string.find(text,":",1,true)
    if firstPos ~= nil then
      text = string.sub(text,1,firstPos-1).." line "..string.sub(text,firstPos+1)
    end
    print(_zRED.."       - "..text.._zDEFAULT)
  end
  
  os.remove(tmpScriptLUACFileName)
  
  if problemFound then
    print("   @@@ Done but found problem(s)")
  else
    -- print("       DONE: Using LUAC.exe...")
    print("   @@@ Done without problem")
  end
  print()
  
  if Container_info == nil then dofile("Container_info.lua") end
  
  --let us try to find the start and end of NMS_MOD_DEFINITION_CONTAINER
  local containerStartLine = 0 --easy
  local containerEndLine = 0   --harder if some code after with tables in it
  
  local scriptTable = ParseTextFileIntoTable(scriptFilenamePath)
  for i=1,#scriptTable do
    if string.find(trim(scriptTable[i]),"NMS_MOD_DEFINITION_CONTAINER",1,true) == 1 then
      containerStartLine = i
    end
  end
  
  local openBracketCount = 0
  local closeBracketCount = 0
  -- local BracketLevel = 0
  local foundContainer = false
  local modified = false
    
  print("   @@@ Scanning script for container...")

  --***************************************************************************************************  
  local function isBalanced(s,t)
    --Lua pattern matching has a 'balanced' pattern that matches sets of balanced characters.
    --Any two characters can be used.
    checkFor = '%b'..t
    print(checkFor)
    print(s:gsub(checkFor,'')=='')
    return s:gsub(checkFor,'')=='' and true or false
  end
  --***************************************************************************************************  
  
  -- local IsScriptSingleQuotesBalanced = isBalanced(script,[['']])
  -- print(string.format([[       Are script '' balanced? %s]],IsScriptSingleQuotesBalanced))
  -- local IsScriptDoubleQuotesBalanced = isBalanced(script,[[""]])
  -- print(string.format([[       Are script "" balanced? %s]],IsScriptDoubleQuotesBalanced))
  -- local IsScriptSquareBalanced = isBalanced(script,"[]")
  -- print(string.format("       Are script [] balanced? %s",IsScriptSquareBalanced))
  -- local IsScriptCurlyBalanced = isBalanced(script,"{}")
  -- print(string.format("       Are script {} balanced? %s",IsScriptCurlyBalanced))
  -- print()    

  for i=containerStartLine,#scriptTable do
    local skip = false
    if scriptTable[i] ~= nil then    
      local t = trim(scriptTable[i])
      if string.sub(t,1,2) == "--" then
        --a comment, skip line
        skip = true
      elseif string.find(t,"--",1,true) ~= nil then
        --there is a comment at the end of this line, remove it
        local commentStartCol = string.find(t,"--",1,true)
        t = string.sub(t,1,commentStartCol - 1)
      end

      if not skip then
        --how many { and } on this line?
        local _,n = string.gsub(t,"{","{")
        openBracketCount = openBracketCount + n
        
        local _,n = string.gsub(t,"}","}")
        closeBracketCount = closeBracketCount + n
        
        if not foundContainer and (openBracketCount > 0 and (closeBracketCount == openBracketCount)) then
          --we have reach the end of the container or the container is malformed
          foundContainer = true
          containerEndLine = i
          print("       > CONTAINER found at lines "..containerStartLine.."-"..containerEndLine.." (found "..closeBracketCount.." {} pairs)")
          print("       > CONTAINER will be further analyzed...")
        end
      end
    end
  end

  if openBracketCount == 0 then
    --we have reach the end of the file and not found the container
    print("CONTAINER not found!")
    problemFound = true
  end
  
  if openBracketCount > 0 and (closeBracketCount ~= openBracketCount) then
    --we have reach the end of the file and the container is malformed
    print("       > Ended file scan with "..openBracketCount.." '{' and "..closeBracketCount.." '}' brackets")
    if openBracketCount > closeBracketCount then
      print(_zRED.."       > Check for some missing '}' ".._zDEFAULT)
    else
      print(_zRED.."       > Check for some missing '{' ".._zDEFAULT)
    end
    print(_zRED.."       > CONTAINER starts at line "..containerStartLine.."-(ending uncertain)".._zDEFAULT)
    print(_zRED.."       > CONTAINER is malformed!".._zDEFAULT)  
  
  end
  
  if containerEndLine == 0 then
    -- modified = true
  end
  print("   @@@ Done")

  local tmpScriptFileName = "CheckScript.lua"
  local resultFileName = "CheckScriptResults.lua"
  
  WriteToFile([[--# selene: allow(unscoped_variables)]].."\n",tmpScriptFileName) --adding to block warning: not local in whole file
  --WriteToFile([[--# selene: allow(unused_variable)]].."\n",tmpScriptFileName) --adding to block warning: unused variable in whole file
  
  WriteToFileAppend([[-- selene: allow(unused_variable)]].."\n",tmpScriptFileName) --adding to block warning: not used for NMS_MOD_DEFINITION_CONTAINER
  WriteToFileAppend([[NMS_MOD_DEFINITION_CONTAINER = {}]].."\n",tmpScriptFileName) --needed for preceding selene block to work

  --extra lines in file due to selene
  local extraLines = 3
  
  --we do this because selene cannot handle the " - " correctly in a file name, it thinks it is an options flag
  WriteToFileAppend(script,tmpScriptFileName) --script to the tmp file
  
  local cmd = [[selene.exe  --display-style="quiet" "]]..tmpScriptFileName..[[">"]]..resultFileName..[["]]
  -- -- print("["..cmd.."]")
  local r,s,n = os.execute(cmd)
  print()
  
  if r == nil then
    print("   @@@ Basic Syntax Analysis detected these other problems, see also ModScriptCheck folder...")
    --we need to removed the extra lines from the results file
    local rs = ParseTextFileIntoTable(resultFileName)
    
    for i=1,#rs - 4 do --skip last 4 lines
      local text = rs[i]
      local nStart = string.find(text,":",1,true) + 1
      local nLineLength = string.find(string.sub(text,nStart),":",1,true) - 1
      local lastPart = string.sub(text,nStart + nLineLength)
      local sLineNum = string.sub(text,nStart,nStart + nLineLength - 1)
      local lineNum = tonumber(sLineNum) - extraLines
      rs[i] = string.sub(text,1,nStart - 1)..lineNum..lastPart
      
      local nColLength = string.find(string.sub(lastPart,2),":",1,true) - 1
      local sColNum = string.sub(lastPart,2,1 + nColLength)
      local msg = string.sub(lastPart,1 + nColLength + 1)
      
      if string.find(msg,"error",1,true) ~= nil then
        possibleProblemFound = true
      end
      
      print(_zRED.."       > line "..lineNum..", col "..sColNum.." "..msg.._zDEFAULT)
    end

    WriteToFile(ConvertLineTableToText(rs),[[..\ModScriptCheck\]]..scriptFilename..[[.selene.txt]])      
    
  else
    print("   @@@ Basic Syntax Analysis did not detect any problems")
  end
  
  print("   @@@ Done")
  print()

  os.remove(tmpScriptFileName)
  os.remove(resultFileName)
  
  return problemFound,possibleProblemFound,modified
end

--***************************************************************************************************  
function OpenUserScript()
  local Hash = ""
  local success = false
  
  --***************************************************************************************************  
  local function load_conf()
    local env = {
    string = string,
    math = math,
    table = table,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    print = print,
    assert = assert,
    io = {open=io.open,type=io.type,input=io.input,read=io.read,close=io.close,lines=io.lines,},
    os = {clock=os.clock,date=os.date,difftime=os.difftime,time=os.time,tmpname=os.tmpname,getenv=os.getenv,},
    pairs = pairs,
    ipairs = ipairs,
    } --user can use anything inside this new environment in the user script
  --***************************************************************************************************  
    
    local scriptFilenamePath = LoadFileData("CurrentModScript.txt")
    local scriptFilename = GetFilenameFromFilePath(scriptFilenamePath)
    
    os.remove([[..\ModScriptCheck\]]..scriptFilename..[[.selene.txt]]) --try to delete the last analysis

    local script = LoadFileData(scriptFilenamePath)
    -- print("script = ["..script.."]")
    
    --for backward compatibility
    script = string.gsub(script,[[REPLACE_AFTER_ENTRY]],[[PRECEDING_KEY_WORDS]])
    script = string.gsub(script,[[ADDSECTION]],[[ADDAFTERSECTION]])
    script = string.gsub(script,[[\]],[[\\]]) --preventing those nasty escape sequence when \ is used inside a ""

    --prevent the use of :write in the script (prevent injection)
    if string.find(script,[[:write]],1,true) ~= nil then
      local scriptFile = ParseTextFileIntoTable(scriptFilenamePath)
      for i=1,#scriptFile do
        if string.find(scriptFile[i],[[:write]],1,true) ~= nil then
          if string.sub(trim(scriptFile[i]),1,2) ~= [[--]] then
            return {}, "XXXXX <not allowed> Lua keyword in used on line "..i.." of the script XXXXX"
          end
        end
      end
    end
    
--$$$$$$$$$$$$$$$$  FOR DEBUG
    local problemFound = false
    local modified = false
    problemFound,possibleProblemFound,modified = AnalyzeScript(script,scriptFilename,scriptFilenamePath)
    
    if problemFound or possibleProblemFound then
      print()
      print(_zRED.."[NOTICE]   Some problem/warning found by analyzing the script (see above)...".._zDEFAULT)
      if modified then
        print(_zRED.."          We may have MODIFIED the script to help pinpoint the problem".._zDEFAULT)
        print(_zRED.."          Please retry it to get further guidance!".._zDEFAULT)
      else
        print(_zRED.."          You could need to correct it and retry!".._zDEFAULT)
      end
      print()
    end
--$$$$$$$$$$$$$$$$  FOR DEBUG

    -- To be used if you want to inspect the loaded script
    if _mDEBUG ~= nil then
      WriteToFile(script, "..\\TempScript.lua")
    end
    
    -- if not problemFound then
      -- print(">>> Creating script Hash...")
      -- local sha1 = require 'sha1'
      -- Hash = sha1.hex(string.sub(script,1,#script - 40)) 

      -- gSCRIPTBUILDERscript = (Hash == string.sub(script,#script - 39))
      -- if gSCRIPTBUILDERscript then print("A SCRIPTBUILDER script!") end
    -- end
    
    --***************************************************************************************************  
    local function MyErrHandler(x)
      print("")
      print(_zRED.."Lua Script error: "..x.._zDEFAULT)
      Report("","Lua Script error: "..x,"ERR")
      -- print(debug.traceback(nil,0))
      -- Report("", debug.traceback(nil,0),"ERR")
      LuaEndedOk(THIS)
    end

    -- --***************************************************************************************************        
    -- local function GetScript()
      -- return load(script,"User Script",'t',env)
    -- end
    
    if not problemFound then
      print(">>> Loading script...")
      success, chunk = xpcall(load(script,"User Script",'t',env),MyErrHandler) --better
      -- local chunk, failure = load(script,"User Script",'t',env)
      
      if success then
          -- chunk()
      elseif chunk ~= nil then
        print("")
        print("Lua is reporting: "..chunk)
        Report("","Lua is reporting: "..chunk,"ERR")
      else
        print("xpcall problem")
      end
    else
      success = false
    end

    return env, chunk, success
  end
  --***************************************************************************************************  

  --###################  MAIN CODE  ###################################
  local conf,status,success = load_conf()

  if success then
    if conf.NMS_MOD_DEFINITION_CONTAINER == nil or conf.NMS_MOD_DEFINITION_CONTAINER == "" then
      success = false
    end
  end
  
  -- if status == nil or status == false then --only use this if not using pcall above
  if success then --use this if using pcall above
    local msg1 = "USER"
    if gSCRIPTBUILDERscript then
      msg1 = "SCRIPTBUILDER"
    end
    
    print(_zGREEN..">>> [INFO] Success loading ".._zDEFAULT..msg1.._zGREEN.." script".._zDEFAULT)
    NMS_MOD_DEFINITION_CONTAINER = conf.NMS_MOD_DEFINITION_CONTAINER

    --***************************************************************************************************  
    local function SerializeLoadedScript(TableName,thisTable,indentLevel,outTable)
      local tmp = ""
      
      if #outTable > 0 then
        tmp = string.gsub(outTable[#outTable],"|  ","") --remove all "|  "
      end
      
      if tonumber(TableName) == nil then
        table.insert(outTable,string.rep("|  ",indentLevel - 1)..TableName.." = {")
      elseif trim(tmp,-2) == "}," then
        indentLevel = indentLevel - 1
        table.insert(outTable,string.rep("|  ",indentLevel - 1).."{")
      else
        outTable[#outTable] = outTable[#outTable].."{"
        indentLevel = indentLevel - 1
      end
      
      for k,v in pairs(thisTable) do
        local value = ""
        if type(v) == "table" then
          indentLevel = indentLevel + 1
          SerializeLoadedScript(k,v,indentLevel,outTable)
          indentLevel = indentLevel - 1
        else
          if type(v) == "nil" then
            value = "nil,"
          elseif type(v) == "string" then
            v = string.gsub(v,[[\\]],[[\]]) --remove \\ in [[...]] strings
            value = "[["..v.."]],"
          elseif type(v) == "number" then
            value = tostring(v)..","
          elseif type(v) == "boolean" then
            if v then
              value = "[[true]],"
            else
              value = "[[false]],"
            end
          end
          
          local info = ""
          if tonumber(k) == nil then
            info = k.." = "
          end
          table.insert(outTable,string.rep("|  ",indentLevel)..info..value)
          
        end
      end
      
      local tmp = string.gsub(outTable[#outTable],"|  ","") --remove all "|  "
      if trim(tmp) == "}," then
        outTable[#outTable] = outTable[#outTable].."},"
      else
        table.insert(outTable,string.rep("|  ",indentLevel - 1).."},")
      end
    end
    --***************************************************************************************************  
    
    if _mSerializeScript == "Y" then
      -- this serialize ALL scripts, if allowed
      print(_zGREEN..">>> [INFO] Creating scriptname.serial.lua in ModScriptCheck folder, please wait...".._zDEFAULT)
      -- print()
      -- print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
      local indentLevel = 1
      local outTable = {}
      local TableName = "NMS_MOD_DEFINITION_CONTAINER"
      
      SerializeLoadedScript(TableName,NMS_MOD_DEFINITION_CONTAINER,indentLevel,outTable)
      
      outTable[#outTable] = string.sub(outTable[#outTable],1,-2) -- remove last ,

      local scriptFilenamePath = LoadFileData("CurrentModScript.txt")
      local scriptFilename = GetFilenameFromFilePath(scriptFilenamePath)

      WriteToFile(ConvertLineTableToText(outTable), [[..\ModScriptCheck\]]..string.sub(scriptFilename,1,-5)..[[.serial.lua]])
      -- for i=1,#outTable do
        -- print(outTable[i])
      -- end
      
      -- print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
      -- print()
    end
    
    if _bScriptCounter == _bNumberScripts then
      -- we are at the last script (or maybe this is the only script)
      -- this serialize only this script, if allowed
      if _mSERIALIZING == "Y" then
        print(_zGREEN..">>> [INFO] Serializing loaded script, please wait...".._zDEFAULT)
        local scriptTable = SerializeScript(NMS_MOD_DEFINITION_CONTAINER,true,"NMS_MOD_DEFINITION_CONTAINER")
        WriteToFile(ConvertLineTableToText(scriptTable), "..\\SerializedScript.lua")
      end
    end
    print(_zGREEN..">>> [INFO] Executing now...".._zDEFAULT)
    pv("["..Hash.."]")
    print()
    
  else
    NMS_MOD_DEFINITION_CONTAINER = ""
    -- print("")
    -- print(status)
    print("XXXXX Error loading USER script! XXXXX")
    print("")
    WriteToFile("", "LoadScriptAndFilenamesERROR.txt")
    Report(LoadFileData("CurrentModScript.txt"),"Error loading USER script!","ERROR")
    if status ~= nil then
      Report(LoadFileData("CurrentModScript.txt"),tostring(status))
    end
    
    -- local problemFound = false
    -- problemFound = AnalyzeScript(script,scriptFilename,scriptFilenamePath)
    
    -- if problemFound then
      -- print()
      -- print(_zRED.."[NOTICE]   Some problem found by analyzing the script, it was MODIFIED to help pinpoint the problem".._zDEFAULT)
      -- print(_zRED.."          Please retry it!".._zDEFAULT)
      -- print()
    -- end
  end
  
  return NMS_MOD_DEFINITION_CONTAINER
end

--***************************************************************************************************  
function LookAt_MOD_PAK_SOURCE_content(flag)
  print(flag)
  local temp_MOD_PAK_SOURCE = ParseTextFileIntoTable("MOD_PAK_SOURCE.txt")
  for i=1,#temp_MOD_PAK_SOURCE do
    print("   ["..temp_MOD_PAK_SOURCE[i].."]")
  end
end

--***************************************************************************************************  
function LocateMOD_PAK_SOURCE(file)
  local pak_listTable = gpak_listTable
  local TempMBIN = string.gsub(file,[[\]],[[/]])
  
  local Pak_File = ""
  local found = false
  
  --LookAt_MOD_PAK_SOURCE_content("- DDDDD before finding source")

  -- print("TempMBIN = "..TempMBIN)
  -- print("pak_list.txt = "..#pak_listTable)
  for i=1,#pak_listTable,1 do
    local line = pak_listTable[i]
    if line ~= nil then
      if string.find(line,"Listing ",1,true) ~= nil then
        local start,stop = string.find(line,"Listing ",1,true)
        Pak_File = string.sub(line, stop+1)
        -- print("["..Pak_File.."]")
      elseif string.find(line,TempMBIN,1,true) ~= nil then
        found = true
        --added "\n".. as a work around for strange bug
        --without, the entries would not be on separate lines all the time
        WriteToFileAppend("\n"..Pak_File.."\n", "MOD_PAK_SOURCE.txt")
        break
      end
    end
  end
  
  --LookAt_MOD_PAK_SOURCE_content("- CCCCC after finding source")
  return found,Pak_File
end

--***************************************************************************************************  
function TestScript(NMS_MOD_DEFINITION_CONTAINER)
  local abortProcessing = false
  
  local MaxPakNameLength = _bMaxPakNameLength

  local mod_filename = NMS_MOD_DEFINITION_CONTAINER["MOD_FILENAME"]
  if mod_filename == nil or mod_filename == "" then
    print(_zRED.."[WARNING] MOD filename not found, using 'GENERIC.pak' as name".._zDEFAULT)
    Report("","MOD filename not found, using 'GENERIC.pak' as name","WARNING")
    mod_filename = "GENERIC.pak"
  end
  if mod_filename ~= "" and string.sub(mod_filename,-4) ~= ".pak" then
    mod_filename = string.sub(mod_filename,1,MaxPakNameLength)
    mod_filename = mod_filename..".pak"
    print(_zRED.."[WARNING] Added .pak extension to MOD filename".._zDEFAULT)
    Report("","Added .pak extension to MOD filename","WARNING")
  else
    mod_filename = string.sub(mod_filename,1,#mod_filename-4)
    mod_filename = string.sub(mod_filename,1,MaxPakNameLength)
    mod_filename = mod_filename..".pak"
  end
  
  local mod_author = NMS_MOD_DEFINITION_CONTAINER["MOD_AUTHOR"]
  if mod_author == nil then mod_author = "" end
  WriteToFile(mod_author, "MOD_AUTHOR.txt")
  
  local lua_author = NMS_MOD_DEFINITION_CONTAINER["LUA_AUTHOR"]
  if lua_author == nil then lua_author = "" end
  WriteToFile(lua_author, "LUA_AUTHOR.txt")
  
  WriteToFile(mod_filename, "MOD_FILENAME.txt")

  local mod_batchname = NMS_MOD_DEFINITION_CONTAINER["MOD_BATCHNAME"]
  if mod_batchname == nil then
    mod_batchname = ""
  end
  if mod_batchname ~= "" and string.sub(mod_batchname,-4) ~= ".pak" then
    mod_batchname = string.sub(mod_batchname,1,MaxPakNameLength)
    mod_batchname = mod_batchname..".pak"
  else
    mod_batchname = string.sub(mod_batchname,1,#mod_batchname-4)
    mod_batchname = string.sub(mod_batchname,1,MaxPakNameLength)
    mod_batchname = mod_batchname..".pak"
  end
  if mod_batchname ~= ".pak" then
    print("[INFO] Current MOD_BATCHNAME set to ".._zGREEN.."["..mod_batchname.."]".._zDEFAULT)
    print()
    Report(""," Current MOD_BATCHNAME set to ["..mod_batchname.."]")
    WriteToFile(mod_batchname, "MOD_BATCHNAME.txt")
  end

  local NewMBIN_FILES = {}
  --***************************************************************************************************  
  local function IsNewMBIN_File(NewMBIN_FILES,candidate)
    local answer = false
    for i=1,#NewMBIN_FILES do
      if candidate == NewMBIN_FILES[i] then
        answer = true
        break            
      end
    end
    return answer
  end
  --***************************************************************************************************  
  
  local mod_def = NMS_MOD_DEFINITION_CONTAINER["MODIFICATIONS"]
  if mod_def~=nil then
    local WordWrap1 = "\n"
    local WordWrap2 = "\n"

    for n=1,#mod_def,1 do
      if n == #mod_def then WordWrap1 = "" end	

      local ConflictTable = {}
      local mod_def_change_table = mod_def[n]["MBIN_CHANGE_TABLE"]
      if mod_def_change_table == nil then
        print(_zRED.."[WARNING] MODIFICATIONS["..n.."] is empty!".._zDEFAULT)
        mod_def_change_table = {}
        abortProcessing = true
      end
      
      for m=1,#mod_def_change_table,1 do	
        local mbin_file_source = mod_def_change_table[m]["MBIN_FILE_SOURCE"]
        if mbin_file_source == nil then
          mbin_file_source = ""
          abortProcessing = true
        end

        if type(mbin_file_source) == "table" then
        
          if type(mbin_file_source[1]) == "table" then
            --alternate syntax #3
            pv("DETECTED a table of tables MBIN_FILE_SOURCE")
            for k=1,#mbin_file_source,1 do
              mbin_file_source[k][1] = NormalizePath(mbin_file_source[k][1])
              mbin_file_source[k][2] = NormalizePath(mbin_file_source[k][2])
              pv("Writing to MOD_MBIN_SOURCE.txt, MBIN_FILE_SOURCE["..k.."][1] "..mbin_file_source[k][1])
              table.insert(NewMBIN_FILES,mbin_file_source[k][2])
              if not IsNewMBIN_File(NewMBIN_FILES,mbin_file_source[k][1]) then
                if m==#mod_def_change_table and n == #mod_def and k==#mbin_file_source then --last one of the table
                  WordWrap2 = ""
                end
                if n==1 and m==1 and k==1 then --first time only
                  WriteToFile(mbin_file_source[k][1]..WordWrap2,"MOD_MBIN_SOURCE.txt")
                else
                  WriteToFileAppend(mbin_file_source[k][1]..WordWrap2,"MOD_MBIN_SOURCE.txt")
                end
              end
            end
          
          else
            --alternate syntax #2
            pv("DETECTED a normal MBIN_FILE_SOURCE table")
            for k=1,#mbin_file_source,1 do
              mbin_file_source[k] = NormalizePath(mbin_file_source[k])
              pv("MBIN_FILE_SOURCE["..k.."] "..mbin_file_source[k])
              
              if not IsNewMBIN_File(NewMBIN_FILES,mbin_file_source[k]) then
                pv("Writing to MOD_MBIN_SOURCE.txt, mbin_file_source[k] = "..mbin_file_source[k])
                if m==#mod_def_change_table and n==#mod_def and k==#mbin_file_source then --last one of the table
                  WordWrap2 = ""
                end
                if n==1 and m==1 and k==1 then --first time only
                  WriteToFile(mbin_file_source[k]..WordWrap2,"MOD_MBIN_SOURCE.txt")
                else
                  WriteToFileAppend(mbin_file_source[k]..WordWrap2,"MOD_MBIN_SOURCE.txt")
                end
              end
            end
          end

        else
          --alternate syntax #1
          pv("DETECTED MBIN_FILE_SOURCE as a string or nil")
          mbin_file_source = NormalizePath(mbin_file_source)
          if mbin_file_source == nil then
            print(_zRED.."[WARNING] MBIN_FILE_SOURCE["..n.."]["..m.."] is empty!".._zDEFAULT)
            mbin_file_source = ""
            abortProcessing = true
          else
            pv("MBIN_FILE_SOURCE["..n.."]["..m.."] "..mbin_file_source)
          end
          
          if not IsNewMBIN_File(NewMBIN_FILES,mbin_file_source) then
            pv("Writing to MOD_MBIN_SOURCE.txt, mbin_file_source = "..mbin_file_source)
            if m==#mod_def_change_table and n==#mod_def then
              WordWrap2 = ""
            end
            if n==1 and m==1 then --first time only
              WriteToFile(mbin_file_source..WordWrap2,"MOD_MBIN_SOURCE.txt")
            else
              WriteToFileAppend(mbin_file_source..WordWrap2,"MOD_MBIN_SOURCE.txt")
            end		
          end
        end		
      end
    end
    
    --CleanUP MOD_MBIN_SOURCE.txt
    local MBIN_SOURCE = ParseTextFileIntoTable("MOD_MBIN_SOURCE.txt")
    for i=1,#MBIN_SOURCE do
      for j=i+1,#MBIN_SOURCE do
        if MBIN_SOURCE[i] == MBIN_SOURCE[j] then
          MBIN_SOURCE[j] = ""
        end
      end
    end
    local MBIN_SOURCE_temp = {}
    for i=1,#MBIN_SOURCE do
      if MBIN_SOURCE[i] ~= "" then
        table.insert(MBIN_SOURCE_temp,MBIN_SOURCE[i])
      end
    end
    WriteToFile(ConvertLineTableToText(MBIN_SOURCE_temp),"MOD_MBIN_SOURCE.txt")
    
    -- print("__________________________________________")
    --check PAK_SOURCE for each MBIN_FILE_SOURCE
    local MODS_pak_list = ParseTextFileIntoTable("MODS_pak_list.txt")
    -- print("MODS_pak_list = "..#MODS_pak_list)
    
    local MBIN_Source = ParseTextFileIntoTable("MOD_MBIN_SOURCE.txt")
    for i=1,#MBIN_Source do
      local TempMBIN = MBIN_Source[i]
      local found = false
      --check if this file is already in MODBUILDER\MOD
      local TempEXML = string.gsub(MBIN_Source[i],[[.MBIN.PC]],[[.MBIN]])
      TempEXML = string.gsub(TempEXML,[[.MBIN]],[[.EXML]])
      if IsFileExist([[.\MOD\]]..TempEXML) then
        found = true
      else
        TempMBIN = string.gsub(MBIN_Source[i],[[\]],[[/]])
        for j=1,#MODS_pak_list do
          -- print("["..MODS_pak_list[j].."]")
          if trim(MODS_pak_list[j]) == "FROM MODS" then
            -- print(">>> break on FROM MODS")
            break
          else
            if string.find(MODS_pak_list[j],TempMBIN,1,true) ~= nil then
              --this MBIN is in one of the ModScript paks
              -- print(">>> Found "..TempMBIN.." in MODS_pak_list.txt at "..j)
              found = true
              break
            end
          end
        end
      end
      
      if not found then
        --this MBIN is not in any of the ModScript paks
        local found,Pak_File = LocateMOD_PAK_SOURCE(MBIN_Source[i])
        -- print("this "..Pak_File)
        if not found then
          print(_zRED.."[WARNING] NMS PAK not found for ["..MBIN_Source[i].."]. Check your file path/name, if it is a NMS file!".._zDEFAULT)
          Report("","NMS PAK not found for ["..MBIN_Source[i].."]. Check your file path/name, if it is a NMS file!","WARNING")
        end
      end
    end
    
    --LookAt_MOD_PAK_SOURCE_content("- BBBBB before cleanup")
    --CleanUP MOD_PAK_SOURCE.txt
    local PAK_Source = ParseTextFileIntoTable("MOD_PAK_SOURCE.txt")
    for i=1,#PAK_Source do
      for j=i+1,#PAK_Source do
        if PAK_Source[i] == PAK_Source[j] then
          PAK_Source[j] = ""
        end
      end
    end
    
    local PAK_Source_temp = {}
    for i=1,#PAK_Source do
      if PAK_Source[i] ~= "" then
        table.insert(PAK_Source_temp,PAK_Source[i])
      end
    end
    
    WriteToFile(ConvertLineTableToText(PAK_Source_temp),"MOD_PAK_SOURCE.txt")
    
    --LookAt_MOD_PAK_SOURCE_content("- AAAAA finally")
  else
    WriteToFile("", "MOD_MBIN_SOURCE.txt")
    WriteToFile("", "MOD_PAK_SOURCE.txt")
    -- WriteToFile("", "MOD_FILENAME.txt")
  end
  
  return abortProcessing
end

--***************************************************************************************************  
function ProcessScript(NMS_MOD_DEFINITION_CONTAINER,Multi_pak)
  if Multi_pak == nil then Multi_pak = false end
  
  --Wbertro
  --edge case involving combining and a certain type of scripts
  --need to signal GetFreshSources to threat REMOVE files differently
  --   if REMOVE, open fresh copy in ALT folder
  --   if REMOVE, file in ALT is to be used by TestScript above then deleted
  
  print(">>> [INFO] Checking MBIN_FILE_SOURCE validity...")
  abortProcessing = TestScript(NMS_MOD_DEFINITION_CONTAINER)
  
  if not abortProcessing then
    local global_integer_to_float = NMS_MOD_DEFINITION_CONTAINER["GLOBAL_INTEGER_TO_FLOAT"]
    
    -- *****************   global_integer_to_float section   ********************
    if global_integer_to_float == nil then
      global_integer_to_float = "" 
    end
    global_integer_to_float = string.upper(global_integer_to_float)
    
    local IsGlobalInteger_to_floatDeclared = (global_integer_to_float ~= "")
    local IsGlobalInteger_to_floatPRESERVE = (global_integer_to_float == "PRESERVE")
    local IsGlobalInteger_to_floatFORCE = (global_integer_to_float == "FORCE")

    if IsGlobalInteger_to_floatDeclared then
      print()
      print(_zGREEN..[[>>> [NOTICE] GLOBAL_INTEGER_TO_FLOAT is "]]..global_integer_to_float..[["]].._zDEFAULT)
      Report(global_integer_to_float,[[>>> GLOBAL_INTEGER_TO_FLOAT is]],"NOTICE")
    end
    
    if IsGlobalInteger_to_floatDeclared and not (IsGlobalInteger_to_floatPRESERVE or IsGlobalInteger_to_floatFORCE) then
      print(_zRED..[[>>> [WARNING] GLOBAL_INTEGER_TO_FLOAT value is incorrect, should be "", "FORCE" or "PRESERVE"]].._zDEFAULT)
      Report(global_integer_to_float,[[>>> GLOBAL_INTEGER_TO_FLOAT value is incorrect, should be "", "FORCE" or "PRESERVE"]],"WARNING")
      
      global_integer_to_float = "" --not used until corrected
    end
      
    print("--------------------------------------------------------------------------------------")

    if os.execute([[cmd /c GetFreshSources.bat]]) == nil then
      print(_zRED.."    [ERROR] GetFreshSources.bat ended unexpectedly".._zDEFAULT)
    end
    --reset
    LuaStarting()
    
    HandleModScript(NMS_MOD_DEFINITION_CONTAINER,Multi_pak,global_integer_to_float)
    
    --make date format configurable
    local now = os.date(_mDateTimeFormat)
    WriteToFile(now,[[DateTime.txt]])
    
    local cleanedNow = string.gsub(now,[[/]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[\]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[:]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[*]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[?]],[[]])
    cleanedNow = string.gsub(cleanedNow,[["]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[<]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[>]],[[]])
    cleanedNow = string.gsub(cleanedNow,[[|]],[[]])
    WriteToFile(cleanedNow,[[cleanedDateTime.txt]]) --used by CreateMod.bat
    
    if CustomDateTimeFormat then
      print(_zRED..">>> [INFO] Using custom DateTime format!".._zDEFAULT)
      Report("","Using custom DateTime format!")
    end

    if _bCOMBINE_MODS == "0" then
      -- an Individual mod
      -- create mod after each script is processed
      print(_zRED..">>> [INFO] Building MOD now...".._zDEFAULT)
      os.execute([[cmd /c CreateMod.bat]])
      --reset
      LuaStarting()
    elseif _bNumberScripts == _bScriptCounter then
      -- all other types of mod: (generic in name), (distinct in name) and Mod1+Mod2+Mod3.pak type mods
      print(_zRED..">>> [INFO] Reached LAST script of Combined Mod, Building MOD now...".._zDEFAULT)
      os.execute([[cmd /c CreateMod.bat]])
      --reset
      LuaStarting()
    else
      print(_zRED..">>> [INFO] Combined Mod ACTIVE: Delaying Building MOD until the end...".._zDEFAULT)
      Report("","Combined Mod ACTIVE: Delaying Building MOD until the end...")
    end
  
  else
    --abortProcessing is true
    print(_zRED..">>> [INFO] Processing aborted...".._zDEFAULT)
    Report("","Processing aborted...")
  end
end
--################  end USERSCRIPT PROCESSING  ###############################

-- ****************************************************
-- main (above should be like SCRIPTBUILDER\TestReCreatedScript.lua)
--      (below not at all)
-- ****************************************************

if gVerbose == nil then dofile("LoadHelpers.lua") end
pv(">>>     In LoadAndExecuteModScript.lua")
gfilePATH = "..\\" --for Report()

THIS = "In LoadAndExecuteModScript: "

NMS_FOLDER = LoadFileData("NMS_FOLDER.txt")
NMS_FOLDER = string.gsub(NMS_FOLDER,"\n","") --remove line break if any
gNMS_PCBANKS_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\PCBANKS\]]
-- print("*************  ["..gNMS_PCBANKS_FOLDER_PATH.."]")

gMASTER_FOLDER_PATH = LoadFileData("MASTER_FOLDER_PATH.txt")
gLocalFolder = [[MODBUILDER\MOD\]]

gSCRIPTBUILDERscript = false
  
--global for all sub-scripts
gSaveSectionContent = {}
gSaveSectionName = {}
gUseSectionContent = {}
gUseSectionName = {}

--to print them
--GetLuaCurrentKeyWordsAndAll(_G,"",true)

--Get all environment variables once
_mLUAC = os.getenv("_mLUAC")

_bNumberScripts = os.getenv("_bNumberScripts")
_bScriptName = os.getenv("_bScriptName")

_bCOMBINE_MODS = os.getenv("_bCOMBINE_MODS")
_mIncludeLuaScriptInPak = os.getenv("-IncludeLuaScriptInPak")

_bCOPYtoNMS = os.getenv("_bCOPYtoNMS")

_bAllowMapFileTreeCreator = os.getenv("_bAllowMapFileTreeCreator")

_bCreateMapFileTree = os.getenv("_bCreateMapFileTree") --internal only
_bReCreateMapFileTree = os.getenv("-ReCreateMapFileTree") --from OPTIONS
_mUSE_TXT_MAPFILETREE = os.getenv("-MAPFILETREE") == "TXT"
_mUSE_LUA_MAPFILETREE = os.getenv("-MAPFILETREE") == "LUA"
_mSERIALIZING = os.getenv("_mSERIALIZING")
_bMaxPakNameLength = os.getenv("_bMaxPakNameLength")

--default
_mDateTimeFormat = "%Y/%m/%d-%H:%M:%S"
CustomDateTimeFormat = false

if IsFileExist([[..\DateTimeFormat.txt]]) then
  local tmpDTF = LoadFileData([[..\DateTimeFormat.txt]])
  if tmpDTF ~= nil and tmpDTF ~= _mDateTimeFormat then
    _mDateTimeFormat = tmpDTF
    CustomDateTimeFormat = true
  end
end

_mWbertro = os.getenv("_mWbertro")
_bOS_bitness = os.getenv("_bOS_bitness")
_bCPU = os.getenv("_bCPU")
_bMinCPU = os.getenv("_bMinCPU")
_mISxxx = os.getenv("_mISxxx")
_mSHOWSECTIONS = os.getenv("-SHOWSECTIONS")
_mSHOWEXTRASECTIONS = os.getenv("-SHOWEXTRASECTIONS")
_mDEBUG = os.getenv("_mDEBUG")
_mSerializeScript = os.getenv("-SerializeScript")
--end Get all environment variables once

gpak_listTable = ParseTextFileIntoTable("pak_list.txt")

gModScriptDirList = {}
gModScriptDirList = ListDir(gModScriptDirList,[[..\ModScript]],true,false)

--clean and keep only .lua scripts
local tempList = {}
for i=1,#gModScriptDirList do
  if string.sub(gModScriptDirList[i],-4) == ".lua" then
    tempList[#tempList+1] = gModScriptDirList[i]
  end
end
gModScriptDirList = tempList

_bScriptCounter = 0
WriteToFile("", "ScriptCounter.txt")

_bNumberScripts = #gModScriptDirList
for i=1,#gModScriptDirList do
  -- print(gModScriptDirList[i])
  _bScriptCounter = i
  _bScriptName = gModScriptDirList[i]
  -- print("_bScriptName = [".._bScriptName.."]")
  -- echo|set /p="%%G">CurrentModScript.txt
  -- echo|set /p="%%~nxG">CurrentModScript_Short.txt
  WriteToFile(gMASTER_FOLDER_PATH..[[ModScript\]].._bScriptName, "CurrentModScript.txt")
  WriteToFile(_bScriptName, "CurrentModScript_Short.txt")

  
  print()
  print(_zRED..">>> Starting to process script #".._bScriptCounter.." of ".._bNumberScripts
                .." [".._bScriptName.."]".._zDEFAULT)
  print()
  print(">>> Opening User Lua Script, Please wait...")

  --*************************************************
  gNMS_MOD_DEFINITION_CONTAINER = OpenUserScript()
  --*************************************************

  if (_mWbertro ~= nil) and gNMS_MOD_DEFINITION_CONTAINER ~= nil then
    SaveTable("..\\TempTable.txt",gNMS_MOD_DEFINITION_CONTAINER,"NMS_MOD_DEFINITION_CONTAINER") 
  end

  if type(gNMS_MOD_DEFINITION_CONTAINER) == "table" then    
    if _bAllowMapFileTreeCreator == "Y" then
      if _bNumberScripts > 0 then
        if not IsFileExist("MapFileTreeSharedList.txt") then
          WriteToFile("","MapFileTreeSharedList.txt")
        end
        dofile("CreateMapFileTreeStarter.lua")
      end
    end

    if _bCOMBINE_MODS == "0" or _bScriptCounter == 1 then
      --INDIVIDUAL MODs: Cleaning directory MOD each time
      --COMBINED MOD: Cleaning directory MOD before first script only
      local cmd = [[CleanMod.bat]]
      NewThread(cmd)
    end

    if type(gNMS_MOD_DEFINITION_CONTAINER[1]) == "table" then
      local Container = gNMS_MOD_DEFINITION_CONTAINER

      for i=1,#Container do
        if i > 1 then
          print()
          print(_zRED..">>> Still processing script #".._bScriptCounter.." of ".._bNumberScripts
                        .." [".._bScriptName.."]".._zDEFAULT)
          print()

          Report("")
          Report("","========================================================================================")
          Report("","Still processing script #".._bScriptCounter.." of ".._bNumberScripts
                        .." [".._bScriptName.."]")
        else
          Report("")
          Report("","========================================================================================")
          Report("","Processing script #".._bScriptCounter.." of ".._bNumberScripts
                        .." [".._bScriptName.."]")
        end
        
        print(_zGREEN.."              ++++++++++  A Multi-PAK script  ++++++++++".._zDEFAULT)
        print(_zGREEN.."              >>> Processing sub-script #"..i..[[ of ]]..#Container.._zDEFAULT)
        print()

        Report("","              ++++++++++  A Multi-PAK script  ++++++++++")
        Report("","              >>> Processing sub-script #"..i..[[ of ]]..#Container)
        
        if _mIncludeLuaScriptInPak ~= nil then
          print(">>> Copying script source to MOD")
          Report("","Copying script source to MOD")

          --copy script to MOD folder
          FilePathSource = LoadFileData("CurrentModScript.txt")
          -- print("["..FilePathSource.."]")
          FolderPath = [[.\MOD\]]..LoadFileData("CurrentModScript_Short.txt")
          -- print("["..FolderPath.."]")
          local cmd = [[xcopy /y /h /v /i "]]..FilePathSource..[[" "]]..FolderPath..[[*" 1>NUL 2>NUL]]
          NewThread(cmd)
        end

        ProcessScript(Container[i],True)
        
        Report("","Ending MBIN/PAK phase...")

        -- this is handle by CreateMod.bat
        -- if _bCOMBINE_MODS == "0" then
          -- --individual mod
          -- Report("","Copied PAKs to NMS MOD folder...")
        -- end

        Report("","Ended sub-script "..i.." of [".._bScriptName.."]")
        if i == #Container then
          Report("","Ended script [".._bScriptName.."]")
        end
        Report("","========================================================================================")

        --spacing for sub-script
        print()
        Report("")
      end
    else
      --only one entry
      Report("")
      Report("","========================================================================================")
      Report("","Starting to process script #".._bScriptCounter.." of ".._bNumberScripts
                    .." [".._bScriptName.."]")

      print(_zGREEN.."              ++++++++++  A Single-PAK script  ++++++++++".._zDEFAULT)
      print()

      if _mIncludeLuaScriptInPak == "Y" then
        print(">>> Copying script source to MOD")
        Report("","Copying script source to MOD")

        --copy script to MOD folder
        FilePathSource = LoadFileData("CurrentModScript.txt")
        -- print("["..FilePathSource.."]")
        FolderPath = [[.\MOD\]]..LoadFileData("CurrentModScript_Short.txt")
        -- print("["..FolderPath.."]")
        local cmd = [[xcopy /y /h /v /i "]]..FilePathSource..[[" "]]..FolderPath..[[*" 1>NUL 2>NUL]]
        NewThread(cmd)
      end

      ProcessScript(gNMS_MOD_DEFINITION_CONTAINER)

      Report("","Ending MBIN/PAK phase...")
      
      -- this is handle by CreateMod.bat
      -- if _bCOMBINE_MODS == "0" then
        -- --individual mod
        -- Report("","Copied PAKs to NMS MOD folder...")
      -- end
      
      Report("","Ended script [".._bScriptName.."]")
      Report("","========================================================================================")
      Report("")
    end
    
  else
    WriteToFile("", "MOD_MBIN_SOURCE.txt")
    WriteToFile("", "MOD_PAK_SOURCE.txt")
    WriteToFile("", "MOD_FILENAME.txt")
    WriteToFile("", "MOD_AUTHOR.txt")
    WriteToFile("", "LUA_AUTHOR.txt")
    WriteToFile("", "LoadScriptAndFilenamesERROR.txt")
    print(_zRED..">>> [ERROR] NMS_MOD_DEFINITION_CONTAINER is not a table, this script has a problem!".._zDEFAULT)
    print("")
    Report(LoadFileData("CurrentModScript.txt"),"NMS_MOD_DEFINITION_CONTAINER is not a table, this script has a problem!","ERROR")
  end

  --save _bScriptCounter for batch
  WriteToFile(tostring(_bScriptCounter), "ScriptCounter.txt")
  
  print()
  print(_zDARKGRAY.."-----------------------------------------------------------".._zDEFAULT)
  print(_zRED..">>>            Scripts processed: ".._bScriptCounter.._zDEFAULT)
  print(_zRED..">>>     Total scripts to process: ".._bNumberScripts.._zDEFAULT)
  print(_zDARKGRAY.."-----------------------------------------------------------".._zDEFAULT)

  if _bCOMBINE_MODS ~= "0" then
    --combined mod
    if _bNumberScripts == _bScriptCounter then
      print()
      print(_zGREEN..">>> Done building ALL scripts".._zDEFAULT)
      print(_zGREEN..">>> Copying PAK to NMS MOD folder...".._zDEFAULT)

      Report("","Done building ALL scripts")
      Report("","Copied PAK to NMS MOD folder...")
      -- Report("")
    end
  end
end

pv(THIS.."ending")
LuaEndedOk(THIS)
