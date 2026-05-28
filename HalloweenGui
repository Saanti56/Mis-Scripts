--[[
    Zovlane Hub
    Enhanced MM2 Script with Comprehensive Features!
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Auto-load utilities
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/n9owns/Files/refs/heads/main/antiafk",true))()
    end)
end)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Default Color Theme
local DefaultColors = {
    Red = Color3.fromRGB(220, 20, 60),
    DarkRed = Color3.fromRGB(139, 0, 0),
    Green = Color3.fromRGB(34, 139, 34),
    DarkGreen = Color3.fromRGB(0, 100, 0),
    Gold = Color3.fromRGB(255, 215, 0),
    White = Color3.fromRGB(255, 255, 255),
    Blue = Color3.fromRGB(30, 144, 255),
    Silver = Color3.fromRGB(192, 192, 192),
    Gray = Color3.fromRGB(128, 128, 128),
}

-- Simple text function (no gradient)
local function simpleText(text)
    return text
end

-- Welcome Popup
local Confirmed = false
WindUI:Popup({
    Title = "Zovlane Hub",
    Icon = "zap",
    Content = "Best MM2 Script!<br/>Join our discord server! Daily Giveaways",
    Buttons = {
        {
            Title = "Exit",
            Callback = function() end,
            Variant = "Tertiary"
        },
        {
            Title = "Copy Discord",
            Callback = function()
                setclipboard("https://discord.gg/8EcCWNXSnS")
                WindUI:Notify({ 
                    Title = "Discord Copied!", 
                    Content = "Discord invite copied to clipboard!", 
                    Icon = "check-circle", 
                    Duration = 3 
                })
                Confirmed = true
            end,
            Variant = "Secondary"
        },
        {
            Title = "Continue",
            Callback = function()
                Confirmed = true
            end,
            Variant = "Primary"
        }
    }
})

repeat task.wait() until Confirmed

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "Zovlane Hub",
    Author = "by Zovlane Scripts",
    Folder = "zovlanehub",
    Icon = "zap",
    NewElements = true,
    
    Size = UDim2.new(0, 580, 0, 480),
    
    Transparent = true,
    BackgroundTransparency = 0.5,
    
    Theme = "Dark",
    SideBarWidth = 220,
    
    HideSearchBar = false,
    ScrollBarEnabled = true,
    
    OpenButton = {
        Title = "Open Zovlane Hub",
        CornerRadius = UDim.new(0.5, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new(
            DefaultColors.Blue, 
            DefaultColors.Green
        )
    },
    
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

-- Auto Farm Variables
local autoFarmCoins = false
local autoEndRound = false
local flingMurdererOnFull = false
local autoFlingMurderer = false
local visitedPositions = {}
local flySpeed = 25
local collected = 0
local currentBagAmount = 0
local maxBagCapacity = 40
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Improved Auto Farm System Variables
local farming = false
local bag_full = false
local resetting = false
local start_position = nil
local farmingCoins = false

-- Check for premium gamepass
local MarketplaceService = game:GetService("MarketplaceService")
local GAMEPASS_ID = 429957 -- Premium gamepass ID

local function checkPremiumStatus()
    local success, hasGamepass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, GAMEPASS_ID)
    end)

    if success then
        if hasGamepass then
            maxBagCapacity = 50
            print("[Gamepass Check] ✅ You own the premium gamepass!")
        else
            maxBagCapacity = 40
            print("[Gamepass Check] ❌ You do NOT own the premium gamepass.")
        end
    else
        maxBagCapacity = 40
        print("[Gamepass Check] ⚠️ Failed to check ownership.")
    end
end

-- Initialize premium check
checkPremiumStatus()

-- ESP System Variables
local murderHasKnife = false
local sheriffHasGun = false
local currentESPOptions = { "Esp All" }
local highlightEnabled = true
local lineESPEnabled = false
local tracers = {}

-- Weapon Dupe Variables
local WeaponName = ""
local FunctionCall = 1

-- Visual Weapon Variables
local fromWeapon = ""
local toWeapon = ""

-- UI Path for dupe functions
local UIPath
if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") ~= nil then
    UIPath = LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main
else
    UIPath = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
end

-- Character Settings
local CharacterSettings = {
    WalkSpeed = {
        Value = 16,
        Default = 16,
        Locked = false
    },
    JumpPower = {
        Value = 50,
        Default = 50,
        Locked = false
    }
}

-- ESP Functions
local function getRole(player)
    local character = player.Character
    if not character then return nil end
    local backpack = player:FindFirstChild("Backpack")
    if character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then return "Murderer" end
    if character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

local function isPlayerTargeted(player, selectedOptions)
    local role = getRole(player)
    if not role then return false end
    if table.find(selectedOptions, "Esp All") then return true end
    if table.find(selectedOptions, "Esp Murder") and role == "Murderer" then return true end
    if table.find(selectedOptions, "Esp Sheriff") and role == "Sheriff" then return true end
    if table.find(selectedOptions, "Esp Sheriff / Murder") and (role == "Sheriff" or role == "Murderer") then return true end
    return false
end

local function createHighlight(character, color)
    local highlight = character:FindFirstChild("RoleHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "RoleHighlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character
    end
    highlight.FillColor = color
end

local function removeHighlight(character)
    local highlight = character:FindFirstChild("RoleHighlight")
    if highlight then highlight:Destroy() end
end

local function createTracer(player, color)
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = color or Color3.new(1, 1, 1)
    line.Transparency = 1
    tracers[player] = line
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

local function updateESP()
    murderHasKnife = false
    sheriffHasGun = false

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getRole(player)
            if role == "Murderer" then murderHasKnife = true end
            if role == "Sheriff" then sheriffHasGun = true end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getRole(player)
            local target = isPlayerTargeted(player, currentESPOptions)

            if highlightEnabled then
                if target then
                    local color = role == "Murderer" and DefaultColors.DarkRed or 
                                 role == "Sheriff" and DefaultColors.Blue or 
                                 DefaultColors.Gold
                    createHighlight(player.Character, color)
                else
                    removeHighlight(player.Character)
                end
            else
                removeHighlight(player.Character)
            end

            if lineESPEnabled and target then
                local color = role == "Murderer" and DefaultColors.DarkRed or 
                             role == "Sheriff" and DefaultColors.Blue or 
                             DefaultColors.Gold
                if not tracers[player] then 
                    createTracer(player, color) 
                else
                    tracers[player].Color = color
                end
            else
                removeTracer(player)
            end
        end
    end
end

-- Character Functions
local function updateCharacter()
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if not CharacterSettings.WalkSpeed.Locked then
            humanoid.WalkSpeed = CharacterSettings.WalkSpeed.Value
        end
        if not CharacterSettings.JumpPower.Locked then
            humanoid.JumpPower = CharacterSettings.JumpPower.Value
        end
    end
end

-- MiniFling function (must be defined before flingMurdererFunction)
local function miniFling(Targets)
    local Players = game:GetService("Players")
    local AllBool = false

    local GetPlayer = function(Name)
        Name = Name:lower()
        if Name == "all" or Name == "others" then
            AllBool = true
            return
        elseif Name == "random" then
            local GetPlayers = Players:GetPlayers()
            if table.find(GetPlayers,Players.LocalPlayer) then table.remove(GetPlayers,table.find(GetPlayers,Players.LocalPlayer)) end
            return GetPlayers[math.random(#GetPlayers)]
        elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
            for _,x in next, Players:GetPlayers() do
                if x ~= Players.LocalPlayer then
                    if x.Name:lower():match("^"..Name) then
                        return x;
                    elseif x.DisplayName:lower():match("^"..Name) then
                        return x;
                    end
                end
            end
        else
            return
        end
    end

    local SkidFling = function(TargetPlayer)
        local Character = Players.LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart

        local TCharacter = TargetPlayer.Character
        local THumanoid
        local TRootPart
        local THead
        local Accessory
        local Handle

        if TCharacter:FindFirstChildOfClass("Humanoid") then
            THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        end
        if THumanoid and THumanoid.RootPart then
            TRootPart = THumanoid.RootPart
        end
        if TCharacter:FindFirstChild("Head") then
            THead = TCharacter.Head
        end
        if TCharacter:FindFirstChildOfClass("Accessory") then
            Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        end
        if Accessory and Accessory:FindFirstChild("Handle") then
            Handle = Accessory.Handle
        end

        if Character and Humanoid and RootPart then
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end
            if THumanoid and THumanoid.Sit and not AllBool then
                return 
            end
            if THead then
                game.Workspace.CurrentCamera.CameraSubject = THead
            elseif not THead and Handle then
                game.Workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid and TRootPart then
                game.Workspace.CurrentCamera.CameraSubject = THumanoid
            end
            if not TCharacter:FindFirstChildWhichIsA("BasePart") then
                return
            end

            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end

            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0

                repeat
                    if RootPart and THumanoid then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100

                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                            task.wait()

                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    else
                        break
                    end
                until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
            end

            game.Workspace.FallenPartsDestroyHeight = 0/0

            local BV = Instance.new("BodyVelocity")
            BV.Name = "EpixVel"
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
            BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

            if TRootPart and THead then
                if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                    SFBasePart(THead)
                else
                    SFBasePart(TRootPart)
                end
            elseif TRootPart and not THead then
                SFBasePart(TRootPart)
            elseif not TRootPart and THead then
                SFBasePart(THead)
            elseif not TRootPart and not THead and Accessory and Handle then
                SFBasePart(Handle)
            else
                return 
            end

            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            game.Workspace.CurrentCamera.CameraSubject = Humanoid

            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                table.foreach(Character:GetChildren(), function(_, x)
                    if x:IsA("BasePart") then
                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end)
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            game.Workspace.FallenPartsDestroyHeight = -500
        else
            return 
        end
        game.Workspace.FallenPartsDestroyHeight = -500
    end

    if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end

    if AllBool then
        for _,x in next, Players:GetPlayers() do
            SkidFling(x)
        end
    end

    for _,x in next, Targets do
        if GetPlayer(x) and GetPlayer(x) ~= Players.LocalPlayer then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        elseif not GetPlayer(x) and not AllBool then
            
        end
    end
end

-- Function to fling murderer (called by both button and auto fling)
local function flingMurdererFunction()
    local murderer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Check character for knife
            if player.Character:FindFirstChild("Knife") then
                murderer = player
                break
            end
            -- Check backpack for knife
            local backpack = player:FindFirstChild("Backpack")
            if backpack and backpack:FindFirstChild("Knife") then
                murderer = player
                break
            end
        end
    end
    
    if murderer and murderer.Character then
        WindUI:Notify({
            Title = "Flinging Murderer",
            Content = "Flinging " .. murderer.Name .. "!",
            Icon = "zap",
            Duration = 3
        })
        
        -- Use miniFling with murderer's name
        miniFling({murderer.Name})
        
        WindUI:Notify({
            Title = "Fling Complete",
            Content = "Murderer has been flung!",
            Icon = "check-circle",
            Duration = 2
        })
        return true
    else
        WindUI:Notify({
            Title = "Fling Error",
            Content = "No murderer found!",
            Icon = "x-circle",
            Duration = 3
        })
    return false
    end
end

-- Auto Farm Functions



-- Improved Auto Farm System
local function getCharacter() 
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
end

local function getHRP() 
    return getCharacter():WaitForChild("HumanoidRootPart") 
end

-- Round event handlers
local CoinCollected = ReplicatedStorage:FindFirstChild("Remotes") and 
                      ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and 
                      ReplicatedStorage.Remotes.Gameplay:FindFirstChild("CoinCollected")

local RoundStart = ReplicatedStorage:FindFirstChild("Remotes") and 
                   ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and 
                   ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundStart")

local RoundEnd = ReplicatedStorage:FindFirstChild("Remotes") and 
                 ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and 
                 ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundEndFade")

if RoundStart then
    RoundStart.OnClientEvent:Connect(function()
        farming = true
        start_position = getHRP().CFrame
        print("[DEBUG] Round started, farming enabled")
    end)
end

if RoundEnd then
    RoundEnd.OnClientEvent:Connect(function()
        farming = false
        print("[DEBUG] Round ended, farming disabled")
    end)
end

-- Improved coin detection function (uses coin detection method)
local function get_nearest_coin()
    local hrp = getHRP()
    local closest, dist = nil, math.huge
    
    -- Search through workspace children for CoinContainer (same method as coin autofarm)
    for _, m in pairs(workspace:GetChildren()) do
        if m:FindFirstChild("CoinContainer") then
            for _, coin in pairs(m.CoinContainer:GetChildren()) do
                if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                    local d = (hrp.Position - coin.Position).Magnitude
                    if d < dist then 
                        closest, dist = coin, d 
                    end
                end
            end
        end
    end
    
    return closest, dist
end

-- Improved Auto Farm Loop
task.spawn(function()
    while true do
        if autoFarmCoins and farming and not bag_full then
            local hrp = getHRP()
            local coin, dist = nil, math.huge
            
            coin, dist = get_nearest_coin()
            
            if coin then
                if dist > 150 then
                    -- Teleport for distant coins
                    hrp.CFrame = coin.CFrame
                    print("[DEBUG] Teleported to distant coin at distance:", dist)
                else
                    -- Use tweening for nearby coins
                    local tween = TweenService:Create(hrp, TweenInfo.new(dist / flySpeed, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                    tween:Play()
                    print("[DEBUG] Tweening to nearby coin at distance:", dist)
                    
                    -- Wait until coin is collected or farming stops
                    repeat 
                        task.wait() 
                    until not coin:FindFirstChild("TouchInterest") or not farming or not autoFarmCoins
                    
                    tween:Cancel()
                end
                
                    collected += 1
                    print("[DEBUG] Collected item, total collected:", collected)
            else
                print("[DEBUG] No valid items found to collect")
            end
        end
        
        task.wait(0.2)
    end
end)

-- Disable collisions while farming
RunService.Stepped:Connect(function()
    if autoFarmCoins and farming and not bag_full then
        local character = LocalPlayer.Character
        if character and character:IsDescendantOf(workspace) then
            for _, v in ipairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- Improved Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    visitedPositions = {}
    currentBagAmount = 0
    bag_full = false
    resetting = false
    checkPremiumStatus()
    print("[DEBUG] Character respawned, farming state reset")
end)

-- Improved Auto Reset System
if CoinCollected then
    CoinCollected.OnClientEvent:Connect(function(coinType, newAmount, oldAmount, additionalData)
        if coinType == "Coin" then
            currentBagAmount = newAmount
            print("[DEBUG] Collected coin! Current amount:", currentBagAmount)
            
            -- Check if bag is full
            if currentBagAmount >= maxBagCapacity then
                print("[DEBUG] Bag is full! (" .. maxBagCapacity .. " coins reached)")
                print("[DEBUG] autoEndRound is:", autoEndRound)
                print("[DEBUG] autoFlingMurderer is:", autoFlingMurderer)
                print("[DEBUG] autoKillMurderer is:", autoKillMurderer)
                
                WindUI:Notify({
                    Title = "Bag Full!",
                    Content = "Coin bag is full (" .. currentBagAmount .. "/" .. maxBagCapacity .. ")",
                    Icon = "package",
                    Duration = 3
                })
                
                -- Stop autofarm when bag is full
                autoFarmCoins = false
                print("[DEBUG] Stopped autofarm")
                
                -- Auto fling murderer if enabled (works independently)
                if autoFlingMurderer then
                    print("[DEBUG] Auto fling murderer enabled...")
                    
                    WindUI:Notify({
                        Title = "Auto Fling Murderer",
                        Content = "Flinging murderer now!",
                        Icon = "zap",
                        Duration = 2
                    })
                    
                    -- Find murderer immediately
                    local murderer = nil
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            if player.Character:FindFirstChild("Knife") then
                                murderer = player
                                break
                            end
                            local backpack = player:FindFirstChild("Backpack")
                            if backpack and backpack:FindFirstChild("Knife") then
                                murderer = player
                                break
                            end
                        end
                    end
                    
                    if murderer and murderer.Character then
                        print("[DEBUG] Found murderer, flinging:", murderer.Name)
                        -- Call the same function as the button
                        flingMurdererFunction()
                        print("[DEBUG] Auto murderer fling completed")
                    else
                        print("[DEBUG] No murderer found")
                    end
                end
                
                
                -- Auto reset character if enabled
                if autoEndRound and not resetting then
                    resetting = true
                    bag_full = true
                    
                    -- Return to start position before resetting
                    local hrp = getHRP()
                    if start_position then
                        print("[DEBUG] Returning to start position...")
                        local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = start_position})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                    
                    -- Wait a bit before resetting
                    task.wait(0.5)
                    
                    -- Reset character
                    print("[DEBUG] Resetting character...")
                    WindUI:Notify({
                        Title = "Auto Reset",
                        Content = "Resetting character instantly!",
                        Icon = "refresh-cw",
                        Duration = 2
                    })
                    
                    if LocalPlayer.Character then
                        LocalPlayer.Character:BreakJoints()
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(1.5)
                        print("[DEBUG] Character reset completed")
                    end
                    
                    -- Reset farming state
                    resetting = false
                    bag_full = false
                    print("[DEBUG] Farming state reset")
                end
            end
        end
    end)
end

-- Improved Round Start Handler
if RoundStart then
    RoundStart.OnClientEvent:Connect(function(roundTime, playerData)
        -- Reset farming state
        currentBagAmount = 0
        visitedPositions = {}
        bag_full = false
        resetting = false
        
        -- Set farming to true for the improved system
        farming = true
        start_position = getHRP().CFrame
        
        print("[DEBUG] Round started, farming enabled")
        
        -- Always resume autofarm if it was enabled before (regardless of autoEndRound setting)
        local wasCoinFarming = autoFarmCoins
        
        -- Resume coin autofarm if it was enabled before
        if wasCoinFarming then
            autoFarmCoins = true
            WindUI:Notify({
                Title = "Round Started!",
                Content = "Coin autofarm resumed automatically",
                Icon = "play-circle",
                Duration = 2
            })
        end
    end)
end

-- Weapon Dupe Functions
local function VisualDupe()
    wait(math.random(1, 3))
    for i,v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for i,v in pairs(v.Container:GetChildren()) do
            if v.Name == "Christmas" or v.Name == "Snowflake" then
                for i,v in pairs(v.Container:GetChildren()) do
                    if v:IsA("Frame") and v.ItemName.Label.Text == WeaponName then
                        local amount = v.Container.Amount.Text
                        if amount == "" or amount == "None" then
                            v.Container.Amount.Text = "x2"
                        else
                            local num = tonumber(amount:match("x(%d+)"))
                            if num then
                                v.Container.Amount.Text = "x" .. tostring(num + 1)
                            end
                        end
                    end
                end
            else
                if v:IsA("Frame") and v.ItemName.Label.Text == WeaponName then
                    local amount = v.Container.Amount.Text
                    if amount == "" or amount == "None" then
                        v.Container.Amount.Text = "x2"
                    else
                        local num = tonumber(amount:match("x(%d+)"))
                        if num then
                            v.Container.Amount.Text = "x" .. tostring(num + 1)
                        end
                    end
                end
            end
        end
    end
end

local function InventoryDupe()
    wait(math.random(3, 5))
    for i,v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for i,v in pairs(v.Container:GetChildren()) do
            if v.Name == "Christmas" or v.Name == "Snowflake" then
                for i,v in pairs(v.Container:GetChildren()) do
                    if v:IsA("Frame") then
                        if v.ItemName.Label.Text ~= "Default Knife" and v.ItemName.Label.Text ~= "Default Gun" then
                            local amount = v.Container.Amount.Text
                            if amount == "" or amount == "None" then
                                v.Container.Amount.Text = "x2"
                            else
                                local num = tonumber(amount:match("x(%d+)"))
                                if num then
                                    v.Container.Amount.Text = "x" .. tostring(num * 2)
                                end
                            end
                        end
                    end
                end
            else
                if v:IsA("Frame") then
                    if v.ItemName.Label.Text ~= "Default Knife" and v.ItemName.Label.Text ~= "Default Gun" then
                        local amount = v.Container.Amount.Text
                        if amount == "" or amount == "None" then
                            v.Container.Amount.Text = "x2"
                        else
                            local num = tonumber(amount:match("x(%d+)"))
                            if num then
                                v.Container.Amount.Text = "x" .. tostring(num * 2)
                            end
                        end
                    end
                end
            end
        end
    end
    for i,v in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if v:IsA("Frame") then
            local amount = v.Container.Amount.Text
            if amount == "" or amount == "None" then
                v.Container.Amount.Text = "x2"
            else
                local num = tonumber(amount:match("x(%d+)"))
                if num then
                    v.Container.Amount.Text = "x" .. tostring(num * 2)
                end
            end
        end
    end
end

-- Visual Weapon Functions
local function NameMatch(name, search)
    local sanitizedName = name:gsub("_G_%d%d%d%d", ""):gsub("_K_%d%d%d%d", ""):lower()
    local sanitizedSearch = search:lower()
    return sanitizedName:find(sanitizedSearch, 1, true) ~= nil
end

-- Trade Scam Functions
local function StartVisualTrade()
    if game:GetService("Players").LocalPlayer.PlayerGui.TradeGUI.Enabled == true or game:GetService("Players").LocalPlayer.PlayerGui.TradeGUI_Phone.Enabled == true then
        wait(1)
        WindUI:Notify({ 
            Title = "Trade Scam Active", 
            Content = "Items In Trade Are Now Visual, Remove All Items!", 
            Icon = "alert-triangle", 
            Duration = 5 
        })
    else
        WindUI:Notify({ 
            Title = "Trade Scam Error", 
            Content = "You Need To Be In Trade For This To Work!", 
            Icon = "x-circle", 
            Duration = 5 
        })
    end
end

-- Weapon Spawner Functions
local function getrandombox()
    local success, boxes = pcall(function()
        return require(game:GetService("ReplicatedStorage").Database.Sync.MysteryBox)
    end)
    
    if not success or not boxes or next(boxes) == nil then 
        return "StandardBox"
    end
    
    local keys = {}
    for k, _ in pairs(boxes) do
        table.insert(keys, k)
    end
    return keys[math.random(1, #keys)]
end

local function opencrate(ITEM_NAME)
    local success = pcall(function()
        local boxmodule = require(game:GetService("ReplicatedStorage").Modules.BoxModule)
        local itemdatabase = require(game:GetService("ReplicatedStorage").Database.Sync.Item)
        
        if ITEM_NAME and itemdatabase[ITEM_NAME] then
            print("Spawning:", ITEM_NAME)
            boxmodule.OpenBox(getrandombox(), ITEM_NAME)
            
            local success2 = pcall(function()
                local poop = getsenv(game:GetService("Players").LocalPlayer.PlayerGui.MainGUI.Inventory.NewItem)._G
                poop.NewItem(ITEM_NAME, nil, nil, "Weapons", 1)
            end)
            
            WindUI:Notify({
                Title = "Success",
                Content = "Successfully spawned: " .. ITEM_NAME,
                Icon = "check-circle",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Invalid item: " .. ITEM_NAME,
                Icon = "x-circle",
                Duration = 3
            })
        end
    end)
    
    if not success then
        WindUI:Notify({
            Title = "Error",
            Content = "Error opening crate for: " .. ITEM_NAME,
            Icon = "x-circle",
            Duration = 3
        })
    end
end

-- Gun System Functions
local GunSystem = {
    AutoGrabEnabled = false,
    NotifyGunDrop = true,
    GunDropCheckInterval = 1,
    ActiveGunDrops = {},
}

local mapPaths = {
    "ResearchFacility", "Hospital3", "MilBase", "House2", "Workplace",
    "Mansion2", "BioLab", "Hotel", "Factory", "Bank2", "PoliceStation"
}

local function ScanForGunDrops()
    GunSystem.ActiveGunDrops = {}
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop then
                table.insert(GunSystem.ActiveGunDrops, gunDrop)
            end
        end
    end
    local rootGunDrop = workspace:FindFirstChild("GunDrop")
    if rootGunDrop then
        table.insert(GunSystem.ActiveGunDrops, rootGunDrop)
    end
end

local function GrabGun(gunDrop)
    if not gunDrop then
        ScanForGunDrops()
        if #GunSystem.ActiveGunDrops == 0 then
            WindUI:Notify({
                Title = "Gun System",
                Content = "No guns available on the map",
                Icon = "x-circle",
                Duration = 3
            })
            return false
        end
        local nearestGun = nil
        local minDistance = math.huge
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            for _, drop in ipairs(GunSystem.ActiveGunDrops) do
                local distance = (humanoidRootPart.Position - drop.Position).Magnitude
                if distance < minDistance then
                    nearestGun = drop
                    minDistance = distance
                end
            end
        end
        gunDrop = nearestGun
    end
    if (gunDrop and LocalPlayer.Character) then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = gunDrop.CFrame
            task.wait(0.3)
            local prompt = gunDrop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                WindUI:Notify({
                    Title = "Gun System",
                    Content = "Successfully grabbed the gun!",
                    Icon = "check-circle",
                    Duration = 3
                })
                return true
            end
        end
    end
    return false
end

local function AutoGrabGun()
    while GunSystem.AutoGrabEnabled do
        ScanForGunDrops()
        if #GunSystem.ActiveGunDrops > 0 and LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local nearestGun = nil
                local minDistance = math.huge
                for _, gunDrop in ipairs(GunSystem.ActiveGunDrops) do
                    local distance = (humanoidRootPart.Position - gunDrop.Position).Magnitude
                    if distance < minDistance then
                        nearestGun = gunDrop
                        minDistance = distance
                    end
                end
                if nearestGun then
                    humanoidRootPart.CFrame = nearestGun.CFrame
                    task.wait(0.3)
                    local prompt = nearestGun:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(1)
                    end
                end
            end
        end
        task.wait(GunSystem.GunDropCheckInterval)
    end
end

-- Murder Functions
local killActive = false
local attackDelay = 0.5
local targetRoles = {"Sheriff", "Hero", "Innocent"}

local function getPlayerRole(player)
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    if roles and roles[player.Name] then
        return roles[player.Name].Role
    end
    return nil
end

local function equipKnife()
    local character = LocalPlayer.Character
    if not character then return false end
    
    if character:FindFirstChild("Knife") then
        return true
    end
    
    local knife = LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = character
        return true
    end
    return false
end

local function getNearestTarget()
    local targets = {}
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if (player ~= LocalPlayer) and player.Character then
            local role = getPlayerRole(player)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if (role and humanoid and humanoid.Health > 0 and targetRoot and table.find(targetRoles, role)) then
                table.insert(targets, {
                    Player = player,
                    Distance = (localRoot.Position - targetRoot.Position).Magnitude
                })
            end
        end
    end
    
    table.sort(targets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return (targets[1] and targets[1].Player) or nil
end

local function attackTarget(target)
    if not target or not target.Character then return false end
    
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if not equipKnife() then
        return false
    end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if (targetRoot and localRoot) then
        localRoot.CFrame = CFrame.new(targetRoot.Position + ((localRoot.Position - targetRoot.Position).Unit * 2), targetRoot.Position)
    end
    
    local knife = LocalPlayer.Character:FindFirstChild("Knife")
    if (knife and knife:FindFirstChild("Stab")) then
        for i = 1, 3 do
            knife.Stab:FireServer("Down")
        end
        return true
    end
    return false
end

local function killTargets()
    if killActive then return end
    killActive = true
    
    local function attackSequence()
        while killActive do
            local target = getNearestTarget()
            if not target then
                killActive = false
                break
            end
            
            attackTarget(target)
            task.wait(attackDelay)
        end
    end
    
    task.spawn(attackSequence)
end

local function stopKilling()
    killActive = false
end


-- Function to auto reset character
local function autoResetCharacter()
    print("[DEBUG] autoResetCharacter function called")
    
    WindUI:Notify({
        Title = "Auto Reset",
        Content = "Resetting character instantly!",
        Icon = "refresh-cw",
        Duration = 3
    })
    
    -- Try multiple reset methods
    if LocalPlayer.Character then
        print("[DEBUG] Character found, attempting reset...")
        
        -- Method 1: BreakJoints (most common method)
        pcall(function()
            LocalPlayer.Character:BreakJoints()
            print("[DEBUG] BreakJoints method used")
        end)
        
        -- Method 2: Destroy and reload character (backup)
        task.wait(0.2)
        pcall(function()
            if LocalPlayer.Character then
                LocalPlayer.Character:Destroy()
                print("[DEBUG] Character destroyed")
                task.wait(0.2)
                LocalPlayer:LoadCharacter()
                print("[DEBUG] Character reloaded")
            end
        end)
        
        print("[DEBUG] Character reset process completed")
    else
        print("[DEBUG] No character found to reset")
        -- Try to load character if none exists
        pcall(function()
            LocalPlayer:LoadCharacter()
            print("[DEBUG] Attempted to load character")
        end)
    end
end


-- Sheriff Functions
local shotType = "Default"

local function ShootMurderer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0 then
        return
    end
    
    local success, roles = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    
    if not success or not roles then return end
    
    local murderer = nil
    for name, data in pairs(roles) do
        if data.Role == "Murderer" then
            murderer = Players:FindFirstChild(name)
            break
        end
    end
    
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Humanoid") or murderer.Character.Humanoid.Health <= 0 then
        return
    end
    
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if (shotType == "Default") and not gun then return end
    
    if gun and not LocalPlayer.Character:FindFirstChild("Gun") then
        gun.Parent = LocalPlayer.Character
    end
    
    if (shotType == "Teleport") then
        local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if (targetRoot and localRoot) then
            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
        end
    end
    
    gun = LocalPlayer.Character:FindFirstChild("Gun")
    if (gun and gun:FindFirstChild("KnifeLocal")) then
        local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local args = {
                [1] = 1,
                [2] = targetPart.Position,
                [3] = "AH2"
            }
            gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        end
    end
end


-- ========================================
-- TABS CREATION
-- ========================================

local ZovlaneFunctions = Window:Section({
    Title = "Zovlane Functions",
    Icon = "flame",
    Opened = true,
})

-- */  ESP Tab  /* --
do
    local ESPTab = ZovlaneFunctions:Tab({
        Title = "ESP",
        Icon = "eye",
    })
    
    ESPTab:Section({
        Title = "Player ESP Settings",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    ESPTab:Toggle({
        Flag = "HighlightESP",
        Title = "Highlight ESP",
        Desc = "Enable player highlighting (shows all by default)",
        Default = true,
        Callback = function(state)
            highlightEnabled = state
            if state then
                currentESPOptions = {"Esp All"}
            end
            updateESP()
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Dropdown({
        Flag = "ESPOptions",
        Title = "Filter ESP",
        Desc = "Filter which players to highlight",
        Values = {
            {Title = "Esp All", Icon = "users"},
            {Title = "Esp Sheriff", Icon = "shield"},
            {Title = "Esp Murder", Icon = "knife"},
            {Title = "Esp Sheriff / Murder", Icon = "target"}
        },
        Value = "Esp All",
        Callback = function(option)
            currentESPOptions = {option.Title}
            updateESP()
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Toggle({
        Flag = "LineESP",
        Title = "Line ESP (Tracers)",
        Desc = "Draw lines to players",
        Default = false,
        Callback = function(state)
            lineESPEnabled = state
            if not state then
                for _, line in pairs(tracers) do line:Remove() end
                tracers = {}
            end
            updateESP()
        end
    })
end

-- */  Auto Farm Tab  /* --
do
    local AutoFarmTab = ZovlaneFunctions:Tab({
        Title = "Auto Farm",
        Icon = "trending-up",
    })
    
    AutoFarmTab:Section({
        Title = "Coin Collection",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    AutoFarmTab:Toggle({
        Flag = "CoinAutofarm",
        Title = "Coin Autofarm",
        Desc = "Collect coins automatically",
        Default = false,
        Callback = function(state)
            autoFarmCoins = state
            if state then
                visitedPositions = {}
                collected = 0
                WindUI:Notify({ 
                    Title = "Coin Autofarm", 
                    Content = "Coin farming started!", 
                    Icon = "coin", 
                    Duration = 3 
                })
            else
                WindUI:Notify({ 
                    Title = "Coin Autofarm", 
                    Content = "Coin farming stopped", 
                    Icon = "x-circle", 
                    Duration = 3 
                })
            end
        end
    })
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Toggle({
        Flag = "AutoEndRound",
        Title = "Auto Reset Character",
        Desc = "Automatically reset character when bag is full",
        Default = false,
        Callback = function(state)
            autoEndRound = state
            flingMurdererOnFull = state
            print("[DEBUG] Auto Reset Character toggle changed to:", state)
            print("[DEBUG] autoEndRound is now:", autoEndRound)
            print("[DEBUG] flingMurdererOnFull is now:", flingMurdererOnFull)
            if state then
                WindUI:Notify({ 
                    Title = "Auto Reset Character", 
                    Content = "Will reset character at " .. maxBagCapacity .. " coins", 
                    Icon = "refresh-cw", 
                    Duration = 3 
                })
            else
                WindUI:Notify({ 
                    Title = "Auto Reset Character", 
                    Content = "Auto reset character disabled", 
                    Icon = "x-circle", 
                    Duration = 3 
                })
            end
        end
    })
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Toggle({
        Flag = "AutoFlingMurderer",
        Title = "Auto Fling Murderer",
        Desc = "Automatically fling murderer when bag is full",
        Default = false,
        Callback = function(state)
            autoFlingMurderer = state
            print("[DEBUG] Auto Fling Murderer toggle changed to:", state)
            if state then
                WindUI:Notify({ 
                    Title = "Auto Fling Murderer", 
                    Content = "Will fling murderer at " .. maxBagCapacity .. " coins", 
                    Icon = "zap", 
                    Duration = 3 
                })
            else
                WindUI:Notify({ 
                    Title = "Auto Fling Murderer", 
                    Content = "Auto fling murderer disabled", 
                    Icon = "x-circle", 
                    Duration = 3 
                })
            end
        end
    })
    
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Slider({
        Flag = "FlySpeed",
        Title = "Autofarm Speed",
        Desc = "Adjust collection speed",
        Step = 1,
        Value = {
            Min = 5,
            Max = 50,
            Default = 25
        },
        Callback = function(value)
            flySpeed = value
        end
    })
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Section({
        Title = "⚠️ Recommended: 25, higher will probably get you kicked",
        TextSize = 14,
        TextTransparency = 0.3,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Button({
        Title = "Reset Counter",
        Icon = "refresh-cw",
        Justify = "Center",
        Callback = function()
            collected = 0
            visitedPositions = {}
            currentBagAmount = 0
            WindUI:Notify({ 
                Title = "Counter Reset", 
                Content = "Collection counter reset!", 
                Icon = "check-circle", 
                Duration = 3 
            })
        end
    })
    
    AutoFarmTab:Space()
    

    AutoFarmTab:Button({
        Title = "Fling Murderer",
        Icon = "zap",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
        Callback = function()
            flingMurdererFunction()
        end
    })
    
    AutoFarmTab:Space()
    
    AutoFarmTab:Button({
        Title = "Enable Anti-AFK",
        Icon = "moon",
        Color = DefaultColors.DarkGreen,
        Justify = "Center",
        Callback = function()
            local success = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
            end)
            
            if success then
                WindUI:Notify({ 
                    Title = "Anti-AFK", 
                    Content = "Anti-AFK enabled!", 
                    Icon = "check-circle", 
                    Duration = 3 
                })
            else
                WindUI:Notify({ 
                    Title = "Anti-AFK Error", 
                    Content = "Failed to load Anti-AFK!", 
                    Icon = "x-circle", 
                    Duration = 5 
                })
            end
        end
    })
end

-- */  Character Tab  /* --
do
    local CharacterTab = ZovlaneFunctions:Tab({
        Title = "Character",
        Icon = "user",
    })
    
    CharacterTab:Section({
        Title = "Movement Settings",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    CharacterTab:Slider({
        Flag = "WalkSpeed",
        Title = "Walk Speed",
        Desc = "Adjust your walking speed",
        Step = 1,
    Value = {
        Min = 0,
        Max = 200,
        Default = 16
    },
    Callback = function(value)
            CharacterSettings.WalkSpeed.Value = value
            updateCharacter()
        end
    })
    
    CharacterTab:Space()
    
    CharacterTab:Toggle({
        Flag = "BlockWalkSpeed",
        Title = "Lock Walk Speed",
        Desc = "Prevent walkspeed changes",
    Default = false,
    Callback = function(state)
            CharacterSettings.WalkSpeed.Locked = state
        end
    })
    
    CharacterTab:Space()
    
    CharacterTab:Slider({
        Flag = "JumpPower",
        Title = "Jump Power",
        Desc = "Adjust your jump height",
        Step = 1,
    Value = {
        Min = 0,
        Max = 200,
        Default = 50
    },
    Callback = function(value)
            CharacterSettings.JumpPower.Value = value
            updateCharacter()
        end
    })
    
    CharacterTab:Space()
    
    CharacterTab:Toggle({
        Flag = "BlockJumpPower",
        Title = "Lock Jump Power",
        Desc = "Prevent jump power changes",
    Default = false,
    Callback = function(state)
            CharacterSettings.JumpPower.Locked = state
        end
    })
    
    CharacterTab:Space()
    
    CharacterTab:Button({
        Title = "Reset to Default",
        Icon = "rotate-ccw",
        Color = DefaultColors.Gold,
        Justify = "Center",
        Callback = function()
            CharacterSettings.WalkSpeed.Value = 16
            CharacterSettings.JumpPower.Value = 50
            updateCharacter()
            WindUI:Notify({
                Title = "Character Reset",
                Content = "Settings reset to default!",
                Icon = "check-circle",
                Duration = 3
            })
        end
    })
end

-- */  Teleport Tab  /* --
do
    local TeleportTab = ZovlaneFunctions:Tab({
        Title = "Teleport",
        Icon = "move",
    })
    
    TeleportTab:Section({
        Title = "Player Teleportation",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local teleportTarget = nil
    local teleportDropdown = nil

local function updateTeleportPlayers()
        local playersList = {}
    for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playersList, {
                    Title = player.Name,
                    Icon = "user"
                })
        end
    end
        return playersList
    end
    
    teleportDropdown = TeleportTab:Dropdown({
        Flag = "TeleportPlayer",
        Title = "Select Player",
        Desc = "Choose a player to teleport to",
        Values = updateTeleportPlayers(),
        Callback = function(option)
            teleportTarget = Players:FindFirstChild(option.Title)
        end
    })
    
    TeleportTab:Space()
    
    TeleportTab:Button({
        Title = "Teleport to Player",
        Icon = "zap",
        Color = DefaultColors.Green,
        Justify = "Center",
        Callback = function()
            if teleportTarget and teleportTarget.Character then
                local targetRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    localRoot.CFrame = targetRoot.CFrame
            WindUI:Notify({
                        Title = "Teleport Success",
                        Content = "Teleported to " .. teleportTarget.Name,
                Icon = "check-circle",
                Duration = 3
                    })
        end
    else
        WindUI:Notify({
                    Title = "Teleport Error",
                    Content = "Target not found!",
            Icon = "x-circle",
            Duration = 3
                })
    end
end
    })
    
    TeleportTab:Space()
    
    TeleportTab:Button({
        Title = "Refresh Player List",
        Icon = "refresh-cw",
        Justify = "Center",
    Callback = function()
            teleportDropdown:Refresh(updateTeleportPlayers())
            WindUI:Notify({
                Title = "Players Updated",
                Content = "Player list refreshed!",
                Icon = "check-circle",
                Duration = 2
            })
        end
    })
    
    TeleportTab:Space({ Columns = 2 })
    
    TeleportTab:Section({
        Title = "Role Teleportation",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    TeleportTab:Button({
        Title = "Teleport to Murderer",
        Icon = "knife",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
        Callback = function()
            local murderer = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Check character for knife
                    if player.Character:FindFirstChild("Knife") then
                        murderer = player
                        break
                    end
                    -- Check backpack for knife
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack and backpack:FindFirstChild("Knife") then
                        murderer = player
                        break
                    end
                end
            end
            
            if murderer and murderer.Character then
                local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    localRoot.CFrame = targetRoot.CFrame
                    WindUI:Notify({
                        Title = "Teleport Success",
                        Content = "Teleported to murderer: " .. murderer.Name,
                        Icon = "check-circle",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Teleport Error",
                    Content = "No murderer found!",
                    Icon = "x-circle",
                    Duration = 3
                })
            end
        end
    })
    
    TeleportTab:Space()
    
    TeleportTab:Button({
        Title = "Teleport to Sheriff",
        Icon = "shield",
        Color = DefaultColors.Blue,
        Justify = "Center",
        Callback = function()
            local sheriff = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Check character for gun
                    if player.Character:FindFirstChild("Gun") then
                        sheriff = player
                        break
                    end
                    -- Check backpack for gun
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack and backpack:FindFirstChild("Gun") then
                        sheriff = player
                        break
                    end
                end
            end
            
            if sheriff and sheriff.Character then
                local targetRoot = sheriff.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    localRoot.CFrame = targetRoot.CFrame
                    WindUI:Notify({
                        Title = "Teleport Success",
                        Content = "Teleported to sheriff: " .. sheriff.Name,
                        Icon = "check-circle",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Teleport Error",
                    Content = "No sheriff found!",
                    Icon = "x-circle",
                    Duration = 3
                })
            end
        end
    })
end

-- */  Weapon Spawner Tab  /* --
do
    local WeaponSpawnerTab = ZovlaneFunctions:Tab({
        Title = "Weapon Spawner",
        Icon = "sword",
    })
    
    WeaponSpawnerTab:Section({
        Title = "Spawn Weapons",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local weaponName = ""
    
    WeaponSpawnerTab:Input({
        Flag = "WeaponName",
    Title = "Weapon Name",
        Desc = "Enter the name of the weapon",
        Placeholder = "e.g., SnowflakeBlade, Raygun",
    Callback = function(text)
        weaponName = text
    end
})

    WeaponSpawnerTab:Space()
    
    WeaponSpawnerTab:Button({
    Title = "Spawn Weapon",
        Icon = "sparkles",
        Color = DefaultColors.Gold,
        Justify = "Center",
    Callback = function()
        if weaponName ~= "" then
            opencrate(weaponName)
        else
            WindUI:Notify({
                Title = "Error",
                    Content = "Please enter a weapon name!",
                    Icon = "x-circle",
                    Duration = 3
            })
        end
    end
})

    WeaponSpawnerTab:Space({ Columns = 2 })
    
    WeaponSpawnerTab:Section({
        Title = "Quick Spawn Godlies",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    WeaponSpawnerTab:Button({
        Title = "Spawn Raygun (Battlepass)",
        Icon = "zap",
        Color = DefaultColors.Blue,
        Callback = function()
            opencrate("Raygun")
        end
    })
    
    WeaponSpawnerTab:Space()
    
    WeaponSpawnerTab:Button({
        Title = "Spawn XenoKnife",
        Icon = "knife",
        Color = DefaultColors.DarkRed,
        Callback = function()
            opencrate("XenoKnife")
        end
    })
    
    WeaponSpawnerTab:Space()
    
    WeaponSpawnerTab:Button({
        Title = "Spawn XenoGun",
        Icon = "crosshair",
        Color = DefaultColors.DarkGreen,
        Callback = function()
            opencrate("XenoGun")
        end
    })
end

-- */  Weapon Dupe Tab  /* --
do
    local WeaponDupeTab = ZovlaneFunctions:Tab({
        Title = "Weapon Dupe",
        Icon = "copy",
    })
    
    WeaponDupeTab:Section({
        Title = "Single Weapon Duplication",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    WeaponDupeTab:Input({
        Flag = "DupeWeaponName",
    Title = "Weapon Name",
        Desc = "Enter weapon to duplicate",
        Placeholder = "e.g., Lightbringer",
    Callback = function(text)
        WeaponName = text
    end
})

    WeaponDupeTab:Space()
    
    WeaponDupeTab:Input({
        Flag = "DupeAmount",
    Title = "Dupe Amount",
        Desc = "How many times to duplicate",
        Placeholder = "e.g., 5",
        Value = "1",
    Callback = function(text)
        FunctionCall = tonumber(text) or 1
    end
})

    WeaponDupeTab:Space()
    
    WeaponDupeTab:Button({
        Title = "Start Duplication",
        Icon = "layers",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
    Callback = function()
        if WeaponName == "" then
            WindUI:Notify({ 
                Title = "Weapon Dupe Error", 
                    Content = "Please enter a weapon name!", 
                Icon = "x-circle", 
                Duration = 5 
            })
            return
        end
        
        WindUI:Notify({ 
            Title = "Weapon Dupe", 
                Content = "Duplicating " .. WeaponName .. " " .. FunctionCall .. " times...", 
                Icon = "loader", 
                Duration = 3 
        })
        
        for i = 1, FunctionCall do
            VisualDupe()
        end
        
        WindUI:Notify({ 
                Title = "Dupe Complete", 
                Content = "Successfully duplicated " .. WeaponName .. "!", 
            Icon = "check-circle", 
            Duration = 5 
        })
    end
})

    WeaponDupeTab:Space({ Columns = 3 })
    
    WeaponDupeTab:Section({
        Title = "Inventory Duplication",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    WeaponDupeTab:Button({
        Title = "Dupe Entire Inventory",
        Icon = "package",
        Color = DefaultColors.Green,
        Justify = "Center",
    Callback = function()
        WindUI:Notify({ 
            Title = "Inventory Dupe", 
                Content = "Duplicating entire inventory...", 
                Icon = "loader", 
                Duration = 3 
        })
        
        InventoryDupe()
        
        WindUI:Notify({ 
            Title = "Inventory Dupe Complete", 
                Content = "Successfully duplicated inventory!", 
            Icon = "check-circle", 
            Duration = 5 
        })
    end
})
end

-- */  Visual Weapons Tab  /* --
do
    local VisualTab = ZovlaneFunctions:Tab({
        Title = "Visual Weapons",
        Icon = "eye-off",
    })
    
    VisualTab:Section({
        Title = "Change Weapon Appearance",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    VisualTab:Input({
        Flag = "FromWeapon",
        Title = "Weapon to Replace",
        Desc = "Current weapon you have",
        Placeholder = "e.g., Blossom",
    Callback = function(text)
        fromWeapon = text
    end
})

    VisualTab:Space()
    
    VisualTab:Input({
        Flag = "ToWeapon",
        Title = "Weapon to Receive",
        Desc = "Weapon appearance you want",
        Placeholder = "e.g., Chroma",
    Callback = function(text)
        toWeapon = text
    end
})

    VisualTab:Space()
    
    VisualTab:Button({
        Title = "Change Visual",
        Icon = "wand-2",
        Color = DefaultColors.Green,
        Justify = "Center",
    Callback = function()
        if fromWeapon == "" or toWeapon == "" then
            WindUI:Notify({ 
                Title = "Visual Weapons Error", 
                Content = "Please enter both weapon names!", 
                Icon = "x-circle", 
                Duration = 5 
            })
            return
        end
        
        local success = pcall(function()
            local Weapons = require(game:GetService("ReplicatedStorage").Database.Sync.Item)
            local foundFromWeapons = {}
            local foundToWeapons = {}
            
            for WeaponName, _ in pairs(Weapons) do
                if NameMatch(WeaponName, fromWeapon) then
                    table.insert(foundFromWeapons, WeaponName)
                end
                if NameMatch(WeaponName, toWeapon) then
                    table.insert(foundToWeapons, WeaponName)
                end
            end
            
            if #foundFromWeapons > 0 and #foundToWeapons > 0 then
                for _, foundFromWeapon in ipairs(foundFromWeapons) do
                    for _, foundToWeapon in ipairs(foundToWeapons) do
                        Weapons[foundFromWeapon] = {}
                        for i, v in pairs(Weapons[foundToWeapon]) do
                            Weapons[foundFromWeapon][i] = v
                        end
                        game:GetService("ReplicatedStorage").Remotes.Inventory.Equip:FireServer(foundToWeapon)
                    end
                end
                WindUI:Notify({ 
                        Title = "Visual Success", 
                        Content = "Weapon visual changed!", 
                    Icon = "check-circle", 
                    Duration = 5 
                })
            else
                WindUI:Notify({ 
                        Title = "Visual Error", 
                        Content = "Weapon not found!", 
                    Icon = "x-circle", 
                    Duration = 5 
                })
            end
        end)
        
        if not success then
            WindUI:Notify({ 
                    Title = "Visual Error", 
                    Content = "Failed to change visual!", 
                Icon = "x-circle", 
                Duration = 5 
            })
        end
    end
})
end

-- */  Trade Scam Tab  /* --
do
    local TradeScamTab = ZovlaneFunctions:Tab({
        Title = "Trade Scam",
        Icon = "shield-alert",
    })
    
    TradeScamTab:Section({
        Title = "Visual Trade Protection",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

local visualTradeEnabled = false

    TradeScamTab:Toggle({
        Flag = "VisualTrade",
        Title = "Enable Visual Trade",
        Desc = "Make items in trade appear visual only",
    Default = false,
        Callback = function(state)
            visualTradeEnabled = state
        WindUI:Notify({ 
            Title = "Visual Trade", 
                Content = state and "Visual Trade Enabled!" or "Visual Trade Disabled!", 
                Icon = state and "shield-check" or "shield-off",
            Duration = 3 
        })
    end
})

    TradeScamTab:Space()
    
    TradeScamTab:Button({
        Title = "Activate Visual Trade",
        Icon = "alert-triangle",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
    Callback = function()
        if not visualTradeEnabled then
            WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Enable Visual Trade first!", 
                Icon = "x-circle", 
                Duration = 5 
            })
            return
        end
        StartVisualTrade()
    end
})
end

-- */  Server Utilities Tab  /* --
do
    local UtilitiesTab = ZovlaneFunctions:Tab({
        Title = "Utilities",
        Icon = "wrench",
    })
    
    UtilitiesTab:Section({
        Title = "Server Utilities",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    UtilitiesTab:Button({
        Title = "Enable Anti-AFK",
        Icon = "moon",
        Color = DefaultColors.DarkGreen,
        Justify = "Center",
        Callback = function()
            local success = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
            end)
            
            if success then
            WindUI:Notify({ 
                    Title = "Anti-AFK", 
                    Content = "Anti-AFK enabled!", 
                    Icon = "check-circle", 
                Duration = 3 
            })
            else
            WindUI:Notify({ 
                    Title = "Anti-AFK Error", 
                    Content = "Failed to load Anti-AFK!", 
                    Icon = "x-circle", 
                Duration = 5 
            })
        end
    end
})

    UtilitiesTab:Space()
    
    UtilitiesTab:Button({
        Title = "Server Lagger",
        Icon = "zap",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
    Callback = function()
        WindUI:Notify({ 
            Title = "Server Lagger", 
                Content = "Lagging server... Risk of disconnect!", 
            Icon = "alert-triangle", 
            Duration = 5 
        })
        
            pcall(function()
            local e = game:GetService("ReplicatedStorage").GetSyncData
            local InvokeServer = e.InvokeServer
            local spawn = task.spawn
                local a = 0
            while 1 do
                for i=1, 1 do
                    spawn(InvokeServer, e)
                end
                a = a + 1
                if a == 3 then
                    a = 0
                    wait(0)
                end
            end
        end)
    end
})
end


-- */  Innocent Tab  /* --
do
    local InnocentTab = ZovlaneFunctions:Tab({
        Title = "Innocent",
        Icon = "user-check",
    })
    
    InnocentTab:Section({
                Title = "Gun System",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    InnocentTab:Toggle({
        Flag = "AutoGrabGun",
    Title = "Auto Grab Gun",
        Desc = "Automatically collect dropped gun",
    Default = false,
    Callback = function(state)
            GunSystem.AutoGrabEnabled = state
        if state then
                coroutine.wrap(AutoGrabGun)()
            WindUI:Notify({
                    Title = "Auto Grab Gun",
                    Content = "Auto grab enabled!",
                Icon = "check-circle",
                Duration = 3
                })
        else
            WindUI:Notify({
                    Title = "Auto Grab Gun",
                    Content = "Auto grab disabled",
                    Icon = "x-circle",
                Duration = 3
                })
        end
    end
    })
    
    InnocentTab:Space()
    
    InnocentTab:Button({
        Title = "Grab Gun Manually",
        Icon = "hand",
        Color = DefaultColors.Blue,
        Justify = "Center",
    Callback = function()
            GrabGun()
        end
    })
    
    InnocentTab:Space()
    
    InnocentTab:Toggle({
        Flag = "NotifyGunDrop",
        Title = "Notify Gun Drop",
        Desc = "Get notified when gun drops",
        Default = true,
        Callback = function(state)
            GunSystem.NotifyGunDrop = state
        end
    })
end

-- */  Murderer Tab  /* --
do
    local MurdererTab = ZovlaneFunctions:Tab({
        Title = "Murderer",
        Icon = "knife",
    })
    
    MurdererTab:Section({
        Title = "Kill Functions",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    MurdererTab:Toggle({
        Flag = "KillAll",
        Title = "Kill All Players",
        Desc = "Automatically attack nearby targets",
        Default = false,
        Callback = function(state)
            if state then
                killTargets()
        WindUI:Notify({
                    Title = "Kill All",
                    Content = "Attack sequence started!",
                    Icon = "zap",
            Duration = 2
                })
            else
                stopKilling()
    WindUI:Notify({
                    Title = "Kill All",
                    Content = "Attack stopped",
        Icon = "x-circle",
        Duration = 2
                })
            end
        end
    })
    
    MurdererTab:Space()
    
    MurdererTab:Slider({
        Flag = "AttackDelay",
    Title = "Attack Delay",
        Desc = "Time between attacks",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 2,
        Default = 0.5
    },
    Callback = function(value)
            attackDelay = value
        end
    })
    
    MurdererTab:Space()
    
    MurdererTab:Button({
    Title = "Equip Knife",
        Icon = "knife",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
    Callback = function()
        if equipKnife() then
            WindUI:Notify({
                    Title = "Knife Equipped",
                    Content = "Knife is ready!",
                Icon = "check-circle",
                Duration = 2
                })
        else
            WindUI:Notify({
                    Title = "Error",
                Content = "No knife found!",
                Icon = "x-circle",
                Duration = 2
                })
        end
    end
    })
end

-- */  Sheriff Tab  /* --
do
    local SheriffTab = ZovlaneFunctions:Tab({
        Title = "Sheriff",
        Icon = "shield",
    })
    
    SheriffTab:Section({
        Title = "Shooting Functions",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    SheriffTab:Dropdown({
        Flag = "ShotType",
    Title = "Shot Type",
        Desc = "Choose shooting method",
        Values = {
            {Title = "Default", Icon = "target"},
            {Title = "Teleport", Icon = "zap"}
        },
    Value = "Default",
        Callback = function(option)
            shotType = option.Title
        WindUI:Notify({
                Title = "Shot Type",
                Content = "Set to: " .. option.Title,
            Icon = "check-circle",
                Duration = 2
            })
        end
    })
    
    SheriffTab:Space()
    
    SheriffTab:Button({
        Title = "Shoot Murderer",
        Icon = "crosshair",
        Color = DefaultColors.Blue,
        Justify = "Center",
        Callback = function()
            ShootMurderer()
        end
    })
end

-- */  Settings & Config Tab  /* --
do
    local SettingsTab = ZovlaneFunctions:Tab({
        Title = "Settings",
        Icon = "settings",
    })
    
    SettingsTab:Section({
        Title = "GUI Settings",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    SettingsTab:Keybind({
        Flag = "GUIKeybind",
        Title = "GUI Toggle Key",
        Desc = "Press to open/close GUI",
        Value = "G",
        Callback = function(key)
            Window:SetToggleKey(Enum.KeyCode[key])
            WindUI:Notify({
                Title = "Keybind Set",
                Content = "GUI toggle key: " .. key,
                Icon = "keyboard",
                Duration = 3
            })
        end
    })
    
    SettingsTab:Space({ Columns = 2 })
    
    SettingsTab:Section({
        Title = "Config Management",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    local ConfigName = "default"
    local ConfigManager = Window.ConfigManager
    
    local ConfigNameInput = SettingsTab:Input({
        Flag = "ConfigName",
        Title = "Config Name",
        Desc = "Name for your configuration",
        Icon = "file",
        Value = ConfigName,
        Callback = function(value)
            ConfigName = value
        end
    })
    
    SettingsTab:Space()
    
    local AllConfigs = ConfigManager:AllConfigs()
    local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil
    
    SettingsTab:Dropdown({
        Flag = "ConfigSelect",
        Title = "Load Config",
        Desc = "Select existing configuration",
        Values = AllConfigs,
        Value = DefaultValue,
        Callback = function(value)
            ConfigName = value
            ConfigNameInput:Set(value)
        end
    })
    
    SettingsTab:Space()
    
    SettingsTab:Button({
        Title = "Save Config",
        Icon = "save",
        Color = DefaultColors.Blue,
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
            if Window.CurrentConfig:Save() then
    WindUI:Notify({
                    Title = "Config Saved",
                    Content = "Saved as '" .. ConfigName .. "'",
                    Icon = "check",
        Duration = 3
                })
            end
        end
    })
    
    SettingsTab:Space()
    
    SettingsTab:Button({
        Title = "Load Config",
        Icon = "upload",
        Color = DefaultColors.Green,
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
            if Window.CurrentConfig:Load() then
    WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Loaded '" .. ConfigName .. "'",
                    Icon = "refresh-cw",
        Duration = 3
                })
            end
        end
    })
end

-- */  Info & Socials Tab  /* --
do
    local InfoTab = ZovlaneFunctions:Tab({
        Title = "Info & Socials",
        Icon = "info",
    })
    
    InfoTab:Section({
        Title = "Zovlane Hub",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    
    InfoTab:Space()
    
    InfoTab:Section({
        Title = "Enhanced MM2 script with comprehensive features including ESP, auto-farming, weapon duplication, role-specific functions, and much more! Perfect for Murder Mystery 2 players looking for an edge.",
        TextSize = 16,
        TextTransparency = 0.3,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    InfoTab:Space({ Columns = 3 })
    
    InfoTab:Section({
        Title = "Features",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    InfoTab:Space()
    
    InfoTab:Section({
        Title = "Player ESP • Auto Farm • Character Mods • Teleportation • Weapon Spawner • Weapon Duplication • Visual Weapons • Trade Scam • Role Functions • Anti-AFK • Server Utilities",
        TextSize = 15,
        TextTransparency = 0.4,
        FontWeight = Enum.FontWeight.Medium,
    })
    
    InfoTab:Space({ Columns = 3 })
    
    InfoTab:Section({
        Title = "Community & Support",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    InfoTab:Button({
    Title = "Copy Discord Invite",
        Icon = "message-circle",
        Color = DefaultColors.DarkGreen,
        Justify = "Center",
    Callback = function()
        setclipboard("https://discord.gg/8EcCWNXSnS")
        WindUI:Notify({ 
                Title = "Discord", 
                Content = "Invite copied to clipboard!", 
            Icon = "check-circle", 
            Duration = 3 
        })
    end
})

    InfoTab:Space()
    
    InfoTab:Button({
        Title = "YouTube Channel",
        Icon = "youtube",
        Color = DefaultColors.DarkRed,
        Justify = "Center",
            Callback = function()
            setclipboard("https://www.youtube.com/@zovlanexd")
                    WindUI:Notify({
                Title = "YouTube",
                Content = "Channel link copied!",
                Icon = "check-circle",
                Duration = 3
            })
        end
    })
    
    InfoTab:Space()
    
    InfoTab:Button({
        Title = "TikTok Profile",
        Icon = "music",
        Color = DefaultColors.Red,
        Justify = "Center",
            Callback = function()
            setclipboard("http://tiktok.com/@zovlanexd")
                    WindUI:Notify({
                Title = "TikTok",
                Content = "Profile link copied!",
                Icon = "check-circle",
                Duration = 3
            })
        end
    })
end

-- ========================================
-- INITIALIZATION
-- ========================================

-- Initialize ESP
updateESP()

-- Connect ESP updates
RunService.RenderStepped:Connect(function()
    if not lineESPEnabled then return end
    for player, line in pairs(tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            local rootGuiSize = workspace.CurrentCamera.ViewportSize
            if onScreen then
                line.From = Vector2.new(rootGuiSize.X / 2, rootGuiSize.Y)
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

-- Monitor player changes for ESP
local function monitorPlayer(player)
    player.CharacterAdded:Connect(function()
        local backpack = player:WaitForChild("Backpack")
        backpack.ChildAdded:Connect(updateESP)
        backpack.ChildRemoved:Connect(updateESP)
        updateESP()
    end)

    if player.Character then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(updateESP)
            backpack.ChildRemoved:Connect(updateESP)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do monitorPlayer(player) end
Players.PlayerAdded:Connect(monitorPlayer)

-- Player removal handling
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, line in pairs(tracers) do
            if line then line:Remove() end
        end
        tracers = {}
    end
end)

-- Initialize gun system
task.spawn(function()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    ScanForGunDrops()
    if GunSystem.AutoGrabEnabled then
        coroutine.wrap(AutoGrabGun)()
    end
end)

-- Set default keybind
Window:SetToggleKey(Enum.KeyCode.G)

-- Config setup
Window.CurrentConfig = Window.ConfigManager:CreateConfig("default")
Window.CurrentConfig:Save()

-- Welcome notification
WindUI:Notify({
    Title = "Zovlane Hub Loaded!",
    Content = "Welcome to Zovlane Hub! Press G to toggle GUI.",
    Icon = "zap",
    Duration = 5
})

-- Auto copy Discord link after 5 seconds
task.spawn(function()
    task.wait(5)
    setclipboard("https://discord.gg/8EcCWNXSnS")
    WindUI:Notify({
        Title = "Discord Copied!",
        Content = "Join our community! Link copied to clipboard.",
        Icon = "message-circle",
        Duration = 4
    })
end)
