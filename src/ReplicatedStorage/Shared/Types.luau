export type DamageEvent = {
	attacker: Player,
	victim: Player,
	hitPartName: string?,
	baseDamage: number,
	finalDamage: number,
	isHeadshot: boolean,
	cause: "Poke" | "Throw",
}

export type WeaponStats = {
	displayName: string,
	maxAmmo: number,
	pokeRange: number,
	pokeWidth: number,
	pokeCooldown: number,
	throwCooldown: number,
	throwRange: number,
	throwMode: "Raycast" | "Projectile",
	throwSpeed: number,
	throwGravity: number,
	projectileLife: number,
	damage: number,
	headMultiplier: number,
	limbMultiplier: number,
	knockback: number,
	upwardBoost: number,
	staminaCostPoke: number,
	staminaCostThrow: number,
	blockMultiplier: number, -- e.g. 0.5 = 50% reduction while blocking
}

export type WeaponDef = {
	id: string,
	modelPath: string?, -- optional, used for visuals
	stats: WeaponStats,
	skins: { string }?,
}

export type MatchModeId = "FFA" | "DUEL" | "TEAM"

export type MatchState = "Lobby" | "Countdown" | "InRound" | "PostRound"

return {}
