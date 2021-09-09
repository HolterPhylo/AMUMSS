--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == a message

if gVerbose == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --in MODBUILDER
pv(">>>     In CheckMBINCompilerLOG.lua")
gfilePATH = arg[1] --for Report()
THIS = "In CheckMBINCompilerLOG: "

local LogTable = ParseTextFileIntoTable(arg[2]..[[MBINCompiler.log]])
local MASTER_FOLDER_PATH = LoadFileData(arg[2]..[[MASTER_FOLDER_PATH.txt]])

local say = arg[3]
-- because string.gsub pattern does not work with all folder names (ex.: ".")
if string.find(say,MASTER_FOLDER_PATH..[[MODBUILDER\MOD\]],1,true) ~= nil then
  local start = string.find(say,MASTER_FOLDER_PATH..[[MODBUILDER\MOD\]],1,true)
  say = string.sub(say,1,start - 1)..string.sub(say,string.len(MASTER_FOLDER_PATH..[[MODBUILDER\MOD\]]) + start)
end

local Compiling = true
local MessageStart = 10
if string.sub(say,1,1) == "D" then
  --we are Decompiling
    Compiling = false
    MessageStart = 12
end

local warningCount = 0
local errorCount = 0
for i=1,#LogTable do
  if string.find(LogTable[i],"[WARN]",1,true) then
    warningCount = warningCount + 1
  end
  if string.find(LogTable[i],"[ERROR]",1,true) then
    errorCount = errorCount + 1
  end
end  

if warningCount > 0 then
  if Compiling then
    Report("","Trying to compile... "..string.sub(say,MessageStart))
  else
    Report("","Trying to decompile... "..string.sub(say,MessageStart))
  end
  local Found = false
  for i=1,#LogTable do
    if not Found and string.find(LogTable[i],"[WARN]",1,true) then
      Found = true
      -- local info = LogTable[i+3] --print filepath+name
      -- print(info)
      local info = LogTable[i]
      local start,ending = string.find(info,"[WARN]: [",1,true)
      if ending ~= nil then
        info = string.sub(info,ending+1,#info-2)
      end
      print("    [WARNING] MBINCompiler = "..info.." OR check your script!")
      Report(info.." OR check your script!","MBINCompiler =","WARNING")
    elseif Found then  
      info = LogTable[i]
      if info == nil or trim(info) == "" 
            or string.find(info," converted.",1,true)
            or string.find(info," WARNINGS.",1,true)
            or string.find(info," TIME:",1,true)
            or string.find(info,"[FILE]:",1,true) then
        --skip it
      else
        print("    [WARN]    MBINCompiler = "..info)
        Report(info,"   MBINCompiler =","WARN")
      end
    end
  end
end

if errorCount > 0 then
  if Compiling then
    Report("","Trying to compile "..string.sub(say,MessageStart))
  else
    Report("","Trying to decompile "..string.sub(say,MessageStart))
  end
  local Found = false
  for i=1,#LogTable do
    if not Found and string.find(LogTable[i],"[ERROR]",1,true) then
      Found = true
      -- local info = LogTable[i+3] --print filepath+name
      -- print(info)
      local info = LogTable[i]
      local start,ending = string.find(info,"[ERROR]: [",1,true)
      if ending ~= nil then
        info = string.sub(info,ending,#info-1)
      end
      print("     [ERROR]  MBINCompiler = "..info.." OR check your script, if it is a NMS file!")
      Report(info.." OR check your script,if it is a NMS file!","MBINCompiler =","ERROR")
      Report("The PAK will not include this EXML, if it is a NMS file!","","PSARC")
    elseif Found then  
      info = LogTable[i]
      if info == nil or trim(info) == "" 
            or string.find(info," converted.",1,true)
            or string.find(info," FAILED.",1,true)
            or string.find(info," TIME:",1,true)
            or string.find(info,"[ERROR]:",1,true)
            or string.find(info,"[FILE]:",1,true) then
        --skip it
      else
        print("     [ERR]    MBINCompiler = "..info)
        Report(info,"  MBINCompiler =","ERR")
      end
    end
  end
end

if warningCount == 0 and errorCount == 0 then
  Report("SUCCESS "..say)
end

LuaEndedOk(THIS)
