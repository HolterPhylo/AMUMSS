function LocatePAK(filename)
  -- pv("In LocatePAK()")
  local pak_listTable = gpak_listTable
  local Pak_FileName = ""
  
  filename = string.gsub(filename,[[%.EXML]],[[.MBIN]])
  filename = string.gsub(filename,[[\]],[[/]])
  -- pv("["..filename.."]")
  -- pv(#pak_listTable.." lines")
  for i=1,#pak_listTable,1 do
		local line = pak_listTable[i]
		if (line ~= nil) then
      if string.find(line,"Listing ",1,true) ~= nil then
        local start,stop = string.find(line,"Listing ",1,true)
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

function DisplayMapFileTreeEXT(EXML,filename)
  --******************************************************************
  --NOT THE SAME AS TestReCreatedScript.lua -> MapFileTree()
  --NOT THE SAME AS LoadAndExecuteModScript.lua -> MapFileTree()
  --this DisplayMapFileTree must only recreate all KEY_WORDS to display them in a tree
  --******************************************************************
  WriteToFileAppend("=== DisplayMapFileTreeEXT: received request to process file ["..filename.."]\n",Runner)
  
  local KEY_WORDS = {}
  local TREE_LEVEL = {}
  local FILE_LINE = {}
  local COMMENT = {}
  local level = 0
  
  if type(EXML) ~= "table" or #EXML <= 1 then
    WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'NO TABLE TO PROCESS'\n",Runner)
    return "ERROR" 
  end

  --***************************************************************************************************  
  local function FindKeywordsInLine(text,i)
    local KeywordsInRange = ""

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
  local Pak_FileNamePath = NMS_PCBANKS_FOLDER_PATH..Pak_FileName
  local fileInfo = string.gsub(filename,[[\]],[[.]])
  local filepathname = "..\\MapFileTrees\\"..fileInfo
   
  if _mUSE_TXT_MAPFILETREE then
    filepathname = filepathname..".txt"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".lua"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]])    

  elseif _mUSE_LUA_MAPFILETREE then
    filepathname = filepathname..".lua"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".txt"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]])    

  else --set default
    _mUSE_TXT_MAPFILETREE = true
    filepathname = filepathname..".txt"

    --delete old other versions
    local OLDfilepathname = "..\\MapFileTrees\\"..fileInfo..".lua"
    --os.remove(OLDfilepathname)    --don't use, can get stuck
    os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..OLDfilepathname..[[" 1>NUL 2>NUL]])  
  end
  
  if IsFile2Newest(Pak_FileNamePath,filepathname) then
    --the MapFileTree file is newest than the NMS pak file
    --no need to update
    -- print("      MapFileTree is up-to-date!")
    -- Report("","      MapFileTree is up-to-date!")
    WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'this MapFileTree is up-to-date!'\n",Runner)
    return "ALREADY EXIST"
  end
  
  -- print("      Creating MapFileTree...")
  -- print("XYZ = "..filename)
  
  local WholeTextFile = LoadFileData(SourcePath..filename) --the EXML file as one text, for speed searching for uniqueness
  -- WriteToFileAppend("=== DisplayMapFileTreeEXT: after WholeTextFile...\n",Runner)
  
  --skipping a few lines at start
  local j = 0
  repeat
    j = j + 1
  until string.find(EXML[j],[[<Data template=]],1,true) ~= nil
  
  local lineCount = j
  local count = 10000
  -- WriteToFileAppend("=== DisplayMapFileTreeEXT: starting main loop...\n",Runner)
  WriteToFileAppend("    DisplayMapFileTreeEXT: total lines to processed = "..#EXML.."("..lineCount..")\n",Runner)
  for i=j,#EXML do
    lineCount = lineCount + 1
    local text = EXML[i]
    if i%count == 0 then 
      WriteToFileAppend("   DMFE: "..i.." lines processed\n",Runner)
    end
    if string.find(text,[[/>]],1,true) ~= nil then
      local Name = ""
      if string.find(text,[[<Property name=]],1,true) ~= nil and string.find(text,[[value=]],1,true) ~= nil then
        Name = StripInfo(text,[[<Property name="]],[[" value=]])
      end
      
      if Name ~= "" then
        local result = FindKeywordsInLine(text,i)
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

      table.insert(KEY_WORDS, name..","..specialName)
      
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
      table.insert(KEY_WORDS, StripInfo(text,[[Property name=]],[[>]])..",") --remembers name
      table.insert(COMMENT, [[P..]])
      
    elseif string.find(text,[[Property value=]],1,true) ~= nil then
      --like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
      --could be a SIGNIFICANT KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[Property value=]],[[>]])..",") --remembers value
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
  WriteToFileAppend("    DisplayMapFileTreeEXT: total lines processed = "..lineCount.."\n",Runner)

  local info = {}
  if _mUSE_LUA_MAPFILETREE then
    WriteToFileAppend("=== DisplayMapFileTreeEXT: using _mUSE_LUA_MAPFILETREE #"..#FILE_LINE..", "..#TREE_LEVEL..", "..#KEY_WORDS..", "..#COMMENT.."\n",Runner)
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
      end
    end
  else --if _mUSE_TXT_MAPFILETREE then
    --default
  end

  -- os.remove([["]]..filepathname..[["]])  --don't use, can get stuck
  os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..filepathname..[[" 1>NUL 2>NUL]])
  
  local filehandle = WriteToFileEXT(filepathname)
  if filehandle ~= nil then
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(_mDateTimeFormat).."\n")
    filehandle:write(" [WARNING] Lower case 's/u' are Special/Unique with 'True', 'False' or a number".."\n")    
    filehandle:write(" TYPE = 'P'receding, 'S/s'pecial, 'U/u'nique".."\n")    
    filehandle:write(" TYPE:FILELINE:LEVEL     KEYWORDS".."\n")    

    if _mUSE_LUA_MAPFILETREE then
      -- filehandle:write("using _mUSE_LUA_MAPFILETREE #"..#info.."\n")    
      for i=1,#info do
        filehandle:write(info[i].."\n")
      end
    elseif _mUSE_TXT_MAPFILETREE then
      -- filehandle:write("using _mUSE_TXT_MAPFILETREE #"..#KEY_WORDS.."\n")    
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
    filehandle:write(">>> MapFileTree: "..filename.." ("..Pak_FileName..") "..os.date(_mDateTimeFormat).."\n")

    filehandle:close()
  end
  
  WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'MapFileTree created!'\n",Runner)
  return "OK"
end

function RunnerThread()
  WriteToFileAppend("+++ In Runner...\n",Runner)
  local Count = 0
  local MaxCount = 36
  local WaitTime = 5
  
  local OkToRun = false
  local FileListHandle = nil
  local Terminate = false
  
  while not OkToRun do
    FileListHandle = io.open([[MapFileTreeSharedList.txt]],"r")
    if FileListHandle == nil then
      WriteToFileAppend("+++ Runner: NOTICE >>> "..((MaxCount-Count+1)*WaitTime)..": Could not open MapFileTreeSharedList.txt.  Re-checking in "..WaitTime.." sec\n",Runner)
      sleep(WaitTime)
      
      if Count > 36 or (Count > 1 and not IsFileExist([[MapFileTreeCreatorRun.txt]])) then --failsafe exit
        Terminate = true
        WriteToFileAppend("+++ Runner: terminating on [waiting for MapFileTreeSharedList.txt]...\n",Runner)
        if IsFileExist([[MapFileTreeCreatorRun.txt]]) then
          WriteToFileAppend("+++ Runner: forcing removal of MapFileTreeCreatorRun.txt\n",Runner)
          os.remove([[MapFileTreeCreatorRun.txt]])
        end
        break
      end
      Count = Count + 1
    else
      WriteToFileAppend("+++ Runner: opened MapFileTreeSharedList.txt\n",Runner)
      OkToRun = true
    end
  end
  
  local List = {}
  local Done = {}

  if OkToRun then 
    WriteToFileAppend("+++ Runner: OkToRun\n",Runner)
  end

  local FlagError = false
  Count = 0
  --normally to check 2 more times before quitting
  while OkToRun and not Terminate do
    local FileList = {}
    local line = FileListHandle:read("l")
    while line ~= nil do 
      if line ~= " " then
        if line ~= "PING" then
          -- WriteToFileAppend("+++ Runner: Adding to FileList: ["..line.."]\n",Runner)
        end
        table.insert(FileList, line) 
      end
      line = FileListHandle:read("l")
    end
    
    for i=#FileList,1,-1 do
      if  FileList[i] == "PING" then
        -- WriteToFileAppend("+++ Runner: Resetting exit timer on PING\n",Runner)
        --reset timer
        Count = 1
      else
        local found = false
        for j=1,#List do
          if List[j] == FileList[i] then
            --skip it, already recorded
            found = true
            break
          end
        end
        if not found then
          if FileList[i] ~= nil then
            --add it to the list
            WriteToFileAppend("+++ Runner: Adding to List: ["..FileList[i].."]\n",Runner)
            table.insert(List,FileList[i])
            table.insert(Done, false)
          end
        else
          WriteToFileAppend("+++ Runner: Already done: ["..FileList[i].."]\n",Runner)
        end
      end
    end
    
    local info = ""
    for i=1,#List do
      if not Done[i] then
        -- WriteToFileAppend("+++ Runner: Resetting exit timer\n",Runner)
        --reset timer
        Count = 1
        
        --process this file
        WriteToFileAppend("+++ Runner: Parsing file ["..SourcePath..List[i].."]\n",Runner)
        local EXML = ParseTextFileIntoTable(SourcePath..List[i])

        info = DisplayMapFileTreeEXT(EXML,List[i])
        WriteToFileAppend("+++ Runner: DisplayMapFileTreeEXT exited with "..info.."\n",Runner)
        
        WriteToFileAppend("+++ Runner: Deleting file ["..SourcePath..List[i].."]\n",Runner)
        os.remove(SourcePath..List[i])
        
        Done[i] = true
      end      
    end
    
    if info == "ERROR" then
      FlagError = true
    end
    
    sleep(WaitTime)
    
    local AllDone = true
    for i=1,#Done do
      if not Done[i] then
        AllDone = false
        break
      end
    end
    
    if AllDone then
      if not IsFileExist([[MapFileTreeCreatorRun.txt]]) and Count > 1 then
        --terminate
        WriteToFileAppend("+++ Runner: received OK to terminate...\n",Runner)
        WriteToFileAppend("+++ Runner: closing MapFileTreeSharedList.txt\n",Runner)
        FileListHandle:close()
        break
      elseif Count > 36 then
        WriteToFileAppend("+++ Runner: terminating on [Count]...\n",Runner)
        WriteToFileAppend("+++ Runner: closing MapFileTreeSharedList.txt\n",Runner)
        FileListHandle:close()
        WriteToFileAppend("+++ Runner: forcing removal of MapFileTreeCreatorRun.txt\n",Runner)
        os.remove([[MapFileTreeCreatorRun.txt]])
        break
      end
      WriteToFileAppend("+++ Runner: Exit in "..((MaxCount-Count)*WaitTime).." sec or less if no more jobs unless asked to terminate...\n",Runner)
      Count = Count + 1
    end
  end

  if FlagError and IsFileExist([[..\WOPT_Wbertro.txt]]) then
    WriteToFileAppend("+++ Runner: WARNING >>> IN PAUSE MODE\n",Runner)
    os.execute([[START /wait "" /MAX cmd /c PAUSE_MAPFILETREE.bat]])  
  end
  
  if IsFileExist([[MapFileTreeSharedList.txt]]) then
    WriteToFileAppend("+++ Runner: removing "..[[MapFileTreeSharedList.txt]].."\n",Runner)
    if os.remove([[MapFileTreeSharedList.txt]]) == nil then
      WriteToFileAppend("+++ Runner: NOTICE >>> MapFileTreeSharedList.txt already removed\n",Runner)
    end
  else
    WriteToFileAppend("+++ Runner: NOTICE >>> MapFileTreeSharedList.txt does not exist!\n",Runner)
  end

  if IsFileExist([[MapFileTreeRequested.txt]]) then
    WriteToFileAppend("+++ Runner: removing "..[[MapFileTreeRequested.txt]].."\n",Runner)
    if os.remove([[MapFileTreeRequested.txt]]) == nil then
      WriteToFileAppend("+++ Runner: WARNING >>> could not remove file MapFileTreeRequested.txt\n",Runner)
    end
  else
    WriteToFileAppend("+++ Runner: WARNING >>> MapFileTreeRequested.txt does not exist!\n",Runner)
  end

  local folder =string.sub(SourcePath,1,#SourcePath-1)
  WriteToFileAppend("+++ Runner: Deleting ["..folder.."]\n",Runner)
  os.execute([[START /wait "" /B /MIN cmd /c Clean_TEMP_MAP.bat]])
  WriteToFileAppend("+++ Runner: terminated\n",Runner)

end

-- ****************************************************
-- main (above should be like SCRIPTBUILDER\TestReCreatedScript.lua)
--      (below not at all)
-- ****************************************************

--to prevent LuaStarting() when loading LoadHelpers.lua
local FlagLua = true
if gVerbose == nil then dofile("LoadHelpers.lua") end
-- pv(">>>     In CreateMapFileTree.lua")
gfilePATH = "..\\" --for Report()

THIS = "In CreateMapFileTree: "

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

NMS_FOLDER = LoadFileData("NMS_FOLDER.txt")
NMS_FOLDER = string.sub(NMS_FOLDER,1,string.find(NMS_FOLDER,"Sky",1,true)+2)
NMS_PCBANKS_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\PCBANKS\]]

MASTER_FOLDER_PATH = LoadFileData("MASTER_FOLDER_PATH.txt")
LocalFolder = [[MODBUILDER\]]

_mUSE_TXT_MAPFILETREE = IsFileExist([[USE_TXT_MAPFILETREE.txt]])
_mUSE_LUA_MAPFILETREE = IsFileExist([[USE_LUA_MAPFILETREE.txt]])

Runner = "MapFileTreeRunner.txt"
SourcePath = [[.\_TEMP_MAP\]]

gpak_listTable = ParseTextFileIntoTable("pak_list.txt")

WriteToFileAppendEXT = WriteToFileAppend

function WriteToFileAppend(msg,filename)
  if filename == Runner then
    --send to both cmd window and Runner file
    WriteToFileAppendEXT(msg,filename)
    local msg = string.gsub(msg,"\n","") --remove line break if any
    print(msg)
  else
    WriteToFileAppendEXT(msg,filename)
  end
end

--os.remove(Runner)

tmp = "TXT"
if _mUSE_LUA_MAPFILETREE then
  tmp = "LUA"
end

WriteToFileAppend("+++ Starting 2nd thread: "..tmp.."\n",Runner)
WriteToFileAppend("+++ Runner: v"..LoadFileData("AMUMSSVersion.txt").."\n",Runner)
print()
print([[  PLEASE DO NOT CLOSE THIS WINDOW, IT WILL SELF-CLOSE WHEN ITS WORK IS DONE!]])
print()
RunnerThread()

-- pv(THIS.."ending")
-- LuaEndedOk(THIS)
