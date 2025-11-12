local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local InputController = Knit.CreateController({ Name = "InputController" })

local CombatService

function InputController:KnitStart()
	CombatService = Knit.GetService("CombatService")
	self:Bind()
end

function InputController:Bind()
	ContextActionService:BindAction("SPEER_Poke", function(_, state)
		if state == Enum.UserInputState.Begin then
			CombatService:RequestPoke()
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

	ContextActionService:BindAction("SPEER_Throw", function(_, state)
		if state == Enum.UserInputState.Begin then
			local cam = workspace.CurrentCamera
			local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
			CombatService:RequestThrow(look)
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton2, Enum.KeyCode.Q)

	ContextActionService:BindAction("SPEER_Block", function(_, state)
		if state == Enum.UserInputState.Begin then
			CombatService:SetBlocking(true)
		elseif state == Enum.UserInputState.End then
			CombatService:SetBlocking(false)
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.F, Enum.KeyCode.ButtonL1)
end

return InputController
