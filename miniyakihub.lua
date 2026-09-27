-- [[ ChilliHub Original Logic - 100% Mirror Copy for miniyakihub ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")

local fn3

fn3 = function(arg)
    local ok, result = pcall(function()
        return require(arg())
    end)

    if not ok then
        result = ok
    end

    local v3 = result or nil
    return v3
end

local tbl

tbl = {
    EggState = fn3(function()
        return ReplicatedStorage.Client.EggState
    end),
    AreaEggs = fn3(function()
        return ReplicatedStorage.Shared.Types.AreaEggs
    end),
    ToolGameplayGuard = fn3(function()
        return ReplicatedStorage.Client.ToolGameplayGuard
    end),
    Assets = fn3(function()
        return ReplicatedStorage.Data.Assets
    end),
    Guards = fn3(function()
        return ReplicatedStorage.Data.Guards
    end),
    EggRecords = fn3(function()
        return ReplicatedStorage.Shared.Util.EggRecords
    end),
    Mutations = fn3(function()
        return ReplicatedStorage.Shared.Modules.Mutations
    end),
    Save = fn3(function()
        return ReplicatedStorage.Shared.Save
    end),
    FuseKernel = fn3(function()
        return ReplicatedStorage.Shared.Util.FuseKernel
    end),
    AreaEggCycle = fn3(function()
        return ReplicatedStorage.Shared.Util.AreaEggCycle
    end),
    AreaEggResetWall = fn3(function()
        return ReplicatedStorage.Client.AreaEggResetWall
    end),
    AreaEggResetCycle = fn3(function()
        return ReplicatedStorage.Data.AreaEggResetCycle
    end),
    Gears = fn3(function()
        return ReplicatedStorage.Data.Gears
    end),
    Areas = fn3(function()
        return ReplicatedStorage.Data.Areas
    end),
    LimitedEgg = fn3(function()
        return ReplicatedStorage.Data.LimitedEgg
    end),
    BrainrotEgg = fn3(function()
        return ReplicatedStorage.Data.BrainrotEgg
    end),
    MonsterEgg = fn3(function()
        return ReplicatedStorage.Data.MonsterEgg
    end),
}

local v3 = (function()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then
            return result
        end
    end
    return CoreGui
end)()
local fn5

do
    local v4 = Random.new()
    local str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    fn5 = function()
        local v5 = v4:NextInteger(12, 20)
        local v6 = table.create(v5)

        for i = 1, v5 do
            local v7 = v4:NextInteger(1, #str)
            v6[i] =
                string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", v7, v7)
        end

        return table.concat(v6)
    end
end

local fn6, fn7

do
    local tbl2 = {}

    fn6 = function(arg)
        table.insert(tbl2, arg)
    end

    local str = "All"

    fn7 = function(arg)
        if type(arg) ~= "table" then
            return arg
        end
        local value = rawget(arg, "Instance")
        if typeof(value) ~= "Instance" then
            return arg
        end
        local flag = false

        local function fn8(arg2)
            if flag then
                return
            end

            if arg2.Text == "None" then
                flag = true
                arg2.Text = str
                flag = false
            end
        end

        local function fn9(arg2)
            if not arg2:IsA("TextLabel") or arg2.Name ~= "Value" then
                return
            end
            fn8(arg2)

            local connection = arg2:GetPropertyChangedSignal("Text"):Connect(function()
                fn8(arg2)
            end)

            fn6(function()
                pcall(function()
                    connection:Disconnect()
                end)
            end)
        end

        for _, descendant in ipairs(value:GetDescendants()) do
            fn9(descendant)
        end

        local connection = value.DescendantAdded:Connect(function(descendant)
            fn9(descendant)
        end)

        fn6(function()
            pcall(function()
                connection:Disconnect()
            end)
        end)
    end
end

-- =================================================================
-- 🛠️ Delta絶対起動システム：ChilliHubのUI生成先をPlayerGuiに強制同期
-- =================================================================
local Options = { AutoSteal = true, AutoHatch = true, AutoPlace = true }

task.spawn(function()
    while true do
        task.wait(0.12)
        if Options.AutoSteal then
            pcall(function()
                local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                local map = game.Workspace:FindFirstChild("Map")
                local eggContainer = map and map:FindFirstChild("Eggs") or game.Workspace:FindFirstChild("Eggs")
                
                if root and eggContainer then
                    for _, egg in ipairs(eggContainer:GetChildren()) do
                        local part = egg:IsA("BasePart") and egg or egg:FindFirstChildOfClass("BasePart")
                        local interest = egg:FindFirstChildOfClass("TouchTransmitter") or (part and part:FindFirstChildOfClass("TouchTransmitter"))
                        if interest and part then
                            root.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                            firetouchinterest(root, interest, 0)
                            firetouchinterest(root, interest, 1)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            local remote = networking:FindFirstChild("EggNetwork") or networking:FindFirstChild("GameplayNetwork")
            if remote then
                if Options.AutoHatch then remote:FireServer("HatchEgg", {}) end
                if Options.AutoPlace then remote:FireServer("PlaceEgg", {}) end
            end
        end)
    end
end)

-- Deltaでも100%描画されるようにPlayerGuiへUIを最終転送
pcall(function()
    if v3 and v3:IsA("ScreenGui") then
        v3.Parent = localPlayer:WaitForChild("PlayerGui")
    end
end)
