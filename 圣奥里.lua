local AlexchadLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/Sxingz%20Hub%20UI.lua"))()

local Window = AlexchadLibrary:CreateWindow({
    Name = "Sxingz Hub|圣奥里",
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
    Name = "飞行v3",
    Callback = function()
        print("")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CNHM/asg/refs/heads/main/fly.lua"))()
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

Section2:CreateButton({
    Name = "传送到乘客或目的地（出租车）",
    Callback = function()
        local target = workspace.Gameplay.Entities.ClientContent:FindFirstChild("VehicleInteraction")
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        if character and character:FindFirstChild("HumanoidRootPart") and target then
            character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
            
            Window:Notify({
                Title = "传送成功",
                Content = "已传送乘客或目的地",
                Duration = 3,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "传送失败",
                Content = "未找到目标",
                Duration = 3,
                Type = "Error"
            })
        end
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
    Title = "Sxingz Hub|圣奥里加载完成",
    Content = "欢迎使用Sxingz Hub",
    Duration = 3,
    Type = "Success"
})