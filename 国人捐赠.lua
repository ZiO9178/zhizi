local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Window = WindUI:CreateWindow({
    Title = "国人捐赠",
    Icon = "monitor",
    Author = "Z某人",
    Folder = "DefenseSystem",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Midnight",
    HideSearchBar = false, 
})


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
        ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 0, 255))
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

local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromRGB(255, 255, 255)
})

local hue = 0
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        
        hue = (hue + 0.01) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        
        TimeTag:SetTitle(hours .. ":" .. minutes)
        TimeTag:SetColor(rainbowColor) 

        task.wait(0.06)
    end
end)

Window:EditOpenButton({
    Title = "打开脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("9B59B6")),
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "赚积分",
    Icon = "",
    Locked = false,
})

local _G_AutoObbyReward = false

local rewardPads = {
    {"ObbyArea", "LongWalk", "ThreePointRewardPad"},
    {"ObbyArea", "InsaneObby", "ThreePointRewardPad"},
    {"ObbyArea", "HardObby", "Obby", "ThreePointRewardPad"},
    {"ObbyArea", "EazyObby", "ThreePointRewardPad"},
    {"ObbyArea", "GlassBridgeChallenge", "ThreePointRewardPad"}
}

local function getPadFromPath(path)
    local current = workspace
    for _, name in ipairs(path) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local function interruptibleWait(seconds)
    local elapsed = 0
    while elapsed < seconds and _G_AutoObbyReward do
        task.wait(0.5)
        elapsed = elapsed + 0.5
    end
end

Tab:Toggle({
    Title = "自动赚积分",
    Default = false,
    Callback = function(Value)
        _G_AutoObbyReward = Value

        if _G_AutoObbyReward then
            task.spawn(function()
                while _G_AutoObbyReward do
                    for _, path in ipairs(rewardPads) do
                        if not _G_AutoObbyReward then break end

                        local targetPad = getPadFromPath(path)
                        local character = game.Players.LocalPlayer.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")

                        if targetPad and hrp then
                            hrp.CFrame = targetPad.CFrame + Vector3.new(0, 3, 0)
                        end

                        interruptibleWait(3)
                    end

                    if not _G_AutoObbyReward then break end

                    interruptibleWait(3600)
                end
            end)
        end
    end
})

Tab:Paragraph({
    Title = "提示",
    Desc = "60分钟后自动下一轮",
})

local Tab = Window:Tab({
    Title = "AFK",
    Icon = "",
    Locked = false,
})

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local antiAfkConnection = nil

Tab:Toggle({
    Title = "防挂机",
    Default = false,
    Callback = function(Value)
        if Value then
            if not antiAfkConnection then
                antiAfkConnection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                    print("")
                end)
                print("")
            end
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
                print("")
            end
        end
    end
})