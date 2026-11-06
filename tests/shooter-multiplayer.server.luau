--!strict
-- Diagnostic only: injected temporarily for StudioTestService; never part of a release build.
local service = game:GetService("StudioTestService")
local Players = game:GetService("Players")
local function run()
    local deadline = os.clock() + 40
    repeat task.wait(0.2) until #Players:GetPlayers() >= 2 or os.clock() > deadline
    assert(#Players:GetPlayers() >= 2, "Two test clients must join")
    local state = game.ReplicatedStorage:WaitForChild("CrossfireState")
    repeat task.wait(0.2) until state:GetAttribute("Phase") == "Live" or os.clock() > deadline
    assert(state:GetAttribute("Phase") == "Live", "Round should start with opposing players")
    local players = Players:GetPlayers()
    local a, b = players[1], players[2]
    local loadDeadline = os.clock() + 30
    local function ready(p: Player): boolean
        local c = p.Character
        return p:GetAttribute("SpawnReady") == true and c ~= nil and c:FindFirstChild("HumanoidRootPart") ~= nil and c:FindFirstChild("PulseBlaster") ~= nil
    end
    repeat task.wait(0.2) until (ready(a) and ready(b)) or os.clock() > loadDeadline
    assert(ready(a) and ready(b), "Both avatars loaded and equipped")
    task.wait(3) -- Let both engine and scripted spawn-protection windows expire.
    assert(a.Team ~= b.Team, "Teams balanced")
    local combat = require(game.ServerScriptService.Server.Combat)
    local function position()
        a.Character:PivotTo(CFrame.new(-15, 4, 55))
        b.Character:PivotTo(CFrame.new(15, 4, 55))
        -- Keep network-owned avatars stationary during deterministic ray assertions.
        a.Character.HumanoidRootPart.Anchored = true
        b.Character.HumanoidRootPart.Anchored = true
        for _, p in {a,b} do
            local shield = p.Character:FindFirstChildOfClass("ForceField")
            if shield then shield:Destroy() end
        end
        task.wait(0.2)
    end
    local function aim(): Vector3
        return (b.Character.HumanoidRootPart.Position - a.Character.Head.Position).Unit
    end
    position()
    local h = b.Character:FindFirstChildOfClass("Humanoid") :: Humanoid
    assert(combat.fire(a, "invalid", true) == nil, "Reject malformed aim")
    assert(combat.fire(a, Vector3.new(0/0, 0, 0), true) == nil, "Reject NaN")
    local shot = combat.fire(a, aim(), true)
    assert(shot and shot.Hit and h.Health == 75, "Server raycast deals 25 body damage: health=" .. h.Health .. ", accepted=" .. tostring(shot ~= nil))
    assert(combat.fire(a, aim(), true) == nil, "Reject excessive firing rate")
    task.wait(0.15)
    local team = b.Team
    b.Team = a.Team
    combat.fire(a, aim(), true)
    assert(h.Health == 75, "Friendly fire blocked")
    b.Team = team
    task.wait(0.15)
    local wall = Instance.new("Part")
    wall.Anchored = true
    wall.Size = Vector3.new(2, 14, 14)
    wall.Position = Vector3.new(0, 6, 55)
    wall.Parent = workspace
    combat.fire(a, aim(), true)
    assert(h.Health == 75, "Cover blocks damage")
    wall:Destroy()
    assert(combat.reload(a), "Reload starts after shots")
    assert(combat.fire(a, aim(), true) == nil, "Cannot fire while reloading")
    task.wait(1.9)
    assert(a:GetAttribute("Ammo") == 24 and a:GetAttribute("Reloading") == false, "Reload completes")
    -- Weapon swap/reload cancellation must preserve separate magazines.
    assert(not combat.switch(a, "NotAWeapon"), "Reject unknown weapon")
    assert(combat.switch(a, "Arc"), "Switch to sidearm")
    task.wait(0.5)
    local pistolShot = combat.fire(a, aim(), true)
    assert(pistolShot and pistolShot.Damage == 40 and h.Health == 35, "Sidearm body damage and feedback")
    assert(a:GetAttribute("Ammo") == 7, "Sidearm magazine consumed")
    assert(combat.fire(a, aim(), true) == nil, "Sidearm fire rate enforced")
    local mirror = Instance.new("Part")
    mirror.Name = "TestMirror"
    mirror.Size = Vector3.new(40, 16, 1)
    mirror.Anchored = true
    mirror.Position = Vector3.new(0, 6, 64)
    mirror:SetAttribute("Ricochet", true)
    mirror.Parent = workspace
    h.Health = 100
    task.wait(0.5)
    local rootPosition = b.Character.HumanoidRootPart.Position
    local virtualTarget = Vector3.new(rootPosition.X, rootPosition.Y, 127 - rootPosition.Z)
    local bank = combat.fire(a, (virtualTarget - a.Character.Head.Position).Unit, true)
    assert(bank and bank.Bounce and bank.Hit and h.Health == 60, "Single bank shot hits opponent for 40")
    mirror:Destroy()
    assert(combat.reload(a), "Sidearm reload starts")
    assert(combat.switch(a, "Pulse"), "Switch cancels reload")
    task.wait(0.4)
    assert(a:GetAttribute("Ammo") == 24, "Primary ammo retained")
    assert(combat.switch(a, "Arc"), "Switch back")
    task.wait(1.5)
    assert(a:GetAttribute("Ammo") == 6 and a:GetAttribute("Reloading") == false, "Canceled reload cannot refill sidearm")
    assert(combat.switch(a, "Pulse"), "Return to primary")
    task.wait(0.2)
    h.Health = 75
    -- Score fixture exercises the real final-elimination transition.
    local scoreName = if a.Team.Name == "Red" then "RedScore" else "BlueScore"
    state:SetAttribute(scoreName, 9)
    local shots = {}
    for _ = 1, 3 do
        local hit = combat.fire(a, aim(), true)
        table.insert(shots, tostring(hit and hit.Hit) .. ":" .. h.Health)
        task.wait(0.18)
    end
    assert(h.Health == 0, "Enemy eliminated: " .. table.concat(shots, ","))
    assert(a.leaderstats.Kills.Value == 1 and b.leaderstats.Deaths.Value == 1, "K/D recorded once")
    task.wait(1.2)
    assert(state:GetAttribute("Phase") == "Intermission", "Score limit ends round")
    assert(a.leaderstats.Wins.Value == 1, "Winning team receives win")
    local respawnDeadline = os.clock() + 20
    local respawned = false
    repeat
        task.wait(0.25)
        local character = b.Character
        local alive = character and character:FindFirstChildOfClass("Humanoid")
        respawned = alive ~= nil and alive.Health > 0
    until respawned or os.clock() > respawnDeadline
    assert(respawned, "Victim respawns within loading deadline")
    return "PASS: two clients, damage, team/cover validation, reloads, sidearm damage/rate, weapon swaps, separate ammo, canceled reload, scoring, win and respawn"
end
local ok, result = pcall(run)
print("CROSSFIRE_QA: " .. (if ok then tostring(result) else "FAIL: " .. tostring(result)))
service:EndTest(if ok then result else "FAIL: " .. tostring(result))
