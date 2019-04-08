local gui = {}
panelWindow = 0
--Siwy biały dla boxu, czcionki i belek po bokach: 204, 204, 204 #cccccc
-- Góra - tło od zakładek rgb: 18, 18, 17
-- A dół to jednolite czarne 0, 0, 0
-- Tylko to w przezroczystości to wiadomo
--https://cdn.discordapp.com/attachments/399695849552085003/463800907633786880/unknown.png
local blurBoxes = {}
local lVars = {} --local script temp-vars
local sx, sy = guiGetScreenSize()
local coid
hideWindow = nil
showWindow = nil
local currentID  = 1
local wantToLeaveClicked

local function spawnBlurBox()
	blurBoxes[1] = exports["blur_box"]:createBlurBox(sx/2-302, sy/2-202, 604, 404, 255, 255, 255, 255, false)
end

local function destroyBlurBox()
	for k, v in ipairs(blurBoxes) do
		exports["blur_box"]:destroyBlurBox(v)
	end
end

local function onCursorEnterTab()	
	guiSetAlpha(source, 0.1)
end

local function onCursorLeaveTab()
	guiSetAlpha(source, 0)
end

local function onCursorClickTab()
	local tabIndex = getElementData(source, "index")
	if not tabIndex then
		return
	end
	if tabIndex == 6 then
		hideWindow()
		return
	end
	triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, coid, tabIndex)
end
local font = {}

local function createButton(x, y, w, h, content, parent)
	local bg = guiCreateStaticImage(x, y, w, h, "media/pixels/darkgrey.png", false, parent)
		local label = guiCreateLabel(0, 0.1, 1, 0.9, content, true, bg)
			guiLabelSetColor(label, 204, 204, 204)
			guiSetFont(label, font.content)
			guiLabelSetHorizontalAlign(label, "center")
			guiLabelSetVerticalAlign(label, "center")
		local button = guiCreateStaticImage(0, 0, 1, 1, "media/pixels/grey.png", true, bg) 
			guiSetAlpha(button, 0)
			addEventHandler("onClientMouseEnter", button, onCursorEnterTab, false, "high")
			addEventHandler("onClientMouseLeave", button, onCursorLeaveTab, false, "high")
		setElementData(bg, "label", label)
	return button
end


do
	do
		font.title = guiCreateFont("media/calibri-bold.ttf", 13)
		font.content = guiCreateFont("media/calibri-bold.ttf", 11)
		font.edit = guiCreateFont("media/calibri-bold.ttf", 10)
	end
	gui = {}
	gui.bg = guiCreateStaticImage(sx/2-302, sy/2-202, 604, 404, "media/pixels/transparent.png", false)
	panelWindow = gui.bg
	gui.win = guiCreateStaticImage(2, 2, 600, 400, "media/pixels/darkgrey.png", false, gui.bg)
		guiSetAlpha(guiCreateStaticImage(2, 0, 602, 2, "media/pixels/darkergrey.png", false, gui.bg), 0.8)
		guiSetAlpha(guiCreateStaticImage(602, 2, 2, 402, "media/pixels/darkergrey.png", false, gui.bg), 0.8)
		guiSetAlpha(guiCreateStaticImage(0, 0, 2, 402, "media/pixels/darkergrey.png", false, gui.bg), 0.8)
		guiSetAlpha(guiCreateStaticImage(0, 402, 602, 2, "media/pixels/darkergrey.png", false, gui.bg), 0.8)
		guiSetAlpha(gui.win, 0.8)
		-- guiSetAlpha(gui.bg, 0.8)
	gui.tabs = {}
	for i, tab in ipairs(tabs) do
		gui.tabs[i] = {}
		gui.tabs[i].bg = guiCreateStaticImage(i * 100 - 100, 0, 100, 80, "media/pixels/transparent.png", false, gui.win)
		-- guiSetAlpha(gui.tabs[i], 0.1)
			guiCreateStaticImage(30, 10, 40, 40, tab.file, false, gui.tabs[i].bg)
			-- guiSetProperty(icon, "ImageColours", "tl:FF0000FF tr:FF0000FF bl:FF0000FF br:FF0000FF")
		local label = guiCreateLabel(0, 50, 100, 30, tab.name, false, gui.tabs[i].bg)
			guiLabelSetColor(label, 204, 204, 204)
			guiSetFont(label, font.content)
			guiLabelSetHorizontalAlign(label, "center")
			guiLabelSetVerticalAlign(label, "center")
		gui.tabs[i].bar = guiCreateStaticImage(0, 78, 100, 2, "media/pixels/grey.png", false, gui.tabs[i].bg)
			guiSetVisible(gui.tabs[i].bar, 1 == i)
		gui.tabs[i].button = guiCreateStaticImage(0, 0, 100, 80, "media/pixels/grey.png", false, gui.tabs[i].bg) 
			guiSetAlpha(gui.tabs[i].button, 0)
			setElementData(gui.tabs[i].button, "index", i)
			addEventHandler("onClientGUIMouseUp", gui.tabs[i].button, onCursorClickTab, false, "high")
			addEventHandler("onClientMouseEnter", gui.tabs[i].button, onCursorEnterTab, false, "high")
			addEventHandler("onClientMouseLeave", gui.tabs[i].button, onCursorLeaveTab, false, "high")
		gui.tabs[i].panel = guiCreateStaticImage(0, 80, 600, 320, "media/pixels/black.png", false, gui.win)
			guiSetAlpha(gui.tabs[i].panel, 0.85)
		if i == 1 then
			gui.tabs[i].dutyToggle = createButton(390, 210, 200, 40, "Rozpocznij służbę", gui.tabs[i].panel)
				addEventHandler("onClientGUIMouseUp", gui.tabs[i].dutyToggle, function()
					triggerServerEvent("onPlayerChangeDutyStatus", resourceRoot, coid, 1)
				end, false, "high")
			gui.tabs[i].clothToggle = createButton(390, 260, 200, 40, "Przebierz się", gui.tabs[i].panel)
				addEventHandler("onClientGUIMouseUp", gui.tabs[i].clothToggle, function()
					triggerServerEvent("onPlayerChangeDutyStatus", resourceRoot, coid, 2)
				end, false, "high")
			
			gui.tabs[i].info = {}
			for j, info in ipairs(infoTab) do
				local iPanel = guiCreateStaticImage(390, j * 36 - 20, 200, 40, "media/pixels/transparent.png", false, gui.tabs[i].panel)
				guiCreateStaticImage(7, 7, 26, 26, info.file, false, iPanel)
				local label = guiCreateLabel(40, 0, 160, 40, info.name, false, iPanel)
					guiLabelSetColor(label, 204, 204, 204)
					guiSetFont(label, font.content)
					guiLabelSetVerticalAlign(label, "center")
					guiLabelSetHorizontalAlign(label, "left", true)
				gui.tabs[i].info[j] = label
			end
			local label = guiCreateLabel(230, 20, 140, 64, "", false, gui.tabs[i].panel)
				guiLabelSetColor(label, 204, 204, 204)
				guiSetFont(label, font.title)
				guiLabelSetVerticalAlign(label, "center")
				guiLabelSetHorizontalAlign(label, "center", true)
				table.insert(gui.tabs[i].info, label)
				table.insert(gui.tabs[i].info, guiCreateStaticImage(230, 84, 140, 2, "media/pixels/grey.png", false, gui.tabs[i].panel))
				table.insert(gui.tabs[i].info, guiCreateStaticImage(230, 110, 140,140, orgIcons[1].path, false, gui.tabs[i].panel))
			local label = guiCreateLabel(10, 26, 200, 30, "Informacje od lidera:", false, gui.tabs[i].panel)
				guiLabelSetColor(label, 204, 204, 204)
				guiSetFont(label, font.title)
				guiLabelSetHorizontalAlign(label, "left", true)
			local label = guiCreateLabel(10, 52, 200, 250, "", false, gui.tabs[i].panel)
				guiLabelSetColor(label, 204, 204, 204)
				guiSetFont(label, font.content)
				guiLabelSetHorizontalAlign(label, "left", true)
				table.insert(gui.tabs[i].info, label)
		elseif i == 2 then
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 280, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			-- addEventHandler("onClientGUIDoubleClick", gui.tabs[i].grid, function()
				-- local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				-- local r, g, b = guiGridListGetItemColor(gui.tabs[i].grid, cRow, 2)
				-- if r == 0 then
					-- guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 255, 0, 0)
				-- elseif g == 0 then
					-- guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 0, 255, 0)
				-- end
			-- end)
			guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.65)
			guiGridListAddColumn(gui.tabs[i].grid, "Na służbie", 0.15)
		elseif i == 3 then
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 280, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			addEventHandler("onClientGUIDoubleClick", gui.tabs[i].grid, function()
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerAskOrganisationPanel", resourceRoot, coid, 3, {vid = vid})
			end)
			guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "Model", 0.65)
			guiGridListAddColumn(gui.tabs[i].grid, "Specjalny", 0.15)
		elseif i == 4 then
			local bNames = {"Dane grupy", "Dane członków", "Zarządzaj uprawnieniami członków", "Zarządzaj uprawnieniami grup", "Zarządzaj grupami członków", "Zarządzaj usługami/produktami", "Pojazdy", "Budynki", "Wiadomość dla personelu", "Pomoc"}
			--600, 320
			for j, bName in ipairs(bNames) do
				local button = createButton(20 + 290 * ((j - 1)%2), 20 + math.floor((j - 1)/2) * 60, 270, 40, bName, gui.tabs[i].panel)
				setElementData(button, "index", j + 6)
				addEventHandler("onClientGUIMouseUp", button, onCursorClickTab, false, "high")
			end
		elseif i == 5 then
			local label = guiCreateLabel(20, 40, 560, 40, "Czy jesteś tego pewien?", false, gui.tabs[i].panel)
				guiLabelSetColor(label, 204, 204, 204)
				guiSetFont(label, font.title)
				guiLabelSetHorizontalAlign(label, "center", true)
			
				addEventHandler("onClientGUIMouseUp", createButton(20, 100, 270, 40, "Tak", gui.tabs[i].panel), function()
					if coid ~= wantToLeaveClicked then
						exports["imta-interface"]:createNotification("Jesteś pewien?", "Opuszczenie organizacji jest akcją nieodwracalną. Czy jesteś tego pewien?", "stop", 5000, 1, 255, 100, 0)
						wantToLeaveClicked = coid
						setTimer(function() 
							wantToLeaveClicked = false
						end, 15000, 1)
					else
						triggerServerEvent("onPlayerLeaveOrganisation", resourceRoot, coid)
					end
				end, false, "high")
			
				addEventHandler("onClientGUIMouseUp", createButton(310, 100, 270, 40, "Nie", gui.tabs[i].panel), function()
					triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, coid, 1)
				end, false, "high")
		end
		if isElement(gui.tabs[i].panel) then
			guiSetVisible(gui.tabs[i].panel, 1 == i)
		end
	end
	for i = 7, 18 do
		gui.tabs[i] = {}
		gui.tabs[i].panel = guiCreateStaticImage(0, 80, 600, 320, "media/pixels/black.png", false, gui.win)
			guiSetAlpha(gui.tabs[i].panel, 0.85)
			guiSetVisible(gui.tabs[i].panel, false)
			
		if i == 7 then
			gui.tabs[i].info = {}
			for j, info in ipairs(infoTabManagement) do
				local iPanel = guiCreateStaticImage(20, j * 30 - 20, 560, 40, "media/pixels/transparent.png", false, gui.tabs[i].panel)
				local label = guiCreateLabel(0, 0, 560, 40, info.name, false, iPanel)
					guiLabelSetColor(label, 204, 204, 204)
					guiSetFont(label, font.content)
					guiLabelSetVerticalAlign(label, "center")
					guiLabelSetHorizontalAlign(label, "left", true)
				gui.tabs[i].info[j] = label
			end

		elseif i == 8 then 
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 280, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.3)
			guiGridListAddColumn(gui.tabs[i].grid, "Ranga", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "Pon", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Wto", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Śro", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Czw", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Pią", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Sob", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "Nie", 0.07)
		elseif i == 9 then
			
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 160, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			gui.tabs[i][1] = guiCreateComboBox(20, 190, 142, 125, "ID skina", false, gui.tabs[i].panel)
			addEventHandler("onClientGUIMouseUp", createButton(182, 190, 20, 20, "?", gui.tabs[i].panel), function()
				exports["imta-interface"]:createNotification("Instrukcja", "Wybierz ID skina z listy. Aby używać skina \"Z grupy\" wybierz skin o id -1", "question_mark", nil, nil, 50, 255, 50)
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", createButton(20, 220, 182, 80, "Zapisz\nskin", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz ustawić skina grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local cid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 7))
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 8))
				local skin = guiComboBoxGetSelected(gui.tabs[i][1])
				if not skin or skin == -1 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wybierz ID skina z listy!", "stop", nil, nil, 255, 204, 0)
					return
				end
				skin = math.floor(tonumber(guiComboBoxGetItemText(gui.tabs[i][1],skin)))
				if not exports["imta-base"]:isOrganisationSkinAllowed(skin) and skin ~= -1 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wybrany skin nie jest poprawny! Błąd: 0x0004. Spróbuj ponownie za minutę.", "stop", nil, nil, 255, 204, 0)
					return
				end
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 9, {rType = "skin", var = skin, gid = gid, cid = cid})
			end, false, "high")
			gui.tabs[i][2] = guiCreateEdit(222, 190, 142, 20, "Maksymalnie 100$", false, gui.tabs[i].panel)
				guiSetFont(gui.tabs[i][2], font.edit)
			addEventHandler("onClientGUIMouseUp", createButton(382, 190, 20, 20, "?", gui.tabs[i].panel), function()
				exports["imta-interface"]:createNotification("Instrukcja", "W pole to wprowadź wysokość wynagrodzenia dla gracza. Jeżeli wprowadzisz wartość -1 to gracz będzie używać domyślnego wynagrodzenia z grupy. Wysokość wynagrodzenia indywidualnego nie może być wyższa od maksymalnego wynagrodzenia w organizacji.", "question_mark", nil, nil, 50, 255, 50)
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", createButton(222, 220, 182, 80, "Zapisz\nwynagrodzenie", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz ustawić wynagrodzenia grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local cid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 7))
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 8))
				local payout = tonumber(guiGetText(gui.tabs[i][2]))
				if not payout or math.floor(payout) < -1 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wysokość wynagrodzenia musi być cyfrą oraz nie może być mniejsza od 0!", "stop", nil, nil, 255, 204, 0)
					return
				end
				payout = math.floor(payout)
				if lVars["max_pay"] < payout then 
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wysokość wynagrodzenia musi być niższa od maksymalnego wynagrodzenia w organizacji ("..lVars["max_pay"].."$)!", "stop", nil, nil, 255, 204, 0)
					return
				end
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 9, {rType = "payout", var = payout, gid = gid, cid = cid})
			end, false, "high")
			gui.tabs[i].rightsButton = createButton(424, 190, 156, 110, "Zmień\nuprawnienia\ngracza", gui.tabs[i].panel)
			addEventHandler("onClientGUIMouseUp", gui.tabs[i].rightsButton, function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz zmienić uprawnień gracza, dopóki nie wybierzesz go z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local cid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 7))
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 8))
				local data = {}
				if guiGridListGetItemText(gui.tabs[i].grid, cRow, 6) == "Tak" then
					data.cid = cid
					data.gid = gid
					data.name = guiGridListGetItemText(gui.tabs[i].grid, cRow, 1)
					
					triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, coid, 18, data)
				else
					triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 9, {rType = "turnOn", gid = gid, cid = cid})
				end
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", gui.tabs[i].grid, function()
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return
				end
				local label = getElementData(gui.tabs[9].rightsButton, "label")
				if guiGridListGetItemText(gui.tabs[i].grid, cRow, 6) == "Tak" then 
					guiSetText(label, "Modyfikuj\nuprawnienia\ngracza")
				else 
					guiSetText(label, "Włącz\nuprawnienia\nindywidualne")
				end

			end, false, "high")
			

			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.28)
			guiGridListAddColumn(gui.tabs[i].grid, "Grupa", 0.21)
			guiGridListAddColumn(gui.tabs[i].grid, "Wypłata", 0.09)
			guiGridListAddColumn(gui.tabs[i].grid, "Skin", 0.09)
			guiGridListAddColumn(gui.tabs[i].grid, "Data dołączenia", 0.14)
			guiGridListAddColumn(gui.tabs[i].grid, "Upr. indywidualne", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "CID", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "GID", 0.12)
		elseif i == 10 then 
			gui.tabs[i].grid = guiCreateGridList(180, 20, 400, 220, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			gui.tabs[i][1] = guiCreateEdit(20, 20, 140, 20, "Maksymalnie 32 znaki", false, gui.tabs[i].panel)
				guiSetFont(gui.tabs[i][1], font.edit)
				guiEditSetMaxLength(gui.tabs[i][1], 32)
			addEventHandler("onClientGUIMouseUp", createButton(20, 60, 140, 40, "Zapisz\nnazwę grupy", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz ustawić nazwy grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				local name = guiGetText(gui.tabs[i][1])
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 10, {rType = "name", var = name, gid = gid})
			end, false, "high")
			gui.tabs[i][2] = guiCreateComboBox(20, 120, 140, 160, "ID skina", false, gui.tabs[i].panel)
			addEventHandler("onClientGUIMouseUp", createButton(20, 160, 140, 40, "Zapisz\nskin", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz ustawić skina grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				local skin = guiComboBoxGetSelected(gui.tabs[i][2])
				if not skin or skin == -1 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wybierz ID skina z listy!", "stop", nil, nil, 255, 204, 0)
					return
				end
				skin = math.floor(tonumber(guiComboBoxGetItemText(gui.tabs[i][2], skin)))
				if not exports["imta-base"]:isOrganisationSkinAllowed(skin) then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wybrany skin nie jest poprawny! Błąd: 0x0004. Spróbuj ponownie za minutę.", "stop", nil, nil, 255, 204, 0)
					return
				end
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 10, {rType = "skin", var = skin, gid = gid})
			end, false, "high")
			gui.tabs[i][3] = guiCreateEdit(20, 220, 140, 20, "Maksymalnie 100$", false, gui.tabs[i].panel)
				guiSetFont(gui.tabs[i][3], font.edit)
			addEventHandler("onClientGUIMouseUp", createButton(20, 260, 140, 40, "Zapisz\nwynagrodzenie", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz ustawić wynagrodzenia grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				local payout = tonumber(guiGetText(gui.tabs[i][3]))
				if not payout or math.floor(payout) < 0 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wysokość wynagrodzenia musi być cyfrą oraz nie może być mniejsza od 0!", "stop", nil, nil, 255, 204, 0)
					return
				end
				payout = math.floor(payout)
				if lVars["max_pay"] < payout then 
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wysokość wynagrodzenia musi być niższa od maksymalnego wynagrodzenia w frakcji ("..lVars["max_pay"].."$)!", "stop", nil, nil, 255, 204, 0)
					return
				end
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 10, {rType = "payout", var = payout, gid = gid})
			end, false, "high")
			
			addEventHandler("onClientGUIMouseUp", createButton(180, 260, 400, 40, "Zmień uprawnienia grupy", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz zmienić uprawnień grupy, dopóki jej nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local data = {}
				data.gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				data.name = guiGridListGetItemText(gui.tabs[i].grid, cRow, 2)
				triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, coid, 17, data)
			end, false, "high")

			

			guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.1)
			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.6)
			guiGridListAddColumn(gui.tabs[i].grid, "Skin", 0.1)
			guiGridListAddColumn(gui.tabs[i].grid, "Wypłata", 0.15)
			
		elseif i == 11 then
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 200, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			gui.tabs[i][1] = guiCreateComboBox(20, 230, 230, 100, "0. Nazwa grupy", false, gui.tabs[i].panel)
				--guiSetFont(gui.tabs[i][1], font.edit)
			addEventHandler("onClientGUIMouseUp", createButton(270, 230, 20, 20, "?", gui.tabs[i].panel), function()
				exports["imta-interface"]:createNotification("Instrukcja", "Aby zmienić grupę do której gracz jest przypisany, zaznacz go, a następnie wybierz z listy odpowiednią grupę i kliknij przycisk \"Zapisz grupę\"", "question_mark", nil, nil, 50, 255, 50)
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", createButton(20, 260, 270, 40, "Zapisz grupę", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz gracza!", "Nie możesz zmienić grupy gracza, dopóki go nie wybierzesz z listy!", "stop", nil, nil, 255, 204, 0)
					return
				end
				local group = guiComboBoxGetSelected(gui.tabs[i][1])
				local cid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 5))
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 6))
				if not group or group < 0 or group > 8 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wybierz grupę do której gracz ma zostać przypisany!", "stop", nil, nil, 255, 204, 0)
					return
				end
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 11, {rType = "change", var = group, gid = gid, cid = cid})
			end, false, "high")

			gui.tabs[i].rightsButton = createButton(310, 230, 270, 70, "Usuń gracza\nz organizacji", gui.tabs[i].panel)
			addEventHandler("onClientGUIMouseUp", gui.tabs[i].rightsButton, function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz grupę!", "Nie możesz usunąć gracza z organizacji, dopóki go nie wybierzesz go z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local cid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 5))
				local gid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 6))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 11, {rType = "remove", gid = gid, cid = cid})
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", gui.tabs[i].grid, function()
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return
				end
				local label = getElementData(gui.tabs[9].rightsButton, "label")
				if guiGridListGetItemText(gui.tabs[i].grid, cRow, 6) == "Tak" then 
					guiSetText(label, "Modyfikuj\nuprawnienia\ngracza")
				else 
					guiSetText(label, "Włącz\nuprawnienia\nindywidualne")
				end

			end, false, "high")
			

			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.28)
			guiGridListAddColumn(gui.tabs[i].grid, "Grupa", 0.21)
			guiGridListAddColumn(gui.tabs[i].grid, "Data dołączenia", 0.14)
			guiGridListAddColumn(gui.tabs[i].grid, "Upr. indywidualne", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "CID", 0.07)
			guiGridListAddColumn(gui.tabs[i].grid, "GID", 0.12)
		elseif i == 12 then
			gui.tabs[i].gid = nil
			gui.tabs[i].cid = nil
			gui.tabs[i].name = nil

			gui.tabs[i][1] = guiCreateEdit(20, 280, 160, 20, "Marża", false, gui.tabs[i].panel)
				guiSetFont(gui.tabs[i][1], font.edit)
			addEventHandler("onClientGUIMouseUp", createButton(200, 280, 20, 20, "?", gui.tabs[i].panel), function()
				exports["imta-interface"]:createNotification("Instrukcja", "W pole to wprowadź wysokość marży. Wprowadzona wartość powinna znajdować się w przedziale <0, 200>", "question_mark", nil, nil, 50, 255, 50)
			end, false, "high")

			addEventHandler("onClientGUIMouseUp", createButton(240, 280, 340, 20, "Zapisz marżę", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					exports["imta-interface"]:createNotification("Wybierz kategorię!", "Nie możesz ustawić wysokości marży produktu/usługi, dopóki nie wybierzesz odpowiedniej kategorii z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local pid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				if not pid then
					exports["imta-interface"]:createNotification("Wybierz kategorię!", "Nie możesz ustawić wysokości marży produktu/usługi, dopóki nie wybierzesz odpowiedniej kategorii z listy!", "stop", nil, nil, 255, 204, 0)
					return 
				end
				local margin = tonumber(guiGetText(gui.tabs[i][1]))
				if not margin or math.floor(margin) < 0 or math.floor(margin) > 200 then
					exports["imta-interface"]:createNotification("Niepoprawne dane!", "Wprowadzona wartość powinna znajdować się w przedziale <0, 200> (same cyfry!)", "stop", nil, nil, 255, 204, 0)
					return
				end
				margin = math.floor(margin)
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 12, {margin = margin, pid = pid, cid = cid})
			end, false, "high")
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 240, false, gui.tabs[i].panel)
				guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
				addEventHandler("onClientGUIDoubleClick", gui.tabs[i].grid, function()
					local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
					local r, g, b = guiGridListGetItemColor(gui.tabs[i].grid, cRow, 2)
					if r == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 255, 0, 0)
					elseif g == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 0, 255, 0)
					end
				end)
				guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.14)
				guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.6)
				guiGridListAddColumn(gui.tabs[i].grid, "Marża (w %)", 0.2)
		elseif i == 13 then 
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 210, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "Model", 0.65)
			guiGridListAddColumn(gui.tabs[i].grid, "Specjalny", 0.15)
			addEventHandler("onClientGUIMouseUp", createButton(20 , 250, 96, 50, "Sprawdź\nhistorię", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return 
				end
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 13, {rType = "checkHistory", vid = vid})
			end, false, "high")
			addEventHandler("onClientGUIMouseUp", createButton(136 , 250, 96, 50, "Usuń\nspecjalność", gui.tabs[i].panel), function()
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return 
				end
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 13, {rType = "removeSpecial", vid = vid})
			end, false, "high")
			addEventHandler("onClientGUIMouseUp", createButton(252 , 250, 96, 50, "Ustaw\nspecjalność A", gui.tabs[i].panel), function()
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return 
				end
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 13, {rType = "setSpecialA", vid = vid})
			end, false, "high")
			addEventHandler("onClientGUIMouseUp", createButton(368 , 250, 96, 50, "Ustaw\nspecjalność B", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return 
				end
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 13, {rType = "setSpecialB", vid = vid})
			end, false, "high")
			addEventHandler("onClientGUIMouseUp", createButton(484 , 250, 96, 50, "Usuń\npojazd", gui.tabs[i].panel), function() 
				local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
				if not cRow or cRow == -1 then
					return 
				end
				local vid = tonumber(guiGridListGetItemText(gui.tabs[i].grid, cRow, 1))
				triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 13, {rType = "removeVehicle", vid = vid})
			end, false, "high")

		elseif i == 14 then 
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 280, false, gui.tabs[i].panel)
			guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
			guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.15)
			guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.6)
			guiGridListAddColumn(gui.tabs[i].grid, "Typ", 0.2)
		elseif i == 15 then 
			gui.tabs[i].edit = guiCreateMemo(20, 20, 560, 180, "", false, gui.tabs[i].panel)
			local label = guiCreateLabel(20, 200, 560, 60, "Notatka od lidera (maksimum 256 znaków, polecam unikać Entera, po zapisaniu tekst będzie widoczny w pierwszej zakładce)", false, gui.tabs[i].panel)
				guiLabelSetColor(label, 204, 204, 204)
				guiSetFont(label, font.content)
				guiLabelSetVerticalAlign(label, "center")
				guiLabelSetHorizontalAlign(label, "center", true)
			guiSetFont(gui.tabs[i].edit, font.content)
				guiSetProperty(gui.tabs[i].edit, "MaxTextLength", 256)
				addEventHandler("onClientGUIMouseUp", createButton(20 , 260, 270, 40, "Zapisz", gui.tabs[i].panel), function()
					local text = guiGetText(gui.tabs[15].edit)
					triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 15, {text = text})
				end, false, "high")
				addEventHandler("onClientGUIMouseUp", createButton(310, 260, 270, 40, "Cofnij", gui.tabs[i].panel), function()
					triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, coid, 4)
				end, false, "high")
		elseif i == 16 then 
			gui.tabs[i].edit = guiCreateMemo(20, 20, 560, 280, ORG_PANEL_HELP_TEXT, false, gui.tabs[i].panel)
				guiSetFont(gui.tabs[i].edit, font.content)
				guiSetEnabled(gui.tabs[i].edit, false)
		elseif i == 17 then
			--600, 320
			gui.tabs[i].gid = nil
			gui.tabs[i].name = nil
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 220, false, gui.tabs[i].panel)
				guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
				addEventHandler("onClientGUIDoubleClick", gui.tabs[i].grid, function()
					local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
					local r, g, b = guiGridListGetItemColor(gui.tabs[i].grid, cRow, 2)
					if r == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 255, 0, 0)
					elseif g == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 0, 255, 0)
					end
				end)
				guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.14)
				guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.78)
			gui.tabs[i].button = createButton(20, 260, 560, 40, "Zapisz ustawienia grupy", gui.tabs[i].panel)
				addEventHandler("onClientGUIMouseUp", gui.tabs[i].button, function()
					local permissonListAllowed = {}
					-- local permissonListDisallowed = {}
					if not gui.tabs[17].gid then 
						return 
					end
					for i = 0, guiGridListGetRowCount(gui.tabs[17].grid) - 1 do
						local r, g, b = guiGridListGetItemColor(gui.tabs[17].grid, i, 2)
						if g == 255 and r == 0 then
							local pIndex = tonumber(guiGridListGetItemText(gui.tabs[17].grid, i, 1))
							if pIndex then
								table.insert(permissonListAllowed, pIndex)
							end
						end
					end
					triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 17, {permissonListNew = permissonListAllowed, gid = gui.tabs[17].gid, name = gui.tabs[17].name})
				end, false, "high")
		elseif i == 18 then
			gui.tabs[i].gid = nil
			gui.tabs[i].cid = nil
			gui.tabs[i].name = nil
			
			gui.tabs[i].grid = guiCreateGridList(20, 20, 560, 210, false, gui.tabs[i].panel)
				guiGridListSetSortingEnabled(gui.tabs[i].grid, false)
				addEventHandler("onClientGUIDoubleClick", gui.tabs[i].grid, function()
					local cRow = guiGridListGetSelectedItem( gui.tabs[i].grid)
					local r, g, b = guiGridListGetItemColor(gui.tabs[i].grid, cRow, 2)
					if r == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 255, 0, 0)
					elseif g == 0 then
						guiGridListSetItemColor(gui.tabs[i].grid, cRow, 2, 0, 255, 0)
					end
				end)
				guiGridListAddColumn(gui.tabs[i].grid, "ID", 0.14)
				guiGridListAddColumn(gui.tabs[i].grid, "Nazwa", 0.78)
			gui.tabs[i].delete = createButton(20, 250, 270, 50, "Usuń uprawnienia\nindywidualne gracza", gui.tabs[i].panel)			
				addEventHandler("onClientGUIMouseUp", gui.tabs[i].delete, function()
					triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 9, {rType = "turnOff", gid = gui.tabs[18].gid, cid = gui.tabs[18].cid, name = gui.tabs[18].name})
				end, false, "high")
			
			gui.tabs[i].button = createButton(310, 250, 270, 50, "Zapisz ustawienia gracza", gui.tabs[i].panel)
				addEventHandler("onClientGUIMouseUp", gui.tabs[i].button, function()
					local permissonListAllowed = {}
					if not gui.tabs[18].gid then 
						return 
					end
					for i = 0, guiGridListGetRowCount(gui.tabs[18].grid) - 1 do
						local r, g, b = guiGridListGetItemColor(gui.tabs[18].grid, i, 2)
						if g == 255 and r == 0 then
							local pIndex = tonumber(guiGridListGetItemText(gui.tabs[18].grid, i, 1))
							if pIndex then
								table.insert(permissonListAllowed, pIndex)
							end
						end
					end
					triggerServerEvent("onPlayerEditOrganisationPanel", resourceRoot, coid, 18, {permissonListNew = permissonListAllowed, gid = gui.tabs[18].gid, cid = gui.tabs[18].cid, name = gui.tabs[18].name})
				end, false, "high")
			
		end
	end
		-- guiCreateStaticImage(20, 20, 40, 40, "media/icons/suitcase.png", false, gui.selectGroup.title)
		-- local title = guiCreateLabel(80, 8, 420, 70, "Grupy:", false, gui.selectGroup.title)
		-- guiLabelSetColor(title, 65, 67, 69)
		-- guiSetFont(title, font.title)
	guiSetVisible(gui.bg, false)
end

hideWindow = function()
	if guiGetVisible(gui.bg) then
		guiSetVisible(gui.bg, false)
		destroyBlurBox()
		showCursor(false)
	end
end

showWindow = function(data)
	if not guiGetVisible(gui.bg) then
		guiSetVisible(gui.bg, true)
		spawnBlurBox()
		guiBringToFront(panelWindow)
		showCursor(true)
	end
end

addEventHandler( "onClientResourceStop", getResourceRootElement( getThisResource()),
function()
	destroyBlurBox()
end)


addEvent("onPlayerDemandOrganisationPanelResponse", true )
addEventHandler("onPlayerDemandOrganisationPanelResponse", resourceRoot, function(i, data, oid, additionalData)
	local color
	if coid ~= oid then
		if i == 1 then
			for j, t in ipairs(gui.tabs) do
				if j == 7 then
					break
				end
				guiSetProperty(gui.tabs[j].bar, "ImageColours", "tl:FF"..data.color.." tr:FF"..data.color.." bl:FF"..data.color.." br:FF"..data.color)
			end
		end
	end
	if i ~= currentID then
		guiSetVisible(gui.tabs[currentID].panel, false)
		if isElement(gui.tabs[currentID].bar) then
			guiSetVisible(gui.tabs[currentID].bar, false)
		end
		currentID = i
		guiSetVisible(gui.tabs[currentID].panel, true)
		if isElement(gui.tabs[currentID].bar) then
			guiSetVisible(gui.tabs[currentID].bar, true)
		end
	end
	if i  == 1 then
		showWindow()
		data.leader_name = ((data.char_first_name or "").." "..(data.char_last_name or ""))
		for j, info in ipairs(infoTab) do
			guiSetText(gui.tabs[i].info[j], info.name..(info.name_before or "")..data[info.base]..(info.name_after or ""))
		end
		guiSetText(gui.tabs[i].info[6], data.name)
		guiSetProperty(gui.tabs[i].info[7], "ImageColours", "tl:FF"..data.color.." tr:FF"..data.color.." bl:FF"..data.color.." br:FF"..data.color)
		guiStaticImageLoadImage(gui.tabs[i].info[8], orgIcons[data.icon_id].path)
		guiSetText(gui.tabs[i].info[9], data.leader_note)
		coid = data.id
		if coid == data.currentOrganisationID then
			guiSetText(getElementData(gui.tabs[1].dutyToggle, "label"), "Zakończ służbę")
		elseif data.currentOrganisationID then
			guiSetText(getElementData(gui.tabs[1].dutyToggle, "label"), "Zmień służbę")
		else
			guiSetText(getElementData(gui.tabs[1].dutyToggle, "label"), "Rozpocznij służbę")
		end
	elseif i == 2 then
		table.sort(data, function(a,b) 
			if a.onDuty == b.onDuty then 
				return a.id < b.id
			else
				return a.onDuty == true
			end
		end)

		guiGridListClear(gui.tabs[i].grid)
		for j, data in ipairs(data) do
			guiGridListAddRow(gui.tabs[i].grid, data.id, data.name, data.onDuty == true and "Tak" or "")
		end
		showWindow()
	elseif i == 3 then
		guiGridListClear(gui.tabs[i].grid)
		if data then
			local vehHandling = exports["imta-handling"]
			for j, data in ipairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.veh_id, vehHandling:getVehicleProperty(data.veh_model, "name") or getVehicleNameFromModel(data.veh_model), VEHICLES_TYPES_DICTIONARY[data.veh_special])
			end
		end
		showWindow()
	
	elseif i == 4 then
		
	elseif i == 5 then
		if data then
			hideWindow()
		end
	elseif i == 6 then
		if data then 
			hideWindow()
		end
	elseif i == 7 then
		for j, info in ipairs(infoTabManagement) do
			guiSetText(gui.tabs[i].info[j], info.name..(info.name_before or "")..data[info.base]..(info.name_after or ""))
		end

	elseif i == 8 then
		guiGridListClear(gui.tabs[i].grid)
		local processedData = {}
		for j, row in ipairs(data) do 
			if not processedData[row.char_id] then 
				processedData[row.char_id] = {}
				processedData[row.char_id][1] = row.char_name
				processedData[row.char_id][2] = row.group_name
				for t = 3, 9 do 
					processedData[row.char_id][t] = 0
				end
			end
			processedData[row.char_id][row.column_index] = row.playtime
		end 
		for j, row in pairs(processedData) do 
			guiGridListAddRow(gui.tabs[i].grid, unpack(row))
		end 
		showWindow()
	elseif i == 9 then
		guiGridListClear(gui.tabs[i].grid)
		guiComboBoxClear(gui.tabs[i][1])
		guiComboBoxAddItem(gui.tabs[i][1], -1)
		local skinList = exports["imta-base"]:getSkinTable()
		for j, skin in pairs(skinList) do
			if skin.organisationAllowed then
				guiComboBoxAddItem(gui.tabs[i][1], j)
			end
		end
		-- guiSetText(gui.tabs[i][1], "Maksymalnie 32 znaki")
		-- guiEditSetCaretIndex(gui.tabs[i][1], 1)
		-- guiSetText(gui.tabs[i][2], "ID Skina")
		-- TODO: dodać to resetowanie pól

		if data then
			lVars["max_pay"] = data[1].max_pay
			guiSetText(gui.tabs[i][2], "Maksymalnie "..lVars["max_pay"].."$")
			for j, data in ipairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.char_name, data.group_name, data.payout == -1 and "Z grupy" or (data.payout.."$"), data.skin_id, data.join_time, data.use_individual_rights == 1 and "Tak" or "Nie", data.char_id, data.group_id)
			end
		end
		showWindow()
		
	elseif i == 10 then
		guiGridListClear(gui.tabs[i].grid)
		guiSetText(gui.tabs[i][1], "Maksymalnie 32 znaki")
		guiEditSetCaretIndex(gui.tabs[i][1], 1)
		guiComboBoxClear(gui.tabs[i][2])
		local skinList = exports["imta-base"]:getSkinTable()
		for j, skin in pairs(skinList) do
			if skin.organisationAllowed then
				guiComboBoxAddItem(gui.tabs[i][2], j)
			end
		end
		lVars["max_pay"] = data[1].max_pay
		guiSetText(gui.tabs[i][3], "Maksymalnie "..lVars["max_pay"].."$")
		local label = getElementData(gui.tabs[17].button, "label")
		guiSetText(label, "Zmień uprawnienia grupy")
		if data then
			for j, data in pairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.internal_id, data.name, data.skin_id, data.payout.."$")
			end
		end
		showWindow()
	elseif i == 11 then
		guiGridListClear(gui.tabs[i].grid)
		guiComboBoxClear(gui.tabs[i][1])
		-- guiSetText(gui.tabs[i][1], "Maksymalnie 32 znaki")
		-- guiEditSetCaretIndex(gui.tabs[i][1], 1)
		-- guiSetText(gui.tabs[i][2], "ID Skina")
		
		if data then
			for j, data in ipairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.char_name, data.group_name, data.join_time, data.use_individual_rights == 1 and "Tak" or "Nie", data.char_id, data.group_id)
			end
		end
		if additionalData then
			for j, data in ipairs(additionalData) do
				guiComboBoxAddItem(gui.tabs[i][1], (data.internal_id)..". "..data.name)
				
			end
		end
		showWindow()
	elseif i == 12 then
		guiGridListClear(gui.tabs[i].grid)
		
		local categoriesIndices = {}
		local categories = {}
		for j, cat in ipairs(additionalData) do
			
			if j == 1 then
				categoriesIndices[j] = cat.category
			else
				categoriesIndices[additionalData[j-1].category] = cat.category
			end
			categories[cat.category] = cat.categoryNamePL
		end
		local category = categoriesIndices[1]
		for j, perm in ipairs(data) do
			if category == perm.category then
				local row = guiGridListAddRow(gui.tabs[i].grid, "", categories[category])
				guiGridListSetItemText(gui.tabs[i].grid, row, 2, categories[category], true, false)
				category = categoriesIndices[category]
			end
			local row = guiGridListAddRow(gui.tabs[i].grid, perm.permission_id, perm.namePL ~= "" and  perm.namePL or perm.name, perm.margin)
			if perm.id then
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 0, 255, 0)
			else
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 255, 0, 0)
			end
		end
		
		showWindow()
		guiSetText(gui.tabs[i][1], "Marża")
	elseif i == 13 then
		guiGridListClear(gui.tabs[i].grid)
		if data then
			local vehHandling = exports["imta-handling"]
			for j, data in ipairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.veh_id, vehHandling:getVehicleProperty(data.veh_model, "name") or getVehicleNameFromModel(data.veh_model), VEHICLES_TYPES_DICTIONARY[data.veh_special])
			end
		end
		showWindow()
	elseif i == 14 then
		guiGridListClear(gui.tabs[i].grid)
		if data then
			for j, data in ipairs(data) do
				guiGridListAddRow(gui.tabs[i].grid, data.int_id, data.int_name, BUILDINGS_TYPES_DICTIONARY[data.int_type])
			end
		end
		showWindow()
	elseif i == 17 then
		guiGridListClear(gui.tabs[i].grid)
		
		local categoriesIndices = {}
		local categories = {}
		for j, cat in ipairs(additionalData) do
			if j == 1 then
				categoriesIndices[j] = cat.category
			else
				categoriesIndices[additionalData[j-1].category] = cat.category
			end
			categories[cat.category] = cat.categoryNamePL
		end
		local category = categoriesIndices[1]
		for j, perm in ipairs(data) do
			if category == perm.category then
				local row = guiGridListAddRow(gui.tabs[i].grid, "", categories[category])
				guiGridListSetItemText(gui.tabs[i].grid, row, 2, categories[category], true, false)
				category = categoriesIndices[category]
			end
			local row = guiGridListAddRow(gui.tabs[i].grid, perm.permission_id, perm.namePL ~= "" and  perm.namePL or perm.name)
			if perm.id then
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 0, 255, 0)
			else
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 255, 0, 0)
			end
		end
		showWindow()
		gui.tabs[i].gid = additionalData.gid
		gui.tabs[i].name = additionalData.name
		local label = getElementData(gui.tabs[i].button, "label")
		guiSetText(label, "Zmień uprawnienia grupy - "..additionalData.name.." ("..additionalData.gid..")")
	elseif i == 18 then
		guiGridListClear(gui.tabs[i].grid)
		
		local categoriesIndices = {}
		local categories = {}
		for j, cat in ipairs(additionalData) do
			if j == 1 then
				categoriesIndices[j] = cat.category
			else
				categoriesIndices[additionalData[j-1].category] = cat.category
			end
			categories[cat.category] = cat.categoryNamePL
		end
		local category = categoriesIndices[1]
		for j, perm in ipairs(data) do
			if category == perm.category then
				local row = guiGridListAddRow(gui.tabs[i].grid, "", categories[category])
				guiGridListSetItemText(gui.tabs[i].grid, row, 2, categories[category], true, false)
				category = categoriesIndices[category]
			end
			local row = guiGridListAddRow(gui.tabs[i].grid, perm.permission_id, perm.namePL ~= "" and  perm.namePL or perm.name)
			if perm.id then
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 0, 255, 0)
			else
				guiGridListSetItemColor(gui.tabs[i].grid, row, 2, 255, 0, 0)
			end
		end
		showWindow()
		gui.tabs[i].gid = additionalData.gid
		gui.tabs[i].cid = additionalData.cid
		gui.tabs[i].name = additionalData.name
		local label = getElementData(gui.tabs[i].button, "label")
		guiSetText(label, "Zmień uprawnienia gracza\n"..additionalData.name.." ("..additionalData.gid.." - "..additionalData.cid..")")
	end
end)

addEvent("onPlayerChangeDutyStatusResponse", true )
addEventHandler("onPlayerChangeDutyStatusResponse", resourceRoot, function(i, data, orgName, orgColor)
	if not i then
		return
	end
	if i == 1 then
		if orgName then 
			setElementData(localPlayer, "organisation:name", orgName, false)
			setElementData(localPlayer, "organisation:color", orgColor, false)
		else 
			setElementData(localPlayer, "organisation:name", nil, false)
			setElementData(localPlayer, "organisation:color", nil, false)
		end
		exports["imta-interface"]:updateInterface("faction")
		if data then 
			guiSetText(getElementData(gui.tabs[1].dutyToggle, "label"), "Zakończ służbę")
		else 
			guiSetText(getElementData(gui.tabs[1].dutyToggle, "label"), "Rozpocznij służbę")
		end
	elseif i == 2 then 
		--?TODO : ??
		
	end	
end)



