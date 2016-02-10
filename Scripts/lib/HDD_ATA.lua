local LibInfo = 'HDD_ATA 0.2 - 25.10.2015'

IncludeParentLib('ROOT_DEVICE.lua')

-- Definitions for Malfunction types

Device.Bad.PCB = Device.MalfunctionClass:new('PCB malfunction') 
Device.Bad.FW = Device.MalfunctionClass:new('FW corruption') 
Device.Bad.Jammed = Device.MalfunctionClass:new('spindle rotation is locked') 
Device.Bad.Heads = Device.MalfunctionClass:new('defective heads')
Device.Bad.BB = Device.MalfunctionClass:new('bad blocks')
Device.Bad.Scratched = Device.MalfunctionClass:new('scratched surface')

-- Rules for processing test results =================================================================================================

Device.Diag[RegFunction('3D_READ', LibInfo)] = function ()
-- Heads 	
	if  (Device.TestReadOD.Status and Device.TestReadOD.Status == FAIL and Device.TestReadOD.ErrCount > 1)
	and (Device.TestReadMD.Status and Device.TestReadMD.Status == FAIL and Device.TestReadMD.ErrCount > 1)
	and (Device.TestReadID.Status and Device.TestReadID.Status == FAIL and Device.TestReadID.ErrCount > 1)
	then 
		Device.Bad.Heads:HighProbability()
		AddExplanation('A large number of bad blocks at the beginning, middle and end of the drive with a high degree of probability indicate a malfunction of one of the heads.')
	end
   
   if  (Device.TestReadOD.Status and Device.TestReadOD.Status == FAIL and Device.TestReadOD.ErrCount == 1)
   and (Device.TestReadMD.Status and Device.TestReadMD.Status == FAIL and Device.TestReadMD.ErrCount == 1)
   and (Device.TestReadID.Status and Device.TestReadID.Status == FAIL and Device.TestReadID.ErrCount == 1)
   then 
       Device.Bad.Heads:Probability()
       AddExplanation('Presence of bad blocks at the beginning, middle and end of the drive indicate a malfunction of one of the heads.')
   end
-- ÂÂ   
   if  (Device.TestReadOD.Status and Device.TestReadOD.Status == FAIL and Device.TestReadOD.ErrCount > 1)
   or (Device.TestReadMD.Status and Device.TestReadMD.Status == FAIL and Device.TestReadMD.ErrCount > 1)
   or (Device.TestReadID.Status and Device.TestReadID.Status == FAIL and Device.TestReadID.ErrCount > 1)
   then 
       Device.Bad.BB:HighProbability()
       AddExplanation('In the process of testing revealed a large number of sectors that are read incorrectly.')
   end
   
   if  (Device.TestReadOD.Status and Device.TestReadOD.Status == FAIL and Device.TestReadOD.ErrCount == 1)
   or (Device.TestReadMD.Status and Device.TestReadMD.Status == FAIL and Device.TestReadMD.ErrCount == 1)
   or (Device.TestReadID.Status and Device.TestReadID.Status == FAIL and Device.TestReadID.ErrCount == 1)
   then 
       Device.Bad.BB:Probability()
       AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
   end
   
   if  (Device.TestReadOD.Status and Device.TestReadOD.Status == PASS and Device.TestReadOD.ErrCount > 0)
   or (Device.TestReadMD.Status and Device.TestReadMD.Status == PASS and Device.TestReadMD.ErrCount > 0)
   or (Device.TestReadID.Status and Device.TestReadID.Status == PASS and Device.TestReadID.ErrCount > 0)
   then 
       Device.Bad.BB:Probability()
       AddExplanation('In the process of testing revealed sectors that are read incorrectly.')
   end
   
end

Device.Diag[RegFunction('RANDOM_READ', LibInfo)] = function ()

   
end


-- Rules for the S.M.A.R.T analisys. =================================================================================================

-- Malfunctions
Device.Diag[RegFunction('SMART_DIAGNOSIS', LibInfo)] = function ()

   
end

--Warnings
Device.Diag[RegFunction('SMART_WARNINGS', LibInfo)] = function ()

   
end










-- Rules for UNDETECTED drives=================================================================================================


--BZZZ-----------------------------------------------------------------------------------------------------------------------------
Device.Diag[RegFunction('NOTDETECTED_BZZZ', LibInfo)] = function ()	
   if  Device.NOTDETECTED 
   and Device.FORM_SOUND == 'BZZZ' 
   and Device.FORM_SPINS_UP ~= 'YES' 
   then 
       Device.Bad.Jammed:HighProbability()
       AddExplanation('"Buzz" sound of undetected drive give high probability of jammed spidel.')
   end
end

--SKIRR
Device.Diag[RegFunction('NOTDETECTED_SKIRR', LibInfo)] = function ()	
   if  Device.NOTDETECTED 
   and Device.FORM_SOUND == 'SKIRR' 
   and Device.FORM_SPINS_UP ~= 'NO' 
   then 
       Device.Bad.Scratched:HighProbability()
       AddExplanation('"Skirr" sound of undetected drive give high probability of scratched surface.')
   end
end

-- KNOCKS-------------------------------------------------------------------------------------------------------------------------------------------------------
Device.Diag[RegFunction('NOTDETECTED_KNOCKS', LibInfo)] = function ()	
   if  Device.NOTDETECTED 
   and Device.FORM_SOUND == 'KNOCKS' 
   and Device.FORM_SPINS_UP ~= 'NO' 
   then 
      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES'
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then      
          Device.Bad.Heads:Probability()
          Device.Bad.BB:Probability()
          Device.Bad.PCB:LowProbability()
          Device.Bad.Scratched:LowProbability()
          AddExplanation('"Knocks" sound of undetected drive give probability of heads and/or surface damage, and low probability of PCB damage or scratched surface.')
      end
           
      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL == 'YES'
      then
          Device.Bad.FW:Probability()
          AddExplanation('"Knocks" sound from drive, with not original ROM may mean that firmware not compatable.')
      end

      if  ( Device.FORM_ELECTRICAL_DAMAGE == 'YES' or  Device.FORM_PCB_DAMAGE == 'YES' or Device.FORM_SMELLS_BURNT == 'YES' ) 
      then
          Device.Bad.PCB:HighProbability()
          Device.Bad.Heads:Probability()
          Device.Bad.Scratched:LowProbability()
          Device.Bad.BB:LowProbability()
          AddExplanation('"Knocks" sound from drive with electrical dameged or with PCB dameged or with smell of burning may mean high probability of PCB mulfunction probability of bad heads and low probability of bad blocks and scratched.')
      end

      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES'
      and Device.FORM_MECHANICAL_SHOCK == 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      then
          Device.Bad.Heads:HighProbability()
          Device.Bad.Scratched:Probability()
          Device.Bad.BB:Probability()
          AddExplanation('"Knocks" sound from drive with mechanical shock may mean high probability of heads mulfunction and probability of platter scratched or probability of bad blocks.')
      end
   end
end

--NORMAL----------------------------------------------------------------------------------------------------------------------------------------
Device.Diag[RegFunction('NOTDETECTED_NORMAL', LibInfo)] = function ()	
   if Device.NOTDETECTED 
   and Device.FORM_SOUND == 'NORMAL' 
   and Device.FORM_SPINS_UP ~= 'NO' 
   then 
      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES' 
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then 
          Device.Bad.FW:HighProbability()
          Device.Bad.BB:LowProbability()
          Device.Bad.Heads:LowProbability()
          Device.Bad.PCB:LowProbability()
          AddExplanation('"Normal" sound of undetected drive mean high probability of firmvare corrupt and low probability of bad blocks or PCB mulfunction or heads mulfunction.')
      end

      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_MECHANICAL_SHOCK == 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL ~= 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES' 
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then 
          Device.Bad.FW:HighProbability()
          Device.Bad.BB:HighProbability()
          Device.Bad.Heads:Probability()
          Device.Bad.Scratched:LowProbability()
          AddExplanation('"Normal" sound of undetected and shoked drive mean high probability of firmvare corrupt and bad blocks and probability of scratched or heads mulfunction.')
      end

      if  Device.FORM_ELECTRICAL_DAMAGE ~= 'YES'
      and Device.FORM_MECHANICAL_SHOCK ~= 'YES'
      and Device.FORM_ROM_NOT_ORIGINAL == 'YES'
      and Device.FORM_PCB_DAMAGE ~= 'YES' 
      and Device.FORM_SMELLS_BURNT ~= 'YES'
      then 
          Device.Bad.FW:HighProbability()
          Device.Bad.BB:LowProbability()
          Device.Bad.Heads:LowProbability()
          Device.Bad.PCB:Probability()
          AddExplanation('"Normal" sound of undetected drive whith not original ROM mean high probability of firmvare incompatible and probability PCB mulfunction and low probability of bad blocks or heads mulfunction.')
      end
   end
end

--SILENCE---------------------------------------------------------------------------------------------------------------------------------------------
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
          Device.Bad.PCB:Probability()
          Device.Bad.Heads:Probability()
          AddExplanation('"Silence" sound from drive in original state mean probability of PCB mulfunction or heads mulfunction.')
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