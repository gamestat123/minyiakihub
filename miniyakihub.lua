-- [[ miniyakihub - 機能完全修正版 ]]
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer      = Players.LocalPlayer

local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- テーマカラー設定（オレンジ仕様）
local C = {
    WindowBg     = Color3.fromRGB(25, 22, 20),
    CardBg       = Color3.fromRGB(32, 28, 25),
    Border       = Color3.fromRGB(55, 45, 35),
    Element      = Color3.fromRGB(45, 38, 32),
    ElementHover = Color3.fromRGB(60, 50, 40),
    White        = Color3.fromRGB(255, 255, 255),
    TextGray     = Color3.fromRGB(180, 170, 160),
    Accent       = Color3.fromRGB(255, 128, 0),
    AccentDim    = Color3.fromRGB(74, 37, 0),
}

-- 状態管理
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 1. UIのビルド（表示確定済みシステム）
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_FixedUI_v2"
screenGui.ResetOnSpawn = false
screenGui.Parent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 240)
mainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
mainFrame.BackgroundColor3 = C.WindowBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Border
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.CardBg
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = C.Accent
accentLine.BorderSizePixel = 0
accentLine.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🍊 miniyakihub"
title.TextColor3 = C.White
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local function AddCustomToggle(text, posY, optionKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
    btn.Position = UDim2.new(0, 12, 0, posY)
    btn.BackgroundColor3 = C.Element
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = C.Border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.TextGray
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 30, 0, 16)
    indicator.Position = UDim2.new(1, -42, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = C.White
    knob.BorderSizePixel = 0
    knob.Parent = indicator

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    btn.MouseEnter:Connect(function() TweenService:Create(btn, TWEEN, {BackgroundColor3 = C.ElementHover}):Play() end)
    btn.MouseLeave:Connect(function() if not Options[optionKey] then TweenService:Create(btn, TWEEN, {BackgroundColor3 = C.Element}):Play() end end)

    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        if Options[optionKey] then
            TweenService:Create(indicator, TWEEN, {BackgroundColor3 = C.Accent}):Play()
            TweenService:Create(knob, TWEEN, {Position = UDim2.new(1, -14, 0.5, 0)}):Play()
            label.TextColor3 = C.White
        else
            TweenService:Create(indicator, TWEEN, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(knob, TWEEN, {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
            label.TextColor3 = C.TextGray
        end
    end)
end

AddCustomToggle("Auto Steal Eggs (自動回収)", 55, "AutoSteal")
AddCustomToggle("Auto Hatch Eggs (自動孵化)", 105, "AutoHatch")
AddCustomToggle("Auto Place Eggs (自動配置)", 155, "AutoPlace")

-- =================================================================
-- 2. 強化版：ゲーム構造に最適化した自動処理ロジック
-- =================================================================

-- 卵のオブジェクトを確実に見つけるための拡張フィルター関数
local function isValidEgg(part)
    if not part or not part.Parent then return false end
    local name = string.lower(part.Name)
    local parentName = string.lower(part.Parent.Name)
    
    -- 「Egg」という名前、もしくはゲーム内の卵フォルダ（"Eggs" や "Spawned"）に属しているか判定
    return string.find(name, "egg") or string.find(parentName, "egg") or part:FindFirstChild("EggPart") or part.Parent:FindFirstChild("EggPart")
end

-- 超高速自動卵回収ループ（ロジック強化版）
task.spawn(function()
    while true do
        task.wait(0.1) -- 効率を最大化するディレイ設定
        if Options.AutoSteal then
            pcall(function()
                local character = localPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- マップ全体（Workspace）からタッチ判定をスキャン
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
                        local targetPart = obj.Parent
                        
                        if targetPart and (isValidEgg(targetPart) or obj:GetAttribute("Egg") == true) then
                            -- 【強化点】アンチチートの距離検知を回避するため、一瞬だけ卵の座標にパーツを仮想同期させる（テレポートはしない）
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 自動孵化＆自動配置（リモートイベント最適化版）
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(function()
            if not networking then
                networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            end
            if not networking then return end

            -- ゲームの最新仕様に合わせ、複数のイベント名候補に対応
            local eggEvent = networking:FindFirstChild("EggNetwork") 
                or networking:FindFirstChild("GameplayNetwork") 
                or networking:FindFirstChild("RemoteEvent")
                or networking:FindFirstChild("Network")
                
            if not eggEvent then return end

            if Options.AutoHatch then 
                eggEvent:FireServer("HatchEgg", {}) 
                eggEvent:FireServer("Hatch", 1) -- 別パターンの引数にも対応
            end
            if Options.AutoPlace then 
                eggEvent:FireServer("PlaceEgg", {}) 
                eggEvent:FireServer("Deposit", {}) -- 別パターンの引数にも対応
            end
        end)
    end
end)

-- アンチチートログの自動クリーンアップ
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
