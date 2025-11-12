local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamsService = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CombatConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatConfig"))
local MapRegistry = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MapRegistry"))

local MatchmakingService = Knit.CreateService({
	Name = "MatchmakingService",
	Client = {
		StateChanged = Knit.CreateSignal(), -- (stateTable)
	},
})

type MatchState = "Lobby" | "Countdown" | "InRound" | "PostRound"

local currentMode: "FFA" | "DUEL" | "TEAM" = "FFA"
local queue: { Player } = {}
local state = {
	phase = "Lobby" :: MatchState,
	timeRemaining = 0,
	mapName = "The Colosseum",
}

local function broadcastState(self)
	self.Client.StateChanged:FireAll(state)
end

local function setPhase(self, phase: MatchState, duration: number?)
	state.phase = phase
	state.timeRemaining = duration or 0
	broadcastState(self)
end

local function getMapFolder(): Folder
	local maps = ReplicatedStorage:FindFirstChild("Maps")
	if not maps then
		maps = Instance.new("Folder")
		maps.Name = "Maps"
		maps.Parent = ReplicatedStorage
	end
	return maps
end

local function cleanupMap()
	local mm = Workspace:FindFirstChild("ActiveMap")
	if mm then
		mm:Destroy()
	end
end

local function loadMap(name: string)
	cleanupMap()
	local maps = getMapFolder()
	local template = maps:FindFirstChild(name)
	if not template then
		warn("Map not found: " .. name)
		return nil
	end
	local clone = template:Clone()
	clone.Name = "ActiveMap"
	clone.Parent = Workspace
	return clone
end

local function teleportToSpawns(players: { Player }, mapModel: Instance)
	local spawnsFolder = mapModel:FindFirstChild(MapRegistry.SpawnsFolderName)
	if not spawnsFolder then
		warn("No spawn folder in map")
		return
	end
	local spawns = spawnsFolder:GetChildren()
	local i = 1
	for _, plr in ipairs(players) do
		local char = plr.Character or plr.CharacterAdded:Wait()
		local humRoot = char:WaitForChild("HumanoidRootPart") :: BasePart
		local spawn = spawns[i]
		if spawn and spawn:IsA("BasePart") then
			humRoot.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
		end
		i += 1
		if i > #spawns then
			i = 1
		end
	end
end

local runningRound = false

local function roundLoop(self)
	if runningRound then
		return
	end
	runningRound = true

	local modeCfg = CombatConfig.Modes[currentMode]
	setPhase(self, "Countdown", modeCfg.Countdown)

	local selectedMap = MapRegistry.DefaultCycle[math.random(1, #MapRegistry.DefaultCycle)]
	state.mapName = selectedMap
	broadcastState(self)

	local map = loadMap(selectedMap) or Instance.new("Model", Workspace)
	teleportToSpawns(Players:GetPlayers(), map)

	local t = modeCfg.Countdown
	while t > 0 do
		task.wait(1)
		t -= 1
		state.timeRemaining = t
		broadcastState(self)
	end

	setPhase(self, "InRound", modeCfg.RoundTime)
	local rt = modeCfg.RoundTime
	while rt > 0 do
		task.wait(1)
		rt -= 1
		state.timeRemaining = rt
		broadcastState(self)
	end

	setPhase(self, "PostRound", 8)
	task.wait(8)

	setPhase(self, "Lobby", 0)
	cleanupMap()
	runningRound = false
end

function MatchmakingService:KnitInit() end

function MatchmakingService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		table.insert(queue, player)
		self.Client.StateChanged:Fire(player, state)
		player.AncestryChanged:Connect(function()
			if not player.Parent then
				for i = #queue, 1, -1 do
					if queue[i] == player then
						table.remove(queue, i)
					end
				end
			end
		end)
		-- auto-start FFA when enough players
		local modeCfg = CombatConfig.Modes[currentMode]
		if #Players:GetPlayers() >= modeCfg.MinPlayers and not runningRound then
			task.spawn(function()
				roundLoop(self)
			end)
		end
	end)
end

-- Client API
function MatchmakingService.Client:JoinQueue(player, mode: string)
	for _, p in ipairs(queue) do
		if p == player then
			return true
		end
	end
	table.insert(queue, player)
	return true
end

function MatchmakingService.Client:LeaveQueue(player)
	for i = #queue, 1, -1 do
		if queue[i] == player then
			table.remove(queue, i)
		end
	end
end

function MatchmakingService.Client:GetState(player)
	return state
end

return MatchmakingService
