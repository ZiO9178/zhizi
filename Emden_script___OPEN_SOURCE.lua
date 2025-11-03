--[[
Open source :D!
skidded scripts exposed server:
https://discord.gg/SQxeSkJ5cY
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local SpeedMultiplier = 1
local JumpMultiplier = 1
local NoClipEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local Flying = false
local FlyConnection = nil
local NoclipLoop = nil
local NameTagEnabled = false
local NameTag = nil
local antiFallDamageEnabled = false
local infinityJumpEnabled = false
local changingColors = false
local isForceField = false
local godModeEnabled = false
local ESPEnabled = false
local BoxESP = false
local LineESP = false
local HealthESP = false
local ESPObjects = {}

local SpeedConnection
local function SetupSpeedHack()
    if SpeedConnection then
        SpeedConnection:Disconnect()
    end
    
    SpeedConnection = RunService.Heartbeat:Connect(function()
        if Character and HumanoidRootPart and Humanoid then
            local moveDirection = Humanoid.MoveDirection
            
            if moveDirection.Magnitude > 0 then
                local newVelocity = moveDirection * (16 * SpeedMultiplier)
                HumanoidRootPart.Velocity = Vector3.new(
                    newVelocity.X,
                    HumanoidRootPart.Velocity.Y,
                    newVelocity.Z
                )
            end
        end
    end)
end

local function ToggleFly()
    FlyEnabled = not FlyEnabled
    
    if FlyEnabled then
        Flying = true
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        BodyVelocity.Parent = HumanoidRootPart
        
        Humanoid.PlatformStand = true
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not FlyEnabled or not Character then
                if FlyConnection then
                    FlyConnection:Disconnect()
                end
                return
            end
            
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                BodyVelocity.Velocity = moveDirection.Unit * FlySpeed
            else
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "Fly Enabled",
            Content = "Fly mode has been activated!",
            Time = 3
        })
    else
        Flying = false
        Humanoid.PlatformStand = false
        
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
        
        OrionLib:MakeNotification({
            Name = "Fly Disabled",
            Content = "Fly mode has been deactivated!",
            Time = 3
        })
    end
end

local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    
    if NoClipEnabled then
        NoclipLoop = RunService.Stepped:Connect(function()
            if Character and NoClipEnabled then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "NoClip Enabled",
            Content = "NoClip mode has been activated!",
            Time = 3
        })
    else
        if NoclipLoop then
            NoclipLoop:Disconnect()
            NoclipLoop = nil
        end

        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        OrionLib:MakeNotification({
            Name = "NoClip Disabled",
            Content = "NoClip mode has been deactivated!",
            Time = 3
        })
    end
end

local function ToggleForceField(state)
    isForceField = state
    
    if isForceField then
        local forceField = Instance.new("ForceField")
        forceField.Parent = Character
        forceField.Name = "nigga"

        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.ForceField
                part.Transparency = 0.3
                part.Color = Color3.fromRGB(0, 150, 255)
            end
        end
        
        OrionLib:MakeNotification({
            Name = "ForceField Enabled",
            Content = "ForceField has been activated!",
            Time = 3
        })
    else
        local forceField = Character:FindFirstChild("nigga")
        if forceField then
            forceField:Destroy()
        end
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
                part.Transparency = 0
                part.Color = Color3.fromRGB(255, 255, 255)
            end
        end
        
        OrionLib:MakeNotification({
            Name = "ForceField Disabled",
            Content = "ForceField has been deactivated!",
            Time = 3
        })
    end
end

--// God Mode System (FIXED)
local function ToggleGodMode(state)
    godModeEnabled = state
    
    if godModeEnabled then
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                    part.CanQuery = false
                end
            end
            
            if Humanoid then
                Humanoid.MaxHealth = math.huge
                Humanoid.Health = math.huge
            end
        end
        
        OrionLib:MakeNotification({
            Name = "God Mode Enabled",
            Content = "God Mode has been activated!",
            Time = 3
        })
    else
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = true
                    part.CanQuery = true
                end
            end
            
            if Humanoid then
                Humanoid.MaxHealth = 100
                Humanoid.Health = 100
            end
        end
        
        OrionLib:MakeNotification({
            Name = "God Mode Disabled",
            Content = "God Mode has been deactivated!",
            Time = 3
        })
    end
end

local function SetupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if infinityJumpEnabled and Character and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function SetupAntiFallDamage()
    RunService.Heartbeat:Connect(function()
        if antiFallDamageEnabled and Character and HumanoidRootPart then
            local velocity = HumanoidRootPart.Velocity
            if velocity.Y < -50 then
                HumanoidRootPart.Velocity = Vector3.new(velocity.X, -5, velocity.Z)
            end
        end
    end)
end

local rainbowColors = {
    Color3.fromRGB(255, 0, 0),    -- Rot
    Color3.fromRGB(255, 127, 0),  -- Orange
    Color3.fromRGB(255, 255, 0),  -- Gelb
    Color3.fromRGB(0, 255, 0),    -- Grün
    Color3.fromRGB(0, 0, 255),    -- Blau
    Color3.fromRGB(75, 0, 130),   -- Indigo
    Color3.fromRGB(148, 0, 211)   -- Violett
}

local function ToggleRainbowCharacter(state)
    changingColors = state
    
    if changingColors then
        coroutine.wrap(function()
            local currentIndex = 1
            while changingColors and Character do
                local newColor = rainbowColors[currentIndex]
                
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.Color = newColor
                        end)
                    end
                end
                
                currentIndex = (currentIndex % #rainbowColors) + 1
                task.wait(0.3)
            end
        end)()
        
        OrionLib:MakeNotification({
            Name = "Rainbow Mode Enabled",
            Content = "Rainbow Character has been activated!",
            Time = 3
        })
    else
        OrionLib:MakeNotification({
            Name = "Rainbow Mode Disabled",
            Content = "Rainbow Character has been deactivated!",
            Time = 3
        })
    end
end

local function toggleNameTag(state)
    NameTagEnabled = state

    if NameTagEnabled then
        if NameTag then 
            NameTag:Destroy()
            NameTag = nil
        end
        
        local head = Character:FindFirstChild("Head")
        if head then
            NameTag = Instance.new("BillboardGui")
            NameTag.Name = "nigga"
            NameTag.Parent = head
            NameTag.Size = UDim2.new(0, 200, 0, 50)
            NameTag.StudsOffset = Vector3.new(0, 2.5, 0)
            NameTag.AlwaysOnTop = true
            NameTag.Enabled = true
            NameTag.Adornee = head

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = NameTag
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = "KING OF CLIENT SIDE"
            TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            TextLabel.TextScaled = true
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.ZIndex = 10
        end
    else
        if NameTag then
            NameTag:Destroy()
            NameTag = nil
        end
    end
end

local function GetTeamColor(Player)
    if Player.Team then
        return Player.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP(Player)
    if Player == Player then return end
    
    local ESPData = {
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Name = Drawing.new("Text")
    }
    
    ESPData.Box.Visible = false
    ESPData.Box.Thickness = 2
    ESPData.Box.Filled = false
    
    ESPData.Line.Visible = false
    ESPData.Line.Thickness = 1
    
    ESPData.HealthBar.Visible = false
    ESPData.HealthBar.Thickness = 3
    
    ESPData.Name.Visible = false
    ESPData.Name.Size = 13
    ESPData.Name.Center = true
    
    ESPObjects[Player] = ESPData
    return ESPData
end

local function UpdateESP()

    for player, espData in pairs(ESPObjects) do
        if not player or not player.Parent then
            for _, drawing in pairs(espData) do
                drawing:Remove()
            end
            ESPObjects[player] = nil
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and not ESPObjects[player] then
            CreateESP(player)
        end
    end
    
    if not ESPEnabled then return end
    
    coroutine.wrap(function()
        while ESPEnabled do
            for player, espData in pairs(ESPObjects) do
                if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    for _, drawing in pairs(espData) do
                        drawing.Visible = false
                    end
                    continue
                end
                
                local character = player.Character
                local hrp = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not head or not humanoid then
                    for _, drawing in pairs(espData) do
                        drawing.Visible = false
                    end
                    continue
                end
                
                local camera = workspace.CurrentCamera
                local screenPosition, onScreen = camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                    local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local teamColor = GetTeamColor(player)

                    if BoxESP then
                        espData.Box.Size = Vector2.new(math.abs(headPos.X - legPos.X), math.abs(headPos.Y - legPos.Y))
                        espData.Box.Position = Vector2.new(screenPosition.X - espData.Box.Size.X / 2, screenPosition.Y - espData.Box.Size.Y / 2)
                        espData.Box.Color = teamColor
                        espData.Box.Visible = true
                    else
                        espData.Box.Visible = false
                    end

                    if LineESP then
                        espData.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        espData.Line.To = Vector2.new(screenPosition.X, screenPosition.Y)
                        espData.Line.Color = teamColor
                        espData.Line.Visible = true
                    else
                        espData.Line.Visible = false
                    end

                    if HealthESP then
                        local healthPercentage = humanoid.Health / humanoid.MaxHealth
                        local barHeight = math.abs(headPos.Y - legPos.Y) * healthPercentage
                        
                        espData.HealthBar.From = Vector2.new(espData.Box.Position.X - 6, espData.Box.Position.Y + espData.Box.Size.Y)
                        espData.HealthBar.To = Vector2.new(espData.Box.Position.X - 6, espData.Box.Position.Y + espData.Box.Size.Y - barHeight)
                        espData.HealthBar.Color = Color3.fromRGB(255 - (healthPercentage * 255), healthPercentage * 255, 0)
                        espData.HealthBar.Visible = true
                    else
                        espData.HealthBar.Visible = false
                    end
                    
                    espData.Name.Position = Vector2.new(screenPosition.X, screenPosition.Y - espData.Box.Size.Y / 2 - 20)
                    espData.Name.Text = player.Name
                    espData.Name.Color = teamColor
                    espData.Name.Visible = true
                    
                else
                    for _, drawing in pairs(espData) do
                        drawing.Visible = false
                    end
                end
            end
            task.wait()
        end
    end)()
end

local function AdvancedTeleport(targetPosition)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        
        OrionLib:MakeNotification({
            Name = "Teleport Successful",
            Content = "Teleported to destination!",
            Time = 3
        })
    end
end

local Window = OrionLib:MakeWindow({
    Name = "k00pzr shitkidd emden GUI | RECOVERD",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "f",
    IntroEnabled = true,
    IntroText = "higgas"
})

--// Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSection({
    Name = "kkk"
})

local SpeedSlider = MainTab:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 1,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        SpeedMultiplier = Value
    end
})

local JumpSlider = MainTab:AddSlider({
    Name = "Jump Multiplier",
    Min = 1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        JumpMultiplier = Value
    end
})

MainTab:AddButton({
    Name = "Toggle Fly (X)",
    Callback = function()
        ToggleFly()
    end
})

MainTab:AddButton({
    Name = "Toggle NoClip (N)",
    Callback = function()
        ToggleNoClip()
    end
})

PlayerTab:AddSection({
    Name = "Player Modifications"
})

PlayerTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        ToggleGodMode(Value)
    end
})

PlayerTab:AddToggle({
    Name = "ForceField",
    Default = false,
    Callback = function(Value)
        ToggleForceField(Value)
    end
})

PlayerTab:AddToggle({
    Name = "Anti Fall Damage",
    Default = false,
    Callback = function(Value)
        antiFallDamageEnabled = Value
        if Value then
            OrionLib:MakeNotification({
                Name = "Anti Fall Damage",
                Content = "Anti Fall Damage has been activated!",
                Time = 3
            })
        end
    end
})

PlayerTab:AddToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(Value)
        infinityJumpEnabled = Value
        if Value then
            OrionLib:MakeNotification({
                Name = "Infinity Jump",
                Content = "Infinity Jump has been activated!",
                Time = 3
            })
        end
    end
})

PlayerTab:AddToggle({
    Name = "Nametag",
    Default = false,
    Callback = function(Value)
        toggleNameTag(Value)
    end
})

VisualTab:AddSection({
    Name = "ESP Settings"
})

VisualTab:AddButton({
    Name = "ESP",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"))()
    end
})

VisualTab:AddSection({
    Name = "Character Visuals"
})

VisualTab:AddToggle({
    Name = "Rainbow Character",
    Default = false,
    Callback = function(Value)
        ToggleRainbowCharacter(Value)
    end
})

TeleportTab:AddSection({
    Name = "Safe Locations"
})

TeleportTab:AddButton({
    Name = "Teleport Safe Spot",
    Callback = function()
        AdvancedTeleport(Vector3.new(-1174.12, 1309.02, 3578.10))
    end
})

TeleportTab:AddSection({
    Name = "Shops & Services"
})

local teleportLocations = {
    ["UG Corner Shop"] = Vector3.new(-301.88, 44.21, -76.12),
    ["Drone Store"] = Vector3.new(-339.94, 44.21, -517.48),
    ["General Store"] = Vector3.new(-102.43, 44.21, -757.93),
    ["Ship Spawner"] = Vector3.new(-581.32, 35.00, -1707.60),
    ["Car Shop"] = Vector3.new(85.44, 44.21, -2184.96),
    ["Tuner Shop"] = Vector3.new(280.90, 44.21, -2105.23),
    ["Hospital"] = Vector3.new(586.84, 44.21, -1762.20),
    ["Fire Department"] = Vector3.new(-1822.48, 44.21, 437.79),
    ["Prison"] = Vector3.new(-3290.83, 44.21, -193.20),
    ["Police Station"] = Vector3.new(-75.49, 71.66, 739.14)
}

for name, position in pairs(teleportLocations) do
    TeleportTab:AddButton({
        Name = "Teleport " .. name,
        Callback = function()
            AdvancedTeleport(position)
        end
    })
end

TeleportTab:AddSection({
    Name = "Robberies"
})

local robberyLocations = {
    ["Gas Station 1"] = Vector3.new(-1174.12, 1309.02, 3578.10),
    ["Gas Station 2"] = Vector3.new(-641.21, 44.06, 2366.95),
    ["Gas Station 3"] = Vector3.new(510.29, 44.42, -2235.49),
    ["Bank"] = Vector3.new(-505.53, 44.21, -1368.42),
    ["Jewelry Store"] = Vector3.new(-455.72, 45.41, 345.04)
}

for name, position in pairs(robberyLocations) do
    TeleportTab:AddButton({
        Name = "Teleport " .. name,
        Callback = function()
            AdvancedTeleport(position)
        end
    })
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.N then
        ToggleNoClip()
    end
end)

SetupSpeedHack()
SetupInfiniteJump()
SetupAntiFallDamage()

Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    SetupSpeedHack()
    
    if NameTagEnabled then
        toggleNameTag(true)
    end
    if isForceField then
        ToggleForceField(true)
    end
    if godModeEnabled then
        ToggleGodMode(true)
    end
end)

OrionLib:Init()