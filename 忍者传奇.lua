repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end

pcall(function()
	if _G.ThunderIntro_Stop then _G.ThunderIntro_Stop() end
end)

local function resolveGuiParent()
	local ok, res = pcall(function() return (gethui and gethui()) end)
	if ok and res then return res end
	ok, res = pcall(function() return (get_hidden_gui and get_hidden_gui()) end)
	if ok and res then return res end
	ok, res = pcall(function() return (gethiddengui and gethiddengui()) end)
	if ok and res then return res end
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
	if pg then return pg end
	return game:GetService("CoreGui")
end

local guiParent = resolveGuiParent()

local BLUE  = Color3.fromRGB(64, 145, 255)

local function Start(opts)
	opts = opts or {}
	local SIZE            = opts.size or 210
	local STROKE_THICK    = 18
	local CORNER          = 18
	local DURATION        = opts.duration or 6 
	local SPIN_STEP_DEG   = 90
	local SPIN_STEP_TIME  = 0.90
	local BREATH_MIN, BREATH_MAX = 0.98, 1.02

	local gui = Instance.new("ScreenGui")
	gui.Name = "ThunderIntro"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	local ok = pcall(function() gui.Parent = guiParent end)
	if not ok then
		local fallback = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
		if fallback then gui.Parent = fallback end
	end

	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(SIZE, SIZE)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.Parent = gui

	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromScale(1, 1)
	ring.BackgroundTransparency = 1
	ring.Parent = root
	local cornerRing = Instance.new("UICorner") cornerRing.CornerRadius = UDim.new(0, CORNER) cornerRing.Parent = ring
	local ringStroke = Instance.new("UIStroke")
	ringStroke.Thickness = STROKE_THICK
	ringStroke.Color = BLUE
	pcall(function() ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	ringStroke.Parent = ring

	local glow = Instance.new("Frame")
	glow.Size = UDim2.fromScale(1, 1)
	glow.BackgroundTransparency = 1
	glow.ZIndex = ring.ZIndex - 1
	glow.Parent = root
	local cornerGlow = Instance.new("UICorner") cornerGlow.CornerRadius = UDim.new(0, CORNER) cornerGlow.Parent = glow
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Thickness = 30
	glowStroke.Color = BLUE
	glowStroke.Transparency = 0.75
	pcall(function() glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	glowStroke.Parent = glow

	local inner = Instance.new("Frame")
	local innerSize = SIZE - STROKE_THICK * 2
	inner.Size = UDim2.fromOffset(innerSize, innerSize)
	inner.AnchorPoint = Vector2.new(0.5, 0.5)
	inner.Position = UDim2.fromScale(0.5, 0.5)
	inner.BackgroundTransparency = 1
	inner.ZIndex = 5
	inner.Parent = root

	
	local thunderText = Instance.new("TextLabel")
	thunderText.Size = UDim2.fromScale(0.7, 0.7)
	thunderText.AnchorPoint = Vector2.new(0.5, 0.5)
	thunderText.Position = UDim2.fromScale(0.5, 0.5)
	thunderText.BackgroundTransparency = 1
	thunderText.Text = "忍者传奇"
	thunderText.TextColor3 = BLUE
	thunderText.TextScaled = true
	thunderText.Font = Enum.Font.GothamBlack
	thunderText.Rotation = -8.56
	thunderText.TextTransparency = 0.10
	thunderText.ZIndex = 7
	thunderText.Parent = inner

	
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,220,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	}
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	}
	gradient.Parent = thunderText

	local ringScale = Instance.new("UIScale", ring) ringScale.Scale = 1

	local alive, hbConn = true, nil
	_G.ThunderIntro_Stop = function()
		if not alive then return end
		alive = false
		if hbConn then hbConn:Disconnect() end
		if gui and gui.Parent then gui:Destroy() end
	end
	
	-- Spin
	task.spawn(function()
		while alive do
			local tw1 = TweenService:Create(ring, TweenInfo.new(SPIN_STEP_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = ring.Rotation + SPIN_STEP_DEG})
			local tw2 = TweenService:Create(glow, TweenInfo.new(SPIN_STEP_TIME,   Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = glow.Rotation + SPIN_STEP_DEG})
			tw1:Play() tw2:Play()
			tw1.Completed:Wait()
		end
	end)
	
	-- Breathe
	task.spawn(function()
		while alive do
			TweenService:Create(ringScale, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = BREATH_MAX}):Play()
			task.wait(0.6)
			TweenService:Create(ringScale, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = BREATH_MIN}):Play()
			task.wait(0.6)
		end
	end)

	-- Gradient sheen animation
	task.spawn(function()
		while alive do
			for i = 0,360,10 do
				gradient.Rotation = i
				task.wait(0.03)
			end
		end
	end)

	-- Auto fade + destroy
	if DURATION and DURATION > 0 then
		task.delay(DURATION, function()
			if not alive then return end
			local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(ringStroke,  ti, {Transparency = 1}):Play()
			TweenService:Create(glowStroke,  ti, {Transparency = 1}):Play()
			TweenService:Create(thunderText, ti, {TextTransparency = 1}):Play()
			task.wait(0.45)
			_G.ThunderIntro_Stop()
		end)
	end

	return gui
end

Start({duration = 6}) -- lasts longer

print("反挂机开启")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)

local Sound = Instance.new("Sound")
        Sound.Parent = game.SoundService
        Sound.SoundId = "rbxassetid://4590662766"
        Sound.Volume = 3
        Sound.PlayOnRemove = true
        Sound:Destroy()
        
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CNHM/asg/refs/heads/main/wind%20ui.lua"))()

local Window = WindUI:CreateWindow({
        Title = "Z脚本|忍者传奇",
        Icon = "shield-user",
        Author = "作者:Z某人",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 200,
        Background = "",
        BackgroundImageTransparency = 0.42,
        HideSearchBar = false,
        ScrollBarEnabled = true,
        User = {
            Enabled = true,
            Anonymous = false,
            Callback = function()
                print("clicked")
            end,
    },
})

Window:EditOpenButton({
    Title = "   打开Z脚本丨忍者传奇   ",
    Icon = "shield-check",
    CornerRadiu = UDim.new(0,16),
    StrokeThickness = 3,
    Color = ColorSequence.new( 
        Color3.fromHex("000000"), 
        Color3.fromHex("FFFFFF"), 
        Color3.fromHex("000000")   
    ),
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "自动功能",
    Icon = "warehouse",
    Locked = false,
})

local running = false
local Toggle = Tab:Toggle({
    Title = "自动挥舞",
    Desc = "",
    Locked = false,
    Callback = function(state)
        running = state
        while running do
            local args = {
                [1] = "swingKatana"
            }
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
            wait() -- Add a small delay to prevent crashing
        end
    end
})

local Toggle = Tab:Toggle({
    Title = "无限跳跃",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            -- 启用无限跳跃
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            
            -- 连接跳跃检测
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if state then  -- 确保开关仍然开启
                    character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            -- 禁用无限跳跃 - 不需要特别操作，连接会自动处理
        end
    end
})

local collecting = false
local connections = {}

local Toggle = Tab:Toggle({
    Title = "自动收集",
    Desc = "",
    Locked = false,
    Callback = function(state)
        collecting = state
        
        -- 清除之前的连接（如果存在）
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        
        if state then
            -- 开启自动收集
            local function collectCoins()
                if not collecting then return end
                
                -- 获取所有硬币
                local coins = workspace.spawnedCoins.Valley:GetChildren()
                
                for _, coin in pairs(coins) do
                    if coin:FindFirstChild("TouchInterest") then
                        -- 模拟玩家触碰硬币
                        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            firetouchinterest(coin, humanoid.RootPart, 0) -- 开始触碰
                            firetouchinterest(coin, humanoid.RootPart, 1) -- 结束触碰
                        end
                    end
                end
                
                -- 设置下次收集
                table.insert(connections, game:GetService("RunService").Heartbeat:Connect(function()
                    collectCoins()
                end))
            end
            
            -- 初始收集
            collectCoins()
        end
    end
})

-- 当玩家离开时自动关闭
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    collecting = false
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end)

local Tab = Window:Tab({
    Title = "传送功能",
    Icon = "warehouse",
    Locked = false,
})

local Button = Tab:Button({
    Title = "远古地狱岛",
    Desc = "",
    Locked = false,
    Callback = function()
        -- 获取本地玩家
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- 确保角色存在且有Humanoid
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- 获取传送点位置
            local teleportPart = workspace.areaTeleportParts.groundToAncientInfernoIsland
            if teleportPart then
                -- 传送到目标位置（稍微高于传送点以防卡住）
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到远古地狱岛")
            else
                warn("找不到传送点！")
            end
        else
            warn("无法找到玩家角色或HumanoidRootPart！")
        end
    end
})

local Button = Tab:Button({
    Title = "传送到星界岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToAstralIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到星界岛")
            else
                warn("找不到星界岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "炽热漩涡岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToBlazingVortexIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到炽热漩涡岛")
            else
                warn("找不到炽热漩涡岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "混沌传奇岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToChaosLegendsIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到混沌传奇岛")
            else
                warn("找不到混沌传奇岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "传送到赛博传奇岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToCyberneticLegendsIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到赛博传奇岛")
            else
                warn("找不到赛博传奇岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "暗影元素岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToDarkElementsIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到暗影元素岛")
            else
                warn("找不到暗影元素岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "龙之传说岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToDragonLegendIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到龙之传说岛")
            else
                warn("找不到龙之传说岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "魔法秘境岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToEnchantedIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到魔法秘境岛")
            else
                warn("找不到魔法秘境岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "永恒之岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToEternalIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到永恒之岛")
            else
                warn("找不到永恒之岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "冬日仙境岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToWinterWonderIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到冬日仙境岛")
            else
                warn("找不到冬日仙境岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "苔原岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToTundraIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到苔原岛")
            else
                warn("找不到苔原岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "雷暴岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToThunderstormIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 5, 0)  -- 高度提升到5防雷击陷地
                print("已传送到雷暴岛")
            else
                warn("找不到雷暴岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "灵魂融合岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToSoulFusionIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame * CFrame.new(0, 3, -2)  -- 后退2单位防止灵魂屏障碰撞
                print("已传送到灵魂融合岛")
            else
                warn("找不到灵魂融合岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "天暴终极岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToSkystormUltrausIsland
            if teleportPart then
                -- 基础传送（保持Y轴+3单位）
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到天暴终极岛")
            else
                warn("找不到天暴终极岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "沙暴岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToSandstormIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到沙暴岛")
            else
                warn("找不到沙暴岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "神话灵魂岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToMythicalSoulsIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到神话灵魂岛")
            else
                warn("找不到神话灵魂岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "神秘岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToMysticalIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到神秘岛")
            else
                warn("找不到神秘岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "午夜岛",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToMidnightIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到午夜岛")
            else
                warn("找不到午夜岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

local Button = Tab:Button({
    Title = "心灵宁静岛",
    Desc = "", 
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local teleportPart = workspace.areaTeleportParts.groundToInnerPeaceIsland
            if teleportPart then
                character.HumanoidRootPart.CFrame = teleportPart.CFrame + Vector3.new(0, 3, 0)
                print("已传送到心灵宁静岛")
            else
                warn("找不到心灵宁静岛传送点！")
            end
        else
            warn("角色或 HumanoidRootPart 不存在！")
        end
    end
})

