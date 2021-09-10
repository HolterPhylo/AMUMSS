function LocatePAK(filename)
  -- pv("In LocatePAK()")
	local TextFileTable = ParseTextFileIntoTable("pak_list.txt")  
  local Pak_FileName = ""
  
  filename = string.gsub(filename,[[%.EXML]],[[.MBIN]])
  filename = string.gsub(filename,[[\]],[[/]])
  -- pv("["..filename.."]")
  -- pv(#TextFileTable.." lines")
  for i=1,#TextFileTable,1 do
		local line = TextFileTable[i]
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
  WriteToFileAppend([[=== DisplayMapFileTreeEXT processing file []]..filename.."]\n",Runner)
  
  local KEY_WORDS = {}
  local TREE_LEVEL = {}
  local FILE_LINE = {}
  local level = 0
  
  if type(EXML) ~= "table" or #EXML <= 1 then
    WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'NO TABLE TO PROCESS'\n",Runner)
    return FILE_LINE,TREE_LEVEL,KEY_WORDS 
  end

  --***************************************************************************************************  
  local function FindKeywordsInRange(text,i)
    local KeywordsInRangeTable = ""
    -- local text = TextFile[StartRange]

    if string.find(text,[[ />]],1,true) ~= nil and string.find(text,[[ue=]],1,true) ~= nil then
      --a line like <Property name="" value="" /> 
      --"name" is a potential special_keyword
      local value = StripInfo(text,[[value="]],[["]])
      -- if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil and string.find(value,".",1,true) == nil then
      if value ~= "" and value ~= "True" and value ~= "False" and tonumber(value) == nil then
        local name = StripInfo(text,[[name="]],[["]])
        KeywordsInRangeTable = "[*"..string.format("%8u",i)..[[: ]]..name..[[="]]..value.."\"]"
      end
    end --if string.find(
    
    return KeywordsInRangeTable
  end
  --***************************************************************************************************  
  --***************************************************************************************************
  local function CheckUniqueness(WholeTextFile,spec_key_words)
    --count = 0 >>> not found, problem
    --count = 1 >>> unique, good
    --count > 1 >>> not unique, maybe good or not
    local s = [[<Property name="]]..spec_key_words[1]..[[" value="]]..spec_key_words[2]..[[" />]]
    local _,count = string.gsub(WholeTextFile,s,s)
    -- if count == 1 then
      -- pv("CheckUniqueness: Unique")
    -- elseif count == 0 then
      -- pv("CheckUniqueness: Not found")
    -- else
      -- pv("CheckUniqueness: More than one")
    -- end
    return count
  end
  --***************************************************************************************************

  local Pak_FileName = LocatePAK(filename)
  local Pak_FileNamePath = NMS_PCBANKS_FOLDER_PATH..Pak_FileName
  local fileInfo = string.gsub(filename,[[\]],[[.]])
  local filepathname = "..\\MapFileTrees\\"..fileInfo..".txt"
  
  if IsFile2Newest(Pak_FileNamePath,filepathname) then
    --the MapFileTree file is newest than the NMS pak file
    --no need to update
    -- print("      MapFileTree is up-to-date!")
    -- Report("","      MapFileTree is up-to-date!")
    WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'MapFileTree is up-to-date!'\n",Runner)
    return FILE_LINE,TREE_LEVEL,KEY_WORDS
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
  
  local count = 10000
  -- WriteToFileAppend("=== DisplayMapFileTreeEXT: starting main loop...\n",Runner)
  for i=j,#EXML do
    local text = EXML[i]
    if i%count == 0 then 
      WriteToFileAppend("   "..i.." lines processed\n",Runner)
    end
    if string.find(text,[[/>]],1,true) ~= nil then
      local Name = ""
      if string.find(text,[[<Property name=]],1,true) ~= nil and string.find(text,[[value=]],1,true) ~= nil then
        Name = StripInfo(text,[[<Property name="]],[[" value=]])
      end
      
      if Name ~= "" then
        local result = FindKeywordsInRange(text,i)
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
          local UniqueMsg = ""
          if secondPos == nil then
            UniqueMsg = " UNIQUE"
          end
          -- table.insert(KEY_WORDS, [[SPECIALNAME: "]]..Name..[[", ]]..StripInfo(text,[[" value=]],[[ />]])) --remembers name and value
          table.insert(KEY_WORDS, [[SPECIALNAME]]..UniqueMsg..[[: {"]]..StripInfo(result,[[: ]],[[=]])..[[",]]..StripInfo(result,[[=]],"]")..[[,},]]) --remembers name and value
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
      level = level - 1
      
    elseif string.find(text,[[<Property name=]],1,true) ~= nil and string.find(text,[[value=]],1,true) ~= nil then
      --like: <Property name="ProceduralTexture" value="TkProceduralTextureChosenOptionList.xml">
      --usually NOT a KEY_WORD but may be needed to match </Property> removing a KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[<Property name=]],[[ value=]])) --remembers name
      
    elseif string.find(text,[[Property name=]],1,true) ~= nil then
      --like: <Property name="Landmarks">
      --this is usually a SIGNIFICANT KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[Property name=]],[[>]])) --remembers name
      
    elseif string.find(text,[[Property value=]],1,true) ~= nil then
      --like: <Property value="TkProceduralTextureChosenOptionSampler.xml">
      --could be a SIGNIFICANT KEY_WORD
      level = level + 1
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[Property value=]],[[>]])) --remembers value
      
    elseif string.find(text,[[<Data template=]],1,true) ~= nil then
      --like: <Data template="GcExternalObjectList">
      --encountered only once at first line
      --NEVER a KEY_WORD
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, StripInfo(text,[[<Data template=]],[[>]])) --remembers template
      
    elseif string.find(text,[[</Data>]],1,true) ~= nil then
      --like: </Data>
      --encountered only once at end of file
      --NEVER a KEY_WORD
      table.insert(FILE_LINE,i)
      table.insert(TREE_LEVEL,level)
      table.insert(KEY_WORDS, "/Data") --remembers "/Data"
      
    end
  end  
  WriteToFileAppend("   "..#EXML.." lines processed\n",Runner)

  --can get stuck
  -- os.remove([["]]..filepathname..[["]])  
  os.execute([[START /wait "" /B /MIN cmd /c Del /f /q /s "]]..filepathname..[[" 1>NUL 2>NUL]])
  
  local filehandle = WriteToFileEXT(filepathname)
  if filehandle ~= nil then
    filehandle:write("MapFileTree: "..filename.." ("..Pak_FileName..")".."\n")
    filehandle:write("   LINE   LEVEL     KEYWORDS".."\n")    
    for i=1,#KEY_WORDS do
      if KEY_WORDS[i] ~= "<<<" then
        local line = string.format("%8u",FILE_LINE[i])
        local level = string.format("%2u",TREE_LEVEL[i])
        local info = "["..line.."] ["..level.."]"..string.rep("  ",TREE_LEVEL[i])..KEY_WORDS[i]
        filehandle:write(info.."\n")
      end
    end
    filehandle:close()
  end
  
  WriteToFileAppend("=== DisplayMapFileTreeEXT: returned 'MapFileTree created!'\n",Runner)
  return FILE_LINE,TREE_LEVEL,KEY_WORDS
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
      WriteToFileAppend("+++ Runner: WARNING >>> Could not open MapFileTreeSharedList.txt.  Re-checking in "..WaitTime.." sec\n",Runner)
      sleep(WaitTime)
      
      if Count > 36 or (Count > 1 and not IsFileExist([[MapFileTreeCreatorRun.txt]])) then --failsafe exit
        Terminate = true
        WriteToFileAppend("+++ Runner: terminating on waiting for MapFileTreeSharedList.txt...\n",Runner)
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
    
    for i=1,#List do
      if not Done[i] then
        -- WriteToFileAppend("+++ Runner: Resetting exit timer\n",Runner)
        --reset timer
        Count = 1
        
        --process this file
        WriteToFileAppend("+++ Runner: Parsing file ["..SourcePath..List[i].."]\n",Runner)
        local EXML = ParseTextFileIntoTable(SourcePath..List[i])

        DisplayMapFileTreeEXT(EXML,List[i])
        WriteToFileAppend("+++ Runner: DisplayMapFileTreeEXT completed\n",Runner)
        
        WriteToFileAppend([[+++ Runner: Deleting file []]..SourcePath..List[i].."]\n",Runner)
        os.remove(SourcePath..List[i])
        
        Done[i] = true
      end
      
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
        WriteToFileAppend("+++ Runner: terminating on Count...\n",Runner)
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
  
  WriteToFileAppend("+++ Runner: removing "..[[MapFileTreeSharedList.txt]].."\n",Runner)
  if os.remove([[MapFileTreeSharedList.txt]]) == nil then
    WriteToFileAppend("+++ Runner: WARNING >>> could not remove file MapFileTreeSharedList.txt\n",Runner)
  end

  WriteToFileAppend("+++ Runner: removing "..[[MapFileTreeRequested.txt]].."\n",Runner)
  if os.remove([[MapFileTreeRequested.txt]]) == nil then
    WriteToFileAppend("+++ Runner: WARNING >>> could not remove file MapFileTreeRequested.txt\n",Runner)
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

NMS_FOLDER = LoadFileData("NMS_FOLDER.txt")
NMS_FOLDER = string.sub(NMS_FOLDER,1,string.find(NMS_FOLDER,"Sky",1,true)+2)
NMS_PCBANKS_FOLDER_PATH = NMS_FOLDER..[[\GAMEDATA\PCBANKS\]]

MASTER_FOLDER_PATH = LoadFileData("MASTER_FOLDER_PATH.txt")
LocalFolder = [[MODBUILDER\]]

Runner = "MapFileTreeRunner.txt"
SourcePath = [[.\_TEMP_MAP\]]

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

os.remove(Runner)

WriteToFile("+++ Starting\n",Runner)
WriteToFileAppend("+++ Runner: v"..LoadFileData("AMUMSSVersion.txt").."\n",Runner)
print()
print([[  PLEASE DO NOT CLOSE THIS WINDOW, IT WILL SELF-CLOSE WHEN ITS WORK IS DONE!]])
print()
RunnerThread()

-- pv(THIS.."ending")
-- LuaEndedOk(THIS)
