

-- Definition of root Malfunction class

device.malfunctionClass = {} 
  function device.malfunctionClass:New(malfunctionName) 
	local obj = {}
	obj.malfunctionName = malfunctionName
    obj.highProbabilityCounter = 0
    obj.probabilityCounter = 0
    obj.lowProbabilityCounter = 0
    
    setmetatable(obj, self)
    self.__index = self
    return obj   
  end
  
function device.malfunctionClass:HighProbability() self.highProbabilityCounter = self.highProbabilityCounter + 1 end
function device.malfunctionClass:Probability() self.probabilityCounter = self.probabilityCounter + 1 end
function device.malfunctionClass:LowProbability() self.lowProbabilityCounter = self.lowProbabilityCounter + 1 end
  
function device.malfunctionClass:Verdict()
	if self.highProbabilityCounter ~= 0 or self.probabilityCounter ~= 0 or self.lowProbabilityCounter ~= 0 then
		local Verdict = ""
		if self.highProbabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.highProbabilityCounter .. ' ' .. rl.Loc(rl.Plural('sign indicates', 'signs indicate', self.highProbabilityCounter)) .. ' ' .. rl.Loc('a high probability of') .. ' ' .. rl.Loc(self.malfunctionName) .. '.\n'
		end
		if self.probabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.probabilityCounter .. ' ' .. rl.Loc(rl.Plural('sign indicates', 'signs indicate', self.probabilityCounter)) .. ' ' .. rl.Loc('a probability of') .. ' ' .. rl.Loc(self.malfunctionName) .. '.\n'
		end
		if self.lowProbabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.lowProbabilityCounter .. ' ' .. rl.Loc(rl.Plural('sign indicates', 'signs indicate', self.lowProbabilityCounter)) .. ' ' .. rl.Loc('a low probability of') .. ' ' .. rl.Loc(self.malfunctionName) .. '.\n'
		end
		return Verdict
	else return nil end       
end
  
function device.malfunctionClass:MalfunctionDetected()
	if self.highProbabilityCounter == 0 and self.probabilityCounter == 0 then
		return false
	else
		return true
	end
end
  