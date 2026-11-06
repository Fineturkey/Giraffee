--!strict
-- Decorative geometry stays clear of the central chase route.
local Scenery = {}
function Scenery.build(parent: Instance)
    local folder = Instance.new("Folder")
    folder.Name = "Scenery"
    local function block(name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?): Part
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = pos
        p.Anchored = true
        p.Color = color
        p.Material = material or Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.Parent = folder
        return p
    end
    local function orb(name: string, size: Vector3, pos: Vector3, color: Color3): Part
        local p = block(name, size, pos, color)
        p.Shape = Enum.PartType.Ball
        return p
    end
    local green = Color3.fromRGB(45, 110, 83)
    local stone = Color3.fromRGB(58, 68, 83)
    local wood = Color3.fromRGB(89, 63, 48)
    for i = 1, 24 do
        local side = if i % 2 == 0 then 1 else -1
        local x = side * (43 + (i % 3) * 8)
        local z = 68 - math.floor((i - 1) / 2) * 13
        local height = 12 + i % 4 * 3
        block("TreeTrunk", Vector3.new(2.5, height, 2.5), Vector3.new(x, height / 2, z), wood, Enum.Material.Wood)
        orb("TreeCrown", Vector3.new(13, 14, 13), Vector3.new(x, height + 2, z), green:Lerp(Color3.fromRGB(91, 153, 107), (i % 4) / 5))
        if i % 3 == 0 then
            local crystal = block("GlowCrystal", Vector3.new(2, 5, 2), Vector3.new(x - side * 5, 2, z + 3), Color3.fromRGB(109, 228, 255), Enum.Material.Neon)
            crystal.CFrame *= CFrame.Angles(0, 0, math.rad(18))
        end
    end
    -- Mountain silhouettes frame the valley, rather than obstructing the chase.
    for i = 1, 9 do
        local mountain = orb("Cliff", Vector3.new(30, 35 + i % 3 * 9, 25), Vector3.new((i - 5) * 22, 8, -100), stone)
        mountain.Material = Enum.Material.Slate
    end
    for _, side in {-1, 1} do
        local water = block("Creek", Vector3.new(17, 0.3, 64), Vector3.new(side * 30, 0.7, -8), Color3.fromRGB(55, 159, 193), Enum.Material.Glass)
        water.Transparency = 0.25
        water.CanCollide = false
        for j = 1, 8 do
            block("BridgePlank", Vector3.new(18, 0.7, 2.2), Vector3.new(side * 30, 1.1, -2 + j * 2.5), wood, Enum.Material.WoodPlanks)
        end
        block("GatePillar", Vector3.new(5, 18, 5), Vector3.new(side * 19, 9, -48), stone, Enum.Material.Slate)
        orb("GateLantern", Vector3.new(3, 3, 3), Vector3.new(side * 19, 19, -48), Color3.fromRGB(185, 129, 255)).Material = Enum.Material.Neon
        -- Hatchery shelter: side supports and roof leave the runway open.
        for _, z in {35, 56} do
            block("HatcheryPost", Vector3.new(1.5, 11, 1.5), Vector3.new(side * 13, 6, z), wood, Enum.Material.Wood)
        end
        for j = 1, 7 do
            orb("NestBoulder", Vector3.new(4, 3, 4), Vector3.new(side * 17, 1.5, -54 - j * 3), stone)
        end
    end
    block("NestArch", Vector3.new(43, 4, 5), Vector3.new(0, 19, -48), stone, Enum.Material.Slate)
    block("HatcheryRoof", Vector3.new(31, 2, 28), Vector3.new(0, 13, 45), Color3.fromRGB(37, 78, 92), Enum.Material.WoodPlanks)
    for i = 1, 3 do
        local pad = block("EggPedestal", Vector3.new(7, 1, 7), Vector3.new((i - 2) * 10, 1.8, -65), stone, Enum.Material.Slate)
        local ring = block("PedestalGlow", Vector3.new(7.2, 0.15, 7.2), pad.Position + Vector3.new(0, 0.55, 0), ({Color3.fromRGB(121,238,147),Color3.fromRGB(255,155,74),Color3.fromRGB(186,135,255)})[i], Enum.Material.Neon)
        ring.CanCollide = false
    end
    for i = 1, 9 do
        local arrow = block("TrailMarker", Vector3.new(1.8, 0.1, 3), Vector3.new(0, 0.8, 32 - i * 8), Color3.fromRGB(255, 222, 151), Enum.Material.Neon)
        arrow.CanCollide = false
    end
    -- Guardian details match its purple body; parented to model so they follow its pivot.
    local guardian = parent:FindFirstChild("NestGuardian") :: Model
    local body = guardian.PrimaryPart :: BasePart
    for _, side in {-1, 1} do
        local horn = block("Horn", Vector3.new(2, 5, 2), body.Position + Vector3.new(side * 3, 5, 0), Color3.fromRGB(241, 220, 175))
        horn.CanCollide = false
        horn.CFrame *= CFrame.Angles(0, 0, math.rad(-side * 20))
        horn.Parent = guardian
        local foot = block("Foot", Vector3.new(3, 2, 5), body.Position + Vector3.new(side * 3, -4, 1), Color3.fromRGB(61, 43, 89))
        foot.CanCollide = false
        foot.Parent = guardian
    end
    local mouth = block("Mouth", Vector3.new(4, 0.7, 0.4), body.Position + Vector3.new(0, -1, 3.6), Color3.fromRGB(26, 22, 35))
    mouth.CanCollide = false
    mouth.Parent = guardian
    folder.Parent = parent
end
return Scenery
