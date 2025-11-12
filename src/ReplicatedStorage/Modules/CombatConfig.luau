local CombatConfig = {
	Global = {
		FriendlyFire = false,
		StaminaMax = 100,
		StaminaRegenPerSecond = 15,
		BlockStaminaPerSecond = 20,
		DodgeStaminaCost = 25,
		TimeToRespawn = 3,
		RagdollOnKill = true,
		HitInvulnerabilityTime = 0.2, -- brief grace period to avoid double-hits
	},

	DamageMultipliers = {
		Head = 1.5,
		UpperTorso = 1.0,
		LowerTorso = 1.0,
		LeftArm = 0.85,
		RightArm = 0.85,
		LeftLeg = 0.85,
		RightLeg = 0.85,
	},

	Modes = {
		FFA = {
			MinPlayers = 2,
			MaxPlayers = 12,
			ScoreToWin = 10,
			AllowTeams = false,
			Countdown = 5,
			RoundTime = 240,
		},

		DUEL = {
			MinPlayers = 2,
			MaxPlayers = 2,
			BestOf = 3,
			AllowTeams = false,
			Countdown = 5,
			RoundTime = 180,
		},

		TEAM = {
			MinPlayers = 4,
			MaxPlayers = 8,
			TeamSize = 4,
			AllowTeams = true,
			Countdown = 10,
			RoundTime = 300,
			ScoreToWin = 30,
		},
	},
}

return CombatConfig
