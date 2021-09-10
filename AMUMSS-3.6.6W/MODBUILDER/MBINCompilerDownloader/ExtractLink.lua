function GetURL()
	local URL = ""
	local line = ""
  local filehandle = assert(io.open("temp.txt", "r"),"io.open: Cannot open temp.txt to load")
	for i=1,2000 do
		line = filehandle:read("l")
		if line ~= nil then 
			--WriteToFile("test","templua.txt")		
			if string.find(line, "MBINCompiler.exe") then				
				local start_pos = string.find(line,'"')
				if start_pos ~= nil then 
					local end_pos   = string.find(line," rel=",start_pos)
					local exstring = string.sub(line,start_pos+1,end_pos-2)
					URL = "https://github.com" .. exstring
				end	
        filehandle:close()
				writeToFile(URL,"temp.txt")
				break
			end
		end
	end
end

function writeToFile(output, file)
  local filehandle = assert(io.open(file, "w"),"io.open: Cannot open temp.txt to write")
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

GetURL()

