
DebugInfo = '\n'
Diagnosis = '\n'
Explanation = '\n'
ResultString = ''

Device = {}
Device.Diag = {} -- Registered rights functions
Device.Bad = {} -- List of mailfunction types
Device.RegList = {} -- List of registered rights functions


Device.DEBUG = 1
Device.NOTDETECTED = 1


function AddExplanation(NewExplanation) Explanation = Explanation .. ' • ' .. NewExplanation .. '\n' end
function AddDebugInfo(NewDebugInfo) if Device.DEBUG then DebugInfo = DebugInfo .. NewDebugInfo .. '\n' end end

function IncludeChunk(FileName)	dofile(FileName) end
function IncludeParentLib(FileName)	dofile(LibFolder .. '/' .. FileName) end
function ProtectedLoad(FileName)
  Function, ErrorMessage = loadfile(FileName)
  if Function then 
    return pcall(Function) 
  else
    return false, ErrorMessage
  end
end

function RegFunction(FunctionName, LibInfo) 
	if Device.RegList[FunctionName] then
		AddDebugInfo('Loaded function ' .. FunctionName .. ' from library ' .. LibInfo .. ' function from ' .. Device.RegList[FunctionName] .. ' overloaded.')
		Device.RegList[FunctionName] = LibInfo
	else
		AddDebugInfo('Loaded function ' .. FunctionName .. ' from library ' .. LibInfo .. '.')
		Device.RegList[FunctionName] = LibInfo
	end
	return FunctionName
end

 -- Tags string deserialization.
for Key, Value in string.gmatch(QuickDiagResult,'([^\n:]+):([^\n]+)') do
	if Value == Value:match('%d+') then
		Device[Key] = tonumber(Value)
	else
		Device[Key] = Value
	end
	AddDebugInfo(Key .. '=>' .. Value)
end

if Device.STAGE_ERROR then return Device.STAGE_ERROR end

LibFolder = Device.BASE_DIR .. 'Scripts/lib'


-- Fill in the values of the derivate tags
-- Refining the model name
do
	if Device.PROFILE_TYPE == 'HDD_ATA' or Device.PROFILE_TYPE == 'SSD_ATA' then 
		Device.RMODEL =  string.match(Device.MODEL,'%w+%s+(%w+-*%w*)')
	end

	if not Device.RMODEL then Device.RMODEL = Device.MODEL end
end

Device.FAMILY_GEN = 'GNRCGEN'

-- Filling the code name of the product family
if Device.FAMILY_ID ~= 0 and not Device.FAMILY then

	if Device.MFGBRAND == 'SAMSUNG' then
	
		IncludeChunk('Scripts/lib/table_Family2ID_SAMSUNG.lua')
		for Family, ID in pairs(Family2ID) do

			if ID == Device.FAMILY_ID then 
				Device.FAMILY = Family
				break
			end
		end
		
	elseif Device.MFGBRAND == 'HGST' then

		IncludeChunk('Scripts/lib/table_Family2ID_HGST.lua')
		for Family, ID in pairs(Family2ID) do

			if ID == Device.FAMILY_ID then 
				Device.FAMILY = Family
				break
			end
		end
		
	elseif Device.MFGBRAND == 'WDC' then

		Device.FAMILY = 'F' .. Device.FAMILY_ID
			
	elseif Device.MFGBRAND == 'SEAGATE' then

		Device.FAMILY = 'F' .. Device.FAMILY_ID
		
	else end	

elseif Device.FAMILY_ID == 0 and not Device.FAMILY then	
	Device.FAMILY = 'GNRCFAMILY'
else 
	ResultString = ResultString .. 'Something wrong with the family definition'
	return ResultString
end

-- If Debug is enabled then send  additional info to output
AddDebugInfo('RMODEL=>' .. Device.RMODEL)
AddDebugInfo('FAMILY=>' .. Device.FAMILY)
AddDebugInfo('FAMILY_GEN=>' .. Device.FAMILY_GEN)

-- Splitting string of smart attributes for ATA devices
if Device.PROFILE_TYPE == 'HDD_ATA' or Device.PROFILE_TYPE == 'SSD_ATA' then 
	for Key, Value in pairs(Device) do
		local SMART_ID = string.match(Key,'^ATTR_(%d+)$')
		if SMART_ID then
			Device['ATTR' .. SMART_ID] = {}
			Device['ATTR' .. SMART_ID].type, Device['ATTR' .. SMART_ID].value, Device['ATTR' .. SMART_ID].worst, Device['ATTR' .. SMART_ID].threshold, Device['ATTR' .. SMART_ID].raw = string.match(Value,'^(%d+),(%d+),(%d+),(%d+),(.+)$')
		end
	end
end

--  Search and load an appropriate library
do
	function LibExists(LibName)
		local FileName = LibFolder .. '/' .. LibName .. '.lua'
		local f=io.open(FileName,"r")
		if f~=nil then io.close(f) return FileName else return false end
	end

	LibFileName = LibExists(Device.PROFILE_TYPE .. '_' .. Device.MFGBRAND  .. '_' .. Device.RMODEL .. '_' .. Device.FWVER) 
				or LibExists(Device.PROFILE_TYPE .. '_' .. Device.MFGBRAND  .. '_' .. Device.RMODEL) 
--				or LibExists(Device.PROFILE_TYPE .. '_' .. Device.MFGBRAND  .. '_' .. Device.FAMILY) 
				or LibExists(Device.PROFILE_TYPE .. '_' .. Device.MFGBRAND) 
				or LibExists(Device.PROFILE_TYPE)
				
	if not LibFileName then 
		ResultString = 'Can\'t found any lib file for this device.\n\n' .. ResultString
		return ResultString 
	else 
		if Device.DEBUG then ResultString = 'Loaded library file ' .. LibFileName .. '\n' .. ResultString  end
	end
end

Success, ErrorMessage = ProtectedLoad(LibFileName)

-- Perform diagnostic functions

if Success then
	for DiagRuleName in pairs(Device.Diag) do 
		Success, ErrorMessage = pcall(Device.Diag[DiagRuleName])
		if Success then
			AddDebugInfo('Run ' .. DiagRuleName .. ' function from library '.. Device.RegList[DiagRuleName] .. '.')
		else 
			return 'Error in the function ' ..  DiagRuleName .. ' from library '.. Device.RegList[DiagRuleName] .. ':\n' .. ErrorMessage .. '\n\n' .. ResultString .. DebugInfo
		end
	end
else
    return ErrorMessage .. '\n\n' .. ResultString .. DebugInfo
end

-- Calling methods, which describe malfunctions

for DiagResultName in pairs(Device.Bad) do
	local Verdict = Device.Bad[DiagResultName]:Verdict()
	if Verdict then Diagnosis = Diagnosis .. Verdict end
end

ResultString = ResultString .. Diagnosis .. '\n<===<EXPLANATION>===>' .. Explanation
if Device.DEBUG then ResultString = '***DEBUG MODE***\n' .. ResultString .. '\n###DEBUG INFO###\n' .. DebugInfo end
return ResultString

