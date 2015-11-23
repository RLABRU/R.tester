

-- Definition of root Malfunction class

Device.MalfunctionClass = {} 
  function Device.MalfunctionClass:new(MalfunctionName) 
	local obj = {}
	obj.MalfunctionName = MalfunctionName
    obj.HighProbabilityCounter = 0
    obj.ProbabilityCounter = 0
    obj.LowProbabilityCounter = 0
    
    setmetatable(obj, self)
    self.__index = self
    return obj   
  end
  
function Device.MalfunctionClass:HighProbability() self.HighProbabilityCounter = self.HighProbabilityCounter + 1 end
function Device.MalfunctionClass:Probability() self.ProbabilityCounter = self.ProbabilityCounter + 1 end
function Device.MalfunctionClass:LowProbability() self.LowProbabilityCounter = self.LowProbabilityCounter + 1 end
  
function Device.MalfunctionClass:Verdict()
	if self.HighProbabilityCounter ~= 0 or self.ProbabilityCounter ~= 0 or self.LowProbabilityCounter ~= 0 then
		local Verdict = ""
		if self.HighProbabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.HighProbabilityCounter .. ' sign(s) point to a high probability of ' .. self.MalfunctionName .. '.\n'
		end
		if self.ProbabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.ProbabilityCounter .. ' sign(s) point to a probability of ' .. self.MalfunctionName .. '.\n'
		end
		if self.LowProbabilityCounter ~= 0 then 
			Verdict = Verdict .. ' ' .. self.LowProbabilityCounter .. ' sign(s) point to a low probability of ' .. self.MalfunctionName .. '.\n'
		end
		return Verdict
	else return nil end       
end
  

  