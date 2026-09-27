-- [[ miniyakihub - Delta Absolute Egg Recognition Fix ]]
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

-- メインウィンドウ
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
mainStroke.Color = Color3.fromRGB(255, 128, 0) -- miniyakihubオレンジ
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

-- トグルボタン
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
-- 2. 核心：名前を完全無視して『マップ上の動く・触れるもの』全てにテレポートするループ
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.05) -- スキャン速度を極限まで引き上げ
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- マップ全体（Workspace）を力押しで全検索
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if Options.AutoSteal == false then break end

                    -- 「自分自身」「他のプレイヤーの体」「地面などの巨大マップパーツ」を徹底的に除外するセーフティ
                    if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and not obj.Parent:FindFirstChild("Humanoid") and obj.Size.Magnitude < 25 then
                        
                        -- 卵フォルダ内、もしくは何らかのタッチ判定を持っているか、モデルの一部である場合
                        if string.find(string.lower(obj.Parent.Name), "egg") 
                        or obj:FindFirstChildOfClass("TouchTransmitter") 
                        or obj.Parent:FindFirstChildOfClass("TouchTransmitter")
                        or obj:GetAttribute("Egg") == true then
                            
                            -- 【究極の力押し】名前認識をスルーしてパーツの「真芯」に0.02秒だけテレポート
                            root.CFrame = obj.CFrame
                            
                            -- 接触信号も同時に全発火
                            local transmitter = obj:FindFirstChildOfClass("TouchTransmitter") or obj.Parent:FindFirstChildOfClass("TouchTransmitter")
                            if transmitter then
                                firetouchinterest(root, transmitter, 0)
                                firetouchinterest(root, transmitter, 1)
                            end
                            
                            task.wait(0.04) -- サーバーが卵の消失を同期するまでの最小ウェイト
                        end
                    end
                end
            end)
        end
    end
end)

-- アンチチート（ThreatLogs）の常時抹消
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local acLog = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if acLog then acLog:ClearAllChildren() end
        end)
    end
end)
