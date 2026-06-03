--// WIND UI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

--// Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

--// Variables
_G.FarmSpeed = 26
_G.AutoCoin = false
_G.ESP = false
_G.Noclip = false

local AimLockConnection
local NoclipConnection
local AntiAFKConnection

--// AUTOFARM VARIABLES
local layAnim = Instance.new("Animation")
layAnim.AnimationId = "rbxassetid://507766388"

local layTrack
local currentTween

--// Window
local Window = WindUI:CreateWindow({
    Title = "MM2 HUB",
    Icon = "rbxassetid://4483362458",
    Author = "By Zick",
    Folder = "MM2 HUB",
    Size = UDim2.fromOffset(520, 420),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

--// Tabs
local MainTab = Window:Tab({
    Title = "Movimiento",
    Icon = "move"
})

local VisualsTab = Window:Tab({
    Title = "Visuales",
    Icon = "eye"
})

local CombatTab = Window:Tab({
    Title = "Combate",
    Icon = "swords"
})

local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "coins"
})

local SystemTab = Window:Tab({
    Title = "Sistema",
    Icon = "settings"
})

--// Funciones
local function getCoinContainer()
    return workspace:FindFirstChild("Normal")
        or workspace:FindFirstChild("Map")
        or workspace
end

local function getClosestCoin()
    local closestCoin = nil
    local shortestDistance = math.huge

    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local container = getCoinContainer()

        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("BasePart")
            and (obj.Name == "Coin" or obj.Name == "C" or obj.Name:find("Coin")) then

                if obj:FindFirstChild("TouchInterest") then
                    local distance = (hrp.Position - obj.Position).Magnitude

                    if distance < shortestDistance and distance < 300 then
                        shortestDistance = distance
                        closestCoin = obj
                    end
                end
            end
        end
    end

    return closestCoin
end

local function GetDroppedGun()
    local container = getCoinContainer()

    for _, v in pairs(container:GetDescendants()) do
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            return v
        end
    end

    return nil
end

local function GetMurderer()
    for _, v in pairs(Players:GetPlayers()) do
        local char = v.Character

        if char then
            if char:FindFirstChild("Knife")
            or v.Backpack:FindFirstChild("Knife") then
                return char
            end
        end
    end

    return nil
end

local function GetClosestPlayer()
    local closestDist = math.huge
    local target = nil

    local character = lp.Character
    local myHrp = character and character:FindFirstChild("HumanoidRootPart")

    if not myHrp then
        return nil
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp then
            local char = v.Character

            if char
            and char:FindFirstChild("HumanoidRootPart")
            and char:FindFirstChild("Humanoid") then

                if char.Humanoid.Health > 0 then
                    local dist = (
                        char.HumanoidRootPart.Position
                        - myHrp.Position
                    ).Magnitude

                    if dist < closestDist then
                        closestDist = dist
                        target = v
                    end
                end
            end
        end
    end

    return target
end

local function ClearAllHighlights()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("HubHighlight") then
            v.Character.HubHighlight:Destroy()
        end
    end
end

--// ROUND ACTIVE
local function IsRoundActive()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                if plr.Backpack:FindFirstChild("Knife")
                or plr.Character:FindFirstChild("Knife")
                or plr.Backpack:FindFirstChild("Gun")
                or plr.Character:FindFirstChild("Gun") then
                    return true
                end
            end
        end
    end

    return false
end

local function ResetCharacterPhysics()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        local hum = lp.Character.Humanoid

        if layTrack then
            layTrack:Stop()
        end

        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

RunService.Stepped:Connect(function()
    if _G.AutoCoin
    and IsRoundActive()
    and lp.Character
    and lp.Character:FindFirstChild("Humanoid") then

        lp.Character.Humanoid:ChangeState(11)

        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Velocity = Vector3.zero
            end
        end
    end
end)

--// MOVIMIENTO
MainTab:Section({
    Title = "Player"
})

MainTab:Slider({
    Title = "Velocidad",
    Value = {
        Min = 16,
        Max = 250,
        Default = 16,
    },
    Callback = function(v)
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = v
        end
    end
})

MainTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        _G.Noclip = v

        if NoclipConnection then
            NoclipConnection:Disconnect()
        end

        if _G.Noclip then
            NoclipConnection = RunService.Stepped:Connect(function()
                if _G.Noclip and lp.Character then
                    for _, part in pairs(lp.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

--// VISUALES
VisualsTab:Section({
    Title = "ESP"
})

VisualsTab:Toggle({
    Title = "ESP de Roles",
    Default = false,
    Callback = function(Value)
        _G.ESP = Value

        if not Value then
            ClearAllHighlights()
            return
        end

        task.spawn(function()
            while _G.ESP do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lp and v.Character then
                        local hi = v.Character:FindFirstChild("HubHighlight")

                        if not hi then
                            hi = Instance.new("Highlight")
                            hi.Name = "HubHighlight"
                            hi.Adornee = v.Character
                            hi.Parent = v.Character
                        end

                        if v.Backpack:FindFirstChild("Knife")
                        or v.Character:FindFirstChild("Knife") then
                            hi.FillColor = Color3.fromRGB(255,0,0)

                        elseif v.Backpack:FindFirstChild("Gun")
                        or v.Character:FindFirstChild("Gun") then
                            hi.FillColor = Color3.fromRGB(0,0,255)

                        else
                            hi.FillColor = Color3.fromRGB(0,255,0)
                        end
                    end
                end

                task.wait(0.7)
            end

            ClearAllHighlights()
        end)
    end
})

VisualsTab:Toggle({
    Title = "ESP DropGun",
    Default = false,
    Callback = function(Value)
        _G.GunESP = Value

        task.spawn(function()
            while _G.GunESP do
                local gun = GetDroppedGun()

                if gun then
                    if not gun:FindFirstChild("GunHighlight") then
                        local hi = Instance.new("Highlight")

                        hi.Name = "GunHighlight"
                        hi.Adornee = gun
                        hi.FillColor = Color3.fromRGB(0,150,255)
                        hi.OutlineColor = Color3.fromRGB(255,255,255)
                        hi.Parent = gun

                        WindUI:Notify({
                            Title = "Pistola Suelta",
                            Content = "Marcada en azul.",
                            Duration = 3
                        })
                    end
                end

                task.wait(1)
            end
        end)
    end
})

--// COMBATE
CombatTab:Section({
    Title = "Combat"
})

CombatTab:Toggle({
    Title = "God Mode",
    Default = false,
    Callback = function(Value)
        _G.GodMode = Value

        if _G.GodMode then
            task.spawn(function()
                while _G.GodMode do
                    pcall(function()
                        if lp.Character then
                            for _, v in pairs(lp.Character:GetChildren()) do
                                if v:IsA("BasePart") and v.CanTouch then
                                    v.CanTouch = false
                                end
                            end
                        end
                    end)

                    task.wait(0.3)
                end
            end)
        else
            if lp.Character then
                for _, v in pairs(lp.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = true
                    end
                end
            end
        end
    end
})

CombatTab:Toggle({
    Title = "Silent Aim Throw",
    Default = false,
    Callback = function(Value)
        _G.SilentAimThrow = Value

        if not _G.MetatableHooked then
            _G.MetatableHooked = true

            pcall(function()
                local mt = getrawmetatable(game)
                setreadonly(mt, false)

                local old = mt.__namecall

                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()

                    if _G.SilentAimThrow
                    and method == "FireServer"
                    and self.Name == "Throw" then

                        local target = GetClosestPlayer()

                        if target
                        and target.Character
                        and target.Character:FindFirstChild("HumanoidRootPart") then

                            return old(
                                self,
                                target.Character.HumanoidRootPart.Position
                            )
                        end
                    end

                    return old(self, ...)
                end)
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(v)
        _G.KillAura = v

        task.spawn(function()
            while _G.KillAura do
                if lp.Character then
                    local knife = lp.Character:FindFirstChild("Knife")
                        or lp.Backpack:FindFirstChild("Knife")

                    local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")

                    if knife and myHrp then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= lp and p.Character then
                                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")

                                if pHrp then
                                    local dist = (
                                        myHrp.Position - pHrp.Position
                                    ).Magnitude

                                    if dist < 15 then
                                        firetouchinterest(pHrp, knife.Handle, 0)
                                        firetouchinterest(pHrp, knife.Handle, 1)
                                    end
                                end
                            end
                        end
                    end
                end

                task.wait(0.15)
            end
        end)
    end
})

CombatTab:Toggle({
    Title = "Silent Aim Lock",
    Default = false,
    Callback = function(Value)
        _G.SilentAimLock = Value

        if AimLockConnection then
            AimLockConnection:Disconnect()
        end

        if _G.SilentAimLock then
            AimLockConnection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("Gun") then
                    local murderer = GetMurderer()

                    if murderer
                    and murderer:FindFirstChild("HumanoidRootPart") then

                        if UserInputService:IsMouseButtonPressed(
                            Enum.UserInputType.MouseButton2
                        ) then

                            workspace.CurrentCamera.CFrame =
                                CFrame.lookAt(
                                    workspace.CurrentCamera.CFrame.Position,
                                    murderer.HumanoidRootPart.Position
                                )
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:Button({
    Title = "TP a Pistola",
    Callback = function()
        local gun = GetDroppedGun()

        if gun
        and lp.Character
        and lp.Character:FindFirstChild("HumanoidRootPart") then

            lp.Character.HumanoidRootPart.CFrame =
                gun.CFrame * CFrame.new(0,2,0)

        else
            WindUI:Notify({
                Title = "Aviso",
                Content = "Pistola no encontrada.",
                Duration = 3
            })
        end
    end
})

--// FARM
FarmTab:Section({
    Title = "Coins"
})

FarmTab:Toggle({
    Title = "Auto Farm Coins",
    Default = false,
    Callback = function(Value)
        _G.AutoCoin = Value

        if not Value then
            ResetCharacterPhysics()
            return
        end

        task.spawn(function()
            while _G.AutoCoin do
                task.wait(0.1)

                if not IsRoundActive() then
                    ResetCharacterPhysics()

                    repeat
                        task.wait(1)
                    until IsRoundActive() or not _G.AutoCoin
                end

                local hrp = lp.Character
                    and lp.Character:FindFirstChild("HumanoidRootPart")

                local hum = lp.Character
                    and lp.Character:FindFirstChild("Humanoid")

                local target = getClosestCoin()

                if hum and (not layTrack or not layTrack.IsPlaying) then
                    pcall(function()
                        layTrack = hum:LoadAnimation(layAnim)
                        layTrack.Looped = true
                        layTrack:Play()
                    end)

                    hum:SetStateEnabled(
                        Enum.HumanoidStateType.GettingUp,
                        false
                    )
                end

                if target and hrp and target.Parent then
                    firetouchinterest(hrp, target, 0)

                    local pos = target.Position - Vector3.new(0, 4.3, 0)

                    if currentTween then
                        currentTween:Cancel()
                    end

                    local distance = (
                        hrp.Position - pos
                    ).Magnitude

                    currentTween = TweenService:Create(
                        hrp,
                        TweenInfo.new(
                            distance / _G.FarmSpeed,
                            Enum.EasingStyle.Linear
                        ),
                        {
                            CFrame = CFrame.new(pos)
                        }
                    )

                    currentTween:Play()

                    repeat
                        task.wait()
                    until
                        not target
                        or not target.Parent
                        or not _G.AutoCoin
                        or not IsRoundActive()
                        or (hrp.Position - pos).Magnitude < 1.5

                    if target and target.Parent then
                        firetouchinterest(hrp, target, 1)
                    end
                end
            end

            ResetCharacterPhysics()
        end)
    end
})

FarmTab:Slider({
    Title = "Farm Speed",
    Value = {
        Min = 10,
        Max = 50,
        Default = 26,
    },
    Callback = function(Value)
        _G.FarmSpeed = Value
    end
})

FarmTab:Toggle({
    Title = "Anti AFK",
    Default = true,
    Callback = function(Value)
        _G.AntiAFK = Value

        if AntiAFKConnection then
            AntiAFKConnection:Disconnect()
        end

        if _G.AntiAFK then
            AntiAFKConnection = lp.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

--// SISTEMA
SystemTab:Section({
    Title = "Optimization"
})

SystemTab:Button({
    Title = "Optimizar FPS",
    Callback = function()
        setfpscap(144)

        WindUI:Notify({
            Title = "FPS",
            Content = "FPS limitados a 144.",
            Duration = 3
        })
    end
})

--// Notify Inicial
WindUI:Notify({
    Title = "MM2 HUB",
    Content = "Convertido correctamente a WindUI",
    Duration = 5
})
