-- ****************************************************
-- main
-- ****************************************************
if gVerbose == nil then dofile("LoadHelpers.lua") end

if not IsFileExist("MapFileTreeRequested.txt") then
  WriteToFile("","MapFileTreeRequested.txt")
  os.execute([[START "CreateMapFileTree" /MIN ]]..os.getenv("_mLUA")..[[ CreateMapFileTree.lua]])
end
