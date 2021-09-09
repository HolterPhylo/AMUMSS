--arg[1] == path to Steam folder
--arg[2] == path to MODBUILDER

if gVerbose == nil then dofile(arg[2]..[[LoadHelpers.lua]]) end
pv(">>>     In GetNMSFolder.lua")
gSteamPATH = arg[1]
THIS = "In GetNMSFolder: "

local SteamLibrariesListPathFilename = gSteamPATH..[[\steamapps\libraryfolders.vdf]]

local SteamLibrariesList = ParseTextFileIntoTable(SteamLibrariesListPathFilename)

print("Found Steam Library paths:")

for i=5,#SteamLibrariesList-1 do
  local LibPath = string.sub(SteamLibrariesList[i],8,-2)
  LibPath = string.gsub(LibPath,[[\\]],[[\]])
  print("   "..LibPath)
  
  if IsFileExist(LibPath..[[\steamapps\common\No Man's Sky\GAMEDATA\PCBANKS\BankSignatures.bin]]) then
    print("Found NMS_FOLDER")
    WriteToFile(LibPath..[[\steamapps\common\No Man's Sky]],[[NMS_FOLDER.txt]])
    break
  end
end

LuaEndedOk(THIS)
