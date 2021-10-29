--arg[1] == path to REPORT.txt
--arg[2] == path to MODBUILDER

if gVerbose == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
pv(">>>     In StartTime.lua")
gfilePATH = arg[1] --for Report()
THIS = "In StartTime: "

local startTime = os.time()
WriteToFile(startTime.."\n",arg[2]..[[Times.txt]])
Report("","Started MODBUILDER automatic processing at "..ShowTime(startTime))
Report("")
LuaEndedOk(THIS)
