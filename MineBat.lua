-- =========================================================
-- MINEBAT MC-STYLE v5.0 (Без мусора + Fake Ban)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local reachDistance = 15
local speedMultiplier = 2.5
local jumpPower = 80

local enabled = {
    killAura = false,
    speed = false,
    jump = false,
    infJump = false,
    fly = false,
    fakeBan = false
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
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "MineBat MC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 340)
    end
end)

local function Toggle(yPos, label, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = MainFrame
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
-- ФУНКЦИИ
-- =========================================================

-- 1. KILL AURA
local attackRemote = nil
local function FindAttackRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "Attack" or v.Name == "Hit" then attackRemote = v end
    end
end
FindAttackRemote()

Toggle(50, "Kill Aura", function(state)
    enabled.killAura = state
    if state then Notify("Kill Aura ON") end
    task.spawn(function()
        while enabled.killAura do
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

-- 2. SPEED
Toggle(90, "Speed", function(state)
    enabled.speed = state
    task.spawn(function()
        while enabled.speed do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 * speedMultiplier end
            task.wait(0.05)
        end
    end)
end)

-- 3. SUPER JUMP
Toggle(130, "Super Jump", function(state)
    enabled.jump = state
    task.spawn(function()
        while enabled.jump do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then hum.JumpPower = jumpPower end
            task.wait(0.05)
        end
    end)
end)

-- 4. INFINITE JUMP
Toggle(170, "Infinite Jump", function(state)
    enabled.infJump = state
    task.spawn(function()
        while enabled.infJump do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum and hum.FloorMaterial == Enum.Material.Air then
                hum.Jump = true
            end
            task.wait()
        end
    end)
end)

-- 5. FLY (Парение)
Toggle(210, "Fly", function(state)
    enabled.fly = state
    task.spawn(function()
        while enabled.fly do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 15, 0)
            end
            task.wait(0.05)
        end
    end)
end)

-- 6. FAKE BAN (HW)
Toggle(250, "Fake Ban (HW)", function(state)
    enabled.fakeBan = state
    task.spawn(function()
        while enabled.fakeBan do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 30, 0)
                task.wait(0.05)
            end
            task.wait(0.25)
        end
    end)
end)

-- =========================================================
-- УПРАВЛЕНИЕ ВЫКЛЮЧЕНИЕМ (FIX)
-- =========================================================
local function switchOffEnabled()
    enabled.killAura = false
    enabled.speed = false
    enabled.jump = false
    enabled.infJump = false
    enabled.fly = false
    enabled.fakeBan = false
}

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        switchOffEnabled()
        Notify("All functions disabled")
    end
end)

Notify("MineBat MC v5.0 Loaded!")
