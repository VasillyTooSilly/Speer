local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local Signal = require(Packages:WaitForChild("Signal"))

local WeaponFactory = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponFactory"))
local CombatConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatConfig"))

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {
		HitFeedback = Knit.CreateSignal(), -- (damage, isKill, partName, victimUserId)
		AmmoUpdate = Knit.CreateSignal(), -- (ammo, inFlight)
		CooldownUpdate = Knit.CreateSignal(), -- (action, remaining)
		Ragdoll = Knit.CreateSignal(), -- (state: boolean)
	},
})

type Cooldowns = { [string]: number }
type PlayerState = {
	stamina: number,
	lastHitAt: number,
	cooldowns: Cooldowns,
	weaponId: string,
	ammo: number,
	blocking: boolean,
}

local state: { [number]: PlayerState } = {}

local function now(): number
	return os.clock()
end

local function getCharHum(player: Player)
	local char = player.Character
	if not char then
		return nil, nil, nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	return char, hum, root
end

local function isAlive(humanoid: Humanoid?): boolean
	return humanoid and humanoid.Health > 0
end

local function ensureState(player: Player): PlayerState
	local ps = state[player.UserId]
	if not ps then
		local defaultWeapon = "Spear"
		local def = WeaponFactory.Get(defaultWeapon)
		ps = {
			stamina = CombatConfig.Global.StaminaMax,
			lastHitAt = 0,
			cooldowns = {},
			weaponId = defaultWeapon,
			ammo = def and def.stats.maxAmmo or 1,
			blocking = false,
			-- new inventory fields:
			inventory = { defaultWeapon }, -- list of strings
			equipped = defaultWeapon, -- convenience
		}
		state[player.UserId] = ps
	end
	return ps
end

local function setCooldown(ps: PlayerState, action: string, seconds: number)
	ps.cooldowns[action] = now() + seconds
end

local function cooldownRemaining(ps: PlayerState, action: string): number
	local t = ps.cooldowns[action]
	if not t then
		return 0
	end
	return math.max(0, t - now())
end

local function drainStamina(ps: PlayerState, amount: number): boolean
	if ps.stamina < amount then
		return false
	end
	ps.stamina -= amount
	return true
end

-- regen loop
RunService.Heartbeat:Connect(function(dt)
	for _, ps in pairs(state) do
		local regen = CombatConfig.Global.StaminaRegenPerSecond * dt
		if ps.blocking then
			regen -= CombatConfig.Global.BlockStaminaPerSecond * dt
		end
		if regen ~= 0 then
			ps.stamina = math.clamp(ps.stamina + regen, 0, CombatConfig.Global.StaminaMax)
		end
	end
end)

local function applyKnockback(victimHum: Humanoid, victimRoot: BasePart, from: Vector3, power: number, up: number)
	local dir = (victimRoot.Position - from).Unit
	local vel = dir * power + Vector3.new(0, up, 0)
	victimRoot.AssemblyLinearVelocity += vel
end

local function damagePlayer(
	attacker: Player,
	victim: Player,
	baseDamage: number,
	hitPartName: string?,
	cause: "Poke" | "Throw"
)
	local _, hum, root = getCharHum(victim)
	if not isAlive(hum) or not root then
		return
	end

	local psVictim = ensureState(victim)
	local mults = CombatConfig.DamageMultipliers
	local m = mults[hitPartName or ""] or 1.0
	local def = WeaponFactory.Get(ensureState(attacker).weaponId)
	local stats = def and def.stats or { headMultiplier = 1.5 }

	if hitPartName == "Head" then
		m = stats.headMultiplier or 1.5
	end

	local final = math.max(1, math.floor(baseDamage * m))

	if psVictim.blocking then
		final = math.floor(final * (stats.blockMultiplier or 0.5))
	end

	hum:TakeDamage(final)
	local killed = hum.Health <= 0

	-- ragdoll/knockback for comedy-- ragdoll/knockback for comedy
	if root then
		local attackerChar = attacker.Character
		local attackerRoot = attackerChar and attackerChar:FindFirstChild("HumanoidRootPart") :: BasePart?
		local attackerPos = attackerRoot and attackerRoot.Position or root.Position

		applyKnockback(hum, root, attackerPos, def and def.stats.knockback or 40, def and def.stats.upwardBoost or 10)

		if CombatConfig.Global.RagdollOnKill and killed then
			-- simple ragdoll: brief physics shove; full ragdoll system can be added later
		end
	end

	-- feedback to attacker
	CombatService.Client.HitFeedback:Fire(attacker, final, killed, hitPartName or "", victim.UserId)
end

function CombatService:KnitInit() end

function CombatService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		ensureState(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		state[player.UserId] = nil
	end)
end

-- Validation helpers
local function canHit(attacker: Player, victim: Player): boolean
	if attacker == victim then
		return false
	end
	if not CombatConfig.Global.FriendlyFire then
		if attacker.Team ~= nil and victim.Team ~= nil and attacker.Team == victim.Team then
			return false
		end
	end
	return true
end

local function validateFacing(attackerRoot: BasePart, dir: Vector3): boolean
	local forward = attackerRoot.CFrame.LookVector
	-- ensure the swing/throw direction is within a forward cone
	local dot = forward:Dot(dir.Unit)
	return dot > 0.25
end

-- Poke implementation (short-range stab)
function CombatService.Client:RequestPoke(player)
	local ps = ensureState(player)
	local def = WeaponFactory.Get(ps.weaponId)
	if not def then
		return
	end
	local stats = def.stats

	if cooldownRemaining(ps, "Poke") > 0 then
		CombatService.Client.CooldownUpdate:Fire(player, "Poke", cooldownRemaining(ps, "Poke"))
		return
	end
	if not drainStamina(ps, stats.staminaCostPoke) then
		return
	end

	local char, hum, root = getCharHum(player)
	if not isAlive(hum) or not root then
		return
	end

	setCooldown(ps, "Poke", stats.pokeCooldown)

	-- server-side hit check: capsule-ish forward sweep
	local origin = root.Position
	local dir = root.CFrame.LookVector
	if not validateFacing(root, dir) then
		return
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }

	local hitVictim: Player? = nil
	local endPos = origin + dir * stats.pokeRange
	-- sample multiple rays to create width
	local right = root.CFrame.RightVector
	local offsets = { Vector3.zero, right * stats.pokeWidth * 0.5, -right * stats.pokeWidth * 0.5 }
	for _, off in ipairs(offsets) do
		local result = Workspace:Raycast(origin + off, (endPos - origin), params)
		if result and result.Instance then
			local model = result.Instance:FindFirstAncestorOfClass("Model")
			if model then
				local p = Players:GetPlayerFromCharacter(model)
				if p and canHit(player, p) then
					hitVictim = p
					damagePlayer(player, p, stats.damage, result.Instance.Name, "Poke")
					break
				end
			end
		end
	end
end

-- Throw implementation (default Raycast MVP)
function CombatService.Client:RequestThrow(player, cameraLookVector: Vector3)
	local ps = ensureState(player)
	local def = WeaponFactory.Get(ps.weaponId)
	if not def then
		return
	end
	local stats = def.stats

	if ps.ammo <= 0 then
		return
	end
	if cooldownRemaining(ps, "Throw") > 0 then
		CombatService.Client.CooldownUpdate:Fire(player, "Throw", cooldownRemaining(ps, "Throw"))
		return
	end
	if not drainStamina(ps, stats.staminaCostThrow) then
		return
	end

	local char, hum, root = getCharHum(player)
	if not isAlive(hum) or not root then
		return
	end

	setCooldown(ps, "Throw", stats.throwCooldown)
	ps.ammo -= 1
	CombatService.Client.AmmoUpdate:Fire(player, ps.ammo, 0)

	local dir = cameraLookVector.Unit
	if not validateFacing(root, dir) then
		dir = root.CFrame.LookVector
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }

	local result = Workspace:Raycast(root.Position + Vector3.new(0, 2, 0), dir * stats.throwRange, params)
	if result and result.Instance then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if model then
			local p = Players:GetPlayerFromCharacter(model)
			if p and canHit(player, p) then
				damagePlayer(player, p, stats.damage, result.Instance.Name, "Throw")
			end
		end
	end

	-- simple ammo return after a delay (simulates pickup/respawn)
	task.delay(2, function()
		ps.ammo = math.min(def.stats.maxAmmo, ps.ammo + 1)
		CombatService.Client.AmmoUpdate:Fire(player, ps.ammo, 0)
	end)
end

function CombatService.Client:SetBlocking(player, isBlocking: boolean)
	local ps = ensureState(player)
	ps.blocking = isBlocking and true or false
end

function CombatService.Client:EquipWeapon(player, weaponId: string)
	local def = WeaponFactory.Get(weaponId)
	if not def then
		return
	end
	local ps = ensureState(player)
	ps.weaponId = weaponId
	ps.ammo = def.stats.maxAmmo
	CombatService.Client.AmmoUpdate:Fire(player, ps.ammo, 0)
end

return CombatService
