local function checkMagazineRights(plr)
	local id = getElementData(plr, "building:last")
	
	if not id then
		outputChatBox("(( Nie jesteś w żadnym budynku! ))", plr)
		return
	end
	
	local oid = getElementData(plr, "organisation:id")
	
	if not oid then
		outputChatBox("(( Nie jesteś na służbie! ))", plr)
		return
	end
	
	if not exports["imta-organisations"]:doesOrganisationHavePermission(oid, 3) then
		triggerClientEvent(plr, "createClientNotification", plr, "Uprawnienia", "Organizacja nie posiada uprawnień do posiadania magazynu!", "error")
		return
	end
	
	local result = exports["imta-db_server"]:getFirstRow("SELECT `building_id`, `building_organisation` FROM imta_buildings WHERE building_id = ?", id)
	if not (result or result.building_id) then
		outputChatBox("(( Błąd - brak budynku w bazie! ))", plr)
		return 
	end
	
	if result.building_organisation then
		if exports["imta-organisations"]:isPlayerInOrganisation(plr, oid) then
			if not exports["imta-organisations"]:doesPlayerHavePermission(plr, 3) then -- uprawnienie do /magazyn
				triggerClientEvent(plr, "createClientNotification", plr, "Uprawnienia", "Nie masz wystarczających uprawnień organizacji!", "error")
				return
			end
		else
			triggerClientEvent(plr, "createClientNotification", plr, "Uprawnienia", "Nie należysz do organizacji, która jest właścicielem tego budynku!", "error")
			return
		end
	else
		triggerClientEvent(plr, "createClientNotification", plr, "Brak organizacji!", "Nie możesz używać magazynu w budynkach nienależących do organizacji!", "error")
	end
	
	return id
end



function getMagazineData(building_id)
	local result = exports["imta-db_server"]:getFirstRow("SELECT `buidling_magazine_content` FROM `imta_buildings` WHERE `building_id` = ?", building_id)
	return exports["imta-eq"]:decompressEQ(result.buidling_magazine_content == "" and "W1tdXQ==" or result.buidling_magazine_content)
end

function setMagazineData(building_id, data)
	exports["imta-db_server"]:query("UPDATE `imta_buildings` SET `buidling_magazine_content` = ? WHERE `building_id` = ?", exports["imta-eq"]:compressEQ(data), building_id)
end

function giveMagazineItem(building_id, item)
	local data = getMagazineData(building_id)
	local itemData = exports["imta-eq"]:getItemData(item.id)
	local hasItem, stackIndex = exports["imta-eq"]:findItem(data, item)
	if hasItem and itemData.isStackable then
		data[stackIndex].count = data[stackIndex].count + item.count
	else
		table.insert(data, item)
		data = exports["imta-eq"]:sortEQTable(data)
	end
	setMagazineData(building_id, data)
end

function takeMagazineItem(building_id, itemToBeTaken, all)
	local data = getMagazineData(building_id)
	local hasItem, stackIndex = exports["imta-eq"]:findItem(data, itemToBeTaken)
	if not hasItem then 
		return false
	end
	local item = data[stackIndex]
	if not all and item.count < itemToBeTaken.count then
		return false
	elseif all or item.count == itemToBeTaken.count then
		table.remove(data, stackIndex)
		setMagazineData(building_id, data)
		return true, item.count
	elseif item.count > itemToBeTaken.count then
		data[stackIndex].count = data[stackIndex].count - itemToBeTaken.count
		setMagazineData(building_id, data)
		return true, data[stackIndex].count
	end
end

function takeAllMagazineItems(building_id)
	local data = getMagazineData(building_id)
	setMagazineData(building_id, {})
	return data
end


function showEQGUI(state, plr)
	local plr = plr or client
	
	exports["imta-controls"]:toggleCustomControl(plr, "fire", not state)
	
	if not state then 
		triggerClientEvent(plr, "onServerDemandShowMagazine", resourceRoot, false)
		exports["imta-eq"]:setPlayerEQVisibility(plr, false) -- wyłącza + zamyka/włącza blokadę otwarcia eq
		return
	end
	
	exports["imta-eq"]:setPlayerEQVisibility(plr, true)
	
	local bid = checkMagazineRights(plr)
	if not bid then
		return 
	end
	
	local data = getMagazineData(bid)

	triggerClientEvent(plr, "onServerDemandShowMagazine", resourceRoot, true, data)
end
addEvent("onPlayerDemandMagazineGUI", true)
addEventHandler("onPlayerDemandMagazineGUI", resourceRoot, showMagazineGUI)



function takeEQSnapshot(state, plr)
	local plr = plr or client
	
	exports["imta-controls"]:toggleCustomControl(plr, "fire", not state)
	
	if not state then 
		triggerClientEvent(plr, "onServerDemandShowMagazine", resourceRoot, false)
		exports["imta-eq"]:setPlayerEQVisibility(plr, false) -- wyłącza + zamyka/włącza blokadę otwarcia eq
		return
	end
	
	exports["imta-eq"]:setPlayerEQVisibility(plr, true)
	
	local bid = checkMagazineRights(plr)
	if not bid then
		return 
	end
	
	local data = getMagazineData(bid)

	triggerClientEvent(plr, "onServerDemandShowMagazine", resourceRoot, true, data)
end
--addEvent("onPlayerDemandMagazineGUI", true)
--addEventHandler("onPlayerDemandMagazineGUI", resourceRoot, showMagazineGUI)


