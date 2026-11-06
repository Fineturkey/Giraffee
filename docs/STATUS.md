# Current state

- Active game: Neon Crossfire, multiplayer first-person team deathmatch. User switched from Monster Egg on November 5, 2026.
- Active mappings: default.project.json and shooter.project.json. Source: shooter/server, shooter/client, shooter/shared, shooter/character.
- Monster Egg preserved in src/ and monster-egg.project.json. Previous status: docs/MONSTER-EGG-STATUS.md.
- Studio open with build/NeonCrossfire.rbxlx; arena preview generated; left in Edit mode. Look up studio IDs each session.
- Implemented: Red/Blue team assignment, three-lane arena, Pulse Blaster plus Arc Pistol, independent magazines, reload cancellation, head/body damage, server raycasts and validation, friendly-fire prevention, cover, spawn protection, respawns, K/D/wins, rounds, intermissions, solo drones, HUD, mouse/controller/touch actions.
- Signature mechanic: Arc Pistol reflects once off marked mint mirror panels; server computes the bounce with remaining range. Bent tracers and BANK SHOT feedback reveal ricochets. Arena has team signs, wall lights and storage crates.
- Weapon controls: 1/2 to select, Y/touch Swap to toggle, right mouse/L2/touch Aim to zoom. Confirmed-shot recoil, damage/headshot/elimination feedback and incoming-damage flash added.
- Health regeneration disabled with StarterCharacterScripts.Health so body hits are consistently 25 damage. Recover on respawn.
- Validation: build and strict Luau analysis passed. Real two-client StudioTestService test passed team assignment/round start, server damage, malformed/NaN rejection, rate limiting, friendly-fire protection, cover, reload locking/completion, elimination attribution, score-limit transition, win and respawn. Actual mouse input consumed ammo and eliminated a named practice drone. Arena/HUD screenshots inspected.
- Regression source: tests/shooter-multiplayer.server.luau (outside project mapping); temporary QA injection removed after test. Score of 9 supplied only in test fixture to exercise final elimination.
- Latest pass: Arc Pistol, independent magazines/reload cancellation, server bank-shot reflection, aim zoom/recoil, hit/headshot/elimination/incoming-damage feedback, arena mirrors and team signs. Production client remotes verified Arc switch (8 ammo), bank shot (40 damage, 7 ammo, BANK SHOT HUD), canceled-reload swap (still 7), keyboard 1 selection, and Pulse shot stopping at mirror (target unchanged, primary ammo 23). Build and strict analysis pass.
- Latest full two-client rerun remains inconclusive under the updated Studio: one run reached bank-shot/scoring assertions then hit an avatar respawn timing failure; later runs had avatar/protection setup timing or returned no result. Diagnostic now waits for SpawnReady and protection expiry; do not claim a fresh full-suite pass. Prior baseline multiplayer pass remains documented above. Temporary test script and solo fixtures removed; Studio left in Edit mode.
- Limits: prototype art, one map, session-only stats, no saved progression or matchmaking, no lag compensation; mobile/gamepad layouts and internet latency still need dedicated tests. Not published.
- User authorized GitHub push to https://github.com/Fineturkey/Giraffee. Origin uses that repository; active branch is main. Initial implementation commit: 8dad6fa. Local generated place is in ignored build/; source is retained. Save Studio-authored art separately.

## Next bounded work

Finish a stable full multiplayer rerun on the updated Studio, then user playtests bank shots with a friend. No recurring/background tasks scheduled.
