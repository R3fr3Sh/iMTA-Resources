ITEMS.functions = {}
ITEMS.functions["addHealth"] = function (client, item, args)
	if isFoodBroke(item) then
		return
	end
	local addedHealth = tonumber(args[1]) or 5
	setElementHealth(client, getElementHealth(client) + addedHealth)
end
--[[ITEMS.functions["addHealth"] = function (client, item, args)
	local addedHealth = tonumber(args[1]) or 5
	local maxHealth = tonumber(args[2]) or 100
	setElementHealth(client, math.min(getElementHealth(client) + addedHealth, maxHealth))
	outputChatBox("Podnosimy życie do "..math.min(getElementHealth(client) + addedHealth, maxHealth), client)
end]]--

ITEMS.functions["addFood"] = function (client, item, args)
	local addedFood = tonumber(args[1]) or 5
	outputChatBox("Dodajemy jedzenie "..addedFood, client)
end
ITEMS.functions["addWater"] = function (client, item, args)
	local addedWater = tonumber(args[1]) or 5
	outputChatBox("Dodajemy picie "..addedWater, client)
end

local aimValues = {[1] = 0.125, [2] = 0.25} -- also in eq_s
ITEMS.functions["chooseWeapon"] = function (client, item, args)
	local cWeapon = getElementData(client, "player:weapon")
	if not item.coreProperties then 
		return 
	end
	local weapon = {
		ITEMID = item.id,
		ID = ITEMS.def[item.id].weaponID,
		uid = item.coreProperties.uid,
		aim = aimValues[item.coreProperties.aim],
		laser = type(item.coreProperties.laser) == "table" and item.coreProperties.laser or nil,
		stock = type(item.coreProperties.stock) == "boolean" or nil,
		grip = tonumber(item.coreProperties.grip) or nil,
		-- clip = type(item.coreProperties.clip) == "boolean" or nil,
		ammo = tonumber(item.coreProperties.ammo) or 0,
		skin = tonumber(item.coreProperties.skin) or nil,
		barrel = tonumber(item.coreProperties.barrel) or nil,
	}
	if cWeapon and cWeapon["black"] and cWeapon["black"].ITEMID and cWeapon["black"].uid then 
		if cWeapon["black"].ITEMID == weapon.ITEMID and cWeapon["black"].uid == weapon.uid then --użył ponownie tej samej broni, więc ją zabieramy
			triggerEvent("onWeaponsSomething", client, "takePlayerWeapon", "black")
		else 
			outputChatBox("Nie możesz wyjąć dwóch broni palnych naraz!", client, 255, 168, 0)
		end
	else 
		if args.flag then
			if not exports["imta-organisations"]:doesPlayerHavePermission(client, args.flag) then
				triggerClientEvent(client, "createClientNotification", root, "Broń", "Nie masz uprawnienia potrzebnego do wyciągnięcia tej broni", "eq_gun_component", 4000,  0.6, 96, 125, 139, true)
				return
			end
		end
		triggerEvent("onWeaponsSomething", client, "givePlayerWeapon", weapon)
	end
end


ITEMS.functions["phoneUse"] = function(client, item, args)
	local item_data = {
		["phNumber"] = tonumber(item.coreProperties.phNumber),
		["phIcons"] = item.coreProperties.phIcons or "standard",
		["phCasing"] = item.coreProperties.phCasing or "iPhone",
		["phWallpaper"] = item.coreProperties.phWallpaper or "wp1",
		["phRingtone"] = item.coreProperties.phRingtone or "standard",
		["phNotificationSound"] = item.coreProperties.phNotificationSound or "standard",
	}
	
	if not (item_data and item_data.phNumber and item_data.phIcons and item_data.phCasing and item_data.phWallpaper and item_data.phRingtone and item_data.phNotificationSound) then
		outputChatBox("(( Błąd PHx01! Zgłoś problem administracji lub kup przedmiot ponownie ))", client)
		return
	end
	
	local phones = getActiveItemsByID(client, 101)
	local phonesCount = 0
	for i, _ in pairs(phones) do
		phonesCount = phonesCount + 1
	end
	if (phonesCount >= 1) then
		outputChatBox("(( Nie możesz wyjąć więcej niż jednego telefonu! ))", client)
		return
	end
	
	if getElementData(client, "phone:using") then -- po zrespieniu browsera ma się pojawić
		outputChatBox("(( Możesz naraz używać tylko jednego telefonu! ))", client)
		return
	end
	
	--disableActiveItemsByItemID(client, 101, "phoneUseStop")

	--setElementData(client, "phone:using", item_data.phNumber, true) -- to się dzieje dopiero po wczytaniu browsera
	
	item.isActive = true
	return item
end

ITEMS.functions["phoneUseStop"] = function(client, item, args)
	local item_data = {
		["phNumber"] = tonumber(item.coreProperties.phNumber),
		["phIcons"] = item.coreProperties.phIcons or "standard",
		["phCasing"] = item.coreProperties.phCasing or "iPhone",
		["phWallpaper"] = item.coreProperties.phWallpaper or "wp1",
		["phRingtone"] = item.coreProperties.phRingtone or "standard",
		["phNotificationSound"] = item.coreProperties.phNotificationSound or "standard",
	}

	local objects = getElementData(client, "attachedElements")
	local newTable = {}
	if objects then
		for element, _ in pairs(objects) do
			if isElement(element) then
				if getElementModel(element) == 1949 then
					destroyElement(element)
				else
					newTable[element] = true
				end
			end
		end
	end
	setElementData(client, "attachedElements", newTable, false)
	setElementData(client, "phone:using", nil)
	
	triggerEvent("phone:disablePhone", client, client)
	
	item.isActive = false
	return item
end


function command(player, cmd, id)
	id = tonumber(id)
	if not id then
		return
	end
	local weapon = createWeapon(id, {ammo = 1000})
	giveItem(player,  weapon)
end
addCommandHandler("giveWeaponItem", command, true)

function command2(player, cmd)
	local weapon = createItem(139, {coreProperties = {health = 100}})
	giveItem(player,  weapon)
end
addCommandHandler("giveArmorItem", command2, true)