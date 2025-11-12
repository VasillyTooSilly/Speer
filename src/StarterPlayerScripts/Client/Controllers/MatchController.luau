local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local MatchController = Knit.CreateController({ Name = "MatchController" })

function MatchController:KnitInit()
	-- Initialize match state and UI bindings
end

function MatchController:KnitStart()
	-- Start match-specific listeners, timers, etc.
end

return MatchController
