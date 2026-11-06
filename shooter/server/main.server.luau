--!strict
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Arena = require(script.Parent.Arena)
local Combat = require(script.Parent.Combat)
local arena = Arena.build()
Players.RespawnTime = 3
local red = Instance.new("Team")
red.Name = "Red"
red.TeamColor = BrickColor.new("Really red")
red.AutoAssignable = false
red.Parent = Teams
local blue = Instance.new("Team")
blue.Name = "Blue"
blue.TeamColor = BrickColor.new("Really blue")
blue.AutoAssignable = false
blue.Parent = Teams

local state = Instance.new("Folder")
state.Name = "CrossfireState"
state.Parent = ReplicatedStorage
state:SetAttribute("Phase", "Warmup")
state:SetAttribute("RedScore", 0)
state:SetAttribute("BlueScore", 0)
state:SetAttribute("Seconds", Config.RoundSeconds)
local action = Instance.new("RemoteEvent")
action.Name = "CrossfireAction"
action.Parent = ReplicatedStorage
local effects = Instance.new("RemoteEvent")
effects.Name = "CrossfireEffects"
effects.Parent = ReplicatedStorage
local lastAction: { [Player]: number } = {}
local phase = "Warmup"

local function equip(player: Player, character: Model)
    player:SetAttribute("SpawnReady", false)
    local hum = character:WaitForChild("Humanoid", 10) :: Humanoid?
    local root = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
    if not hum or not root or player.Character ~= character then return end
    hum.WalkSpeed = Config.WalkSpeed
    Combat.reset(player)
    local teamName = if player.Team == red then "Red" else "Blue"
    local points = arena.Spawns[teamName]
    local spawn = points[math.random(1, #points)]
    root.CFrame = CFrame.lookAt(spawn.Position + Vector3.new(0, 4, 0), Vector3.new(0, 4, spawn.Position.Z))
    if not character:FindFirstChildOfClass("ForceField") then
        local shield = Instance.new("ForceField")
        shield.Parent = character
        game:GetService("Debris"):AddItem(shield, Config.SpawnProtection)
    end
    local tool = Instance.new("Tool")
    tool.Name = "PulseBlaster"
    tool.CanBeDropped = false
    tool.ToolTip = "Hold fire • R to reload"
    tool.Grip = CFrame.new(0, -0.25, 0.4)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.6, 0.8, 2.5)
    handle.Color = Color3.fromRGB(38, 45, 63)
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Massless = true
    handle.Parent = tool
    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.35, 0.35, 1.2)
    barrel.Color = if player.Team == red then Config.Red else Config.Blue
    barrel.Material = Enum.Material.Neon
    barrel.CanCollide = false
    barrel.Massless = true
    barrel.CFrame = handle.CFrame * CFrame.new(0, 0.15, -1.4)
    barrel.Parent = tool
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = barrel
    weld.Parent = barrel
    tool.Parent = player:WaitForChild("Backpack")
    hum:EquipTool(tool)
    player:SetAttribute("SpawnReady", true)
    hum.Died:Connect(function()
        player:SetAttribute("SpawnReady", false)
        local stats = player:FindFirstChild("leaderstats")
        if stats then (stats:FindFirstChild("Deaths") :: IntValue).Value += 1 end
        local killer = Combat.killer(hum)
        if killer and killer ~= player and killer.Team ~= player.Team and phase == "Live" then
            local killerStats = killer:FindFirstChild("leaderstats")
            if killerStats then (killerStats:FindFirstChild("Kills") :: IntValue).Value += 1 end
            local score = if killer.Team == red then "RedScore" else "BlueScore"
            state:SetAttribute(score, (state:GetAttribute(score) :: number) + 1)
            effects:FireAllClients("Elimination", killer.DisplayName .. " eliminated " .. player.DisplayName)
        end
    end)
end

local function join(player: Player)
    player.Team = if #red:GetPlayers() <= #blue:GetPlayers() then red else blue
    player.Neutral = false
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    for _, name in {"Kills", "Deaths", "Wins"} do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Parent = stats
    end
    stats.Parent = player
    player.CharacterAdded:Connect(function(char) equip(player, char) end)
    if player.Character then task.spawn(equip, player, player.Character) end
end
Players.PlayerAdded:Connect(join)
for _, player in Players:GetPlayers() do join(player) end
Players.PlayerRemoving:Connect(function(player)
    Combat.remove(player)
    lastAction[player] = nil
    task.defer(function()
        local r, b = red:GetPlayers(), blue:GetPlayers()
        if #r + #b >= 2 and (#r == 0 or #b == 0) then
            local donor = if #r > #b then r else b
            local moved = donor[#donor]
            moved.Team = if #r == 0 then red else blue
            task.spawn(function() moved:LoadCharacterAsync() end)
        end
    end)
end)
action.OnServerEvent:Connect(function(player: Player, command: unknown, direction: unknown)
    if phase == "Intermission" then return end
    local now = os.clock()
    if now - (lastAction[player] or 0) < 0.04 then return end
    lastAction[player] = now
    if command == "Reload" then Combat.reload(player)
    elseif command == "Switch" then
        if Combat.switch(player, direction) then
            local tool = player.Character and player.Character:FindFirstChild("PulseBlaster")
            local handle = tool and tool:FindFirstChild("Handle") :: BasePart?
            if handle then handle.Size = if direction == "Arc" then Vector3.new(0.5, 0.7, 1.4) else Vector3.new(0.6, 0.8, 2.5) end
        end
    elseif command == "Fire" then
        local result = Combat.fire(player, direction, phase == "Live")
        if result then
            effects:FireAllClients("Shot", player.UserId, result.Origin, result.Endpoint, result.Hit, result.Bounce)
            if result.Hit then effects:FireClient(player, "Feedback", result.Damage, result.Headshot, result.Eliminated, result.Bounce ~= nil) end
        end
    end
end)

local function addTarget(position: Vector3)
    local target = Arena.target(arena.Targets, position)
    local hum = target:FindFirstChildOfClass("Humanoid") :: Humanoid
    hum.Died:Once(function()
        task.delay(2, function()
            target:Destroy()
            if phase == "Warmup" then addTarget(position) end
        end)
    end)
end
local function targets(enabled: boolean)
    arena.Targets:ClearAllChildren()
    if enabled then
        for _, z in {-38, 0, 38} do addTarget(Vector3.new(0, 3, z)) end
    end
end
local function enoughPlayers(): boolean
    return #red:GetPlayers() > 0 and #blue:GetPlayers() > 0
end
local function resetPlayers()
    for _, player in Players:GetPlayers() do
        player:SetAttribute("SpawnReady", false)
        task.spawn(function() player:LoadCharacterAsync() end)
    end
end
targets(true)
task.spawn(function()
    while true do
        task.wait(1)
        if phase == "Warmup" and enoughPlayers() then
            phase = "Live"
            targets(false)
            state:SetAttribute("RedScore", 0)
            state:SetAttribute("BlueScore", 0)
            state:SetAttribute("Seconds", Config.RoundSeconds)
            state:SetAttribute("Winner", "")
            resetPlayers()
        elseif phase == "Live" then
            state:SetAttribute("Seconds", (state:GetAttribute("Seconds") :: number) - 1)
            local r = state:GetAttribute("RedScore") :: number
            local b = state:GetAttribute("BlueScore") :: number
            if not enoughPlayers() then
                phase = "Warmup"
                targets(true)
            elseif r >= Config.ScoreToWin or b >= Config.ScoreToWin or (state:GetAttribute("Seconds") :: number) <= 0 then
                phase = "Intermission"
                local winner = if r == b then "Draw" elseif r > b then "Red" else "Blue"
                state:SetAttribute("Winner", winner)
                state:SetAttribute("Seconds", Config.Intermission)
                for _, player in Players:GetPlayers() do
                    if player.Team and player.Team.Name == winner then
                        (player.leaderstats.Wins :: IntValue).Value += 1
                    end
                end
            end
        elseif phase == "Intermission" then
            state:SetAttribute("Seconds", (state:GetAttribute("Seconds") :: number) - 1)
            if (state:GetAttribute("Seconds") :: number) <= 0 then
                phase = "Warmup"
                targets(true)
                resetPlayers()
            end
        end
        state:SetAttribute("Phase", phase)
    end
end)
print("[Crossfire] Ready: team deathmatch, server combat, reloads, respawns and solo practice.")
