local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MatchController = Knit.CreateController({ Name = "MatchController" })

local MatchmakingService
local UIController

function MatchController:KnitStart()
	MatchmakingService = Knit.GetService("MatchmakingService")
	UIController = Knit.GetController("UIController")

	MatchmakingService.StateChanged:Connect(function(state)
		UIController:SetMatchState(state)
	end)

	-- initial pull
	task.spawn(function()
		local st = MatchmakingService:GetState()
		UIController:SetMatchState(st)
	end)
end

return MatchController
