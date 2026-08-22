-- =========================================================
-- MINEBAT v3.0 (Spinner + Target Menu)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChild("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

local enabled = {
    spider = false,
    killAura = false,
    spin = false,
    esp = false,
    aim = false,
    aiAura = false,
    targetMenu = false,
    fakeBan = false
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
-- МЕНЮ (стиль Delta)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "MineBat"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local function Toggle(yPos, label, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = MainFrame
    Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
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
-- АИМБОТ
-- =========================================================
Toggle(50, "Aimbot", function(state)
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

-- =========================================================
-- КИЛЛ АУРА + SPINNER
-- =========================================================
Toggle(90, "Kill Aura", function(state)
    enabled.killAura = state
    if state then Notify("Kill Aura ON") end
end)

Toggle(110, "Spinner", function(state)
    enabled.spin = state
    if state then Notify("Spinner ON") end
end)

local function KillAura()
    if enabled.killAura then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 10 then
                        p.Character.Humanoid.Health = 0
                    end
                end
            end
        end
    end
end

local function Spinner()
    if enabled.killAura and enabled.spin then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            local nearest = nil
            local nearestDist = 10
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
                local spinSpeed = 5
                root.CFrame = CFrame.new(root.Position, nearest.Position)
                root.CFrame = root.CFrame * CFrame.Angles(0, spinSpeed * tick(), 0)
            end
        end
    end
end

RunService.Heartbeat:Connect(KillAura)
RunService.Heartbeat:Connect(Spinner)

-- =========================================================
-- ESP
-- =========================================================
Toggle(150, "ESP", function(state)
    enabled.esp = state
    if state then Notify("ESP ON") end
end)

local espObjs = {}
local function ESP()
    if enabled.esp then
        for _, v in pairs(espObjs) do v:Remove() end
        table.clear(espObjs)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local head, vis = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                local foot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                if vis then
                    local height = math.abs(head.Y - foot.Y)
                    local width = height / 1.5
                    local box = Drawing.new("Square")
                    box.Position = Vector2.new(head.X - width/2, head.Y)
                    box.Size = Vector2.new(width, height)
                    box.Color = Color3.fromRGB(255, 0, 0)
                    box.Thickness = 2
                    box.Visible = true
                    table.insert(espObjs, box)
                end
            end
        end
        task.wait()
    end
end

RunService.RenderStepped:Connect(ESP)

-- =========================================================
-- AI AURA
-- =========================================================
Toggle(190, "AI Aura", function(state)
    enabled.aiAura = state
    if state then Notify("AI Aura ON") end
end)

local function AiAura()
    if enabled.aiAura then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            for _, model in pairs(workspace:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - model.HumanoidRootPart.Position).Magnitude
                    if dist < 10 then
                        model.Humanoid.Health = 0
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(AiAura)

-- =========================================================
-- СПАЙДЕР
-- =========================================================
Toggle(230, "Spider", function(state)
    enabled.spider = state
    if state then Notify("Spider ON") end
end)

local function Spider()
    if enabled.spider then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 5, 0)
        end
    end
end

RunService.Heartbeat:Connect(Spider)

-- =========================================================
-- TARGET MENU
-- =========================================================
Toggle(270, "Target Menu", function(state)
    enabled.targetMenu = state
    if state then Notify("Target Menu ON") end
end)

local function TargetMenu()
    if enabled.targetMenu then
        local nearest = nil
        local nearestDist = 100
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = p
                end
            end
        end
        if nearest then
            local headPos = Camera:WorldToViewportPoint(nearest.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            local hp = nearest.Character:FindFirstChild("Humanoid")
            local hpLine = Drawing.new("Line")
            hpLine.From = Vector2.new(headPos.X - 10, headPos.Y - 10)
            hpLine.To = Vector2.new(headPos.X - 10, headPos.Y + 10)
            hpLine.Color = Color3.fromRGB(0, 255, 0)
            hpLine.Thickness = 3
            hpLine.Visible = true
            table.insert(espObjs, hpLine)
            
            local playerName = Drawing.new("Text")
            playerName.Text = nearest.Name
            playerName.Position = Vector2.new(headPos.X - 10, headPos.Y - 20)
            playerName.Color = Color3.fromRGB(255, 255, 255)
            playerName.Size = 24
            playerName.Visible = true
            table.insert(espObjs, playerName)
            
            local hpText = Drawing.new("Text")
            hpText.Text = tostring(hp.Health)
            hpText.Position = Vector2.new(headPos.X - 10, headPos.Y - 10)
            hpText.Color = Color3.fromRGB(255, 255, 255)
            hpText.Size = 24
            hpText.Visible = true
            table.insert(espObjs, hpText)
        end
    end
end

RunService.RenderStepped:Connect(TargetMenu)

-- =========================================================
-- FAKE BAN
-- =========================================================
Toggle(300, "Fake Ban (HW)", function(state)
    enabled.fakeBan = state
    if state then Notify("Fake Ban ON") end
end)

local function FakeBan()
    if enabled.fakeBan then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 30, 0)
            task.wait(0.5)
            root.Velocity = Vector3.new(0, 0, 0)
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Reset:FireServer()
            end)
        end
    end
end

RunService.Heartbeat:Connect(FakeBan)

-- =========================================================
-- Кнопка закрытия / раскрытия меню
-- =========================================================
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 350)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ScreenGui.Visible = not ScreenGui.Visible
    end
end)

print("MineBat v3.0 Loaded!")
