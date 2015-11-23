--[[ Vendor, family and generation clarification
  ]]

Device = {}
LOut = {}
Device.DEBUG = nil

-- Fill in the tag table
for Tag, Value in string.gmatch(DeviceInfoForBrand,'([^\n:]+):([^\n]+)') do
	Device[Tag] = Value
end

LibFolder = Device.BASE_DIR .. 'Scripts/lib/'


-- Set debug output
if Device.DEBUG then 
	io.output(Device.BASE_DIR .. 'debug_out_OnDetectBrand.txt') 
end

function DebugOut(String)
	if Device.DEBUG then 
		io.write (String .. '\n')
	end
end

DebugOut(DeviceInfoForBrand)



-- Load external chunk function
function IncludeChunk(FileName)
	dofile(LibFolder .. FileName)
end

-- Fill in Brand2ID table
IncludeChunk('table_Brand2ID.lua')

-- Set initial values

Device.FAMILY_ID = Device.FAMILY_ID or 0
Device.FAMILY_GEN_ID = Device.FAMILY_GEN_ID or 0

Device.FAMILY = Device.FAMILY or 'GNRCFAMILY'
Device.FAMILY_GEN = Device.FAMILY_GEN or 'GNRCGEN'

-- Refining the model name
do
	if Device.PROFILE_TYPE == 'HDD_ATA' or Device.PROFILE_TYPE == 'SSD_ATA' then 
		Device.RMODEL =  string.match(Device.MODEL,'%w+%s+(%w+-*%w*)')
	end

	if not Device.RMODEL then Device.RMODEL = Device.MODEL end
end

-- ====================BRAND DETECTION=================================================================================================

-- Based on the model name in general case, when brand is unknown.
if Device.MFGBRAND == 'UNKNOWN' then
	for Brand, ID in pairs(Brand2ID) do
		if Device.MODEL:match(Brand) then
			Device.MFGBRAND = Brand
			break
		end
	end
end



-- TEST Identifying of SAMSUNG among SEAGATE
if Device.MFGBRAND == 'SEAGATE' and Device.FWVER:find('^2A[RC].....$')  then Device.MFGBRAND = 'SAMSUNG' end



-- ====================FAMILY DETECTION=================================================================================================

if Device.MFGBRAND == 'SAMSUNG' then

	IncludeChunk('table_Model2Family_SAMSUNG.lua')
	if Model2Family[Device.RMODEL] then		
		Device.FAMILY = Model2Family[Device.RMODEL]
	end

	IncludeChunk('table_FW2Family_SAMSUNG.lua')		
	for FWPattern, Family in pairs(FW2Family) do
		if Device.FWVER:match(FWPattern) then
			Device.FAMILY = Family
			break
		end
	end
	
	if Device.FAMILY then 
		IncludeChunk('table_Family2ID_SAMSUNG.lua')
		Device.FAMILY_ID = Family2ID[Device.FAMILY]
	end	
	
elseif Device.MFGBRAND == 'SEAGATE' then
	
elseif Device.MFGBRAND == 'HGST' then

	IncludeChunk('table_Model2Family_HGST.lua')	
	if Model2Family[Device.RMODEL] then	
		Device.FAMILY = Model2Family[Device.RMODEL]
		IncludeChunk('table_Family2ID_HGST.lua')
		Device.FAMILY_ID = Family2ID[Device.FAMILY]	
	end

elseif Device.MFGBRAND == 'WDC' then

elseif Device.MFGBRAND == 'TOSHIBA' then

else end


--===================GENERATION DETECTION==========================================================================================
--[[
-- wxWidgets test
package.cpath = package.cpath .. ';' .. Device.BASE_DIR .. 'wx.dll'
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




--========================================================================================================================================
LOut.RMODEL = Device.RMODEL

LOut.BRAND_ID = Brand2ID[Device.MFGBRAND]
LOut.FAMILY_ID = Device.FAMILY_ID
LOut.FAMILY_GEN_ID = Device.FAMILY_GEN_ID

LOut.MFGBRAND = Device.MFGBRAND
LOut.FAMILY = Device.FAMILY
LOut.FAMILY_GEN = Device.FAMILY_GEN

return Brand2ID[Device.MFGBRAND] .. ',' .. Device.FAMILY_ID .. ',' .. Device.FAMILY_GEN_ID