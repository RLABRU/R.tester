
rl = require('rl')

debugInfo = ''
diagnosis = '\n'
explanation = '\n'
warning = '\n'
resultString = ''

device = {}
device.diag = {} -- Registered rights functions
device.fail = {} -- List of mailfunction types
device.regRulesList = {} -- List of registered rights functions

function AddExplanation(newExplanation) explanation = explanation .. ' • ' .. rl.Loc(newExplanation) .. '\n' end

function AddWarning(newWarning) warning = warning .. ' ! ' .. rl.Loc(newWarning) .. '\n' end

function AddDebugInfo(newDebugInfo) 
	if device.DEBUG then 
		if newDebugInfo then
			debugInfo = debugInfo .. newDebugInfo .. '\n'
		else
			debugInfo = debugInfo .. '\n'
		end
	end 
end

function IncludeParentLib(fileName)	dofile(libFolder .. fileName) end

-- Diagnostic functions registration
function RegFunction(functionName, libInfo) 
	if device.regRulesList[functionName] then
		AddDebugInfo('Loaded function ' .. functionName .. ' from library ' .. libInfo .. ' function from ' .. device.regRulesList[functionName] .. ' overloaded.')
	else
		AddDebugInfo('Loaded function ' .. functionName .. ' from library ' .. libInfo .. '.')
	end
	device.regRulesList[functionName] = libInfo
	return functionName
end

-- SCSI errors decoding
function SCSISenseDecode(errCode)
	local keySense
	local codeSense
	if not errCode then return nil, 'ErrCod is nil' end
	if errCode ~= '00000000' then
		rl.IncludeOnce(libFolder .. 'table_fakeSense.lua')
		if fakeSense[errCode] then 
			return fakeSense[errCode]
		else
			local key, code, qualifier, FRU = string.match(errCode, '(%w%w)(%w%w)(%w%w)(%w%w)')
			if code then
				rl.IncludeOnce(libFolder .. 'table_scsiSense.lua')
				keySense = scsiSense[key]
				if not keySense then return nil, 'Can\'t found sense key in SCSISense table' end
			
				codeSense, errorMessage = rl.IniVal(device.BASE_DIR .. 'SCSI_Err.ini', 'SENSE', code .. qualifier)
				if not codeSense then return nil, errorMessage end
			else return nil, 'Can\'t parse SenseCode.' end
		end
	else return 'No SCSI errors.' end
	
	return keySense .. '    ' .. codeSense
end

-- GO!!! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 -- Tags string deserialization.
for key, value in string.gmatch(QuickDiagResult,'([^\n:]+):([^\n]+)') do
	if value == value:match('%d+') then
		device[key] = tonumber(value)
	else
		device[key] = value
	end
end

AddDebugInfo(QuickDiagResult)

-- Аdd the missing source tags
device.MFGBRAND = device.MFGBRAND or 'NOTDETECTED'
device.FAMILY = device.FAMILY or 'GNRC'
device.FAMILY_ID = device.FAMILY_ID or 0
device.FAMILY_GEN = device.FAMILY_GEN or 'GNRC'

-- End the program if there is an error in the previous stages of diagnostics
if device.STAGE_ERROR then return device.STAGE_ERROR end

-- Assigning values to auxiliary variables
libFolder = device.BASE_DIR .. 'Scripts/lib/'

-- Fill in the values of the derivate tags ======================================================================================

-- Refining the model name
do
	if device.PROFILE_TYPE == 'HDD_ATA' or device.PROFILE_TYPE == 'SSD_ATA' then 
		device.RMODEL =  string.match(device.MODEL,'%w+%s+(%w+-*%w*)')
	end

	if not device.RMODEL then device.RMODEL = device.MODEL end
end

-- Filling the code name of the product family
if (device.PROFILE_TYPE == 'HDD_ATA' or device.PROFILE_TYPE == 'SSD_ATA') and device.FAMILY_ID ~= 0 then

	if device.MFGBRAND == 'SAMSUNG' then
	
		rl.IncludeChunk('Scripts/lib/table_family2ID_SAMSUNG.lua')
		for family, id in pairs(family2ID) do

			if id == device.FAMILY_ID then 
				device.FAMILY = family
				break
			end
		end
		
	elseif device.MFGBRAND == 'HGST' then

		rl.IncludeChunk('Scripts/lib/table_family2ID_HGST.lua')
		for family, id in pairs(family2ID) do

			if id == device.FAMILY_ID then 
				device.FAMILY = family
				break
			end
		end
		
	elseif device.MFGBRAND == 'WDC' then

		device.FAMILY = 'F' .. device.FAMILY_ID
			
	elseif device.MFGBRAND == 'SEAGATE' then

		device.FAMILY = 'F' .. device.FAMILY_ID
		
	else end	
end

-- If Debug is enabled then send  additional info to output
AddDebugInfo('RMODEL=>' .. device.RMODEL)
AddDebugInfo('FAMILY=>' .. device.FAMILY)
AddDebugInfo('FAMILY_GEN=>' .. device.FAMILY_GEN)

-- preliminary cooking of the tag contents ==================================================================================================================


-- Splitting string of SMART attributes for ATA devices-------------------------------------------------------------------------------------------------------------------------------------------
if device.PROFILE_TYPE == 'HDD_ATA' or device.PROFILE_TYPE == 'SSD_ATA' then
	local tmpTable = {}
	for key, value in pairs(device) do
		local SMART_ID = string.match(key,'^ATTR_(%d+)')
		if SMART_ID then
			tmpTable['attr' .. SMART_ID] = {}
			tmpTable['attr' .. SMART_ID].type, tmpTable['attr' .. SMART_ID].value, tmpTable['attr' .. SMART_ID].worst, tmpTable['attr' .. SMART_ID].threshold, tmpTable['attr' .. SMART_ID].raw1, tmpTable['attr' .. SMART_ID].raw2, tmpTable['attr' .. SMART_ID].raw3 = string.match(value,'^(%d+),(%d+),(%d+),(%d+),(%d+)/*(%d*)/*(%d*)$')
			for attrType, attrValue in pairs(tmpTable['attr' .. SMART_ID]) do
				if attrValue and attrValue ~= '' then
					tmpTable['attr' .. SMART_ID][attrType] = tonumber(attrValue)
				end
			end
		end
	end
	for key, value in pairs(tmpTable) do device[key] = value end
end

-- Splitting of read test results-----------------------------------------------------------------------------------------------------------------------------------------------------------------

if device.TEST_RANDOM_SEEK then
	device.testRandomSeek = {}
	device.testRandomSeek.status, device.testRandomSeek.startLBA, device.testRandomSeek.stopLBA, device.testRandomSeek.lastLBA, device.testRandomSeek.seekCount, device.testRandomSeek.seekDone, device.testRandomSeek.errCode, device.testRandomSeek.cmdTimeMin, device.testRandomSeek.cmdTimeMax, device.testRandomSeek.cmdTimeAvg = string.match(device.TEST_RANDOM_SEEK,'^(%w+),(%d+),(%d+),(%-?%d+),(%d+),(%d+),(%w+),(%d+),(%d+),(%d+)$')
	if device.testRandomSeek.status then 
		device.testRandomSeek.startLBA = tonumber(device.testRandomSeek.startLBA); device.testRandomSeek.stopLBA = tonumber(device.testRandomSeek.stopLBA); device.testRandomSeek.lastLBA = tonumber(device.testRandomSeek.lastLBA); device.testRandomSeek.seekCount = tonumber(device.testRandomSeek.seekCount); device.testRandomSeek.seekDone = tonumber(device.testRandomSeek.seekDone); device.testRandomSeek.cmdTimeMin = tonumber(device.testRandomSeek.cmdTimeMin); device.testRandomSeek.cmdTimeMax = tonumber(device.testRandomSeek.cmdTimeMax); device.testRandomSeek.cmdTimeAvg = tonumber(device.testRandomSeek.cmdTimeAvg)
	end	
	if device.DEBUG then
		AddDebugInfo('\nRandomSeek test results in expanded form:')
		for key, value in rl.Pairs(device.testRandomSeek) do
			AddDebugInfo('TestRandomSeek.' .. key .. ' = ' .. value)
		end
		local scsiSenseInfo, errorMessage = SCSISenseDecode(device.testRandomSeek.errCode)
		if scsiSenseInfo then AddDebugInfo('Last SCSI Sense:   ' .. scsiSenseInfo)
		else AddDebugInfo('ERROR during last error code decoding:   ' .. errorMessage) end
	end
end

if device.TEST_RANDOM_READ then
	device.testRandomRead = {}
	device.testRandomRead.status, device.testRandomRead.startLBA, device.testRandomRead.stopLBA, device.testRandomRead.lastLBA, device.testRandomRead.blockSize, device.testRandomRead.readsCount, device.testRandomRead.readsDone, device.testRandomRead.errCode, device.testRandomRead.cmdTime, device.testRandomRead.testTimeMin, device.testRandomRead.testTimeMax, device.testRandomRead.testTimeAvg = string.match(device.TEST_RANDOM_READ,'^(%w+),(%d+),(%d+),(%-?%d+),(%d+),(%d+),(%d+),(%w+),(%d+),(%d+),(%d+),(%d+)$')
	if device.testRandomRead.status then 
		device.testRandomRead.startLBA = tonumber(device.testRandomRead.startLBA); device.testRandomRead.stopLBA = tonumber(device.testRandomRead.stopLBA); device.testRandomRead.lastLBA = tonumber(device.testRandomRead.lastLBA); device.testRandomRead.blockSize = tonumber(device.testRandomRead.blockSize); device.testRandomRead.readsCount = tonumber(device.testRandomRead.readsCount); device.testRandomRead.readsDone = tonumber(device.testRandomRead.readsDone); device.testRandomRead.cmdTime = tonumber(device.testRandomRead.cmdTime); device.testRandomRead.testTimeMin = tonumber(device.testRandomRead.testTimeMin); device.testRandomRead.testTimeMax = tonumber(device.testRandomRead.testTimeMax); device.testRandomRead.testTimeAvg = tonumber(device.testRandomRead.testTimeAvg)
	end
	if device.DEBUG then
		AddDebugInfo('\nRandomRead test results in expanded form:')
		for key, value in rl.Pairs(device.testRandomRead) do
			AddDebugInfo('TestRandomRead ' .. key .. ' = ' .. value)
		end
		local scsiSenseInfo, errorMessage = SCSISenseDecode(device.testRandomRead.errCode)
		if scsiSenseInfo then AddDebugInfo('Last SCSI Sense:   ' .. scsiSenseInfo)
		else AddDebugInfo('ERROR during last error code decoding:   ' .. errorMessage) end
	end
end

function DDDSplit(testName, tagVal)
	if tagVal then
		local table = {}
		table.status, table.startLBA, table.stopLBA, table.blockSize, table.errCount, table.errCode, table.testTime = string.match(tagVal,'^(%w+),(%d+),(%d+),(%d+),(%d+),(%w+),(%d+)$')
		if table.status then 
			table.startLBA = tonumber(table.startLBA); table.stopLBA = tonumber(table.stopLBA); table.blockSize = tonumber(table.blockSize); table.errCount = tonumber(table.errCount); table.testTime = tonumber(table.testTime)
		end
		if device.DEBUG then
			AddDebugInfo('\n' .. testName ..' test results in expanded form:')
			for key, value in rl.Pairs(table) do
				AddDebugInfo(testName .. ' ' .. key .. ' = ' .. value)
			end
			local scsiSenseInfo, errorMessage = SCSISenseDecode(table.errCode)
			if scsiSenseInfo then AddDebugInfo('Last SCSI Sense:   ' .. scsiSenseInfo)
			else AddDebugInfo('ERROR during last error code decoding:   ' .. errorMessage) end
		end
	return table
	end
end 

device.testReadOD = DDDSplit('TestReadOD', device.TEST_READ_OD)
device.testReadMD = DDDSplit('TestReadMD', device.TEST_READ_MD)
device.testReadID = DDDSplit('TestReadID', device.TEST_READ_ID)

AddDebugInfo('\n')


-- Diagnosis on the basis of the information provided====================================================================================================

--  Search and load an appropriate library---------------------------------------------------------------------------------------------------------------------------
do
	function LibExists(libName)
		local fileName = libFolder .. libName .. '.lua'
		if rl.FileExists(fileName) then return fileName else return false end
	end

	libFileName = LibExists(device.PROFILE_TYPE .. '_' .. device.MFGBRAND  .. '_' .. device.RMODEL .. '_' .. device.FWVER) 
				or LibExists(device.PROFILE_TYPE .. '_' .. device.MFGBRAND  .. '_' .. device.RMODEL) 
--				or LibExists(device.PROFILE_TYPE .. '_' .. device.MFGBRAND  .. '_' .. device.FAMILY) 
				or LibExists(device.PROFILE_TYPE .. '_' .. device.MFGBRAND) 
				or LibExists(device.PROFILE_TYPE)
				
	if not libFileName then 
		errorMessage = 'Can\'t found any lib file for this device.\n\n'
		return errorMessage .. '\n\n' .. resultString .. debugInfo
	else 
		if device.DEBUG then resultString = 'Loaded library file ' .. libFileName .. '\n' .. resultString  end
	end
end

success, errorMessage = rl.ProtectedLoad(libFileName)

-- Perform diagnostic functions ---------------------------------------------------------------------------------------------------------------------------
if success then
	for diagRuleName in pairs(device.diag) do 
		success, errorMessage = pcall(device.diag[diagRuleName])
		if success then
			AddDebugInfo('Run ' .. diagRuleName .. ' function from library '.. device.regRulesList[diagRuleName] .. '.')
		else 
			return 'Error in the function ' ..  diagRuleName .. ' from library '.. device.regRulesList[diagRuleName] .. ':\n' .. errorMessage .. '\n\n' .. resultString .. debugInfo
		end
	end
else
    return errorMessage .. '\n\n' .. resultString .. debugInfo
end

-- Calling methods, which describe malfunctions ---------------------------------------------------------------------------------------------------------------------------

local malfunctionDetected = false
for diagResultName in pairs(device.fail) do
	local verdict = device.fail[diagResultName]:Verdict()
	if verdict then diagnosis = diagnosis .. verdict end
	if not malfunctionDetected then 
		malfunctionDetected = device.fail[diagResultName]:MalfunctionDetected() 
	end	
end

-- Formatting output---------------------------------------------------------------------------------------------------------------------------------------------

local intro
local finally



if not device.DEBUG then
	if  device.NOTDETECTED then	
		if malfunctionDetected then
			intro = rl.Loc('На основе предоставленных данных, можно предположить следующий характер \nнеисправности:')
			finally = rl.Loc('')
			if string.find(device.PROFILE_TYPE, 'HDD') then 		
				finally = finally .. rl.Loc('Для уточнения диагноза и восстановления данных, рекомендуем обратиться \nк специалистам, обладающим соответствующим опытом и специальным \nоборудованием, таким как комплекс PC-3000.')
			end
		else
			intro = rl.Loc('Предоставленных данных не достаточно для определения характера \nнеисправности.')
			if string.find(device.PROFILE_TYPE, 'HDD') then 		
				finally = rl.Loc('Для предположения типа неисправности жесткого диска, ключевое значение \nимеют издаваемые устройством звуки. Уделите пожалуйста особое внимание \nэтому пункту анкеты.')
			end
		end		
	else
		if malfunctionDetected then
			intro = rl.Loc('Обнаружены признаки аппаратной неисправности:')
			finally = rl.Loc('Для уточнения диагноза и восстановления данных, рекомендуем обратиться к специалистам, обладающим \nсоответствующим опытом и специальным оборудованием, таким как комплекс PC-3000.')
		else
			if string.find(device.PROFILE_TYPE, 'HDD') and device.FORM_DATA_IMPORTANCE == 'CRITICAL' and device.FORM_MECHANICAL_SHOCK == 'YES' then
				intro = rl.Loc('При подозрениях наличия механических повреждений, в случае кртически \nважных данных, диагностика не выполняется.')
				finally = rl.Loc('В подобных случаях работа с жестким диском без предварительного изучения \nсостояния блока головок, может привести к уменьшению шансов успешного \nвосстановления. Рекомендуем отключить питание накопителя и обратиться к \nспециалистам.')
			else
				intro = rl.Loc('Признаков аппаратных неисправностей не выявлено.')
				finally = rl.Loc('Если данные на накопителе недоступны, это может указывать на повреждения \nтаблицы разделов или файловой системы. В таком случае воспользуйтесь \nпрограммами для восстановления данных, например UFS Explorer или R.saver\n(бесплатная версия UFS Explorer для FAT, NTFS, exFAT).')
			end
		end		
	end
	finally = finally .. '\n\n' .. rl.Loc([[
Точная диагностика требует наличия специального оборудования и действий,
для выполнения которых нужен соответствующий опыт. 

Процедура автоматической диагностики предназначена для быстрой оценки 
состояния устройства и примерного определения характера неисправности:

o	Точность диагноза может варьироваться от 30% до 100% 
	в зависимости от модели устройства и типа неисправности.
	
o	Логика алгоритма отталкивается от того, что пользователь 
	наблюдает неполадки в работе устройства, и стоит задача 
	определения неисправности, которая их вызвала.
	
o	Доступ к накопителям в технологическом режиме не используется.

Помните, что любые манипуляции с физически неисправным носителем могут 
привести к ухудшению его состояния. Поэтому, в случае потери критически
важных данных, обращайтесь к специалистам сразу.
]])
end

if intro and intro ~= '\n' then resultString = resultString .. intro .. '\n' end
if diagnosis and diagnosis ~= '\n' then resultString = resultString .. diagnosis end
if explanation and explanation ~= '\n' then resultString = resultString .. '\n' .. rl.Loc('<===< EXPLANATION >===>') .. explanation end
if warning and warning ~= '\n' then resultString = resultString .. '\n' ..  rl.Loc('!!! WARNING !!!') .. warning end
if finally and finally ~= '\n' then resultString = resultString  .. '\n' .. finally .. '\n' end




if device.DBG_CONTAINER then resultString = '+++CONTEINER VIEWING MODE+++\n' .. resultString .. '\n###STORED INFORMATION###\n' .. QuickDiagResult end
if device.DEBUG then resultString = '***DEBUG MODE***\n' .. resultString .. '\n###DEBUG INFO###\n' .. debugInfo end

return resultString

