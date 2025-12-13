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
	thunderText.Text = "通缉"
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
        
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()

local Window = WindUI:CreateWindow({
        Title = "Sxingz Hub|通缉",
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
    Title = "打开Sxingz|通缉",
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
    Title = "通用",
    Icon = "bolt",
    Locked = false,
})

local Slider = Tab:Slider({
    Title = "移动速度",
    
    Step = 1,
    
    Value = {
        Min = 0,
        Max = 320,
        Default = 16,
    },
    Callback = function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

local Slider = Tab:Slider({
    Title = "跳跃高度",
    
    Step = 1,
    
    Value = {
        Min = 50,
        Max = 1000,
        Default = 50,
    },
    Callback = function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

local Slider = Tab:Slider({
    Title = "重力",
    
    Step = 1,
    
    Value = {
        Min = 0,
        Max = 1000,
        Default = 196,
    },
    Callback = function(value)
    game.Workspace.Gravity = value
    end
})

local Button = Tab:Button({
    Title = "无限跳",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
    end
})

local Button = Tab:Button({
    Title = "飞行V3",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CNHM/asg/refs/heads/main/fly.lua"))()
    end
})

local Tab = Window:Tab({
    Title = "赚钱功能",
    Icon = "server",
    Locked = false,
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local running = false
local loopConn

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local Toggle = Tab:Toggle({
    Title = "自动抢夺ATM机",
    Desc = "附近要有ATM机",
    Locked = false,
    Callback = function(state)
        running = state

        if loopConn then
            loopConn:Disconnect()
            loopConn = nil
        end
        if not running then return end

        loopConn = RunService.Heartbeat:Connect(function()
            if not running then return end

            local atm = workspace:FindFirstChild("Local")
                and workspace.Local:FindFirstChild("Gizmos")
                and workspace.Local.Gizmos:FindFirstChild("White")
                and workspace.Local.Gizmos.White:FindFirstChild("ATM")

            local hrp = getHRP()
            if not (atm and hrp) then return end

            local cf
            if atm:IsA("BasePart") then
                cf = atm.CFrame
            else
                local part = atm:FindFirstChildWhichIsA("BasePart", true)
                if part then cf = part.CFrame end
            end
            if not cf then return end

            hrp.CFrame = cf
            task.wait(1)

            pressE()
        end)
    end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local running = false
local loopConn

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local Toggle = Tab:Toggle({
    Title = "自动抢夺印钞机",
    Desc = "附近要有印钞机",
    Locked = false,
    Callback = function(state)
        running = state

        if loopConn then
            loopConn:Disconnect()
            loopConn = nil
        end
        if not running then return end

        loopConn = RunService.Heartbeat:Connect(function()
            if not running then return end

            local register = workspace:FindFirstChild("Local")
                and workspace.Local:FindFirstChild("Gizmos")
                and workspace.Local.Gizmos:FindFirstChild("White")
                and workspace.Local.Gizmos.White:FindFirstChild("Register")

            local hrp = getHRP()
            if not (register and hrp) then return end

            local cf
            if register:IsA("BasePart") then
                cf = register.CFrame
            else
                local part = register:FindFirstChildWhichIsA("BasePart", true)
                if part then cf = part.CFrame end
            end
            if not cf then return end

            hrp.CFrame = cf
            task.wait(1)
            pressE()
        end)
    end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local running = false
local loopConn

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local Toggle = Tab:Toggle({
    Title = "自动拾取掉落现金",
    Desc = "",
    Locked = false,
    Callback = function(state)
        running = state

        if loopConn then
            loopConn:Disconnect()
            loopConn = nil
        end
        if not running then return end

        loopConn = RunService.Heartbeat:Connect(function()
            if not running then return end

            local cash = workspace:FindFirstChild("Local")
                and workspace.Local:FindFirstChild("Gizmos")
                and workspace.Local.Gizmos:FindFirstChild("Green")
                and workspace.Local.Gizmos.Green:FindFirstChild("CashBundle")

            local hrp = getHRP()
            if not (cash and hrp) then return end

            local cf
            if cash:IsA("BasePart") then
                cf = cash.CFrame
            else
                local part = cash:FindFirstChildWhichIsA("BasePart", true)
                if part then cf = part.CFrame end
            end
            if not cf then return end

            hrp.CFrame = cf
            pressE()
        end)
    end
})

local Tab = Window:Tab({
    Title = "绘制功能",
    Icon = "server",
    Locked = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local espEnabled = false
local conns = {}
local guisByPlayer = {}

local function disconnectAll()
	for _, c in ipairs(conns) do
		if c and c.Disconnect then c:Disconnect() end
	end
	table.clear(conns)
end

local function removeGui(plr)
	local gui = guisByPlayer[plr]
	if gui then
		gui:Destroy()
		guisByPlayer[plr] = nil
	end
end

local function makeGui(plr, character)
	if plr == Players.LocalPlayer then return end
	if not character then return end

	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not head or not humanoid then return end

	removeGui(plr)

	local bb = Instance.new("BillboardGui")
	bb.Name = "NameHpESP"
	bb.AlwaysOnTop = true
	bb.Size = UDim2.fromOffset(200, 50)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
	bb.MaxDistance = 250
	bb.Parent = head

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextStrokeTransparency = 0.2
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Parent = bb

	guisByPlayer[plr] = bb

	local function update()
		if not espEnabled then return end
		if humanoid.Parent == nil or head.Parent == nil then return end

		local hp = math.max(0, math.floor(humanoid.Health + 0.5))
		local maxhp = math.max(1, math.floor(humanoid.MaxHealth + 0.5))
		label.Text = string.format("%s  [%d/%d]", plr.Name, hp, maxhp)

		local ratio = humanoid.Health / math.max(1, humanoid.MaxHealth)
		label.TextColor3 = Color3.fromRGB(255, math.floor(255 * ratio), math.floor(255 * ratio))
	end

	update()
	table.insert(conns, humanoid.HealthChanged:Connect(update))
	table.insert(conns, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update))
end

local function hookPlayer(plr)
	table.insert(conns, plr.CharacterAdded:Connect(function(char)
		if espEnabled then
			task.wait(0.2)
			makeGui(plr, char)
		end
	end))

	if plr.Character and espEnabled then
		makeGui(plr, plr.Character)
	end
end

local function enableESP()
	espEnabled = true
	disconnectAll()

	for _, plr in ipairs(Players:GetPlayers()) do
		hookPlayer(plr)
	end

	table.insert(conns, Players.PlayerAdded:Connect(function(plr)
		if espEnabled then
			hookPlayer(plr)
		end
	end))

	table.insert(conns, Players.PlayerRemoving:Connect(function(plr)
		removeGui(plr)
	end))
end

local function disableESP()
	espEnabled = false
	disconnectAll()
	for plr, _ in pairs(guisByPlayer) do
		removeGui(plr)
	end
	table.clear(guisByPlayer)
end

local Toggle = Tab:Toggle({
	Title = "绘制玩家",
	Desc = "",
	Locked = false,
	Callback = function(state)
		if state then
			enableESP()
		else
			disableESP()
		end
	end
})

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local atmEspEnabled = false
local atmEspConn = nil
local created = {}

local function getAdornee(atm)
    if not atm or not atm.Parent then return nil end
    if atm:IsA("BasePart") then return atm end
    local p = atm:FindFirstChildWhichIsA("BasePart", true)
    return p
end

local function addATM(atm)
    if created[atm] then return end
    local part = getAdornee(atm)
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ATM_ESP"
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(200, 50)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.Text = "ATM"
    label.Parent = bb

    created[atm] = bb
end

local function removeAll()
    for atm, bb in pairs(created) do
        if bb and bb.Parent then bb:Destroy() end
        created[atm] = nil
    end
end

local function scanAll()
    local root = workspace:FindFirstChild("Local")
    root = root and root:FindFirstChild("Gizmos")
    root = root and root:FindFirstChild("White")
    if not root then return end

    for _, inst in ipairs(root:GetDescendants()) do
        if inst.Name == "ATM" then
            addATM(inst)
        end
    end
end

local Toggle = Tab:Toggle({
    Title = "绘制ATM机",
    Desc = "",
    Locked = false,
    Callback = function(state)
        atmEspEnabled = state

        if atmEspEnabled then
            scanAll()
            local root = workspace:FindFirstChild("Local")
            root = root and root:FindFirstChild("Gizmos")
            root = root and root:FindFirstChild("White")
            if root then
                atmEspConn = root.DescendantAdded:Connect(function(inst)
                    if not atmEspEnabled then return end
                    if inst.Name == "ATM" then
                        task.defer(addATM, inst)
                    end
                end)
            end
        else
            if atmEspConn then atmEspConn:Disconnect() atmEspConn = nil end
            removeAll()
        end
    end
})

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local regEspEnabled = false
local regEspConn = nil
local created = {}

local function getAdornee(modelOrPart)
    if not modelOrPart or not modelOrPart.Parent then return nil end
    if modelOrPart:IsA("BasePart") then return modelOrPart end
    return modelOrPart:FindFirstChildWhichIsA("BasePart", true)
end

local function addRegister(reg)
    if created[reg] then return end
    local part = getAdornee(reg)
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "REGISTER_ESP"
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(220, 55)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.Text = "印钞机"
    label.Parent = bb

    created[reg] = bb
end

local function removeAll()
    for reg, bb in pairs(created) do
        if bb and bb.Parent then bb:Destroy() end
        created[reg] = nil
    end
end

local function scanAll()
    local root = workspace:FindFirstChild("Local")
    root = root and root:FindFirstChild("Gizmos")
    root = root and root:FindFirstChild("White")
    root = root and root:FindFirstChild("Register")
    if not root then return end

    addRegister(root)
    for _, inst in ipairs(root:GetDescendants()) do
        if inst:IsA("Model") or inst:IsA("BasePart") then
            addRegister(inst)
        end
    end
end

local Toggle = Tab:Toggle({
    Title = "绘制印钞机",
    Desc = "",
    Locked = false,
    Callback = function(state)
        regEspEnabled = state

        if regEspEnabled then
            scanAll()

            local root = workspace:FindFirstChild("Local")
            root = root and root:FindFirstChild("Gizmos")
            root = root and root:FindFirstChild("White")
            root = root and root:FindFirstChild("Register")

            if root then
                regEspConn = root.DescendantAdded:Connect(function(inst)
                    if not regEspEnabled then return end
                    if inst:IsA("Model") or inst:IsA("BasePart") then
                        task.defer(addRegister, inst)
                    end
                end)
            end
        else
            if regEspConn then regEspConn:Disconnect() regEspConn = nil end
            removeAll()
        end
    end
})

local Tab = Window:Tab({
    Title = "出售功能",
    Icon = "server",
    Locked = false,
})

local running = false

local Toggle = Tab:Toggle({
    Title = "自动出售",
    Desc = "",
    Locked = false,
    Callback = function(state)
        running = state
        if not running then return end

        task.spawn(function()
            while running do
                pcall(function()
                    game:GetService("ReplicatedStorage").Shared.Core.Network
                        :FindFirstChild("2YdK2c9A"):InvokeServer()
                end)
                task.wait(0.1)
            end
        end)
    end
})

local Button = Tab:Button({
    Title = "手动出售",
    Desc = "",
    Locked = false,
    Callback = function()
    game:GetService("ReplicatedStorage").Shared.Core.Network:FindFirstChild("2YdK2c9A"):InvokeServer()
    end
})