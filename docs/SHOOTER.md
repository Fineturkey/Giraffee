# Neon Crossfire

Active project: default.project.json (also shooter.project.json). Code is in shooter/. Monster Egg is preserved in src/ and monster-egg.project.json.

Team deathmatch: Red versus Blue, first to 10 eliminations or highest score after three minutes. Eight-second intermission, automatic respawns, brief spawn protection. Joining players are assigned to the smaller team; an empty team is refilled when someone leaves.

Pulse Blaster: hold left click / right trigger / touch FIRE. R / X / touch Reload. 24-round magazine, 1.7-second reload, 25 body damage and 40 head damage. Ammo, rate of fire, equipped/alive checks, raycasts, damage, team checks, and scores live on the server. Spawn protection prevents firing and receiving damage. Automatic health regeneration is disabled; health returns on respawn.

Solo play is warmup with three gold practice drones that respawn. They do not count toward competitive scores. A round starts once both teams have a player.

Second loadout: Arc Pistol (8 shots, 40 body / 65 head damage, 0.42-second fire interval, 1.3-second reload). Use 1/2 to select a weapon, Y on controller or touch Swap to toggle. Each weapon keeps its own magazine; swapping cancels reload and cannot refill ammo. Hold right mouse/L2/touch Aim for zoom. Confirmed shots provide recoil; damage, headshots, eliminations and incoming damage have HUD feedback.

Signature mechanic: Arc Pistol shots bounce once off marked mint mirror panels. Use them to hit around cover. The server computes the reflected ray and preserves the remaining range; the Pulse Blaster cannot bounce. Bent mint tracers and BANK SHOT feedback identify successful ricochets. This is the first distinct mechanic, not a claim that the game is ready for release.

Open build/NeonCrossfire.rbxlx in Studio. Use Rojo with default.project.json for ongoing file sync; Ctrl+Shift+B checks the active project. The generated arena is rebuilt from shooter/server/Arena.luau each session. Save a separate place if making Studio-authored art changes.

Multiplayer regression test: tests/shooter-multiplayer.server.luau is diagnostic only. Inject it temporarily into ServerScriptService, invoke StudioTestService:ExecuteMultiplayerTestAsync(2, "CrossfireQA"), then remove the injected script. It must never be part of the release mapping. It checks real two-player combat/rules using the production combat module and ends the test with a result.

Prototype limitations: one arena/weapon, session-only stats, no matchmaking or saved progression, no lag compensation. Mobile/controller bindings are present; device-specific layouts and online latency need separate testing.
