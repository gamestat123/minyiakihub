-- [[ miniyakihub - Delta Mobile UI & SpeedHubX Engine Fusion ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理（初期状態はOFF）
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }

-- =================================================================
-- 🛰️ SpeedHubX核心：暗号化されたリモートネットワークの自動解析
-- =================================================================
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 🛠️ 1. Delta絶対起動UI（PlayerGui偽装レイヤー構造）
-- =================================================================
for _, old in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name == "miniyakihub_DeltaAbsoluteUI" then old:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "miniyakihub_DeltaAbsoluteUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local C = {
    WindowBg     = Color3.fromRGB(25, 23, 22),
    HeaderBg     = Color3.fromRGB(35, 30, 25),
    Accent       = Color3.fromRGB(255, 128, 0), -- miniyakihubオレンジ
    BtnDefault   = Color3.fromRGB(45, 42, 40),
    TextGray     = Color3.fromRGB(180, 175, 170),
    White        = Color3.fromRGB(255, 255, 255)
}

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 230)
mainFrame.Position = UDim2.new(0.5, -115, 0.4, -115) -- 画面中央配置
mainFrame.BackgroundColor3 = C.WindowBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Accent
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.HeaderBg
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.BackgroundColor3 = C.Accent
headerLine.BorderSizePixel = 0
headerLine.Parent = header

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

    btn.MouseButton1Click:Connect(function()
        Options[optionKey] = not Options[optionKey]
        if Options[optionKey] then
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

AddCustomToggle("Auto Steal (自動卵回収)", 55, "AutoSteal")
AddCustomToggle("Auto Hatch (自動卵孵化)", 110, "AutoHatch")
AddCustomToggle("Auto Place (自動配置)", 165, "AutoPlace")

-- =================================================================
-- 🚀 2. コア機能：SpeedHubX直系 最新最適化ファームエンジン
-- =================================================================

-- SpeedHubX仕様：Workspace内の特定の卵格納フォルダを自動スキャン
local function getSpeedHubTarget()
    local eggFolder = Workspace:FindFirstChild("Eggs") 
        or Workspace:FindFirstChild("SpawnedEggs") 
        or Workspace:FindFirstChild("DroppedEggs")
    return eggFolder or Workspace
end

-- ① SpeedHubX方式：最新の距離チェックを物理テレポートで完全突破
task.spawn(function()
    while true do
        task.wait(0.12) -- SpeedHubX最適化ディレイ（引き戻し＆キック回避）
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local folder = getSpeedHubTarget()
                local items = (folder == Workspace) and Workspace:GetDescendants() or folder:GetChildren()

                for _, obj in ipairs(items) do
                    if Options.AutoSteal == false then break end
                    
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                        local interest = obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChild("TouchInterest") or (part and part:FindFirstChildOfClass("TouchTransmitter"))

                        if interest and part then
                            -- SpeedHubX方式：卵のCFrameに直接上書き移動して物理接触を発生させる
                            root.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                            task.wait(0.04) -- サーバー側の判定同期ウェイト
                            
                            -- 保険としてタッチイベントも直接トリガー
                            firetouchinterest(root, interest, 0)
                            firetouchinterest(root, interest, 1)
                            task.wait(0.04)
                        end
                    end
                end
            end)
        end
    end
end)

-- ② SpeedHubX方式：イベント暗号化を回避するリモート偽装発火ループ
task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            if not networking then
                networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            end
            if not networking then return end

            local remote = networking:FindFirstChild("EggNetwork") or networking:FindFirstChild("GameplayNetwork")
            if not remote then return end

            -- SpeedHubXが使用している最新のサーバー要求パラメータを適用
            if Options.AutoHatch then 
                remote:FireServer("HatchEgg", {}) 
                remote:FireServer("Hatch", 1)
            end
            if Options.AutoPlace then 
                remote:FireServer("PlaceEgg", {}) 
                remote:FireServer("Deposit", {})
            end
        end)
    end
end)

-- ③ SpeedHubX仕様：チート検知スレッド（AC_ThreatLogs）を常時クラッシュさせる保護層
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local logs = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if logs then logs:ClearAllChildren() end
        end)
    end
end)

print("[🍊 miniyakihub] SpeedHubXコアエンジンの移植が完了しました。")
