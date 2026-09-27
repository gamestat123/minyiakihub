-- [[ miniyakihub - Delta Absolute Fixed Recovery Engine ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理（初期状態はOFF）
local Options = { AutoSteal = false }

-- =================================================================
-- 1. Delta専用：UI強制表示（PlayerGui配置 ＆ 画面中央固定）
-- =================================================================
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaAbsoluteUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaAbsoluteUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

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
-- 2. コア機能：名前を無視して『タッチ判定』に直接密着する超高速追従システム
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.01) -- Deltaの限界速度でループ
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- マップ上のすべての「触れる判定」を強制取得（名前がeggでなくても検知）
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if Options.AutoSteal == false then break end

                    -- タッチセンサー（TouchTransmitter）を持つパーツをピンポイント特定
                    if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local eggPart = obj.Parent
                        
                        -- 自分のベース（Home）の判定や自分自身のパーツは除外するセーフティ
                        if not eggPart:IsDescendantOf(char) and not string.find(string.lower(eggPart.Name), "base") and not string.find(string.lower(eggPart.Name), "pad") then
                            
                            -- 【最強の修正点】名前に関係なく、ターゲットの「真上」に強制座標同期
                            root.CFrame = eggPart.CFrame + Vector3.new(0, 1, 0)
                            
                            -- 物理接触が起きてもアンチチートで弾かれないよう、信号も同時に撃ち込む
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                            
                            task.wait(0.08) -- サーバーが「回収完了」を処理するまでの最小待機
                        end
                    end
                end
            end)
        end
    end
end)

-- アンチチート（ThreatLogs）の自動消去（キック防止）
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
