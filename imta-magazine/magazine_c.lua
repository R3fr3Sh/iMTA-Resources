
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
		settings.fontButton = guiCreateFont(":imta-organisations/media/calibri-bold.ttf", 9)
		settings.menuWidth = 80
		settings.margin = 6
	elseif sx > 1024 and sx <= 1600 then
		settings.rowHeight = 26
		settings.rowWidth = 350
		settings.rowAmount = 14
		settings.fontItems = guiCreateFont(":imta-interface/media/fontroboto.ttf", 12)
		settings.fontHeader = guiCreateFont(":imta-interface/media/fontroboto.ttf", 16)
		settings.fontButton = guiCreateFont(":imta-organisations/media/calibri-bold.ttf", 10)
		settings.menuWidth = 100
		settings.margin = 8
	else
		settings.rowHeight = 30
		settings.rowWidth = 500
		settings.rowAmount = 20
		settings.fontItems = guiCreateFont(":imta-interface/media/fontroboto.ttf", 14)
		settings.fontHeader = guiCreateFont(":imta-interface/media/fontroboto.ttf", 18)
		settings.fontButton = guiCreateFont(":imta-organisations/media/calibri-bold.ttf", 11)
		settings.menuWidth = 120
		settings.margin = 10
	end
	settings.buttonWidth = (settings.rowWidth - 3 * settings.margin) / 2
	settings.headerSpace = (settings.rowWidth - settings.rowHeight) / settings.rowWidth
end

--SUPPORT


local function onCursorEnterTab()	
	guiSetAlpha(source, 0.1)
end

local function onCursorLeaveTab()
	guiSetAlpha(source, 0)
end

local function createButton(x, y, w, h, content, parent)
	local bg = guiCreateStaticImage(x, y, w, h, ":imta-organisations/media/pixels/darkgrey.png", false, parent)
		local label = guiCreateLabel(0, 0.1, 1, 0.9, content, true, bg)
			guiLabelSetColor(label, 204, 204, 204)
			guiSetFont(label, settings.fontButton)
			guiLabelSetHorizontalAlign(label, "center")
			guiLabelSetVerticalAlign(label, "center")
		local button = guiCreateStaticImage(0, 0, 1, 1, ":imta-organisations/media/pixels/grey.png", true, bg) 
			guiSetAlpha(button, 0)
			addEventHandler("onClientMouseEnter", button, onCursorEnterTab, false, "high")
			addEventHandler("onClientMouseLeave", button, onCursorLeaveTab, false, "high")
		setElementData(bg, "label", label)
	return button
end


local function createGUI()
	if isElement(gui.win) then 
		destroyElement(gui.win)
	end
	gui.win = guiCreateStaticImage(sx /2 - settings.rowWidth / 2, 0.15 * sy, settings.rowWidth, settings.rowHeight * (settings.rowAmount + 3), ":imta-interface/media/background.png", false)
		-- exports["blur_box"]:createBlurBox(sx-settings.rowWidth, 0.3 * sy, settings.rowWidth, settings.rowHeight * settings.rowAmount, 255, 255, 255, 255, false) TODO!!!
	gui.header = {}
	gui.header.bg = guiCreateStaticImage(0, 0, settings.rowWidth, settings.rowHeight, ":imta-interface/media/pixels/grey.png", false, gui.win)

	gui.header.icon = guiCreateStaticImage(settings.rowHeight * 0.1, settings.rowHeight * 0.1, settings.rowHeight * 0.8, settings.rowHeight * 0.8, ":imta-eq/files/icons/empty-box-open.png", false, gui.header.bg)
		guiSetProperty(gui.header.icon, "ImageColours", "tl:FF434343 tr:FF434343 bl:FF434343 br:FF434343")
	gui.header.name = guiCreateLabel(settings.rowHeight, 0,settings.rowWidth - settings.rowHeight, settings.rowHeight, " Magazyn", false, gui.header.bg)
		guiSetFont(gui.header.name, settings.fontHeader)
		guiLabelSetColor(gui.header.name, 65, 67, 69)
		guiLabelSetVerticalAlign(gui.header.name, "center")
	gui.background = guiCreateStaticImage(0, settings.rowHeight, settings.rowWidth, settings.rowHeight * (settings.rowAmount - 1), ":imta-interface/media/transparent.png", false, gui.win)
	gui.take = createButton(settings.margin, settings.rowHeight * (settings.rowAmount + 1) - settings.margin, settings.buttonWidth, settings.rowHeight * 2, "Zabierz (LPM)\nZabierz wszystko\n(przytrzymaj LPM)", gui.win)
	gui.leave = createButton(settings.margin * 2 + settings.buttonWidth, settings.rowHeight * (settings.rowAmount + 1) - settings.margin, settings.buttonWidth, settings.rowHeight * 2, "Zamknij (PPM)", gui.win)
	gui.rows = {}
	guiSetVisible(gui.win, false)
	do
		gui.emptyMagazineInfo = guiCreateStaticImage(0, settings.rowHeight * (settings.rowAmount - 8) / 2, settings.rowWidth, settings.rowHeight * 6, ":imta-interface/media/transparent.png", false, gui.background)
		local icon = guiCreateStaticImage(settings.rowWidth * 0.5 - settings.rowHeight * 2, settings.rowHeight * 2, settings.rowHeight * 4, settings.rowHeight * 4, ":imta-eq/files/icons/empty-box-open.png", false, gui.emptyMagazineInfo)
		local name = guiCreateLabel(0, 0, settings.rowWidth, settings.rowHeight, "W magazynie nie znajdują się żadne przedmioty" , false, gui.emptyMagazineInfo)
			guiSetFont(name, settings.fontItems)
			guiLabelSetColor(name, 204, 204, 204)
			guiLabelSetVerticalAlign(name, "center")
			guiLabelSetHorizontalAlign(name, "center")
	end
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

local function moveUp()
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


local function createRow(item)
	local itemData = exports["imta-eq"]:getItemData(item.id)
	local row = guiCreateStaticImage(0,#gui.rows * settings.rowHeight, settings.rowWidth, settings.rowHeight, ":imta-interface/media/transparent.png", false, gui.background)
	local icon = guiCreateStaticImage(settings.rowHeight * 0.1, settings.rowHeight * 0.1, settings.rowHeight * 0.8, settings.rowHeight * 0.8, ":imta-eq/files/icons/"..itemData.iconPath, false, row)
	local bind = guiCreateLabel(settings.rowHeight, 0, 0.1 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, settings.rowHeight, "_", false, row)
		guiSetFont(bind, settings.fontItems)
		guiLabelSetColor(bind, 204, 204, 204)
		guiLabelSetVerticalAlign(bind, "center")
		guiLabelSetHorizontalAlign(bind, "center")
	local name = guiCreateLabel(settings.rowHeight + 0.1 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, 0, 0.75 * (settings.rowWidth - settings.rowHeight) * settings.headerSpace, settings.rowHeight, " "..exports["imta-eq"]:getItemName(item.id, item.coreProperties)..(item.count > 1 and " ("..item.count.."x)" or "") , false, row)
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

local function downClickEQ()
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

local lastClick = getTickCount()
local function leftClickMagazineFirst() 
	lastClick = getTickCount()
end

local function leftClickMagazineSecond()
	if gui.rows[currentIndex] then

		if getTickCount() - lastClick > 300 then
			outputChatBox("Podwójny")
			triggerServerEvent("onPlayerDemandMagazineTakeAll", resourceRoot)
		else 
			outputChatBox("Pojedynczy")
			triggerServerEvent("onPlayerDemandMagazineTakeOne", resourceRoot, EQ[currentIndex])
		end
		
	end
end

local function rightClickMagazine() 
	triggerServerEvent("onPlayerDemandMagazineGUI", resourceRoot, false)
end

local function remakeNewGUI(res)
	if getResourceName(res) == "imta-interface" then
		createGUI()
	end
end
createGUI()
addEventHandler("onClientResourceStart", root, remakeNewGUI)
addEventHandler("onClientResourceStop", root,remakeNewGUI)

local function showMagazine(state, EQServer)
	if not getElementData(localPlayer, "EQ") then 
		return
	end
	EQ = EQServer
	if state then
		for i = 1, #gui.rows do
			destroyElement(gui.rows[i])
		end
		gui.rows = {}
		for i, item in ipairs(EQ) do
			table.insert(gui.rows, createRow(item))
		end
		if #gui.rows > 0 then
			local newRow = gui.rows[1]
			local newRowHighlighter = getElementData(newRow, "rowHighlighter")
			currentIndex = 1
			changeHighlightedRow(nil, newRowHighlighter)
		end
		unbindKey("mouse_wheel_down", "down", downClickEQ)
		unbindKey("mouse_wheel_up", "down", upClickEQ)
		unbindKey("mouse1", "down", leftClickMagazineFirst)
		unbindKey("mouse1", "up", leftClickMagazineSecond)
		unbindKey("mouse2", "down", rightClickMagazine)
		bindKey("mouse_wheel_down", "down", downClickEQ)
		bindKey("mouse_wheel_up", "down", upClickEQ)
		bindKey("mouse1", "down", leftClickMagazineFirst)
		bindKey("mouse1", "up", leftClickMagazineSecond)
		bindKey("mouse2", "down", rightClickMagazine)
		guiSetVisible(gui.emptyMagazineInfo, #EQ == 0)
	else
		unbindKey("mouse_wheel_down", "down", downClickEQ)
		unbindKey("mouse_wheel_up", "down", upClickEQ)
		unbindKey("mouse1", "down", leftClickMagazineFirst)
		unbindKey("mouse1", "up", leftClickMagazineSecond)
		unbindKey("mouse2", "down", rightClickMagazine)
	end
	guiSetVisible(gui.win, state)
end
addEvent("onServerDemandShowMagazine", true)
addEventHandler("onServerDemandShowMagazine", resourceRoot, showMagazine)

addCommandHandler("magazyn", function()
	if isElement(gui.win) then
		for i = 1, #gui.rows do
			destroyElement(gui.rows[i])
		end
		gui.rows = {}
	end
	triggerServerEvent("onPlayerDemandMagazineGUI", resourceRoot, true)
end)

