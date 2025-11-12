local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local CombatController = Knit.CreateController({ Name = "CombatController" })

function CombatController:KnitInit()
	-- Setup combat-related signals, state, and services
end

function CombatController:KnitStart()
	-- Begin listening to player input or service events
end

return CombatController
