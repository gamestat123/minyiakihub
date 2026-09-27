-- [[ miniyakihub - Delta Executor Mobile Fixed Full Version ]]
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer      = Players.LocalPlayer

local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ════════════════════════════════════════════════════════════════════════════
-- テーマカラー設定（全体を圧倒的なオレンジ仕様に上書きカスタマイズ）
-- ════════════════════════════════════════════════════════════════════════════
local C = {
    WindowBg     = Color3.fromRGB(25, 22, 20),      -- 深みのある黒オレンジ
    CardBg       = Color3.fromRGB(32, 28, 25),      -- カード背景
    Border       = Color3.fromRGB(55, 45, 35),      -- オレンジがかった境界線
    Element      = Color3.fromRGB(45, 38, 32),      -- ボタン背景
    ElementHover = Color3.fromRGB(60, 50, 40),      -- ホバー時
    White        = Color3.fromRGB(255, 255, 255),
    TextGray     = Color3.fromRGB(180, 170, 160),
    Accent       = Color3.fromRGB(255, 128, 0),     -- 核心：鮮やかなオレンジ！
    AccentDim    = Color3.fromRGB(74, 37, 0),       -- 暗いオレンジ
    AccentText   = Color3.fromRGB(255, 255, 255),
}

-- 自動化の状態管理
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 1. Delta専用：UIオブジェクトの強制ビルドシステム
-- =================================================================
-- 重複起動によるクラッシュを防ぐため、古いUIを削除
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999

-- 【Deltaセキュリティ対策】エラーを回避するためPlayerGuiを確実に親に指定
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- メインウィンドウ（スマホ・タブレットの画面中央にレスポンシブ配置）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 240)
mainFrame.Position = UDim2.new(0.5, -120, 0.4, -120) -- 画面中央に強制出現
mainFrame.BackgroundColor3 = C.WindowBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- モバイルのドラッグ操作に対応
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Border
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- ヘッダーバー
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.CardBg
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- オレンジのアクセントライン
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
title.Text = "🍊 miniyakihub (Delta)"
title.TextColor3 = C.White
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- =================================================================
-- 2. トグルボタン生成ロジック
-- =================================================================
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
    label.TextSize = 11
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

    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        local isEnabled = Options[optionKey]

        if isEnabled then
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
-- 3. 強化版：自動化・検知回避コアロジック
-- =================================================================
local function isValidEgg(part)
    if not part or not part.Parent then return false end
    local name = string.lower(part.Name)
    local parentName = string.lower(part.Parent.Name)
    return string.find(name, "egg") or string.find(parentName, "egg") or part:FindFirstChild("EggPart")
end

-- アンチチートThreatLogs自動リセット
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)

-- 卵自動回収ループ（最速設定）
task.spawn(function()
    while true do
        task.wait(0.15)
        if Options.AutoSteal then
            pcall(function()
                local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
                        local parentPart = obj.Parent
                        if parentPart and isValidEgg(parentPart) then
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 切れていたリモート発火ロジックの完全結合・クローズ
task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            if not networking then
                networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            end
            if not networking then return end

            local eggEvent = networking:FindFirstChild("EggNetwork") or networking:FindFirstChild("GameplayNetwork")
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

print("🍊 miniyakihub initialized successfully on Delta!")
