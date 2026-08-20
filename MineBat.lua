local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerScripts = player:WaitForChild("PlayerScripts")
local attack = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")
local disable = playerScripts:FindFirstChild("DisableUse")
local env = getgenv()
local character, humanoid, root, camera
local jumpConn, charConn, jumpRequestConn
local fpTrack, fpAnim, charTrack, charAnim
local jumped, jumpAt = false, 0
local enabled, radius = true, 170
local fallY, scanRate = -1.5, 0.04
local lastScan, lastSwing, currentTool = 0, 0, nil
local corners = {
    Vector3.new(-1,-1,-1), Vector3.new(-1,-1,1),
    Vector3.new(-1,1,-1), Vector3.new(-1,1,1),
    Vector3.new(1,-1,-1), Vector3.new(1,-1,1),
    Vector3.new(1,1,-1), Vector3.new(1,1,1)
}
local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.IgnoreWater = true
local function new(class, parent, props)
    local i = Instance.new(class, parent)
    for k, v in pairs(props or {}) do i[k] = v end
    return i
end
local function notif(text)
    task.spawn(function()
        for _ = 1, 6 do
            if pcall(function()
                StarterGui:SetCore("SendNotification", {Title="Hiyo!", Text=text, Duration=3})
            end) then return end
            task.wait(0.25)
        end
    end)
end
if env.__silenttrigger then pcall(function() env.__silenttrigger:Destroy() end) end
local old = playerGui:FindFirstChild("!Fov")
if old then old:Destroy() end
local silenttrigger = {}
env.__silenttrigger = silenttrigger
local gui = new("ScreenGui", playerGui, {Name="!Fov", ResetOnSpawn=false, ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder=999, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local circle = new("Frame", gui, {Name="!Circle", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(radius*2,radius*2), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=999})
new("UICorner", circle, {CornerRadius=UDim.new(1,0)})
local stroke = new("UIStroke", circle, {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=Color3.fromRGB(255,255,255), Thickness=2, Transparency=0})

local function bind(char)
    if jumpConn then jumpConn:Disconnect() end
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    camera = workspace.CurrentCamera
    jumped, jumpAt = false, 0
    fpTrack, fpAnim, charTrack, charAnim = nil, nil, nil, nil
    currentTool = nil
    jumpConn = humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping then
            jumped, jumpAt = true, tick()
        elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
            jumped = false
        end
    end)
end
bind(player.Character or player.CharacterAdded:Wait())
charConn = player.CharacterAdded:Connect(bind)
jumpRequestConn = UserInputService.JumpRequest:Connect(function()
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.FloorMaterial == Enum.Material.Air then return end
    jumped, jumpAt = true, tick()
end)

local function refs()
    camera = workspace.CurrentCamera
    if not character or not character.Parent then return false end
    if not humanoid or humanoid.Health <= 0 then return false end
    if not root or not root.Parent or not camera then return false end
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
    local interval = math.max(tonumber(tool:GetAttribute("ChargeTime")) or 0.5,0.36)
    return tool, range, interval
end
local function ready()
    if not jumped then return true end
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        if tick()-jumpAt < 0.18 then return false end
        jumped = false
        return true
    end
    return root.AssemblyLinearVelocity.Y <= fallY
end
local function fovdist(model, cursor)
    local best = math.huge
    for _, part in ipairs(model:GetChildren()) do
        if not part:IsA("BasePart") then continue end
        local half = part.Size*0.5
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local found = false
        for _, corner in ipairs(corners) do
            local offset = Vector3.new(half.X*corner.X,half.Y*corner.Y,half.Z*corner.Z)
            local pos = camera:WorldToViewportPoint(part.CFrame:PointToWorldSpace(offset))
            if pos.Z <= 0 then continue end
            found = true
            minX, minY = math.min(minX,pos.X), math.min(minY,pos.Y)
            maxX, maxY = math.max(maxX,pos.X), math.max(maxY,pos.Y)
        end
        if not found then continue end
        local closest = Vector2.new(math.clamp(cursor.X,minX,maxX),math.clamp(cursor.Y,minY,maxY))
        best = math.min(best,(cursor-closest).Magnitude)
        if best <= radius then return best end
    end
    return best
end
local function rangeok(model, range)
    local best = math.huge
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then best = math.min(best,(part.Position-root.Position).Magnitude) end
    end
    return best <= range+0.5
end
local function models()
    local list, seen = {}, {}
    local function add(model)
        if not model or model == character or seen[model] or not model:IsA("Model") then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local targetRoot = model:FindFirstChild("HumanoidRootPart") or hum and hum.RootPart
        if not hum or not targetRoot or hum.Health <= 0 then return end
        seen[model] = true
        table.insert(list,model)
    end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then add(other.Character) end
    end
    local ai = workspace:FindFirstChild("Ai")
    if ai then
        for _, model in ipairs(ai:GetChildren()) do add(model) end
    end
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then add(model) end
    end
    return list
end
local function valid(model, cursor, range)
    if not rangeok(model,range) then return false end
    if fovdist(model,cursor) > radius then return false end
    return true
end
local function replay(track)
    if not track then return end
    pcall(function()
        track:Stop(0)
        track.TimePosition = 0
        track:Play(0.03,1,1)
    end)
end
local function play(tool)
    local equipped = character:FindFirstChild(tool.Name) or tool
    local animations = equipped:FindFirstChild("Animations")
    local swing = animations and animations:FindFirstChild("RightSwing")
    if swing then
        local animMod = character:FindFirstChild("AnimMod")
        local played = animMod and pcall(function() require(animMod).PlayAnimation(swing) end)
        if not played then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                if charAnim ~= swing or not charTrack then
                    charTrack = animator:LoadAnimation(swing)
                    charTrack.Priority = Enum.AnimationPriority.Action
                    charAnim = swing
                end
                replay(charTrack)
            end
        end
    end
    local arms = camera:FindFirstChild("FPArms")
    local controller = arms and arms:FindFirstChildOfClass("AnimationController")
    local animator = controller and controller:FindFirstChildOfClass("Animator")
    local fpTool = arms and arms:FindFirstChild(tool.Name)
    local fpAnimations = fpTool and fpTool:FindFirstChild("FPAnimations")
    local fpSwing = fpAnimations and fpAnimations:FindFirstChild("RightSwing")
    if not fpSwing and arms then
        local fallback = arms:FindFirstChild("Animations")
        fpSwing = fallback and fallback:FindFirstChild("RightSwing")
    end
    if animator and fpSwing then
        if fpAnim ~= fpSwing or not fpTrack then
            fpTrack = animator:LoadAnimation(fpSwing)
            fpTrack.Priority = Enum.AnimationPriority.Action
            fpAnim = fpSwing
        end
        replay(fpTrack)
    end
end
function silenttrigger:Destroy()
    enabled = false
    if self.render then self.render:Disconnect() end
    if self.input then self.input:Disconnect() end
    if jumpConn then jumpConn:Disconnect() end
    if charConn then charConn:Disconnect() end
    if jumpRequestConn then jumpRequestConn:Disconnect() end
    if fpTrack then pcall(function() fpTrack:Stop() end) end
    if charTrack then pcall(function() charTrack:Stop() end) end
    if gui then gui:Destroy() end
    if env.__silenttrigger == self then env.__silenttrigger = nil end
end

silenttrigger.render = RunService.Heartbeat:Connect(function()
    circle.Size = UDim2.fromOffset(radius*2,radius*2)
    stroke.Color = enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(110,110,110)
    if not enabled or not refs() then return end
    if disable and disable.Value then return end
    local inventory = playerGui:FindFirstChild("Inventory")
    if inventory and inventory:IsA("ScreenGui") and inventory.Enabled then return end
    local settings = workspace:FindFirstChild("Settings")
    local pvp = settings and settings:FindFirstChild("PVP")
    if pvp and not pvp.Value then return end
    local tool, range, interval = weapon()
    if not tool then
        if currentTool then currentTool = nil; notif("No compatible weapon equipped ;c") end
        return
    end
    if currentTool ~= tool then
        currentTool = tool
        fpTrack, fpAnim, charTrack, charAnim = nil, nil, nil, nil
        notif(tool.Name.." detected")
    end
    if not ready() then return end
    local now = tick()
    if now-lastScan < scanRate then return end
    lastScan = now
    if now-lastSwing < interval then return end
    local cursor = camera.ViewportSize*0.5
    local targets = {}
    for _, model in ipairs(models()) do
        if valid(model,cursor,range) then table.insert(targets,model) end
    end
    if #targets == 0 then return end
    lastSwing = now
    play(tool)
    for _, model in ipairs(targets) do
        if model.Parent then attack:FireServer(model,1,nil,tool.Name) end
    end
end)
silenttrigger.input = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.V then
        enabled = not enabled
        notif(enabled and "Enabled" or "Disabled")
    elseif input.KeyCode == Enum.KeyCode.Delete then
        notif("Unloaded")
        silenttrigger:Destroy()
    end
end)
notif("Loaded! V to toggle off/on PC!")
