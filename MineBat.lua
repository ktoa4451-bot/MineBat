-- =========================================================
-- MINEBAT v4.0 (Rage Menu + Спайдер + Target + Spinner + Fake Ban)
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
    killAura = false,
    spin = false,
    esp = false,
    aim = false,
    spider = false,
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
-- МЕНЮ (Стиль Delta)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
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
                        -- Урон через RemoteEvent
                        local remote = ReplicatedStorage:FindFirstChild("Attack", true)
                        if remote then
                            remote:FireServer(p.Character)
                        else
                            p.Character.Humanoid.Health = 0
                        end
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
                root.CFrame = CFrame.new(root.Position, nearest.Position)
                root.CFrame = root.CFrame * CFrame.Angles(0, 5 * tick(), 0)
            end
        end
    end
end

RunService.Heartbeat:Connect(KillAura)
RunService.Heartbeat:Connect(Spinner)

-- =========================================================
-- ESP (Highlight)
-- =========================================================
Toggle(150, "ESP", function(state)
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
end

RunService.Heartbeat:Connect(ESP)

-- =========================================================
-- СПАЙДЕР (Скалолазание)
-- =========================================================
Toggle(190, "Spider", function(state)
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

-- =========================================================
-- TARGET MENU (Вокруг прицела)
-- =========================================================
Toggle(230, "Target Menu", function(state)
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
            local hpBar = Drawing.new("Line")
            hpBar.From = Vector2.new(headPos.X - 10, headPos.Y - 10)
            hpBar.To = Vector2.new(headPos.X - 10, headPos.Y + 10)
            hpBar.Color = Color3.fromRGB(0, 255, 0)
            hpBar.Thickness = 3
            hpBar.Visible = true
            table.insert(espObjs, hpBar)
            
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
-- FAKE BAN (HW) (По-медленнее, через 5 секунд урон)
-- =========================================================
Toggle(270, "Fake Ban (HW)", function(state)
    enabled.fakeBan = state
    if state then Notify("Fake Ban ON") end
end)

local function FakeBan()
    if enabled.fakeBan then
        local root = GetChar():FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 10, 0)
            task.wait(0.2)
            root.Velocity = Vector3.new(0, 0, 0)
            task.wait(4)
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Reset:FireServer()
            end)
        end
    end
end

RunService.Heartbeat:Connect(FakeBan)

-- =========================================================
-- СВОРАЧИВАНИЕ МЕНЮ
-- =========================================================
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 300)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ScreenGui.Visible = not ScreenGui.Visible
    end
end)

print("MineBat v4.0 Loaded!")
