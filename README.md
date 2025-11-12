# Speer

Lightweight Roblox game project scaffolded with Rojo and Wally.

Quick summary
- Language: Luau (Roblox)
- Tooling: Rojo (project mapping), Wally (package manager), Selene (linter), Rokit (tool pins)
- Dependency layout: Wally installs to the repository `Packages/` folder. Rojo publishes this folder into the game tree at `ReplicatedStorage.Packages` (see `default.project.json`).

Repository structure (key paths)
- `default.project.json` — Rojo mapping: maps `src/` into the Roblox tree and maps repo `Packages/` into `ReplicatedStorage.Packages`.
- `Packages/` — Wally-managed vendored packages (canonical location).
- `src/ReplicatedStorage/Shared` — shared constants, utilities, helpers.
- `src/ReplicatedStorage/Modules` — gameplay systems (weapons, economy, etc.).
- `src/ServerScriptService` — server bootstrap and Knit services.
- `src/StarterPlayer/StarterPlayerScripts/Client` — client boot scripts & controllers.
- `src/StarterGui/LobbyUI`, `HUD`, `Menus` — UI screens and panels.

Developer workflows

- Install/update dependencies (Wally):

	wally install

- Build a place file (produces `Speer.rbxlx`):

	rojo build -o "Speer.rbxlx"

- Start a Rojo live server (sync to Studio):

	rojo serve

- If you use Rokit to pin tool versions (optional):

	rokit run wally install

Editor configuration
- `selene.toml` is present to lint Luau with the Roblox standard (`std = "roblox"`).
- `luau.json` points the Luau language server to package types under `Packages/_Index/...` so the editor can resolve requires.

Runtime patterns and conventions
- Require third-party libraries from `ReplicatedStorage.Packages.<Name>` at runtime. Example bootstraps use `ReplicatedStorage:WaitForChild("Packages", 10)` then `packages:WaitForChild("Knit", 10)` and require that Module to avoid race conditions.
- Keep Rojo mappings in `default.project.json` in sync when you move or add top-level folders. If you add a new runtime folder under `src/`, update the Rojo mapping.
- When adding modules intended to be shared at runtime, place them under `src/shared` or `src/ReplicatedStorage` and return pure module tables/functions (avoid side-effectful top-level code unless explicitly initialising).

Troubleshooting
- Unknown require at runtime (e.g. "Unknown require: game/ReplicatedStorage/Packages/Knit"):
	- Ensure `Packages/` exists at repo root and contains the package (run `wally install`).
	- Ensure `default.project.json` maps the repo `Packages` into `ReplicatedStorage.Packages`.
	- Use `WaitForChild` with a timeout in boot scripts to avoid startup races.

- Rojo mapping errors (e.g. "ClassName ... specified in both project file and from filesystem"):
	- Rojo treats folders containing `init.client.luau` / `init.server.luau` as Script instances. If you need a folder container, place scripts inside a subfolder and map that subfolder in `default.project.json` (the project already uses `Main` and `Client` subfolders).

Notes for contributors
- Do not manually edit `Packages/` unless you're vendoring a change — prefer `wally install` and let Wally manage versions. The repo ignores `src/ReplicatedStorage/Packages` to prevent accidental duplicates.
- Commit messages: use conventional prefixes like `feat:`, `fix:`, `chore:`, `docs:`.
---
Generated/maintained by repository automation (Rojo/Wally) and updated by the project maintainer.

Repository top-level tree
```
.
├── Packages/                 # Wally-installed packages (published into ReplicatedStorage.Packages)
├── src/                      # Source mapped into the Roblox tree by Rojo
│   ├── ReplicatedStorage/
│   │   ├── Shared/           # Utilities, constants, helpers
│   │   │   └── Hello.luau
│   │   └── Modules/          # Gameplay systems (ready for expansion)
│   ├── ServerScriptService/
│   │   ├── Main.server.luau  # Server bootstrap (Knit initialization)
│   │   └── Services/         # Knit services directory
│   │       ├── CombatService.luau (placeholder)
│   │       ├── MatchmakingService.luau (placeholder)
│   │       ├── EconomyService.luau (placeholder)
│   │       └── DataService.luau (placeholder)
│   ├── StarterCharacterScripts/
│   │   └── script.luau       # Character-local controller template
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       └── Client/
│   │           ├── Main.client.luau       # Client bootstrap
│   │           └── Controllers/
│   │               ├── UIController.luau
│   │               ├── CombatController.luau
│   │               ├── InputController.luau
│   │               └── MatchController.luau
│   └── StarterGui/
│       ├── LobbyUI/          # Lobby UI screens
│       ├── HUD/              # In-game HUD
│       └── Menus/            # Game menus
├── default.project.json      # Rojo mapping
├── luau.json                 # Editor type resolution for Luau
├── rokit.toml                # Pinned tool versions (optional)
├── selene.toml               # Selene lint config
├── wally.toml / wally.lock   # Wally package config / lockfile
└── README.md
```
```
.
├── Packages/                           # Wally-installed packages (published into ReplicatedStorage.Packages)
├── src/                                # Source mapped into the Roblox tree by Rojo
│   ├── ReplicatedStorage/
│   │   ├── Shared/                     # Shared constants, utilities, helpers
│   │   │   └── Hello.luau
│   │   └── Modules/                    # Gameplay systems
│   │
│   ├── ServerScriptService/
│   │   ├── Main.server.luau            # Server bootstrap (Knit server entry)
│   │   └── Services/                   # Knit services
│   │       ├── CombatService.luau
│   │       ├── MatchmakingService.luau
│   │       ├── EconomyService.luau
│   │       └── DataService.luau
│   │
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       └── Client/
│   │           ├── Main.client.luau    # Client bootstrap (Knit client entry)
│   │           └── Controllers/        # Knit controllers
│   │               ├── UIController.luau
│   │               ├── CombatController.luau
│   │               ├── InputController.luau
│   │               └── MatchController.luau
│   │
│   ├── StarterCharacterScripts/
│   │   └── script.luau                 # Character-local controller template
│   │
│   └── StarterGui/
│       ├── LobbyUI/                    # Lobby screens
│       ├── HUD/                        # In-game HUD elements
│       └── Menus/                      # Pause/Settings menus
│
├── default.project.json                # Rojo mapping (defines game tree structure)
├── luau.json                           # Editor type resolution for Luau language server
├── rokit.toml                          # Pinned tool versions (optional)
├── selene.toml                         # Selene lint config
├── wally.toml / wally.lock             # Wally package config / lockfile
└── README.md                           # This file
```