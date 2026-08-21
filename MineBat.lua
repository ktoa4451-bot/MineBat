-- =========================================================
-- MINEBAT MC-STYLE v3.0 (12 функций)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local reachDistance = 15
local speedMultiplier = 2.5
local jumpPower = 80

local enabled = {
    killAura = false,
    silentAim = false,
    velocity = false,
    speed = false,
    jump = false,
    infJump = false,
    fly = false,
    nuker = false,
    esp = false,
    xray = false,
    autoBlock = false,
    fullbright = false
}

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function Notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="MineBat MC", Text=text, Duration=3})
    end)
end

-- =========================================================
-- МЕНЮ
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = playerGui
ScreenGui.Name = "MineBatMC"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 500)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "MineBat MC-Style"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollingFrame.ScrollBarThickness = 4

local function Toggle(yPos, label, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = ScrollingFrame
    Frame.Size = UDim2.new(0.95, 0, 0.07, 0)
    Frame.Position = UDim2.new(0.025, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = label
    Label.TextColor3 = Color3.new(1, 1, 1)

    local Button = Instance.new("TextButton")
    Button.Parent = Frame
    Button.Size = UDim2.new(0.3, 0, 0.7, 0)
    Button.Position = UDim2.new(0.65, 0, 0.15, 0)
    Button.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    Button.Text = "OFF"

    local isOn = false
    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        Button.Text = isOn and "ON" or "OFF"
        Button.BackgroundColor3 = isOn and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
        callback(isOn)
    end)
end

-- =========================================================
-- 1. FULLBRIGHT
-- =========================================================
Toggle(50, "Fullbright", function(state)
    enabled.fullbright = state
    Lighting.Brightness = state and 2 or 0.5
    Lighting.ClockTime = state and 12 or 6
end)

-- =========================================================
-- 2. KILL AURA (Minecraft Reach)
-- =========================================================
local attackRemote = nil
local function FindAttackRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "Attack" or v.Name == "Hit" then attackRemote = v end
    end
end
FindAttackRemote()

Toggle(90, "Kill Aura", function(state)
    enabled.killAura = state
    if state then Notify("Kill Aura ON") end
    task.spawn(function()
        while state do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < reachDistance then
                            if attackRemote then
                                attackRemote:FireServer(p.Character)
                            else
                                -- Если нет Remote, эмулируем удар
                                local hum = p.Character:FindFirstChild("Humanoid")
                                if hum then hum.Health = 0 end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- =========================================================
-- 3. SILENT AIM (Атака по лучу)
-- =========================================================
Toggle(130, "Silent Aim", function(state)
    enabled.silentAim = state
    task.spawn(function()
        while state do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local ray = Ray.new(root.Position, (root.CFrame.LookVector * 50))
                local hit, pos = workspace:FindPartOnRay(ray, char)
                if hit and hit.Parent and hit.Parent:IsA("Model") and hit.Parent:FindFirstChild("Humanoid") then
                    if attackRemote then
                        attackRemote:FireServer(hit.Parent)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- =========================================================
-- 4. VELOCITY (Защита от отбрасывания)
-- =========================================================
Toggle(170, "Velocity", function(state)
    enabled.velocity = state
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = 9999
                hum.Health = 9999
            end
            task.wait(0.1)
        end
    end)
end)

-- =========================================================
-- 5. SPEED (Bunny Hop)
-- =========================================================
Toggle(210, "Speed", function(state)
    enabled.speed = state
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 * speedMultiplier end
            task.wait(0.05)
        end
    end)
end)

-- =========================================================
-- 6. SUPER JUMP
-- =========================================================
Toggle(250, "Super Jump", function(state)
    enabled.jump = state
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then hum.JumpPower = jumpPower end
            task.wait(0.05)
        end
    end)
end)

-- =========================================================
-- 7. INFINITE JUMP
-- =========================================================
Toggle(290, "Infinite Jump", function(state)
    enabled.infJump = state
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum and hum.FloorMaterial == Enum.Material.Air then
                hum.Jump = true
            end
            task.wait()
        end
    end)
end)

-- =========================================================
-- 8. FLY (Парение)
-- =========================================================
Toggle(330, "Fly", function(state)
    enabled.fly = state
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 15, 0)
            end
            task.wait(0.05)
        end
    end)
end)

-- =========================================================
-- 9. NUKER (Мгновенное копание)
-- =========================================================
Toggle(370, "Nuker", function(state)
    enabled.nuker = state
    task.spawn(function()
        while state do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("ore") or obj.Name:lower():find("stone") then
                        local dist = (root.Position - obj.Position).Magnitude
                        if dist < 10 then
                            obj:Destroy()
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- =========================================================
-- 10. ESP (Стены + Блоки)
-- =========================================================
local espObjs = {}
Toggle(410, "ESP (Wallhack)", function(state)
    enabled.esp = state
    if state then
        task.spawn(function()
            while state do
                for _, v in pairs(espObjs) do v:Remove() end
                table.clear(espObjs)
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local root = p.Character.HumanoidRootPart
                        local head, vis = workspace.CurrentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local foot = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        if vis then
                            local height = math.abs(head.Y - foot.Y)
                            local width = height / 1.5
                            local box = Drawing.new("Square")
                            box.Position = Vector2.new(head.X - width/2, head.Y)
                            box.Size = Vector2.new(width, height)
                            box.Color = Color3.fromRGB(255, 0, 0)
                            box.Visible = true
                            table.insert(espObjs, box)
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        for _, v in pairs(espObjs) do v:Remove() end
        table.clear(espObjs)
    end
end)

-- =========================================================
-- 11. XRAY (Просмотр сквозь стены)
-- =========================================================
Toggle(450, "XRay", function(state)
    enabled.xray = state
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Terrain" and obj.Name ~= "Baseplate" then
            if state then
                obj.LocalTransparencyModifier = 0.9
            else
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end)

-- =========================================================
-- 12. AUTO BLOCK (Защита)
-- =========================================================
Toggle(490, "Auto Block", function(state)
    enabled.autoBlock = state
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.AutoRotate = false
                -- Если есть щит в руке, зажимаем ПКМ
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, Enum.UserInputType.MouseButton2, true)
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Управление клавишей V (для ПК)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        enabled.killAura = not enabled.killAura
        Notify(enabled.killAura and "Kill Aura ON (V)" or "Kill Aura OFF")
    end
end)

Notify("MineBat MC v3.0 Loaded!")
