local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "minyaki HUB",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "minyaki HUB",
   LoadingSubtitle = "inyaki HUB",
   ShowText = "inyaki HUB", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458) -- Title, Image

local Slider = PlayerTab:CreateSlider({
   Name = "speed",
   Range = {0, 100},
   Increment = 10,
   Suffix = "speed",
   CurrentValue = 10,
   Flag = "Slider1", 
   Callback = function(Value)
  game.players.LocalPlayer.Character.Humanoid.WalkSpeed = Value

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
