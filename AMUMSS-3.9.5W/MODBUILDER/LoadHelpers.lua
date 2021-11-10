local lfs = require("lfs")

gVerbose = false
if not gVerbose then
  local handle = io.open([[..\WOPT_VERBOSE_LUA.txt]])
  if handle ~= nil then
    gVerbose = true
    handle:close()
  else
    if os.getenv("_gVERBOSE") == "Y" then
      gVerbose = true
    end
  end
end

if gVerbose then print("   [==[LUA Verbose ON]==]") end
gfilePATH = ".\\" --for Report()
local gReportFilehandle = nil

--***************************************************************************************************
gTracing = ""
function pv(...)
  if gVerbose then
    local temp = ""
    local num = select("#",...)
    for i=1,num do
      local text = select(i,...)
      if text == nil then text = "nil" end
      if type(text) == "boolean" then
        if text then
          text = "True"
        else
          text = "False"
        end
      end
      temp = temp..text
    end
    if temp ~= "" then
      temp = "<=>"..temp.."<=>"
    end
    if gTracing ~= "" then
      print(temp.."   T: "..gTracing)
    else
      print(temp)
    end
  end
  gTracing = ""
end

if not gVerbose then
  function pv()
  end
end 

pv(">>>     In LoadHelpers.lua")

gColors = (os.getenv("-UseColors") == "Y")

-- if not gColors then
  -- local handle = io.open([[..\OPT_Colors_ON.txt]])
  -- if handle ~= nil then
    -- gColors = true
    -- handle:close()
  -- end
-- end

if gColors then
  -- _zBLACK      ="[30m"
  _zRED           ="[1;31m[1m" 
  _zGREEN         ="[1;32m[1m"
  _zYELLOW        ="[1;33m[1m"
  _zDARKGRAY      ="[1;90m[1m"
  -- _zWHITE      ="[97m"

  _zWHITEonYELLOW ="[93;43m[1m"
  _zBLACKonYELLOW ="[7;93m"
  
  _zINVERSE       ="[7m"
  _zDEFAULT       ="[0m"
  
  _zUpOneLineErase="[F[K"
else
  -- _zBLACK      =""
  _zRED        =""
  _zGREEN      =""
  _zYELLOW     =""
  _zDARKGRAY   =""
  -- _zWHITE      =""
  
  _zWHITEonYELLOW =""

  _zBLACKonYELLOW =""
  _zINVERSE    =""
  _zDEFAULT    =""
  
  _zUpOneLineErase=""
end

--***************************************************************************************************
--local cmd = [[...]]
--NewThread(cmd)
function NewThread(cmd)
  -- /B /wait "": order is important for it to work on win7 and early win10 version
  return os.execute([[START /B /wait "" /MIN cmd /c ]]..cmd)
end

--***************************************************************************************************
function IsFileExist(filenamePath)
  local Exist = false
  if filenamePath == nil or filenamePath == "" then return Exist end
  local filehandle = io.open(filenamePath,"rb")
  Exist = (filehandle ~= nil)
  if Exist then filehandle:close() end
  return Exist
end

--***************************************************************************************************
function GetFileSize(filenamePath)
  local filehandle = assert(io.open(filenamePath,"r"),"io.open: Cannot open file to get file size: "..filenamePath)
  local size = filehandle:seek("end")    -- get file size
  filehandle:close()
  return size
end

--***************************************************************************************************
function GetFileCreationDate(filenamePath)
  local filehandle = io.popen( "dir "..filenamePath.." /T:W", "r" )
  local LineTable = {}
  local line = assert(filehandle:read("l"),"read: cannot read line from file: "..filenamePath)
  while line ~= nil do
    -- print(line,filenamePath)
    if tonumber(string.sub(line,1,1)) ~= nil then
      table.insert(LineTable, line)
    end
    line = filehandle:read("l")
  end

  filehandle:close()
  return LineTable
end

--***************************************************************************************************
function GetFileCreationByDate(path)
  local filehandle = io.popen( "dir "..path.." /O:-D /T:W /A:-D /B", "r")
  local LineTable = {}
  local line = filehandle:read("l")
  while line ~= nil do
    table.insert(LineTable, line)
    line = filehandle:read("l")
  end

  filehandle:close()
  return LineTable
end

--***************************************************************************************************
function IsFile2Newest(file1,file2)
  -- pv("IsFile2Newest: ["..file1.."]")
  -- pv("IsFile2Newest: ["..file2.."]")
  local File2IsNewest = false
  os.remove("NewerFile.txt")

  -- pv("IsFile2Newest: "..command)
  local cmd = [[cmd /c xcopy /DYLR "]]..file1
        ..[[" "]]..file2..[[*" | findstr /BC:"0" >nul && echo|set /p="]]..file2..[[ is newer">"NewerFile.txt"]]
  NewThread(cmd)

  File2IsNewest = IsFileExist("NewerFile.txt")
  os.remove("NewerFile.txt")
  return File2IsNewest
end

--***************************************************************************************************
function WriteToFile(output,filenamePath,binary)
  local filehandle = nil
  -- print("["..filenamePath.."]")
  if binary == "b" then
    -- print(io.open(filenamePath,"wb")) --wbertro: for debug
    filehandle = assert(io.open(filenamePath,"wb"),"io.open: Cannot open binary file to write: "..filenamePath)
  else
    -- print(io.open(filenamePath,"w")) --wbertro: for debug
    filehandle = assert(io.open(filenamePath,"w"),"io.open: Cannot open file to write: "..filenamePath)
  end
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

--***************************************************************************************************
function WriteToFileAppend(output,filenamePath)
  local filehandle = io.open(filenamePath,"a+")
  
  if filehandle == nil then
    sleep(1)
    filehandle = assert(io.open(filenamePath,"a+"),"io.open: Cannot open file to append: "..filenamePath)
  end
  
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

-- --***************************************************************************************************
-- function WriteToFileAppend(output,filename)
  -- local closeIt = false
  
  -- local filehandle = io.type(filename)
-- print("WriteToFileAppend: "..tostring(io.type(filename)))
  -- if filehandle == "file" then
    -- filehandle = filename
  -- else
    -- filehandle = nil
  -- end
  
  -- if filehandle == nil then
    -- filehandle = io.open(filename,"a+")
    -- closeIt = true
  -- end
  
  -- if filehandle == nil then
    -- sleep(1)
    -- filehandle = assert(io.open(filename,"a+"),"io.open: Cannot open file to append: "..filename)
    -- closeIt = true
  -- end
  
  -- if filehandle ~= nil then
    -- filehandle:write(output)
    
    -- if closeIt then
      -- filehandle:flush()
      -- filehandle:close()
      -- return nil
    -- else
      -- return filehandle
    -- end
  -- end
-- end

--***************************************************************************************************
function WriteToFileAppendEXT(filenamePath,...)
  local filehandle = assert(io.open(filenamePath,"a+"),"io.open: Cannot open file to append: "..filenamePath)
  if filehandle ~= nil then
    filehandle:write(...)
    filehandle:write("\n")
    filehandle:flush()
    filehandle:close()
  end
end

--***************************************************************************************************
function WriteToFileEXT(filenamePath,binary)
  local filehandle = nil
  -- print("["..filenamePath.."]")
  if binary == "b" then
    -- print(io.open(filenamePath,"wb")) --wbertro: for debug
    filehandle = assert(io.open(filenamePath,"wb"),"io.open: Cannot open file to write: "..filenamePath)
  else
    -- print(io.open(filenamePath,"w")) --wbertro: for debug
    filehandle = assert(io.open(filenamePath,"w"),"io.open: Cannot open file to write: "..filenamePath)
  end
  return filehandle
end

--***************************************************************************************************
function LoadFileData(filenamePath,binary)
  local data = ""
  local filehandle = nil
  if IsFileExist(filenamePath) then
    if binary == "b" then
      filehandle = assert(io.open(filenamePath,"rb"),"io.open: Cannot open binary file to load: "..filenamePath)
    else
      filehandle = assert(io.open(filenamePath,"r"),"io.open: Cannot open file to load: "..filenamePath)
    end
    data = assert(filehandle:read("a"),"read: cannot read file: "..filenamePath)
    if filehandle ~= nil then
      filehandle:close()
    end
  end
  return data
end

--***************************************************************************************************
function ParseTextFileIntoTable(filenamePath)
  local msg = ""
  local LineTable = {}
  if IsFileExist(filenamePath) then
    local filehandle = assert(io.open(filenamePath,"r"),"io.open: Cannot open file to parse: "..filenamePath)
    local line = filehandle:read("l")
    while line ~= nil do 
      table.insert(LineTable, line) 
      line = filehandle:read("l")
    end
    filehandle:close()
  else
    msg = "ERROR"
  end
  return LineTable,msg
end

--***************************************************************************************************
function ConvertLineTableToText(LineTable)
	return table.concat(LineTable, "\n")
end

--***************************************************************************************************
function CopyFile(src,dest)
  local cmd = [[cmd /c xcopy /y /h /v /i "]]..src..[[" "]]..dest..[[*" 1>NUL 2>NUL]]
  return NewThread(cmd)
end

--***************************************************************************************************
function MoveFileDirectory(src,dest)
  local success,errmsg = os.rename(src,dest)
  if success then
    if os.remove(src) == nil then
      print("Could not remove source file "..src)
    end
  else
    print("Could not move/rename file "..src.." to "..dest)
  end
  return success,errmsg
end

--***************************************************************************************************
function ListDir(DirList,path,StripPath,SubDir)
  if StripPath == nil then StripPath = false end
  if SubDir == nil then SubDir = false end
  
  if SubDir then StripPath = false end
  
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." then
      local f = path..[[\]]..file
      local attr = lfs.attributes(f)
      
      if attr.mode == "file" then
        if StripPath then
          DirList[#DirList+1] = file
        else
          DirList[#DirList+1] = f
        end
      end
      
      assert(type(attr) == "table")
      if SubDir and attr.mode == "directory" then
        ListDir(DirList,f,StripPath,SubDir)
      else
      end
    end
  end
  return DirList
end

--***************************************************************************************************
function mkdir(path)
  local sep, pStr = package.config:sub(1, 1), ""
  for dir in path:gmatch("[^" .. sep .. "]+") do
    pStr = pStr .. dir .. sep
    lfs.mkdir(pStr)
  end
end

--does not work
-- function RemoveDirectory(path)
  -- --***************************************************************************************************
  -- local function removedir(path)
    -- local iter, dir_obj = lfs.dir(path)
    -- while true do
      -- local dir = iter(dir_obj)
      -- if dir == nil then
        -- print("break")
        -- break
      -- end
      -- print(dir)
      -- if dir ~= "." and dir ~= "..." then
        -- local CurDir = path..dir
        -- print("["..CurDir.."]")
        -- local mode = lfs.attributes(CurDir, "mode")
        -- print("mode = "..mode)
        -- if mode == "Directory" then
          -- print("Recursive call...")
          -- removedir(CurDir.."/")
        -- elseif mode == "File" then
          -- print("os.remove...")
          -- os.remove(CurDir)
        -- end
      -- end
    -- end
    -- print("Out of while loop")
    -- local succ, des = os.remove(path)
    -- if des then
      -- print("From os.remove(path): "..des)
    -- end
    -- return succ
  -- end
  -- --***************************************************************************************************
    
  -- return removedir(path)
-- end

--***************************************************************************************************
do
  --To retrieve a table from a text file
  function table.load( sfile )
    local ftables,err = loadfile( sfile )
    if err then return _,err end
    local tables = ftables()
    for idx = 1,#tables do
       local tolinki = {}
       for i,v in pairs( tables[idx] ) do
          if type( v ) == "table" then
            tables[idx][i] = tables[v[1]]
          end
          if type( i ) == "table" and tables[i[1]] then
            table.insert( tolinki,{ i,tables[i[1]] } )
          end
       end
       -- link indices
       for _,v in ipairs( tolinki ) do
          tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
       end
    end
    return tables[1]
  end

  local function basicSerialize(o)
    if type(o) == "number" then
      return tostring(o)
    else   -- assume it is a string
      return string.format("%q", o)
    end
    -- return string.format([["%s"]], o)
  end

  --To save a table to a text file
  function table.save(filename, value, saved)
    saved = saved or {}       -- initial value
    io.write(filename, " = ")
    if type(value) == "number" or type(value) == "string" then
      io.write(basicSerialize(value), "\n")
    elseif type(value) == "table" then
      if saved[value] then    -- value already saved?
        io.write(saved[value], "\n")  -- use its previous filename
      else
        saved[value] = filename   -- save filename for next time
        io.write("{}\n")     -- create a new table
        for k,v in pairs(value) do      -- save its fields
          local fieldfilename = string.format("%s[%s]", filename, basicSerialize(k))
          table.save(fieldfilename, v, saved)
        end
      end
    else
      error("cannot save a " .. type(value))
    end
  end
end

--***************************************************************************************************
function SaveTable(filename,MyTable,TableName)
  io.output(filename)
  local name = string.sub(filename,1,string.find(filename,".",1,true)-1)
  io.write(TableName)
  table.save(name, MyTable)
  io.close()
end

--***************************************************************************************************
-- serialize ~ by YellowAfterlife
-- https://yal.cc/lua-serializer/
-- Converts value back into according Lua presentation
-- Accepts strings, numbers, boolean values, and tables.
-- Table values are serialized recursively, so tables linking to themselves or
-- linking to other tables in "circles". Table indexes can be numbers, strings,
-- and boolean values.
-- Created under https://creativecommons.org/licenses/by-nc-sa/3.0/
-- Changes made by Wbertro:
  --padding reduced to '  '
  --adapted to 'understand' a AMUMSS script
function serializeObject(object,multiline,depth,name)
	depth = depth or 0
	if multiline == nil then multiline = true end
	local padding = string.rep('  ', depth) -- can use '\t' if printing to file
	local r = padding -- result string
	local NextLine = '\n'
  -- if depth == 0 then
    -- NextLine = ''
  -- end
  
  if name then -- should start from name
    -- enclose in brackets if not string or not a valid identifier
    -- thanks to Boolsheet from #love@irc.oftc.net for string pattern
    local test1 = (type(name) ~= 'string' or name:find('^([%a_][%w_]*)$') == nil)
    local test2 = ( (type(name) == 'string') and string.format('%q', name) or tostring(name) )
    local test3 = ( test1 and ('['..test2..']') or tostring(name) )
    prefix = ""
    suffix = ""
    if depth ~= 0 then
      prefix = "[\""
      suffix = "\"]"
    end
		r = r..prefix..test3..suffix..' = '
    NextLine = ''
    if depth == 0 then
      --only on first run
      NextLine = '\n'
    end
	end
	
  if type(object) == 'table' then --we need to go into that table
    if depth == 0 then
      --only on first run
      r = r..(multiline and '\n' or '')..'{'..(multiline and NextLine or '')
    else
      r = r..(multiline and '\n' or '')..padding..'{'..(multiline and '\n' or ' ')
		end
    
    local length = 0
    for i, v in ipairs(object) do
			r = r..serializeObject(v, multiline, multiline and (depth + 1) or 0)..','..(multiline and '\n' or ' ')
			length = i
		end
		
    for i, v in pairs(object) do
			local itype = type(i) -- convert type into something easier to compare:
			itype =(itype == 'number')  and 1
          or (itype == 'string')  and 2
          or (itype == 'boolean') and 3
          or error('Unsupported index type "' .. itype .. '"')
          
			-- detect if item should be skipped
      local test4 = ( (itype == 1) and (i%1 == 0) and (i >= 1) and (i <= length) ) -- ipairs part
      local test5 = ( (itype == 2) and (string.sub(i, 1, 1) == '_') ) -- prefixed string
      local skip = test4 or test5
			if not skip then
				r = r ..serializeObject(v, multiline, multiline and (depth + 1) or 0, i)..','..(multiline and '\n' or ' ')
			end
		end
		
    r = r..(multiline and padding or '')..'}'
	
  elseif type(object) == 'string' then
		-- r = r .. string.format('%q', object)
    if string.find(object,"\n",1,true) == nil then
      r = r..[["]]..object..[["]] --puts "" around values
    else
		r = r .."[["..object.."]]" --puts [[]] around long string
    end
	
  elseif type(object) == 'number' or type(object) == 'boolean' then
		r = r..tostring(object) --writes a number or a boolean
	
  elseif object == nil then
		r = r..[[nil]]
	
  else
		error('Unserializeable value "'..tostring(object)..'"')
	end
	
  return r --a string
end

--***************************************************************************************************
--**********  switch statement  *****************************************************************************************
--https://gist.github.com/FreeBirdLjj/6303864
--see also: http://lua-users.org/wiki/SwitchStatement

  -- --USAGE EXAMPLE
  -- --***************************************************************************************************
  -- local param = "My".."junk" --tostring(true)
  -- print("param = ["..param.."]")
  -- switch(param,{["Mytrue"] = function() print("[IsPrecedingKeyWords is True]") end,
                -- ["Myfalse"] = function() print("[IsPrecedingKeyWords is False]") end,
                -- [1] = function() print("[This is One]") end,
                -- [4] = function() print("[This is Four]") end,
                -- ["default"] = function() print("default junk") end,})
    
    -- --output:
    -- --  param = [Myjunk]
    -- --  default junk

  -- local param = 4
  -- print("param = ["..param.."]")
  -- switch(param,{["Mytrue"] = function() print("[IsPrecedingKeyWords is True]") end,
                -- ["Myfalse"] = function() print("[IsPrecedingKeyWords is False]") end,
                -- [1] = function() print("[This is One]") end,
                -- [4] = function() print("[This is Four]") end,
                -- ["default"] = function() print("default junk") end,})
    
    -- --output:
    -- --  param = 4
    -- --  [This is Four]
  -- --***************************************************************************************************  

--this becomes a new lua 'Basic function'
_G.switch = function(param, case_table)
    local case = case_table[param]
    -- print("case = "..tostring(case))
    if case then return case() end
    local def = case_table['default']
    -- print("def = "..tostring(def))
    return def and def() or nil
end
--**********  END: switch statement  *****************************************************************************************

--***************************************************************************************************
function iif(test, true_part, false_part)
  if (test) then
    return true_part
  else
    return false_part
  end
end

--***************************************************************************************************
function Round(number)
  return math.floor(number+0.5)
end

--***************************************************************************************************
local function math_sign(v)
	return (v >= 0 and 1) or -1
end

--***************************************************************************************************
local function math_round(v, multi)
	multi = multi or 1
	return math.floor((v/multi) + (math_sign(v) * 0.5)) * multi
end

--***************************************************************************************************
function string.round(value)
  local dotPosition = string.find(value,".",1,true)
  if dotPosition == nil then return value end
  local afterDotString  = string.sub(value,dotPosition+1)
  if string.find(afterDotString,"0000",1,true) or string.find(afterDotString,"9999",1,true) then
    value = tostring(math_round(tonumber(value),0.001))
  end
  return value
end

--***************************************************************************************************
-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
-- modified
function trim(s)
  -- using local r:
  -- to force the return of only first arg of string.gsub
  -- if used with table.insert: it will confuse it when the second arg is returned
  -- from PiL2 20.4
  local r = string.gsub(s,"^%s*(.-)%s*$", "%1")
  return r
end

--***************************************************************************************************
-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
-- modified
function rtrim(s)
  -- using local r:
  -- to force the return of only first arg of string.gsub
  -- if used with table.insert: it will confuse it when the second arg is returned
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  local r = s:sub(1, n)
  return r
end

--***************************************************************************************************
-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
-- modified
function ltrim(s)
  -- using local r:
  -- to force the return of only first arg of string.gsub
  -- if used with table.insert: it will confuse it when the second arg is returned
  local r = s:gsub("^%s*", "")
  return r
end

--***************************************************************************************************
-- function ReverseOrder(s)
  -- local result = ""
  -- for i=#s,4,-4 do
    -- local byte = string.sub(s,i-3,i)
    -- result = result..byte
  -- end
  -- return result
-- end

--***************************************************************************************************
-- function HexToString(str)
    -- return (string.gsub(str,'..', function (cc)
        -- return string.char(tonumber(cc, 16))
    -- end))
-- end

--***************************************************************************************************
-- function StringToHex(str)
    -- return (string.gsub(str,'.', function (c)
        -- return string.format('%02X', string.byte(c))
    -- end))
-- end

--***************************************************************************************************
-- function bytes_to_int(str,endian,signed) -- use length of string to determine 8,16,32,64 bits
    -- local t={string.byte(str,1,-1)}
    -- if endian=="big" then --reverse bytes
        -- local tt={}
        -- for k=1,#t do
            -- tt[#t-k+1]=t[k]
        -- end
        -- t=tt
    -- end
    -- local n=0
    -- for k=1,#t do
        -- n=n+t[k]*2^((k-1)*8)
    -- end
    -- if signed then
        -- n = (n > 2^(#t*8-1) -1) and (n - 2^(#t*8)) or n -- if last bit set, negative.
    -- end
    -- return n
-- end

--***************************************************************************************************
-- function int_to_bytes(num,endian,signed)
    -- if num<0 and not signed then num=-num print"warning, dropping sign from number converting to unsigned" end
    -- local res={}
    -- local n = math.ceil(select(2,math.frexp(num))/8) -- number of bytes to be used.
    -- if signed and num < 0 then
        -- num = num + 2^n
    -- end
    -- for k=n,1,-1 do -- 256 = 2^8 bits per char.
        -- local mul=2^(8*(k-1))
        -- res[k]=math.floor(num/mul)
        -- num=num-res[k]*mul
    -- end
    -- assert(num==0)
    -- if endian == "big" then
        -- local t={}
        -- for k=1,n do
            -- t[k]=res[n-k+1]
        -- end
        -- res=t
    -- end
    -- return string.char(unpack(res))
-- end

--***************************************************************************************************
function StripInfo(Info,cut1,cut2)
  --if Info == nil then return nil end
  if type(Info) == "number" then Info = tostring(Info) end
  local _,stop = string.find(Info,cut1,1,true)
  if stop==nil then return Info end
  local result = string.sub(Info,stop+1)
  if cut2~=nil then
    local start = string.find(result,cut2,1,true)
    if start==nil then return Info end
    result = string.sub(result,1,start-1)
  end
  return result
end

--***************************************************************************************************
function StripPath(filename,cutter)
  local start,stop = string.find(filename,cutter,1,true)
  local result = string.sub(filename,stop+1)
  return result
end

--***************************************************************************************************
CurrentKeyWordsAndAll = {}

do
  local seen={}
  function GetLuaCurrentKeyWordsAndAll(t,tab,AllInfo,parent)
    seen[t]=true
    local s={}
    local n=0
    for k in pairs(t) do
      n=n+1
      s[n]=k
    end
    table.sort(s)

    for k,v in ipairs(s) do
      if AllInfo then
        parent = parent or ""
        print("["..parent..v.."]")
      else
        print("["..v.."]")
      end
      table.insert(CurrentKeyWordsAndAll,v)
      local possibleParent = v
      v=t[v]
      if type(v)=="table" and not seen[v] then
        if AllInfo then
          -- if parent == "" then
            parent = possibleParent.."."
          -- end
          GetLuaCurrentKeyWordsAndAll(v,tab.."\t",AllInfo,parent)
          parent = ""
        end
      end
    end
  end
end

--***************************************************************************************************
--function Report(msg,Info,msgType) --TODO: maybe change order
function Report(Info,msg,msgType)
  -- the order is: msgType..msg..Info
  -- msgType default is (0 spaces)[INFO], otherwise it is (4 spaces)[msgType]
  -- Info will appear inside [], any space before the first letter is transferred in front of the []
  -- msg will appear without change
  
  if Info == nil then return end
  if Info == "" and msg == nil then
    msgType = "" --to force a blank line to output
  end
  if msg == nil then msg = "" end

  if msgType == nil then
--    msgType = "[INFO] "
    msgType = ""
  elseif msgType ~= "" then
    msgType = "    ["..msgType.."] "
  end
  
  local FileName = ""
  if gReport_ext ~= nil then
    FileName = "-"..gReport_ext
  end
  
  local chain = "" --derived from Info
  local say = "" --final complete message
  if type(Info) == "table" then
    for z=1,#Info do
      chain = chain..Info[z]..[[, ]]
    end		
  elseif type(Info) == "string" then
    chain = Info
  elseif type(Info) == "boolean" then
    if Info then
      chain = "true"
    else
      chain = "false"
    end
  else
    chain = "???"
    say = "ERROR: in Report(): type(Info) is "..type(Info)
    print(say)
  end
  if chain ~= "" then
    local spacer = string.match(chain,"^%s*")
    if spacer == nil then spacer = "" end
    chain = " "..spacer.."["..trim(chain).."]"
  end
  -- if msg ~= "" then
    -- msg = " "..msg
  -- end
  say = msgType..msg..chain
  -- print("***** "..say.." *****")

  -- if gfilePATH == "..\\" and FileName == "" then
    -- -- this is the standard REPORT.lua file
    -- if gReportFilehandle == nil then
      -- gReportFilehandle = io.open(gfilePATH.."REPORT"..FileName..".txt","a+")
    -- end
    
    -- gReportFilehandle:write([[.]]..say.."\n")
    -- -- gReportFilehandle:flush()
    
  -- else
    WriteToFileAppend(say.."\n", gfilePATH.."REPORT"..FileName..".lua")
  -- end
end

--***************************************************************************************************
function ShowTime(Time)
  return os.date("%H:%M:%S",Time)
end

--***************************************************************************************************
function NormalizePath(path)
  if path == nil then return path end
  path = string.gsub(path,[[/]],[[\]])
  path = string.gsub(path,[[\\]],[[\]])
  return string.upper(path)
end

--***************************************************************************************************
function FolderExists(path)
  local result = false
  path = string.gsub(path,[[/]],[[\]])
  if string.sub(path,#path-1) == [[\]] then
    path = string.sub(path,1,-2)
  end
  -- print(">>> "..path)
  if lfs.attributes(path,'mode') == "directory" then
    result = true
  end
  return result  
end

--***************************************************************************************************
function CreateFolder(path)
  local cmd = [[cmd /c mkdir ]]..[["]]..path..[["]]
  return NewThread(cmd)
end

--***************************************************************************************************
function getPath(str)
  -- return str:gsub('\\','/'):match('.*/')
  return str:gsub([[/]],[[\]]):match([[.*\]])
end

--***************************************************************************************************
function GetFilenameFromFilePath(pathname)
  NormalizePath(pathname)
  return pathname:match([[^.+\(.+)$]])
end

--***************************************************************************************************
function GetFolderPathFromFilePath(filePathAndName)
	assert(filePathAndName ~= nil)
  filePathAndName = string.gsub(filePathAndName,[[/]],[[\]])
  local _,count = string.gsub(filePathAndName,[[\]],"")
	if count == 0 then
    return ""
	elseif count == 1 then
    return string.sub(filePathAndName,1,string.find(filePathAndName,[[\]]) - 1)
  end
	local temp1 = string.gsub(filePathAndName,[[\]],"X_TEMP_X",count-1)
	local temp2 = string.sub(temp1,1,string.find(temp1,[[\]])-1)
	return string.gsub(temp2,"X_TEMP_X",[[\]])
end

--***************************************************************************************************
function TestNoNil(Info,...)
  local FoundNoNil = true
  local args = { n = select("#", ...), ... }
  for i=1,args.n do
    if args[i] == nil then
      print("BUG: "..Info..", arg["..i.."] is nil")
      FoundNoNil = false
    end
  end
  return FoundNoNil
end

--***************************************************************************************************
function boolToString(Bool)
  local s = "false"
  if Bool then s = "true" end
  return s
end

--***************************************************************************************************
function sleep(s)
  -- s==2 =>> 1 second delay
	if s==nil then s=1 end
  s = math.tointeger(s+1)
  --localhost was 127.0.0.1
  local command = [[PING -n ]]..s..[[ localhost>nul]]
	NewThread(command)
end

--***************************************************************************************************
function pause()
  io.stdin:flush()
  print("Press Enter to continue...")
  io.stdin:read([[*l]])
end

--***************************************************************************************************
do
  local path = ""
  local MasterPath = os.getenv("_bMASTER_FOLDER_PATH")
  if MasterPath ~= nil then
    path = MasterPath..[[MODBUILDER\]]
  end
  pv("LuaStarting path: ["..path.."]")
  function LuaStarting()
    pv("      +++++++++  LuaStarting  +++++++++")
    if os.remove(path..[[LuaEndedOk.txt]]) then
      pv("       LuaEndedOk.txt removed")
    end
  end

  function LuaEndedOk(Info)
    if Info == nil then Info = "" end
    pv("       --------  LuaEndedOk   -------- "..Info)
    WriteToFile("",path..[[LuaEndedOk.txt]])
  end

  if FlagLua == nil then
    LuaStarting()
  else
    pv("FlagLua used!")
  end
end

