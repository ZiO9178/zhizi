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
	thunderText.Text = "暴力区"
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
        Title = "Sxingz Hub|暴力区",
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
    Title = "打开Sxingz|暴力区",
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
    Title = "透视",
    Icon = "server",
    Locked = false,
})

local Hook = {
    Players = {
        ["Killer"] = {Color = Color3.fromRGB(255, 0, 0), On = true},
        ["Survivor"] = {Color = Color3.fromRGB(0, 255, 0), On = true}
    },
    Objects = {
        ["Generator"] = {Color = Color3.fromRGB(203, 132, 66), On = true},
        ["Gate"] = {Color = Color3.fromRGB(255, 255, 255), On = true},
        ["Pallet"] = {Color = Color3.fromRGB(255, 255, 0), On = true},
        ["Window"] = {Color = Color3.fromRGB(255, 255, 255), On = true},
        ["Hook"] = {Color = Color3.fromRGB(255, 0, 0), On = true},
        ["Pumpkin"] = {Color = Color3.fromRGB(255, 140, 0), On = true}
    }
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function ESP(obj, color)
    if not obj or obj:FindFirstChild("H") then return end
    local h = Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = obj
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0
    h.Parent = obj
end

local function RemoveESP(obj)
    if not obj then return end
    local h = obj:FindFirstChild("H")
    if h then h:Destroy() end
end

local Toggle = Tab:Toggle({
    Title = "透视杀手",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Players["Killer"].On = state

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Team and p.Team.Name == "Killer" then
                state and ESP(p.Character, Hook.Players["Killer"].Color) or RemoveESP(p.Character)
            end
        end

        Players.PlayerAdded:Connect(function(newP)
            newP.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                if newP ~= localPlayer and newP.Team and newP.Team.Name == "Killer" and Hook.Players["Killer"].On then
                    ESP(char, Hook.Players["Killer"].Color)
                end
            end)
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视幸存者",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Players["Survivor"].On = state

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Team and p.Team.Name == "Survivors" then
                state and ESP(p.Character, Hook.Players["Survivor"].Color) or RemoveESP(p.Character)
            end
        end

        Players.PlayerAdded:Connect(function(newP)
            newP.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                if newP ~= localPlayer and newP.Team and newP.Team.Name == "Survivors" and Hook.Players["Survivor"].On then
                    ESP(char, Hook.Players["Survivor"].Color)
                end
            end)
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视发电机",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Objects["Generator"].On = state
        local targetFolder = Workspace.Map

        for _, obj in ipairs(targetFolder:GetDescendants()) do
            if obj.Name == "Generator" then
                state and ESP(obj, Hook.Objects["Generator"].Color) or RemoveESP(obj)
            end
        end

        targetFolder.DescendantAdded:Connect(function(newObj)
            task.wait(0.05)
            if newObj.Name == "Generator" and Hook.Objects["Generator"].On then
                ESP(newObj, Hook.Objects["Generator"].Color)
            end
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视大门",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Objects["Gate"].On = state
        local targetFolder = Workspace.Map

        for _, obj in ipairs(targetFolder:GetDescendants()) do
            if obj.Name == "Gate" then
                state and ESP(obj, Hook.Objects["Gate"].Color) or RemoveESP(obj)
            end
        end

        targetFolder.DescendantAdded:Connect(function(newObj)
            task.wait(0.05)
            if newObj.Name == "Gate" and Hook.Objects["Gate"].On then
                ESP(newObj, Hook.Objects["Gate"].Color)
            end
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视木板",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Objects["Pallet"].On = state
        local targetFolder = Workspace.Map
        local objName = "Palletwrong"

        for _, obj in ipairs(targetFolder:GetDescendants()) do
            if obj.Name == objName then
                state and ESP(obj, Hook.Objects["Pallet"].Color) or RemoveESP(obj)
            end
        end

        targetFolder.DescendantAdded:Connect(function(newObj)
            task.wait(0.05)
            if newObj.Name == objName and Hook.Objects["Pallet"].On then
                ESP(newObj, Hook.Objects["Pallet"].Color)
            end
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视窗户",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Objects["Window"].On = state
        local targetFolder = Workspace

        for _, obj in ipairs(targetFolder:GetDescendants()) do
            if obj.Name == "Window" then
                state and ESP(obj, Hook.Objects["Window"].Color) or RemoveESP(obj)
            end
        end

        targetFolder.DescendantAdded:Connect(function(newObj)
            task.wait(0.05)
            if newObj.Name == "Window" and Hook.Objects["Window"].On then
                ESP(newObj, Hook.Objects["Window"].Color)
            end
        end)
    end
})

local Toggle = Tab:Toggle({
    Title = "透视钩子",
    Desc = "",
    Locked = false,
    Callback = function(state)
        Hook.Objects["Hook"].On = state
        local targetFolder = Workspace.Map

        local function UpdateHooks()
            for _, obj in ipairs(targetFolder:GetDescendants()) do
                if obj.Name == "Hook" then
                    if obj:FindFirstChild("Model") then
                        for _, part in ipairs(obj.Model:GetDescendants()) do
                            if part:IsA("MeshPart") then
                                state and ESP(part, Hook.Objects["Hook"].Color) or RemoveESP(part)
                            end
                        end
                    end
                    local bloodPuddle = obj:FindFirstChild("Cartoony Blood Puddle")
                    if bloodPuddle then
                        state and ESP(bloodPuddle, Hook.Objects["Hook"].Color) or RemoveESP(bloodPuddle)
                    end
                end
            end
        end

        UpdateHooks()

        targetFolder.DescendantAdded:Connect(function(newObj)
            task.wait(0.05)
            if newObj.Name == "Hook" and Hook.Objects["Hook"].On then
                UpdateHooks()
            end
        end)
    end
})