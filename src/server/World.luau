--!strict
local Config = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local World = {}
local Scenery = require(script.Parent.Scenery)

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
    local object = Instance.new("Part")
    object.Name = name
    object.Anchored = true
    object.Size = size
    object.Position = position
    object.Color = color
    object.Material = Enum.Material.SmoothPlastic
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.Parent = parent
    return object
end

local function sign(parent: BasePart, text: string, color: Color3)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(360, 80)
    gui.StudsOffset = Vector3.new(0, 6, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 65
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.Text = text
    label.Parent = gui
end

function World.build()
    local lighting = game:GetService("Lighting")
    lighting.ClockTime = 16.8
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(98, 109, 135)
    lighting.OutdoorAmbient = Color3.fromRGB(140, 153, 165)
    lighting.FogColor = Color3.fromRGB(155, 189, 193)
    lighting.FogStart = 120
    lighting.FogEnd = 480
    local baseplate = workspace:FindFirstChild("Baseplate")
    if baseplate and baseplate:IsA("BasePart") then
        baseplate.Color = Color3.fromRGB(54, 81, 67)
        baseplate.Material = Enum.Material.Grass
    end
    local existing = workspace:FindFirstChild("MonsterEggPrototype")
    if existing then existing:Destroy() end
    local root = Instance.new("Folder")
    root.Name = "MonsterEggPrototype"
    local ground = part(root, "Meadow", Vector3.new(130, 1, 170), Vector3.new(0, 0, -10), Color3.fromRGB(46, 78, 64))
    ground.Material = Enum.Material.Grass
    part(root, "Trail", Vector3.new(16, 0.15, 100), Vector3.new(0, 0.6, -10), Color3.fromRGB(117, 100, 77))
    local base = part(root, "Hatchery", Vector3.new(30, 1, 30), Config.BasePosition - Vector3.new(0, 1, 0), Color3.fromRGB(60, 220, 209))
    base.Material = Enum.Material.Neon
    sign(base, "SAFE HATCHERY\nBring an egg here to hatch it", Color3.fromRGB(158, 255, 242))
    local nest = part(root, "Nest", Vector3.new(34, 1, 22), Config.NestPosition - Vector3.new(0, 1, 0), Color3.fromRGB(122, 79, 54))
    sign(nest, "MONSTER NEST\nSteal an egg. Get back alive!", Color3.fromRGB(255, 220, 154))
    local upgrade = part(root, "Upgrade", Vector3.new(5, 5, 5), Config.BasePosition + Vector3.new(22, 1, 0), Color3.fromRGB(255, 205, 86))
    sign(upgrade, "CARRY TRAINING\n60 coins per level", Color3.fromRGB(255, 225, 130))
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Train (+2 carrying speed)"
    prompt.ObjectText = "Carry training • 60 coins"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.Parent = upgrade
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PrototypeSpawn"
    spawn.Anchored = true
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Config.BasePosition + Vector3.new(0, 0, 7)
    spawn.Neutral = true
    spawn.Duration = 0
    spawn.Transparency = 1
    spawn.Parent = root
    local monster = Instance.new("Model")
    monster.Name = "NestGuardian"
    local body = part(monster, "Body", Vector3.new(9, 9, 7), Config.NestPosition + Vector3.new(0, 4, -14), Color3.fromRGB(89, 57, 122))
    body.CanCollide = false
    monster.PrimaryPart = body
    for _, x in {-2.5, 2.5} do
        local eye = part(monster, "Eye", Vector3.new(1.4, 1.4, 0.5), body.Position + Vector3.new(x, 1.5, 3.6), Color3.fromRGB(255, 103, 89))
        eye.CanCollide = false
        eye.Material = Enum.Material.Neon
    end
    sign(body, "NEST GUARDIAN", Color3.fromRGB(255, 170, 190))
    monster.Parent = root
    local eggs = Instance.new("Folder")
    eggs.Name = "Eggs"
    eggs.Parent = root
    local creatures = Instance.new("Folder")
    creatures.Name = "HatchedCreatures"
    creatures.Parent = root
    for index = 1, 10 do
        local side = if index % 2 == 0 then 1 else -1
        local pos = Vector3.new(side * (34 + index % 3 * 7), 3, 60 - index * 14)
        local rock = part(root, "Rock", Vector3.new(7, 7, 7), pos, Color3.fromRGB(79, 96, 94))
        rock.Shape = Enum.PartType.Ball
        rock.Material = Enum.Material.Slate
    end
    Scenery.build(root)
    root.Parent = workspace
    return { Root = root, Eggs = eggs, Creatures = creatures, Monster = monster, Upgrade = prompt, Spawn = spawn }
end

return World
