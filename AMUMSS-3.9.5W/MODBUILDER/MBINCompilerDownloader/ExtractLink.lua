function GetURL()
	local URL = ""
	local line = ""
  local filehandle = assert(io.open("RAW.txt", "r"),"io.open: Cannot open RAW.txt to load")
	
  local compilerCount = 0

  local latest_release = false
  
  for i=1,2000 do
		line = filehandle:read("l")
		if line ~= nil then
      if string.find(line, ">Latest release<") then
        latest_release = true
      end
    
			if string.find(line, "/monkeyman192/MBINCompiler/releases/download/") and string.find(line, "MBINCompiler.exe") then				
				compilerCount = compilerCount + 1
        local start_pos = string.find(line,'"')
				if start_pos ~= nil then 
					local end_pos   = string.find(line," rel=",start_pos)
					if end_pos ~= nil then
            local exstring = string.sub(line,start_pos+1,end_pos-2)
            URL = "https://github.com" .. exstring
          end
				end	
				
        if compilerCount == 1 then
          writeToFile(URL,"temp1.txt")
          if latest_release then
            writeToFile(URL,"temp2.txt")
            break
          end
          
        elseif latest_release then
          writeToFile(URL,"temp2.txt")
          break
        end
        
			end
		end
	end
  
  filehandle:close()
end

function writeToFile(output, file)
  local filehandle = assert(io.open(file, "w"),"io.open: Cannot open tempX.txt to write")
  if filehandle ~= nil then
    filehandle:write(output)
    filehandle:flush()
    filehandle:close()
  end
end

if gVerbose == nil then dofile("..\\LoadHelpers.lua") end
GetURL()

