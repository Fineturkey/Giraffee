--!strict
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Combat = {}
type Shot = { Origin: Vector3, Endpoint: Vector3, Hit: boolean, Damage: number, Headshot: boolean, Eliminated: boolean, Bounce: Vector3? }
type WeaponState = { Ammo: number, LastShot: number, Reloading: boolean, Generation: number, Weapon: string, Reserve: { [string]: number }, LastSwitch: number }
local states: { [Player]: WeaponState } = {}
local tags: { [Humanoid]: { Player: Player, Time: number } } = setmetatable({}, {__mode = "k"}) :: any

function Combat.reset(player: Player)
    local old = states[player]
    states[player] = {Ammo = Config.Magazine, LastShot = 0, Reloading = false, Generation = if old then old.Generation + 1 else 1, Weapon = "Pulse", Reserve = {Pulse = 24, Arc = 8}, LastSwitch = 0}
    player:SetAttribute("Ammo", Config.Magazine)
    player:SetAttribute("Reloading", false)
    player:SetAttribute("Weapon", "Pulse")
end
function Combat.switch(player: Player, id: unknown): boolean
    if typeof(id) ~= "string" or not Config.Weapons[id] then return false end
    local state = states[player]
    local char = player.Character
    local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
    if not state or state.Weapon == id or not char or not hum or hum.Health <= 0 or not char:FindFirstChild("PulseBlaster") or os.clock() - state.LastSwitch < 0.3 then return false end
    state.Reserve[state.Weapon] = state.Ammo
    state.Generation += 1
    state.Reloading = false
    state.Weapon = id
    state.Ammo = state.Reserve[id]
    state.LastSwitch = os.clock()
    state.LastShot = os.clock()
    player:SetAttribute("Weapon", id)
    player:SetAttribute("Ammo", state.Ammo)
    player:SetAttribute("Reloading", false)
    return true
end
function Combat.remove(player: Player) states[player] = nil end
function Combat.killer(humanoid: Humanoid): Player?
    local tag = tags[humanoid]
    return if tag and os.clock() - tag.Time < 8 and tag.Player.Parent == Players then tag.Player else nil
end
function Combat.reload(player: Player): boolean
    local state = states[player]
    local weapon = if state then Config.Weapons[state.Weapon] else nil
    local char = player.Character
    local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
    if not state or not weapon or state.Reloading or state.Ammo == weapon.Magazine or not hum or hum.Health <= 0 or not char or not char:FindFirstChild("PulseBlaster") then return false end
    state.Reloading = true
    player:SetAttribute("Reloading", true)
    local generation = state.Generation
    task.delay(weapon.ReloadTime, function()
        if states[player] ~= state or state.Generation ~= generation then return end
        state.Ammo = weapon.Magazine
        state.Reloading = false
        player:SetAttribute("Ammo", state.Ammo)
        player:SetAttribute("Reloading", false)
    end)
    return true
end

function Combat.fire(player: Player, direction: unknown, allowDamage: boolean): Shot?
    local state = states[player]
    local weapon = if state then Config.Weapons[state.Weapon] else nil
    if typeof(direction) ~= "Vector3" then return nil end
    local aim = direction :: Vector3
    if aim.X ~= aim.X or aim.Y ~= aim.Y or aim.Z ~= aim.Z or aim.Magnitude < 0.9 or aim.Magnitude > 1.1 then return nil end
    local char = player.Character
    local humanoid = if char then char:FindFirstChildOfClass("Humanoid") else nil
    local head = if char then char:FindFirstChild("Head") :: BasePart? else nil
    if not state or not weapon or not char or not humanoid or humanoid.Health <= 0 or not head or not char:FindFirstChild("PulseBlaster") then return nil end
    if state.Reloading or state.Ammo <= 0 or os.clock() - state.LastShot < weapon.FireInterval then return nil end
    if char:FindFirstChildOfClass("ForceField") then return nil end
    state.LastShot = os.clock()
    state.Ammo -= 1
    player:SetAttribute("Ammo", state.Ammo)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local origin = head.Position
    local hit = workspace:Raycast(origin, aim.Unit * weapon.Range, params)
    local bounce: Vector3? = nil
    if hit and state.Weapon == "Arc" and hit.Instance:GetAttribute("Ricochet") == true then
        bounce = hit.Position
        local reflected = aim.Unit - 2 * aim.Unit:Dot(hit.Normal) * hit.Normal
        local remaining = weapon.Range - (hit.Position - origin).Magnitude
        local bounceStart = hit.Position + hit.Normal * 0.05 + reflected * 0.05
        hit = workspace:Raycast(bounceStart, reflected * remaining, params)
        if not hit then
            return {Origin = origin, Endpoint = bounceStart + reflected * remaining, Hit = false, Damage = 0, Headshot = false, Eliminated = false, Bounce = bounce}
        end
    end
    local endpoint = if hit then hit.Position else origin + aim.Unit * weapon.Range
    local damaged = false
    local damage = 0
    local headshot = false
    local eliminated = false
    if hit then
        local target = hit.Instance:FindFirstAncestorOfClass("Model")
        local victim = if target then target:FindFirstChildOfClass("Humanoid") else nil
        local targetPlayer = if target then Players:GetPlayerFromCharacter(target) else nil
        local practice = target and target:GetAttribute("PracticeTarget") == true
        local enemy = targetPlayer and targetPlayer.Team ~= player.Team
        if victim and victim.Health > 0 and target and not target:FindFirstChildOfClass("ForceField") and ((enemy and allowDamage) or (practice and not allowDamage)) then
            tags[victim] = {Player = player, Time = os.clock()}
            headshot = hit.Instance.Name == "Head"
            damage = math.min(victim.Health, if headshot then weapon.HeadDamage else weapon.Damage)
            victim:TakeDamage(damage)
            damaged = true
            eliminated = victim.Health <= 0
        end
    end
    return {Origin = origin, Endpoint = endpoint, Hit = damaged, Damage = damage, Headshot = headshot, Eliminated = eliminated, Bounce = bounce}
end
return Combat
