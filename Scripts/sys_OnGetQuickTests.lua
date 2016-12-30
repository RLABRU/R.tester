--[[ Vendor, family and generation clarification
  ]]

rl = require('rl')
  
device = {}
lOut = {}

-- Fill in the tag table
for tag, value in string.gmatch(reqTestSeq,'([^\n:]+):([^\n]+)') do
	device[tag] = value
end

debugLogFile = device.BASE_DIR .. 'Logs/DebugOut_sys_OnGetQuickTests.txt'

-- Set debug output
DebugOut = rl.CreateDebugLogFunc(debugLogFile)


DebugOut(reqTestSeq .. '\n================================\n')

-- if it is not real drive, then skip all tests
if device.DBG_CONTAINER or device.NOTDETECTED then
	io.write ('There is no real device, then no any tests will started.')
	return 'QUICK_TESTS:NOTESTS'
end

if device.PROFILE_TYPE == 'FLASHDRIVE' then
		testSeq = '3DREAD(20000,1024,16),IGNORE_ERR(0)\n'
end

if device.PROFILE_TYPE == 'SSD_ATA' then
		testSeq = 'READRND(1024,8,1),3DREAD(20000,1024,16),GET_SMART(),GET_SMART_EXT(),IGNORE_ERR(0)\n'
end

if device.PROFILE_TYPE == 'HDD_ATA' then
	if device.FORM_DATA_IMPORTANCE == 'DONTCARE' then
--[[		lOut['3DREAD'] = '(OD/MD/ID)'
		lOut. SEEKRND = 'SMTH'
		lOut.SEEKRND = 'SMTH'
		lOut.GET_SMART = 1
		lOut.GET_SMART_EXT = 1
		lOut.GET_DEFECTS = 1
		lOut.CHECK_CAPACITY = 1
		lOut.GET_TCG = 1
		lOut.IGNORE_ERR = 1
		]]
--		testSeq = 'SEEKRND(1024, 16), READRND(1024, 8, 16), 3DREAD(2000000, 1024, 16), GET_SMART(), GET_SMART_EXT(), IGNORE_ERR(1)\n'
		testSeq = 'READRND(1024,8,16),3DREAD(2000000,1024,16),GET_SMART(),GET_SMART_EXT(),IGNORE_ERR(1)\n'
		DebugOut('\n-->DONTCARE data importance selected\n')
	elseif device.FORM_DATA_IMPORTANCE == 'AVERADGE' then
		testSeq = 'READRND(1024, 8, 1),3DREAD(2000000,1024,1),GET_SMART(),GET_SMART_EXT(),IGNORE_ERR(1)\n'
		DebugOut('\n-->AVERAGE data importance selected\n')
	else
--		lOut.NOTESTS = 1
		if device.FORM_MECHANICAL_SHOCK ~= 'NOTSURE' or not (device.FORM_SOUND == 'NORMAL' or device.FORM_SOUND == 'NOTSURE') then
			testSeq = 'NOTESTS'
		else
			testSeq = 'READRND(1024,8,1),3DREAD(2000000,1024,1),GET_SMART(),GET_SMART_EXT(),IGNORE_ERR(0)\n'
		end
		DebugOut('\n-->CRITICAL data importance selected\n')
	end
end

testSeqTeg = '\nQUICK_TESTS:' .. testSeq

DebugOut(testSeqTeg)

return testSeqTeg
