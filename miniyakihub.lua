local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "minyaki HUB",
   Icon = 0,
   LoadingTitle = "minyaki HUB",
   LoadingSubtitle = "inyaki HUB",
   ShowText = "inyaki HUB",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "minyaki_hub_save", -- nilから独自のフォルダ名に変更（エラー防止）
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false -- 不要であれば設定テーブルを無理に書かなくても大丈夫です
})

-- 1. タブを作成（変数名は PlayerTab ）
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- 2. スピード変更スライダー
local Slider = PlayerTab:CreateSlider({
   Name = "speed",
   Range = {0, 100},
   Increment = 10,
   Suffix = "speed",
   CurrentValue = 10,
   Flag = "Slider1", 
   Callback = function(Value)
      -- 大文字の「Players」に修正
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Toggle Example",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- 💡 Tweenを使った滑らかな高速移動のサンプル
local TweenService = game:GetService("TweenService")
local character = game.Players.LocalPlayer.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

if rootPart then
    local targetPosition = Vector3.new(100, 10, 50) -- 目的地の座標
    local distance = (rootPart.Position - targetPosition).Magnitude
    local speed = 50 -- 秒速50スタッド（アンチチートに引っかからない限界の速さに調整可能）
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait() -- 移動が終わるまで待つ
end

   end,
})
