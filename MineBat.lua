-- =========================================================
-- MINEBAT v6.0 (Тач + Постоянный Target Menu)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChild("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

local enabled = {
    killAura = false,
    spider = false,
    fakeBan = false,
    aim = false
}

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function Notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="MineBat", Text=text, Duration=3})
    end)
end

-- =========================================================
-- МЕНЮ (СТИЛЬ DELTA)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "MineBat v6.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local function CreateSection(xPos, sectionName)
    local Frame = Instance.new("Frame")
    Frame.Parent = MainFrame
    Frame.Size = UDim2.new(0.23, 0, 1, -30)
    Frame.Position = UDim2.new(xPos, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Label.Text = sectionName
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextScaled = true

    local function AddItem(yPos, itemLabel, callback)
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Parent = Frame
        ItemFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
        ItemFrame.Position = UDim2.new(0.05, 0, 0, yPos)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

        local Label = Instance.new("TextLabel")
        Label.Parent = ItemFrame
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Text = itemLabel
        Label.TextColor3 = Color3.new(1, 1, 1)

        local Button = Instance.new("TextButton")
        Button.Parent = ItemFrame
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

    return AddItem
end

local AddCombat = CreateSection(0.01, "Combat")
local AddMovement = CreateSection(0.25, "Movement")
local AddRender = CreateSection(0.50, "Render")
local AddPlayer = CreateSection(0.75, "Player")

-- =========================================================
-- ПОСТОЯННЫЙ TARGET MENU
-- =========================================================
local TargetGui = Instance.new("ScreenGui")
TargetGui.Parent = player:WaitForChild("PlayerGui")
TargetGui.Name = "TargetMenuGui"
TargetGui.ResetOnSpawn = false

local TargetFrame = Instance.new("Frame")
TargetFrame.Parent = TargetGui
TargetFrame.Size = UDim2.new(0, 100, 0, 45)
TargetFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TargetFrame.Visible = false

local HeadImg = Instance.new("ImageLabel")
HeadImg.Parent = TargetFrame
HeadImg.Size = UDim2.new(0, 40, 0, 40)
HeadImg.Position = UDim2.new(0, 2, 0, 2)
HeadImg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HeadImg.Image = ""

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = TargetFrame
NameLabel.Size = UDim2.new(0, 40, 0, 20)
NameLabel.Position = UDim2.new(0.5, 0, 0, 2)
NameLabel.Text = ""
NameLabel.TextColor3 = Color3.new(1, 1, 1)
NameLabel.TextScaled = true

local HpLabel = Instance.new("TextLabel")
HpLabel.Parent = TargetFrame
HpLabel.Size = UDim2.new(0, 40, 0, 20)
HpLabel.Position = UDim2.new(0.5, 0, 0, 22)
HpLabel.Text = ""
HpLabel.TextColor3 = Color3.new(1, 1, 1)
HpLabel.TextScaled = true

-- =========================================================
-- ФУНКЦИИ
-- =========================================================

-- 1. АИМБОТ
AddCombat(10, "Aimbot", function(state)
    enabled.aim = state
    if state then Notify("Aimbot ON") end
end)

local function Aimbot()
    if enabled.aim then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            local nearest = nil
            local nearestDist = 120
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = p.Character.HumanoidRootPart
                    end
                end
            end
            if nearest then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Position)
            end
        end
    end
end

RunService.RenderStepped:Connect(Aimbot)

-- 2. КИЛЛ АУРА
AddCombat(30, "Kill Aura", function(state)
    enabled.killAura = state
    if state then Notify("Kill Aura ON") end
end)

local function KillAura()
    if enabled.killAura then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            local remote = ReplicatedStorage:FindFirstChild("Attack", true)
            if remote then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 12 then
                            remote:FireServer(p.Character)
                        end
                    end
                end
            else
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 12 then
                            p.Character.Humanoid.Health = 0
                        end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(KillAura)

-- 3. СПАЙДЕР (без управляемости)
AddMovement(10, "Spider", function(state)
    enabled.spider = state
    if state then Notify("Spider ON") end
end)

local function Spider()
    if enabled.spider then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                hum.JumpPower = 0
                hum.UseJumpPower = false
            end
            root.Velocity = Vector3.new(0, 10, 0)
        end
    end
end

RunService.Heartbeat:Connect(Spider)

-- 4. ESP
AddRender(10, "ESP", function(state)
    if state then
        task.spawn(function()
            while true do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if not p.Character:FindFirstChild("ESP_HL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "ESP_HL"
                            hl.Parent = p.Character
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_HL") then
                p.Character.ESP_HL:Destroy()
            end
        end
    end
end)

-- 5. FAKE BAN
AddPlayer(10, "Fake Ban", function(state)
    enabled.fakeBan = state
    if state then Notify("Fake Ban ON") end
end)

local function FakeBan()
    if enabled.fakeBan then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 15, 0)
            task.wait(0.5)
            root.Velocity = Vector3.new(0, 0, 0)
            task.wait(4)
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
            end
        end
    end
end

RunService.Heartbeat:Connect(FakeBan)

-- =========================================================
-- TARGET MENU (Постоянный)
-- =========================================================
local function TargetMenu()
    if player.Character then
        local rootPos = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPos then
            local nearest = nil
            local nearestDist = 100
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (rootPos.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = p
                    end
                end
            end
            if nearest then
                local headPos = workspace.CurrentCamera:WorldToViewportPoint(nearest.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                local hp = nearest.Character:FindFirstChild("Humanoid")
                
                TargetFrame.Position = UDim2.fromOffset(headPos.X - 50, headPos.Y - 22)
                TargetFrame.Visible = true
                
                HeadImg.Image = "rbxassetid://" .. nearest.UserId
                NameLabel.Text = nearest.Name
                HpLabel.Text = "HP: " .. hp.Health
            else
                TargetFrame.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(TargetMenu)

-- =========================================================
-- Кнопка открытия/сворачивания
-- =========================================================
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 450, 0, 30) or UDim2.new(0, 450, 0, 400)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ScreenGui.Visible = not ScreenGui.Visible
    end
end)

print("MineBat v6.0 Loaded!")
