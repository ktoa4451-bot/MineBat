-- =========================================================
-- MINEBAT v1.0 (Чит с меню)
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChild("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

-- Меню (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "MineBatMenu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
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
-- ФУНКЦИИ
-- =========================================================

-- 1. Скорость через Velocity
Toggle(50, "Speed", function(state)
    if state then
        task.spawn(function()
            while state do
                if root and humanoid then
                    root.Velocity = root.Velocity + root.CFrame.LookVector * 1.5
                end
                task.wait(0.01)
            end
        end)
    end
end)

-- 2. Прыжок
Toggle(90, "Jump", function(state)
    if state then
        task.spawn(function()
            while state do
                if humanoid then
                    humanoid.JumpPower = 80
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- 3. Бесконечный прыжок
Toggle(130, "Infinite Jump", function(state)
    if state then
        task.spawn(function()
            while state do
                if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
                    local platform = Instance.new("Part")
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Transparency = 1
                    platform.Size = Vector3.new(4, 0.1, 4)
                    platform.Position = root.Position - Vector3.new(0, 2, 0)
                    platform.Parent = workspace
                    task.delay(0.1, function() platform:Destroy() end)
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- 4. Копание (Auto Mine)
Toggle(170, "Auto Mine", function(state)
    if state then
        task.spawn(function()
            while state do
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
                task.wait(0.1)
            end
        end)
    end
end)

-- Ключ V (переключение)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ScreenGui.Visible = not ScreenGui.Visible
    end
end)

print("MineBat v1.0 Loaded!")
