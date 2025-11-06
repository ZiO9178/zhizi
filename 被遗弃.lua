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
	thunderText.Text = "被遗弃"
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
        Title = "Sxingz Hub|被遗弃",
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
    Title = "打开Sxingz|被遗弃",
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
    Title = "透视功能",
    Icon = "warehouse",
    Locked = false,
})

local highlights = {}
local nameTags = {}
local healthBars = {}

local Toggle = Tab:Toggle({
    Title = "透视杀手",
    Desc = "显示敌人信息",
    Locked = false,
    Callback = function(state)
        if state then
            -- 创建玩家信息UI
            for _, killer in pairs(workspace.Players.Killers:GetChildren()) do
                local player = killer.Parent -- 假设killer是Player的子对象
                
                -- 创建名字标签
                local nameTag = Instance.new("TextLabel")
                nameTag.Text = player.Name
                nameTag.Size = 20
                nameTag.Position = UDim2.new(0, 0, 0, -30) -- 附加到头顶
                nameTag.Parent = player.PlayerGui
                nameTags[player] = nameTag
                
                -- 创建血条
                local healthBar = Instance.new("ImageLabel")
                healthBar.Image = "http://www.roblox.com/asset/?id=4934349617" -- 血条图片
                healthBar.Size = UDim2.new(0, 100, 0, 10)
                healthBar.Position = UDim2.new(0, 0, 0, -20) -- 附加到名字标签下方
                healthBar.Parent = player.PlayerGui
                healthBars[player] = healthBar
                
                -- 创建高亮效果
                local highlight = Instance.new("Highlight")
                highlight.Parent = killer
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlights[killer] = highlight
                
                -- 初始化血条
                local maxHealth = player.Character.Humanoid.MaxHealth
                local health = player.Character.Humanoid.Health
                healthBar.ImageTransparency = 1 - (health / maxHealth)
            end
        else
            -- 销毁所有UI元素
            for player, nameTag in pairs(nameTags) do
                nameTag:Destroy()
                nameTags[player] = nil
            end
            
            for player, healthBar in pairs(healthBars) do
                healthBar:Destroy()
                healthBars[player] = nil
            end
            
            for killer, highlight in pairs(highlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            
            highlights = {}
            nameTags = {}
            healthBars = {}
        end
    end
})

-- 实时更新血条
game:GetService("RunService").RenderStepped:Connect(function()
    if Toggle.State then
        for player, healthBar in pairs(healthBars) do
            local health = player.Character.Humanoid.Health
            local maxHealth = player.Character.Humanoid.MaxHealth
            healthBar.ImageTransparency = 1 - (health / maxHealth)
        end
    end
end)

local survivorHighlights = {} 

local SurvivorToggle = Tab:Toggle({
    Title = "透视幸存者",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            for _, survivor in pairs(workspace.Players.Survivors:GetChildren()) do
                local highlight = Instance.new("Highlight")
                highlight.Parent = survivor
                highlight.FillColor = Color3.fromRGB(0, 255, 0) 
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.3 
                survivorHighlights[survivor] = highlight 
            end
        else
            for survivor, highlight in pairs(survivorHighlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy() 
                end
            end
            survivorHighlights = {} 
        end      
    end
})

local generatorHighlights = {} 

local GeneratorToggle = Tab:Toggle({
    Title = "透视发电机",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            local function highlightGenerators()
                for _, generator in pairs(workspace.Map.Ingame.Map:GetChildren()) do
                    if generator.Name == "Generator" and not generatorHighlights[generator] then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = generator
                        highlight.FillColor = Color3.fromRGB(0, 200, 255) 
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.FillTransparency = 0.5
                        generatorHighlights[generator] = highlight 
                    end
                end
            end
            
            highlightGenerators()
            
            if not generatorChildAddedConnection then
                generatorChildAddedConnection = workspace.Map.Ingame.Map.ChildAdded:Connect(function(child)
                    if child.Name == "Generator" then
                        task.wait(0.5) 
                        if GeneratorToggle.Value then 
                            local highlight = Instance.new("Highlight")
                            highlight.Parent = child
                            highlight.FillColor = Color3.fromRGB(0, 200, 255)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                            highlight.FillTransparency = 0.5
                            generatorHighlights[child] = highlight
                        end
                    end
                end)
            end
        else
            for generator, highlight in pairs(generatorHighlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            generatorHighlights = {} 
            
            if generatorChildAddedConnection then
                generatorChildAddedConnection:Disconnect()
                generatorChildAddedConnection = nil
            end
        end      
    end
})

local Tab = Window:Tab({
    Title = "耐力功能",
    Icon = "warehouse",
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "无限耐力",
    Desc = "",
    Locked = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        local function waitFor(child, name, timeout)
            return child:WaitForChild(name, timeout or 10)
        end

        local success, err = pcall(function()
            if not Toggle.originalValues then
                local speedMultFolder = waitFor(character, "SpeedMultipliers")
                local fovMultFolder = waitFor(character, "FOVMultipliers")
                
                local speedValue = speedMultFolder:FindFirstChild("Sprinting")
                local fovValue = fovMultFolder:FindFirstChild("Sprinting")
                
                Toggle.originalValues = {
                    StaminaLoss = nil,
                    StaminaLossDisabled = nil,
                    SprintSpeed = speedValue and speedValue.Value,
                    SprintFOV = fovValue and fovValue.Value
                }
            end

            if state then
                for _, module in pairs(getgc(true)) do
                    if typeof(module) == "table" then
                        if rawget(module, "StaminaLoss") then
                            Toggle.originalValues.StaminaLoss = module.StaminaLoss
                            module.StaminaLoss = 0
                            print("[✓] Patched StaminaLoss to 0")
                        end
                        if rawget(module, "StaminaLossDisabled") then
                            Toggle.originalValues.StaminaLossDisabled = module.StaminaLossDisabled
                            module.StaminaLossDisabled = true
                            print("[✓] Disabled StaminaLoss")
                        end
                    end
                end
            else
                for _, module in pairs(getgc(true)) do
                    if typeof(module) == "table" then
                        if rawget(module, "StaminaLoss") and Toggle.originalValues.StaminaLoss ~= nil then
                            module.StaminaLoss = Toggle.originalValues.StaminaLoss
                            print("[✓] Restored StaminaLoss to original value")
                        end
                        if rawget(module, "StaminaLossDisabled") and Toggle.originalValues.StaminaLossDisabled ~= nil then
                            module.StaminaLossDisabled = Toggle.originalValues.StaminaLossDisabled
                            print("[✓] Restored StaminaLossDisabled")
                        end
                    end
                end
                
                if Toggle.originalValues.SprintSpeed then
                    local speedMultFolder = waitFor(character, "SpeedMultipliers")
                    local speedValue = speedMultFolder:FindFirstChild("Sprinting")
                    if speedValue then
                        speedValue.Value = Toggle.originalValues.SprintSpeed
                    end
                end
                
                if Toggle.originalValues.SprintFOV then
                    local fovMultFolder = waitFor(character, "FOVMultipliers")
                    local fovValue = fovMultFolder:FindFirstChild("Sprinting")
                    if fovValue then
                        fovValue.Value = Toggle.originalValues.SprintFOV
                    end
                end
            end
        end)

        if not success then
            warn("[!] Failed to patch stamina:", err)
        else
            print(state and "[✓] Stamina patch executed successfully" or "[✓] Stamina patch disabled")
        end     
    end
})

local Tab = Window:Tab({
    Title = "修机功能",
    Icon = "server",
    Locked = false,
})

local Toggle = Tab:Toggle({
    Title = "自动修机",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            while state do
                if workspace.Map.Ingame.Map.Generator.Health.Value < 100 then
                    workspace.Map.Ingame.Map.Generator.Remotes.RE:FireServer("Repair")
                    
                    
                    wait(5)
                else
                    wait(1)
                end
            end
        else
            print("自动修机已关闭")
        end
    end
})