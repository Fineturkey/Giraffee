# Roblox game starter

Active game: **Neon Crossfire**, a multiplayer arena shooter. See [shooter guide](docs/SHOOTER.md). Source: `shooter/`; active Rojo mapping: `default.project.json`. Monster Egg is preserved under `src/` and `monster-egg.project.json`.

Daily workflow: [docs/WORKFLOW.md](docs/WORKFLOW.md). Current handoff: [docs/STATUS.md](docs/STATUS.md).

VS Code: press Ctrl+Shift+B to validate the Rojo mapping and build a test place. Luau Language Server shows coding errors in Problems; StyLua formats Luau on save.

This folder is the source for our game scripts. Roblox Studio is where we build the world and playtest. Rojo syncs these source files into Studio.

## First connection

1. Install Roblox Studio and sign in.
2. Open this folder in VS Code.
3. Install the official Rojo extension in VS Code. Follow its prompts to install the Rojo server and Roblox Studio plugin: https://rojo.space/docs/v7/getting-started/installation/
4. In Studio, create a Baseplate and save the place locally.
5. In VS Code, open the Command Palette, run `Rojo: Open Menu`, select `default.project.json`, and start the server. Alternatively, with the Rojo CLI installed, run `rojo serve default.project.json` in this folder.
6. In Studio, open the Rojo plugin and connect to the local server (default port 34872). Review the proposed sync before accepting.
7. Press Play in Studio and open Output. Look for the Server and Client connection messages.

The shooter arena is generated from `shooter/server/Arena.luau`. Build additional art in Studio and save the place separately; Rojo does not automatically back up Studio-authored objects.

## Where code goes

- `shooter/server/`: server combat, arena, teams and rounds.
- `shooter/client/`: player controls, first-person aiming and UI.
- `shooter/shared/`: shared weapon/match settings. Never put secrets here.
- `src/`: preserved Monster Egg source, loaded by `monster-egg.project.json`.

While connected, edit scripts in this folder so Rojo can sync them into Studio. Playtest each small change. Share errors from Studio's Output when debugging.

## Git

Git tracks the source files locally. No GitHub remote is configured yet. A remote is optional for development; add one later for online backups and collaboration. Studio place files are ignored here; keep separate backups of the world.

## Language

Roblox uses Luau, a language derived from Lua. Start with variables, functions, conditions, loops, tables, and events. Then learn server/client responsibilities and RemoteEvents.
