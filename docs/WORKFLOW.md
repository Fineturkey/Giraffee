# Lean development workflow

## Stack

- Roblox Studio: world editing, built-in Script Analysis, playtesting, publishing.
- Luau: game code; no TypeScript transpiler or gameplay framework initially.
- VS Code + Luau Language Server: autocomplete and local type/lint diagnostics.
- StyLua VS Code extension: format on save.
- Rojo 7.7.1 pinned in aftman.toml: disk scripts into Studio.
- Git: local source history; optional private GitHub backup later.
- Codex + official Studio MCP: occasional implementation, difficult debugging, and focused playtests.

No AI service is embedded in the game. No API key or additional AI subscription is needed for this starter. Extra agents and overlapping AI coding plugins add coordination and context costs; add only after measuring a real need.

## Daily loop

1. Open this folder in VS Code and your saved place in Studio.
2. Start one Rojo server using the extension or the serve task; connect Studio and review sync changes.
3. You build art/maps, tune settings, and playtest. Edit scripts on disk while Rojo is connected.
4. Use VS Code Problems and formatting before asking AI to diagnose simple errors.
5. Ctrl+Shift+B runs project validation. It builds an ignored validation place; it does not typecheck Luau or back up your Studio world.
6. Ask AI for one feature or bug fix with a clear completion condition. Let it finish that batch and stop.
7. Save the place separately. Commit source after a working milestone.

## Low-usage AI prompts

Feature: "Implement [one feature]. Done when [observable behavior]. Change only related files, validate, give a short summary, then stop."

Bug: "Expected [X], got [Y]. Repro: [steps]. Output error: [exact message]. Inspect relevant files only and fix the cause."

Planning: "Give me three options and your pick in under 200 words. Do not implement yet."

Handoff: "Update STATUS.md and stop at this milestone."

Keep the assistant idle while you build or play. Running an open app is different from requesting continuous AI monitoring/work. Continuous autonomous work uses inference; use bounded batches instead. Do not enable periodic monitoring merely to keep the assistant awake.

## Ownership and backups

- Disk owns mapped scripts and declared project objects. MCP script edits must also be saved to src/ or Rojo can overwrite them.
- Studio owns terrain/art and other unmapped objects. Save the actual place; build/validation.rbxlx is only a mapping check and is not your complete game.
- Never edit the same file/object simultaneously with AI. Tell it the area you are working on.
- No game concept selected yet. Avoid speculative systems, large dependency trees, monetization, trading, and persistence until the core loop is fun.
