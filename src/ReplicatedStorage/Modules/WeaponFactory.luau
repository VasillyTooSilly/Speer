--!nolint LocalUnused
-- Data-driven weapon registry and factory
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CombatConfig = require(ReplicatedStorage.Modules:WaitForChild("CombatConfig")) -- allow both mapping styles
-- If the line above errors depending on mapping, fallback:
if typeof(CombatConfig) ~= "table" then
	CombatConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatConfig"))
end

local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local WeaponFactory = {}
WeaponFactory.__index = WeaponFactory

local registry: { [string]: Types.WeaponDef } = {}

local function registerDefaultWeapons()
	registry["Spear"] = {
		id = "Spear",
		modelPath = "ReplicatedStorage/Assets/Weapons/Spear", -- optional
		stats = {
			displayName = "Classic Spear",
			maxAmmo = 1, -- 1 spear at a time
			pokeRange = 8,
			pokeWidth = 2.0, -- radius around poke path
			pokeCooldown = 0.5,

			throwCooldown = 1.25,
			throwRange = 120,
			throwMode = "Raycast", -- "Projectile" later
			throwSpeed = 180,
			throwGravity = workspace.Gravity,
			projectileLife = 8,

			damage = 65,
			headMultiplier = 1.5,
			limbMultiplier = 0.85,

			knockback = 50,
			upwardBoost = 15,

			staminaCostPoke = 10,
			staminaCostThrow = 25,

			blockMultiplier = 0.5,
		},
		skins = { "Default", "Flaming", "Crystal", "Banana", "Shadow" },
	}
end
registerDefaultWeapons()

function WeaponFactory.Register(def: Types.WeaponDef)
	assert(def and def.id and def.stats, "Invalid weapon def")
	registry[def.id] = def
end

function WeaponFactory.Get(id: string): Types.WeaponDef?
	return registry[id]
end

function WeaponFactory.List(): { Types.WeaponDef }
	local list = {}
	for _, def in pairs(registry) do
		table.insert(list, def)
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	return list
end

-- server helpers used by CombatService
function WeaponFactory.ComputeDamage(weaponId: string, hitPartName: string?): number
	local def = registry[weaponId]
	if not def then
		return 0
	end
	local mults = require(ReplicatedStorage.Modules.CombatConfig).DamageMultipliers
	local base = def.stats.damage
	if not hitPartName then
		return base
	end
	local m = mults[hitPartName] or 1.0
	return math.floor(base * m)
end

return WeaponFactory
