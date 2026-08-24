local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()

local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Window = WindUI:CreateWindow({
    Title = "文本",
    Icon = "monitor",
    Author = "by Z某人",
    Folder = "DefenseSystem",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Dark",
    Background = "",
    HideSearchBar = false,
    ToggleKey = Enum.KeyCode.RightShift,
    User = {
        Enabled = true,
        Callback = function() end,
        Anonymous = false
    },
})

local TimeTag = Window:Tag({
    Title = "00:00:00",
    Icon = "",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 5,
})

task.spawn(function()
    while true do
        local timeStr = os.date("%H:%M:%S")
        if TimeTag and TimeTag.SetTitle then
            TimeTag:SetTitle("" .. timeStr)
        end
        task.wait(1)
    end
end)

do
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then
        task.wait(0.3)
        mainFrame = Window.UIElements and Window.UIElements.Main
    end
    if not mainFrame then
        warn("")
        return
    end

    local corner = mainFrame:FindFirstChild("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end

    local oldStroke = mainFrame:FindFirstChild("RainbowStroke")
    if oldStroke then oldStroke:Destroy() end

    local colorScheme = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    })

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RainbowStroke"
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = mainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = colorScheme
    gradient.Rotation = 0
    gradient.Parent = stroke

    local angle = 0
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not stroke or stroke.Parent == nil then
            connection:Disconnect()
            return
        end
        angle = (angle + 180 * deltaTime) % 360
        gradient.Rotation = angle
    end)

    print("")
end

Window:EditOpenButton({
    Title = "打开菜单",
    Icon = "menu",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190, 0, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 0, 255))
    }),
    Enabled = true,
    Draggable = true,
})

WindUI:Notify({
    Title = "欢迎使用",
    Content = "脚本已成功加载",
    Duration = 5,
    Icon = "sparkles"
})

local MainTab = Window:Tab({ Title = "自动功能", Icon = "" })

MainTab:Toggle({
    Title = "自动捡叶子",
    Desc = "",
    Locked = false,
    Callback = function(state)
        if state then
            if _G.CollectRunning then
                _G.CollectRunning = false
                task.wait(0.5)
            end
            
            _G.CollectRunning = true
            
            local function collectLeaves()
                local collectedCount = 0
                while _G.CollectRunning do
                    for i = 1, 10000 do
                        if not _G.CollectRunning then 
                            break 
                        end
                        
                        pcall(function()
                            local args = {i}
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CollectLeaf"):FireServer(unpack(args))
                            collectedCount = collectedCount + 1
                        end)
                        
                        task.wait(0.05)
                    end
                    
                    if _G.CollectRunning then
                        task.wait(0.5)
                    end
                end
                print("" .. collectedCount .. "")
            end
            
            _G.CollectThread = coroutine.create(collectLeaves)
            coroutine.resume(_G.CollectThread)
            
            WindUI:Notify({
                Title = "状态",
                Content = "自动捡叶子已开启",
                Icon = "solar:leaf-bold",
                Duration = 3,
                CanClose = false,
            })
        else
            _G.CollectRunning = false
            _G.CollectThread = nil
            
            WindUI:Notify({
                Title = "状态",
                Content = "自动捡叶子已关闭",
                Icon = "solar:bell-bold",
                Duration = 3,
                CanClose = false,
            })
        end
    end
})

MainTab:Toggle({
    Title = "自动出售",
    Desc = "要靠近垃圾桶",
    Locked = false,
    Callback = function(state)
        if state then
            if _G.AutoSellRunning then
                _G.AutoSellRunning = false
                task.wait(0.5)
            end
            
            _G.AutoSellRunning = true
            
            coroutine.wrap(function()
                while _G.AutoSellRunning do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EmptyBackpack"):FireServer()
                    end)
                    task.wait(2)
                end
            end)()
            
            WindUI:Notify({
                Title = "状态",
                Content = "自动出售已开启",
                Icon = "solar:dollar-bold",
                Duration = 3,
                CanClose = false,
            })
        else
            _G.AutoSellRunning = false
            
            WindUI:Notify({
                Title = "状态",
                Content = "自动出售已关闭",
                Icon = "solar:bell-bold",
                Duration = 3,
                CanClose = false,
            })
        end
    end
})

local MainTab = Window:Tab({ Title = "升级功能", Icon = "" })

local autoUpgrade = false
local upgradeType = "Hold"

MainTab:Dropdown({
    Title = "手",
    Values = {"按住", "敏捷", "抓住"},
    Value = "按住",
    Callback = function(Value)
        local upgradeMap = {
            ["按住"] = "Hold",
            ["敏捷"] = "Dexterity",
            ["抓住"] = "Grasp"
        }
        upgradeType = upgradeMap[Value]
    end
})

MainTab:Toggle({
    Title = "自动升级手",
    Callback = function(State)
        autoUpgrade = State
        if autoUpgrade then
            while autoUpgrade and task.wait(0.1) do
                local args = {"Hand", upgradeType}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyUpgrade"):FireServer(unpack(args))
            end
        end
    end
})

local autoUpgrade = false
local upgradeType = "Range"

MainTab:Dropdown({
    Title = "耙子",
    Values = {"范围", "半径", "粘性"},
    Value = "范围",
    Callback = function(Value)
        local upgradeMap = {
            ["范围"] = "Range",
            ["半径"] = "Radius",
            ["粘性"] = "Stickiness"
        }
        upgradeType = upgradeMap[Value]
    end
})

MainTab:Toggle({
    Title = "自动升级耙子",
    Callback = function(State)
        autoUpgrade = State
        if autoUpgrade then
            while autoUpgrade and task.wait(0.1) do
                local args = {"Rake", upgradeType}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyUpgrade"):FireServer(unpack(args))
            end
        end
    end
})

local autoUpgrade = false
local upgradeType = "Width"

MainTab:Dropdown({
    Title = "吹叶机",
    Values = {"宽度", "力量", "涂抹"},
    Value = "宽度",
    Callback = function(Value)
        local upgradeMap = {
            ["宽度"] = "Width",
            ["力量"] = "Power",
            ["涂抹"] = "Spread"
        }
        upgradeType = upgradeMap[Value]
    end
})

MainTab:Toggle({
    Title = "自动升级吹叶机",
    Callback = function(State)
        autoUpgrade = State
        if autoUpgrade then
            while autoUpgrade and task.wait(0.1) do
                local args = {"LeafBlower", upgradeType}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyUpgrade"):FireServer(unpack(args))
            end
        end
    end
})

local MainTab = Window:Tab({ Title = "工具购买", Icon = "" })

MainTab:Dropdown({
    Title = "选择工具",
    Values = {"耙子", "吹叶机", "LeafMower"},
    Value = "Rake",
    Callback = function(Value)
        _G.SelectedTool = Value
    end
})

MainTab:Button({
    Title = "购买工具",
    Desc = "",
    Locked = false,
    Callback = function()
        local toolName = _G.SelectedTool or "Rake"
        local args = {toolName}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyToolCash"):FireServer(unpack(args))
        WindUI:Notify({
            Title = "购买成功",
            Content = "你已成功购买 " .. toolName .. "！",
            Icon = "solar:bell-bold",
            Duration = 5,
            CanClose = false,
        })
    end
})