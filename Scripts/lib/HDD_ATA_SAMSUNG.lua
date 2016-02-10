local LibInfo = 'HDD_ATA_Samsung 0.1'

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
          AddExplanation('"Silence" sound from drive, with not origginal ROM high probability of firmvare incompatable.')
      end
      
      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then
          Device.Bad.PCB:HighProbability()
          Device.Bad.FW:HighProbability()
          AddExplanation('"Silence" sound fromb Samsung drive in original state mean high probability of PCB mulfunction and high probability of FW damedge.')
      end
 
      if  ( Device.FORM_ELECTRICAL_DAMAGE == 'YES' or  Device.FORM_SMELLS_BURNT == 'YES' or Device.FORM_PCB_DAMAGE ~= 'YES' )
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          Device.Bad.PCB:HighProbability()
          Device.Bad.Heads:Probability()
          AddExplanation('"Silence" sound from drive suspected that PCB have a problem mean high probability of PCB mulfunction and probability of heads mulfunction.')
      end
   end    
end