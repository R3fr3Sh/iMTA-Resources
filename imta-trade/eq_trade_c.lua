local gui = {}
local s = {}
local r = {}
local sx, sy = guiGetScreenSize()

local EQ_TO_TRADE = {}
local TRANSPARENT = ":imta-interface/media/transparent.png"
local GREY = ":imta-interface/media/pixels/grey.png"
local draggedIndex = 1

local function getEQToSend()
	local EQ_TO_SEND = {}
	for i, item in ipairs(EQ_TO_TRADE) do
		if item.countToTrade and item.countToTrade > 0 then
			table.insert(EQ_TO_SEND, item)
		end
	end
	return EQ_TO_SEND
end

local function setButtonState(button, state, doNotSend)
	local icon = getElementData(button, "icon")
	if state then 
		guiStaticImageLoadImage(icon, "media/tick.png")
		setElementData(button, "state", state) 
	else 
		guiStaticImageLoadImage(icon, "media/forbid.png")
		setElementData(button, "state", state)
	end
	if button == gui.rightPane.button then 
		if not doNotSend then
			triggerServerEvent("updateTradeOffer", resourceRoot, getEQToSend(), gui.rightPane.bottomMoney, state)
			if not state then 
				setButtonState(gui.leftPane.button, false)
			end
		end
	end
	
end

local function getElementRealSize(element, inPixels)
	local w, h = guiGetSize(element, true)
	local p = getElementParent(element)
	if p ~= guiRoot then
		local pw, ph = getElementRealSize(p, inPixels)
		return pw * w, ph * h
	else
		if inPixels then
			return w * sx, h * sy
		else
			return w, h
		end
	end
end

function getElementRealPosition(element)
	if not element or not isElement(element) then
		return false
	end
	local x, y = guiGetPosition(element, false)
	local p = getElementParent(element)
	if p ~= guiRoot then
		local pw, ph = getElementRealPosition(p)
		if not pw then
			return false
		end
		return pw + x, ph + y
	else
		return x, y
	end
end

local function onCursorEnterTab()	
	guiSetAlpha(source, 0.1)
end

local function onCursorLeaveTab()
	guiSetAlpha(source, 0)
end

local function updateOfferString()
	local tradeString = "Oferuje: "
	local j = 1
	for i, item in ipairs(EQ_TO_TRADE) do
		if item.countToTrade and item.countToTrade > 0 then
			if j <= 3 then
				local itemName = exports["imta-eq"]:getItemName(item.id, item.coreProperties)
				if j == 1 then
					tradeString = tradeString .. itemName .. (item.count == 1 and "" or " ("..item.countToTrade.."x)")
				else 
					tradeString = tradeString .. ", " .. itemName .. (item.count == 1 and "" or " ("..item.countToTrade.."x)")
				end
				j = j + 1
			elseif j == 4 then 
				tradeString = tradeString .. " [...]"
				j = j + 1
			else
				break
			end
		end
	end
	guiSetText(gui.rightPane.tradeLabel, tradeString)
end

local function updateRightLabelText(item, row)
	local itemName = exports["imta-eq"]:getItemName(item.id, item.coreProperties)
	local nameLabel = getElementData(row, "labelName")
		guiSetText(nameLabel, itemName)
	local countLabel = getElementData(row, "labelCount")
	if item.count ~= 1 then
		guiSetText(countLabel, (item.count == 1 and "" or (item.countToTrade or 0).."/"..item.count))
	else 
		guiSetText(countLabel, "")
	end
	
	if item.countToTrade and item.countToTrade > 0 then
		guiLabelSetColor(nameLabel, 204, 204, 204)
		guiLabelSetColor(countLabel, 204, 204, 204)
	else
		guiLabelSetColor(nameLabel, 104, 104, 104)
		guiLabelSetColor(countLabel, 104, 104, 104)
	end
end

local function resizePane(paneType, count)
	local newHeight = math.max((count) * s.paneRowHeight, s.paneRealHeight)
	local gx, gy = guiGetSize(gui[paneType].middlePane, false)
	guiSetSize(gui[paneType].middlePane, gx, newHeight, false)
end

local onPlayerDragMouse
onPlayerDragMouse = function()
	if not getKeyState("mouse1") then 
		removeEventHandler("onClientRender", root, onPlayerDragMouse)
		setButtonState(gui.rightPane.button, false)
	end


	local mx, my = getCursorPosition()
	mx = mx * sx 
	my = my * sy
	local percent = math.max(math.min((mx - r.rx) / r.rw, 1), 0)
	local item = EQ_TO_TRADE[draggedIndex]
	local tradedItemCount = math.floor(percent * item.count)
	if not (item.countToTrade and item.countToTrade == tradedItemCount) then 
		item.countToTrade = tradedItemCount
		updateRightLabelText(item, gui.rightPane.rows[draggedIndex])
		updateOfferString()
	end
end 


local function onCursorClickItem(btn)
	if btn == "left" then
		local i = getElementData(source, "index")
		draggedIndex = i
		r.rx, r.ry = getElementRealPosition(gui.rightPane.rows[draggedIndex])
		r.rw, r.rh = guiGetSize(gui.rightPane.rows[draggedIndex], false)
		addEventHandler("onClientRender", root, onPlayerDragMouse)
		setButtonState(gui.rightPane.button, false)
	elseif btn == "right" then
		local i = getElementData(source, "index")
		local item = EQ_TO_TRADE[i]
		if item.countToTrade and item.countToTrade > 0 then
			item.countToTrade = 0
			updateRightLabelText(item, gui.rightPane.rows[i])
			setButtonState(gui.rightPane.button, false)
			updateOfferString()
		else 
			item.countToTrade = item.count
			updateRightLabelText(item, gui.rightPane.rows[i])
			setButtonState(gui.rightPane.button, false)
			updateOfferString()
		end
	end
end

local onLeftClickAfterMoneyChange 
onLeftClickAfterMoneyChange = function(button, state, x, y)
	if button == "left" then
		local rx, ry = getElementRealPosition(gui.rightPane.bottomEdit)
		local rw, rh = guiGetSize(gui.rightPane.bottomEdit, false)
		local mx, my = getCursorPosition()
		local buffer = 40
		rx = rx - buffer
		rw = rw + buffer * 2
		ry = ry - buffer
		rh = rh + buffer * 2
		
		mx = mx * sx 
		my = my * sy
		
		
		if mx > rx and mx < (rx + rw) and my > ry and my < (ry + rh) then 
			return
		end
		
		local digit = tonumber(guiGetText(gui.rightPane.bottomEdit))
		if digit then 
			digit = math.floor(digit)
			if digit > getPlayerMoney() then 
				exports["imta-interface"]:createNotification("Zbyt dużo!", "Kwota którą chcesz wprowadzić jest większa od ilości gotówki przy sobie!", "stop", 5000, 1, 255, 100, 0)
			elseif digit < 0 then
				exports["imta-interface"]:createNotification("Zbyt mało!", "Kwota którą chcesz wprowadzić jest mniejsza od zera!", "stop", 5000, 1, 255, 100, 0)
			else
				guiSetText(gui.rightPane.bottomLabel, string.format("$%09d", digit))
				guiSetText(gui.rightPane.bottomEdit, digit)
				gui.rightPane.bottomMoney = digit
			end
		else 
			exports["imta-interface"]:createNotification("Niepoprawne formatowanie!", "Kwota którą chcesz wprowadzić musi być liczbą!", "stop", 5000, 1, 255, 100, 0)
			
		end
		guiSetVisible(gui.rightPane.bottomEdit, false)
		triggerServerEvent("updateTradeOffer", resourceRoot, getEQToSend(), gui.rightPane.bottomMoney)

		removeEventHandler("onClientClick", root, onLeftClickAfterMoneyChange)
	end
end

local function onCursorClickRightLabel(button)
	if button == "left" then 
		guiSetVisible(gui.rightPane.bottomEdit, true)
		--TODO kill timer
		setTimer(function () addEventHandler("onClientClick", root, onLeftClickAfterMoneyChange) end, 250, 1)
	end
end

local function createRowRight(toResize)
	local count = #gui.rightPane.rows
	if toResize then
		resizePane("rightPane", count + 1)
	end
	local row = guiCreateStaticImage(0, count * s.paneRowHeight, s.contentWidth, s.paneRowHeight, TRANSPARENT, false, gui.rightPane.middlePane)
	table.insert(gui.rightPane.rows, row)
	local labelName = guiCreateLabel(0, 0, s.paneNameRatio, 1, "", true, row)
		guiSetFont(labelName, s.rowFont)
		guiLabelSetColor(labelName, 204, 204, 204)
		guiLabelSetVerticalAlign(labelName, "center")
		setElementData(row, "labelName", labelName)
	local labelCount = guiCreateLabel(s.paneNameRatio, 0, 1 - s.paneNameRatio, 1, " 10 szt.", true, row)
		guiSetFont(labelCount, s.rowFont)
		guiLabelSetColor(labelCount, 204, 204, 204)
		guiLabelSetVerticalAlign(labelCount, "center")
		guiLabelSetHorizontalAlign(labelCount, "right")
		setElementData(row, "labelCount", labelCount)
	local button = guiCreateStaticImage(0, 0, 1, 1, GREY, true, row)
		guiSetAlpha(button, 0)
		addEventHandler("onClientMouseEnter", button, onCursorEnterTab, false, "high")
		addEventHandler("onClientMouseLeave", button, onCursorLeaveTab, false, "high")
		addEventHandler("onClientGUIMouseDown", button, onCursorClickItem, false, "high")
		setElementData(row, "btn", button)
	
end



local function createRowLeft(toResize)
	local count = #gui.leftPane.rows
	if toResize then
		resizePane("leftPane", count + 1)
	end
	local row = guiCreateStaticImage(0, count * s.paneRowHeight, s.contentWidth, s.paneRowHeight, TRANSPARENT, false, gui.leftPane.middlePane)
	table.insert(gui.leftPane.rows, row)
	local labelName = guiCreateLabel(0, 0, s.paneNameRatio, 1, "", true, row)
		guiSetFont(labelName, s.rowFont)
		guiLabelSetColor(labelName, 204, 204, 204)
		guiLabelSetVerticalAlign(labelName, "center")
		setElementData(row, "labelName", labelName)
	local labelCount = guiCreateLabel(s.paneNameRatio, 0, 1 - s.paneNameRatio, 1, "", true, row)
		guiSetFont(labelCount, s.rowFont)
		guiLabelSetColor(labelCount, 204, 204, 204)
		guiLabelSetVerticalAlign(labelCount, "center")
		guiLabelSetHorizontalAlign(labelCount, "right")
		setElementData(row, "labelCount", labelCount)
end

local function populateLeftRows(content, cash, readyToTrade)
	local contentCount = #content
	local defRows = (s.leftDefaultRows + 1)
	local curRows = #gui.leftPane.rows
	if contentCount < curRows then 
		for i = (defRows + 1), curRows do 
			if contentCount == i then 
				break
			end
			if isElement(gui.leftPane.rows[i]) then
				destroyElement(gui.leftPane.rows[i])
				gui.leftPane.rows[i] = nil
			end

		end
	end
	for i = 1, #gui.leftPane.rows do
		guiSetText(getElementData(gui.leftPane.rows[i], "labelName"), "")
		guiSetText(getElementData(gui.leftPane.rows[i], "labelCount"), "")
	end 
	resizePane("leftPane", #gui.leftPane.rows)
	local tradeString = "Oferuje: "
	for i, item in ipairs(content) do
		if not isElement(gui.leftPane.rows[i]) then
			createRowLeft(true)
		end
		local itemName = exports["imta-eq"]:getItemName(item.id, item.coreProperties)
		local nameLabel = getElementData(gui.leftPane.rows[i], "labelName")
			guiSetText(nameLabel, itemName)
		local countLabel = getElementData(gui.leftPane.rows[i], "labelCount")
		if i <= 3 then
			if i == 1 then
				tradeString = tradeString .. itemName .. (item.countToTrade == 1 and "" or " ("..item.countToTrade.."x)")
			else 
				tradeString = tradeString .. ", " .. itemName .. (item.countToTrade == 1 and "" or " ("..item.countToTrade.."x)")
			end
		elseif i == 4 then 
			tradeString = tradeString .. " [...]"
		end

		if item.countToTrade ~= 1 then
			guiSetText(countLabel, item.countToTrade.." szt.")
		else 
			guiSetText(countLabel, "")
		end
	end
	guiSetText(gui.leftPane.bottomLabel, string.format("$%09d", cash))
	guiSetText(gui.leftPane.tradeLabel, tradeString)
	setButtonState(gui.leftPane.button, readyToTrade, true)
	if not readyToTrade then 
		setButtonState(gui.rightPane.button, false, true)
	end
end

local function populateRightRows(content)
	for i = 1, #gui.rightPane.rows do 
		if isElement(gui.rightPane.rows[i]) then
			destroyElement(gui.rightPane.rows[i])
			gui.rightPane.rows[i] = nil
		end
	end
	EQ_TO_TRADE = content
	for i, item in ipairs(content) do
		if not isElement(gui.rightPane.rows[i]) then
			createRowRight(true)
		end
		updateRightLabelText(item, gui.rightPane.rows[i])
		setElementData(getElementData(gui.rightPane.rows[i], "btn"), "index", i)
	end
	resizePane("rightPane", #gui.rightPane.rows)
	guiSetText(gui.rightPane.bottomLabel, string.format("$%09d", 0))
	guiSetText(gui.rightPane.bottomEdit, 0)
	gui.rightPane.bottomMoney = 0
	updateOfferString()
end


local function downClickTrade()
	local mx, my = getCursorPosition()
	local paneType = 0
	if mx < 0.5 then 
		paneType = "leftPane"
	else 
		paneType = "rightPane"
	end
	--s.paneRealHeight
	local listX, listY = guiGetPosition(gui[paneType].middlePane, false)
	local listW, listH = guiGetSize(gui[paneType].middlePane, false)
	if (listY + listH - s.paneRowHeight) < s.paneRealHeight then
		guiSetPosition(gui[paneType].middlePane, 0, s.paneRealHeight - listH, false)
	else 
		guiSetPosition(gui[paneType].middlePane, 0, listY - s.paneRowHeight, false)
	end
end

local function upClickTrade()
	local mx, my = getCursorPosition()
	local paneType = 0
	if mx < 0.5 then 
		paneType = "leftPane"
	else 
		paneType = "rightPane"
	end
	--s.paneRealHeight
	local listX, listY = guiGetPosition(gui[paneType].middlePane, false)
	local listW, listH = guiGetSize(gui[paneType].middlePane, false)
	if (listY + s.paneRowHeight) > 0 then
		guiSetPosition(gui[paneType].middlePane, 0, 0, false)
	else 
		guiSetPosition(gui[paneType].middlePane, 0, listY + s.paneRowHeight, false)
	end
end

local function onClickButtonRight()
	setButtonState(source, not getElementData(source, "state"))
end

local function onClickButtonEnd()
	triggerServerEvent("updateTradeOffer", resourceRoot, getEQToSend(), gui.rightPane.bottomMoney, state, true)
end

local function createButton(x, y, w, h, content, parent, paneType)
	local bg = guiCreateStaticImage(x, y, w, h, TRANSPARENT, false, parent)
		local boxSize = h - s.thinBorder * 2
		local labelButton = guiCreateStaticImage(s.thinBorder + boxSize + s.thinBorder, s.thinBorder, w - s.thinBorder * 3 + boxSize, h - s.thinBorder * 2, ":imta-organisations/media/pixels/darkgrey.png", false, bg)
		
		local iconButton = guiCreateStaticImage(s.thinBorder, s.thinBorder, boxSize, h - s.thinBorder * 2, ":imta-organisations/media/pixels/darkgrey.png", false, bg)
		local icon = guiCreateStaticImage(s.thinBorder, s.thinBorder, boxSize - s.thinBorder * 2, boxSize - s.thinBorder * 2, "media/forbid.png", false, iconButton)
			guiSetAlpha(icon, 0.6)
			--guiSetAlpha(labelButton, 0.7)
		--BORDERS
		local leftBorder = guiCreateStaticImage(0, 0, s.thinBorder, h, GREY, false, bg)
			guiSetAlpha(leftBorder, 0.3)
		local rightBorder = guiCreateStaticImage(w - s.thinBorder, 0, s.thinBorder, h, GREY, false, bg)
			guiSetAlpha(rightBorder, 0.3)
		local bottomBorder = guiCreateStaticImage(s.thinBorder, 0, w - s.thinBorder * 2, s.thinBorder, GREY, false, bg)
			guiSetAlpha(bottomBorder, 0.3)
		local topBorder = guiCreateStaticImage(s.thinBorder, h - s.thinBorder, w - s.thinBorder * 2, s.thinBorder, GREY, false, bg)
			guiSetAlpha(topBorder, 0.3)
		local middleBorder = guiCreateStaticImage(s.thinBorder + boxSize, s.thinBorder, s.thinBorder, h - s.thinBorder * 2, GREY, false, bg)
			guiSetAlpha(middleBorder, 0.3)

		local label = guiCreateLabel(boxSize / w, 0, (w - boxSize) / w, 1, content, true, bg)
			guiLabelSetColor(label, 204, 204, 204)
			guiSetFont(label, s.barFont)
			guiLabelSetHorizontalAlign(label, "center")
			guiLabelSetVerticalAlign(label, "center")
		local button
			if paneType == "leftPane" then
				button = guiCreateStaticImage(0, 0, 1, 1, ":imta-organisations/media/pixels/darkgrey.png", true, bg)
				guiSetAlpha(button, 0.7)
			else
				button = guiCreateStaticImage(0, 0, 1, 1, GREY, true, bg)
				guiSetAlpha(button, 0)
				addEventHandler("onClientMouseEnter", button, onCursorEnterTab, false, "high")
				addEventHandler("onClientMouseLeave", button, onCursorLeaveTab, false, "high")
				addEventHandler("onClientGUIMouseDown", button, onClickButtonRight, false, "high")
			end
			--TODO:
		setElementData(button, "label", label)
		setElementData(button, "icon", icon)
		setElementData(button, "status", false)
	return button
end

local function createButtonSimple(x, y, w, h, content, parent)
	local bg = guiCreateStaticImage(x, y, w, h, TRANSPARENT, false, parent)
		
		local button = guiCreateStaticImage(s.thinBorder, s.thinBorder - s.thinBorder * 2, w, h - s.thinBorder * 2, ":imta-organisations/media/pixels/darkgrey.png", false, bg)
		--BORDERS
		local leftBorder = guiCreateStaticImage(0, 0, s.thinBorder, h, GREY, false, bg)
			guiSetAlpha(leftBorder, 0.3)
		local rightBorder = guiCreateStaticImage(w - s.thinBorder, 0, s.thinBorder, h, GREY, false, bg)
			guiSetAlpha(rightBorder, 0.3)
		local bottomBorder = guiCreateStaticImage(s.thinBorder, 0, w - s.thinBorder * 2, s.thinBorder, GREY, false, bg)
			guiSetAlpha(bottomBorder, 0.3)
		local topBorder = guiCreateStaticImage(s.thinBorder, h - s.thinBorder, w - s.thinBorder * 2, s.thinBorder, GREY, false, bg)
			guiSetAlpha(topBorder, 0.3)

		local label = guiCreateLabel(0, 0, 1, 1, content, true, bg)
			guiLabelSetColor(label, 204, 204, 204)
			guiSetFont(label, s.barFont)
			guiLabelSetHorizontalAlign(label, "center")
			guiLabelSetVerticalAlign(label, "center")
		
		local label = guiCreateStaticImage(0, 0, 1, 1, GREY, true, bg)
		guiSetAlpha(label, 0)
		addEventHandler("onClientMouseEnter", label, onCursorEnterTab, false, "high")
		addEventHandler("onClientMouseLeave", label, onCursorLeaveTab, false, "high")
		addEventHandler("onClientGUIMouseDown", label, onClickButtonEnd, false, "high")
	return label
end



local function createPane(x, y, width, height, paneType)
	--local pane = guiCreateStaticImage(x, y, width, height, GREY, false, gui.window)
	--	guiSetAlpha(pane, 0.1)
	local pane = guiCreateStaticImage(x, y, width, height, TRANSPARENT, false, gui.panel)
	gui[paneType].rows = {}
	--PANES
	gui[paneType].topLabel = guiCreateLabel(s.paneIntMarginHor, 0, s.contentWidth, s.paneIntMarginVer, "Przedmioty Remigiusz_Maciaszek", false, pane)
		guiSetFont(gui[paneType].topLabel, s.barFont)
		guiLabelSetColor(gui[paneType].topLabel, 204, 204, 204)
		guiLabelSetVerticalAlign(gui[paneType].topLabel, "center")
		guiLabelSetHorizontalAlign(gui[paneType].topLabel, "center")
	gui[paneType].topBar = guiCreateStaticImage(s.paneIntMarginHor, s.paneIntMarginVer, s.contentWidth, s.thinBorder, GREY, false, pane)
		guiSetAlpha(gui[paneType].topBar, 0.3)
	gui[paneType].bottomLabel = guiCreateLabel(s.paneIntMarginHor, height - s.paneIntMarginVer, s.contentWidth, s.paneIntMarginVer - s.thinBorder, "", false, pane)  --$000000005
		guiSetFont(gui[paneType].bottomLabel, s.barFont)
		guiLabelSetColor(gui[paneType].bottomLabel, 204, 204, 204)
		guiLabelSetVerticalAlign(gui[paneType].bottomLabel, "center")
		if paneType == "rightPane" then 
			guiLabelSetHorizontalAlign(gui[paneType].bottomLabel, "right")
		end
	if paneType == "rightPane" then 
		gui[paneType].bottomEdit = guiCreateEdit(s.paneIntMarginHor + s.editWidth, height - s.paneIntMarginVer, s.contentWidth - s.editWidth, s.paneIntMarginVer - s.thinBorder * 2, "", false, pane)
			guiSetVisible(gui[paneType].bottomEdit, false)
			guiSetFont(gui[paneType].bottomEdit, s.barFont)
		addEventHandler("onClientGUIMouseDown", gui[paneType].bottomLabel, onCursorClickRightLabel, false, "high")

	end

	gui[paneType].bottomBar = guiCreateStaticImage(s.paneIntMarginHor, height - s.paneIntMarginVer - s.thinBorder, s.contentWidth, s.thinBorder, GREY, false, pane)
		guiSetAlpha(gui[paneType].bottomBar, 0.3)

	s.paneRealHeight = height - (s.paneIntMarginVer + s.thinBorder) * 2
	gui[paneType].middle = guiCreateStaticImage(s.paneIntMarginHor, s.paneIntMarginVer + s.thinBorder, s.contentWidth, s.paneRealHeight, TRANSPARENT, false, pane)
	gui[paneType].middlePane = guiCreateStaticImage(0, 0, s.contentWidth, s.paneRealHeight, TRANSPARENT, false, gui[paneType].middle) 
		
	--BORDERS
	gui[paneType].leftBorder = guiCreateStaticImage(0, 0, s.thinBorder, height, GREY, false, pane)
		guiSetAlpha(gui[paneType].leftBorder, 0.3)
	gui[paneType].rightBorder = guiCreateStaticImage(width - s.thinBorder, 0, s.thinBorder, height, GREY, false, pane)
		guiSetAlpha(gui[paneType].rightBorder, 0.3)
	gui[paneType].bottomBorder = guiCreateStaticImage(s.thinBorder, 0, width - s.thinBorder * 2, s.thinBorder, GREY, false, pane)
		guiSetAlpha(gui[paneType].bottomBorder, 0.3)
	gui[paneType].topBorder = guiCreateStaticImage(s.thinBorder, height - s.thinBorder, width - s.thinBorder * 2, s.thinBorder, GREY, false, pane)
		guiSetAlpha(gui[paneType].topBorder, 0.3)
	--BOTTOM
	--gui[paneType].tradeLabel = guiCreateStaticImage(x, y + height, width, s.textHeight, GREY, false, gui.panel)
	gui[paneType].tradeLabel = guiCreateLabel(x, y + height, width, s.textHeight, "", false, gui.panel)
		guiSetFont(gui[paneType].tradeLabel, s.barFont)
		guiLabelSetColor(gui[paneType].tradeLabel, 204, 204, 204)
		--TODO limit znaków, max 3 itemy?
		guiLabelSetHorizontalAlign(gui[paneType].tradeLabel, "left", true)
		guiLabelSetVerticalAlign(gui[paneType].tradeLabel, "center")
	gui[paneType].button = createButton(x, y + height + s.textHeight, width + s.thinBorder * 2, s.buttonHeight, "Gotowość wymiany", gui.panel, paneType)
end

do
	if sx <= 1024 then
		--CONSTANTS
		s.width = 700
		s.height = 440
		s.topBarHeight = 30
		s.thinBorder = 2
		s.boldBorder = 4
		
		s.paneMarginHor = 50
		s.paneMarginVer = 20
		s.paneWidth = 220
		s.paneHeight = 290
		s.paneIntMarginHor = 10
		s.paneIntMarginVer = 20
		s.paneRowHeight = 20
		s.paneNameRatio = 0.7 --decides how much does the name take as a percentage
		
		s.textHeight = 35
		s.buttonHeight = 35
		s.editWidth = 100

		s.rowFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 8)
		s.barFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 9)
		s.bigFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 13)

	elseif sx > 1024 and sx <= 1600 then
		--CONSTANTS
		s.width = 960
		s.height = 600
		s.topBarHeight = 60
		s.thinBorder = 2
		s.boldBorder = 4
		
		s.paneMarginHor = 30
		s.paneMarginVer = 20
		s.paneWidth = 300
		s.paneHeight = 410
		s.paneIntMarginHor = 15
		s.paneIntMarginVer = 25
		s.paneRowHeight = 25
		s.paneNameRatio = 0.7 --decides how much does the name take as a percentage

		s.textHeight = 50
		s.buttonHeight = 40
		s.editWidth = 165

		s.rowFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 10)
		s.barFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 11)
		s.bigFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 16)

	else
		--CONSTANTS
		s.width = 960
		s.height = 600
		s.topBarHeight = 60
		s.thinBorder = 2
		s.boldBorder = 4
		
		s.paneMarginHor = 50
		s.paneMarginVer = 20
		s.paneWidth = 300
		s.paneHeight = 410
		s.paneIntMarginHor = 15
		s.paneIntMarginVer = 25
		s.paneRowHeight = 25
		s.paneNameRatio = 0.7 --decides how much does the name take as a percentage
		
		s.textHeight = 50
		s.buttonHeight = 40
		s.editWidth = 165
		
		s.rowFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 10)
		s.barFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 11)
		s.bigFont = guiCreateFont(":imta-interface/media/fontroboto.ttf", 16)
	end
		s.contentWidth = s.paneWidth - s.paneIntMarginHor * 2

		--Creation
		gui.window = guiCreateStaticImage((sx - s.width) * 0.5 - s.thinBorder, (sy - s.height) * 0.5 - s.thinBorder, s.width + s.thinBorder * 2, s.height + s.thinBorder * 2, TRANSPARENT, false)
		guiSetVisible(gui.window, false)

		
		--PANEL
		gui.panel = guiCreateStaticImage(s.thinBorder, s.topBarHeight + s.thinBorder, s.width, s.height - s.topBarHeight, ":imta-interface/media/background.png", false, gui.window)
		
		gui.topBar = guiCreateStaticImage(s.thinBorder, s.thinBorder, s.width, s.topBarHeight, GREY, false, gui.window)
			guiSetAlpha(gui.topBar, 0.7)
		gui.topLabel = guiCreateLabel(s.thinBorder, s.thinBorder, s.width, s.topBarHeight, "Handel z Remigiusz_Maciaszek", false, gui.window)
			guiSetFont(gui.topLabel, s.bigFont)
			guiLabelSetColor(gui.topLabel, 35, 35, 35)
			guiLabelSetVerticalAlign(gui.topLabel, "center")
			guiLabelSetHorizontalAlign(gui.topLabel, "center")
		--BORDERS
			gui.leftBorder = guiCreateStaticImage(0, 0, s.thinBorder, s.height + s.thinBorder * 2, ":imta-interface/media/border.png", false, gui.window)
				--guiSetAlpha(gui.leftBorder, 0.3)
			gui.rightBorder = guiCreateStaticImage(s.width + s.thinBorder, 0, s.thinBorder, s.height + s.thinBorder * 2, ":imta-interface/media/border.png", false, gui.window)
				--guiSetAlpha(gui.rightBorder, 0.3)
			gui.bottomBorder = guiCreateStaticImage(s.thinBorder, 0, s.width, s.thinBorder, ":imta-interface/media/border.png", false, gui.window)
				--guiSetAlpha(gui.bottomBorder, 0.1)
			gui.topBorder = guiCreateStaticImage(s.thinBorder, s.height + s.thinBorder, s.width, s.thinBorder, ":imta-interface/media/border.png", false, gui.window)
				--guiSetAlpha(gui.topBorder, 0.3)
		gui.back = createButtonSimple(s.paneWidth + s.paneMarginHor * 1.5, s.paneMarginVer + s.paneHeight + s.textHeight, s.width - 2 * (s.paneWidth + s.paneMarginHor * 1.5), s.buttonHeight, "Zakończ", gui.panel)
		--INTERNALS
			--label
		gui.leftPane = {}
			gui.leftPane.window = createPane(s.paneMarginHor, s.paneMarginVer, s.paneWidth, s.paneHeight, "leftPane")
			
		gui.rightPane = {}
			gui.rightPane.window = createPane(s.width - s.paneMarginHor - s.paneWidth, s.paneMarginVer, s.paneWidth, s.paneHeight, "rightPane")
		-- setButtonState(gui.rightPane.button, true)
		
			--for left pane we create a few rows by default, so it won't lag when we open trade and resize window
		s.leftDefaultRows = math.floor((s.paneHeight - s.paneIntMarginVer * 2) / s.paneRowHeight) - 1
		for i = 1, s.leftDefaultRows do
			createRowLeft(false)
		end
		createRowLeft(true)
end




function initiateTrade(EQ, partnerName)
	EQ_TO_TRADE = EQ
	populateRightRows(EQ_TO_TRADE)
	populateLeftRows({}, 0)
	local myName = string.gsub(getPlayerName(localPlayer), "_", " ")
	guiSetText(gui.rightPane.topLabel, "Przedmioty "..myName)
	guiSetText(gui.leftPane.topLabel, "Przedmioty "..partnerName)
	guiSetText(gui.topLabel, "Handel z "..partnerName)
	guiSetVisible(gui.window, true)
	showCursor(true, true)

	bindKey("mouse_wheel_down", "down", downClickTrade)
	bindKey("mouse_wheel_up", "down", upClickTrade)

end
addEvent("onServerInitiateTrade", true)
addEventHandler("onServerInitiateTrade", resourceRoot, initiateTrade)


function hideGUI()
	EQ_TO_TRADE = {}
	populateRightRows({})
	populateLeftRows({}, 0)
	guiSetVisible(gui.window, false)
	showCursor(false)

	unbindKey("mouse_wheel_down", "down", downClickTrade)
	unbindKey("mouse_wheel_up", "down", upClickTrade)

end
addEvent("onPartnerEndOffer", true)
addEventHandler("onPartnerEndOffer", resourceRoot, hideGUI)

addEvent("onPartnerUpdateOffer", true)
addEventHandler("onPartnerUpdateOffer", resourceRoot, populateLeftRows)