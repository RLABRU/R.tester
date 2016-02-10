local LibInfo = 'HDD_ATA_WDC 0.1'

IncludeParentLib('HDD_ATA.lua')

--SILENCE-------------------------------------------------------------------------------------------------------------------
Device.Diag[RegFunction('NOTDETECTED_SILENCE', LibInfo)] = function ()	
   if  Device.NOTDETECTED 
   and Device.FORM_SOUND == 'SILENCE' 
   and Device.FORM_SPINS_UP ~= 'YES' 
   then   
      if  Device.FORM_ROM_NOT_ORIGINAL == 'YES'
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES'
      and Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      then
          Device.Bad.FW:HighProbability()
          AddExplanation('"Silence" sound from drive, with not origginal ROM high probability of firmware incompatable.')
      end
      
      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then
          Device.Bad.PCB:Probability()
          Device.Bad.Heads:Probability()
          AddExplanation('"Silence" sound from drive in original state mean probability of PCB mulfunction or heads mulfunction.')
      end
 
      if  ( Device.FORM_ELECTRICAL_DAMAGE == 'YES' or  Device.FORM_SMELLS_BURNT == 'YES' or Device.FORM_PCB_DAMAGE == 'YES' )
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          Device.Bad.PCB:HighProbability()
          Device.Bad.Heads:HighProbability()
          AddExplanation('"Silence" sound from WD drive suspected that PCB have a problem mean high probability of PCB and heads mulfunction.')
      end
   end
end