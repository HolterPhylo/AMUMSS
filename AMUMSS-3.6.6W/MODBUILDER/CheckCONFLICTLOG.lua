function LocatePAK(CurrentMBIN)
	local TextFileTable = ParseTextFileIntoTable(arg[2].."pak_list.txt")

  --because pak_list.txt uses / (and "xxx") and MBIN_PAKS.txt uses \
  TempMBIN = string.sub(string.gsub(CurrentMBIN,[[\]],[[/]]),2,#CurrentMBIN - 1)
  
  local NMSPAKname = ""
  local found = false
  
	for i=1,#TextFileTable do
		local line = TextFileTable[i]
		if (line ~= nil) then
      if (string.find(line,"Listing ",1,true) ~= nil) then
        local start,stop = string.find(line,"Listing ",1,true)
        NMSPAKname = string.sub(line, stop+1)
      elseif (string.find(line,TempMBIN,1,true) ~= nil) then
        found = true
        break
      end
		end
	end
  if not found then 
    NMSPAKname = "Only in User paks below"
  end
  
  return NMSPAKname
end

-- ****************************************************
-- main
-- ****************************************************

--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER
--arg[3] == a message
--arg[4] == 1 (check NMS MODS for conflict)

if gVerbose == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end --.\MODBUILDER\
pv(">>>     In CheckCONFLICTLOG.lua")
gfilePATH = arg[1] --to use by LoadHelpers.Report()
THIS = "In CheckCONFLICTLOG: "

-- -- Report(arg[3])
-- local LogTable = ParseTextFileIntoTable(arg[1]..[[REPORT.txt]])
local CheckMODSconflicts = (arg[4] == "1")

if CheckMODSconflicts then
  --merge MODS_pak_list with MBIN_PAKS
  local MODSTable = ParseTextFileIntoTable(arg[2]..[[MODS_pak_list.txt]])
  local pakName = ""
  for i=1,#MODSTable do
    local text = MODSTable[i]
    if text ~= nil and trim(text) ~= "" then
      if string.sub(text,1,7) == "Listing" then
        pakName = string.sub(text,9)
      elseif string.sub(text,1,5) == "FROM " then
        if string.sub(text,6) == "MODS" then
        else -- "ModScript"
        end
      else
        local pakFile = string.gsub(StripInfo(text,[[]],[[ (]]),[[/]],[[\]])
        -- because some user pak file list may start with / or other non-letters
        local start = string.find(pakFile,"%a")
        pakFile = string.sub(pakFile,start)
        WriteToFileAppend(pakFile..", : "..pakName.."\n",arg[2]..[[MBIN_PAKS.txt]])
      end
    end
  end
end

local ConflictScriptTable = ParseTextFileIntoTable(arg[2]..[[MBIN_PAKS.txt]])

-- --debug purposes only
-- WriteToFile("", "MBIN_PAKS_combined.txt")    
-- for i=1,#ConflictScriptTable do
  -- local text = ConflictScriptTable[i]
  -- if text ~= nil and trim(text) ~= "" then
    -- WriteToFileAppend(text.."\n", "MBIN_PAKS_combined.txt")    
  -- end
-- end

-- print(os.date())

if CheckMODSconflicts then
  print()
  print(">>> Checking Conflicts in Processed Scripts/paks and NMS MODS paks. Please wait...")
  Report("")
  Report("",">>> Checked Conflicts in Processed Scripts/paks and NMS MODS paks.")
  Report("")
else
  print()
  print("===== Conflicts in NMS MODS were NOT checked at user request =====")
  -- print()
  Report("")
  Report("","===== Conflicts in NMS MODS were NOT checked at user request =====")
  -- Report("")

  -- print()
  print(">>> Checking Conflicts in Processed Scripts/paks only. Please wait...")
  -- Report("")
  Report("",">>> ONLY Checked Conflicts in Processed Scripts/paks.")
  Report("")
end

local ConflictsDetected = false
local modulo = 1
local display = false
if #ConflictScriptTable > 500 then
  display = true
  modulo = math.ceil(#ConflictScriptTable / 10)
end
if #ConflictScriptTable - 1 > 0 then
  if display then
    print("    We have "..#ConflictScriptTable.." lines to process, be patient!  WORKING...")
  else
    print("    We have "..#ConflictScriptTable.." lines to process!  WORKING...")
  end
end

--remove duplicate lines
for i=1,#ConflictScriptTable-1 do
  local text1 = ConflictScriptTable[i]
  if text1 ~= nil and trim(text1) ~= "" then
    for j=i+1,#ConflictScriptTable do
      local text2 = ConflictScriptTable[j]
      if text2 ~= nil and trim(text2) ~= "" then
        if text1 == text2 then
          --duplicate
          ConflictScriptTable[j] = ""
        end
      end
    end
  end
end

-- --debug purposes only
-- for i=1,#ConflictScriptTable do
  -- local text1 = ConflictScriptTable[i]
  -- if text1 ~= nil and trim(text1) ~= "" then
    -- print(i.." ["..text1.."]")
  -- else
    -- print(i.." Empty")
  -- end
-- end
-- print()

for i=1,#ConflictScriptTable-1 do
  -- print("Line: "..i)
  if display and i%modulo == 0 then print(string.format("%9u of %u lines processed...",i,#ConflictScriptTable)) end
  local text = ConflictScriptTable[i]
  if text ~= nil and trim(text) ~= "" then
    local ConflictYet = false
    local MBINname = [["]]..StripInfo(text,[[]],[[,]])..[["]]
    local SCRIPTname = [["]]..StripInfo(text,[[, ]],[[:]])..[["]]
    local PAKname = [["]]..StripInfo(text,[[: ]])..[["]]
    -- print("A: "..i.." ["..MBINname.."]")
    -- print("A: "..i.." ["..SCRIPTname.."]")
    -- print("A: "..i.." ["..PAKname.."]")

    for j=i+1,#ConflictScriptTable do
      local text1 = ConflictScriptTable[j]
      if text1 ~= nil and trim(text1) ~= "" then
        local MBINname1 = [["]]..StripInfo(text1,[[]],[[,]])..[["]]
        local SCRIPTname1 = [["]]..StripInfo(text1,[[, ]],[[:]])..[["]]
        local PAKname1 = [["]]..StripInfo(text1,[[: ]])..[["]]
        -- print("B: "..j.."   ["..MBINname1.."]")
        -- print("B: "..j.."   ["..SCRIPTname1.."]")
        -- print("B: "..j.."   ["..PAKname1.."]")
        if PAKname ~= PAKname1 then --different PAKname, investigate
          if MBINname == MBINname1 then --same MBINname, a conflict
            if not ConflictYet then 
              --this one is modified by another one
              pv("Conflict in line "..i)
              ConflictYet = true
              ConflictsDetected = true
              local NMSPAKname = LocatePAK(MBINname)
              Report("",MBINname..[[ (]]..NMSPAKname..[[)]],"CONFLICT")
              Report("","is MOD-ified by:")
              if trim(SCRIPTname) ~= [[""]] then
                Report("","\t\t  "..[[ (==> ModScript folder)]]..SCRIPTname)
              else
                local PAKname = [["]]..StripInfo(text,[[: ]])..[["]]
                local start,stop = string.find(PAKname,[[..\ModScript\]],1,true)
                local comingFrom = "==> NMS MODS folder"
                if stop ~= nil then
                  PAKname = [["]]..string.sub(PAKname,stop+1)
                  comingFrom = "==> ModScript folder"
                end
                Report("","\t\t  ".." ("..comingFrom..")"..PAKname)
              end
            end
            if ConflictYet then
              if trim(SCRIPTname1) ~= [[""]] then
                Report("","\t\t+ "..[[ (==> ModScript folder)]]..SCRIPTname1)
              else
                local start,stop = string.find(PAKname1,[[..\ModScript\]],1,true)
                local comingFrom = "==> NMS MODS folder"
                if stop ~= nil then
                  PAKname1 = [["]]..string.sub(PAKname1,stop+1)
                  comingFrom = "==> ModScript folder"
                end
                Report("","\t\t+ ".." ("..comingFrom..")"..PAKname1)
              end
              ConflictScriptTable[j] = ""
              pv("       With line "..j)
            end
          end
        else --same PAKname
          if MBINname == MBINname1 then --same MBINNAME
            ConflictScriptTable[j] = ""
            pv("Rejected line "..j)
          -- elseif trim(SCRIPTname) ~= [[""]] and SCRIPTname == SCRIPTname1 then --same SCRIPTname
            -- ConflictScriptTable[j] = ""
          end
        end
      end
    end
    if Conflict then
      Report("")
    end
  end
end

print()
if ConflictsDetected then
  -- print([[XXXXX Some conflicts were detected, see "REPORT.txt" XXXXX]])
  -- print("          If you already made COMBINED paks for each, you're OK.")
  -- print("          Note, the COMBINED pak should also be listed as a conflicting file")
  -- print("          Otherwise, please COMBINE those scripts that MOD-ify the same file")
  -- print("          If you want them together in MODS to get the full effect of each script/mod")
  -- print()
  -- Report("")
  -- Report("","XXXXX Some conflicts were detected XXXXX","ABOUT CONFLICTS")
  -- Report("","      If you already made COMBINED paks for each, you're OK.","ABOUT CONFLICTS")
  -- Report("","      Note, the COMBINED pak should also be listed as a conflicting file","ABOUT CONFLICTS")
  -- Report("","      Otherwise, please COMBINE those scripts that MOD-ify the same file","ABOUT CONFLICTS")
  -- Report("","      If you want them together in MODS to get the full effect of each script/mod","ABOUT CONFLICTS")
  -- Report("")
else
  -- print("***** NO CONFLICT DETECTED IN USED SCRIPTS *****")
  -- print("          It is safe to use together any of the generated PAK")
  -- print()
  -- Report("")
  -- Report("","***** NO CONFLICT DETECTED IN USED SCRIPTS *****")
  -- Report("","          It is safe to use together any of the generated PAK")
  -- Report("")

end

LuaEndedOk(THIS)
