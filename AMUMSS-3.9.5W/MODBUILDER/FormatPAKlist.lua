function FormatPAKList(filename)
  local LineTable = ParseTextFileIntoTable(filename)
  local TempTable = {}
  local FullTempTable = {}
  local badFile = false
  
  for i=1,#LineTable do
    local text = LineTable[i]
    if string.sub(text,1,7) == "Listing" then
      TempTable[i] = text.." = {"
      FullTempTable[i] = text
    elseif string.sub(text,1,1) ~= " " then
      local start = string.find(text," (",1,true)
      if start == nil then
        badFile = true
        break
      end
      local info = string.sub(string.gsub(text,[[/]],[[\]]),1,start-1)
      TempTable[i] = [["]]..info..[[",]]
      FullTempTable[i] = info
    else
      TempTable[i] = trim(text).."}"
      FullTempTable[i] = text
    end
  end
  
  if not badFile then
    local text = ConvertLineTableToText(TempTable)
    WriteToFile(text, filename.."Pretty.lua")
    
    local text = ConvertLineTableToText(FullTempTable)
    WriteToFile(text,"Full_"..filename)
  end
  return badFile
end

function GetDirList(filename)
  local LineTable = ParseTextFileIntoTable(filename)
  local TempTable = {}
  
  --pass one, remove all file names and remove duplicate directories
  local tempInfo = ""
  for i=1,#LineTable do
    local text = LineTable[i]
    if string.sub(text,1,7) == "Listing" then
      TempTable[#TempTable+1] = text.." = {"
      -- print(text)
    elseif string.sub(text,1,1) ~= " " then
      local info = getPath(text)
      -- local start = string.find(text,[[\]],-1,true)
      -- local info = string.sub(string.gsub(text,[[/]],[[\]]),1,start)
      if info ~= nil and info ~= tempInfo then
        TempTable[#TempTable+1] = "[["..info.."]],"
        tempInfo = info
        -- print(info)
      end
    else
      TempTable[#TempTable+1] = trim(text).."}"
    end
    -- if i > 10 then
      -- break
    -- end
  end

  -- --pass two, create pretty file
  -- local Temp = {}
  -- for i=1,#TempTable do
    -- local text = TempTable[i]
    -- if string.sub(text,1,7) == "Listing" then
      -- Temp[i] = text.." = {"
    -- elseif string.sub(text,1,1) ~= " " then
      -- -- local start = string.find(text," (",1,true)
      -- -- local info = string.sub(string.gsub(text,[[/]],[[\]]),1,start-1)
      -- Temp[i] = [["]]..text..[[",]]
    -- else
      -- Temp[i] = "}"
    -- end
  -- end
  
  -- local text = ConvertLineTableToText(Temp)
  local text = ConvertLineTableToText(TempTable)
  WriteToFile(text, "pak_Dir.txtPretty.lua")
  
end

-- ****************************************************
-- main
-- ****************************************************

--we are in SCRIPTBUILDER

LocalFolder = ""
if gVerbose == nil then dofile(LocalFolder.."LoadHelpers.lua") end
pv(">>>     In FormatPAKlist.lua")
THIS = "In FormatPAKlist: "

-- gfilePATH = "..\\" --for Report()

THIS = "In FormatPAKlist: " --Check for THIS in code before changing this string

MASTER_FOLDER_PATH = LoadFileData(LocalFolder.."MASTER_FOLDER_PATH.txt")

badFile = FormatPAKList(LocalFolder.."pak_list.txt")
if not badFile then
  GetDirList(LocalFolder.."Full_pak_list.txt")
else
  print(_zRED..[[>>> [ERROR] AMUMSS could not list NMS paks content, check access to folder GAMEDATA]].._zDEFAULT)
  Report("",[[>>> AMUMSS could not list NMS paks content, check access to folder GAMEDATA]],"ERROR")          
end

LuaEndedOk(THIS)
