--[[
The Library module containing functions used by R.tester scripts.

Version 07.03.2016
--]]



local rl = {}

-- Just test function
function rl.Zombie(str)
  local resultStr = '     (x(x_(X_x(O_o)x_x)_X)x)\n'
  if str then resultStr = str .. resultStr end
  return resultStr
end

-- For the testing and debugging needs
function rl.TmpOut(...)
	local str = '\n\n\n\n\n'
	local arg = {...}
	local n = select('#',...)
	for i = 1, n do
		v = tostring(arg[i])
		str = str .. i .. ' ==> ' .. v .. '\n'
	end
	resultStr = str .. '\n\n\n\n\n' .. resultStr
end

function rl.TmpOutRaw(...)
	local str = ''
	local arg = {...}
	local n = select('#',...)
	for i = 1, n do
		v = tostring(arg[i])
		str = str .. v
	end
	resultStr = str .. resultStr
end

function rl.Plural(singular, plural, nomber)
	if nomber == 1 then
		return singular
	else 
		return plural
	end
end

function rl.Date()
  return os.date('%d.%m.%Y %X')
end


function rl.CreateDebugLogFunc(fileName)
	if device.DEBUG then
		if pcall(function(file) io.output(file) end, fileName) then
			io.write (rl.Date() .. ' DEBUG OUT ==> ' .. fileName .. '\n\n')
			return function(str) io.write (str .. '\n') end
		else
			return function() return false end
		end
	else
		return function() return true end
	end
end

-- Check if file exists
function rl.FileExists(fileName)
	local f=io.open(fileName,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end

-- Localization function
function rl.Loc(str)
	if device.LANG == 'EN' then return str end
	if not device.LANG then return 'ERROR when using the "rl.Loc" localization function. "device.LANG" variable must be set before using this function.' end
	if not libFolder then return 'ERROR when using the "rl.Loc" localization function. "LibFolder" variable must be set before using this function.' end
	rl.IncludeOnce(libFolder .. 'loc_' .. device.LANG .. '.lua')
	if locTable[str] then
		return locTable[str]
	else 
		return str
	end
end


-- Set of functions to load chunks of code for different purposes

function rl.IncludeChunk(fileName)	
	dofile(fileName) 
end

function rl.AddIncludeOnceFunction()
	local IncludeOnceFileList = {}
	return function(fileName)	
		if not IncludeOnceFileList[fileName] then 
			IncludeOnceFileList[fileName] = true
			dofile(fileName)
		end
	end
end
rl.IncludeOnce = rl.AddIncludeOnceFunction()

function rl.ProtectedLoad(fileName)
  Function, errorMessage = loadfile(fileName)
  if Function then 
    return pcall(Function) 
  else
    return false, errorMessage
  end
end

-- Returns a table containing all the data from the .ini file or returns nil and error message.
function rl.IniLoad(fileName)
	local file, errorMessage = io.open(fileName, 'r')
	if not file then return nil, errorMessage end
	local data = {}
	local section
	for line in file:lines() do
		local tmpSection = line:match('^%s*%[([^%[%]]+)%]%s*$')
		if tmpSection then
			section = tmpSection
			data[section] = data[section] or {}
		end
    if section then
      local param, value = Line:match('^%s*([%w|_]*%s*[%w|_]+)%s*=%s*(.+)%s*$')
      if param and value ~= nil then
        if tonumber(value) then value = tonumber(value)
        elseif value == 'true'  then value = true
        elseif value == 'false' then value = false
        end
        Data[section][param] = value
      end
    end
	end
	file:close()
	return data
end


-- Returns the value of the requested parameter of the requested section from the .ini file. Or returns nil and error message.
function rl.IniVal(fileName, reqSection, reqParam)
	local file, errorMessage = io.open(fileName, 'r')
	if not file then return nil, errorMessage end
	local sectionFound
  
	for Line in file:lines() do
		local tmpSection = Line:match('^%s*%[([^%[%]]+)%]%s*$')
		if tmpSection then
		sectionFound = tmpSection
		end
    if sectionFound == reqSection then
      local value = Line:match('^%s*' .. reqParam .. '%s*=%s*(.+)%s*$')
      if value then
        if tonumber(value) then value = tonumber(value)
        elseif value == 'true'  then value = true
        elseif value == 'false' then value = false
        end
        file:close()
        return value
      end
    end
	end
	file:close()
	return nil, 'The requested parameter is not found.'
end


-- Sorts the contents of the table by a key
function rl.Pairs(t)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a)
		local i = 0 
		local Iter = function ()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return Iter
end

return rl