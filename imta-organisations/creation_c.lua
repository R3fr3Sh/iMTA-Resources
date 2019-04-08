local gui = {}
--Siwy biały dla boxu, czcionki i belek po bokach: 204, 204, 204 #cccccc
-- Góra - tło od zakładek rgb: 18, 18, 17
-- A dół to jednolite czarne 0, 0, 0
-- Tylko to w przezroczystości to wiadomo
--https://cdn.discordapp.com/attachments/399695849552085003/463800907633786880/unknown.png
--limit wynagrodzenia - 5k
--[[
Wynagrodzenia:
gracz1 - 1000$
gracz2 - 500$
gracz3 - 500$
limit - 1000$
obecnapula - 2000$
proporcja - limit/obecnapula = 50%
wypłaty:
gracz1proporcja 
gracz2proporcja 
gracz3*proporcja 
Wypłacone wynagrodzenia: 1000$

--total wages per org per day and max pay daily
--pay multiplier for day per player
SELECT *, (CASE WHEN playtime < 30 THEN 0 WHEN (playtime >= 30 and playtime < 60) THEN 0.5 WHEN playtime < 120 THEN 1 WHEN (playtime >= 120 and playtime < 180) THEN 1.25 ELSE 1.5 END) as 'multiplier' FROM `imta_organisation_member_playtime` WHERE `payment_run` = 0
--this but better
SELECT *, (CASE WHEN playtime < 30 THEN 0 WHEN (playtime >= 30 and playtime < 60) THEN 0.5 WHEN playtime < 120 THEN 1 WHEN (playtime >= 120 and playtime < 180) THEN 1.25 ELSE 1.5 END) as 'multiplier' FROM imta_organisation_member_playtime omp LEFT JOIN imta_organisation_groups og ON og.organisation_id = omp.org_id LEFT JOIN imta_organisation_group_members ogm ON (omp.`char_id` = ogm.`char_id`) AND (og.`organisation_id` = omp.`org_id`) WHERE payment_run = 0

SELECT *, (CASE WHEN playtime < 30 THEN 0 WHEN (playtime >= 30 and playtime < 60) THEN 0.5 WHEN playtime < 120 THEN 1 WHEN (playtime >= 120 and playtime < 180) THEN 1.25 ELSE 1.5 END) as 'multiplier' WHERE payment_run = 0


0.5h = 50%
1h = 100%
2h = 125%
3h = 150% ("brak wartości pośrednich")

Wypłąty o 4 rano, jak się jest w grze to zaczyna się nowy okres rozliczeniowy

]]




local sx, sy = guiGetScreenSize()
local hideWindow, showWindow
local hex = "FFFFFF"

hideWindow = function()
	guiSetVisible(gui.win, false)
	showCursor(false)
end

showWindow = function(permissions, pCategories)
	guiSetVisible(gui.win, true)
	showCursor(true)
	guiGridListClear(gui.grid)
	categoriesIndices = {}
	categories = {}
	for i, cat in ipairs(pCategories) do
		if i == 1 then
			categoriesIndices[i] = cat.category
		else
			categoriesIndices[pCategories[i-1].category] = cat.category
		end
		categories[cat.category] = cat.categoryNamePL
	end
	
	local category = categoriesIndices[1]
	for i, perm in ipairs(permissions) do
		if category == perm.category then
			local row = guiGridListAddRow(gui.grid, "", categories[category])
			guiGridListSetItemText(gui.grid, row, 2, categories[category], true, false)
			category = categoriesIndices[category]
		end
		local row = guiGridListAddRow(gui.grid, perm.id, perm.namePL ~= "" and  perm.namePL or perm.name)
		guiGridListSetItemColor(gui.grid, row, 2, 255, 0, 0)
	end
end

local function fetchFactionCreationData()
	
	local comboIconID = guiComboBoxGetSelected(gui.icon)
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

	local name = guiGetText(gui.name)
	
	local maxPayout = tonumber(guiGetText(gui.pay))
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
	
	local totalMaxPayout = tonumber(guiGetText(gui.totalPay))
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
	
	local maxMembers = tonumber(guiGetText(gui.member))
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
	
	local leaderName = guiGetText(gui.cidLabel)
	local cid = tonumber(guiGetText(gui.cid))
	if leaderName == "Nazwa: brak" then
		exports["imta-interface"]:createNotification("Niepoprawne id postaci", "Postać o takim ID nie istnieje!", "stop", 5000, 1, 255, 204, 0)
	elseif not cid or cid < 0 then
		exports["imta-interface"]:createNotification("Niepoprawne id postaci", "ID postaci musi być liczbą naturalną!", "stop", 5000, 1, 255, 204, 0)
	end
	
	local permissonList = {}
	for i = 0, guiGridListGetRowCount(gui.grid) - 1 do
		local r, g, b = guiGridListGetItemColor(gui.grid, i, 2)
		if g == 255 and r == 0 then
			local pIndex = tonumber(guiGridListGetItemText(gui.grid, i, 1))
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
	}
	triggerServerEvent("onClientDemandOrganisationCreation", resourceRoot, data)
end

do
	gui.win = guiCreateWindow(sx/2 - 350, sy/2 - 225, 700, 450, "Kreacje organizacji", false)
	gui.icon = guiCreateComboBox(20, 30, 180, 200, "Ikona organizacji", false, gui.win)
	gui.colorPicker = guiCreateButton(20, 70, 180, 40, "Wybierz kolor organizacji\n#FFFFFF", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.colorPicker, function() 
			colorPicker.create(1, "#"..hex, "Kolor organizacji") 
		end, false, "high")
	guiCreateLabel(20, 125, 180, 20, "Nazwa organizacji:", false, gui.win)
	gui.nameEx =  "Maksimum 32 znaki"
	gui.name = guiCreateEdit(20, 145, 180, 20, gui.nameEx, false, gui.win)
		guiEditSetMaxLength(gui.name, 32)
	guiCreateLabel(20, 175, 180, 20, "Górny limit wypłaty (na godzinę):", false, gui.win)
	gui.payEx = "Maksimum 5000$"
	gui.pay = guiCreateEdit(20, 195, 180, 20, gui.payEx, false, gui.win)
	guiCreateLabel(20, 225, 180, 20, "Dzienna pula wynagrodzeń:", false, gui.win)
	gui.totalPayEx = "Maksimum 1.000.000$"
	gui.totalPay = guiCreateEdit(20, 245, 180, 20, gui.totalPayEx, false, gui.win)
	guiCreateLabel(20, 275, 180, 20, "Limit członków (0 = brak limitu):", false, gui.win)
	gui.memberEx = "0"
	gui.member = guiCreateEdit(20, 295, 180, 20, gui.memberEx, false, gui.win)
	guiCreateLabel(20, 325, 180, 20, "CID przyszłego lidera:", false, gui.win)
	gui.cidEx = "ID postaci"
	gui.cid = guiCreateEdit(20, 345, 180, 20, gui.cidEx, false, gui.win)
		addEventHandler("onClientGUIChanged", gui.cid, function()
			local content = guiGetText(gui.cid)
			if tonumber(content) then
				triggerServerEvent("onClientDemandCharacterNameFromCID", resourceRoot, tonumber(content))
			else
				guiSetText(gui.cidLabel, "Nazwa: brak")
			end
		end)
	gui.cidLabel = guiCreateLabel(20, 370, 180, 20, "Nazwa: brak", false, gui.win)
	gui.close = guiCreateButton(115, 400, 85, 30, "Zamknij", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.close, hideWindow, false, "high")
	gui.create = guiCreateButton(20, 400, 85, 30, "Utwórz", false, gui.win)
		addEventHandler("onClientGUIMouseUp", gui.create, fetchFactionCreationData, false, "high")
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
	for i, icon in ipairs(orgIcons) do
		guiComboBoxAddItem(gui.icon, icon.name)
	end
	guiSetVisible(gui.win, false)
end
addEvent("onPlayerOpenCreateGroupWindow", true)
addEventHandler("onPlayerOpenCreateGroupWindow", resourceRoot, showWindow)

addEvent("onServerSendLeaderDetails", true)
addEventHandler("onServerSendLeaderDetails", resourceRoot, function(name)
	guiSetText(gui.cidLabel, "Nazwa: "..name)
end)

addEvent("onServerFinalizeOrganisationCreation", true)
addEventHandler("onServerFinalizeOrganisationCreation", resourceRoot, function()
	guiSetVisible(gui.win, false)
	showCursor(false)
	guiSetText(gui.totalPay, gui.totalPayEx)
	guiSetText(gui.name, gui.nameEx)
	guiSetText(gui.pay, gui.payEx)
	guiSetText(gui.member, gui.memberEx)
	guiSetText(gui.cid, gui.cidEx)
end)

function onAdminPickColor(r, g, b)
	hex = RGBToHex(r, g, b)
	guiSetText(gui.colorPicker, "Wybierz kolor organizacji\n#"..hex)
end