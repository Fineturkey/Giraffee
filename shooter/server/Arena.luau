--!strict
local Arena = {}
function Arena.build()
    local old = workspace:FindFirstChild("CrossfireArena")
    if old then old:Destroy() end
    local model = Instance.new("Model")
    model.Name = "CrossfireArena"
    local function block(name: string, size: Vector3, pos: Vector3, color: Color3, neon: boolean?): Part
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = pos
        p.Anchored = true
        p.Color = color
        p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = model
        return p
    end
    local dark = Color3.fromRGB(31, 39, 58)
    local concrete = Color3.fromRGB(69, 83, 106)
    block("ArenaFloor", Vector3.new(180, 2, 140), Vector3.new(0, -1, 0), dark)
    for _, x in {-91, 91} do
        block("Boundary", Vector3.new(2, 24, 142), Vector3.new(x, 11, 0), dark)
        block("WallGlow", Vector3.new(2.2, 0.6, 140), Vector3.new(x, 6, 0), Color3.fromRGB(126, 112, 255), true)
    end
    for _, z in {-71, 71} do
        block("Boundary", Vector3.new(180, 24, 2), Vector3.new(0, 11, z), dark)
    end
    for _, x in {-60, -30, 0, 30, 60} do
        block("FloorSeam", Vector3.new(0.15, 0.04, 136), Vector3.new(x, 0.02, 0), Color3.fromRGB(70, 94, 121))
    end
    local spawns: { [string]: {SpawnLocation} } = { Red = {}, Blue = {} }
    for _, side in {-1, 1} do
        local name = if side == -1 then "Red" else "Blue"
        local color = if side == -1 then Color3.fromRGB(255, 95, 116) else Color3.fromRGB(74, 191, 255)
        block(name .. "Base", Vector3.new(22, 0.3, 110), Vector3.new(side * 76, 0.15, 0), color)
        for _, z in {-42, 0, 42} do
            local spawn = Instance.new("SpawnLocation")
            spawn.Name = name .. "Spawn"
            spawn.Anchored = true
            spawn.Size = Vector3.new(8, 0.5, 8)
            spawn.Position = Vector3.new(side * 77, 0.6, z)
            spawn.Neutral = false
            spawn.TeamColor = if name == "Red" then BrickColor.new("Really red") else BrickColor.new("Really blue")
            spawn.Duration = 2.5
            spawn.Transparency = 1
            spawn.Parent = model
            table.insert(spawns[name], spawn)
        end
        block(name .. "SpawnShield", Vector3.new(4, 12, 36), Vector3.new(side * 58, 6, 0), concrete)
        for _, z in {-38, 38} do
            block("LaneCover", Vector3.new(17, 7, 9), Vector3.new(side * 36, 3.5, z), concrete)
            block("CoverAccent", Vector3.new(17.2, 0.3, 9.2), Vector3.new(side * 36, 7.1, z), color, true)
            block("ShortCover", Vector3.new(8, 4, 13), Vector3.new(side * 14, 2, z * 0.55), concrete)
        end
        block("CenterPillar", Vector3.new(12, 15, 12), Vector3.new(side * 10, 7.5, 0), concrete)
        block("PillarLight", Vector3.new(12.2, 0.5, 12.2), Vector3.new(side * 10, 15.1, 0), color, true)
    end
    block("BridgeBeam", Vector3.new(34, 3, 10), Vector3.new(0, 16, 0), concrete)
    -- Readable team entrances and industrial detail outside the main firing lanes.
    local function sign(name: string, pos: Vector3, color: Color3)
        local p = block(name .. "Sign", Vector3.new(1, 1, 1), pos, dark)
        p.Transparency = 1
        p.CanCollide = false
        p.CanQuery = false
        local gui = Instance.new("BillboardGui")
        gui.Size = UDim2.fromOffset(200, 45)
        gui.MaxDistance = 100
        gui.Parent = p
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBold
        label.TextSize = 24
        label.Parent = gui
    end
    sign("RED BASE", Vector3.new(-76, 14, 0), Color3.fromRGB(255, 95, 116))
    sign("BLUE BASE", Vector3.new(76, 14, 0), Color3.fromRGB(74, 191, 255))
    for _, z in {-69, 69} do
        for _, x in {-28, 28} do
            local mirror = block("BankShotMirror", Vector3.new(24, 12, 1), Vector3.new(x, 7, z), Color3.fromRGB(118, 245, 227), true)
            mirror:SetAttribute("Ricochet", true)
            mirror.Reflectance = 0.4
            sign("ARC BANK SHOTS", mirror.Position + Vector3.new(0, 8, 0), Color3.fromRGB(145, 255, 224))
        end
    end
    for _, z in {-66, 66} do
        for _, x in {-65, -40, 0, 40, 65} do
            local p = block("WallColumn", Vector3.new(3, 18, 3), Vector3.new(x, 9, z), concrete)
            block("ColumnLight", Vector3.new(3.1, 0.4, 3.1), p.Position + Vector3.new(0, 8, 0), Color3.fromRGB(153, 132, 255), true)
        end
        for _, x in {-47, 47} do
            block("StorageCrate", Vector3.new(10, 5, 7), Vector3.new(x, 2.5, z - math.sign(z) * 8), Color3.fromRGB(53, 70, 87))
        end
    end
    local targets = Instance.new("Folder")
    targets.Name = "PracticeTargets"
    targets.Parent = model
    local lighting = game:GetService("Lighting")
    lighting.ClockTime = 15
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(110, 120, 145)
    lighting.FogEnd = 1000
    model.Parent = workspace
    return { Model = model, Spawns = spawns, Targets = targets }
end

function Arena.target(parent: Instance, position: Vector3): Model
    local model = Instance.new("Model")
    model.Name = "PracticeDrone"
    for _, spec in {
        {Name = "HumanoidRootPart", Size = Vector3.new(2, 2, 1), Offset = Vector3.zero},
        {Name = "Torso", Size = Vector3.new(3, 3, 2), Offset = Vector3.zero},
        {Name = "Head", Size = Vector3.new(2, 2, 2), Offset = Vector3.new(0, 2.5, 0)},
    } do
        local p = Instance.new("Part")
        p.Name = spec.Name
        p.Size = spec.Size
        p.Position = position + spec.Offset
        p.Anchored = true
        p.Color = Color3.fromRGB(255, 209, 98)
        p.Parent = model
        if p.Name == "HumanoidRootPart" then p.Transparency = 1; p.CanCollide = false end
    end
    local humanoid = Instance.new("Humanoid")
    humanoid.RequiresNeck = false
    humanoid.BreakJointsOnDeath = false
    humanoid.DisplayName = "PRACTICE DRONE"
    humanoid.Parent = model
    model:SetAttribute("PracticeTarget", true)
    model.Parent = parent
    return model
end
return Arena
