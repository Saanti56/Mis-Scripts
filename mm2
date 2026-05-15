local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 ELITE HUB | Silent Aim Edition",
   LoadingTitle = "Configurando Silent Aim...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FolderName = "MM2_Elite", FileName = "Config" }
})

-- Variables
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Función para buscar la pistola
local function GetDroppedGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            return v
        end
    end
    return nil
end

-- Función para obtener el objetivo más cercano (Silent Aim)
local function GetClosestPlayer()
    local closestDist = math.huge
    local target = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local dist = (v.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
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
   Callback = function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end,
})

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v)
      _G.Noclip = v
      RunService.Stepped:Connect(function()
         if _G.Noclip and lp.Character then
            for _, part in pairs(lp.Character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = false end
            end
         end
      end)
   end,
})

-- TAB: VISUALES
local VisualsTab = Window:CreateTab("Visuales", 4483362458)

VisualsTab:CreateToggle({
   Name = "ESP Jugadores (Roles)",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP = Value
      spawn(function()
         while _G.ESP do
            for _, v in pairs(Players:GetPlayers()) do
               if v ~= lp and v.Character then
                  local hi = v.Character:FindFirstChild("Highlight") or Instance.new("Highlight", v.Character)
                  if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                     hi.FillColor = Color3.fromRGB(255, 0, 0)
                  elseif v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") then
                     hi.FillColor = Color3.fromRGB(0, 0, 255)
                  else
                     hi.FillColor = Color3.fromRGB(0, 255, 0)
                  end
               end
            end
            task.wait(1)
         end
      end)
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Pistola (AZUL NEÓN)",
   CurrentValue = false,
   Callback = function(Value)
      _G.GunESP = Value
      spawn(function()
         while _G.GunESP do
            local gun = GetDroppedGun()
            if gun then
               if not gun:FindFirstChild("GunHighlight") then
                  local hi = Instance.new("Highlight", gun)
                  hi.Name = "GunHighlight"
                  hi.FillColor = Color3.fromRGB(0, 150, 255)
                  hi.OutlineColor = Color3.fromRGB(255, 255, 255)
                  hi.Adornee = gun
                  Rayfield:Notify({Title = "Pistola Suelta", Content = "Marcada en AZUL NEÓN.", Duration = 3})
               end
            end
            task.wait(0.5)
         end
      end)
   end,
})

-- TAB: COMBATE (SILENT AIM & KILL AURA)
local CombatTab = Window:CreateTab("Combate", 4483362458)

CombatTab:CreateToggle({
   Name = "Silent Aim (Lanzar Cuchillo)",
   CurrentValue = false,
   Flag = "MurdererSilent",
   Callback = function(Value)
      _G.SilentAim = Value
      spawn(function()
         local metatable = getrawmetatable(game)
         setreadonly(metatable, false)
         local oldNamecall = metatable.__namecall
         
         metatable.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if _G.SilentAim and method == "FireServer" and self.Name == "Throw" then
               local target = GetClosestPlayer()
               if target and target.Character then
                  args[1] = target.Character.HumanoidRootPart.Position
                  return self:FireServer(unpack(args))
               end
            end
            return oldNamecall(self, unpack(args))
         end)
      end)
   end,
})

CombatTab:CreateToggle({
   Name = "Kill Aura (Cuerpo a Cuerpo)",
   CurrentValue = false,
   Callback = function(v)
      _G.KillAura = v
      while _G.KillAura do
         task.wait(0.1)
         local knife = lp.Character:FindFirstChild("Knife")
         if knife and knife:IsA("Tool") then
            for _, p in pairs(Players:GetPlayers()) do
               if p ~= lp and p.Character and (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                  firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 0)
                  firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 1)
               end
            end
         end
      end
   end,
})

CombatTab:CreateButton({
   Name = "TP a Pistola",
   Callback = function()
      local gun = GetDroppedGun()
      if gun then
         lp.Character.HumanoidRootPart.CFrame = gun.CFrame * CFrame.new(0, 2, 0)
      else
         Rayfield:Notify({Title = "Aviso", Content = "Pistola no encontrada.", Duration = 2})
      end
   end,
})

-- TAB: SISTEMA
local SysTab = Window:CreateTab("Sistema", 4483362458)

SysTab:CreateButton({
   Name = "FPS Boost",
   Callback = function()
      for _, v in pairs(game:GetDescendants()) do
         if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
      end
   end,
})

Rayfield:LoadConfiguration()
