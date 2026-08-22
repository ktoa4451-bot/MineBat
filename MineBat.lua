-- =========================================================
-- MINEBAT v8.0 (Компакт + Телефон + V)
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
    aim = false,
    esp = false
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
-- КНОПКА (ТЕЛЕФОН)
-- =========================================================
local ButtonGui = Instance.new("ScreenGui")
ButtonGui.Parent = player:WaitForChild("PlayerGui")
ButtonGui.Name = "MineBatButton"
ButtonGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ButtonGui
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.85, 0, 0.85, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "M"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextScaled = true
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = true

local function Uncollapsible()
    if ToggleButton.Visible then
        ToggleButton.Visible = false
        ScreenGui.Visible = true
    } else {
        ScreenGui.Visible = false
        ToggleButton.Visible = true
    }
end

-- =========================================================
-- МЕНЮ (Компакт + Заголовок + Кнопка)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 350)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "MineBat v8.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local function CreateItem(yPos, itemLabel, callback)
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Parent = MainFrame
    ItemFrame.Size = UDim2.new(0.9, 0, 0.08, 0)
    ItemFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ItemFrame.BorderSizePixel = 0

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

-- =========================================================
-- ФУНКЦИИ
-- =========================================================

-- 1. АИМБОТ
CreateItem(40, "Aimbot", function(state)
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
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearest.Position)
            end
        end
    end
end

RunService.RenderStepped:Connect(Aimbot)

-- 2. КИЛЛ АУРА
CreateItem(80, "Kill Aura", function(state)
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

-- 3. СПАЙДЕР
CreateItem(120, "Spider", function(state)
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
CreateItem(160, "ESP", function(state)
    enabled.esp = state
    if state then Notify("ESP ON") end
end)

local function ESP()
    if enabled.esp then
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
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_HL") then
                p.Character.ESP_HL:Destroy()
            end
        end
    end
end)

RunService.Heartbeat:Connect(ESP)

-- 5. FAKE BAN
CreateItem(200, "Fake Ban", function(state)
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
-- Кнопка для телефона (M)
-- =========================================================
ToggleButton.MouseButton1Click:Connect(Uncollapsible)

-- =========================================================
-- Клавиша V для ПК
-- =========================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        Uncollapsible()
    end
end)

print("MineBat v8.0 Loaded!")
