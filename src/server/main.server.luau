--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local World = require(script.Parent.World)
local world = World.build()

type Carry = { Egg: Part, Index: number, Started: number, HatchStarted: number? }
local carrying: { [Player]: Carry } = {}
local monsterHome = world.Monster:GetPivot()
local sprinting: { [Player]: boolean } = {}
local stamina: { [Player]: number } = {}
local actionTimes: { [Player]: number } = {}
local actions = Instance.new("RemoteEvent")
actions.Name = "MonsterEggAction"
actions.Parent = ReplicatedStorage

local function carryLevel(player: Player): number
    local value = player:GetAttribute("CarryLevel")
    return if typeof(value) == "number" then value else 0
end

local function message(player: Player, text: string)
    player:SetAttribute("Message", text)
end

local function characterParts(player: Player): (BasePart?, Humanoid?)
    local character = player.Character
    if not character then return nil, nil end
    return character:FindFirstChild("HumanoidRootPart") :: BasePart?, character:FindFirstChildOfClass("Humanoid")
end

local function clearCarry(player: Player)
    local entry = carrying[player]
    if not entry then return end
    carrying[player] = nil
    entry.Egg:Destroy()
    player:SetAttribute("Carrying", "")
    player:SetAttribute("Danger", 0)
    player:SetAttribute("HatchProgress", 0)
    player:SetAttribute("Hatching", false)
    local _, humanoid = characterParts(player)
    if humanoid then humanoid.WalkSpeed = Config.WalkSpeed end
end

actions.OnServerEvent:Connect(function(player: Player, action: unknown, enabled: unknown)
    if typeof(action) ~= "string" then return end
    if action == "Sprint" and enabled == false then sprinting[player] = false; return end
    local now = os.clock()
    if now - (actionTimes[player] or 0) < 0.08 then return end
    actionTimes[player] = now
    if action == "Sprint" and typeof(enabled) == "boolean" then
        sprinting[player] = enabled
    elseif action == "Drop" and carrying[player] and not carrying[player].HatchStarted then
        clearCarry(player)
        message(player, "Egg abandoned! Your carrying speed is restored.")
    end
end)

local spawnEgg: (number) -> ()
spawnEgg = function(index: number)
    local definition = Config.Eggs[index]
    local egg = Instance.new("Part")
    egg.Name = definition.Name .. "Egg"
    egg.Shape = Enum.PartType.Ball
    egg.Size = Vector3.new(3, 4, 3)
    egg.Color = definition.Color
    egg.Material = Enum.Material.SmoothPlastic
    egg.Anchored = true
    local sparkle = Instance.new("PointLight")
    sparkle.Color = definition.Color
    sparkle.Range = 8
    sparkle.Brightness = 0.6
    sparkle.Parent = egg
    egg.CFrame = CFrame.new(Config.NestPosition + Vector3.new((index - 2) * 10, 2, 0))
    egg.Parent = world.Eggs
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Steal egg"
    prompt.ObjectText = definition.Name .. " • " .. definition.Value .. " coins"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 9
    prompt.Parent = egg
    local claimed = false
    prompt.Triggered:Connect(function(player: Player)
        local root, humanoid = characterParts(player)
        if claimed or carrying[player] or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - egg.Position).Magnitude > 12 then return end
        claimed = true
        prompt:Destroy()
        carrying[player] = { Egg = egg, Index = index, Started = os.clock() }
        egg.Anchored = false
        egg.CanCollide = false
        egg.Massless = true
        egg.CFrame = root.CFrame * CFrame.new(0, 0.5, -3)
        local weld = Instance.new("Weld")
        weld.Part0 = root
        weld.Part1 = egg
        weld.C0 = CFrame.new(0, 0.5, -3)
        weld.Parent = egg
        humanoid.WalkSpeed = math.min(Config.WalkSpeed, definition.Speed + carryLevel(player) * 2)
        player:SetAttribute("Carrying", definition.Name)
        message(player, "RUN TO THE CYAN HATCHERY! Guardian wakes in " .. Config.WakeDelay .. " seconds.")
        task.delay(Config.RespawnSeconds, function()
            if world.Root.Parent then spawnEgg(index) end
        end)
    end)
end

local function hatch(player: Player, entry: Carry)
    local definition = Config.Eggs[entry.Index]
    clearCarry(player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end
    local coins = stats:FindFirstChild("Coins") :: IntValue
    local hatched = stats:FindFirstChild("Hatched") :: IntValue
    coins.Value += definition.Value
    hatched.Value += 1
    local previous = world.Creatures:FindFirstChild(tostring(player.UserId))
    local display: Instance = previous or Instance.new("Folder")
    if not previous then
        display.Name = tostring(player.UserId)
        display.Parent = world.Creatures
    end
    local known = player:GetAttribute("Found" .. entry.Index) == true
    if not known then player:SetAttribute("Found" .. entry.Index, true) end
    local collection = 0
    for index in Config.Eggs do
        if player:GetAttribute("Found" .. index) then collection += 1 end
    end
    player:SetAttribute("Collection", collection)
    if collection == #Config.Eggs and not player:GetAttribute("CollectionReward") then
        player:SetAttribute("CollectionReward", true)
        coins.Value += Config.CollectionBonus
    end
    local oldSpecies = display:FindFirstChild(definition.Name)
    if oldSpecies then oldSpecies:Destroy() end
    local creature = Instance.new("Part")
    creature.Name = definition.Name
    creature.Shape = Enum.PartType.Ball
    creature.Size = Vector3.new(3, 3, 3)
    creature.Anchored = true
    creature.CanCollide = false
    creature.Color = definition.Color
    creature.Position = Config.BasePosition + Vector3.new((entry.Index - 2) * 7, 2, -5)
    creature:SetAttribute("Species", definition.Name)
    creature.Parent = display
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.fromOffset(140, 36)
    tag.StudsOffset = Vector3.new(0, 3, 0)
    tag.MaxDistance = 40
    tag.Parent = creature
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.fromScale(1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = definition.Name
    nameLabel.TextColor3 = definition.Color
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = tag
    for _, x in {-0.65, 0.65} do
        local eye = Instance.new("Part")
        eye.Size = Vector3.new(0.5, 0.5, 0.4)
        eye.Anchored = true
        eye.CanCollide = false
        eye.Color = Color3.new(0.05, 0.05, 0.08)
        eye.Position = creature.Position + Vector3.new(x, 0.4, 1.4)
        eye.Parent = creature
    end
    message(player, "HATCHED " .. definition.Name .. "! +" .. definition.Value .. " coins" .. (if not known then " • NEW DISCOVERY!" else "") .. (if collection == #Config.Eggs and not known then " • COLLECTION COMPLETE! +100 coins" else ""))
end

local function setupPlayer(player: Player)
    if player:FindFirstChild("leaderstats") then return end
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    for _, name in {"Coins", "Hatched"} do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Parent = stats
    end
    stats.Parent = player
    player.RespawnLocation = world.Spawn
    player:SetAttribute("CarryLevel", 0)
    player:SetAttribute("Carrying", "")
    player:SetAttribute("Danger", 0)
    player:SetAttribute("Collection", 0)
    player:SetAttribute("Hatching", false)
    player:SetAttribute("HatchProgress", 0)
    player:SetAttribute("Stamina", 100)
    stamina[player] = 100
    message(player, "Find the monster nest. Hold E on an egg, then escape to the cyan hatchery.")
    local function onCharacter(character: Model)
        clearCarry(player)
        sprinting[player] = false
        stamina[player] = 100
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = Config.WalkSpeed
        humanoid.Died:Connect(function() clearCarry(player) end)
        local root = character:WaitForChild("HumanoidRootPart") :: BasePart
        root.CFrame = CFrame.new(Config.BasePosition + Vector3.new(0, 5, 7))
    end
    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

world.Upgrade.Triggered:Connect(function(player: Player)
    local root, humanoid = characterParts(player)
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - (world.Upgrade.Parent :: BasePart).Position).Magnitude > 12 then return end
    local level = carryLevel(player)
    local stats = player:FindFirstChild("leaderstats")
    local coins = if stats then stats:FindFirstChild("Coins") :: IntValue? else nil
    if level >= Config.MaxUpgradeLevel then message(player, "Carry training is maxed!"); return end
    if not coins or coins.Value < Config.UpgradeCost then message(player, "You need 60 coins. Hatch more eggs!"); return end
    coins.Value -= Config.UpgradeCost
    player:SetAttribute("CarryLevel", level + 1)
    local entry = carrying[player]
    if entry then humanoid.WalkSpeed = math.min(Config.WalkSpeed, Config.Eggs[entry.Index].Speed + (level + 1) * 2) end
    message(player, "Carry training level " .. (level + 1) .. "! Heavy eggs are easier to escape with.")
end)

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do setupPlayer(player) end
Players.PlayerRemoving:Connect(function(player: Player)
    clearCarry(player)
    stamina[player] = nil
    sprinting[player] = nil
    actionTimes[player] = nil
    local creature = world.Creatures:FindFirstChild(tostring(player.UserId))
    if creature then creature:Destroy() end
end)
for index in Config.Eggs do spawnEgg(index) end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt: number)
    accumulator += dt
    if accumulator < 0.1 then return end
    local step = math.min(accumulator, 0.25)
    accumulator = 0
    local target: BasePart? = nil
    local nearest = math.huge
    local monsterPosition = world.Monster:GetPivot().Position
    for _, player in Players:GetPlayers() do
        local _, humanoid = characterParts(player)
        if not humanoid then continue end
        local entry = carrying[player]
        local energy = stamina[player] or 100
        local moving = humanoid.MoveDirection.Magnitude > 0.1
        local sprint = sprinting[player] and energy > 5 and moving and not (entry and entry.HatchStarted)
        energy = math.clamp(energy + (if sprint then -Config.SprintDrain else Config.StaminaRecovery) * step, 0, 100)
        stamina[player] = energy
        player:SetAttribute("Stamina", math.floor(energy))
        local speed = if entry then math.min(Config.WalkSpeed, Config.Eggs[entry.Index].Speed + carryLevel(player) * 2) else Config.WalkSpeed
        humanoid.WalkSpeed = speed + (if sprint then Config.SprintBonus else 0)
    end
    for player, entry in carrying do
        local root, humanoid = characterParts(player)
        if not root or not humanoid or humanoid.Health <= 0 then clearCarry(player); continue end
        if entry.HatchStarted then
            local progress = math.clamp((os.clock() - entry.HatchStarted) / Config.HatchSeconds, 0, 1)
            player:SetAttribute("HatchProgress", math.floor(progress * 100))
            entry.Egg.CFrame = CFrame.new(Config.BasePosition + Vector3.new((entry.Index - 2) * 6, 3, 0)) * CFrame.Angles(0, os.clock() * 3, math.sin(os.clock() * 22) * 0.12)
            if progress >= 1 then hatch(player, entry) end
            continue
        end
        if (root.Position - Config.BasePosition).Magnitude <= Config.SafeRadius then
            entry.HatchStarted = os.clock()
            local weld = entry.Egg:FindFirstChildOfClass("Weld")
            if weld then weld:Destroy() end
            entry.Egg.Anchored = true
            player:SetAttribute("Hatching", true)
            player:SetAttribute("Danger", 0)
            message(player, "EGG SECURED! Hatching your creature...")
            continue
        end
        local age = os.clock() - entry.Started
        local weld = entry.Egg:FindFirstChildOfClass("Weld")
        if weld then
            weld.C0 = CFrame.new(0, 0.5, -3) * CFrame.Angles(0, 0, math.sin(age * 14) * math.min(0.16, age * 0.025))
            local light = entry.Egg:FindFirstChildOfClass("PointLight")
            if light then light.Brightness = 1 + math.sin(age * 10) * 0.6 end
        end
        player:SetAttribute("Danger", math.min(100, math.floor(age / Config.WakeDelay * 100)))
        if age >= Config.WakeDelay then
            local distance = (root.Position - monsterPosition).Magnitude
            if distance <= Config.CatchDistance then
                clearCarry(player)
                root.CFrame = CFrame.new(Config.BasePosition + Vector3.new(0, 5, 7))
                message(player, "CAUGHT! You lost the egg. Try a lighter one or train your carrying.")
            elseif distance < nearest then nearest = distance; target = root end
        end
    end
    local destination = if target then Vector3.new(target.Position.X, monsterHome.Position.Y, target.Position.Z) else monsterHome.Position
    world.Monster:SetAttribute("Awake", target ~= nil)
    local body = world.Monster.PrimaryPart
    if body then body.Color = if target then Color3.fromRGB(155, 63, 105) else Color3.fromRGB(89, 57, 122) end
    local delta = destination - monsterPosition
    if delta.Magnitude > 0.1 then
        local nextPosition = monsterPosition + delta.Unit * math.min(delta.Magnitude, Config.MonsterSpeed * step)
        world.Monster:PivotTo(CFrame.lookAt(nextPosition, nextPosition - delta.Unit))
    end
end)
print("[Monster Egg] Ready: steal, escape, hatch, upgrade. Session-only prototype; progress is not saved.")
