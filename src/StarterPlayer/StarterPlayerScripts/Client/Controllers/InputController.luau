local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local InputController = Knit.CreateController({ Name = "InputController" })

function InputController:KnitInit()
	-- Connect input bindings, set up context actions
end

function InputController:KnitStart()
	-- Activate input listeners
end

return InputController
