-- [[ miniyakihub - Delta Executor Mobile Absolute Fixed v4 ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- 自動化の状態管理（初期状態はOFF）
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 🛠️ 1. Delta絶対起動UIシステム（偽装PlayerGuiレイヤー）
-- =================================================================
-- 重複起動を防止するために古いUIを徹底クリーンアップ
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaAbsoluteUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaAbsoluteUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999 -- Deltaの描画制限を上回る最前面配置

-- 【Delta最重要対策】CoreGui等への干渉を避け、安全なPlayerGuiに強制格納
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- ─── UIカラー構成（miniyakihub専用オレンジ仕様） ───
local C = {
    WindowBg     = Color3.fromRGB(25, 23, 22),      -- 黒に近い深みのあるオレンジ
    HeaderBg     = Color3.fromRGB(35, 30, 25),      -- ヘッダー
    Accent       = Color3.fromRGB(255, 128, 0),     -- メインオレンジ（焼き色）
    BtnDefault   = Color3.fromRGB(45, 42, 40),      -- ボタンOFF時
    TextGray     = Color3.fromRGB(180, 175, 170),
    White        = Color3.fromRGB(255, 255, 255)
}

-- メインウィンドウ（スマホの画面比率を考慮したレスポンシブ中央配置）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 230)
mainFrame.Position = UDim2.new(0.5, -115, 0.4, -115) -- 画面ど中央に絶対出現
mainFrame.BackgroundColor3 = C.WindowBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- モバイルのタッチ移動に完全対応
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- 全体を引き締める鮮やかなオレンジの枠線（UIStroke）
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Accent
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

-- ヘッダー部分
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.HeaderBg
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- ヘッダー下部のオレンジライン
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.BackgroundColor3 = C.Accent
headerLine.BorderSizePixel = 0
headerLine.Parent = header

-- タイトルロゴ
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🍊 miniyakihub"
title.TextColor3 = C.White
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ─── Deltaに最適化した高反応トグルボタンの生成関数 ───
local function AddCustomToggle(text, posY, optionKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 42)
    btn.Position = UDim2.new(0, 12, 0, posY)
    btn.BackgroundColor3 = C.BtnDefault
    btn.BorderSizePixel = 0
    btn.Text = "   " .. text .. " : OFF"
    btn.TextColor3 = C.TextGray
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(55, 52, 50)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    -- タップ（クリック）時の超高速反応処理
    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        local isEnabled = Options[optionKey]

        if isEnabled then
            btn.BackgroundColor3 = C.Accent
            btn.TextColor3 = C.White
            btn.Text = "   " .. text .. " : ON"
            btnStroke.Color = C.White
        else
            btn.BackgroundColor3 = C.BtnDefault
            btn.TextColor3 = C.TextGray
            btn.Text = "   " .. text .. " : OFF"
            btnStroke.Color = Color3.fromRGB(55, 52, 50)
        end
    end)
end

-- ボタンを縦並びで綺麗にレイアウト
AddCustomToggle("Auto Steal (自動卵回収)", 55, "AutoSteal")
AddCustomToggle("Auto Hatch (自動卵孵化)", 110, "AutoHatch")
AddCustomToggle("Auto Place (自動ベース配置)", 165, "AutoPlace")


-- =================================================================
-- 🚀 2. 自動化機能 ＆ OxideHub直系バイパスロジック
-- =================================================================

-- 卵オブジェクトの絶対判定フィルター
local function isValidEgg(part)
    if not part or not part.Parent then return false end
    local name = string.lower(part.Name)
    local parentName = string.lower(part.Parent.Name)
    return string.find(name, "egg") or string.find(parentName, "egg") or part:FindFirstChild("EggPart")
end

-- ① 超高速自動卵回収コアループ
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
                            -- 物理テレポートを挟まずに、サーバー側へ直接「触れた(0)」「離れた(1)」を送信して吸い込む
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- ② 自動孵化 ＆ 自動ベース配置リモート発火コアループ
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

-- ③ OxideHub直系 アンチチートThreatLogs自動リセット
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)

print("[🍊 miniyakihub] 起動成功！Delta専用の最前面レイヤーに展開されました。")
