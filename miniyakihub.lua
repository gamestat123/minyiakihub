-- [[ miniyakihub - Delta Mobile Safe Path Farm Working ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer      = Players.LocalPlayer

-- 自動化の状態管理（初期状態はOFF）
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
-- 2. コア機能：ブロック不可能な「爆速物理走行回収」システム
-- =================================================================
-- ゲームが卵を格納している専用フォルダの自動特定
local function getValidEggFolder()
    return Workspace:FindFirstChild("Eggs") 
        or Workspace:FindFirstChild("SpawnedEggs") 
        or Workspace:FindFirstChild("DroppedEggs")
        or Workspace
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end

                -- 【アンチチート突破】キャラの走るスピードをブロックされない安全な超高速（例: 80）に固定
                humanoid.WalkSpeed = 80

                local folder = getValidEggFolder()
                local eggs = (folder == Workspace) and Workspace:GetDescendants() or folder:GetChildren()

                for _, egg in ipairs(eggs) do
                    if Options.AutoSteal == false then break end

                    -- 卵の本体パーツを取得
                    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildOfClass("BasePart")
                    if eggPart and (string.find(string.lower(egg.Name), "egg") or string.find(string.lower(eggPart.Name), "egg") or egg:FindFirstChildOfClass("TouchTransmitter")) then
                        
                        -- 卵がまだマップに存在し、触れる状態か確認
                        if eggPart.Parent and (eggPart:FindFirstChildOfClass("TouchTransmitter") or egg:FindFirstChildOfClass("TouchTransmitter")) then
                            
                            -- 【最強の回避策】Roblox公式のパス移動を使い、卵の座標まで爆速でキャラを物理的に走らせる
                            humanoid:MoveTo(eggPart.Position)
                            
                            -- 卵に接触して消えるまで、最大で1秒間だけ待機（引っかかり防止）
                            local count = 0
                            while eggPart.Parent and eggPart:FindFirstChildOfClass("TouchTransmitter") and count < 10 do
                                task.wait(0.1)
                                count = count + 1
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- スイッチOFF時に速度を通常（16）に戻すセーフティスレッド
task.spawn(function()
    while task.wait(0.5) do
        if not Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end)
        end
    end
end)
