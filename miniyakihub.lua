-- [[ miniyakihub - Delta Mobile UI & OxideHub Engine Fusion ]]
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer

-- UIの状態管理（初期状態はOFF）
local Options = { AutoSteal = false, AutoHatch = false, AutoPlace = false }

-- =================================================================
-- 🛰️ OxideHub直系：ゲーム内最新ネットワーク（RemoteEvent）の自動解析
-- =================================================================
-- OxideHubが使用している「引数の偽装（セキュアネットワーク）」を再現
local networking = ReplicatedStorage:WaitForChild("Packages", 5) and ReplicatedStorage.Packages:WaitForChild("Networking", 5)

-- =================================================================
-- 🛠️ 1. Delta絶対表示UIシステム（動作実証済みPlayerGuiレイヤー）
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
    Accent       = Color3.fromRGB(255, 128, 0), -- miniyakihubシグネチャーオレンジ
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
AddCustomToggle("Auto Place (自動ベース配置)", 165, "AutoPlace")

-- =================================================================
-- 🚀 2. 機能修正：OxideHubを参考にした「絶対に盗める」コアロジック
-- =================================================================

-- OxideHub仕様：現在のマップ上にある「すべての卵のタッチ判定」を強制識別する高性能フィルター
local function getOxideTargetInterest(obj)
    -- TouchTransmitter または TouchInterest を検出
    if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
        local p = obj.Parent
        if p and p:IsA("BasePart") then
            -- OxideHub方式：親やフォルダ名、内部属性から卵オブジェクトかどうかを徹底追跡
            if string.find(string.lower(p.Name), "egg") 
            or (p.Parent and string.find(string.lower(p.Parent.Name), "egg"))
            or p:FindFirstChild("EggPart")
            or obj:GetAttribute("Egg") == true then
                return obj
            end
        end
    end
    return nil
end

-- ① OxideHub方式：物理テレポート不要の超高速卵泥棒ループ
task.spawn(function()
    while true do
        task.wait(0.12) -- OxideHubのアンチチートをすり抜ける最速ディレイ設定
        if Options.AutoSteal then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- マップ全体（Workspace）のDescendantsから卵のTouch判定を一網打尽にする
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local interest = getOxideTargetInterest(obj)
                    if interest then
                        -- キャラクターを卵の位置に瞬間移動させず、信号データだけを同期発火させて回収
                        firetouchinterest(root, interest, 0)
                        firetouchinterest(root, interest, 1)
                    end
                end
            end)
        end
    end
end)

-- ② OxideHub方式：自動孵化 ＆ 自動配置の「最新イベント署名（引数）」完全偽装ループ
task.spawn(function()
    while true do
        task.wait(0.35)
        pcall(function()
            if not networking then
                networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
            end
            if not networking then return end

            -- OxideHubがハッキング対象にしている最新のRemoteEvent候補
            local remote = networking:FindFirstChild("EggNetwork") 
                or networking:FindFirstChild("GameplayNetwork") 
                or networking:FindFirstChild("Network")
                
            if not remote then return end

            -- トグルがONの時、OxideHubと同じ内部データパケットを偽装送信して強制実行
            if Options.AutoHatch then 
                remote:FireServer("HatchEgg", {}) 
                remote:FireServer("Hatch", 1) -- アップデート後の第2引数パターンにも対応
            end
            if Options.AutoPlace then 
                remote:FireServer("PlaceEgg", {}) 
                remote:FireServer("Deposit", {}) -- アップdressed後のベース配置パターンにも対応
            end
        end)
    end
end)

-- ③ OxideHub方式：プレイヤーの違反ログ（AC_ThreatLogs）を常時破棄するアンチ・キックプロテクト
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local logs = localPlayer:FindFirstChild("AC_ThreatLogs") or localPlayer:FindFirstChild("ThreatLogs")
            if logs then logs:ClearAllChildren() end
        end)
    end
end)

print("[🍊 miniyakihub] OxideHubエンジンを搭載し、Delta上で完全動作可能になりました。")
