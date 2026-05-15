local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 HUB",
   LoadingTitle = "Welcome to MM2 HUB",
   LoadingSubtitle = "By Zick",
   ConfigurationSaving = { Enabled = true, FolderName = "MM2 HUB", FileName = "Config" }
})

-- Variables Globales
_G.FarmSpeed = 26
_G.AutoCoin = false
_G.ESP = false
_G.Noclip = false
local AimLockConnection
local NoclipConnection -- Corrección: Variable definida para evitar errores de referencia

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService") -- Corrección: Servicio faltante
local lp = Players.LocalPlayer

-- Función de búsqueda de monedas
local function getClosestCoin()
    local closestCoin = nil
    local shortestDistance = math.huge
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    if hrp then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj.Name:find("Coin") or obj.Name == "C") and obj:IsA("BasePart") then
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

-- Función para buscar la pistola
local function GetDroppedGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            return v
        end
    end
    return nil
end

-- Función para obtener al asesino
local function GetMurderer()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) then
            return v.Character
        end
    end
    return nil
end

-- Función para obtener el objetivo más cercano (Silent Aim)
local function GetClosestPlayer()
    local closestDist = math.huge
    local target = nil
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (v.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                target = v
            end
        end
    end
    return target
end

-- TAB: MOVIMIENTO
local MainTab = Window:CreateTab("Movimiento", 4483362458)
MainTab:CreateSlider({
   Name = "Velocidad",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then 
            lp.Character.Humanoid.WalkSpeed = v 
        end 
   end,
})

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v)
      _G.Noclip = v
      if _G.Noclip then
          NoclipConnection = RunService.Stepped:Connect(function()
              if _G.Noclip and lp.Character then
                  for _, part in pairs(lp.Character:GetDescendants()) do
                      if part:IsA("BasePart") then part.CanCollide = false end
                  end
              end
          end)
      else
          if NoclipConnection then NoclipConnection:Disconnect() end
      end
   end,
})

-- TAB: VISUALES
local VisualsTab = Window:CreateTab("Visuales", 4483362458)

VisualsTab:CreateToggle({
   Name = "ESP de Roles",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP = Value
      if not Value then
          for _, v in pairs(Players:GetPlayers()) do
              if v.Character and v.Character:FindFirstChild("Highlight") then
                  v.Character.Highlight:Destroy()
              end
          end
      end
      
      task.spawn(function()
          while _G.ESP do
             for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character then
                   local hi = v.Character:FindFirstChild("Highlight") or Instance.new("Highlight", v.Character)
                   hi.Adornee = v.Character
                   
                   if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                      hi.FillColor = Color3.fromRGB(255, 0, 0)
                   elseif v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") then
                      hi.FillColor = Color3.fromRGB(0, 0, 255)
                   else
                      hi.FillColor = Color3.fromRGB(0, 255, 0)
                   end
                end
             end
             task.wait(0.5)
          end
      end)
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP DropGun",
   CurrentValue = false,
   Callback = function(Value)
      _G.GunESP = Value
      task.spawn(function()
          while _G.GunESP do
             local gun = GetDroppedGun()
             if gun then
                if not gun:FindFirstChild("GunHighlight") then
                   local hi = Instance.new("Highlight", gun)
                   hi.Name = "GunHighlight"
                   hi.FillColor = Color3.fromRGB(0, 150, 255)
                   hi.OutlineColor = Color3.fromRGB(255, 255, 255)
                   Rayfield:Notify({Title = "Pistola Suelta", Content = "Marcada en AZUL NEÓN.", Duration = 3})
                end
             end
             task.wait(0.5)
          end
      end)
   end,
})

-- TAB: COMBATE
local CombatTab = Window:CreateTab("Combate", 4483362458)

CombatTab:CreateToggle({
   Name = "God Mode (Anti-Knife)",
   CurrentValue = false,
   Callback = function(Value)
      _G.GodMode = Value
      if _G.GodMode then
          task.spawn(function()
              while _G.GodMode do
                  pcall(function()
                      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                          for _, v in pairs(lp.Character:GetChildren()) do
                              if v:IsA("BasePart") then
                                  v.CanTouch = false 
                              end
                          end
                      end
                  end)
                  task.wait(0.1)
              end
          end)
      else
          if lp.Character then
              for _, v in pairs(lp.Character:GetChildren()) do
                  if v:IsA("BasePart") then v.CanTouch = true end
              end
          end
      end
   end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (Throw)",
   CurrentValue = false,
   Callback = function(Value)
      _G.SilentAimThrow = Value
      pcall(function()
          local mt = getrawmetatable(game)
          setreadonly(mt, false)
          local old = mt.__namecall
          mt.__namecall = newcclosure(function(self, ...)
              local method = getnamecallmethod()
              if _G.SilentAimThrow and method == "FireServer" and self.Name == "Throw" then
                  local target = GetClosestPlayer()
                  if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                      return old(self, target.Character.HumanoidRootPart.Position)
                  end
              end
              return old(self, ...)
          end)
      end)
   end,
})

CombatTab:CreateToggle({
   Name = "Kill Aura (Cuerpo a Cuerpo)",
   CurrentValue = false,
   Callback = function(v)
      _G.KillAura = v
      task.spawn(function()
          while _G.KillAura do
             task.wait(0.1)
             if lp.Character then
                 local knife = lp.Character:FindFirstChild("Knife") or lp.Backpack:FindFirstChild("Knife")
                 if knife and lp.Character:FindFirstChild("HumanoidRootPart") then
                    for _, p in pairs(Players:GetPlayers()) do
                       if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                          local dist = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                          if dist < 15 then
                             firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 0)
                             firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 1)
                          end
                       end
                    end
                 end
             end
          end
      end)
   end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (CFrame Lock)",
   CurrentValue = false,
   Flag = "CFrameAim",
   Callback = function(Value)
      _G.SilentAimLock = Value
      
      if _G.SilentAimLock then
          AimLockConnection = RunService.RenderStepped:Connect(function()
            if _G.SilentAimLock and lp.Character then
                local hasGun = lp.Character:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun")
                if hasGun then
                   local murderer = GetMurderer()
                   if murderer and murderer:FindFirstChild("HumanoidRootPart") then
                      if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                         workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, murderer.HumanoidRootPart.Position)
                      end
                   end
                end
            end
          end)
      else
          if AimLockConnection then AimLockConnection:Disconnect() end
      end
   end,
})

CombatTab:CreateButton({
   Name = "TP a Pistola",
   Callback = function()
      local gun = GetDroppedGun()
      if gun and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
         lp.Character.HumanoidRootPart.CFrame = gun.CFrame * CFrame.new(0, 2, 0)
      else
         Rayfield:Notify({Title = "Aviso", Content = "Pistola no encontrada o personaje no cargado.", Duration = 2})
      end
   end,
})

-- TAB AUTO-FARM
local TabFarm = Window:CreateTab("Auto-Farm", 4483362458)

TabFarm:CreateToggle({
   Name = "Auto-Farm Monedas",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoCoin = Value
      task.spawn(function()
          while _G.AutoCoin do
             local target = getClosestCoin()
             local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
             
             if target and hrp and target.Parent then
                local distance = (hrp.Position - target.Position).Magnitude
                local duration = distance / _G.FarmSpeed
                local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.1)
             else
                task.wait(0.5)
             end
          end
      end)
   end,
})

TabFarm:CreateSlider({
   Name = "Velocidad de Farm",
   Range = {10, 50},
   Increment = 1,
   CurrentValue = 26,
   Callback = function(Value) _G.FarmSpeed = Value end,
})

TabFarm:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        _G.AntiAFK = Value
        if _G.AntiAFK then
            lp.Idled:Connect(function()
                if _G.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end,
})

-- TAB SISTEMA
local TabSettings = Window:CreateTab("Sistema", 4483362458)
TabSettings:CreateButton({
   Name = "Optimizar FPS",
   Callback = function()
      setfpscap(144)
      Rayfield:Notify({
          Title = "FPS Ajustados",
          Content = "Capacidad de frames subida a 144.",
          Duration = 3,
          Image = 4483362458,
      })
   end,
})
