local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CombatController = Knit.CreateController({ Name = "CombatController" })

local CombatService
local UIController

function CombatController:KnitStart()
	CombatService = Knit.GetService("CombatService")
	UIController = Knit.GetController("UIController")

	CombatService.HitFeedback:Connect(function(damage, isKill, partName, victimUserId)
		UIController:FlashHitMarker(isKill)
		UIController:ShowFloatingDamage(damage)
	end)

	CombatService.AmmoUpdate:Connect(function(ammo, inFlight)
		UIController:SetAmmo(ammo)
	end)

	CombatService.CooldownUpdate:Connect(function(action, remaining)
		UIController:SetCooldown(action, remaining)
	end)
end

return CombatController
