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
	thunderText.Text = "挖出后院"
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
        Title = "Z脚本|挖出后院",
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
    Title = "   打开Z脚本丨挖出后院",
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
    Title = "耐力",
    Icon = "warehouse",
    Locked = false,
})

local Button = Tab:Button({
    Title = "铲子无限耐力",
    Desc = "",
    Locked = false,
    Callback = function()
    local remote = game:GetService("ReplicatedStorage").ReplicaRemoteEvents.Replica_ReplicaSignal

local mt = getrawmetatable(remote) or {}
local old = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    if self == remote and getnamecallmethod() == "FireServer" then
        local args = {...}
        if args[1] == 1345 and args[2] == "PromptMine" then
            print("阻止了 PromptMine 远程事件")
            return nil
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)
    end
})

local Tab = Window:Tab({
    Title = "出售",
    Icon = "warehouse",
    Locked = false,
})

local Button = Tab:Button({
    Title = "点击出售",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "SellOres"
}

game:GetService("ReplicatedStorage").Framework.Features.MiningSystem.MineUtil.RemoteEvent:FireServer(unpack(args))
    end
})

local Tab = Window:Tab({
    Title = "升级",
    Icon = "warehouse",
    Locked = false,
})

local Button = Tab:Button({
    Title = "铲子",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "BuyUpgrade",
    [2] = "Shovel"
}

game:GetService("ReplicatedStorage").Framework.Features.MiningSystem.UpgradeUtil.RemoteEvent:FireServer(unpack(args))
    end
})

local Button = Tab:Button({
    Title = "背包",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "BuyUpgrade",
    [2] = "Backpack"
}

game:GetService("ReplicatedStorage").Framework.Features.MiningSystem.UpgradeUtil.RemoteEvent:FireServer(unpack(args))
    end
})

local Button = Tab:Button({
    Title = "能量",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "BuyUpgrade",
    [2] = "Energy"
}

game:GetService("ReplicatedStorage").Framework.Features.MiningSystem.UpgradeUtil.RemoteEvent:FireServer(unpack(args))
    end
})

local Button = Tab:Button({
    Title = "喷气背包",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "BuyUpgrade",
    [2] = "Jetpack"
}

game:GetService("ReplicatedStorage").Framework.Features.MiningSystem.UpgradeUtil.RemoteEvent:FireServer(unpack(args))
    end
})

local Tab = Window:Tab({
    Title = "透视",
    Icon = "warehouse",
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "透视所有矿石",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")

            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            oreHighlights = {}
            oreLabels = {}

            local function createOreLabel(ore)
                if oreLabels[ore] then return end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "OreLabel"
                billboard.Adornee = ore
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 0
                billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "Label"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = ore.Name
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                
                textLabel.Parent = billboard
                billboard.Parent = ore
                
                oreLabels[ore] = billboard
                
                local highlight = Instance.new("Highlight")
                highlight.Name = "OreHighlight"
                highlight.Adornee = ore
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                
                if ore.Name:find("Iron") or ore.Name:find("铁") then
                    highlight.FillColor = Color3.fromRGB(169, 169, 169)
                    highlight.OutlineColor = Color3.fromRGB(211, 211, 211)
                elseif ore.Name:find("Gold") or ore.Name:find("金") then
                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                elseif ore.Name:find("Diamond") or ore.Name:find("钻石") then
                    highlight.FillColor = Color3.fromRGB(185, 242, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 191, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                end
                
                highlight.Parent = ore
                oreHighlights[ore] = highlight
            end

            local function removeOreLabel(ore)
                if oreLabels[ore] then
                    oreLabels[ore]:Destroy()
                    oreLabels[ore] = nil
                end
                if oreHighlights[ore] then
                    oreHighlights[ore]:Destroy()
                    oreHighlights[ore] = nil
                end
            end

            for _, ore in pairs(workspace.SpawnedOres:GetChildren()) do
                createOreLabel(ore)
            end

            oreAddedConn = workspace.SpawnedOres.ChildAdded:Connect(function(ore)
                createOreLabel(ore)
            end)

            oreRemovedConn = workspace.SpawnedOres.ChildRemoved:Connect(function(ore)
                removeOreLabel(ore)
            end)

            local function updateLabels()
                for ore, label in pairs(oreLabels) do
                    if ore:IsA("BasePart") and label then
                        local distance = (humanoidRootPart.Position - ore.Position).Magnitude
                        local scale = math.clamp(50 / distance, 0.5, 2)
                        label.Size = UDim2.new(0, 200 * scale, 0, 50 * scale)
                        
                        local transparency = math.clamp((distance - 50) / 100, 0, 0.7)
                        label.Label.TextTransparency = transparency
                        if oreHighlights[ore] then
                            oreHighlights[ore].FillTransparency = 0.7 + transparency * 0.3
                        end
                    end
                end
            end
            heartbeatConn = RunService.Heartbeat:Connect(updateLabels)
            characterAddedConn = player.CharacterAdded:Connect(function(newChar)
                character = newChar
                humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
            end)
        else
            if oreAddedConn then oreAddedConn:Disconnect() end
            if oreRemovedConn then oreRemovedConn:Disconnect() end
            if heartbeatConn then heartbeatConn:Disconnect() end
            if characterAddedConn then characterAddedConn:Disconnect() end
            
            for ore, label in pairs(oreLabels) do
                if label and label.Parent then
                    label:Destroy()
                end
            end
            for ore, highlight in pairs(oreHighlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            
            oreLabels = {}
            oreHighlights = {}
        end
    end
})