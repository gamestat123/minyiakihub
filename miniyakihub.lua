-- [[ miniyakihub - Delta Executor Mobile Fixed ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 1. Delta専用：強制描画UI偽装システム
-- =================================================================
-- 古い同名UIが残っていたら競合を防ぐため事前に消去
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999 -- 最前面に強制レイヤー配置

-- 【Delta対策】セキュリティエラーを回避するため、Deltaが一番得意とするPlayerGuiを親に指定
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- メインウィンドウ（スマホの画面サイズに合わせてレスポンシブに中央配置）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 200)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -100) -- スマホ画面のほぼ中央に強制表示！
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- スマホのタップドラッグ操作に対応
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- オレンジの枠線
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 128, 0) -- 鮮やかなオレンジ
mainStroke.Thickness = 2.5
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
title.Text = "🍊 miniyakihub (Delta)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ボタン生成（モバイルのタップ操作に最適化）
local function AddCustomToggle(text, posY, optionKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    -- タップ（クリック）時のイベント処理
    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        if Options[optionKey] then
            btn.Text = "  " .. text .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(255, 128, 0) -- ONでオレンジ化
        else
            btn.Text = "  " .. text .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    end)
end

-- ボタンを縦並びで配置
AddCustomToggle("Auto Steal (自動卵回収)", 45, "AutoSteal")
AddCustomToggle("Auto Hatch (自動卵孵化)", 100, "AutoHatch")
AddCustomToggle("Auto Place (自動配置)", 155, "AutoPlace")

-- =================================================================
-- 2. 自動化ロジック (Delta 処理速度最適化版)
-- =================================================================
local function isValidEgg(part)
    if not part or not part.Parent then return false end
    local name = string.lower(part.Name)
    local parentName = string.lower(part.Parent.Name)
    return string.find(name, "egg") or string.find(parentName, "egg") or part:FindFirstChild("EggPart")
end

-- 卵回収ループ
task.spawn(function()
    while true do
        task.wait(0.2) -- モバイル端末の負荷を考慮し、微修正
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

-- リモート通信ループ
task.spawn(function()
    while true do
        task.wait(0.5)
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

-- アンチチート検知データの防御
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
