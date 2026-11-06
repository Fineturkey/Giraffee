--!strict
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local screen = Instance.new("ScreenGui")
screen.Name = "MonsterEggHUD"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.9, 0, 0, 165)
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 12)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(560, 165)
limit.Parent = panel
panel.BackgroundColor3 = Color3.fromRGB(19, 27, 37)
panel.BackgroundTransparency = 0.12
panel.Parent = screen
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local function label(y: number, height: number, size: number, color: Color3): TextLabel
    local item = Instance.new("TextLabel")
    item.Position = UDim2.new(0, 14, 0, y)
    item.Size = UDim2.new(1, -28, 0, height)
    item.BackgroundTransparency = 1
    item.Font = Enum.Font.GothamBold
    item.TextSize = size
    item.TextColor3 = color
    item.TextWrapped = true
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Parent = panel
    return item
end
label(8, 28, 22, Color3.fromRGB(153, 255, 207)).Text = "STEAL A MONSTER EGG"
local statsLabel = label(38, 24, 16, Color3.fromRGB(255, 218, 133))
local messageLabel = label(65, 48, 16, Color3.fromRGB(238, 245, 255))
local dangerLabel = label(119, 30, 16, Color3.fromRGB(255, 150, 150))
local footer = Instance.new("Frame")
footer.Name = "ExpeditionStatus"
footer.AnchorPoint = Vector2.new(0.5, 1)
footer.Position = UDim2.new(0.5, 0, 1, -18)
footer.Size = UDim2.new(0.8, 0, 0, 96)
footer.BackgroundColor3 = Color3.fromRGB(19, 27, 37)
footer.BackgroundTransparency = 0.1
footer.Parent = screen
local footerLimit = Instance.new("UISizeConstraint")
footerLimit.MaxSize = Vector2.new(560, 96)
footerLimit.Parent = footer
corner:Clone().Parent = footer
local collectionLabel = Instance.new("TextLabel")
collectionLabel.Size = UDim2.new(1, -20, 0, 30)
collectionLabel.Position = UDim2.fromOffset(10, 4)
collectionLabel.BackgroundTransparency = 1
collectionLabel.TextColor3 = Color3.fromRGB(170, 235, 216)
collectionLabel.Font = Enum.Font.GothamBold
collectionLabel.TextSize = 14
collectionLabel.TextWrapped = true
collectionLabel.Parent = footer
local bar = Instance.new("Frame")
bar.Position = UDim2.new(0, 12, 0, 40)
bar.Size = UDim2.new(1, -24, 0, 8)
bar.BackgroundColor3 = Color3.fromRGB(42, 56, 70)
bar.BorderSizePixel = 0
bar.Parent = footer
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(1, 1)
fill.BackgroundColor3 = Color3.fromRGB(108, 228, 204)
fill.BorderSizePixel = 0
fill.Parent = bar
local controls = collectionLabel:Clone()
controls.Position = UDim2.fromOffset(10, 55)
controls.TextColor3 = Color3.fromRGB(193, 203, 215)
controls.TextSize = 13
controls.Text = "STAMINA ↑   •   Shift / L3: sprint   •   Q / B: drop   •   All 3 species: +100 coins"
controls.Parent = footer
local actions = game:GetService("ReplicatedStorage"):WaitForChild("MonsterEggAction") :: RemoteEvent
ContextActionService:BindAction("EggSprint", function(_, state)
    if state == Enum.UserInputState.Begin then actions:FireServer("Sprint", true)
    elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then actions:FireServer("Sprint", false) end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
ContextActionService:SetTitle("EggSprint", "Sprint")
ContextActionService:SetPosition("EggSprint", UDim2.new(1, -160, 1, -180))
ContextActionService:BindAction("EggDrop", function(_, state)
    if state == Enum.UserInputState.Begin then actions:FireServer("Drop") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonB)
ContextActionService:SetTitle("EggDrop", "Drop")
ContextActionService:SetPosition("EggDrop", UDim2.new(1, -240, 1, -140))
local stats = player:WaitForChild("leaderstats")
local coins = stats:WaitForChild("Coins") :: IntValue
local hatched = stats:WaitForChild("Hatched") :: IntValue
local function refresh()
    statsLabel.Text = string.format("%d coins  |  %d hatched  |  Carry level %d", coins.Value, hatched.Value, player:GetAttribute("CarryLevel") or 0)
    messageLabel.Text = player:GetAttribute("Message") or "Find the nest!"
    local carrying = player:GetAttribute("Carrying") or ""
    local danger = player:GetAttribute("Danger") or 0
    local hatching = player:GetAttribute("Hatching") == true
    dangerLabel.Text = if hatching then string.format("HATCHING %s • %d%%", carrying, player:GetAttribute("HatchProgress") or 0) elseif carrying == "" then "Follow the golden trail through the stone arch" elseif danger >= 100 then "GUARDIAN AWAKE! Sprint to the cyan hatchery!" else string.format("Carrying %s  •  Guardian waking: %d%%", carrying, danger)
    local names = {}
    for index, name in {"Mossling", "Emberhorn", "Voidwing"} do
        table.insert(names, (if player:GetAttribute("Found" .. index) then "✓ " else "? ") .. name)
    end
    collectionLabel.Text = table.concat(names, "  •  ")
    local energy = player:GetAttribute("Stamina") or 100
    fill.Size = UDim2.fromScale(energy / 100, 1)
    fill.BackgroundColor3 = if energy < 25 then Color3.fromRGB(255, 151, 91) else Color3.fromRGB(108, 228, 204)
    panel.BackgroundColor3 = if danger >= 100 and not hatching then Color3.fromRGB(70, 25, 39) else Color3.fromRGB(19, 27, 37)
end
for _, attribute in {"Message", "CarryLevel", "Carrying", "Danger", "Stamina", "Found1", "Found2", "Found3", "Hatching", "HatchProgress"} do
    player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
coins.Changed:Connect(refresh)
hatched.Changed:Connect(refresh)
refresh()
player:GetAttributeChangedSignal("Message"):Connect(function()
    messageLabel.TextTransparency = 0.6
    TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end)
