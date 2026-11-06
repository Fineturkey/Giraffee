# Shooter regression test

`shooter-multiplayer.server.luau` is a temporary Studio diagnostic, excluded from all Rojo project mappings. It exercises production combat with two real local clients. Test avatars are anchored during ray assertions to avoid client network ownership moving the fixtures.

Run only in a disposable local test: insert the source as ServerScriptService.CrossfireMultiplayerQA in Edit mode, invoke StudioTestService:ExecuteMultiplayerTestAsync(2, "CrossfireQA"), read the returned PASS/FAIL string, and remove the injected script afterward. The server script calls EndTest. It supplies a score of 9 to test the final elimination/round transition without playing ten full eliminations.

Keep test fixtures out of published games. Manual input testing is still needed for weapon feel and device layouts; this is a rules/network integration check.
