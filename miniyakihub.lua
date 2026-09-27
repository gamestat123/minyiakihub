local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "minyaki HUB | Steal an Egg",
   Icon = 0,
   LoadingTitle = "minyaki HUB",
   LoadingSubtitle = "for Steal an Egg",
   ShowText = "minyaki HUB",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "minyaki_steal_an_egg", -- 専用の保存フォルダ
      FileName = "Config"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false
})

-- ==========================================
-- タブの作成
-- ==========================================
local MainTab = Window:CreateTab("Main (メイン機能)", 4483362458)
local PlayerTab = Window:CreateTab("Player (プレイヤー設定)", 4483362458)

-- ==========================================
-- Mainタブの機能 (ゲーム内自動化の枠組み)
-- ==========================================
MainTab:CreateSection("Auto Farm")

-- 自動で卵を盗むトグル (ON/OFF)
local AutoSteal = false
MainTab:CreateToggle({
   Name = "Auto Steal Eggs (自動で卵を盗む)",
   CurrentValue = false,
   Flag = "ToggleAutoSteal",
   Callback = function(Value)
      AutoSteal = Value
      -- 💡 ここに自動で卵の場所にテレポート/回収するループ処理を書き込みます
      task.spawn(function()
         while AutoSteal do
            print("自動卵盗み機能が作動中...")
            task.wait(1)
         end
      end)
   end,
})

-- 自動でトレッドミル(マシン)で走るトグル
local AutoTrain = false
MainTab:CreateToggle({
   Name = "Auto Train Speed (自動でスピード訓練)",
   CurrentValue = false,
   Flag = "ToggleAutoTrain",
   Callback = function(Value)
      AutoTrain = Value
      -- 💡 ここにトレッドミルに触れる、または訓練リモートを呼び出す処理を書き込みます
      task.spawn(function()
         while AutoTrain do
            print("自動スピード訓練中...")
            task.wait(1)
         end
      end)
   end,
})

-- ==========================================
-- Playerタブの機能 (キャラ能力の変更)
-- ==========================================
PlayerTab:CreateSection("Character Mod")

-- 歩行速度変更スライダー
PlayerTab:CreateSlider({
   Name = "WalkSpeed (移動速度)",
   Increment = 1,
   Max = 200,
   Min = 16,
   CurrentValue = 16,
   Flag = "SliderWalkSpeed",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- ジャンプ力変更スライダー
PlayerTab:CreateSlider({
   Name = "JumpPower (ジャンプ力)",
   Increment = 1,
   Max = 300,
   Min = 50,
   CurrentValue = 50,
   Flag = "SliderJumpPower",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

Rayfield:Notify({
   Title = "minyaki HUB",
   Content = "正常にスクリプトが読み込まれました！",
   Duration = 5,
   Image = 4483362458,
})
