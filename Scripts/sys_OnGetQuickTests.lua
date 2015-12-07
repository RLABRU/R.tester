--[[ Vendor, family and generation clarification
  ]]

Device = {}
LOut = {}

-- Fill in the tag table
for Tag, Value in string.gmatch(reqTestSeq,'([^\n:]+):([^\n]+)') do
	Device[Tag] = Value
end

-- Set debug output
if Device.DEBUG then 
	io.output(Device.BASE_DIR .. 'Logs/DebugOut_sys_OnGetQuickTests.txt') 
end

function DebugOut(String)
	if Device.DEBUG then 
		io.write (String .. '\n')
	end
end

DebugOut(reqTestSeq .. '\n================================\n')

-- if it is not real drive, then skip all tests
if Device.DBG_CONTAINER or Device.NOTDETECTED then
	io.write ('There is no real device, then no any tests will started.')
	return 'QUICK_TESTS:NOTESTS'
end

if Device.FORM_DATA_IMPORTANCE == 'DONTCARE' then
	LOut['3DREAD'] = '(OD/MD/ID)'
	LOut. SEEKRND = 'SMTH'
	LOut.SEEKRND = 'SMTH'
	LOut.GET_SMART = 1
	LOut.GET_SMART_EXT = 1
	LOut.GET_DEFECTS = 1
	LOut.CHECK_CAPACITY = 1
	LOut.GET_TCG = 1
	LOut.IGNORE_ERR = 1
	TestSeq = '3DREAD(OD/MD/ID), SEEKRND(SMTH), GET_SMART(), GET_SMART_EXT(), GET_DEFECTS(), CHECK_CAPACITY(), GET_TCG(), IGNORE_ERR(1)'
	DebugOut('\n-->DONTCARE data importance selected\n')
elseif Device.FORM_DATA_IMPORTANCE == 'AVERADGE' then
	LOut['3DREAD'] = '(OD/MD/ID)'
	LOut. SEEKRND = 'SMTH'
	LOut.SEEKRND = 'SMTH'
	LOut.GET_SMART = 1
	LOut.GET_SMART_EXT = 1
	LOut.GET_DEFECTS = 1
	LOut.CHECK_CAPACITY = 1
	LOut.GET_TCG = 1
	TestSeq = '3DREAD(OD/MD/ID), SEEKRND(SMTH), GET_SMART(), GET_SMART_EXT(), GET_DEFECTS(), CHECK_CAPACITY(), GET_TCG()'
	DebugOut('\n-->AVERAGE data importance selected\n')
else
	LOut.NOTESTS = 1
	TestSeq = 'NOTESTS'
	DebugOut('\n-->CRITICAL data importance selected\n')
end

TestSeqTeg = 'QUICK_TESTS:' .. TestSeq

DebugOut(TestSeqTeg)

return TestSeqTeg
