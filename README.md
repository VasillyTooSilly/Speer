# Speer

Lightweight Roblox game project scaffolded with Rojo and Wally.

Quick summary
- Language: Luau (Roblox)
- Tooling: Rojo (project mapping), Wally (package manager), Selene (linter), Rokit (tool pins)
- Dependency layout: Wally installs to the repository `Packages/` folder. Rojo publishes this folder into the game tree at `ReplicatedStorage.Packages` (see `default.project.json`).

Repository structure (key paths)
- `default.project.json` — Rojo mapping: maps `src/` into the Roblox tree and maps repo `Packages/` into `ReplicatedStorage.Packages`.
- `Packages/` — Wally-managed vendored packages (canonical location).
- `src/ReplicatedStorage` — shared runtime modules (example: `Hello.luau`).
- `src/ServerScriptService` — server-side scripts (Knit services live here).
- `src/StarterPlayerScripts/Client` — client boot scripts & controllers.

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