--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == a message

if gVerbose == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
pv(">>>     In CheckREPORTLOG.lua")
gfilePATH = arg[1] --to use by LoadHelpers.Report()
THIS = "In CheckREPORTLOG: "

-- Report(arg[3])
local LogTable = ParseTextFileIntoTable(arg[1]..[[REPORT.txt]])
 
local WarningCount = 0
local ConflictCount = 0
local ErrorCount = 0
local BugCount = 0
for i=1,#LogTable do
  if string.find(LogTable[i],"[WARNING]:",1,true) then
    WarningCount = WarningCount + 1
  end
  if string.find(LogTable[i],"[CONFLICT]:",1,true) then
    ConflictCount = ConflictCount + 1
  end
  if string.find(LogTable[i],"[ERROR]:",1,true) then
    ErrorCount = ErrorCount + 1
  end
  if string.find(LogTable[i],"[BUG]:",1,true) then
    BugCount = BugCount + 1
  end
end

local say = ""
local spacerCMD = "           "
local spacerREPORT = "         "
local msgType = "ATTENTION"
local SeeReport = "" -- [[   >>> See "REPORT.txt"  <<<]]

say = ""
if BugCount > 0 then
  if BugCount > 1 then
    say = string.format(say..[[%6u BUGs reported. PLEASE post ALL scripts AND "REPORT.txt" on NEXUS at https://www.nexusmods.com/nomanssky/mods/957]],BugCount)
  else
    say = string.format(say..[[%6u BUG reported. PLEASE post ALL scripts AND "REPORT.txt" on NEXUS at https://www.nexusmods.com/nomanssky/mods/957]],BugCount)
  end
  print("")
  print(say)
  Report("")
  Report("",say,msgType)
  -- Report("")
end

say = ""
if ErrorCount > 0 then
  if ErrorCount > 1 then
    say = string.format(say..[[%6u ERRORS detected]],ErrorCount)
  else
    say = string.format(say..[[%6u ERROR detected]],ErrorCount)
  end

  print("")
  print(say..SeeReport)
  Report("")
  Report("",say,msgType)

  say = spacerCMD.."ERRORS will NOT produce MBIN files and a complete PAK file may not have been created."
  print(say)
  Report("",say,msgType)
  say = spacerCMD.."You need to correct the error first!"
  print(say)
  Report("",say,msgType)
else
  say = string.format(say.."%6u ERROR detected",ErrorCount)
  print("")
  print(say)
  Report("")
  Report("",spacerREPORT..say)
end

say = ""
if WarningCount > 0 then
  -- say = "XXXXX "
  if WarningCount > 1 then
    say = string.format(say..[[%6u WARNINGS raised]],WarningCount)
  else
    say = string.format(say..[[%6u WARNING raised]],WarningCount)
  end

  print("")
  print(say..SeeReport)
  Report("")
  Report("",say,msgType)

  say = spacerCMD.."WARNINGS may produce good or bad PAK files.  You have to be the judge!"
  print(say)
  Report("",say,msgType)
else
  say = string.format(say.."%6u WARNING raised",WarningCount)
  print("")
  print(say)
  Report("")
  Report("",spacerREPORT..say)
end

print("")
-- Report("")

say = ""
if ConflictCount > 0 then
  if ConflictCount > 1 then
    say = string.format(say..[[%6u CONFLICTS detected in processed Scripts/paks]],ConflictCount)
  else
    say = string.format(say..[[%6u CONFLICT detected in processed Scripts/paks]],ConflictCount)
  end
  print(say..SeeReport)
  Report("")
  Report("",say,msgType)

  -- Report("")
  say = spacerCMD.."CONFLICTS will prevent the mods involved from expressing their full effect."
  print(say)
  Report("",say,msgType)

  say = spacerCMD.."Some CONFLICTS can be resolved by COMBINING mods..."
  print(say)
  Report("",say,msgType)
  -- print()
  -- Report("")

  say = spacerCMD.."See file 'Creating a Patch for an existing MOD PAK.txt' for further help"
  print(say)
  Report("",say,msgType)
  print("")
  Report("")
else
  say = string.format(say.."%6u CONFLICT detected in processed Scripts/paks",ConflictCount)
  -- print("")
  print(say)
  Report("")
  Report("",spacerREPORT..say)  
  if (io.open(arg[2].."OnlyOneScript.txt") == nil) then
    say = spacerCMD.."It is safe to use together any of the generated PAKs"
    print(say)
    Report("",spacerREPORT..say)
  end
  print("")
  Report("")
end

LuaEndedOk(THIS)
