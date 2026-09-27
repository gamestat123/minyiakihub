-- [[ miniyakihub - Delta Mobile UI & Real Farm Working ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer      = Players.LocalPlayer

-- 自動化の状態管理（初期状態はOFF）
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
screenGui.Parent = localPlayer:WaitForChild("PlayerGui") -- Deltaで100%出る親

-- メインウィンドウ（オレンジ仕様）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -55) -- モバイル画面の中央に配置
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- タップドラッグ移動対応
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 128, 0) -- 鮮やかなオレンジ
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
        btn.BackgroundColor3 = Color3.fromRGB(255, 128, 0) -- ONでオレンジ化
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "Auto Steal (自動卵回収) : ON"
    else
        btn.BackgroundColor3 = Color3.fromRGB(45, 42, 40)
        btn.TextColor3 = Color3.fromRGB(180, 175, 170)
        btn.Text = "Auto Steal (自動卵回収) : OFF"
    end
end)

-- =================================================================
-- 2. コア機能：本当に卵が吸い込まれる自動ファーム（Dice&Oxideロジック）
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.15)
        if Options.AutoSteal then
            pcall(function()
                local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- マップ上のすべてのオブジェクトからタッチ判定をスキャン
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
                        local parentPart = obj.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            local pName = string.lower(parentPart.Name)
                            
                            -- 最新の卵のネームスペース（egg/spawn/pickup）を狙い撃ち
                            if string.find(pName, "egg") or string.find(pName, "spawn") or string.find(pName, "pickup") or obj:GetAttribute("Egg") == true then
                                -- テレポートせずに信号だけを一瞬で送り、卵を自分のインベントリに吸い込む
                                firetouchinterest(root, obj, 0)
                                firetouchinterest(root, obj, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- アンチチート（ThreatLogs）の自動消去（キック防止）
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
