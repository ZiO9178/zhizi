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
	thunderText.Text = "超速射撀"
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
        Title = "Sxingz Hub|超速射撀",
        Icon = "shield-user",
        Author = "作者:Z某人",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 200,
        Background = "rbxassetid://77044761659704",
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
    Title = "打开Sxingz|超速射撀",
    Icon = "shield-check",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))
    }),
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "ESP功能",
    Icon = "server",
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "敌人显示",
    Desc = "显示敌人名字、血条和距离",
    Locked = false,
    Callback = function(state)
        if state then
            -- 启用敌人显示
            enableEnemyDisplay()
        else
            -- 禁用敌人显示
            disableEnemyDisplay()
        end
    end
})

-- 存储敌人信息的表
local enemyData = {}
local connections = {}

-- 获取本地玩家
local localPlayer = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera

-- 创建绘制对象
function createBillboard(enemy)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EnemyDisplay"
    billboard.Adornee = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head") or enemy.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100
    billboard.Parent = enemy
    
    -- 名字标签
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = enemy.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    -- 血条背景
    local healthBarBackground = Instance.new("Frame")
    healthBarBackground.Name = "HealthBarBackground"
    healthBarBackground.Size = UDim2.new(1, 0, 0, 10)
    healthBarBackground.Position = UDim2.new(0, 0, 0, 25)
    healthBarBackground.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    healthBarBackground.BorderSizePixel = 1
    healthBarBackground.BorderColor3 = Color3.new(0, 0, 0)
    healthBarBackground.Parent = billboard
    
    -- 血条前景
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBackground
    
    -- 距离标签
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, 40)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "距离: 0"
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = billboard
    
    return billboard
end

-- 更新敌人显示
function updateEnemyDisplay()
    for enemy, data in pairs(enemyData) do
        if enemy and enemy.Parent then
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            local rootPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head") or enemy.PrimaryPart
            
            if humanoid and rootPart and data.billboard then
                -- 更新血条
                local healthBar = data.billboard:FindFirstChild("HealthBarBackground"):FindFirstChild("HealthBar")
                if healthBar then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                    
                    -- 根据血量改变颜色
                    if healthPercent > 0.5 then
                        healthBar.BackgroundColor3 = Color3.new(1 - (healthPercent - 0.5) * 2, 1, 0)
                    else
                        healthBar.BackgroundColor3 = Color3.new(1, healthPercent * 2, 0)
                    end
                end
                
                -- 更新距离
                local distanceLabel = data.billboard:FindFirstChild("DistanceLabel")
                if distanceLabel and localPlayer.Character then
                    local playerRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if playerRoot then
                        local distance = (rootPart.Position - playerRoot.Position).Magnitude
                        distanceLabel.Text = "距离: " .. math.floor(distance) .. " 米"
                    end
                end
            end
        else
            -- 敌人已不存在，清理数据
            if data.billboard then
                data.billboard:Destroy()
            end
            enemyData[enemy] = nil
        end
    end
end

-- 检查是否为敌人
function isEnemy(character)
    -- 这里根据你的游戏逻辑来判断是否为敌人
    -- 示例：检查是否不是玩家角色且包含Humanoid
    if character:FindFirstChildOfClass("Humanoid") and not game:GetService("Players"):GetPlayerFromCharacter(character) then
        return true
    end
    return false
end

-- 添加敌人到显示列表
function addEnemy(enemy)
    if not enemyData[enemy] and isEnemy(enemy) then
        local billboard = createBillboard(enemy)
        enemyData[enemy] = {
            billboard = billboard,
            connection = enemy.AncestryChanged:Connect(function()
                if not enemy.Parent then
                    removeEnemy(enemy)
                end
            end)
        }
    end
end

-- 从显示列表移除敌人
function removeEnemy(enemy)
    if enemyData[enemy] then
        if enemyData[enemy].billboard then
            enemyData[enemy].billboard:Destroy()
        end
        if enemyData[enemy].connection then
            enemyData[enemy].connection:Disconnect()
        end
        enemyData[enemy] = nil
    end
end

-- 启用敌人显示
function enableEnemyDisplay()
    -- 清空现有数据
    disableEnemyDisplay()
    
    -- 查找现有敌人
    for _, enemy in pairs(workspace.Mobs:GetChildren()) do
        addEnemy(enemy)
    end
    
    -- 监听新敌人出现
    connections.mobAdded = workspace.Mobs.ChildAdded:Connect(function(child)
        addEnemy(child)
    end)
    
    -- 监听敌人移除
    connections.mobRemoved = workspace.Mobs.ChildRemoved:function(child)
        removeEnemy(child)
    end
    
    -- 创建更新循环
    connections.updateLoop = game:GetService("RunService").RenderStepped:Connect(updateEnemyDisplay)
end

-- 禁用敌人显示
function disableEnemyDisplay()
    -- 断开所有连接
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
    
    -- 清除所有敌人显示
    for enemy, data in pairs(enemyData) do
        if data.billboard then
            data.billboard:Destroy()
        end
        if data.connection then
            data.connection:Disconnect()
        end
    end
    enemyData = {}
end