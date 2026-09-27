-- [[ miniyakihub - Delta UI & ChilliHub Absolute Recognition Fusion ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理（初期状態はOFF）
local Options = { AutoSteal = false }
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 1. Delta専用：UI強制表示（PlayerGui配置 ＆ 画面中央固定）
-- =================================================================
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaAbsoluteUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaAbsoluteUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui") -- Delta対策

-- メインウィンドウ（オレンジ仕様）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 128, 0)
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

-- タイトル
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
title.Text = "  🍊 miniyakihub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- トグルボタン（ON/OFFスイッチ）
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -24, 0, 42)
btn.Position = UDim2.new(0, 12, 0, 50)
btn.BackgroundColor3 = Color3.fromRGB(45, 42, 40)
btn.Text = "Auto Steal (自動卵回収) : OFF"
btn.TextColor3 = Color3.fromRGB(180, 175, 170)
btn.Font = Enum.Font.GothamMedium
btn.TextSize = 11
btn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btn

btn.MouseButton1Click:Connect(function()
    Options.AutoSteal = not Options.AutoSteal
    if Options.AutoSteal then
        btn.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "Auto Steal (自動卵回収) : ON"
    else
        btn.BackgroundColor3 = Color3.fromRGB(45, 42, 40)
        btn.TextColor3 = Color3.fromRGB(180, 175, 170)
        btn.Text = "Auto Steal (自動卵回収) : OFF"
    end
end)

-- =================================================================
-- 🚀 2. 移植箇所：ChilliHub直系 卵認識オブジェクト検索＆回収エンジン
-- =================================================================

-- ChilliHubの参照パスを完全再現し、卵のコンテナフォルダを特定する関数
local function getChilliHubEggContainer()
    local map = Workspace:FindFirstChild("Map")
    if map and map:FindFirstChild("Eggs") then
        return map.Eggs
    end
    return Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("SpawnedEggs") or Workspace
end

task.spawn(function()
    while true do
        task.wait(0.12) -- ChilliHub最適化ディレイ速度
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local eggContainer = getChilliHubEggContainer()
                -- コンテナ内の子要素のみを処理することでDeltaの処理落ちを防止
                local eggList = (eggContainer == Workspace) and Workspace:GetDescendants() or eggContainer:GetChildren()

                for _, eggObject in ipairs(eggList) do
                    if Options.AutoSteal == false then break end

                    -- ChilliHub仕様：モデル構造や個別パーツから正規のターゲットおよびタッチ判定を精密スキャン
                    local mainPart = eggObject:IsA("BasePart") and eggObject or eggObject:FindFirstChildOfClass("BasePart")
                    local touchInterest = eggObject:FindFirstChildOfClass("TouchTransmitter") 
                        or eggObject:FindFirstChild("TouchInterest") 
                        or (mainPart and mainPart:FindFirstChildOfClass("TouchTransmitter"))

                    if touchInterest and mainPart then
                        -- アンチ距離チェックを欺くために卵の真上（CFrame）に一瞬で物理同期
                        root.CFrame = mainPart.CFrame + Vector3.new(0, 1.5, 0)
                        task.wait(0.04) -- サーバー側との接触ラグを処理する極小ディレイ
                        
                        -- ChilliHub方式：触れた信号（0）と離れた信号（1）を正確に送りつけて卵を回収
                        firetouchinterest(root, touchInterest, 0)
                        firetouchinterest(root, touchInterest, 1)
                    end
                end
            end)
        end
    end
end)

-- ChilliHubプロテクト：ゲーム側の不正検知バッファ（AC_ThreatLogs）を常時初期化
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
