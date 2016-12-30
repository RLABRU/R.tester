local libInfo = 'HDD_ATA 0.5 - 21.08.2016'

IncludeParentLib('ROOT_DEVICE.lua')

-- Definitions for Malfunction types

device.fail.pcb = device.malfunctionClass:New('PCB malfunction') 
device.fail.fw = device.malfunctionClass:New('FW corruption') 
device.fail.jammed = device.malfunctionClass:New('spindle rotation is locked') 
device.fail.heads = device.malfunctionClass:New('defective heads')
device.fail.bb = device.malfunctionClass:New('bad blocks')
device.fail.scratched = device.malfunctionClass:New('scratched surface')

-- Rules for processing test results =================================================================================================

device.diag[RegFunction('3D_READ', libInfo)] = function ()

-- Heads ----------------------------------	
	if  device.testReadOD and device.testReadOD.status == 'FAIL' and device.testReadOD.errCount > 1
	and device.testReadMD and device.testReadMD.status == 'FAIL' and device.testReadMD.errCount > 1
	and device.testReadID and device.testReadID.status == 'FAIL' and device.testReadID.errCount > 1
	then 
		device.fail.heads:HighProbability()
		AddExplanation('A large number of bad blocks at the beginning, middle and end of the drive with a high degree of probability indicate a malfunction of one of the heads.')
	end
   
   if  device.testReadOD and device.testReadOD.status == 'FAIL' and device.testReadOD.errCount == 1
   and device.testReadMD and device.testReadMD.status == 'FAIL' and device.testReadMD.errCount == 1
   and device.testReadID and device.testReadID.status == 'FAIL' and device.testReadID.errCount == 1
   then 
       device.fail.heads:Probability()
       AddExplanation('Presence of bad blocks at the beginning, middle and end of the drive indicate a malfunction of one of the heads.')
   end
-- ÂÂ ----------------------------------   
   if device.testReadOD and device.testReadOD.status == 'FAIL' and device.testReadOD.errCount > 1
   or device.testReadMD and device.testReadMD.status == 'FAIL' and device.testReadMD.errCount > 1
   or device.testReadID and device.testReadID.status == 'FAIL' and device.testReadID.errCount > 1
   then 
       device.fail.bb:HighProbability()
       AddExplanation('In the process of testing revealed a large number of sectors that are read incorrectly.')
   end
   
   if device.testReadOD and device.testReadOD.status == 'FAIL' and device.testReadOD.errCount == 1
   or device.testReadMD and device.testReadMD.status == 'FAIL' and device.testReadMD.errCount == 1
   or device.testReadID and device.testReadID.status == 'FAIL' and device.testReadID.errCount == 1
   then 
       device.fail.bb:Probability()
       AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
   end

   if device.testReadOD and device.testReadOD.status == 'PASS' and device.testReadOD.errCount > 0
   or device.testReadMD and device.testReadMD.status == 'PASS' and device.testReadMD.errCount > 0
   or device.testReadID and device.testReadID.status == 'PASS' and device.testReadID.errCount > 0
   then 
       device.fail.bb:Probability()
       AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
   end
   
end

device.diag[RegFunction('RANDOM_READ', libInfo)] = function ()

	if device.testRandomRead and device.testRandomRead.status == 'FAIL' and device.testRandomRead.readsCount - device.testRandomRead.readsDone > 1
	then
	   device.fail.bb:HighProbability()
	   AddExplanation('In the process of testing revealed a large number of sectors that are read incorrectly.')
	end

	if device.testRandomRead and device.testRandomRead.status == 'FAIL' and device.testRandomRead.readsCount - device.testRandomRead.readsDone == 1
	then
	   device.fail.bb:Probability()
	   AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
	end

	if device.testRandomRead and device.testRandomRead.status == 'PASS' and device.testRandomRead.readsCount - device.testRandomRead.readsDone > 0
	then
	   device.fail.bb:Probability()
	   AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
	end  
end


-- Rules for the S.M.A.R.T analisys. =================================================================================================

-- Malfunctions-----------------------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('SMART_DIAGNOSIS', libInfo)] = function ()
-- #5 and 198
	if device.attr5 and ( device.attr5.raw1 > 499 or device.attr5.value < 26 ) 
	or device.attr198 and ( device.attr198.raw1 > 499 or device.attr198.value < 26 )	
	then 
       device.fail.bb:Probability()
       AddExplanation('S.M.A.R.T. attributes analysis indicates the likelihood of the presence of unreadable sectors.')
	end
-- #184
	if device.attr184 and device.attr184.raw1 > 0 
	then
       device.fail.pcb:LowProbability()
       AddExplanation('A non-zero value of the attribute 184 may indicate a problem with the electronics board or controller, or cable or contact, or to strong electromagnetic interference.')	
	end
-- #199	
	if device.attr199 and device.attr199.raw1 > 0 
	then
       device.fail.pcb:LowProbability()
       AddExplanation('A non-zero value of the attribute 199 may be a problem. This is either a cable or a buffer memory or firmware error.')	
	end
	
	if device.attr197 and device.attr197.raw1 > 0 
	then
		if device.attr197.raw1 < 10 
		then
			device.fail.bb:Probability()
			AddExplanation('A non-zero value of the attribute 197 may indicate a problem with bad sectors.')	
		else
			device.fail.bb:HighProbability()
			AddExplanation('A non-zero value of the attribute 197 indicate a problem with bad sectors.')	
		end
	end
end

--Warnings-----------------------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('SMART_WARNINGS', libInfo)] = function ()
-- #4
	if device.attr4 and device.attr4.raw1 > 10000 
	then
       AddWarning('Number of on / off disk is too large.')
	end
-- #5 and 198
	if device.attr5 and ( 0 < device.attr5.raw1 and device.attr5.raw1 < 500 or 25 < device.attr5.value and device.attr5.value < 75 )
	or device.attr198 and ( 0 < device.attr198.raw1 and device.attr198.raw1 < 500 or 25 < device.attr198.value and device.attr198.value < 75 )	
	then 
       AddWarning('The first signs of disc wear.')
	end
-- #5 and 196 and 197
	if device.attr5 and device.attr5.raw1 == 0 
	and ( device.attr196 and device.attr196.raw1 > 99 or  device.attr197 and device.attr197.raw1 > 99 )
	then 
       AddWarning('The first signs of disc wear.')
	end
--#10
	if device.attr10 and device.attr10.value < device.attr10.threshold
	then
       AddWarning('S.M.A.R.T. attributes analysis indicates spindle motor start problems.')
	end
-- #11
	if device.attr11 and device.attr11.value < device.attr11.threshold
	then
       AddWarning('Frequent recalibration may indicate the degradation of the surface and of the head.')
	end
-- #183
	if device.attr183 and device.attr183.raw1 > 5
	then
       AddWarning('Perhaps the problem with the cable or controller.')
	end
-- #190 and 194 and 231
	if device.attr190 and device.attr190.raw1 > 50 
	or device.attr194 and device.attr194.raw1 > 50
	or device.attr231 and device.attr231.raw1 > 50
	then 
      AddWarning('Drive is overheated.')
	end
-- #193 
	if device.attr193 and device.attr193.value > 99999 
	or device.attr193 and device.attr193.value < device.attr193.threshold
	then 
       AddWarning('Too much parking/unparking of the heads.')
	end
-- #200
	if device.attr200 and device.attr200.raw1 > 0
	then
       AddWarning('Drive has a problem with the recording, perhaps a consequence of general wear and tear.')
	end
-- #254
	if device.attr254 and device.attr254.raw1 > 0
	then
       AddWarning('The sensor recorded freefall.')
	end

end










-- Rules for UNDETECTED drives=================================================================================================


--BZZZ-----------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('NOTDETECTED_BZZZ', libInfo)] = function ()	
   if  device.NOTDETECTED 
   and device.FORM_SOUND == 'BZZZ' 
   and device.FORM_SPINS_UP ~= 'YES' 
   then 
       device.fail.jammed:HighProbability()
       AddExplanation('"Buzz" sound of undetected drive give high probability of jammed spidel.')
   end
end

--SKIRR
device.diag[RegFunction('NOTDETECTED_SKIRR', libInfo)] = function ()	
   if  device.NOTDETECTED 
   and device.FORM_SOUND == 'SKIRR' 
   and device.FORM_SPINS_UP ~= 'NO' 
   then 
       device.fail.scratched:HighProbability()
       AddExplanation('"Skirr" sound of undetected drive give high probability of scratched surface.')
   end
end

-- KNOCKS-------------------------------------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('NOTDETECTED_KNOCKS', libInfo)] = function ()	
   if  device.NOTDETECTED 
   and device.FORM_SOUND == 'KNOCKS' 
   and device.FORM_SPINS_UP ~= 'NO' 
   then 
      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES'
      and device.FORM_SMELLS_BURNT ~= 'YES'
      then      
          device.fail.heads:Probability()
          device.fail.bb:Probability()
          device.fail.pcb:LowProbability()
          device.fail.scratched:LowProbability()
          AddExplanation('"Knocks" sound of undetected drive give probability of heads and/or surface damage, and low probability of PCB damage or scratched surface.')
      end
           
      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL == 'YES'
      then
          device.fail.fw:Probability()
          AddExplanation('"Knocks" sound from drive, with not original ROM may mean that firmware not compatable.')
      end

      if  ( device.FORM_ELECTRICAL_DAMAGE == 'YES' or  device.FORM_PCB_DAMAGE == 'YES' or device.FORM_SMELLS_BURNT == 'YES' ) 
      then
          device.fail.pcb:HighProbability()
          device.fail.heads:Probability()
          device.fail.scratched:LowProbability()
          device.fail.bb:LowProbability()
          AddExplanation('"Knocks" sound from drive with electrical dameged or with PCB dameged or with smell of burning may mean high probability of PCB mulfunction probability of bad heads and low probability of bad blocks and scratched.')
      end

      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK == 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          device.fail.heads:HighProbability()
          device.fail.scratched:Probability()
          device.fail.bb:Probability()
          AddExplanation('"Knocks" sound from drive with mechanical shock may mean high probability of heads mulfunction and probability of platter scratched or probability of bad blocks.')
      end
   end
end

--NORMAL----------------------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('NOTDETECTED_NORMAL', libInfo)] = function ()	
   if device.NOTDETECTED 
   and device.FORM_SOUND == 'NORMAL' 
   and device.FORM_SPINS_UP ~= 'NO' 
   then 
      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES' 
      and device.FORM_SMELLS_BURNT ~= 'YES'
      then 
          device.fail.fw:HighProbability()
          device.fail.bb:LowProbability()
          device.fail.heads:LowProbability()
          device.fail.pcb:LowProbability()
          AddExplanation('"Normal" sound of undetected drive mean high probability of firmvare corrupt and low probability of bad blocks or PCB mulfunction or heads mulfunction.')
      end

      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK == 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES' 
      and device.FORM_SMELLS_BURNT ~= 'YES'
	  then 
          device.fail.fw:HighProbability()
          device.fail.bb:HighProbability()
          device.fail.heads:Probability()
          device.fail.scratched:LowProbability()
          AddExplanation('"Normal" sound of undetected and shoked drive mean high probability of firmvare corrupt and bad blocks and probability of scratched or heads mulfunction.')
      end

      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL == 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES' 
      and device.FORM_SMELLS_BURNT ~= 'YES'
      then 
          device.fail.fw:HighProbability()
          device.fail.bb:LowProbability()
          device.fail.heads:LowProbability()
          device.fail.pcb:Probability()
          AddExplanation('"Normal" sound of undetected drive whith not original ROM mean high probability of firmvare incompatible and probability PCB mulfunction and low probability of bad blocks or heads mulfunction.')
      end
   end
end

--SILENCE---------------------------------------------------------------------------------------------------------------------------------------------
device.diag[RegFunction('NOTDETECTED_SILENCE', libInfo)] = function ()	
   if  device.NOTDETECTED 
   and device.FORM_SOUND == 'SILENCE' 
   and device.FORM_SPINS_UP ~= 'YES' 
   then   
      if  device.FORM_ROM_NOT_ORIGINAL == 'YES'
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES'
      and device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      then
          device.fail.fw:HighProbability()
          AddExplanation('"Silence" sound from drive, with not origginal ROM high probability of firmvare incompatable.')
      end
      
      if  device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and device.FORM_PCB_DAMAGE ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and device.FORM_SMELLS_BURNT ~= 'YES'
      then
          device.fail.pcb:Probability()
          device.fail.heads:Probability()
          AddExplanation('"Silence" sound from drive in original state mean probability of PCB mulfunction or heads mulfunction.')
      end
 
      if  ( device.FORM_ELECTRICAL_DAMAGE == 'YES' or  device.FORM_SMELLS_BURNT == 'YES' )
	  and device.FORM_PCB_DAMAGE ~= 'YES'
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          device.fail.pcb:HighProbability()
          device.fail.heads:Probability()
          AddExplanation('"Silence" sound from drive suspected that PCB have a problem mean high probability of PCB mulfunction and probability of heads mulfunction.')
      end
   end    
end