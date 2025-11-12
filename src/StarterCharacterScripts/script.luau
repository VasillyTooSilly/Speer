-- CharacterController template
-- This LocalScript should be parented under the player Character and handles
-- character-local client logic (camera adjustments, local animations, input
-- that depends on the character, etc.).

local Players = game:GetService("Players")

local _player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Example: react when the humanoid starts jumping
humanoid.Jumping:Connect(function()
	-- play jump SFX or UI feedback here
end)

-- Clean up when the character is removed
script.AncestryChanged:Connect(function()
	if not script:IsDescendantOf(game) then
		-- perform cleanup here
		return
	end
end)
