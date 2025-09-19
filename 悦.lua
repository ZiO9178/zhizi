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
	thunderText.Text = "悦"
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
        Title = "Z脚本|悦",
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
    Title = "打开Z脚本|悦",
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

local player = Players.LocalPlayer
local oreFolder = workspace.Map.Houses["\231\159\191\230\180\158"].Ores -- 您提供的矿石路径 (即 "矿山")
local mineEvent = ReplicatedStorage:WaitForChild("MineEvent") -- 【重要】请将 "MineEvent" 替换为游戏中真正负责挖矿的RemoteEvent名称

-- 控制变量
local isAutoMining = false -- 主开关状态
local isFastMode = false   -- 快速模式开关状态
local miningLoopConnection = nil -- 用于控制循环任务

-- 将挖矿逻辑封装成一个函数
local function startMiningLoop()
    -- 创建一个新的线程来运行循环，防止游戏卡死
    miningLoopConnection = coroutine.wrap(function()
        while isAutoMining do
            -- 确保玩家角色和模型都存在
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                RunService.Heartbeat:Wait()
                continue
            end

            local playerPos = player.Character.HumanoidRootPart.Position
            local nearestOre = nil
            local shortestDist = math.huge

            -- 遍历所有矿石，找到最近的一个
            for _, ore in pairs(oreFolder:GetChildren()) do
                -- 简单的检查，确保目标是一个有效的部件
                if ore:IsA("BasePart") and ore:FindFirstChild("Position") then
                    local distance = (playerPos - ore.Position).Magnitude
                    if distance < shortestDist then
                        shortestDist = distance
                        nearestOre = ore
                    end
                end
            end

            -- 如果找到了最近的矿石
            if nearestOre then
                print("找到最近的矿石: " .. nearestOre.Name .. ", 距离: " .. math.floor(shortestDist))

                -- 移动到矿石旁边 (如果距离太远)
                if shortestDist > 15 then
                     player.Character.Humanoid:MoveTo(nearestOre.Position)
                     -- 等待角色靠近矿石
                     repeat RunService.Heartbeat:Wait() until not isAutoMining or (player.Character.HumanoidRootPart.Position - nearestOre.Position).Magnitude < 15
                end
                
                -- 如果在移动过程中关闭了开关，则退出
                if not isAutoMining then break end

                -- 根据是否开启快速模式来决定如何挖矿
                if isFastMode then
                    -- === 快速模式 ===
                    print("快速模式挖掘中...")
                    for i = 1, 10 do
                        if not isAutoMining then break end -- 如果中途关闭，立即停止
                        mineEvent:FireServer(nearestOre)
                    end
                    wait(0.1) -- 快速模式下的短暂间隔
                else
                    -- === 普通模式 ===
                    print("普通模式挖掘中...")
                    mineEvent:FireServer(nearestOre)
                    wait(1) -- 普通模式下的标准间隔
                end

            else
                print("未找到任何矿石，5秒后重试...")
                wait(5)
            end
             -- 每次循环都短暂等待，给游戏处理时间，防止崩溃
            RunService.Heartbeat:Wait()
        end
    end)()
end

-- 创建UI元素 (这里使用你提供的 Tab:Toggle 格式)
-- 主开关
local MainToggle = Tab:Toggle({
    Title = "自动挖矿 (Auto Mining)",
    Desc = "启动或停止自动寻找并挖掘矿石。",
    Locked = false,
    Callback = function(state)
        isAutoMining = state
        if isAutoMining then
            -- 如果开启，则启动挖矿循环
            startMiningLoop()
        else
            -- 如果关闭，miningLoopConnection 会因为 isAutoMining = false 而自然停止
            print("自动挖矿已停止。")
        end
    end
})

-- 快速模式的子开关
local FastModeToggle = Tab:Toggle({
    Title = "  ㄴ 启用快速模式 (Enable Fast Mode)", -- 使用特殊字符让它看起来像子选项
    Desc = "开启后，自动挖矿会以极快速度进行。风险更高！",
    Locked = false,
    Callback = function(state)
        isFastMode = state
        if isFastMode then
            print("快速模式已启用！")
        else
            print("快速模式已关闭。")
        end
    end
})