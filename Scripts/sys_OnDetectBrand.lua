--[[ Vendor, family and generation clarification
  ]]

rl = require('rl')
 
device = {}
lOut = {}

-- Fill in the tag table
for tag, value in string.gmatch(DeviceInfoForBrand,'([^\n:]+):([^\n]+)') do
	device[tag] = value
end

libFolder = device.BASE_DIR .. 'Scripts/lib/'
debugLogFile = device.BASE_DIR .. 'Logs/DebugOut_sys_OnDetectBrand.txt'

-- Set debug output
DebugOut = rl.CreateDebugLogFunc(debugLogFile)

DebugOut(DeviceInfoForBrand)

-- Load external chunk function
function IncludeChunk(fileName)
	dofile(libFolder .. fileName)
end

-- Set initial values

device.PROFILE_TYPE = device.PROFILE_TYPE or 'NOTPASSED'
device.MFGBRAND = device.MFGBRAND or 'NOTPASSED'
device.MODEL = device.MODEL or 'NOTPASSED'

device.FAMILY_ID = device.FAMILY_ID or 0
device.FAMILY_GEN_ID = device.FAMILY_GEN_ID or 0

device.FAMILY = device.FAMILY or 'GNRC'
device.FAMILY_GEN = device.FAMILY_GEN or 'GNRC'


-- Fill in brand2ID table
IncludeChunk('table_brand2ID.lua')

-- Refining the model name
do
	if device.PROFILE_TYPE == 'HDD_ATA' or device.PROFILE_TYPE == 'SSD_ATA' then 
		device.RMODEL =  string.match(device.MODEL,'%w+%s+(%w+-*%w*)')
	end

	if not device.RMODEL then device.RMODEL = device.MODEL end
end

-- ====================BRAND DETECTION=================================================================================================

-- Based on the model name in general case, when brand is unknown.
if device.MFGBRAND == 'UNKNOWN' or device.MFGBRAND == 'NOTPASSED' then
	for brand, ID in pairs(brand2ID) do
		if device.MODEL:match(brand) then
			device.MFGBRAND = brand
			break
		end
	end
end



-- TEST Identifying of SAMSUNG among SEAGATE
if device.MFGBRAND == 'SEAGATE' and device.FWVER:find('^2A[RC].....$')  then device.MFGBRAND = 'SAMSUNG' end



-- ====================FAMILY DETECTION=================================================================================================
if device.PROFILE_TYPE == 'HDD_ATA' or device.PROFILE_TYPE == 'SSD_ATA' then
	if device.MFGBRAND == 'SAMSUNG' then

		IncludeChunk('table_model2Family_SAMSUNG.lua')
		if model2Family[device.RMODEL] then		
			device.FAMILY = model2Family[device.RMODEL]
		end

		IncludeChunk('table_fw2Family_SAMSUNG.lua')		
		for fwPattern, family in pairs(fw2Family) do
			if device.FWVER:match(fwPattern) then
				device.FAMILY = family
				break
			end
		end
	
		if device.FAMILY then 
			IncludeChunk('table_family2ID_SAMSUNG.lua')
			device.FAMILY_ID = family2ID[device.FAMILY]
		end	

	elseif device.MFGBRAND == 'SEAGATE' then
	
	elseif device.MFGBRAND == 'HGST' then

		IncludeChunk('table_model2Family_HGST.lua')	
		if model2Family[device.RMODEL] then	
			device.FAMILY = model2Family[device.RMODEL]
			IncludeChunk('table_family2ID_HGST.lua')
			device.FAMILY_ID = family2ID[device.FAMILY]	
		end

	elseif device.MFGBRAND == 'WDC' then

	elseif device.MFGBRAND == 'TOSHIBA' then

	else end
end

--===================GENERATION DETECTION==========================================================================================
--[[
-- wxWidgets test
package.cpath = package.cpath .. ';' .. device.BASE_DIR .. 'wx.dll'
local wx = require('wx')

-- создаем фрейм размером 200x200 с заголовком Hello wxLua
frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Hello wxLua",
        wx.wxDefaultPosition, wx.wxSize(200, 200),
        wx.wxDEFAULT_FRAME_STYLE)

-- делаем фрейм видимым
frame:Show(true)

-- запускаем основной цикл выполнения программы
wx.wxGetApp():MainLoop()
]]

--[[
-- IUP test
package.cpath = package.cpath .. ';C:/Users/gk/Downloads/iup-3.16-Lua52_Win32_dll10_lib/?52.dll'
require( "iuplua" )
iup.Message('YourApp','Finished Successfully!')


]]

-- Check for the case, when no such brand in the table
if brand2ID[device.MFGBRAND] then
	device.BRAND_ID = brand2ID[device.MFGBRAND]
else
	device.BRAND_ID = 0
end

--========================================================================================================================================
lOut.RMODEL = device.RMODEL

lOut.BRAND_ID = device.BRAND_ID
lOut.FAMILY_ID = device.FAMILY_ID
lOut.FAMILY_GEN_ID = device.FAMILY_GEN_ID

lOut.MFGBRAND = device.MFGBRAND
lOut.FAMILY = device.FAMILY
lOut.FAMILY_GEN = device.FAMILY_GEN

DebugOut( '\nBRAND_ID: ' .. device.BRAND_ID .. ', ' .. 'FAMILY_ID: ' .. device.FAMILY_ID .. ', ' .. 'FAMILY_GEN_ID: ' .. device.FAMILY_GEN_ID)

return device.BRAND_ID .. ',' .. device.FAMILY_ID .. ',' .. device.FAMILY_GEN_ID