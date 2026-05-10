-- Script para Auto-Aceptar Trades
-- Basado en la lógica de TradeRequestUI.module.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientGlobals = require(ReplicatedStorage.Client.Modules.ClientGlobals)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local TradingFlags = require(ReplicatedStorage.Shared.Flags.TradingFlags)

local SessionState = ClientGlobals.SessionState
local ActiveNegotiation = ClientGlobals.ActiveNegotiation

-- Función para verificar si ya hay un intercambio en curso
local function isNegotiationActive()
    local Data = ActiveNegotiation.Data
    return type(Data) == "table" and Data.player1 ~= nil
end

-- Función principal de Auto-Aceptar
local function autoAcceptTrades()
    -- 1. Obtener la lista de solicitudes entrantes desde el SessionState
    local incoming = SessionState:TryIndex({ "incomingTradeRequests" })
    local incomingTable = type(incoming) == "table" and incoming or {}

    -- 2. Verificar si el sistema de trading está habilitado
    if not TradingFlags.Enabled:Get() then 
        return 
    end

    -- 3. Si ya estamos en un trade, no aceptamos otros
    if isNegotiationActive() then 
        return 
    end

    -- 4. Iterar sobre las solicitudes y aceptarlas todas
    for _, senderPlayer in ipairs(incomingTable) do
        print("Auto-aceptando trade de: " .. tostring(senderPlayer.Name))
        Remotes.AcceptInvite:FireServer(senderPlayer)
    end
end

-- Monitorizar cambios en las solicitudes entrantes
SessionState:Observe({ "incomingTradeRequests" }, function()
    -- Ejecutar el auto-accept cada vez que la lista cambie
    autoAcceptTrades()
end)

print("Sistema de Auto-Accept activado.")
