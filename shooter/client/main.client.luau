--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild("CrossfireState")
local action = ReplicatedStorage:WaitForChild("CrossfireAction") :: RemoteEvent
local effects = ReplicatedStorage:WaitForChild("CrossfireEffects") :: RemoteEvent
player.CameraMode = Enum.CameraMode.LockFirstPerson
UserInputService.MouseIconEnabled = false
local gui = Instance.new("ScreenGui")
gui.Name = "CrossfireHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function text(name: string, pos: UDim2, size: UDim2, fontSize: number): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = pos
    label.Size = size
    label.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
    label.BackgroundTransparency = 0.18
    label.BorderSizePixel = 0
    label.TextColor3 = Color3.fromRGB(237, 245, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = fontSize
    label.TextWrapped = true
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    return label
end
local score = text("Score", UDim2.new(0.2, 0, 0, 10), UDim2.new(0.6, 0, 0, 74), 20)
local ammo = text("Ammo", UDim2.new(0.5, -145, 1, -85), UDim2.fromOffset(290, 62), 20)
local health = text("Health", UDim2.new(0, 16, 1, -75), UDim2.fromOffset(140, 50), 18)
local feed = text("Feed", UDim2.new(0.2, 0, 0, 90), UDim2.new(0.6, 0, 0, 34), 15)
feed.Visible = false
local crosshair = text("Crosshair", UDim2.new(0.5, -15, 0.5, -15), UDim2.fromOffset(30, 30), 26)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
local feedback = text("HitFeedback", UDim2.new(0.5, -140, 0.5, 30), UDim2.fromOffset(280, 35), 20)
feedback.BackgroundTransparency = 1
feedback.Visible = false
local teamLabel = text("Team", UDim2.new(0, 16, 0, 12), UDim2.fromOffset(130, 40), 16)
local damageFlash = Instance.new("Frame")
damageFlash.Size = UDim2.fromScale(1, 1)
damageFlash.BackgroundColor3 = Config.Red
damageFlash.BackgroundTransparency = 1
damageFlash.BorderSizePixel = 0
damageFlash.ZIndex = 0
damageFlash.Parent = gui
local feedbackVersion = 0
local aiming = false
local function activeWeapon()
    local id = player:GetAttribute("Weapon")
    return Config.Weapons[if typeof(id) == "string" then id else "Pulse"] or Config.Weapons.Pulse
end
local hitUntil = 0
local firing = false
local lastFire = 0
local feedVersion = 0
local function refresh()
    local phase = state:GetAttribute("Phase")
    local seconds = state:GetAttribute("Seconds") :: number? or 0
    local redScore = state:GetAttribute("RedScore") or 0
    local blueScore = state:GetAttribute("BlueScore") or 0
    score.Text = if phase == "Warmup" then "NEON CROSSFIRE • PRACTICE\nWaiting for an opponent • Shoot the gold drones" elseif phase == "Intermission" then tostring(state:GetAttribute("Winner")) .. " • ROUND OVER\nNext round in " .. seconds else string.format("RED %d   —   %d BLUE\n%d:%02d • FIRST TO %d", redScore, blueScore, math.floor(seconds/60), seconds%60, Config.ScoreToWin)
    local weapon = activeWeapon()
    ammo.Text = if player:GetAttribute("Reloading") then weapon.Name .. " • RELOADING..." else string.format("%s   %d / %d\n%s", weapon.Name, player:GetAttribute("Ammo") or 0, weapon.Magazine, if player:GetAttribute("Weapon") == "Arc" then "Bounce shots off mint mirror panels!" else "1 / 2: weapon • R / X: reload")
    local team = player.Team
    teamLabel.Text = if team then string.upper(team.Name) .. " TEAM" else "JOINING"
    teamLabel.TextColor3 = if team and team.Name == "Red" then Config.Red else Config.Blue
    local char = player.Character
    local hum = if char then char:FindFirstChildOfClass("Humanoid") else nil
    health.Text = if hum then "HEALTH " .. math.ceil(hum.Health) else "RESPAWNING"
    health.TextColor3 = if hum and hum.Health < 35 then Config.Red else Color3.fromRGB(157, 246, 201)
end
state.AttributeChanged:Connect(refresh)
player:GetAttributeChangedSignal("Ammo"):Connect(refresh)
player:GetAttributeChangedSignal("Reloading"):Connect(refresh)
player:GetAttributeChangedSignal("Weapon"):Connect(refresh)
player:GetPropertyChangedSignal("Team"):Connect(refresh)
local function characterReady(character: Model)
    firing = false
    aiming = false
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
    local hum = character:WaitForChild("Humanoid") :: Humanoid
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function(value)
        if value < lastHealth then
            damageFlash.BackgroundTransparency = 0.8
            TweenService:Create(damageFlash, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        end
        lastHealth = value
        refresh()
    end)
    hum.Died:Connect(function() firing = false; refresh() end)
    refresh()
end
player.CharacterAdded:Connect(characterReady)
if player.Character then task.spawn(characterReady, player.Character) end
ContextActionService:BindAction("CrossfireFire", function(_, inputState)
    if inputState == Enum.UserInputState.Begin then firing = true
    elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then firing = false end
    return Enum.ContextActionResult.Sink
end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
ContextActionService:SetTitle("CrossfireFire", "FIRE")
ContextActionService:SetPosition("CrossfireFire", UDim2.new(1, -140, 1, -180))
ContextActionService:BindAction("CrossfireReload", function(_, inputState)
    if inputState == Enum.UserInputState.Begin then action:FireServer("Reload") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.R, Enum.KeyCode.ButtonX)
ContextActionService:SetTitle("CrossfireReload", "Reload")
ContextActionService:SetPosition("CrossfireReload", UDim2.new(1, -220, 1, -125))
ContextActionService:BindAction("CrossfirePrimary", function(_, inputState)
    if inputState == Enum.UserInputState.Begin then firing = false; action:FireServer("Switch", "Pulse") end
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.One)
ContextActionService:BindAction("CrossfireSecondary", function(_, inputState)
    if inputState == Enum.UserInputState.Begin then firing = false; action:FireServer("Switch", "Arc") end
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Two)
ContextActionService:BindAction("CrossfireSwap", function(_, inputState)
    if inputState == Enum.UserInputState.Begin then
        firing = false
        action:FireServer("Switch", if player:GetAttribute("Weapon") == "Arc" then "Pulse" else "Arc")
    end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.ButtonY)
ContextActionService:SetTitle("CrossfireSwap", "Swap")
ContextActionService:SetPosition("CrossfireSwap", UDim2.new(1, -300, 1, -180))
ContextActionService:BindAction("CrossfireAim", function(_, inputState)
    aiming = inputState == Enum.UserInputState.Begin
    local camera = workspace.CurrentCamera
    if camera then TweenService:Create(camera, TweenInfo.new(0.12), {FieldOfView = if aiming then 55 else 70}):Play() end
    return Enum.ContextActionResult.Sink
end, true, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2)
ContextActionService:SetTitle("CrossfireAim", "Aim")
ContextActionService:SetPosition("CrossfireAim", UDim2.new(1, -220, 1, -235))
UserInputService.WindowFocusReleased:Connect(function()
    firing = false
    aiming = false
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
end)
RunService.RenderStepped:Connect(function()
    crosshair.TextColor3 = if os.clock() < hitUntil then Color3.fromRGB(255, 210, 95) else Color3.new(1, 1, 1)
    local camera = workspace.CurrentCamera
    if firing and camera and os.clock() - lastFire >= activeWeapon().FireInterval + 0.01 then
        lastFire = os.clock()
        if (player:GetAttribute("Ammo") or 0) == 0 then action:FireServer("Reload")
        else action:FireServer("Fire", camera.CFrame.LookVector) end
    end
end)
effects.OnClientEvent:Connect(function(kind: string, a: any, b: any, c: any, d: any, e: any)
    if kind == "Shot" then
        local start = b :: Vector3
        local finish = c :: Vector3
        local points: {Vector3} = {start}
        if typeof(e) == "Vector3" then table.insert(points, e) end
        table.insert(points, finish)
        for index = 1, #points - 1 do
        local from, to = points[index], points[index + 1]
        local length = (to - from).Magnitude
        if length > 0.01 then
            local beam = Instance.new("Part")
            beam.Name = "BlasterTracer"
            beam.Anchored = true
            beam.CanCollide = false
            beam.CanQuery = false
            beam.CanTouch = false
            beam.Material = Enum.Material.Neon
            beam.Color = if e then Color3.fromRGB(118, 245, 227) else Color3.fromRGB(255, 217, 115)
            beam.Size = Vector3.new(0.07, 0.07, length)
            beam.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -length / 2)
            beam.Parent = workspace
            Debris:AddItem(beam, 0.06)
        end
        end
        if a == player.UserId and d then hitUntil = os.clock() + 0.15 end
        if a == player.UserId and workspace.CurrentCamera then
            workspace.CurrentCamera.CFrame *= CFrame.Angles(math.rad(if aiming then 0.15 else 0.3), 0, 0)
        end
    elseif kind == "Feedback" then
        feedbackVersion += 1
        local version = feedbackVersion
        feedback.Visible = true
        feedback.Text = (if d then "BANK SHOT • " else "") .. (if c then "ELIMINATED • " elseif b then "HEADSHOT • " else "") .. tostring(a) .. " DAMAGE"
        feedback.TextColor3 = if c then Config.Red else Color3.fromRGB(255, 218, 113)
        crosshair.Text = if c then "×" else "+"
        task.delay(0.8, function()
            if version == feedbackVersion then feedback.Visible = false; crosshair.Text = "+" end
        end)
    elseif kind == "Elimination" then
        feedVersion += 1
        local version = feedVersion
        feed.Text = a
        feed.Visible = true
        task.delay(4, function() if version == feedVersion then feed.Visible = false end end)
    end
end)
refresh()
