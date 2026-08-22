-- =========================================================
-- MINEBAT v5.1 (Spider выключается чисто)
-- =========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChild("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

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
Title.Text = "MineBat v5.1"
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
-- ФУНКЦИИ
-- =========================================================

-- 1. АИМБОТ
AddCombat(10, "Aimbot", function(state)
    if state then
        task.spawn(function()
            while true do
                if player.Character then
                    local rootPos = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPos then
                        local nearest = nil
                        local nearestDist = 120
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (rootPos.Position - p.Character.HumanoidRootPart.Position).Magnitude
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
                task.wait(0.1)
            end
        end)
    end
end)

-- 2. КИЛЛ АУРА (через Remote)
AddCombat(30, "Kill Aura", function(state)
    if state then
        task.spawn(function()
            while true do
                if player.Character then
                    local rootPos = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPos then
                        local remote = ReplicatedStorage:FindFirstChild("Attack", true)
                        if remote then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local dist = (rootPos.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if dist < 12 then
                                        remote:FireServer(p.Character)
                                    end
                                end
                            end
                        else
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local dist = (rootPos.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if dist < 12 then
                                        p.Character.Humanoid.Health = 0
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- 3. СПАЙДЕР (Карабканье по стенам + выключение)
AddMovement(10, "Spider", function(state)
    if state then
        task.spawn(function()
            while true do
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hum = player.Character.Humanoid
                    local rootPos = player.Character.HumanoidRootPart
                    
                    -- Поиск ближайшей вертикальной стены
                    local ray = Ray.new(rootPos.Position, rootPos.CFrame.LookVector * 5)
                    local hit = workspace:FindPartOnRay(ray, player.Character)
                    
                    if hit then
                        hum.WalkSpeed = 100
                        hum.JumpPower = 0
                        hum.UseJumpPower = false
                        
                        -- Когда близко к стене + нажимается прыжок, поднимаемся вверх
                        if hum.FloorMaterial == Enum.Material.Air and hit then
                            hum.Jump = true
                            rootPos.Velocity = Vector3.new(0, 15, 0)
                        end
                    else
                        hum.WalkSpeed = 16
                        hum.JumpPower = 50
                        hum.UseJumpPower = true
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        -- ОБРАТНО К НОРМЕ
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.UseJumpPower = true
        end
    end
end)

-- 4. ESP (Highlight)
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

-- 5. TARGET MENU (Голова + Ник + ХП)
AddRender(30, "Target Menu", function(state)
    if state then
        task.spawn(function()
            while true do
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
                            
                            local cardFrame = Instance.new("Frame")
                            cardFrame.Parent = playerGui
                            cardFrame.Name = "TargetCard"
                            cardFrame.Size = UDim2.new(0, 100, 0, 45)
                            cardFrame.Position = UDim2.fromOffset(headPos.X - 50, headPos.Y - 22)
                            cardFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                            cardFrame.Visible = true
                            
                            local head = Instance.new("ImageLabel")
                            head.Parent = cardFrame
                            head.Size = UDim2.new(0, 40, 0, 40)
                            head.Position = UDim2.new(0, 2, 0, 2)
                            head.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            head.Image = "rbxassetid://" .. nearest.UserId
                            
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Parent = cardFrame
                            nameLabel.Size = UDim2.new(0, 40, 0, 20)
                            nameLabel.Position = UDim2.new(0.5, 0, 0, 2)
                            nameLabel.Text = nearest.Name
                            nameLabel.TextColor3 = Color3.new(1, 1, 1)
                            nameLabel.TextScaled = true
                            
                            local hpBar = Instance.new("TextLabel")
                            hpBar.Parent = cardFrame
                            hpBar.Size = UDim2.new(0, 40, 0, 20)
                            hpBar.Position = UDim2.new(0.5, 0, 0, 22)
                            hpBar.Text = "HP: " .. hp.Health
                            hpBar.TextColor3 = Color3.new(1, 1, 1)
                            hpBar.TextScaled = true
                            
                            cardFrame:Destroy()
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- 6. FAKE BAN
AddPlayer(10, "Fake Ban", function(state)
    if state then
        task.spawn(function()
            while true do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPos = player.Character.HumanoidRootPart
                    rootPos.Velocity = Vector3.new(0, 15, 0)
                    task.wait(0.5)
                    rootPos.Velocity = Vector3.new(0, 0, 0)
                    task.wait(4)
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum then
                        hum.Health = 0
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

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

print("MineBat v5.1 Loaded!")
