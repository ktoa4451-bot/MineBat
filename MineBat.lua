-- =========================================================
-- MINEBAT SILENT AIM v2.0 (Телефон + Меню)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local attack = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")

local character, humanoid, root, camera
local jumpConn, charConn
local jumped, jumpAt = false, 0
local enabled = true
local radius = 170
local fallY = -1.5
local lastScan, lastSwing, currentTool = 0, 0, nil

local corners = {
    Vector3.new(-1,-1,-1), Vector3.new(-1,-1,1),
    Vector3.new(-1,1,-1), Vector3.new(-1,1,1),
    Vector3.new(1,-1,-1), Vector3.new(1,-1,1),
    Vector3.new(1,1,-1), Vector3.new(1,1,1)
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function notif(text)
    task.spawn(function()
        for _ = 1, 6 do
            if pcall(function()
                StarterGui:SetCore("SendNotification", {Title="MineBat", Text=text, Duration=3})
            end) then return end
            task.wait(0.25)
        end
    end)
end

-- =========================================================
-- МЕНЮ ДЛЯ ТЕЛЕФОНА
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = playerGui
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "MineBat Silent"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local function CreateToggle(yPos, label, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = MainFrame
    ToggleFrame.Size = UDim2.new(0.95, 0, 0.08, 0)
    ToggleFrame.Position = UDim2.new(0.025, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = label
    Label.TextColor3 = Color3.new(1, 1, 1)

    local Button = Instance.new("TextButton")
    Button.Parent = ToggleFrame
    Button.Size = UDim2.new(0.3, 0, 0.7, 0)
    Button.Position = UDim2.new(0.65, 0, 0.15, 0)
    Button.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.new(1, 1, 1)

    local isOn = false
    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        Button.Text = isOn and "ON" or "OFF"
        Button.BackgroundColor3 = isOn and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
        callback(isOn)
    end)
end

-- =========================================================
-- ЛОГИКА ПЕРСОНАЖА И ОРУЖИЯ
-- =========================================================

local function bind(char)
    if jumpConn then jumpConn:Disconnect() end
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    camera = workspace.CurrentCamera
    jumped, jumpAt = false, 0
    currentTool = nil

    jumpConn = humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping then
            jumped, jumpAt = true, tick()
        elseif state == Enum.HumanoidStateType.Landed then
            jumped = false
        end
    end)
end

bind(player.Character or player.CharacterAdded:Wait())
charConn = player.CharacterAdded:Connect(bind)

local function refs()
    camera = workspace.CurrentCamera
    if not character or not character.Parent then return false end
    if not humanoid or humanoid.Health <= 0 then return false end
    if not root or not root.Parent then return false end
    rayParams.FilterDescendantsInstances = {character}
    return true
end

local function weapon()
    local hand = character and character:FindFirstChild("Hand2")
    local tool = hand and hand.Value
    if not tool or not tool:IsA("Tool") then return end
    local range = tonumber(tool:GetAttribute("Range"))
    local damage = tonumber(tool:GetAttribute("Damage"))
    if not range or not damage then return end
    local interval = math.max(tonumber(tool:GetAttribute("ChargeTime")) or 0.5, 0.36)
    return tool, range, interval
end

local function ready()
    if not jumped then return true end
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        if tick() - jumpAt < 0.18 then return false end
        jumped = false
        return true
    end
    return root.AssemblyLinearVelocity.Y <= fallY
end

local function fovdist(model, cursor)
    local best = math.huge
    for _, part in ipairs(model:GetChildren()) do
        if not part:IsA("BasePart") then continue end
        local half = part.Size * 0.5
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local found = false
        for _, corner in ipairs(corners) do
            local offset = Vector3.new(half.X*corner.X, half.Y*corner.Y, half.Z*corner.Z)
            local pos = camera:WorldToViewportPoint(part.CFrame:PointToWorldSpace(offset))
            if pos.Z <= 0 then continue end
            found = true
            minX, minY = math.min(minX, pos.X), math.min(minY, pos.Y)
            maxX, maxY = math.max(maxX, pos.X), math.max(maxY, pos.Y)
        end
        if not found then continue end
        local closest = Vector2.new(math.clamp(cursor.X, minX, maxX), math.clamp(cursor.Y, minY, maxY))
        best = math.min(best, (cursor - closest).Magnitude)
        if best <= radius then return best end
    end
    return best
end

local function rangeok(model, range)
    local best = math.huge
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then best = math.min(best, (part.Position - root.Position).Magnitude) end
    end
    return best <= range + 0.5
end

local function models()
    local list, seen = {}, {}
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local model = other.Character
            if model and not seen[model] then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local targetRoot = model:FindFirstChild("HumanoidRootPart") or hum and hum.RootPart
                if hum and targetRoot and hum.Health > 0 then
                    seen[model] = true
                    table.insert(list, model)
                end
            end
        end
    end
    return list
end

local function valid(model, cursor, range)
    if not rangeok(model, range) then return false end
    if fovdist(model, cursor) > radius then return false end
    return true
end

local function play(tool)
    local equipped = character:FindFirstChild(tool.Name) or tool
    local animations = equipped and equipped:FindFirstChild("Animations")
    local swing = animations and animations:FindFirstChild("RightSwing")
    if swing then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local track = animator:LoadAnimation(swing)
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
        end
    end
end

-- =========================================================
-- ОСНОВНОЙ ЦИКЛ
-- =========================================================
RunService.Heartbeat:Connect(function()
    if not enabled or not refs() then return end

    local tool, range, interval = weapon()
    if not tool then return end

    if not ready() then return end
    local now = tick()
    if now - lastScan < 0.04 then return end
    lastScan = now
    if now - lastSwing < interval then return end

    local cursor = camera.ViewportSize * 0.5
    local targets = {}

    for _, model in ipairs(models()) do
        if valid(model, cursor, range) then
            table.insert(targets, model)
        end
    end

    if #targets == 0 then return end
    lastSwing = now

    play(tool)
    for _, model in ipairs(targets) do
        if model.Parent then
            attack:FireServer(model, 1, nil, tool.Name)
        end
    end
end)

-- =========================================================
-- КНОПКИ МЕНЮ (Включение/Выключение)
-- =========================================================
CreateToggle(50, "Silent Aim (ON/OFF)", function(state)
    enabled = state
    notif(state and "Silent Aim Enabled" or "Silent Aim Disabled")
end)

-- =========================================================
-- СКРЫТИЕ МЕНЮ ПО ТАПУ НА ЗАГОЛОВОК
-- =========================================================
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 250)
    end
end)

notif("Loaded! Use Menu to Toggle.")
