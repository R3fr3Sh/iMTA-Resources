local gui = {}
local guiCE = {}
local sx, sy = guiGetScreenSize()
local hideWindow, showWindow
local hideWindowCE, showWindowCE
local hex = "FFFFFF"
local organisations = {}
local orgBeingEdited
hideWindow = function()
	guiSetVisible(gui.win, false)
	showCursor(false)
end
local wasRemoveOrgButtonClicked = false

showWindow = function(newOrganisations)
	guiSetVisible(gui.win, true)
	guiSetVisible(gui.winData, false)
	guiSetVisible(guiCE.win, false)
	showCursor(true)
	guiGridListClear(gui.grid)
	organisations = newOrganisations
	for i, org in ipairs(organisations) do
		local row = guiGridListAddRow(gui.grid, org.id, org.name)
		--columny liczą się od 1, rowy od 0
		--guiGridListSetItemColor(gui.grid, row, 2, 255, 0, 0)
	end
end

showWindowData = function(players)
	guiSetVisible(gui.win, false)
	guiSetVisible(guiCE.win, false)
	guiSetVisible(gui.winData, true)
	showCursor(true)
	guiGridListClear(gui.gridData)
	for i, plr in ipairs(players) do
		local row = guiGridListAddRow(gui.gridData, plr.char_name, plr.group_name, plr.join_time)
	end
end

local function getCurrentlySelectedOrganisationID()
	return tonumber(guiGridListGetItemText(gui.grid, guiGridListGetSelectedItem(gui.grid), 1 ))
end

local function fetchFactionEditionData()
	local comboIconID = guiComboBoxGetSelected(guiCE.icon)
	if (not comboIconID) or comboIconID < 0 then
		exports["imta-interface"]:createNotification("Brak symbolu", "Aby utworzyć nową organizację musisz wybrać jej symbol!", "stop", 5000, 1, 255, 204, 0)
		return
	end
	comboIconID = comboIconID + 1
	
	local color = hex
	if not color or string.len(color) ~= 6 then
		exports["imta-interface"]:createNotification("Błędny kolor", "Wartość koloru "..tostring(color).." jest niepoprawna. Jeżeli ten błąd nie powinien wystąpić zgłoś go administracji", "stop", 5000, 1, 255, 204, 0)
		return
	end

	local name = guiGetText(guiCE.name)
	
	local maxPayout = tonumber(guiGetText(guiCE.pay))
	if not maxPayout then
		exports["imta-interface"]:createNotification("Błędne wynagrodzenie", "Aby utworzyć nową organizację musisz wprowadzić górny limit wynagrodzeń!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif maxPayout < 0 then
		exports["imta-interface"]:createNotification("Zbyt niskie wynagrodzenie", "Maksymalne godzinowe wynagrodzenie organizacji nie może być ujemne!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif maxPayout > 5000 then
		exports["imta-interface"]:createNotification("Zbyt duże wynagrodzenie", "Maksymalne godzinowe wynagrodzenie organizacji nie powinno przekraczać 5000$!", "stop", 5000, 1, 255, 204, 0)
		return
	end
	
	local totalMaxPayout = tonumber(guiGetText(guiCE.totalPay))
	if not totalMaxPayout then
		exports["imta-interface"]:createNotification("Błędne wynagrodzenie", "Aby utworzyć nową organizację musisz wprowadzić górny limit wynagrodzeń!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif totalMaxPayout < 0 then
		exports["imta-interface"]:createNotification("Zbyt niskie wynagrodzenie", "Maksymalne godzinowe wynagrodzenie organizacji nie może być ujemne!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif totalMaxPayout > 1000000 then
		exports["imta-interface"]:createNotification("Zbyt duże wynagrodzenie", "Maksymalne godzinowe wynagrodzenie organizacji nie powinno przekraczać 1.000.000$!", "stop", 5000, 1, 255, 204, 0)
		return
	end
	
	local maxMembers = tonumber(guiGetText(guiCE.member))
	if not maxMembers then
		exports["imta-interface"]:createNotification("Błędne ilość członków", "Aby utworzyć nową organizację musisz wprowadzić poprawny (numeryczny) limit graczy do niej należących!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif maxMembers < 0 then
		exports["imta-interface"]:createNotification("Zbyt niski limit", "Maksymalna liczba członków organizacji nie może być ujemna!", "stop", 5000, 1, 255, 204, 0)
		return
	elseif maxMembers > 500 then
		exports["imta-interface"]:createNotification("Zbyt wysoki limit", "Maksymalna ilość członków organizacji nie może przekraczać 500 osób!", "stop", 5000, 1, 255, 204, 0)
		return
	end
	
	local leaderName = guiGetText(guiCE.cidLabel)
	local cid = tonumber(guiGetText(guiCE.cid))
	if leaderName == "Nazwa: brak" then
		exports["imta-interface"]:createNotification("Niepoprawne id postaci", "Postać o takim ID nie istnieje!", "stop", 5000, 1, 255, 204, 0)
	elseif not cid or cid < 0 then
		exports["imta-interface"]:createNotification("Niepoprawne id postaci", "ID postaci musi być liczbą naturalną!", "stop", 5000, 1, 255, 204, 0)
	end
	
	local permissonList = {}
	for i = 0, guiGridListGetRowCount(guiCE.grid) - 1 do
		local r, g, b = guiGridListGetItemColor(guiCE.grid, i, 2)
		if g == 255 and r == 0 then
			local pIndex = tonumber(guiGridListGetItemText(guiCE.grid, i, 1))
			if pIndex then
				table.insert(permissonList, pIndex)
			end
		end
	end
	local data = 
	{
		iconID = comboIconID,
		color = color,
		name = name,
		maxPayout = maxPayout,
		totalMaxPayout = totalMaxPayout,
		maxMembers= maxMembers,
		cid = cid,
		pList = permissonList,
		oid = orgBeingEdited,
	}
	triggerServerEvent("onClientDemandOrganisationEdition", resourceRoot, data, orgBeingEdited)
end

addEvent("onServerReturnOrganisationEditData", true)
addEventHandler("onServerReturnOrganisationEditData", resourceRoot, function(result, permList, catList, oid)
	
	hideWindow()
	showCursor(true)
	guiSetVisible(guiCE.win, true)
	
	orgBeingEdited = oid

	
	local name = guiSetText(guiCE.name, result.name)
	
	hex = result.color
	guiSetText(guiCE.colorPicker, "Wybierz kolor organizacji\n#"..hex)
	
	guiComboBoxSetSelected(guiCE.icon, result.icon_id - 1)
	
	local maxPayout = guiSetText(guiCE.pay, result.max_pay)
	
	local totalMaxPayout = guiSetText(guiCE.totalPay, result.max_pay_daily)
	
	local maxMembers = guiSetText(guiCE.member, result.member_limit)
	
	local cid = guiSetText(guiCE.cid, result.leader_id)
	local content = guiGetText(guiCE.cid)
	if tonumber(content) then
		triggerServerEvent("onClientDemandCharacterNameFromCID", resourceRoot, tonumber(content))
	else
		guiSetText(guiCE.cidLabel, "Nazwa: brak")
	end

	
	guiGridListClear(guiCE.grid)
	
	local categoriesIndices = {}
	local categories = {}
	for j, cat in ipairs(catList) do
		if j == 1 then
			categoriesIndices[j] = cat.category
		else
			categoriesIndices[catList[j-1].category] = cat.category
		end
		categories[cat.category] = cat.categoryNamePL
	end
	local category = categoriesIndices[1]
	for j, perm in ipairs(permList) do
		if category == perm.category then
			local row = guiGridListAddRow(guiCE.grid, "", categories[category])
			guiGridListSetItemText(guiCE.grid, row, 2, categories[category], true, false)
			category = categoriesIndices[category]
		end
		local row = guiGridListAddRow(guiCE.grid, perm.id, perm.namePL ~= "" and  perm.namePL or perm.name)
		if perm.is_used then
			guiGridListSetItemColor(guiCE.grid, row, 2, 0, 255, 0)
		else
			guiGridListSetItemColor(guiCE.grid, row, 2, 255, 0, 0)
		end
	end

end)

do
	gui.win = guiCreateWindow(sx/2 - 350, sy/2 - 225, 700, 450, "Modyfikowanie organizacji", false)
	guiCreateLabel(20, 30, 200, 20, "Szukaj organizacji:", false, gui.win)
	gui.name = guiCreateEdit(20, 50, 200, 20, "", false, gui.win)
		guiEditSetMaxLength(gui.name, 32)
		addEventHandler("onClientGUIChanged", gui.name, function()
			guiGridListClear(gui.grid)
			local sOrgName = string.lower(guiGetText(gui.name))
			if sOrgName ~= "" then
				for k, org in ipairs(organisations) do
					if string.find(string.lower(org.name), sOrgName) then
						local row = guiGridListAddRow(gui.grid, org.id, org.name)
					end
				end
			else 
				for k, org in ipairs(organisations) do
					local row = guiGridListAddRow(gui.grid, org.id, org.name)
				end
			end
		end)
	guiCreateLabel(20, 80, 200, 20, "Wysokość przelanej kwoty:", false, gui.win) 
	gui.moneyToBeSent = guiCreateEdit(20, 100, 200, 20, "", false, gui.win)
	gui.sendMoney = guiCreateButton(20, 135, 200, 30, "Przelej środki dla organizacji", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.sendMoney, function()
			local orgID = getCurrentlySelectedOrganisationID()
			if not orgID then 
				exports["imta-interface"]:createNotification("Brak organizacji!", "Aby móc przelać środki jakiejkolwiek organizacji wpierw musisz ją wybrać z listy!", "stop", nil, 1, 255, 204, 0)
				return
			end
			local amount = tonumber(guiGetText(gui.moneyToBeSent))
			if not amount or amount < 0 then
				exports["imta-interface"]:createNotification("Niepoprawna kwota!", "Kwota którą wprowadziłeś jest niepoprawna!", "stop", nil, 1, 255, 204, 0)
				return
			end
			triggerServerEvent("onClientDemandTransferOfMoney", resourceRoot, orgID, amount)
			--trigger evnet serwer
		end, false, "high")
	gui.joinOrg = guiCreateButton(20, 180, 200, 30, "Dołącz do organizacji", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.joinOrg, function()
			local orgID = getCurrentlySelectedOrganisationID()
			if not orgID then 
				exports["imta-interface"]:createNotification("Brak organizacji!", "Aby móc dołączyć do jakiejkolwiek organizacji wpierw musisz ją wybrać z listy!", "stop", nil, 1, 255, 204, 0)
				return
			end
			triggerServerEvent("onClientDemandJoinOrganisation", resourceRoot, orgID)
			--trigger evnet serwer
		end, false, "high")
	gui.editOrg = guiCreateButton(20, 225, 200, 30, "Edytuj organizację", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.editOrg, function()
			local orgID = getCurrentlySelectedOrganisationID()
			if not orgID then 
				exports["imta-interface"]:createNotification("Brak organizacji!", "Aby móc modyfikować organizację wpierw musisz ją wybrać z listy!", "stop", nil, 1, 255, 204, 0)
				return
			end
			triggerServerEvent("onClientDemandOrganisationEditData", resourceRoot, orgID)
			--trigger evnet serwer
		end, false, "high")
	gui.getOrgPlayers = guiCreateButton(20, 270, 200, 30, "Dane członków organizacji", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.getOrgPlayers, function()
			local orgID = getCurrentlySelectedOrganisationID()
			if not orgID then 
				exports["imta-interface"]:createNotification("Brak organizacji!", "Aby móc zobaczyć listę członków organizacji wpierw musisz ją (organizację) wybrać z listy!", "stop", nil, 1, 255, 204, 0)
				return
			end
			triggerServerEvent("onClientDemandOrganisationCharacterList", resourceRoot, orgID)
			--trigger evnet serwer
		end, false, "high")
	gui.removeOrg = guiCreateButton(20, 315, 200, 60, "USUŃ ORGANIZACJĘ\n(NIEODWRACALNE!)", false, gui.win)
		guiSetProperty(gui.removeOrg, "NormalTextColour", "FFAA0000")
		guiSetProperty(gui.removeOrg, "HoverTextColour", "FFFF0000")
		guiSetProperty(gui.removeOrg, "PushedTextColour", "FFDD0000")
		addEventHandler("onClientGUIMouseUp", gui.removeOrg, function()
			local orgID = getCurrentlySelectedOrganisationID()
			if not orgID then 
				exports["imta-interface"]:createNotification("Brak organizacji!", "Aby móc skasować organizację wpierw musisz ją (organizację) wybrać z listy!", "stop", nil, 1, 255, 204, 0)
				return
			end
			if orgID ~= wasRemoveOrgButtonClicked then
				exports["imta-interface"]:createNotification("Jesteś pewien?", "Kasacja organizacji jest akcją nieodwracalną, jej wszystkie dane zostanę utracone. Jeżeli mimo tego chcesz kontynuować kliknij w przycisk ponownie.", "stop", 10000, 1, 255, 204, 0)
				wasRemoveOrgButtonClicked = orgID
				guiSetEnabled(gui.removeOrg, false)
				setTimer(function() 
					guiSetEnabled(gui.removeOrg, true)
				end, 5000, 1)
				setTimer(function() 
					wasRemoveOrgButtonClicked = false
				end, 15000, 1)
			else
				outputChatBox("KASUJEMY")
			end
		end, false, "high")
	gui.close = guiCreateButton(20, 390, 200, 40, "Zamknij", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.close, hideWindow, false, "high")
	gui.grid = guiCreateGridList(240, 30, 440, 400, false, gui.win)
		guiGridListSetSortingEnabled(gui.grid, false)
		addEventHandler("onClientGUIDoubleClick", gui.grid, function()
			local cRow = guiGridListGetSelectedItem( gui.grid )
			local r, g, b = guiGridListGetItemColor(gui.grid, cRow, 2)
			if r == 0 then
				guiGridListSetItemColor(gui.grid, cRow, 2, 255, 0, 0)
			elseif g == 0 then
				guiGridListSetItemColor(gui.grid, cRow, 2, 0, 255, 0)
			end
		end)
		guiGridListAddColumn(gui.grid, "ID", 0.14)
		guiGridListAddColumn(gui.grid, "Nazwa", 0.78)
	guiSetVisible(gui.win, false)
end

do
	gui.winData = guiCreateWindow(sx/2 - 350, sy/2 - 225, 700, 450, "Dane członków organizacji", false)
	gui.gridData = guiCreateGridList(20, 30, 660, 360, false, gui.winData)
	gui.backData = guiCreateButton(20, 400, 660, 40, "Cofnij", false, gui.winData)

	addEventHandler("onClientGUIMouseUp", gui.backData, function()
		triggerServerEvent("onPlayerDemandFindGroupWindow", resourceRoot, localPlayer)
	end, false, "high")
		
	guiGridListAddColumn(gui.gridData, "Nazwa", 0.4)
	guiGridListAddColumn(gui.gridData, "Grupa", 0.35)
	guiGridListAddColumn(gui.gridData, "Data dołączenia", 0.2)
	guiSetVisible(gui.winData, false)
end


do
	guiCE.win = guiCreateWindow(sx/2 - 350, sy/2 - 225, 700, 450, "Edycja organizacji", false)
	guiCE.icon = guiCreateComboBox(20, 30, 180, 200, "Ikona organizacji", false, guiCE.win)
	guiCE.colorPicker = guiCreateButton(20, 70, 180, 40, "Wybierz kolor organizacji\n#FFFFFF", false, guiCE.win)
		addEventHandler("onClientGUIMouseUp", guiCE.colorPicker, function() 
			colorPicker.create(1, "#"..hex, "Kolor organizacji", true) 
		end, false, "high")
	guiCreateLabel(20, 125, 180, 20, "Nazwa organizacji:", false, guiCE.win)
	guiCE.nameEx =  "Maksimum 32 znaki"
	guiCE.name = guiCreateEdit(20, 145, 180, 20, guiCE.nameEx, false, guiCE.win)
		guiEditSetMaxLength(guiCE.name, 32)
	guiCreateLabel(20, 175, 180, 20, "Górny limit wypłaty (na godzinę):", false, guiCE.win)
	guiCE.payEx = "Maksimum 5000$"
	guiCE.pay = guiCreateEdit(20, 195, 180, 20, guiCE.payEx, false, guiCE.win)
	guiCreateLabel(20, 225, 180, 20, "Dzienna pula wynagrodzeń:", false, guiCE.win)
	guiCE.totalPayEx = "Maksimum 1.000.000$"
	guiCE.totalPay = guiCreateEdit(20, 245, 180, 20, guiCE.totalPayEx, false, guiCE.win)
	guiCreateLabel(20, 275, 180, 20, "Limit członków (0 = brak limitu):", false, guiCE.win)
	guiCE.memberEx = "0"
	guiCE.member = guiCreateEdit(20, 295, 180, 20, guiCE.memberEx, false, guiCE.win)
	guiCreateLabel(20, 325, 180, 20, "CID lidera:", false, guiCE.win)
	guiCE.cidEx = "ID postaci"
	guiCE.cid = guiCreateEdit(20, 345, 180, 20, guiCE.cidEx, false, guiCE.win)
		addEventHandler("onClientGUIChanged", guiCE.cid, function()
			local content = guiGetText(guiCE.cid)
			if tonumber(content) then
				triggerServerEvent("onClientDemandCharacterNameFromCID", resourceRoot, tonumber(content))
			else
				guiSetText(guiCE.cidLabel, "Nazwa: brak")
			end
		end)
	guiCE.cidLabel = guiCreateLabel(20, 370, 180, 20, "Nazwa: brak", false, guiCE.win)
	guiCE.close = guiCreateButton(115, 400, 85, 30, "Zamknij", false, guiCE.win)
		addEventHandler("onClientGUIMouseUp", guiCE.close, function()
			guiSetVisible(guiCE.win, false)
			guiSetVisible(gui.win, true)
		end, false, "high")
	guiCE.create = guiCreateButton(20, 400, 85, 30, "Zapisz", false, guiCE.win)
		addEventHandler("onClientGUIMouseUp", guiCE.create, fetchFactionEditionData, false, "high")
	guiCE.grid = guiCreateGridList(240, 30, 440, 400, false, guiCE.win)
		guiGridListSetSortingEnabled(guiCE.grid, false)
		addEventHandler("onClientGUIDoubleClick", guiCE.grid, function()
			local cRow = guiGridListGetSelectedItem( guiCE.grid )
			local r, g, b = guiGridListGetItemColor(guiCE.grid, cRow, 2)
			if r == 0 then
				guiGridListSetItemColor(guiCE.grid, cRow, 2, 255, 0, 0)
			elseif g == 0 then
				guiGridListSetItemColor(guiCE.grid, cRow, 2, 0, 255, 0)
			end
		end)
		guiGridListAddColumn(guiCE.grid, "ID", 0.14)
		guiGridListAddColumn(guiCE.grid, "Nazwa", 0.78)
	for i, icon in ipairs(orgIcons) do
		guiComboBoxAddItem(guiCE.icon, icon.name)
	end
	guiSetVisible(guiCE.win, false)
end


function onAdminEditPickColor(r, g, b)
	hex = RGBToHex(r, g, b)
	guiSetText(guiCE.colorPicker, "Wybierz kolor organizacji\n#"..hex)
end


addEvent("onServerSendLeaderDetails", true)
addEventHandler("onServerSendLeaderDetails", resourceRoot, function(name)
	guiSetText(guiCE.cidLabel, "Nazwa: "..name)
end)

addEvent("onPlayerOpenEditGroupWindow", true)
addEventHandler("onPlayerOpenEditGroupWindow", resourceRoot, showWindow)

addEvent("onPlayerOpenFindGroupWindow", true)
addEventHandler("onPlayerOpenFindGroupWindow", resourceRoot, showWindow)

addEvent("onPlayerOpenCharacterListWindow", true)
addEventHandler("onPlayerOpenCharacterListWindow", resourceRoot, showWindowData)
