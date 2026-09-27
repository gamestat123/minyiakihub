-- [[ miniyakihub - UI強制描画・アンチ検知バイパス版 ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 1. アンチチートを破壊するUI偽装生成システム
-- =================================================================
-- ゲーム側のUIスキャンを避けるため、名前を完全にランダムな英数字にする
local function generateRandomName()
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = ""
    for i = 1, 16 do
        local rand = math.random(1, #characters)
        name = name .. string.sub(characters, rand, rand)
    end
    return name
end

-- 既存の古いUIがあれば削除
local oldUI = game:GetService("CoreGui"):FindFirstChild("miniyakihub_FixedUI_v3") or localPlayer:WaitForChild("PlayerGui"):FindFirstChild("miniyakihub_FixedUI_v3")
if oldUI then oldUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_FixedUI_v3"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999 -- 他のすべてのUIよりも手前に強制配置

-- 描画エラーを完全に回避する親オブジェクトの選択
if typeof(gethui) == "function" then
    screenGui.Parent = gethui()
else
    screenGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
end

-- =================================================================
-- 2. オレンジ仕様デザインの構築
-- =================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = generateRandomName()
mainFrame.Size = UDim2.new(0, 230, 0, 210)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0) -- 画面中央付近に出現
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- マウスや指で自由に移動可能
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- オレンジの枠線
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 128, 0)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- ヘッダー
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🍊 miniyakihub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ボタン生成共通ロジック
local function AddCustomToggle(text, posY, optionKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        if Options[optionKey] then
            btn.Text = "  " .. text .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(255, 128, 0) -- ONでオレンジ色に変化
        else
            btn.Text = "  " .. text .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    end)
end

-- 3つのボタンを配置
AddCustomToggle("Auto Steal (自動回収)", 45, "AutoSteal")
AddCustomToggle("Auto Hatch (自動孵化)", 100, "AutoHatch")
AddCustomToggle("Auto Place (自動配置)", 155, "AutoPlace")

-- =================================================================
-- 3. 自動化コアループ (強化版)
-- =================================================================
local function isValidEgg(part)
    if not part or not part.Parent then return false end
    local name = string.lower(part.Name)
    local parentName = string.lower(part.Parent.Name)
    return string.find(name, "egg") or string.find(parentName, "egg") or part:FindFirstChild("EggPart")
end

-- 卵回収スレッド
task.spawn(function()
    while true do
        task.wait(0.15)
        if Options.AutoSteal then
            pcall(function()
                local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
                        local targetPart = obj.Parent
                        if targetPart and isValidEgg(targetPart) then
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- リモート発火スレッド
task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            if not networking then
                networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            end
            if not networking then return end

            local eggEvent = networking:FindFirstChild("EggNetwork") 
                or networking:FindFirstChild("GameplayNetwork") 
                or networking:FindFirstChild("RemoteEvent")
                
            if not eggEvent then return end

            if Options.AutoHatch then 
                eggEvent:FireServer("HatchEgg", {}) 
                eggEvent:FireServer("Hatch", 1)
            end
            if Options.AutoPlace then 
                eggEvent:FireServer("PlaceEgg", {}) 
                eggEvent:FireServer("Deposit", {})
            end
        end)
    end
end)

-- アンチチート防御
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
