local sx, sy = guiGetScreenSize()
local gui = {}
local EQ = {}
local settings = {}
local currentIndex = 1
local currentMenuIndex = 1
local currentMenuItemIndex = 1

do
	if sx <= 1024 then
		settings.rowHeight = 22
		settings.rowWidth = 280
		settings.rowAmount = 10
		settings.fontItems = guiCreateFont(":imta-interface/media/fontroboto.ttf", 8)
		settings.fontHeader = guiCreateFont(":imta-interface/media/fontroboto.ttf", 12)
		settings.menuWidth = 80
	elseif sx > 1024 and sx <= 1600 then
		settings.rowHeight = 26
		settings.rowWidth = 350
		settings.rowAmount = 14
		settings.fontItems = guiCreateFont(":imta-interface/media/fontroboto.ttf", 12)
		settings.fontHeader = guiCreateFont(":imta-interface/media/fontroboto.ttf", 16)
		settings.menuWidth = 100
	else
		settings.rowHeight = 30
		settings.rowWidth = 500
		settings.rowAmount = 20
		settings.fontItems = guiCreateFont(":imta-interface/media/fontroboto.ttf", 14)
		settings.fontHeader = guiCreateFont(":imta-interface/media/fontroboto.ttf", 18)
		settings.menuWidth = 120
	end
	settings.headerSpace = (settings.rowWidth - settings.rowHeight) / settings.rowWidth
end


gui.win = guiCreateStaticImage(sx-settings.rowWidth, 0.3 * sy, settings.rowWidth, settings.rowHeight * settings.rowAmount, ":imta-interface/media/background.png", false)
	-- exports["blur_box"]:createBlurBox(sx-settings.rowWidth, 0.3 * sy, settings.rowWidth, settings.rowHeight * settings.rowAmount, 255, 255, 255, 255, false) TODO!!!
gui.header = {}
gui.header.bg = guiCreateStaticImage(0, 0, settings.rowWidth, settings.rowHeight, ":imta-interface/media/pixels/grey.png", false, gui.win)

gui.header.icon = guiCreateStaticImage(settings.rowHeight * 0.1, settings.rowHeight * 0.1, settings.rowHeight * 0.8, settings.rowHeight * 0.8, "files/icons/rucksack.png", false, gui.header.bg)
gui.header.name = guiCreateLabel(settings.rowHeight, 0,settings.rowWidth - settings.rowHeight, settings.rowHeight, " Przedmioty", false, gui.header.bg)
	guiSetFont(gui.header.name, settings.fontHeader)
	guiLabelSetColor(gui.header.name, 65, 67, 69)
	guiLabelSetVerticalAlign(gui.header.name, "center")
gui.background = guiCreateStaticImage(0, settings.rowHeight, settings.rowWidth, settings.rowHeight * (settings.rowAmount - 1), ":imta-interface/media/transparent.png", false, gui.win)
gui.rows = {}
guiSetVisible(gui.win, false)
do
	gui.emptyEQInfo = guiCreateStaticImage(0, settings.rowHeight * (settings.rowAmount - 8) / 2, settings.rowWidth, settings.rowHeight * 6, ":imta-interface/media/transparent.png", false, gui.background)
	local icon = guiCreateStaticImage(settings.rowWidth * 0.5 - settings.rowHeight * 2, settings.rowHeight * 2, settings.rowHeight * 4, settings.rowHeight * 4, "files/icons/empty-box-open.png", false, gui.emptyEQInfo)
	local name = guiCreateLabel(0, 0, settings.rowWidth, settings.rowHeight, "Nie posiadasz żadnych przedmiotów" , false, gui.emptyEQInfo)
		guiSetFont(name, settings.fontItems)
		guiLabelSetColor(name, 204, 204, 204)
		guiLabelSetVerticalAlign(name, "center")
		guiLabelSetHorizontalAlign(name, "center")
end

local function changeHighlightedRow(oldRH, newRH)
	if oldRH then
		guiStaticImageLoadImage(oldRH, ":imta-interface/media/transparent.png")
	end
	if newRH then
		guiStaticImageLoadImage(newRH, ":imta-interface/media/pixels/white.png")
	end
end

local function createRowHighlighter(parent)
	local rowHighlighter = guiCreateStaticImage(0, 0, 1, 1, ":imta-interface/media/transparent.png", true, parent)
		guiSetAlpha(rowHighlighter, 0.2)
	return rowHighlighter
end


gui.functions = {}

gui.functions.use = function()
	triggerServerEvent("onPlayerUseItem", resourceRoot, getElementData(localPlayer, "EQ")[currentIndex])
end

gui.functions.stopUse = function()
	triggerServerEvent("onPlayerStopUseItem", resourceRoot, getElementData(localPlayer, "EQ")[currentIndex])
end

gui.functions.modify = function()
	triggerServerEvent("onPlayerModifyItem", resourceRoot, getElementData(localPlayer, "EQ")[currentIndex])
end

local function isUpgradePossible(possibleUpgrades, wid)
	for k, id in ipairs(possibleUpgrades or {}) do
		if wid == id then 
			return true
		end
	end
	return false
end

gui.functions.info = function()
	local item = getElementData(localPlayer, "EQ")[currentIndex]
	outputChatBox(getItemName(item.id, item.coreProperties)..": "..ITEMS.def[item.id].description)
	local wid  = tonumber(ITEMS.def[item.id].weaponID)
	-- White weapons:
	if wid and type(item.coreProperties) == "table" then
		if tonumber(item.coreProperties.uid) then
			outputChatBox("Numer seryjny: "..item.coreProperties.uid, 235, 235, 235)
		end
		local aimT = tonumber(item.coreProperties.aim)
		if aimT then 
			if aimT == 1 then 
				outputChatBox("Celownik: kolimatorowy", 235, 235, 235)
			elseif aimT == 2 then 
				outputChatBox("Celownik: ACOG", 235, 235, 235)
			end
		elseif isUpgradePossible(ITEMS.def[17].allowedIN, wid) or isUpgradePossible(ITEMS.def[18].allowedIN, wid) then
			outputChatBox("Celownik: brak", 235, 235, 235)
		end
		if type(item.coreProperties.stock) == "boolean" and item.coreProperties.stock then
			outputChatBox("Kolba: Zainstalowana", 235, 235, 235)
		elseif isUpgradePossible(ITEMS.def[24].allowedIN, wid) then
			outputChatBox("Kolba: brak", 235, 235, 235)
		end
		local grip = tonumber(item.coreProperties.grip)
		if grip then 
			if grip == 1 then 
				outputChatBox("Chwyt: pochylony", 235, 235, 235)
			elseif grip == 2 then
				outputChatBox("Chwyt: ERGO", 235, 235, 235)
			end
		elseif isUpgradePossible(ITEMS.def[22].allowedIN, wid) or isUpgradePossible(ITEMS.def[23].allowedIN, wid) then
			outputChatBox("Chwyt: brak", 235, 235, 235)
		end
		local barrel = tonumber(item.coreProperties.barrel)
		if barrel then 
			if barrel == 1 then 
				outputChatBox("Lufa: tłumik", 235, 235, 235)
			elseif barrel == 2 then
				outputChatBox("Lufa: ciężka lufa", 235, 235, 235)
			end
		elseif isUpgradePossible(ITEMS.def[19].allowedIN, wid) or isUpgradePossible(ITEMS.def[20].allowedIN, wid) then
			outputChatBox("Lufa: brak modyfikacji", 235, 235, 235)
		end
		if type(item.coreProperties.laser) == "table" then
			outputChatBox("Laser: RGB ("..(item.coreProperties.laser.r or 0)..", "..(item.coreProperties.laser.g or 0)..", "..(item.coreProperties.laser.b or 0)..")", 235, 235, 235)
		elseif  isUpgradePossible(ITEMS.def[19].allowedIN, wid) and not (barrel  and barrel == 2)  then --poprawić
			outputChatBox("Laser: brak (wymaga tłumiku)", 235, 235, 235)
		end
		if tonumber(item.coreProperties.skin) then
			outputChatBox("Numer skórki: "..item.coreProperties.skin, 235, 235, 235)
		else 
			outputChatBox("Numer skórki: brak", 235, 235, 235)
		end
		if tonumber(item.coreProperties.ammo) then
			outputChatBox("Ilość amunicji: "..item.coreProperties.ammo, 235, 235, 235)
		end 
	end
end

gui.functions.drop = function()
	triggerServerEvent("onPlayerDropItem", resourceRoot, getElementData(localPlayer, "EQ")[currentIndex])
end

gui.functions.dropAll = function()
	triggerServerEvent("onPlayerDropItem", resourceRoot, getElementData(localPlayer, "EQ")[currentIndex], true)
end

local function createMenu(item, index)
	if isElement(gui.menu) then
		destroyElement(gui.menu)
	end

	local x, y = guiGetPosition(gui.win, false)
	local offsetX, offsetY = guiGetPosition(gui.rows[index], false)
	local createDrop, createDropAll, createInfo, createUse, createCustomization, createStopUse
	local sizeIndex = 0
	if ITEMS.def[item.id].functions and type(ITEMS.def[item.id].functions) == "table" and table.size(ITEMS.def[item.id].functions) > 0 and not item.isActive then
		sizeIndex = sizeIndex + 1
		createUse = true
	end
	if ITEMS.def[item.id].functions and type(ITEMS.def[item.id].functions) == "table" and table.size(ITEMS.def[item.id].functions) > 0 and item.isActive then
		sizeIndex = sizeIndex + 2
		createStopUse = true
	end
	if not ITEMS.def[item.id].forbiddenDrop and not item.isActive then
		sizeIndex = sizeIndex + 1
		createDrop = true
		if item.count > 1 then
			sizeIndex = sizeIndex + 1
			createDropAll = true
		end
	end
	if ITEMS.def[item.id].description then
		sizeIndex = sizeIndex + 1
		createInfo = true
	end
	if ITEMS.def[item.id].allowCustomization then 
		sizeIndex = sizeIndex + 1
		createCustomization = true
	end
	
	if sizeIndex == 0 then 
		return
	end
	gui.menu = guiCreateStaticImage(x - settings.menuWidth, y + settings.rowHeight + offsetY, settings.menuWidth, settings.rowHeight * sizeIndex, ":imta-interface/media/background.png", false)
	gui.options = {}
	local i = 1
	local sizeIndex = 1
	if createUse then
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (sizeIndex - 1), settings.menuWidth, settings.rowHeight, " Użyj", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "use")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 1
		i = i + 1
	end
	if createStopUse then 
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (sizeIndex - 1), settings.menuWidth, settings.rowHeight * 2, " Przestań\n używać", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "stopUse")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 2
		i = i + 1
	end
	if createCustomization then
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (sizeIndex - 1), settings.menuWidth, settings.rowHeight, " Modyfikuj", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "modify")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 1
		i = i + 1
	end
	if createInfo then
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (sizeIndex - 1), settings.menuWidth, settings.rowHeight, " Informacje", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "info")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 1
		i = i + 1
	end
	if createDrop then
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (sizeIndex - 1), settings.menuWidth, settings.rowHeight, " Wyrzuć", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "drop")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 1
		i = i + 1

	end
	if createDropAll then
		gui.options[i] = guiCreateLabel(0, settings.rowHeight * (i - 1), settings.menuWidth, settings.rowHeight, " Wyrzuć wsz.", false, gui.menu)
			guiSetFont(gui.options[i], settings.fontItems)
			guiLabelSetColor(gui.options[i], 204, 204, 204)
			guiLabelSetVerticalAlign(gui.options[i], "center")
			setElementData(gui.options[i], "purpose", "dropAll")
			setElementData(gui.options[i], "rowHighlighter", createRowHighlighter(gui.options[i]))
		sizeIndex = sizeIndex + 1
		i = i + 1
	end
	currentMenuIndex = 1
	changeHighlightedRow(nil, getElementData(gui.options[currentMenuIndex], "rowHighlighter"))
	settings.currentItem = item
end

local function moveUp()
	-- if #gui.rows < settings.rowAmount then 
		-- return
	-- end
	do 
		if #gui.rows > 0 then
			local x, y =  guiGetPosition(gui.rows[1], false)
			if y == 0 then 
				return false
			end
		else 
			return false
		end
	end
	for i, row in ipairs(gui.rows) do
		local x, y = guiGetPosition(row, false)
		if y < -settings.rowHeight then
			guiSetPosition(row, x, (y + settings.rowHeight - 1), false)
		else
			guiSetPosition(row, x, y + settings.rowHeight, false)
		end
	end
	return true
end

local function moveDown()
	if #gui.rows < settings.rowAmount then 
		return
	end
	do 
		if #gui.rows > 0 then
			local x, y =  guiGetPosition(gui.rows[#gui.rows], false)
			if y == settings.rowHeight * (settings.rowAmount - 2) then 
				return false
			end
		else 
			return false
		end
	end
	for i, row in ipairs(gui.rows) do
		local x, y = guiGetPosition(row, false)
		if y < settings.rowHeight then
			guiSetPosition(row, x, (y - settings.rowHeight - 1), false)
		else
			guiSetPosition(row, x, y - settings.rowHeight, false)
		end
	end
	return true
end



local function createRow(item, multiplier)
	local row = guiCreateStaticImage(0,#gui.rows * settings.rowHeight, settings.rowWidth, settings.rowHeight, ":imta-interface/media/transparent.png", false, gui.background)
	local icon = guiCreateStaticImage(settings.rowHeight * 0.1, settings.rowHeight * 0.1, settings.rowHeight * 0.8, settings.rowHeight * 0.8, "files/icons/"..ITEMS.def[item.id].iconPath, false, row)
	local bind = guiCreateLabel(settings.rowHeight, 0, 0.1 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, settings.rowHeight, "_", false, row)
		guiSetFont(bind, settings.fontItems)
		guiLabelSetColor(bind, 204, 204, 204)
		guiLabelSetVerticalAlign(bind, "center")
		guiLabelSetHorizontalAlign(bind, "center")
	local name = guiCreateLabel(settings.rowHeight + 0.1 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, 0, 0.75 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, settings.rowHeight, " "..getItemName(item.id, item.coreProperties)..(item.count > 1 and " ("..item.count.."x)" or "") , false, row)
		guiSetFont(name, settings.fontItems)
		if item.isActive then
			guiLabelSetColor(name, 204, 204, 0)
		else
			guiLabelSetColor(name, 204, 204, 204)
		end
		guiLabelSetVerticalAlign(name, "center")
		setElementData(row, "nameLabel", name, false)
	local subtype = guiCreateLabel(settings.rowHeight + 0.85 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, 0, 0.15 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, settings.rowHeight, (item.subtype or "-").." ", false, row)
		guiSetFont(subtype, settings.fontItems)
		guiLabelSetColor(subtype, 204, 204, 204)
		guiLabelSetVerticalAlign(subtype, "center")
		guiLabelSetHorizontalAlign(subtype, "right")
	local rowHighlighter = guiCreateStaticImage(0, 0, 1, 1, ":imta-interface/media/transparent.png", true, row)
		setElementData(row, "rowHighlighter", rowHighlighter)
		guiSetAlpha(rowHighlighter, 0.2)
	return row
end

local function redrawEQ(forced, index, option)
	if forced then
		for i, row in ipairs(gui.rows) do
			destroyElement(row)
		end
		gui.rows = {}
		for i, item in ipairs(getElementData(localPlayer, "EQ")) do
			local row = createRow(item)
			table.insert(gui.rows, row)
		end
	else 
		if option == "CHANGED" then
			if not gui.rows[index] then 
				return 
			end
			local nameLabel = getElementData(gui.rows[index], "nameLabel")
			local item = EQ[index]
			guiSetText(nameLabel, " "..getItemName(item.id, item.coreProperties)..(item.count > 1 and " ("..item.count.."x)" or ""))
			if item.isActive then 
				guiLabelSetColor(nameLabel, 204, 204, 0)
			else
				guiLabelSetColor(nameLabel, 204, 204, 204)
			end
			if currentIndex == index then
				if isElement(gui.menu) then
					destroyElement(gui.menu)
					createMenu(item, index)
				end
			end
		elseif option == "REMOVED" then 
			 -- we remove our old row first
			local row = table.remove(gui.rows, index)
			destroyElement(row)
			
			-- make sure that our last row isn't the one removed
			if index <= #gui.rows then
				-- if the index that is removed before our currentIndex we do what?
				-- if index < currentIndex then
				-- if the index that is removed is currentIndex we do what?
				-- elseif index == currentIndex then
				-- if the index that is removed after our currentIndex we do what?
				-- elseif index > currentIndex then
				-- end
				for i = (index), #gui.rows do
					local x, y = guiGetPosition(gui.rows[i], false)
					if y < settings.rowHeight then
						guiSetPosition(gui.rows[i], x, (y - settings.rowHeight - 1), false)
					else
						guiSetPosition(gui.rows[i], x, y - settings.rowHeight, false)
					end
				end
				moveUp()
			-- if it's last row, then we only move our whole thing up
			else
				moveUp()
			end
			-- moveDown()
			if currentIndex == index then
				currentIndex = math.max(currentIndex - 1, 1) --we make sure that cIndex > 0
			end
			-- check if currentIndex row exists
			if gui.rows[currentIndex] then
				--if it does then we higlight it, if it doesn't then we don't care, because there are no items in EQ
				local newRowHighlighter = getElementData(gui.rows[currentIndex], "rowHighlighter")
				changeHighlightedRow(nil, newRowHighlighter)
			end
			--if there is some other menu just destroy it
			if isElement(gui.menu) then
				destroyElement(gui.menu)
			end
			guiSetVisible(gui.emptyEQInfo, #gui.rows == 0)
		elseif option == "INSERTED" then
			if index <= #gui.rows then
				local row = createRow(EQ[index])
				local x, y = guiGetPosition(gui.rows[index], false)
				if y <= settings.rowHeight then
					guiSetPosition(row, x, (y - settings.rowHeight - 1), false)
				else
					guiSetPosition(row, x, y - settings.rowHeight, false)
				end
				local x, y = guiGetPosition(row, false)

				table.insert(gui.rows, index, row)
				
				for i = index, #gui.rows do
					local x, y = guiGetPosition(gui.rows[i], false)
					if y < -settings.rowHeight then
						guiSetPosition(gui.rows[i], x, (y + settings.rowHeight - 1), false)
					else
						guiSetPosition(gui.rows[i], x, y + settings.rowHeight, false)
					end
				end
			else
				local row = createRow(EQ[index])
				if gui.rows[index-1] then
					local x, y = guiGetPosition(gui.rows[index-1], false)
					guiSetPosition(row, x, y + settings.rowHeight, false)
				end
				table.insert(gui.rows, row)
			end
			guiSetVisible(gui.emptyEQInfo, #gui.rows == 0)
			-- if it's the first item we add higlighting to it
			if #gui.rows == 1 then
				if gui.rows[currentIndex] then
					local newRowHighlighter = getElementData(gui.rows[currentIndex], "rowHighlighter")
					changeHighlightedRow(nil, newRowHighlighter)
				end
			elseif index <= currentIndex and #gui.rows ~= 1 then
				-- if we insert an item before our currently selected item we increment cIndex by one and moveDown()
				moveDown()
				currentIndex = currentIndex + 1
			end
		end	
	end
end

--[[addCommandHandler("dipa", function ()
	outputChatBox("TEST1")
	for i, v in ipairs(gui.rows) do
		local x, y = guiGetPosition(v, false)
		outputChatBox("I: "..i.." X: "..x.." Y: "..y)
	end
end)]]

local clickLimiter = getTickCount()

local function downClickEQ()
	clickLimiter = getTickCount()
	--handle scrolling down in the menu list
	if isElement(gui.menu) then
		if gui.options[currentMenuIndex + 1] then
			local oldRowHighlighter = getElementData(gui.options[currentMenuIndex], "rowHighlighter")
			local newRowHighlighter = getElementData(gui.options[currentMenuIndex + 1], "rowHighlighter")
			changeHighlightedRow(oldRowHighlighter, newRowHighlighter)
			currentMenuIndex = currentMenuIndex + 1
			--moveUp()
		end
		return
	end
	--handle scrolling down in the item list
	if gui.rows[currentIndex + 1] then
		local oldRowHighlighter = getElementData(gui.rows[currentIndex], "rowHighlighter")
		local newRowHighlighter = getElementData(gui.rows[currentIndex + 1], "rowHighlighter")
		changeHighlightedRow(oldRowHighlighter, newRowHighlighter)
		currentIndex = currentIndex + 1
		moveDown()
	end
end

local function upClickEQ()
	clickLimiter = getTickCount()
	--handle scrolling down up the menu list
	if isElement(gui.menu) then
		if gui.options[currentMenuIndex - 1] then
			local oldRowHighlighter 
			if isElement(gui.options[currentMenuIndex]) then
				oldRowHighlighter = getElementData(gui.options[currentMenuIndex], "rowHighlighter")
			end
			local newRowHighlighter = getElementData(gui.options[currentMenuIndex - 1], "rowHighlighter")
			changeHighlightedRow(oldRowHighlighter, newRowHighlighter)
			currentMenuIndex = currentMenuIndex - 1
			--moveUp()
		end
		return
	end
	--handle scrolling up in the item list
	if gui.rows[currentIndex - 1] then
		local oldRowHighlighter 
		if isElement(gui.rows[currentIndex]) then
			oldRowHighlighter = getElementData(gui.rows[currentIndex], "rowHighlighter")
		end
		local newRowHighlighter = getElementData(gui.rows[currentIndex - 1], "rowHighlighter")
		changeHighlightedRow(oldRowHighlighter, newRowHighlighter)
		currentIndex = currentIndex - 1
		moveUp()
	end
end

local function leftClickEQ() 
	if getTickCount() < clickLimiter + 100 then 
		return
	end
	clickLimiter = getTickCount()
	if gui.rows[currentIndex] then
		--handle menu clicks
		if isElement(gui.menu) then
			local purpose = getElementData(gui.options[currentMenuIndex], "purpose")
			gui.functions[purpose]()
		--handle non-menu clicks
		else
			local item = getElementData(localPlayer, "EQ")[currentIndex]
			if item.isActive then
				triggerServerEvent("onPlayerStopUseItem", resourceRoot, item)
			else 
				triggerServerEvent("onPlayerUseItem", resourceRoot, item)
			end
		end
	end
end

local function rightClickEQ() 
	if getTickCount() < clickLimiter + 100 then 
		return
	end
	clickLimiter = getTickCount()
	--handle non-menu clicks
	if not isElement(gui.menu) and gui.rows[currentIndex] then
		local item = getElementData(localPlayer, "EQ")[currentIndex]
		createMenu(item, currentIndex)
	--handle menu clicks
	else
		if isElement(gui.menu) then
			destroyElement(gui.menu)
		end
	end
end


local function showEQ(state)
	if not getElementData(localPlayer, "EQ") then 
		return
	end
	if state then
		for i = 1, #gui.rows do
			guiSetPosition(gui.rows[i], 0, (i - 1) * settings.rowHeight, false)
		end
		if #gui.rows > 0 then
			local oldRow = gui.rows[currentIndex]
			local newRow = gui.rows[1]
			local oldRowHighlighter
			if oldRow then
				oldRowHighlighter = getElementData(oldRow, "rowHighlighter")
			end
			local newRowHighlighter = getElementData(newRow, "rowHighlighter")
			currentIndex = 1
			changeHighlightedRow(oldRowHighlighter, newRowHighlighter)
		end
		bindKey("mouse_wheel_down", "down", downClickEQ)
		bindKey("mouse_wheel_up", "down", upClickEQ)
		bindKey("mouse1", "down", leftClickEQ)
		bindKey("mouse2", "down", rightClickEQ)
		guiSetVisible(gui.emptyEQInfo, #gui.rows == 0)
	else
		unbindKey("mouse_wheel_down", "down", downClickEQ)
		unbindKey("mouse_wheel_up", "down", upClickEQ)
		unbindKey("mouse1", "down", leftClickEQ)
		unbindKey("mouse2", "down", rightClickEQ)
		if isElement(gui.menu) then
			destroyElement(gui.menu)
		end
	end
	--toggleControl("fire", guiGetVisible(gui.win))
	guiSetVisible(gui.win, state)
end
addEvent("onServerDemandEQVIsibilityChange", true)
addEventHandler("onServerDemandEQVIsibilityChange", resourceRoot, showEQ)

local function bindEQ()
	if not getElementData(localPlayer, "EQ") then 
		return
	end
	if guiGetVisible(gui.win) then
		triggerServerEvent("onPlayerDemandEQShowChange", resourceRoot, false)
	else
		triggerServerEvent("onPlayerDemandEQShowChange", resourceRoot, true)
	end
end
bindKey("i", "down", bindEQ)

addEvent("onClientEQRefresh", true)
addEventHandler("onClientEQRefresh", resourceRoot, function(_EQ, index, option, forced)
	setElementData(localPlayer, "EQ", _EQ, false)
	EQ = _EQ
	redrawEQ(forced, index, option)
end)

if getElementData(localPlayer, "EQ") then
	redrawEQ(true, nil, nil)
end

function onClientPlayerWeaponFireFunc(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	triggerServerEvent("onPlayerUpdateAmmo", resourceRoot, ammo)
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(), onClientPlayerWeaponFireFunc )

local boomboxGUI = {}
local boomboxSounds = {}

function closeBoomboxGUI()
	showCursor(false) -- przy restarcie imta-interface, cursor zostanie
	if isElement(boomboxGUI["window_audio"]) then
		guiSetVisible(boomboxGUI["window_audio"], false)
	end
end

function playBoomboxSound()
	local url = guiGetText(boomboxGUI["edit___audio"])
	closeBoomboxGUI()
	triggerServerEvent("playBoombox", localPlayer, localPlayer, url)
end

function destroyBoomboxSound()
	closeBoomboxGUI()
	triggerServerEvent("destroyBoombox", localPlayer, localPlayer)
end

function playSoundURL(player, url)
	if not isElementStreamedIn(player) then
		return
	end
	if isElement(boomboxSounds[player]) then
		destroyElement(boomboxSounds[player])
	end
	local sound = playSound3D(url,0,0,0)
	local dimension = getElementDimension(player)
	local interior = getElementInterior(player)
	setElementDimension(sound, dimension)
	setElementInterior(sound, interior)
	attachElements(sound, player)
	boomboxSounds[player] = sound
end

function createBoomboxGUI()
	for k,v in pairs(boomboxGUI) do
		if isElement(v) then
			destroyElement(v)
		end
	end
	local sx,sy = guiGetScreenSize()
	--boomboxGUI["window_audio"] = exports["imta-interface"]:createBox(sx*0.3, sy*0.2, sx*0.4, sy*0.3)
	if not isElement(boomboxGUI["window_audio"]) then
		boomboxGUI["window_audio"] = guiCreateWindow(0.3, 0.2, 0.4, 0.3, "Podaj URL do utworu", true)
	end
	boomboxGUI["edit___audio"] = guiCreateEdit(0.05, 0.15, 0.9, 0.1, "", true,boomboxGUI["window_audio"])
	boomboxGUI["cancel_audio"] = guiCreateButton(0.05, 0.75, 0.266, 0.15, "Anuluj",  true, boomboxGUI["window_audio"])
	boomboxGUI["destroyaudio"] = guiCreateButton(0.366,  0.75, 0.266, 0.15, "Wyłącz dźwięk",  true, boomboxGUI["window_audio"])
	boomboxGUI["akcept_audio"] = guiCreateButton(0.683, 0.75, 0.266, 0.15, "Zatwierdź",  true, boomboxGUI["window_audio"])
	guiSetVisible(boomboxGUI["window_audio"], false)
	addEventHandler("onClientGUIClick", boomboxGUI["cancel_audio"], closeBoomboxGUI, false)
	addEventHandler("onClientGUIClick", boomboxGUI["akcept_audio"], playBoomboxSound, false)
	addEventHandler("onClientGUIClick", boomboxGUI["destroyaudio"], destroyBoomboxSound, false)
end

addEvent("onUseBoombox", true)
addEventHandler("onUseBoombox", root, function()
	if not isElement(boomboxGUI["window_audio"]) then
		createBoomboxGUI()
	end
	showCursor(true)
	guiSetVisible(boomboxGUI["window_audio"],  true)
end)

addEvent("playBoomboxSound", true)
addEventHandler("playBoomboxSound", root, function(player, sound)
	playSoundURL(player,  sound)
end)

addEvent("playBoomboxSounds", true)
addEventHandler("playBoomboxSounds", root, function(tab)
	for k,v in ipairs(tab) do
		playSoundURL(v[1], v[2])
	end
end)

addEvent("destroyBoomboxSound", true)
addEventHandler("destroyBoomboxSound", root, function(player)
	if isElement(boomboxSounds[player]) then
		destroyElement(boomboxSounds[player])
	end
end)

local players = getElementsByType("player", root, true)
if #players>0 then
	triggerServerEvent("getBoomboxSounds", localPlayer, players)
end

addEventHandler( "onClientElementStreamOut", root, function()
        if getElementType(source) == "player" then
		if isElement(boomboxSounds[source]) then
			destroyElement(boomboxSounds[source])
		end
        end
end)
addEventHandler("onClientElementStreamIn", root, function()
        if getElementType(source) == "player" then
		triggerServerEvent("getBoomboxSound", localPlayer, source)
        end
end)
