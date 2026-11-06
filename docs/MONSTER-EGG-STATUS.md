# Current state

- Phase: expanded playable Monster Egg prototype.
- Installed: Studio, VS Code, Git, Aftman/Rojo 7.7.1, Rojo extension/plugin, Luau Language Server, StyLua extension.
- Studio MCP successfully connected to Place1. Look up the current studio ID each session.
- Scripts: World.luau builds the preview map; main.server.luau owns theft/carrying/chase/hatching/coins/upgrades; main.client.luau supplies the HUD. Settings live in shared/GameConfig.luau.
- World: forest valley, creeks/bridges, crystals, cliffs, ruined nest gate, pedestals, hatchery shelter, horned guardian. Removed obsolete cyan sync-test pad. Scenery.luau owns decorative geometry; World.luau assembles the map.
- Setup validation passed: Rojo sourcemap and place build. VS Code tasks use .cmd scripts to work with the existing PowerShell policy. Reload VS Code to activate the newly installed extensions; editor diagnostics/formatting have not been visually verified yet.
- Git repository exists; no remote and no initial commit yet. No online backup configured.
- World backups: save the Studio place locally and publish privately for version history when the user is ready. Source builds do not contain the Studio-authored world.

## Next decisions

1. User playtests steal → escape → hatch → upgrade. Approach eggs and hold E; return to cyan hatchery. Gold block sells carry training for 60 coins.
2. Save Place1 to a known location; establish a separate backup of the Studio world.
3. Optionally connect a private GitHub repository for source backup.

## Work queue

Implemented: three egg species/weights/rewards, two-second guardian wake delay and speed 24, chase/catch, ten-second egg respawn, shaking/light-pulsing eggs, three-second hatch animation, species collection and one-time +100 bonus, carrying training, server stamina/sprint, drop action, touch/gamepad bindings, compact HUD.

Validation: Rojo sourcemap/build and standalone Luau LSP analysis passed. Live Studio tests passed: E-key pickup and carrying speed, hatch +20 coins/count/creature, guardian catch with no reward and speed reset, insufficient-funds rejection, upgrade 60→0 coins/level 0→1, egg respawn. Studio left in Edit mode; press Play for gameplay.

Expanded validation: collection completion gave 235 coins total (20+40+75+100), duplicate Mossling hatch gave only 20 more, sprint speed 27 with stamina drain, dropping restored speed without reward, death during incubation canceled reward/state, updated guardian caught a stationary carrier. Full light-egg route from nest to hatchery using character navigation at normal speed passed and awarded 20 coins after incubation. Screenshot inspected. Final Luau analysis and build passed.

Limits: session-only progress; direct guardian pursuit without pathfinding; shared hatchery; per-species displays can overlap between players. No persistence, trading, monetization, or imported assets. Multi-client/mobile layouts not yet tested. Preview regenerates from source each play.

Next: user feedback, multi-client tests and individual collection plots, saving after balancing. Studio left in Edit mode overlooking expanded map. No background feature work scheduled.
