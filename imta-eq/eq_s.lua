local ITEMS = ITEMS
local SQL = exports["imta-db_server"]
-- local EQ = {}
local EQ_SAVE_TIME = 120000 --we save eq on every update and after EQ_SAVE_TIME 
local possiblePhoneData = exports["imta-phone"]:getPhoneData() or {}


function compressEQ(EQ)
	local compressedEQ = {}
	for i, item in ipairs(EQ) do
		if item.isActive and ITEMS.def[item.id].saveActiveInDatabase then
			if item.coreProperties then
				item.coreProperties.isActive = true
			end
		end
		compressedEQ[i] = {}
		compressedEQ[i]["i"] = item.id
		compressedEQ[i]["c"] = item.count
		if item.health then
			compressedEQ[i]["h"] = item.health
		end
		if item.subtype then
			compressedEQ[i]["s"] = item.subtype
		end
		if item.coreProperties then
			compressedEQ[i]["p"] = item.coreProperties
		end
	end	
	return base64Encode(toJSON(compressedEQ, true))
end 

function decompressEQ(EQ)
	EQ = fromJSON(base64Decode(EQ))
	local decompressedEQ  = {}
	for i, item in ipairs(EQ) do
		decompressedEQ[i] = {}
		decompressedEQ[i]["id"] = item.i
		decompressedEQ[i]["count"] = item.c
		if item.h then
			decompressedEQ[i]["health"] = item.h
		end
		if item.s then
			decompressedEQ[i]["subtype"] = item.s
		end
		if item.p then
			decompressedEQ[i]["coreProperties"] = item.p
			if item.p.isActive then
				--outputChatBox("")
				--decompressedEQ[i]["coreProperties"].isActive = true
				--TODO:
			end

		end
	end	
	return decompressedEQ
end
 

function savePlayerEQ(player, forced)
	local EQ = getElementData(player, "EQ")
	local lastEQSaveTick = getElementData(player, "lastEQSaveTick") or 0
	if (lastEQSaveTick + EQ_SAVE_TIME < getTickCount()) or forced then
		setElementData(player, "lastEQSaveTick", getTickCount(), false)
		local cid = getElementData(player, "character:id")
		if not EQ or not cid then
			return
		end
		EQ = compressEQ(EQ)
		SQL:query("UPDATE `imta_characters` SET `char_eq`= ? WHERE `char_id` = ?", EQ, cid)
	end
end

function getPlayerEQFromCID(cid)
	for i, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "character:id") == cid then 
			if getElementData(player, "EQ") then 
				return getElementData(player, "EQ")
			else
				return false
			end
		end
	end
	local EQ = SQL:query("SELECT `char_eq` FROM `imta_characters` WHERE `char_id` = ?", cid)
	if EQ and EQ.char_eq then 
		decompressEQ(EQ)
	end
	return false
end

function showPlayerEQ(player, state) --TODO: ADD TO META
	if not getElementData(player, "EQ:hide") then
		triggerClientEvent(player, "onServerDemandEQVIsibilityChange", resourceRoot, state)
		exports["imta-controls"]:toggleCustomControl(player, "fire", not state)
	end
end 

addEvent("onPlayerDemandEQShowChange", true)
addEventHandler("onPlayerDemandEQShowChange", resourceRoot, function(state) showPlayerEQ(client, state) end)

function setPlayerEQVisibility(player, state) --TODO: ADD TO META
	setElementData(player, "EQ:hide", state, false)
	if getElementData(player, "EQ:hide") then
		triggerClientEvent(player, "onServerDemandEQVIsibilityChange", resourceRoot, false)
	end
end


local function compareItems(fItem, sItem)
	if not fItem or not sItem then 
		outputDebugString( "Próba porównania przedmiotów bez przedmiotów")
		return false
	elseif not tonumber(fItem.id) or not tonumber(sItem.id) then
		outputDebugString("Próba porównania przedmiotów bez przypisanego ID")
		return false
	elseif fItem.id ~= sItem.id then 
		return false
	elseif fItem.subtype ~= sItem.subtype then 
		return false
	end
	if (type(fItem.coreProperties) == "table" and type(sItem.coreProperties) == "table")  then 
		if not table.compare(fItem.coreProperties, sItem.coreProperties) then
			return false
		end
	else
		if fItem.coreProperties ~= sItem.coreProperties then
			return false
		end
	end
	return true
end

local function sortEQ(a, b)
	if ITEMS.categories[ITEMS.def[a.id].category] < ITEMS.categories[ITEMS.def[b.id].category] then
		return true
	elseif ITEMS.categories[ITEMS.def[a.id].category] > ITEMS.categories[ITEMS.def[b.id].category] then
		return false
	elseif getItemName(a.id, a.coreProperties) < getItemName(b.id, b.coreProperties) then
		return true
	elseif getItemName(a.id, a.coreProperties) > getItemName(b.id, b.coreProperties) then
		return false
	else
		return (a.subtype or -1) < (b.subtype or -1)
	end
end

function sortEQTable(EQ)
	table.sort(EQ, sortEQ)
	return EQ
end 

function createItem(id, properties)
	if not id then
		return false
	end
	local item = {}
	item.id = id
	if properties then
		item.count = tonumber(properties.count) or 1
		item.health = tonumber(properties.health) or nil
		item.subtype = tonumber(properties.subtype) or nil
		item.coreProperties = type(properties.coreProperties) == "table" and table.copy(properties.coreProperties) or nil
	else 
		item.count = 1
	end
	return item
end

local aimValues = {[1] = 0.125, [2] = 0.25} --also in eq_functions_s.lua
local barrelValues = {[1] = true, [2] = true} --also in eq_functions_s.lua
function createWeapon(id, gunProperties)
	if not id then
		return false
	end
	local item = {}
	item.id = id
	local wid =  ITEMS.def[item.id].weaponID
	item.count = 1
	item.subtype = tonumber(gunProperties.subtype) or nil
	item.coreProperties = {}
	item.coreProperties.aim = aimValues[gunProperties.aim] and gunProperties.aim or nil
	item.coreProperties.laser = type(gunProperties.laser) == "table" and gunProperties.laser or nil
	item.coreProperties.stock = type(gunProperties.stock) == "boolean" or nil
	item.coreProperties.grip = tonumber(gunProperties.grip) or nil
	-- item.coreProperties.clip = type(gunProperties.clip) == "boolean" or nil
	item.coreProperties.barrel = barrelValues[tonumber(gunProperties.barrel)] and tonumber(gunProperties.barrel) or nil
	item.coreProperties.ammo = tonumber(gunProperties.ammo) or 0
	item.coreProperties.skin = tonumber(gunProperties.skin) or nil

	local uid =  SQL:getFirstRow("SELECT current_id FROM `imta_weapons_indices` WHERE `weapon_id` = ?", wid)
	local nr =  SQL:query("UPDATE `imta_weapons_indices` SET `current_id` = `current_id` + 1 WHERE `weapon_id` = ?", wid)
	if not uid or not nr or not tonumber(uid.current_id) then
		outputDebugString("Wystąpił błąd w trakcie tworzenia broni. Wartość: "..tostring(uid)..":"..tostring(uid and uid.current_id and uid.current_id or "BRAK")..":"..tostring(nr)..":")
		return false
	end
	item.coreProperties.uid = tonumber(uid.current_id)
	-- itemid = x
	-- id = x
	-- uid = x
	-- aim = nil/1/2 -- 1 - w. 0.2 2 - w. 0.4
	-- laser = nil/{r, g, b}
	-- stock = nil/true
	-- grip = nil/0/1 -- 0 ergo, 1 pionowy
	-- clip = nil/true
	-- ammo = x
	-- skin = ID tekstury albo nil

	return item
end

function createPhone(casing, icons, number)
	assert(possiblePhoneData and possiblePhoneData["phoneCasings"] and possiblePhoneData["phoneCasings"][casing], "Phone casing doesn't exists, got "..casing)
	assert(possiblePhoneData["phoneIcons"] and possiblePhoneData["phoneIcons"][icons], "Phone icons doesn't exists, got "..icons)
	local wallpaper = possiblePhoneData[wallpaper]
	local ringtone = possiblePhoneData[ringtone]
	local notification = possiblePhoneData[notification]
	
	if not number then
		local query = exports["imta-db_server"]:getFirstRow("SELECT used_number FROM imta_phone_used_numbers ORDER BY used_number DESC LIMIT 1")
		number = query.used_number + 1
	end
	exports["imta-db_server"]:query("INSERT INTO imta_phone_used_numbers (used_number) VALUES (?)", number)
	
	local item = {}
	item.id = 101
	item.count = 1
	item.coreProperties = {}
	item.coreProperties.phNumber = number
	item.coreProperties.phIcons = icons
	item.coreProperties.phCasing = casing
	item.coreProperties.phWallpaper = wallpaper
	item.coreProperties.phRingtone = ringtone
	item.coreProperties.phNotificationSound = notification

	return item
end

function findItem(EQ, item)
	for i, searchedItem in ipairs(EQ) do
		if compareItems(searchedItem, item) then
			return true, i
		end
	end
	return false
end

--local tester = getPlayerFromName("Refresh_Hyperionowy")

function getItemStackIndex(client, itemToBeFound)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, itemToBeFound)
	if not hasItem then 
		return false
	end
	return stackIndex
end

function getItem(client, itemToBeFound)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, itemToBeFound)
	if not hasItem then 
		return false
	end
	return table.copy(EQ[stackIndex])
end

function getItemsByID(client, itemID)
	local EQ = getElementData(client, "EQ")
	local newEQ = {}
	for i, item in ipairs(EQ) do
		if item.id == itemID then 
			newEQ[i] = item
		end 
	end
	return newEQ
end 

function getActiveItemsByID(client, itemID)
	local EQ = getItemsByID(client, itemID)
	local activeEQ = {}
	for i, item in pairs(EQ) do 
		if item.isActive then 
			activeEQ[i] = item
		end
	end
	return activeEQ
end


function takeItemByStackIndex(client, stackIndex)
	local EQ = getElementData(client, "EQ")
	if not tonumber(stackIndex) then	
		return
	end
	local item = table.remove(EQ, stackIndex)
	setElementData(client, "EQ", EQ, false)
	triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, stackIndex, "REMOVED") 
	savePlayerEQ(client, false)
	return true, item.count
end

function takeItem(client, itemToBeTaken, all)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, itemToBeTaken)
	if not hasItem then 
		return false
	end
	local item = EQ[stackIndex]
	if not all and item.count < itemToBeTaken.count then
		return false
	elseif all or item.count == itemToBeTaken.count then
		table.remove(EQ, stackIndex)
		setElementData(client, "EQ", EQ, false)
		triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, stackIndex, "REMOVED")
		savePlayerEQ(client, false)
		return true, item.count
	elseif item.count > itemToBeTaken.count then
		EQ[stackIndex].count = EQ[stackIndex].count - itemToBeTaken.count
		setElementData(client, "EQ", EQ, false)
		triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, stackIndex, "CHANGED")
		savePlayerEQ(client, false)
		return true, EQ[stackIndex].count
	end
end

function disableActiveItemsByItemID(client, itemID, functionName)
	items = exports["imta-eq"]:getActiveItemsByID(client, itemID)
	for i, item in pairs(items) do
		local EQ = getElementData(client, "EQ")
		if functionName then
			local item = ITEMS.functions[functionName](client, item, ITEMS.def[item.id].functions[functionName])
		end
		EQ[i] = item
		setElementData(client, "EQ", EQ, false)
		triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, i, "CHANGED") 
	end
end

function giveItem(client, item)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, item)
	if hasItem and ITEMS.def[item.id].isStackable then
		EQ[stackIndex].count = EQ[stackIndex].count + item.count
		setElementData(client, "EQ", EQ, false)
		triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, stackIndex, "CHANGED") 
		savePlayerEQ(client, false)
	else
		item = table.copy(item)
		table.insert(EQ, item)
		table.sort(EQ, sortEQ)
		setElementData(client, "EQ", EQ, false)
		hasItem, stackIndex = findItem(EQ, item)
		triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, stackIndex, "INSERTED") 
		savePlayerEQ(client, false)
	end
end


function getEQTradeableItems(EQ)
	local onlyTradeEQ = {}
	for i, item in ipairs(EQ) do
		if not ITEMS.def[item.id].forbiddenTrade and not item.isActive then 
			table.insert(onlyTradeEQ, item)
		end
	end
	return onlyTradeEQ
end
--[[setTimer(function()
	local DOSKASOWANIABAAAAAAAAAAAAAAA = createWeapon(13, {ammo = 150, aim = nil, laser = {r = 0, g = 168, b = 255}})
	giveItem(getPlayerFromName("Remigiusz_Maciaszek"), DOSKASOWANIABAAAAAAAAAAAAAAA)
end, 1000, 1)]]

addEvent("onPlayerUseItem", true)
function useItem(item, player)
	local client = client or player
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, item)
	if hasItem then
		if item.isActive then 
			outputChatBox("Nie możesz użyć tego przedmiotu!", client)
		end
		if type(ITEMS.def[item.id].functions) == "table" then
			local newItem
			for functionName, args in pairs(ITEMS.def[item.id].functions) do
				newItem = ITEMS.functions[functionName](client, item, args)
			end
			if ITEMS.def[item.id].isLostOnUse and not newItem then --right check was added last 
				if EQ[stackIndex].count <= 1 then 
					table.remove(EQ, stackIndex)
					setElementData(client, "EQ", EQ, false)
					triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "REMOVED") 
					savePlayerEQ(client, false)
				else 
					if newItem then
						EQ[stackIndex] = newItem -- if new item is returned then we replace the old one and THEN we decrease it's aomunt
					end
					EQ[stackIndex].count = EQ[stackIndex].count - 1
					setElementData(client, "EQ", EQ, false)
					triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "CHANGED") 
					savePlayerEQ(client, false)
				end
			else 
				EQ = getElementData(client, "EQ")
				if newItem then
					EQ[stackIndex] = newItem -- if new item is returned then we replace the old one
				end
				setElementData(client, "EQ", EQ, false)
				triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "CHANGED") 
				savePlayerEQ(client, false)
			end
		end
	else
		outputChatBox("Próbujesz użyć przedmiotu którego nie masz w ekwipunku!", client)
		return
	end
end
addEventHandler("onPlayerUseItem", resourceRoot, useItem)

addEvent("onPlayerStopUseItem", true)
function stopUseItem(item, player)
	local client = client or player
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, item)

	if hasItem and item.isActive then
		if type(ITEMS.def[item.id].functions) == "table" then
			local newItem
			for functionName, args in pairs(ITEMS.def[item.id].functions) do
				newItem = ITEMS.functions[functionName.."Stop"](client, item, args)
			end
			if ITEMS.def[item.id].isLostOnUse then
				if EQ[stackIndex].count <= 1 then 
					table.remove(EQ, stackIndex)
					setElementData(client, "EQ", EQ, false)
					triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "REMOVED") 
					savePlayerEQ(client, false)
				else 
					if newItem then
						EQ[stackIndex] = newItem -- if new item is returned then we replace the old one and THEN we decrease it's aomunt
					end
					EQ[stackIndex].count = EQ[stackIndex].count - 1
					setElementData(client, "EQ", EQ, false)
					triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "CHANGED") 
					savePlayerEQ(client, false)
				end
			else 
				if newItem then
					EQ[stackIndex] = newItem -- if new item is returned then we replace the old one
				end
				setElementData(client, "EQ", EQ, false)
				triggerClientEvent(client, "onClientEQRefresh", resourceRoot, getElementData(client, "EQ"), stackIndex, "CHANGED") 
				savePlayerEQ(client, false)
			end
		end
	else
		outputChatBox("Próbujesz użyć przedmiotu którego nie masz w ekwipunku/nie jest aktywny!", client)
		return
	end
end
addEventHandler("onPlayerStopUseItem", resourceRoot, stopUseItem)

addEvent("onPlayerModifyItem", true)
local function modifyItem(item)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, item)
	local newItem = table.copy(item)
	if hasItem then
		call(getResourceFromName(ITEMS.def[item.id].exportedFunctionResource), ITEMS.def[item.id].exportedFunctionName, client, item, newItem)
	end
end
addEventHandler("onPlayerModifyItem", resourceRoot, modifyItem)


addEvent("onPlayerDropItem", true)
local function dropItem(item, all)
	local EQ = getElementData(client, "EQ")
	local hasItem, stackIndex = findItem(EQ, item)
	if hasItem  then
		if ITEMS.def[item.id].forbiddenDrop and not item.isActive then
			outputChatBox("Tego przedmiotu nie da się wyrzucić!", client)
			return
		end
		if not all then
			item.count = 1
		end
		local result, count = takeItem(client, item, all)
		if result then
			local x, y, z = getElementPosition(client)
			local rx, ry, rz = getElementRotation(client)
			local rrz = math.rad(rz + 180)
			x = x - (1 * math.sin(-rrz))
			y = y - (1 * math.cos(-rrz))
			z = z - 1
			local d = getElementDimension(client)
			local i = getElementInterior(client)
			local obj = createObject(ITEMS.def[item.id].pickModel or 2386, x, y, z, 0, 0, rz)
			setElementDimension(obj, d)
			setElementInterior(obj, i)
			setElementData(obj, "EQ:item", item)
		end
	else
		outputChatBox("Próbujesz wyrzucić przedmiot którego nie masz w ekwipunku!", client)
		return
	end
end
addEventHandler("onPlayerDropItem", resourceRoot, dropItem)

addEventHandler("onPlayerQuit", root, function(qType, reason)
	savePlayerEQ(source, true)
end)

local function useItemsByIndex(itemsToBeUsed, player)
	local EQ = getElementData(player, "EQ", decompressedEQ, false)
	for i, itemIndex in ipairs(itemsToBeUsed) do
		useItem(EQ[itemIndex], player)
	end
end

function  setPlayerEQ(player, EQ)
	local decompressedEQ = decompressEQ(EQ)
	local itemsToBeUsed = {}
	for i, item in ipairs(decompressedEQ) do 
		if item.coreProperties and item.coreProperties.isActive then 
			table.insert(itemsToBeUsed, i)
			item.coreProperties.isActive = nil
		end 
	end
	setElementData(player, "EQ", decompressedEQ, false)
	triggerClientEvent(player, "onClientEQRefresh", resourceRoot, decompressedEQ, nil, nil, true)	
	if #itemsToBeUsed > 0 then 
		setTimer(useItemsByIndex, 2000, 1, itemsToBeUsed, player)
	end
end

function updatePlayerAmmo(player, ammo)
	local EQ  = getElementData(client, "EQ")
	local cWeapon = getElementData(client, "player:weapon")
	if cWeapon and cWeapon["black"] and cWeapon["black"].UID then
		local cUID = cWeapon["black"].UID
		for k, item in ipairs(EQ) do
			if item and item.coreProperties and item.coreProperties.uid and cUID == item.coreProperties.uid then 
				item.coreProperties.ammo = ammo
				triggerClientEvent(client, "onServerDemandInterfaceUpdate", client, )
			end
		end
	end
	setElementData(client, "EQ", EQ, false)
	triggerClientEvent(client, "onClientEQRefresh", resourceRoot, EQ, nil, nil, nil)
end

addEvent("onPlayerUpdateAmmo", true)
addEventHandler("onPlayerUpdateAmmo", resourceRoot, function(ammo)
	updatePlayerAmmo(player, ammo)
end)

addCommandHandler("purgeEQ", function(player)
	setPlayerEQ(player, base64Encode(toJSON({})))
end)



local function spawnItem(player, cmd, _itemID, _count, _subtype)
	if not _itemID then 
		outputChatBox("/dajmi <itemID> [count] [subtype]", player, 245, 245, 0)
		return
	end
	if not getElementData(player, "EQ") then 
		outputChatBox("Nie możesz używać komendy /dajmi bez ekwipunku postaci.", player, 255, 168, 0)
		return
	end
	local itemID = tonumber(_itemID)
	local count = math.abs(math.ceil(tonumber(_count) or 1))
	local subtype = tonumber(_subtype)
	subtype = subtype and math.ceil(subtype) or nil
	if not itemID or not ITEMS.def[itemID] then 
		outputChatBox("Podany przez Ciebie numer przedmiotu jest niepoprawny", player, 255, 168, 0)
		return
	elseif count < 1 then
		outputChatBox("Ilość przedmiotu musi być większa lub równa jeden.", player, 255, 168, 0)
		return
	elseif count > 1 and not ITEMS.def[itemID].isStackable then
		outputChatBox("Przedmiot który chcesz utworzyć nie może mieć większej ilości niż jeden.", player, 255, 168, 0)
		return
	elseif _subtype and not subtype then
		outputChatBox("Podany przez Ciebie podtyp przedmiotu jest niepoprawny.", player, 255, 168, 0)
		return
	end
	local item = createItem(itemID, {subtype = subtype, count=count})
	giveItem(player, item)
end
addCommandHandler("dajmi", spawnItem)

local boomboxObjects = {}

local function createPlayerBoomboxObject(player)
	local object = createObject(2226,0,0,-20)
	boomboxObjects[player] = object
	exports["bone_attach"]:attachElementToBone(object, player, 11, 0,0,0.4,0,180,0)
end

local function destroyMusic(player)
	removeElementData(player, "boombox:url")
	triggerClientEvent("destroyBoomboxSound", player, player)
	if isElement(boomboxObjects[player]) then
		destroyElement(boomboxObjects[player])
	end
end

addEvent("playBoombox", true)
addEventHandler("playBoombox", root, function(player, url)
	setElementData(player, "boombox:url", url, false)
	triggerClientEvent("playBoomboxSound", player, player, url)
	createPlayerBoomboxObject(player)
end)

addEvent("destroyBoombox", true)
addEventHandler("destroyBoombox", root, function(player)
	destroyMusic(player)
end)

function quitPlayer()
	destroyMusic(source)
end
addEventHandler("onPlayerQuit", root, quitPlayer)
addEventHandler("onPlayerWasted", root, quitPlayer)


addEvent("getBoomboxSound", true)
addEventHandler("getBoomboxSound", root, function(player)
	local url = getElementData(player, "boombox:url")
	if not url then
		return
	end
	triggerClientEvent(client, "playBoomboxSound", client, player, url)
end)

addEvent("getBoomboxSounds", true)
addEventHandler("getBoomboxSounds", root, function(players)
	local new_table = {}
	for k,v in ipairs(players) do
		local url = getElementData(v, "boombox:url")
		if url then
			table.insert(new_table, {v, url})
		end
	end
	triggerClientEvent(client, "playBoomboxSounds", client, new_table)
end)

local players = getElementsByType("player")
if #players>0 then
	for k,v in ipairs(players) do
		local url = getElementData(v, "boombox:url")
		if url then
			createPlayerBoomboxObject(v)
		end
	end
end