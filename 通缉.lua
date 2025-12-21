local AlexchadLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/Sxingz%20Hub%20UI.lua"))()

local Window = AlexchadLibrary:CreateWindow({
    Name = "Sxingz Hub|通缉",
    Subtitle = "Z某人",
    Version = "免费版",
    LoadingTitle = "Sxingz Hub加载中",
    LoadingSubtitle = "请稍后...",
    Theme = "Default",
    AnimationSpeed = 0.2,
    RippleEnabled = false, 
    RippleSpeed = 0.35,
    CornerRadius = 12,
    ElementCornerRadius = 10,
    BlurEnabled = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "AlexchadLibraryExample", 
        FileName = "Config"
    },
    ToggleKey = Enum.KeyCode.RightShift
})

local Tab1 = Window:CreateTab({
    Name = "主要功能",
    Icon = ""
})

local Section1 = Tab1:CreateSection("通用")

Section1:CreateSlider({
    Name = "奔跑速度",
    Flag = "",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

Section1:CreateSlider({
    Name = "跳跃高度",
    Flag = "",
    Range = {0, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            pcall(function()
                humanoid.JumpHeight = value
            end)

            pcall(function()
                humanoid.UseJumpPower = true
                humanoid.JumpPower = value
            end)
        end
    end
})

Section1:CreateButton({
    Name = "无限跳跃",
    Callback = function()
        print("")
        loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
    end
})

Section1:CreateButton({
    Name = "电脑键盘",
    Callback = function()
        print("")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt", true))()
    end
})

local Tab2 = Window:CreateTab({
    Name = "赚钱功能",
    Icon = ""
})

local Section2 = Tab2:CreateSection("赚钱功能")

Section2:CreateToggle({
    Name = "自动抢夺ATM机",
    Flag = "",
    CurrentValue = false,
    Callback = function(enabled)
        getgenv().AutoTpPressE = enabled
        if not enabled then return end

        task.spawn(function()
            local Players = game:GetService("Players")
            local VIM = game:GetService("VirtualInputManager")
            local lp = Players.LocalPlayer

            local function getRoot()
                local ch = lp.Character or lp.CharacterAdded:Wait()
                return ch:WaitForChild("HumanoidRootPart", 5)
            end

            local function findATM()
                local localFolder = workspace:FindFirstChild("Local")
                local gizmos = localFolder and localFolder:FindFirstChild("Gizmos")
                local white = gizmos and gizmos:FindFirstChild("White")
                local atm = white and white:FindFirstChild("ATM")
                if not atm then return nil end

                if atm:IsA("BasePart") then
                    return atm
                end
                if atm:IsA("Model") then
                    return atm.PrimaryPart or atm:FindFirstChildWhichIsA("BasePart")
                end
                return atm:FindFirstChildWhichIsA("BasePart")
            end

            while getgenv().AutoTpPressE do
                local hrp = getRoot()
                local atmPart = findATM()

                if hrp and atmPart then
                    hrp.CFrame = atmPart.CFrame * CFrame.new(0, 0, -3)

                    task.wait(0.2)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                    task.wait(0.5)
                else
                    task.wait(0.5)
                end
            end
        end)
    end
})

Section2:CreateToggle({
    Name = "自动抢夺收银机",
    Flag = "",
    CurrentValue = false,
    Callback = function(enabled)
        getgenv().AutoTpPressE_Register = enabled
        if not enabled then return end

        task.spawn(function()
            local Players = game:GetService("Players")
            local VIM = game:GetService("VirtualInputManager")
            local lp = Players.LocalPlayer

            local function getRoot()
                local ch = lp.Character or lp.CharacterAdded:Wait()
                return ch:WaitForChild("HumanoidRootPart", 5)
            end

            local function findRegisterPart()
                local localFolder = workspace:FindFirstChild("Local")
                local gizmos = localFolder and localFolder:FindFirstChild("Gizmos")
                local white = gizmos and gizmos:FindFirstChild("White")
                local reg = white and white:FindFirstChild("Register")
                if not reg then return nil end

                if reg:IsA("BasePart") then
                    return reg
                end
                if reg:IsA("Model") then
                    return reg.PrimaryPart or reg:FindFirstChildWhichIsA("BasePart")
                end
                return reg:FindFirstChildWhichIsA("BasePart")
            end

            while getgenv().AutoTpPressE_Register do
                local hrp = getRoot()
                local targetPart = findRegisterPart()

                if hrp and targetPart then
                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, -3)

                    task.wait(0.2)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                    task.wait(0.5)
                else
                    task.wait(0.5)
                end
            end
        end)
    end
})

Section2:CreateToggle({
    Name = "自动拾取金银条",
    Flag = "",
    CurrentValue = false,
    Callback = function(enabled)
        getgenv().AutoTpPressE_Bars = enabled
        if not enabled then return end

        task.spawn(function()
            local Players = game:GetService("Players")
            local VIM = game:GetService("VirtualInputManager")
            local lp = Players.LocalPlayer

            local function getRoot()
                local ch = lp.Character or lp.CharacterAdded:Wait()
                return ch:WaitForChild("HumanoidRootPart", 5)
            end

            local function toPart(obj)
                if not obj then return nil end
                if obj:IsA("BasePart") then return obj end
                if obj:IsA("Model") then
                    return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                end
                return obj:FindFirstChildWhichIsA("BasePart", true)
            end

            local function getTargetParts()
                local localFolder = workspace:FindFirstChild("Local")
                local gizmos = localFolder and localFolder:FindFirstChild("Gizmos")
                local white = gizmos and gizmos:FindFirstChild("White")
                if not white then return {} end

                local gold = toPart(white:FindFirstChild("Gold Bar"))
                local silver = toPart(white:FindFirstChild("Silver Bar"))

                local parts = {}
                if gold then table.insert(parts, gold) end
                if silver then table.insert(parts, silver) end
                return parts
            end

            local idx = 1
            while getgenv().AutoTpPressE_Bars do
                local hrp = getRoot()
                local parts = getTargetParts()

                if hrp and #parts > 0 then
                    if idx > #parts then idx = 1 end
                    local target = parts[idx]

                    hrp.CFrame = target.CFrame * CFrame.new(0, 0, -3)

                    task.wait(0.2)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                    idx += 1
                    task.wait(0.5)
                else
                    task.wait(0.5)
                end
            end
        end)
    end
})

local Tab3 = Window:CreateTab({
    Name = "传送功能",
    Icon = ""
})

local Section3 = Tab3:CreateSection("传送功能")

Section3:CreateButton({
    Name = "传送到奥菲的价值兑换",
    Callback = function()
        print("")
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2907.68848, 37.1002731, 1652.74817, 0.848566413, 3.93804456e-08, -0.529088855, -1.77410708e-08, 1, 4.59770924e-08, 0.529088855, -2.96280138e-08, 0.848566413)
    end
})

Section3:CreateButton({
    Name = "传送到绿洲银行",
    Callback = function()
        print("")
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-431.537354, 39.6113892, -1400.08313, -0.901108384, -1.61007385e-08, -0.433593899, -5.26811039e-09, 1, -2.61848694e-08, 0.433593899, -2.13111857e-08, -0.901108384)
    end
})

Section3:CreateButton({
    Name = "传送到绿洲城警察",
    Callback = function()
        print("")
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1578.02393, 119.169289, -718.579773, -0.395326763, -5.95983245e-08, -0.918540537, -9.65633831e-08, 1, -2.33242137e-08, 0.918540537, 7.94766919e-08, -0.395326763)
    end
})

local Tab4 = Window:CreateTab({
    Name = "绘制功能",
    Icon = ""
})

local Section4 = Tab4:CreateSection("绘制功能")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local showNameHp = false
local drawingsByPlayer = {}

local function removePlayerDrawings(plr)
	local d = drawingsByPlayer[plr]
	if d then
		if d.name then d.name:Remove() end
		if d.hp then d.hp:Remove() end
		drawingsByPlayer[plr] = nil
	end
end

local function getOrCreateDrawings(plr)
	local d = drawingsByPlayer[plr]
	if d then return d end

	local nameText = Drawing.new("Text")
	nameText.Center = true
	nameText.Outline = true
	nameText.Size = 13
	nameText.Color = Color3.fromRGB(255, 255, 255)
	nameText.Visible = false

	local hpText = Drawing.new("Text")
	hpText.Center = true
	hpText.Outline = true
	hpText.Size = 13
	hpText.Color = Color3.fromRGB(0, 255, 80)
	hpText.Visible = false

	d = { name = nameText, hp = hpText }
	drawingsByPlayer[plr] = d
	return d
end

Players.PlayerRemoving:Connect(removePlayerDrawings)

RunService.RenderStepped:Connect(function()
	if not showNameHp then
		for _, d in pairs(drawingsByPlayer) do
			d.name.Visible = false
			d.hp.Visible = false
		end
		return
	end

	local localPlr = Players.LocalPlayer
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localPlr then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			local d = getOrCreateDrawings(plr)

			if hrp and hum and hum.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					d.name.Text = plr.Name
					d.hp.Text = ("HP: %d/%d"):format(math.floor(hum.Health), math.floor(hum.MaxHealth))

					d.name.Position = Vector2.new(pos.X, pos.Y - 20)
					d.hp.Position = Vector2.new(pos.X, pos.Y - 6)

					d.name.Visible = true
					d.hp.Visible = true
				else
					d.name.Visible = false
					d.hp.Visible = false
				end
			else
				d.name.Visible = false
				d.hp.Visible = false
			end
		end
	end
end)

Section4:CreateToggle({
	Name = "绘制玩家",
	Flag = "",
	CurrentValue = false,
	Callback = function(value)
		showNameHp = value
		print("DrawPlayerNameHp:", value)

		if not value then
			for _, d in pairs(drawingsByPlayer) do
				d.name.Visible = false
				d.hp.Visible = false
			end
		end
	end
})

local Tab5 = Window:CreateTab({
    Name = "取枪功能",
    Icon = ""
})

local Section5 = Tab5:CreateSection("取枪功能")

Section5:CreateButton({
    Name = "传送到自动瞄准器",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到自动瞄准器",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-822.973816, 325.617432, -506.576813, -0.829824746, 4.1572001e-08, 0.558024108, -1.70914252e-08, 1, -9.99148426e-08, -0.558024108, -9.2449234e-08, -0.829824746)
    end
})

Section5:CreateButton({
    Name = "传送到UMP 45",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到UMP 45",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1665.20264, 143.366074, -644.008301, -0.711087286, 7.77756792e-09, -0.703103721, 4.32548192e-10, 1, 1.0624305e-08, 0.703103721, 7.25068183e-09, -0.711087286)
    end
})

Section5:CreateButton({
    Name = "传送到贝内利M1014",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到贝内利M1014",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1345.20422, 141.041168, -4809.10693, -0.879722357, 4.09640144e-08, -0.475487679, 7.86845344e-09, 1, 7.15937816e-08, 0.475487679, 5.92412981e-08, -0.879722357)
    end
})

Section5:CreateButton({
    Name = "传送到M4A1",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到M4A1",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6342.43115, 134.380051, -4326.82861, -0.984255195, 1.02914059e-08, 0.176753372, 1.64892793e-08, 1, 3.35962618e-08, -0.176753372, 3.59818308e-08, -0.984255195)
    end
})

Section5:CreateButton({
    Name = "传送到AK-47",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到AK-47",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-7835.20752, 21.3648071, 1192.14551, -0.907641709, 3.20506324e-08, -0.419745833, 5.61626869e-08, 1, -4.50867184e-08, 0.419745833, -6.44966391e-08, -0.907641709)
    end
})

Section5:CreateButton({
    Name = "传送到RPG-7",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到RPG-7",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1392.19739, 275.933319, 3200.5188, -0.999439657, -4.08361416e-08, -0.0334718302, -4.13620711e-08, 1, 1.50201771e-08, 0.0334718302, 1.63962248e-08, -0.999439657)
    end
})

Section5:CreateButton({
    Name = "传送到乌兹",
    Callback = function()
        Window:Notify({
            Title = "传送成功",
            Content = "已传送到乌兹",
            Duration = 3,
            Type = "Success"
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1348.55493, 40.2014694, 2033.73645, -0.322550327, 6.19108533e-08, -0.946552336, 8.24317254e-08, 1, 3.73169797e-08, 0.946552336, -6.59893402e-08, -0.322550327)
    end
})

local CoreGui = game:GetService("CoreGui")
local MainUI = CoreGui:FindFirstChild("AlexchadLibrary") or CoreGui:FindFirstChild("Sxingz Hub") 

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SxToggle"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Text = "S"
ToggleButton.TextColor3 = Color3.fromRGB(120, 160, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Draggable = true
ToggleButton.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.fromRGB(80, 120, 255)
UIStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    local mainFrame = nil
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v:FindFirstChild("Main") or v:FindFirstChild("MainFrame") or v.Name:find("Alex")) then
            mainFrame = v:FindFirstChild("Main") or v:FindFirstChild("MainFrame") or v:FindFirstChildOfClass("Frame")
            if mainFrame then break end
        end
    end

    if mainFrame then
        mainFrame.Visible = not mainFrame.Visible
    else
        pcall(function() Window:Toggle() end) 
    end

    ToggleButton:TweenSize(UDim2.new(0, 48, 0, 48), "Out", "Quad", 0.1, true)
    task.wait(0.1)
    ToggleButton:TweenSize(UDim2.new(0, 55, 0, 55), "Out", "Quad", 0.1, true)
end)

Window:Notify({
    Title = "Sxingz Hub|加载完成",
    Content = "欢迎使用Sxingz Hub",
    Duration = 3,
    Type = "Success"
})