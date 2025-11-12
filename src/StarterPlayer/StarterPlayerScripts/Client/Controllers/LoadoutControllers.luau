local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
local Knit = require(Packages:WaitForChild("Knit"))

local LoadoutController = Knit.CreateController({ Name = "LoadoutController" })

local WeaponFactory = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponFactory"))
local CombatService

local player = Players.LocalPlayer
local equippedModel -- currently equipped visual

-- Clone and attach weapon model to character (simple approach)
local function attachModelToCharacter(model: Model, character: Model)
	if not model or not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- remove previous visuals
	if equippedModel and equippedModel.Parent then
		equippedModel:Destroy()
		equippedModel = nil
	end

	local clone = model:Clone()
	clone.Name = "EquippedWeapon"
	clone.Parent = character
	-- If model has a PrimaryPart, position it relative to a hand.
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm") -- R6 fallback
	if clone.PrimaryPart and rightHand then
		-- weld PrimaryPart to rightHand
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = rightHand
		weld.Parent = clone.PrimaryPart
		-- position it: you might need to adjust according to model orientation
		clone:SetPrimaryPartCFrame(rightHand.CFrame * CFrame.new(0, 0, -0.5)) -- tweak offsets
	else
		-- fallback: anchor to root
		if clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -1))
		end
	end

	equippedModel = clone
end

function LoadoutController:KnitStart()
	CombatService = Knit.GetService("CombatService")

	-- Hook the client-side interface: if you have LobbyUI, add dynamic buttons
	local playerGui = player:WaitForChild("PlayerGui")
	local lobby = playerGui:FindFirstChild("LobbyUI")
	if lobby then
		local panel = lobby:FindFirstChild("Panel", true)
		if panel then
			-- create a simple list of buttons for each weapon
			local y = 0
			for _, def in ipairs(WeaponFactory.List()) do
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(0, 160, 0, 28)
				btn.Position = UDim2.new(0, 10, 0, 60 + y)
				btn.Text = "Equip: " .. (def.stats.displayName or def.id)
				btn.Parent = panel
				y = y + 34

				btn.MouseButton1Click:Connect(function()
					-- request server to equip; the server will update ammo and state
					CombatService:EquipWeapon(def.id)
					-- also attach the local visual (client-side cosmetic)
					local model
					if def.modelPath and def.modelPath ~= "" then
						-- convert "ReplicatedStorage/Assets/Weapons/Spear" to actual instance
						local assets = ReplicatedStorage:FindFirstChild("Assets")
						if assets then
							local weapons = assets:FindFirstChild("Weapons")
							if weapons then
								local mod = weapons:FindFirstChild(def.id) or weapons:FindFirstChild(def.id .. "/Spear")
								model = weapons:FindFirstChild(def.id)
							end
						end
					end
					-- simpler: try to find under ReplicatedStorage.Assets.Weapons.<id> or ReplicatedStorage.Assets.Weapons.<id>.Spear
					local modelInstance = nil
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					if assets then
						local weapons = assets:FindFirstChild("Weapons")
						if weapons then
							modelInstance = weapons:FindFirstChild(def.id) or weapons:FindFirstChild("Spear")
						end
					end
					if modelInstance and player.Character then
						attachModelToCharacter(modelInstance, player.Character)
					end
				end)
			end
		end
	end

	-- Also listen to respawn to reattach visuals if weapon is equipped
	player.CharacterAdded:Connect(function(char)
		-- ask server for weapon state? simplest: attach default Spear if exists
		local defaultId = "Spear"
		local def = WeaponFactory.Get(defaultId)
		if def then
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			if assets and assets:FindFirstChild("Weapons") then
				local modelInstance = assets.Weapons:FindFirstChild(defaultId) or assets.Weapons:FindFirstChild("Spear")
				if modelInstance then
					-- small delay until hand exists
					task.wait(0.5)
					attachModelToCharacter(modelInstance, char)
				end
			end
		end
	end)
end

return LoadoutController
