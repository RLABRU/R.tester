local LibInfo = 'HDD_ATA 0.2 - 25.10.2015'

IncludeParentLib('ROOT_DEVICE.lua')

-- Definitions for Malfunction types

Device.Bad.PCB = Device.MalfunctionClass:new('PCB malfunction')
Device.Bad.FW = Device.MalfunctionClass:new('FW corruption')
Device.Bad.Jammed = Device.MalfunctionClass:new('spindle rotation is locked')
Device.Bad.Heads = Device.MalfunctionClass:new('defective heads')
Device.Bad.BB = Device.MalfunctionClass:new('bad blocks')
Device.Bad.Scratched = Device.MalfunctionClass:new('scratched surface')

-- PCB Malfunction signs for UNDETECTED drives  -----------------------------------------------------
Device.Diag[RegFunction('PCB_NOTDETECTED', LibInfo)] = function ()

    if Device.NOTDETECTED and Device.FORM_ELECTRICAL_DAMAGE == 'YES' then
		Device.Bad.PCB:HighProbability()
		Device.Bad.Heads:LowProbability()
		AddExplanation('Electrical damage give high probability of PCB Malfunction.')
    end

    if Device.NOTDETECTED and Device.FORM_SOUND == 'SILENCE' and FORM_SPINS_UP == 'NO' then
		Device.Bad.PCB:HighProbability()
		AddExplanation('HDD does not spin up, which means a high probability of PCB Malfunction.')
    end

	if Device.NOTDETECTED and Device.FORM_SOUND == 'SILENCE' and FORM_SPINS_UP == 'NOTSURE' then
		Device.Bad.PCB:Probability()
		AddExplanation('HDD does not spin up, which means a probability of PCB Malfunction.')
    end
end


-- FW Malfunction signs -----------------------------------------------------
Device.Diag[RegFunction('FW_NOTDETECTED', LibInfo)] = function ()

    if Device.NOTDETECTED and Device.FORM_SOUND == 'NORMAL' then
		Device.Bad.FW:HighProbability()
		AddExplanation('Normal sound of undetected drive give high probability  of firmware Malfunction.')
    end

    if Device.NOTDETECTED and Device.FORM_COMPONENTS_CHANGED == 'YES' then
		Device.Bad.FW:Probability()
		AddExplanation('Undetected drive with changed components  have probability  of firmware Malfunction.')
    end
end


-- Spindel rotation blocked -----------------------------------------------------
Device.Diag[RegFunction('Jammed_NOTDETECTED', LibInfo)] = function ()

	if Device.NOTDETECTED and Device.FORM_SOUND == 'BZZZ' and FORM_SPINS_UP == 'NOTSURE' then
		Device.Bad.Jammed:Probability()
		AddExplanation('Sound BZZZ indicate high probability of a motor jam or head stuck on the plates.')
	end

	if Device.NOTDETECTED and FORM_SPINS_UP == 'NO' then
		Device.Bad.Jammed:Probability()
		AddExplanation('HDD undetected and not spins up, that gives probability of a motor jam or head stuck on the plates.')
	end

	if Device.NOTDETECTED and Device.FORM_SOUND == 'BZZZ' and FORM_SPINS_UP == 'NO' then
		Device.Bad.Jammed:HighProbability()
		AddExplanation('HDD attempts, but unable to spin up, which indicates high probability of a motor jam or head stuck on the plates.')
	end
end


-- Heads problem signs -----------------------------------------------------
Device.Diag[RegFunction('Heads_NOTDETECTED', LibInfo)] = function ()

  if Device.NOTDETECTED and Device.FORM_SOUND == 'KNOCKS' then
	Device.Bad.Heads:Probability()
	Device.Bad.PCB:LowProbability()
	AddExplanation('Knoking may mean defective heads.')
	AddExplanation('Knoking may mean also PCB Malfunction.')
  end

  if Device.NOTDETECTED and Device.FORM_SPINS_UP == 'THENSTOP' then
	Device.Bad.Heads:HighProbability()
	AddExplanation('Knoking then stop may mean defective heads.')
  end

  if Device.NOTDETECTED and Device.FORM_SPINS_UP == 'YES' then
	Device.Bad.Heads:Probability()
	AddExplanation('Knoking may mean defective heads.')
  end

  if Device.NOTDETECTED and Device.FORM_MECHANICAL_SHOCK == 'YES' then
	Device.Bad.Heads:Probability()
	AddExplanation('Shock to the turned on hard drive may mean defective heads.')
  end
end


-- Bad Block problem signs -----------------------------------------------------
Device.Diag[RegFunction('BadBlocks_NOTDETECTED', LibInfo)] = function ()

	if Device.NOTDETECTED and Device.FORM_MECHANICAL_SHOCK == 'YES' then
		Device.Bad.BB:HighProbability()
		AddExplanation('Shock shock to the turned on hard drive mean HDD have a bad blocks.')
	end
end


-- Scratched problem signs -----------------------------------------------------
Device.Diag[RegFunction('Scratched_NOTDETECTED', LibInfo)] = function ()

	if Device.NOTDETECTED and Device.FORM_SOUND == 'SKIRR' then
		Device.Bad.Scratched:HighProbability()
		AddExplanation('Sound "skirr" may mean that drive surface is scratched.')
	end
end

