local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local UIController = Knit.CreateController({ Name = "UIController" })

function UIController:KnitInit()
	-- Initialize UI state, bind events, cache references
end

function UIController:KnitStart()
	-- Called after all controllers and services have started
end

return UIController
