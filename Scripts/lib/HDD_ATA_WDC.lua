local libInfo = 'HDD_ATA_WDC 0.2 - 21.08.2016'

IncludeParentLib('HDD_ATA.lua')

--SILENCE-------------------------------------------------------------------------------------------------------------------
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
          AddExplanation('"Silence" sound from drive, with not origginal ROM high probability of firmware incompatable.')
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
 
      if  ( device.FORM_ELECTRICAL_DAMAGE == 'YES' or  device.FORM_SMELLS_BURNT == 'YES' or device.FORM_PCB_DAMAGE == 'YES' )
      and device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          device.fail.pcb:HighProbability()
          device.fail.heads:HighProbability()
          AddExplanation('"Silence" sound from WD drive suspected that PCB have a problem mean high probability of PCB and heads mulfunction.')
      end
   end
end