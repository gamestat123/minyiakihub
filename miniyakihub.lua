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

-- 3. 自動化のON/OFF変数（頭の local を削除してグローバル化）
_G.AutoSteal = false 

-- 「PlayerTab」に対してトグルを作成するように修正
local Toggle = PlayerTab:CreateToggle({
   Name = "Auto Steal Eggs",
   CurrentValue = false,
   Flag = "ToggleAutoSteal", 
   Callback = function(Value)
      _G.AutoSteal = Value 

      if _G.AutoSteal == true then
         task.spawn(function()
            while _G.AutoSteal == true do
               
               -- 💡 ここに「Steal an Egg」用の具体的な卵泥棒コードを挟みます
               print("卵を自動で盗んでいます...") 

               task.wait(1) 
            end
         end)
      end
   end,
})
