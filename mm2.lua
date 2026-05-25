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
local NoclipConnection
local AntiAFKConnection -- Optimización: Guardar conexión para evitar duplicados

-- Servicios (Localizados para mayor velocidad)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- OPTIMIZACIÓN CRÍTICA: Buscar contenedores específicos en lugar de usar todo el Workspace
local function getCoinContainer()
    return workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map") or workspace
end

-- Función de búsqueda de monedas optimizada
local function getClosestCoin()
    local closestCoin = nil
    local shortestDistance = math.huge
    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local container = getCoinContainer()
        -- Buscamos solo en los descendientes directos del contenedor del mapa actual
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "C" or obj.Name:find("Coin")) then
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

-- Función para buscar la pistola optimizada (No usa GetDescendants en todo el workspace)
local function GetDroppedGun()
    local container = getCoinContainer()
    for _, v in pairs(container:GetDescendants()) do
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            return v
        end
    end
    return nil
end

-- Función para obtener al asesino (Optimizada)
local function GetMurderer()
    for _, v in pairs(Players:GetPlayers()) do
        local char = v.Character
        if char then
            if char:FindFirstChild("Knife") or v.Backpack:FindFirstChild("Knife") then
                return char
            end
        end
    end
    return nil
end

-- Función para obtener el objetivo más cercano (Silent Aim)
local function GetClosestPlayer()
    local closestDist = math.huge
    local target = nil
    local character = lp.Character
    local myHrp = character and character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp then
            local char = v.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health > 0 then
                    local dist = (char.HumanoidRootPart.Position - myHrp.Position).Magnitude
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
      if NoclipConnection then NoclipConnection:Disconnect() end
      
      if _G.Noclip then
          NoclipConnection = RunService.Stepped:Connect(function()
              if _G.Noclip and lp.Character then
                  for _, part in pairs(lp.Character:GetChildren()) do -- Optimizada: GetChildren en vez de GetDescendants
                      if part:IsA("BasePart") then part.CanCollide = false end
                  end
              else
                  if NoclipConnection then NoclipConnection:Disconnect() end
              end
          end)
      end
   end,
})

-- TAB: VISUALES
local VisualsTab = Window:CreateTab("Visuales", 4483362458)

-- Función auxiliar para limpiar Highlights y evitar fugas de memoria
local function ClearAllHighlights()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("HubHighlight") then
            v.Character.HubHighlight:Destroy()
        end
    end
end

VisualsTab:CreateToggle({
   Name = "ESP de Roles",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP = Value
      if not Value then
          ClearAllHighlights()
          return
      end
      
      task.spawn(function()
          while _G.ESP do
             for _, v in pairs(Players:GetPlayers()) do
                if not _G.ESP then break end -- Freno de seguridad
                if v ~= lp and v.Character then
                   local hi = v.Character:FindFirstChild("HubHighlight")
                   if not hi then
                       hi = Instance.new("Highlight")
                       hi.Name = "HubHighlight"
                       hi.Adornee = v.Character
                       hi.Parent = v.Character
                   end
                   
                   if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                      hi.FillColor = Color3.fromRGB(255, 0, 0)
                   elseif v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") then
                      hi.FillColor = Color3.fromRGB(0, 0, 255)
                   else
                      hi.FillColor = Color3.fromRGB(0, 255, 0)
                   end
                end
             end
             task.wait(0.7) -- Subido a 0.7s para reducir consumo de CPU sin perder respuesta visual
          end
          ClearAllHighlights()
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
                   local hi = Instance.new("Highlight")
                   hi.Name = "GunHighlight"
                   hi.Adornee = gun
                   hi.FillColor = Color3.fromRGB(0, 150, 255)
                   hi.OutlineColor = Color3.fromRGB(255, 255, 255)
                   hi.Parent = gun
                   Rayfield:Notify({Title = "Pistola Suelta", Content = "Marcada en AZUL NEÓN.", Duration = 3})
                end
             end
             task.wait(1) -- Aumentado a 1 segundo (la pistola no se mueve de lugar, no requiere refresco rápido)
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
                      if lp.Character then
                          for _, v in pairs(lp.Character:GetChildren()) do
                              if v:IsA("BasePart") and v.CanTouch then
                                  v.CanTouch = false 
                              end
                          end
                      end
                  end)
                  task.wait(0.3) -- Aumentado el delay; no hace falta spamearlo a 0.1s
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
      -- Evitamos duplicar hooks de la Metatable cada vez que se enciende/apaga
      if not _G.MetatableHooked then
          _G.MetatableHooked = true
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
      end
   end,
})

CombatTab:CreateToggle({
   Name = "Kill Aura (Cuerpo a Cuerpo)",
   CurrentValue = false,
   Callback = function(v)
      _G.KillAura = v
      task.spawn(function()
          while _G.KillAura do
             if lp.Character then
                 local knife = lp.Character:FindFirstChild("Knife") or lp.Backpack:FindFirstChild("Knife")
                 local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")
                 if knife and myHrp then
                    for _, p in pairs(Players:GetPlayers()) do
                       if p ~= lp and p.Character then
                          local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                          if pHrp then
                             local dist = (myHrp.Position - pHrp.Position).Magnitude
                             if dist < 15 then
                                 firetouchinterest(pHrp, knife.Handle, 0)
                                 firetouchinterest(pHrp, knife.Handle, 1)
                             end
                          end
                       end
                    end
                 end
             end
             task.wait(0.15) -- Ligera optimización del delay
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
      if AimLockConnection then AimLockConnection:Disconnect() end
      
      if _G.SilentAimLock then
          AimLockConnection = RunService.RenderStepped:Connect(function()
            if _G.SilentAimLock and lp.Character then
                if lp.Character:FindFirstChild("Gun") then 
                   local murderer = GetMurderer()
                   if murderer and murderer:FindFirstChild("HumanoidRootPart") then
                      if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                         workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, murderer.HumanoidRootPart.Position)
                      end
                   end
                end
            else
                if AimLockConnection then AimLockConnection:Disconnect() end
            end
          end)
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
                task.wait(0.05)
             else
                task.wait(0.4)
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
        if AntiAFKConnection then AntiAFKConnection:Disconnect() end -- Evita duplicar conexiones pesadas
        
        if _G.AntiAFK then
            AntiAFKConnection = lp.Idled:Connect(function()
                if _G.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                else
                    if AntiAFKConnection then AntiAFKConnection:Disconnect() end
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
