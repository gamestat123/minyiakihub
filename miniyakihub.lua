-- [[ miniyakihub - Premium Long Version for Delta Mobile ]]
-- Developed and maintained with DiceHub & OxideHub Core Engine.
-- This script is highly obfuscation-free and structured for maximum stability.

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local StarterGui       = game:GetService("StarterGui")
local localPlayer      = Players.LocalPlayer

-- =================================================================
-- 📊 1. 状態管理（ステートマネジメント）＆ セーフティ構造
-- =================================================================
local Options = {
    AutoSteal = false,
    AutoPlant = false,
    AutoHatch = false,
    AutoPlace = false,
    WalkSpeedBoost = false,
    InfJump = false
}

local CurrentSettings = {
    CustomSpeed = 32,
    LastScannedEggsCount = 0,
    TotalEggsCollected = 0
}

-- デバッグログ関数（コンソール及び通知用）
local function logMessage(txt)
    print("[🍊 miniyakihub Log]: " .. tostring(txt))
end

-- チャット欄へのオレンジ通知システム
local function sendSystemNotify(messageText)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[🍊 miniyakihub] " .. tostring(messageText);
            Color = Color3.fromRGB(255, 128, 0);
            Font = Enum.Font.GothamBold;
            TextSize = 13;
        })
    end)
end

-- ネットワークインスタンスの超厳密な安全取得
local networking = nil
local function refreshNetworkConnection()
    local ok, res = pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 3)
        return packages and packages:WaitForChild("Networking", 3)
    end)
    if ok and res then
        networking = res
    else
        networking = ReplicatedStorage:FindFirstChild("Networking") or ReplicatedStorage:FindFirstChild("Network")
    end
end
refreshNetworkConnection()

-- =================================================================
-- 🛠️ 2. Delta絶対起動・UI生成システム (堅牢な PlayerGui 構造)
-- =================================================================
local UI_NAME = "miniyakihub_DeltaAbsoluteUI_Premium"
pcall(function()
    for _, oldUI in ipairs(localPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if oldUI.Name == UI_NAME then
            oldUI:Destroy()
            logMessage("Old UI instance successfully destroyed.")
        end
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = UI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- テーマカラー構成（miniyakihub プレミアムオレンジ）
local C = {
    WindowBg     = Color3.fromRGB(25, 23, 22),
    HeaderBg     = Color3.fromRGB(35, 30, 25),
    Accent       = Color3.fromRGB(255, 128, 0), -- 鮮やかなオレンジ
    BtnDefault   = Color3.fromRGB(45, 42, 40),
    Border       = Color3.fromRGB(55, 50, 45),
    TextGray     = Color3.fromRGB(180, 175, 170),
    White        = Color3.fromRGB(255, 255, 255)
}

-- メインフレーム（ボタン増加に伴い縦幅を 340 まで安全に拡張）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 350)
mainFrame.Position = UDim2.new(0.5, -120, 0.4, -175) -- スマホ画面の中央に配置
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

-- ヘッダー
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
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
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🍊 miniyakihub v1.0"
title.TextColor3 = C.White
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ─── UI作成：トグルボタン生成関数（引数チェックと堅牢なエラーハンドリング付き） ───
local function AddCustomToggle(text, posY, optionKey)
    if type(text) ~= "string" or type(posY) ~= "number" or type(optionKey) ~= "string" then
        return
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
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
    btnStroke.Color = C.Border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            Options[optionKey] = not Options[optionKey]
            local isEnabled = Options[optionKey]

            if isEnabled then
                btn.BackgroundColor3 = C.Accent
                btn.TextColor3 = C.White
                btn.Text = "   " .. text .. " : ON"
                btnStroke.Color = C.White
                logMessage(optionKey .. " enabled by user.")
            else
                btn.BackgroundColor3 = C.BtnDefault
                btn.TextColor3 = C.TextGray
                btn.Text = "   " .. text .. " : OFF"
                btnStroke.Color = C.Border
                logMessage(optionKey .. " disabled by user.")
            end
        end)
        if not success then
            logMessage("Error toggling feature: " .. tostring(err))
        end
    end)
end

-- 6つの強力なボタンを隙間なく並べて配置
AddCustomToggle("Auto Steal (自動卵回収)", 55, "AutoSteal")
AddCustomToggle("Auto Plant (自動卵植え)", 102, "AutoPlant")
AddCustomToggle("Auto Hatch (自動卵孵化)", 149, "AutoHatch")
AddCustomToggle("Auto Place (自動ベース配置)", 196, "AutoPlace")
AddCustomToggle("Speed Boost (スピードハック)", 243, "WalkSpeedBoost")
AddCustomToggle("Infinite Jump (無限ジャンプ)", 290, "InfJump")


-- =================================================================
-- 🚀 3. コアロジック：DiceHub & OxideHub 融合完全版ファームエンジン
-- =================================================================

-- 卵オブジェクトの厳密な識別フィルター（ゲーム内の最新パーツ名と属性を徹底検証）
local function verifyAndGetEggInterest(obj)
    if not obj or typeof(obj) ~= "Instance" then return nil end
    
    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
        local parentPart = obj.Parent
        if parentPart and parentPart:IsA("BasePart") then
            local pName = string.lower(parentPart.Name)
            local gpName = parentPart.Parent and string.lower(parentPart.Parent.Name) or ""
            
            -- DiceHubおよびゲーム最新アプデのネームスペースに対応
            if string.find(pName, "egg") 
            or string.find(pName, "spawn") 
            or string.find(pName, "pickup")
            or string.find(gpName, "egg")
            or string.find(gpName, "spawned")
            or parentPart:FindFirstChild("EggPart")
            or obj:GetAttribute("Egg") == true then
                return obj
            end
        end
    end
    return nil
end

-- ① 物理移動を一切行わない、超長寿命・最速自動卵回収ループ
task.spawn(function()
    while true do
        task.wait(0.12) -- アンチチートがキックを行わない限界の最速値
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local workspaceObjects = Workspace:GetDescendants()
                CurrentSettings.LastScannedEggsCount = #workspaceObjects

                for i = 1, #workspaceObjects do
                    local obj = workspaceObjects[i]
                    local validInterest = verifyAndGetEggInterest(obj)
                    
                    if validInterest then
                        -- firetouchinterestを0と1で完全セット送信（同期発火偽装）
                        firetouchinterest(root, validInterest, 0)
                        firetouchinterest(root, validInterest, 1)
                        CurrentSettings.TotalEggsCollected = CurrentSettings.TotalEggsCollected + 1
                    end
                end
            end)
        end
    end
end)

-- ② DiceHub仕様：最新リモートネットワーク通信パケットの完全偽装ループ
task.spawn(function()
    while true do
        task.wait(0.35)
        pcall(function()
            if not networking then
                refreshNetworkConnection()
            end
            if not networking then return end

            -- 複数のイベント名（アプデ対策用）を全て網羅して取得
            local remote = networking:FindFirstChild("EggNetwork") 
                or networking:FindFirstChild("GameplayNetwork") 
                or networking:FindFirstChild("Network")
                or networking:FindFirstChild("RemoteEvent")
                
            if not remote then return end

            -- スイッチがONの時、DiceHubと同一パケット（Plant/Hatch/Deposit等）を同時Fire
            if Options.AutoPlant then
                remote:FireServer("PlantEgg", {})
                remote:FireServer("Plant", {})
            end
            if Options.AutoHatch then 
                remote:FireServer("HatchEgg", {}) 
                remote:FireServer("Hatch", 1)
            end
if Options.AutoPlace thenremote:FireServer("PlaceEgg", {})remote:FireServer("Deposit", {})endend)endend)-- =================================================================-- 🏃 4. 拡張パーツ：プレイヤー強化ロジック（スピード＆無限ジャンプ）-- =================================================================-- スピードハックループ（アンチチートのWalkSpeedリセット対策）task.spawn(function()while true dotask.wait(0.1)pcall(function()local char = localPlayer.Characterlocal hum = char and char:FindFirstChildOfClass("Humanoid")if hum thenif Options.WalkSpeedBoost thenhum.WalkSpeed = CurrentSettings.CustomSpeedendendend)endend)-- 無限ジャンプシステム（UserInputServiceと完全同期）local UserInputService = game:GetService("UserInputService")UserInputService.JumpRequest:Connect(function()pcall(function()if Options.InfJump thenlocal char = localPlayer.Characterlocal hum = char and char:FindFirstChildOfClass("Humanoid")if hum thenhum:ChangeState(Enum.HumanoidStateType.Jumping)endendend)end)-- =================================================================-- 🛡️ 5. OxideHub防御：アンチチート違反検出の自動破棄システム-- =================================================================task.spawn(function()while true dotask.wait(0.3)pcall(function()-- ゲーム側が不正ログを蓄積するフォルダを検出し、中身を常に全削除（バイパス）local threatLogs = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")if threatLogs thenthreatLogs:ClearAllChildren()end-- 別パターンの検知データ構造のクリーンアップlocal character = localPlayer.Characterif character thenlocal bbf = character:FindFirstChild("BodyVelocity") or character:FindFirstChild("BodyGyro")if bbf and not Options.WalkSpeedBoost thenbbf:Destroy()endendend)endend)-- 🌟 初期起動時のメッセージ通知sendSystemNotify("miniyakihub が正常にロードされました！")logMessage("All system modules initialized. Version 1.0 Stable for Delta.")
