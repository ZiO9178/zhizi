local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local isRunning = false
local vehSpeed = 150
local autoLoopEnabled = false

local function GetTargetPosition(targetObj)
    if not targetObj then return nil end
    if targetObj:IsA("BasePart") then return targetObj.Position
    elseif targetObj:IsA("Model") then return targetObj:GetPivot().Position
    elseif targetObj:IsA("ObjectValue") or targetObj:IsA("Folder") then
        local part = targetObj:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position end
    end
    return nil
end

local function WaitForTarget(name, timeout)
    timeout = timeout or 15
    local elapsed = 0
    local lastPos = nil
    
    while elapsed < timeout do
        if not isRunning then break end
        
        local DoorNpcs = workspace:FindFirstChild("DoorNpcs")
        local obj = DoorNpcs and DoorNpcs:FindFirstChild(name)
        
        if obj then
            local pos = GetTargetPosition(obj)
            if pos then
                if lastPos and (pos - lastPos).Magnitude < 5 then
                    return pos
                end
                lastPos = pos
            end
        else
            lastPos = nil
        end
        
        task.wait(0.2)
        elapsed = elapsed + 0.2
    end
    return lastPos
end

local function SetVehicleCollision(vehicle, state)
    if not vehicle then return end
    for _, v in pairs(vehicle:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = state
        end
    end
end

local function FastStepMove(drivePart, targetPos, speed)
    local currentPos = drivePart.Position
    local distance = (currentPos - targetPos).Magnitude
    if distance < 2 then return end

    local stepSize = math.clamp(speed * 0.02, 2, 10) 
    local waitTime = 0.01
    
    local timeout = distance / (stepSize / waitTime) + 10
    local elapsed = 0

    while elapsed < timeout and isRunning do
        if not drivePart or not drivePart.Parent then break end
        
        local dir = targetPos - drivePart.Position
        local dist = dir.Magnitude
        if dist < 3 then break end
        
        local moveVec = dir.Unit * math.min(stepSize, dist)
        drivePart.CFrame = CFrame.new(drivePart.Position + moveVec) * drivePart.CFrame.Rotation
        
        task.wait(waitTime)
        elapsed = elapsed + waitTime
    end
end

local function MoveVehicleFly(targetPos, speed, vehicle)
    if not vehicle then return end
    local drivePart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not drivePart then return end

    pcall(function()
        if drivePart:CanSetNetworkOwnership() then
            drivePart:SetNetworkOwner(LocalPlayer)
        end
    end)

    SetVehicleCollision(vehicle, false)

    local currentPos = drivePart.Position
    local flyHeight = math.max(currentPos.Y, targetPos.Y) + 30
    
    local upPos = Vector3.new(currentPos.X, flyHeight, currentPos.Z)
    FastStepMove(drivePart, upPos, speed)

    local horizontalPos = Vector3.new(targetPos.X, flyHeight, targetPos.Z)
    FastStepMove(drivePart, horizontalPos, speed)

    local downPos = Vector3.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
    FastStepMove(drivePart, downPos, speed)
    
    SetVehicleCollision(vehicle, true)
    
    drivePart.AssemblyLinearVelocity = Vector3.zero
    drivePart.AssemblyAngularVelocity = Vector3.zero
end

local function MovePlayerWalk(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = false
    hum.WalkSpeed = speed
    
    local elapsed = 0
    local timeout = 30
    hum:MoveTo(targetPos)

    while elapsed < timeout and isRunning do
        if not char.Parent or not hum then break end
        if (hrp.Position - targetPos).Magnitude < 5 then break end
        task.wait(0.1)
        elapsed = elapsed + 0.1
    end
    
    if hum then
        hum:MoveTo(hrp.Position)
        hum.WalkSpeed = 16 
    end
end

local function FireDelivery()
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:FindFirstChild("Gameplay") 
        and rs.Gameplay:FindFirstChild("Deliveries") 
        and rs.Gameplay.Deliveries:FindFirstChild("SetActive")
    
    if event then
        pcall(function() event:FireServer(true) end)
        return true
    end
    return false
end

local function SpawnVehicle()
    local rs = game:GetService("ReplicatedStorage")
    local event = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("ResetScooter")
    if event then
        pcall(function() event:FireServer() end)
        return true
    end
    return false
end

local Window = WindUI:CreateWindow({
    Title = "滑板车模拟器",
    Icon = "monitor",
    Author = "Z某人",
    Folder = "AutoDelivery",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Midnight",
    HideSearchBar = false, 
})

local mainContainer = Window.UIElements and Window.UIElements.Main
if mainContainer then
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1, 1, 1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190, 0, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 0, 255))
    })
    gradient.Enabled = true
    gradient.Parent = stroke
    stroke.Parent = mainContainer

    task.spawn(function()
        local speed = 8
        while stroke and stroke.Parent do
            task.wait()
            gradient.Rotation = (gradient.Rotation + speed) % 360
        end
    end)
end

local TimeTag = Window:Tag({Title = "00:00", Color = Color3.fromRGB(255, 255, 255)})
local hue = 0
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        hue = (hue + 0.01) % 1
        TimeTag:SetTitle(hours .. ":" .. minutes)
        TimeTag:SetColor(Color3.fromHSV(hue, 1, 1)) 
        task.wait(0.06)
    end
end)

Window:EditOpenButton({
    Title = "打开脚本", Icon = "monitor", CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2, Color = ColorSequence.new(Color3.fromHex("9B59B6")), Draggable = true,
})

local Tab = Window:Tab({Title = "控制", Icon = "car", Locked = false})

Tab:Section({Title = "状态", TextXAlignment = "Left", TextSize = 17})

local StatusPara = Tab:Paragraph({Title = "状态", Desc = "等待启动"})

Tab:Slider({
    Title = "载具速度",
    Value = {Min = 50, Max = 300, Default = 150}, 
    Increment = 10,
    Callback = function(val) vehSpeed = val end,
})

local function RunCycle()
    StatusPara:SetTitle("状态: 召唤载具...")
    SpawnVehicle()
    task.wait(2)
    
    FireDelivery()
    task.wait(1.5)

    StatusPara:SetTitle("状态: 前往接单点...")
    -- 给 15 秒找寻时间，防抖读取
    local pickupPos = WaitForTarget("TutorialCustomer", 15)
    if not pickupPos then return false end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum and hum.SeatPart then
        local vehicle = hum.SeatPart:FindFirstAncestorOfClass("Model")
        if vehicle then
            MoveVehicleFly(pickupPos, vehSpeed, vehicle)
        else
            MovePlayerWalk(pickupPos, 18)
        end
    else
        MovePlayerWalk(pickupPos, 18)
    end
    
    task.wait(1)

    StatusPara:SetTitle("状态: 前往目的地...")
    local destPos = WaitForTarget("Player", 15)
    if not destPos then return false end

    char = LocalPlayer.Character
    hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum and hum.SeatPart then
        local vehicle = hum.SeatPart:FindFirstAncestorOfClass("Model")
        if vehicle then
            MoveVehicleFly(destPos, vehSpeed, vehicle)
        else
            MovePlayerWalk(destPos, 18)
        end
    else
        MovePlayerWalk(destPos, 18)
    end
    
    task.wait(1)
    return true
end

Tab:Button({
    Title = "轮一次",
    Callback = function()
        if isRunning then return end
        isRunning = true
        task.spawn(function()
            local success = RunCycle()
            isRunning = false
            if success then
                StatusPara:SetTitle("状态: 完成")
                WindUI:Notify({Title = "完成", Content = "已送达", Duration = 5})
            else
                StatusPara:SetTitle("状态: 失败")
                WindUI:Notify({Title = "错误", Content = "目标丢失", Duration = 5})
            end
        end)
    end,
})

Tab:Toggle({
    Title = "全自动",
    Default = false,
    Callback = function(state)
        autoLoopEnabled = state
        if state then
            if not isRunning then
                isRunning = true
                task.spawn(function()
                    while isRunning and autoLoopEnabled do
                        local success = RunCycle()
                        if not success then
                            WindUI:Notify({Title = "错误", Content = "目标丢失，停止", Duration = 5})
                            autoLoopEnabled = false
                            isRunning = false
                            break
                        end
                        task.wait(3)
                    end
                end)
            end
        else
            isRunning = false
            StatusPara:SetTitle("状态: 已停止")
        end
    end,
})

Tab:Button({
    Title = "停止",
    Callback = function()
        isRunning = false
        autoLoopEnabled = false
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                if hum.SeatPart then
                    local vehicle = hum.SeatPart:FindFirstAncestorOfClass("Model")
                    if vehicle then SetVehicleCollision(vehicle, true) end
                    pcall(function()
                        hum.SeatPart.ThrottleFloat = 0
                        hum.SeatPart.SteerFloat = 0
                    end)
                end
            end
        end
        StatusPara:SetTitle("状态: 已停止")
    end,
})