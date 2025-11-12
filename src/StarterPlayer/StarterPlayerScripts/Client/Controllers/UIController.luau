local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local UIController = Knit.CreateController({ Name = "UIController" })

local player = Players.LocalPlayer

local LobbyGui: ScreenGui?
local HUDGui: ScreenGui?

-- Helpers for simple UI lookup; your Studio UIs should match these names
local function getUI()
	if not LobbyGui then
		LobbyGui = player:WaitForChild("PlayerGui"):WaitForChild("LobbyUI", 5) :: ScreenGui
	end
	if not HUDGui then
		HUDGui = player:WaitForChild("PlayerGui"):WaitForChild("HUD", 5) :: ScreenGui
	end
end

function UIController:KnitStart()
	getUI()

	-- hook up lobby buttons if present
	if LobbyGui then
		local btn = LobbyGui:FindFirstChild("JoinQueueButton", true)
		if btn and btn:IsA("TextButton") then
			btn.MouseButton1Click:Connect(function()
				local MatchmakingService = Knit.GetService("MatchmakingService")
				MatchmakingService:JoinQueue("FFA")
			end)
		end
	end

	self:SetAmmo(1)
	self:SetCooldown("Poke", 0)
	self:SetCooldown("Throw", 0)
end

function UIController:SetMatchState(state)
	getUI()
	if LobbyGui and HUDGui then
		if state.phase == "Lobby" then
			LobbyGui.Enabled = true
			HUDGui.Enabled = false
		else
			LobbyGui.Enabled = false
			HUDGui.Enabled = true
		end

		local lbl = HUDGui:FindFirstChild("MatchStateLabel", true)
		if lbl and lbl:IsA("TextLabel") then
			lbl.Text = string.format(
				"%s - %s (%ds)",
				state.mapName or "Map",
				state.phase,
				math.floor(state.timeRemaining or 0)
			)
		end
	end
end

function UIController:SetAmmo(ammo: number)
	getUI()
	local lbl = HUDGui and HUDGui:FindFirstChild("AmmoLabel", true)
	if lbl and lbl:IsA("TextLabel") then
		lbl.Text = "Ammo: " .. tostring(ammo)
	end
end

function UIController:SetCooldown(action: string, remaining: number)
	getUI()
	local lbl = HUDGui and HUDGui:FindFirstChild(action .. "CooldownLabel", true)
	if lbl and lbl:IsA("TextLabel") then
		if remaining <= 0 then
			lbl.Text = ""
		else
			lbl.Text = string.format("%s CD: %.1fs", action, remaining)
		end
	end
end

function UIController:FlashHitMarker(isKill: boolean)
	getUI()
	local marker = HUDGui and HUDGui:FindFirstChild("HitMarker", true)
	if marker and marker:IsA("Frame") then
		marker.Visible = true
		if isKill then
			marker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		else
			marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
		task.delay(0.15, function()
			marker.Visible = false
		end)
	end
end

function UIController:ShowFloatingDamage(dmg: number)
	-- optional: spawn a small label near crosshair; left as simple stub
end

return UIController
