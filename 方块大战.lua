if _G.VW_HUB then
	pcall(function() _G.VW_HUB:Destroy() end)
	_G.VW_HUB = nil
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer

local CFG = {
	autoFire = false,
	fireRate = 9,
	fov = 260,
	part = "Head",
	teamCheck = true,
	playersOnly = false,
	predict = true,
	autoReload = false,
	reloadEvery = 2.2,
	gunArg = 0,
	originMode = "Head",
	esp = false,
	espInfo = true,
	fullbright = false,
}

local remoteCache = {}

local function getRemote(path)
	local cached = remoteCache[path]
	if cached and cached.Parent then
		return cached
	end
	local node = RS
	for seg in string.gmatch(path, "[^%.]+") do
		if not node then return nil end
		node = node:FindFirstChild(seg)
	end
	remoteCache[path] = node
	return node
end

local function getChar()
	local c = LP.Character
	if c and c.Parent then return c end
	return nil
end

local function getHRP()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function nowTs()
	local ok, t = pcall(function() return tick() end)
	if ok and type(t) == "number" then return t end
	return os.time()
end

local function myTeamName()
	local t = LP.Team
	return t and t.Name or nil
end

local function modelTeam(model)
	local a = model:GetAttribute("Team") or model:GetAttribute("team")
	if type(a) == "string" then return a end
	for _, d in ipairs(model:GetChildren()) do
		if d:IsA("StringValue") and (d.Name == "Team" or d.Name == "team") then
			return d.Value
		end
	end
	return nil
end

local function isAlly(t)
	if not CFG.teamCheck then return false end
	local my = myTeamName()
	if not my then return false end
	if t.plr then
		local team = t.plr.Team
		return team ~= nil and team.Name == my
	end
	return modelTeam(t.char) == my
end

local targets = {}

local function considerModel(m, out)
	if not m:IsA("Model") then return end
	if m == getChar() then return end
	local hum = m:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local plr = Players:GetPlayerFromCharacter(m)
	if plr == LP then return end
	if plr == nil and CFG.playersOnly then return end
	out[#out + 1] = { char = m, hum = hum, plr = plr }
end

local function scanTargets()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local c = p.Character
			if c then considerModel(c, out) end
		end
	end
	if not CFG.playersOnly then
		for _, d in ipairs(workspace:GetChildren()) do
			considerModel(d, out)
			if d:IsA("Model") then
				for _, c in ipairs(d:GetChildren()) do
					if c:IsA("Model") then considerModel(c, out) end
				end
			end
		end
	end
	local seen, final = {}, {}
	for _, t in ipairs(out) do
		if not seen[t.char] then
			seen[t.char] = true
			if not isAlly(t) then
				final[#final + 1] = t
			end
		end
	end
	targets = final
end

task.spawn(function()
	while true do
		pcall(scanTargets)
		task.wait(0.25)
	end
end)

local function targetPartOf(t)
	local p = t.char:FindFirstChild(CFG.part)
	if not p then p = t.char:FindFirstChild("Head") end
	if not p then p = t.char:FindFirstChild("HumanoidRootPart") end
	return p
end

local function predictPos(t, part)
	local pos = part.Position
	if not CFG.predict then return pos end
	local ping = 0
	pcall(function() ping = LP:GetNetworkPing() end)
	local vel = part.AssemblyLinearVelocity
	if vel and vel.Magnitude > 0.5 then
		pos = pos + vel * (ping * 0.5)
	end
	return pos
end

local function bestTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local vp = cam.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local best, bestScore = nil, math.huge
	local global = CFG.fov >= 900

	for _, t in ipairs(targets) do
		local part = targetPartOf(t)
		if part and part.Parent then
			local pos = predictPos(t, part)
			local sp, onScreen = cam:WorldToViewportPoint(pos)
			local score
			if onScreen then
				local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
				if sd <= CFG.fov then score = sd end
			elseif global then
				score = (pos - cam.CFrame.Position).Magnitude * 10
			end
			if score and score < bestScore then
				bestScore = score
				best = { t = t, pos = pos }
			end
		end
	end
	return best
end

local shotsFired = 0

local function fireAt(pos)
	local ev = getRemote("Voxel.Remotes.FireRifle")
	if not ev then return false end
	local char = getChar()
	local hrp = getHRP()
	local cam = workspace.CurrentCamera
	if not hrp or not cam then return false end

	local origin
	if CFG.originMode == "Camera" then
		origin = cam.CFrame.Position
	elseif CFG.originMode == "Head" and char then
		local head = char:FindFirstChild("Head")
		origin = head and head.Position or (hrp.Position + Vector3.new(0, 1.5, 0))
	else
		origin = hrp.Position + Vector3.new(0, 1.5, 0)
	end

	local delta = pos - origin
	if delta.Magnitude < 0.05 then return false end
	local dir = delta.Unit
	local ts = nowTs()

	local ok = pcall(function()
		ev:FireServer(origin, dir, ts, dir, CFG.gunArg)
	end)
	if ok then shotsFired = shotsFired + 1 end
	return ok
end

task.spawn(function()
	local nextFire = 0
	local nextReload = 0
	while true do
		task.wait(0.01)
		local ok = pcall(function()
			local clock = os.clock()
			if CFG.autoFire then
				local t = bestTarget()
				if t then
					local rate = math.clamp(CFG.fireRate, 1, 40)
					if clock >= nextFire then
						nextFire = clock + (1 / rate)
						if not fireAt(t.pos) then
							nextFire = clock + 0.5
						end
					end
				end
			end
			if CFG.autoReload and clock >= nextReload then
				nextReload = clock + math.max(0.5, CFG.reloadEvery)
				local ev = getRemote("Voxel.Remotes.ReloadRifle")
				if ev then pcall(function() ev:FireServer() end) end
			end
		end)
		if not ok then task.wait(0.2) end
	end
end)

local espStore = {}

local function destroyESP(char)
	local d = espStore[char]
	if d then
		pcall(function()
			if d.hl then d.hl:Destroy() end
			if d.bb then d.bb:Destroy() end
		end)
		espStore[char] = nil
	end
end

local function buildESP(char)
	local hl = Instance.new("Highlight")
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillColor = Color3.fromRGB(255, 60, 60)
	hl.FillTransparency = 0.55
	hl.OutlineColor = Color3.fromRGB(255, 160, 160)
	hl.OutlineTransparency = 0
	hl.Adornee = char
	hl.Parent = char

	local bb
	if CFG.espInfo then
		bb = Instance.new("BillboardGui")
		bb.Adornee = char
		bb.Size = UDim2.fromOffset(180, 46)
		bb.StudsOffset = Vector3.new(0, 2.4, 0)
		bb.AlwaysOnTop = true
		bb.Parent = char

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.TextColor3 = Color3.fromRGB(255, 235, 235)
		lbl.TextStrokeTransparency = 0.4
		lbl.Text = ""
		lbl.Name = "Tag"
		lbl.Parent = bb
	end

	espStore[char] = { hl = hl, bb = bb, label = bb and bb:FindFirstChild("Tag") }
end

task.spawn(function()
	while true do
		task.wait(0.2)
		pcall(function()
			if not CFG.esp then
				for char in pairs(espStore) do destroyESP(char) end
			else
				local alive = {}
				local cam = workspace.CurrentCamera
				for _, t in ipairs(targets) do
					alive[t.char] = true
					if not espStore[t.char] then buildESP(t.char) end
					local rec = espStore[t.char]
					if rec and rec.label and cam then
						local part = targetPartOf(t)
						if part then
							local dist = math.floor((part.Position - cam.CFrame.Position).Magnitude)
							local hp = math.floor(t.hum.Health)
							local name = t.plr and t.plr.DisplayName or t.char.Name
							rec.label.Text = string.format("%s  [%d]  %dm", name, hp, dist)
						end
					end
				end
				for char in pairs(espStore) do
					if not alive[char] or not char.Parent then destroyESP(char) end
				end
			end
		end)
	end
end)

local fbBackup

local function setFullbright(on)
	if on then
		if not fbBackup then
			fbBackup = {
				Brightness = Lighting.Brightness,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				FogEnd = Lighting.FogEnd,
				ClockTime = Lighting.ClockTime,
			}
		end
		Lighting.Brightness = 3
		Lighting.Ambient = Color3.fromRGB(150, 150, 150)
		Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
		Lighting.FogEnd = 1e6
		Lighting.ClockTime = 14
	elseif fbBackup then
		Lighting.Brightness = fbBackup.Brightness
		Lighting.Ambient = fbBackup.Ambient
		Lighting.OutdoorAmbient = fbBackup.OutdoorAmbient
		Lighting.FogEnd = fbBackup.FogEnd
		Lighting.ClockTime = fbBackup.ClockTime
		fbBackup = nil
	end
end

local Window = WindUI:CreateWindow({
	Title = "方块大战",
	Icon = "crosshair",
	Author = "by:Z某人",
	Folder = "VoxelWarsHub",
	Size = UDim2.fromOffset(400, 400),
	Theme = "Midnight",
	HideSearchBar = true,
})

_G.VW_HUB = Window

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
		ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 0, 255)),
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

Window:EditOpenButton({
	Title = "打开脚本",
	Icon = "crosshair",
	CornerRadius = UDim.new(0, 16),
	StrokeThickness = 2,
	Color = ColorSequence.new(Color3.fromHex("9B59B6")),
	Draggable = true,
})

local CombatTab = Window:Tab({ Title = "战斗", Icon = "crosshair", Locked = false })

CombatTab:Section({ Title = "瞄准", TextXAlignment = "Left", TextSize = 17 })

CombatTab:Toggle({
	Title = "自动开火",
	Default = false,
	Callback = function(state) CFG.autoFire = state and true or false end,
})

CombatTab:Slider({
	Title = "射速",
	Value = { Min = 1, Max = 30, Default = 9 },
	Increment = 1,
	Callback = function(v) if type(v) == "number" then CFG.fireRate = v end end,
})

CombatTab:Slider({
	Title = "锁定范围",
	Value = { Min = 40, Max = 1000, Default = 260 },
	Increment = 10,
	Callback = function(v) if type(v) == "number" then CFG.fov = v end end,
})

CombatTab:Dropdown({
	Title = "瞄准部位",
	Values = { "Head", "UpperTorso", "HumanoidRootPart", "Torso" },
	Value = "Head",
	Callback = function(v) if v then CFG.part = v end end,
})

CombatTab:Dropdown({
	Title = "弹道起点",
	Values = { "Head", "Camera", "HumanoidRootPart" },
	Value = "Head",
	Callback = function(v) if v then CFG.originMode = v end end,
})

CombatTab:Slider({
	Title = "弹道参数",
	Value = { Min = 0, Max = 8, Default = 0 },
	Increment = 1,
	Callback = function(v) if type(v) == "number" then CFG.gunArg = v end end,
})

CombatTab:Section({ Title = "其他", TextXAlignment = "Left", TextSize = 17 })

CombatTab:Toggle({
	Title = "队伍检测",
	Default = true,
	Callback = function(state) CFG.teamCheck = state and true or false end,
})

CombatTab:Toggle({
	Title = "只打玩家",
	Default = false,
	Callback = function(state) CFG.playersOnly = state and true or false end,
})

CombatTab:Toggle({
	Title = "弹道预判",
	Default = true,
	Callback = function(state) CFG.predict = state and true or false end,
})

CombatTab:Toggle({
	Title = "自动换弹",
	Default = false,
	Callback = function(state) CFG.autoReload = state and true or false end,
})

CombatTab:Slider({
	Title = "换弹间隔",
	Value = { Min = 1, Max = 10, Default = 2 },
	Increment = 0.1,
	Callback = function(v) if type(v) == "number" then CFG.reloadEvery = v end end,
})

local VisualTab = Window:Tab({ Title = "视觉", Icon = "eye", Locked = false })

VisualTab:Section({ Title = "透视", TextXAlignment = "Left", TextSize = 17 })

VisualTab:Toggle({
	Title = "ESP",
	Default = false,
	Callback = function(state) CFG.esp = state and true or false end,
})

VisualTab:Toggle({
	Title = "显示血量距离",
	Default = true,
	Callback = function(state) CFG.espInfo = state and true or false end,
})

VisualTab:Section({ Title = "画面", TextXAlignment = "Left", TextSize = 17 })

VisualTab:Toggle({
	Title = "全亮",
	Default = false,
	Callback = function(state) setFullbright(state and true or false) end,
})

VisualTab:Slider({
	Title = "视野 FOV",
	Value = { Min = 40, Max = 120, Default = 70 },
	Increment = 1,
	Callback = function(v)
		if type(v) == "number" and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = v
		end
	end,
})

VisualTab:Button({
	Title = "重置 FOV",
	Callback = function()
		if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
	end,
})
