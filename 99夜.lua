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
	thunderText.Text = "森林中的99夜"
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
        Title = "Sxingz Hub|森林中的99夜",
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
    Title = "打开Sxingz|森林中的99夜",
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
    Title = "物品功能",
    Icon = "server",
    Locked = false,
})

local Button = Tab:Button({
    Title = "传送全部物品",
    Desc = "",
    Locked = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        local itemsFolder = workspace:FindFirstChild("Items")
        if not itemsFolder then
            warn("[警告] 未找到 workspace.Items 文件夹")
            return
        end

        local items = itemsFolder:GetChildren()

        for _, item in ipairs(items) do
            local targetPart = item:IsA("Model") and item.PrimaryPart or item:IsA("BasePart") and item

            if targetPart then
                local originalAnchored = targetPart.Anchored
                local originalCanCollide = targetPart.CanCollide

                targetPart.Anchored = false
                targetPart.CanCollide = false

                targetPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 2, 0)

                delay(1, function()
                    targetPart.Anchored = originalAnchored
                    targetPart.CanCollide = originalCanCollide
                end)

                print("[Log] 已传送物品: " .. item.Name)
            end
        end

        print("[Log] 所有物品传送完成")
    end
})

local Tab = Window:Tab({
    Title = "食物功能",
    Icon = "server",
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "自动升级营火",
    Desc = "自动向营火添加燃料物品",
    Locked = false,
    Callback = function(state)
        -- 自动升级营火配置
        local AutoUpgradeCampfire = {
            Enabled = state,
            DropPosition = Vector3.new(0, 19, 0), -- 营火位置
            CheckInterval = 2, -- 检查间隔
            SelectedItems = {} -- 选中的燃料物品
        }

        -- 燃料物品列表
        local fuelItems = {
            "Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"
        }

        -- 物品名称映射（英文到中文）
        local itemNameMap = {
            ["Log"] = "原木",
            ["Coal"] = "煤炭", 
            ["Fuel Canister"] = "燃料罐",
            ["Oil Barrel"] = "油桶",
            ["Biofuel"] = "生物燃料"
        }

        -- 移动物品到营火位置
        local function moveItemToCampfire(item)
            if not item or not item:IsDescendantOf(workspace) then return end
            
            local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item
            if not part or not part:IsA("BasePart") then return end

            -- 设置主部件（如果是模型）
            if item:IsA("Model") and not item.PrimaryPart then
                pcall(function() item.PrimaryPart = part end)
            end

            -- 移动物品
            pcall(function()
                local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
                remoteEvents.RequestStartDraggingItem:FireServer(item)
                if item:IsA("Model") then
                    item:SetPrimaryPartCFrame(CFrame.new(AutoUpgradeCampfire.DropPosition))
                else
                    part.CFrame = CFrame.new(AutoUpgradeCampfire.DropPosition)
                end
                remoteEvents.StopDraggingItem:FireServer(item)
            end)
        end

        -- 自动升级营火主函数
        local function startAutoUpgrade()
            while AutoUpgradeCampfire.Enabled do
                -- 检查所有选中的燃料物品
                for itemName, enabled in pairs(AutoUpgradeCampfire.SelectedItems) do
                    if not AutoUpgradeCampfire.Enabled then break end
                    
                    if enabled then
                        -- 在场景中查找该物品
                        local itemsFolder = Workspace:FindFirstChild("Items")
                        if itemsFolder then
                            for _, item in ipairs(itemsFolder:GetChildren()) do
                                if not AutoUpgradeCampfire.Enabled then break end
                                
                                if item.Name == itemName then
                                    moveItemToCampfire(item)
                                    task.wait(0.1) -- 物品移动间隔
                                end
                            end
                        end
                    end
                end
                
                task.wait(AutoUpgradeCampfire.CheckInterval) -- 主循环间隔
            end
        end

        -- 根据Toggle状态启动或停止
        if state then
            -- 开启前检查是否有选中的物品
            local hasSelectedItems = false
            for _, enabled in pairs(AutoUpgradeCampfire.SelectedItems) do
                if enabled then
                    hasSelectedItems = true
                    break
                end
            end
            
            if not hasSelectedItems then
                WindUI:Notify({
                    Title = "自动升级营火",
                    Content = "请先选择要使用的燃料物品",
                    Duration = 3
                })
                if Toggle.SetValue then
                    Toggle:SetValue(false)
                end
                return
            end
            
            -- 开启自动升级
            task.spawn(function()
                WindUI:Notify({
                    Title = "自动升级营火",
                    Content = "已开启，正在自动添加燃料",
                    Duration = 2
                })
                startAutoUpgrade()
            end)
        else
            -- 关闭自动升级
            WindUI:Notify({
                Title = "自动升级营火",
                Content = "已关闭",
                Duration = 2
            })
        end
    end
})