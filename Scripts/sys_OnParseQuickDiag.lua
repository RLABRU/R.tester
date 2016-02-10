
rl = require('rl')

DebugInfo = ''
Diagnosis = '\n'
Explanation = '\n'
Warning = '\n'
ResultString = ''

Device = {}
Device.Diag = {} -- Registered rights functions
Device.Bad = {} -- List of mailfunction types
Device.RegList = {} -- List of registered rights functions

function AddExplanation(NewExplanation) Explanation = Explanation .. ' • ' .. rl.Loc(NewExplanation) .. '\n' end

function AddWarning(NewWarning) Warning = Warning .. ' ! ' .. rl.Loc(NewWarning) .. '\n' end

function AddDebugInfo(NewDebugInfo) 
	if Device.DEBUG then 
		if NewDebugInfo then
			DebugInfo = DebugInfo .. NewDebugInfo .. '\n'
		else
			DebugInfo = DebugInfo .. '\n'
		end
	end 
end

function IncludeParentLib(FileName)	dofile(LibFolder .. FileName) end

-- Diagnostic functions registration
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

-- SCSI errors decoding
function SCSISenseDecode(ErrCode)
	local KeySense
	local CodeSense
	if not ErrCode then return nil, 'ErrCod is nil' end
	if ErrCode ~= '00000000' then
		rl.IncludeOnce(LibFolder .. 'table_FakeSense.lua')
		if FakeSense[ErrCode] then 
			return FakeSense[ErrCode]
		else
			local Key, Code, Qualifier, FRU = string.match(ErrCode, '(%w%w)(%w%w)(%w%w)(%w%w)')
			if Code then
				rl.IncludeOnce(LibFolder .. 'table_SCSISense.lua')
				KeySense = SCSISense[Key]
				if not KeySense then return nil, 'Can\'t found sense key in SCSISense table' end
			
				CodeSense, ErrorMessage = rl.IniVal(Device.BASE_DIR .. 'SCSI_Err.ini', 'SENSE', Code .. Qualifier)
				if not CodeSense then return nil, ErrorMessage end
			else return nil, 'Can\'t parse SenseCode.' end
		end
	else return 'No SCSI errors.' end
	
	return KeySense .. '    ' .. CodeSense
end

-- GO!!! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 -- Tags string deserialization.
for Key, Value in string.gmatch(QuickDiagResult,'([^\n:]+):([^\n]+)') do
	if Value == Value:match('%d+') then
		Device[Key] = tonumber(Value)
	else
		Device[Key] = Value
	end
end

AddDebugInfo(QuickDiagResult)

if Device.STAGE_ERROR then return Device.STAGE_ERROR end

LibFolder = Device.BASE_DIR .. 'Scripts/lib/'


-- Fill in the values of the derivate tags ======================================================================================

-- Refining the model name
do
	if Device.PROFILE_TYPE == 'HDD_ATA' or Device.PROFILE_TYPE == 'SSD_ATA' then 
		Device.RMODEL =  string.match(Device.MODEL,'%w+%s+(%w+-*%w*)')
	end

	if not Device.RMODEL then Device.RMODEL = Device.MODEL end
end

Device.FAMILY_GEN = 'GNRC'

-- Filling the code name of the product family
if Device.FAMILY_ID ~= 0 and not Device.FAMILY then

	if Device.MFGBRAND == 'SAMSUNG' then
	
		rl.IncludeChunk('Scripts/lib/table_Family2ID_SAMSUNG.lua')
		for Family, ID in pairs(Family2ID) do

			if ID == Device.FAMILY_ID then 
				Device.FAMILY = Family
				break
			end
		end
		
	elseif Device.MFGBRAND == 'HGST' then

		rl.IncludeChunk('Scripts/lib/table_Family2ID_HGST.lua')
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
	Device.FAMILY = 'GNRC'
else 
	ResultString = ResultString .. 'Something wrong with the family definition'
	return ResultString
end

-- If Debug is enabled then send  additional info to output
AddDebugInfo('RMODEL=>' .. Device.RMODEL)
AddDebugInfo('FAMILY=>' .. Device.FAMILY)
AddDebugInfo('FAMILY_GEN=>' .. Device.FAMILY_GEN)

-- preliminary cooking of the tag contents ==================================================================================================================

-- Splitting string of SMART attributes for ATA devices-------------------------------------------------------------------------------------------------------------------------------------------
if Device.PROFILE_TYPE == 'HDD_ATA' or Device.PROFILE_TYPE == 'SSD_ATA' then 
	for Key, Value in pairs(Device) do
		local SMART_ID = string.match(Key,'^ATTR_(%d+)$')
		if SMART_ID then
			Device['Attr' .. SMART_ID] = {}
			Device['Attr' .. SMART_ID].Type, Device['Attr' .. SMART_ID].Value, Device['Attr' .. SMART_ID].Worst, Device['Attr' .. SMART_ID].Threshold, Device['Attr' .. SMART_ID].Raw1, Device['Attr' .. SMART_ID].Raw2, Device['Attr' .. SMART_ID].Raw3 = string.match(Value,'^(%d+),(%d+),(%d+),(%d+),(%d+)/*(%d*)/*(%d*)$')
			for Type, AttrValue in pairs(Device['Attr' .. SMART_ID]) do
				if AttrValue and AttrValue ~= '' then
					Device['Attr' .. SMART_ID][Type] = tonumber(AttrValue)
				end
			end
		end
	end
end

-- Splitting of read test results-----------------------------------------------------------------------------------------------------------------------------------------------------------------

if Device.TEST_RANDOM_SEEK then
	Device.TestRandomSeek = {}
	Device.TestRandomSeek.Status, Device.TestRandomSeek.StartLBA, Device.TestRandomSeek.StopLBA, Device.TestRandomSeek.LastLBA, Device.TestRandomSeek.SeekCount, Device.TestRandomSeek.SeekDone, Device.TestRandomSeek.ErrCode, Device.TestRandomSeek.CmdTimeMin, Device.TestRandomSeek.CmdTimeMax, Device.TestRandomSeek.CmdTimeAvg = string.match(Device.TEST_RANDOM_SEEK,'^(%w+),(%d+),(%d+),(%-?%d+),(%d+),(%d+),(%w+),(%d+),(%d+),(%d+)$')
	if Device.TestRandomSeek.Status then 
		tonumber(Device.TestRandomSeek.StartLBA); tonumber(Device.TestRandomSeek.StopLBA); tonumber(Device.TestRandomSeek.LastLBA); tonumber(Device.TestRandomSeek.SeekCount); tonumber(Device.TestRandomSeek.SeekDone); tonumber(Device.TestRandomSeek.CmdTimeMin); tonumber(Device.TestRandomSeek.CmdTimeMax); tonumber(Device.TestRandomSeek.CmdTimeAvg)
	end	
	if Device.DEBUG then
		AddDebugInfo('\nRandomSeek test results in expanded form:')
		for Key, Value in rl.Pairs(Device.TestRandomSeek) do
			AddDebugInfo('TestRandomSeek.' .. Key .. ' = ' .. Value)
		end
		local SCSISenseInfo, ErrorMessage = SCSISenseDecode(Device.TestRandomSeek.ErrCode)
		if SCSISenseInfo then AddDebugInfo('Last SCSI Sense code decoding:   ' .. SCSISenseInfo)
		else AddDebugInfo('ERROR during last error code decoding:   ' .. ErrorMessage) end
	end
end

if Device.TEST_RANDOM_READ then
	Device.TestRandomRead = {}
	Device.TestRandomRead.Status, Device.TestRandomRead.StartLBA, Device.TestRandomRead.StopLBA, Device.TestRandomRead.LastLBA, Device.TestRandomRead.BlockSize, Device.TestRandomRead.ReadsCount, Device.TestRandomRead.ReadsDone, Device.TestRandomRead.ErrCode, Device.TestRandomRead.CmdTime, Device.TestRandomRead.TestTimeMin, Device.TestRandomRead.TestTimeMax, Device.TestRandomRead.TestTimeAvg = string.match(Device.TEST_RANDOM_READ,'^(%w+),(%d+),(%d+),(%-?%d+),(%d+),(%d+),(%d+),(%w+),(%d+),(%d+),(%d+),(%d+)$')
	if Device.TestRandomRead.Status then 
		tonumber(Device.TestRandomRead.StartLBA); tonumber(Device.TestRandomRead.StopLBA); tonumber(Device.TestRandomRead.LastLBA); tonumber(Device.TestRandomRead.BlockSize); tonumber(Device.TestRandomRead.ReadsCount); tonumber(Device.TestRandomRead.ReadsDone); tonumber(Device.TestRandomRead.CmdTime); tonumber(Device.TestRandomRead.TestTimeMin); tonumber(Device.TestRandomRead.TestTimeMax); tonumber(Device.TestRandomRead.TestTimeAvg)
	end
	if Device.DEBUG then
		AddDebugInfo('\nRandomRead test results in expanded form:')
		for Key, Value in rl.Pairs(Device.TestRandomRead) do
			AddDebugInfo('TestRandomRead ' .. Key .. ' = ' .. Value)
		end
		local SCSISenseInfo, ErrorMessage = SCSISenseDecode(Device.TestRandomRead.ErrCode)
		if SCSISenseInfo then AddDebugInfo('Last SCSI Sense code decoding:   ' .. SCSISenseInfo)
		else AddDebugInfo('ERROR during last error code decoding:   ' .. ErrorMessage) end
	end
end

function DDDSplit(TestName, TagVal)
	if TagVal then
		local Table = {}
		Table.Status, Table.StartLBA, Table.StopLBA, Table.BlockSize, Table.ErrCount, Table.ErrCode, Table.TestTime = string.match(TagVal,'^(%w+),(%d+),(%d+),(%d+),(%d+),(%w+),(%d+)$')
		if Table.Status then 
			tonumber(Table.StartLBA); tonumber(Table.StopLBA); tonumber(Table.BlockSize); tonumber(Table.ErrCount); tonumber(Table.TestTime)
		end
		if Device.DEBUG then
			AddDebugInfo('\n' .. TestName ..' test results in expanded form:')
			for Key, Value in rl.Pairs(Table) do
				AddDebugInfo(TestName .. ' ' .. Key .. ' = ' .. Value)
			end
			local SCSISenseInfo, ErrorMessage = SCSISenseDecode(Table.ErrCode)
			if SCSISenseInfo then AddDebugInfo('Last SCSI Sense code decoding:   ' .. SCSISenseInfo)
			else AddDebugInfo('ERROR during last error code decoding:   ' .. ErrorMessage) end
		end
	return Table
	end
end 

Device.TestReadOD = DDDSplit('TestReadOD', Device.TEST_READ_OD)
Device.TestReadMD = DDDSplit('TestReadMD', Device.TEST_READ_MD)
Device.TestReadID = DDDSplit('TestReadID', Device.TEST_READ_ID)

AddDebugInfo('\n')


-- Diagnosis on the basis of the information provided====================================================================================================

--  Search and load an appropriate library---------------------------------------------------------------------------------------------------------------------------
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
		ErrorMessage = 'Can\'t found any lib file for this device.\n\n'
		return ErrorMessage .. '\n\n' .. ResultString .. DebugInfo
	else 
		if Device.DEBUG then ResultString = 'Loaded library file ' .. LibFileName .. '\n' .. ResultString  end
	end
end

Success, ErrorMessage = rl.ProtectedLoad(LibFileName)

-- Perform diagnostic functions ---------------------------------------------------------------------------------------------------------------------------
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

-- Calling methods, which describe malfunctions ---------------------------------------------------------------------------------------------------------------------------

for DiagResultName in pairs(Device.Bad) do
	local Verdict = Device.Bad[DiagResultName]:Verdict()
	if Verdict then Diagnosis = Diagnosis .. Verdict end
end

-- Formatting output---------------------------------------------------------------------------------------------------------------------------------------------

if Diagnosis and Diagnosis ~= '\n' then ResultString = ResultString .. Diagnosis end
if Explanation and Explanation ~= '\n' then ResultString = ResultString .. '\n<===<EXPLANATION>===>' .. Explanation end
if Warning and Warning ~= '\n' then ResultString = ResultString .. '\n!!! WARNING !!!' .. Warning end
if Device.DBG_CONTAINER then ResultString = '+++CONTEINER VIEWING MODE+++\n' .. ResultString .. '\n###STORED INFORMATION###\n' .. QuickDiagResult end
if Device.DEBUG then ResultString = '***DEBUG MODE***\n' .. ResultString .. '\n###DEBUG INFO###\n' .. DebugInfo end

return ResultString

