--TODO:
--1. check if admin has proper rank to use commands and stuff
--3. IF SOMEONE GETS HIGHER RANK HE INHERITS TODAYS PLAYTIME
--remember to UPDATE permission id after change in position
local permissions

function isCommunityManager(plr)
    local isAdmin = exports["imta-admin"]:getPlayerMaxRank(plr)
    if type(isAdmin) ~= "table" then
        return 0
    end
    if isAdmin[2] == 3 then -- admin w górę zawsze
        return 3
    end
    if isAdmin[2] and isAdmin[2] == 2 then -- CM w zależności
        return isAdmin[1]
    end
    return 0
end

function isAdmin(plr)
    local isAdmin = exports["imta-admin"]:getPlayerMaxRank(plr)
    if type(isAdmin) ~= "table" then
        return false
    end
    if isAdmin[2] == 3 and isAdmin[1] > 1 then -- admin2 w górę zawsze
        return true
    end
    return false
end


addCommandHandler("utworzgrupa", function(plr) 
	if isCommunityManager(plr) < 1 then
		return 
	end
	if not getElementData(plr, "character:id") then 
		return
	end
	permissions = exports["imta-db_server"]:getRows("SELECT id, name, namePL, op.category FROM `imta_organisation_permissions` op JOIN `imta_organisation_permisson_categories` opc ON op.category = opc.category ORDER BY `opc`.`rank` ASC, `op`.`id` ASC")
	local pCategories = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
	triggerClientEvent(plr, "onPlayerOpenCreateGroupWindow", resourceRoot, permissions, pCategories)
end)

function findGroupWindow(plr) 
	if isCommunityManager(plr) < 1 then
		return 
	end
	if not getElementData(plr, "character:id") then 
		return
	end
	local organisations = exports["imta-db_server"]:getRows("SELECT id, name FROM `imta_organisation`")
	triggerClientEvent(plr, "onPlayerOpenFindGroupWindow", resourceRoot, organisations)
end
addCommandHandler("agrupy", findGroupWindow)
addEvent("onPlayerDemandFindGroupWindow", true)
addEventHandler("onPlayerDemandFindGroupWindow", resourceRoot, findGroupWindow)


addEvent("onClientDemandOrganisationCharacterList", true)
addEventHandler("onClientDemandOrganisationCharacterList", resourceRoot, function(cid)
	local result = exports["imta-db_server"]:getRows("SELECT DATE_FORMAT(ogm.`join_time`, '%d.%m.%Y') AS 'join_time', CONCAT(c.`char_first_name`, ' ', c.`char_last_name`) as 'char_name', og.name as 'group_name' FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` JOIN `imta_characters` c ON ogm.`char_id` = c.`char_id` WHERE og.`organisation_id` = ? ORDER BY `char_name` ASC", cid)
	triggerClientEvent(client, "onPlayerOpenCharacterListWindow", resourceRoot, result)
end)


addEvent("onClientDemandCharacterNameFromCID", true)
addEventHandler("onClientDemandCharacterNameFromCID", resourceRoot, function(cid)
	local result = exports["imta-db_server"]:getFirstRow("SELECT char_first_name as name, char_last_name as surname FROM imta_characters WHERE char_id = ?", cid)
	if result and result.name then
		triggerClientEvent(client, "onServerSendLeaderDetails", resourceRoot, result.name.." "..result.surname)
	else
		triggerClientEvent(client, "onServerSendLeaderDetails", resourceRoot, "brak")
	end
end)


function transferMoneyToOrganisation(organisation_id, amount)
	exports["imta-db_server"]:query("UPDATE `imta_organisation` SET `money`= `money` + ? WHERE id = ?", organisation_id, amount)
end

addEvent("onClientDemandOrganisationCreation", true)
addEventHandler("onClientDemandOrganisationCreation", resourceRoot, function(data)
	if isCommunityManager(client) < 1 then
		return 
	end
	--check if faction with that name exists and block it otherwise
	local oldName = exports["imta-db_server"]:getFirstRow("SELECT name FROM imta_organisation WHERE name = ?", data.name)
	if oldName and oldName.name and oldName.name == data.name then
		triggerClientEvent(client, "createClientNotification", root, "Organizacja istnieje", "Nazwa organizacji którą podałeś jest już w użytku!", "stop", 5000, 0.75, 255, 204, 0)
		return
	end
	--check if potential leader has slot for faction
	if not hasPlayerOrganisationSlot(data.cid, client) then
		return
	end
	--create organisation
	local success = exports["imta-db_server"]:query("INSERT INTO `imta_organisation`(`name`, `icon_id`, `max_pay`, `max_pay_daily`, `member_limit`, `leader_id`, `color`, `leader_note`) VALUES (?, ?, ?, ?, ?, ?, ?, '')", data.name, data.iconID, data.maxPayout, data.totalMaxPayout, data.maxMembers, data.cid, data.color)
	if not success then
		triggerClientEvent(client, "createClientNotification", root, "Błąd bazy", "Wystąpił błąd bazy! #x02", "stop", 5000, 0.75, 255, 204, 0)
		return
	end

	local org = exports["imta-db_server"]:getFirstRow("SELECT max(id) as lastInsert FROM `imta_organisation`")
	do
		--create groups within faction
		local queryPart = ""
		for i = 1, 8 do
			queryPart = queryPart.."("..tostring(org.lastInsert)..", "..i..")"..(i~= 8 and "," or "")			
		end
		exports["imta-db_server"]:query(("INSERT INTO `imta_organisation_groups`(`organisation_id`, `internal_id`) VALUES "..queryPart));
		exports["imta-db_server"]:query("INSERT INTO `imta_organisation_groups`(`organisation_id`, `internal_id`, `payout`, `name`) VALUES (?, ?, ?, ?)", org.lastInsert, 9, data.maxPayout, "Lider")
		addPlayerToOrganisation(data.cid, org.lastInsert, 9)
	end
	do
		--create permissions
		local queryPart = ""
		for i, permID in ipairs(data.pList) do
			queryPart = queryPart.."("..org.lastInsert..", "..permID..", 'faction')"..(i~= #data.pList and "," or "")
		end
		exports["imta-db_server"]:query("INSERT INTO `imta_organisation_permission_list`(`id`, `permission_id`, `type`) VALUES "..queryPart);
	end
	triggerClientEvent("onServerFinalizeOrganisationCreation", resourceRoot)
	triggerClientEvent(client, "createClientNotification", root, "Organizacja stworzona", "Organizacja o nazwie "..data.name.." została utworzona pomyślnie.", "tick", nil, nil, 85, 204, 0)
end)

function sendOrganisationEditData(orgID, client)
	if isCommunityManager(client) < 1 then
		return 
	end
	local result = exports["imta-db_server"]:getFirstRow("SELECT * FROM `imta_organisation` WHERE id = ?", orgID)
	local permissionList = exports["imta-db_server"]:getRows("SELECT op.`id`, opl.`id` as 'is_used', op.`namePL`, op.`category` FROM `imta_organisation_permissions` op JOIN `imta_organisation_permisson_categories` opc ON op.`category` = opc.`category` LEFT OUTER JOIN `imta_organisation_permission_list` opl ON opl.`id` = ? AND opl.`type` = 'faction' AND op.`id` = opl.`permission_id` ORDER BY `opc`.`rank` ASC, `op`.`id` ASC", orgID)
	local permissionCategories = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
	if not result then
		triggerClientEvent(client, "createClientNotification", root, "Wystąpił błąd!", "Nie udało się pobrać danych tej organizacji. Spróbuj ponownie za chwilę.", "stop", nil, nil, 255, 204, 0)
		return 
	end
	triggerClientEvent(client, "onServerReturnOrganisationEditData", resourceRoot, result, permissionList, permissionCategories, orgID)
end

addEvent("onClientDemandOrganisationEdition", true)
addEventHandler("onClientDemandOrganisationEdition", resourceRoot, function(data)
	if isCommunityManager(client) < 1 then
		return 
	end
	
	local cOrgData = exports["imta-db_server"]:getFirstRow("SELECT * FROM `imta_organisation` WHERE id = ?", data.oid)

	--check if faction with that name exists and block it otherwise - ignore if the name hasn't changed at all
	local oldName = exports["imta-db_server"]:getFirstRow("SELECT name FROM imta_organisation WHERE name = ?", data.name)
	if oldName and oldName.name and oldName.name == data.name and not(cOrgData.name ~= oldName) then
		triggerClientEvent(client, "createClientNotification", root, "Organizacja istnieje", "Nazwa organizacji którą podałeś jest już w użytku!", "stop", 5000, 0.75, 255, 204, 0)
		return
	end
	--check if potential leader has slot for faction or ignore that point if the current leader is not changed
	
	local gid = getPlayerGroupByPlayerID(data.cid, data.oid)
	outputDebugString(gid)
	if cOrgData.leader_id ~= data.cid and not hasPlayerOrganisationSlot(data.cid, client, gid and 1 or 0) then
		return
	end

	local success = exports["imta-db_server"]:query("UPDATE `imta_organisation` SET `name` = ?, `icon_id` = ?, `max_pay` = ?, `max_pay_daily` = ?, `member_limit` = ?, `leader_id` = ?, `color`= ? WHERE `id` = ?", data.name, data.iconID, data.maxPayout, data.totalMaxPayout, data.maxMembers, data.cid, data.color, data.oid)

	if not success then
		triggerClientEvent(client, "createClientNotification", root, "Błąd bazy", "Wystąpił błąd bazy! #x03", "stop", 5000, 0.75, 255, 204, 0)
		return
	end
		if gid then 
			local newGroup = exports["imta-db_server"]:getFirstRow("SELECT `id` FROM `imta_organisation_groups` WHERE `organisation_id` = ? AND `internal_id` = ?", data.oid, 9)
			exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` SET `group_id` = ? WHERE `char_id` = ? AND `group_id` = ?", newGroup.id, data.cid, gid)
		else 
			addPlayerToOrganisation(data.cid, data.oid, 9)
		end
	for i, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "character:id") == data.cid then 
			triggerClientEvent(player, "createClientNotification", root, "Nowe stanowisko", "Od dzisiaj jesteś liderem organizacji \""..data.name.."\". Gratulacje!", "tick", nil, nil, 85, 204, 0)
		end
	end


	triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "EDYCJA ORGANIZACJI CID: "..getElementData(client, "character:id").." OID: "..data.oid.." LISTA: "..toJSON(data))
	if #data.pList == 0 then 
		--it's empty so we delete all of the rows related to the group
		exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'faction'", data.oid)
	else
		--it's not empty so we use standard procedure
		local filteredOrganisationListStringToDelete = table.concat(data.pList, ",")
		exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'faction' AND permission_id NOT IN ("..filteredOrganisationListStringToDelete..")", data.oid)
		local filteredOrganisationListStringToInsert = "("..data.oid..", "..table.concat(data.pList, ", 'faction'), ("..data.oid..", ")..", 'faction')"
		exports["imta-db_server"]:query("INSERT IGNORE INTO `imta_organisation_permission_list` (`id`, `permission_id`, `type`) VALUES "..filteredOrganisationListStringToInsert)
	end
	
	triggerClientEvent(client, "createClientNotification", root, "Organizacja zmieniona", "Organizacja o nazwie "..data.name.." została zmieniona pomyślnie.", "tick", nil, nil, 85, 204, 0)
	findGroupWindow(client)
end)

addEvent("onClientDemandTransferOfMoney", true)
addEventHandler("onClientDemandTransferOfMoney", resourceRoot, function(orgID, amount)
	if isCommunityManager(client) < 1 then
		return 
	end

	amount = math.floor(amount)
	if exports["imta-base"]:takeClientMoney(client, amount) then
		local rv = exports["imta-db_server"]:query("UPDATE `imta_organisation` SET `money` = `money` + ? WHERE id = ?", amount, orgID)
		if rv then
			triggerClientEvent(client, "createClientNotification", root, "Operacja udana!", "Przelanie środków na konto organizacji zakończyło się powodzeniem. Przelana kwota "..amount.."$.", "tick", nil, nil, 85, 204, 0)
		else 
			triggerClientEvent(client, "createClientNotification", root, "Wystąpił błąd!", "Przelanie środków na konto organizacji zakończyło się niepowodzeniem z powodu błędu bazy danych.", "stop", nil, nil, 255, 204, 0)
		end
	else
		triggerClientEvent(client, "createClientNotification", root, "Brak środków!", "Przelanie środków na konto organizacji zakończyło się niepowodzeniem z powodu niewystarczających środków.", "stop", nil, nil, 255, 204, 0)
	end
end)


addEvent("onClientDemandOrganisationEditData", true)
addEventHandler("onClientDemandOrganisationEditData", resourceRoot, function(orgID) sendOrganisationEditData(orgID, client) end)




addEvent("onClientDemandJoinOrganisation", true)
addEventHandler("onClientDemandJoinOrganisation", resourceRoot, function(orgID, amount)
	if isCommunityManager(client) < 1 then
		return 
	end

	local cid = getElementData(client, "character:id")
	if not hasPlayerOrganisationSlot(cid, client) then
		triggerClientEvent(client, "createClientNotification", root, "Operacja nieudana!", "Nie posiadasz żadnego wolnego miejsca na organizację!", "stop", nil, nil, 255, 204, 0)
		return
	else
		if addPlayerToOrganisation(cid, orgID, 9) then
			triggerClientEvent(client, "createClientNotification", root, "Operacja udana!", "Pomyślnie dołączyłeś do frakcji.", "tick", nil, nil, 85, 204, 0)
		else 
			triggerClientEvent(client, "createClientNotification", root, "Operacja nieudana!", "Nie udało Ci się dołączyć do frakcji (być może już jesteś członkiem)", "stop", nil, nil, 255, 204, 0)
		end
	end
end)

function playerDemandItsOrganisationList(client, turnOff)
	local cid = tonumber(getElementData(client, "character:id"))
	if turnOff then
		triggerClientEvent(client, "onPlayerDemandItsOrganisationListResponse", resourceRoot, {}, true)
		return
	end
	if cid then
		local result = exports["imta-db_server"]:getRows("SELECT ogm.`char_id`, og.`organisation_id` AS 'org_id', (SELECT playtime FROM `imta_organisation_member_playtime` omp WHERE omp.`start_time` = CURDATE() AND omp.`char_id` = ogm.`char_id` AND omp.`org_id` = og.`organisation_id`) AS 'playtime', (SELECT name FROM `imta_organisation` o WHERE o.id = org_id) AS 'name' FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE ogm.`char_id` = ? ORDER BY `org_id` ASC LIMIT 3" , cid)
		triggerClientEvent(client, "onPlayerDemandItsOrganisationListResponse", resourceRoot, result)
	else
		triggerClientEvent(client, "createClientNotification", root, "Operacja nieudana!", "Nie można załadować organizacji dla gracza który nie posiada id postaci.", "stop", nil, nil, 255, 204, 0)
	end
end

addCommandHandler("organisationList", function(plr)
	if not getElementData(plr, "character:id") then 
		return
	end
	playerDemandItsOrganisationList(plr)
end)

addEvent("onPlayerDemandOrganisationPanel", true)
addEventHandler("onPlayerDemandOrganisationPanel", resourceRoot, function(oid, i, dataObj, data)
	local client = isElement(dataObj) and dataObj or client
	local cid = tonumber(getElementData(client, "character:id"))
	oid = tonumber(oid)
	if not oid or not cid  or not i then 
		return
	end	
	local returnData
	local additionalData
	if i == 1 then
		local gid = exports["imta-db_server"]:getFirstRow("SELECT og.`id` as gid FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE ogm.`char_id` = ? AND og.`organisation_id` = ?", cid, oid)
		if not gid or not tonumber(gid.gid) then
			return
		else
			gid = gid.gid
		end
		returnData = exports["imta-db_server"]:getFirstRow("SELECT o.`name`, o.`leader_note`, c.`char_first_name`, c.`char_last_name`, o.`icon_id`, o.`color`, o.`id`,(SELECT COUNT(*) FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE og.`organisation_id` = o.`id`) AS 'member_count', (SELECT COUNT(*) FROM `imta_vehicles` v WHERE v.`veh_owning_organisation` = o.`id`) AS 'vehicle_count', IFNULL((SELECT `skin_id` FROM `imta_organisation_group_members` ogm2 WHERE ogm2.`char_id` = ? and ogm2.`group_id` = ?), IFNULL((SELECT skin_id FROM `imta_organisation_groups` og2 WHERE og2.`id` = ?), 'brak' )) AS 'skin_id', IF( (SELECT `payout` FROM `imta_organisation_group_members` WHERE `char_id` = ? and `group_id` = ?) = -1, (SELECT `payout` FROM `imta_organisation_groups` WHERE `id` = ?), (SELECT `payout` FROM `imta_organisation_group_members` WHERE `char_id` = ? and `group_id` = ?)) as 'payout' FROM `imta_organisation` o JOIN `imta_characters` c ON c.`char_id` = o.`leader_id` WHERE o.`id` = ?", cid, gid, gid, cid, gid, gid, cid, gid, oid)
		returnData.currentOrganisationID = getElementData(client, "organisation:id")
	elseif  i == 2 then
		local result = exports["imta-db_server"]:getRows("SELECT ogm.`char_id` FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` JOIN `imta_current_online` co ON ogm.`char_id` = co.`char_id` WHERE og.`organisation_id` = ?", oid)
		local players = getElementsByType("player")
		local playersByID = {}
		for i, player in ipairs(players) do
			playersByID[getElementData(player, "character:id")] = player
		end
		returnData = {}
		for i, d in ipairs(result) do
			if playersByID[d.char_id] then
				local player = playersByID[d.char_id] 
				if isElement(player) then
					table.insert(returnData, {
					id = string.gsub(getElementID(player), "p.", ""),
					name = getPlayerName(player),
					onDuty = (getElementData(player, "organisation:id") == oid),
					})
				end
			end
		end
		-- returnData = testData
	elseif i == 3 then
		returnData = exports["imta-db_server"]:getRows("SELECT veh_id, veh_model, veh_special FROM `imta_vehicles` WHERE veh_owning_organisation = ? ORDER BY `imta_vehicles`.`veh_special` ASC, `imta_vehicles`.`veh_id` ASC", oid)

	elseif i == 4 then 
		local rank = isPlayerInOrganisation(client, oid)
		if rank ~= 9 then 
			triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Nie posiadasz wystarczających uprawnień, aby móc zarządzać tą organizacją!", "stop", nil, nil, 255, 204, 0)
			return
		end 
	elseif i == 7 then 
		returnData = exports["imta-db_server"]:getFirstRow("SELECT o.`id`, o.`name`, o.`member_limit`, o.`money`, o.`color`, CONCAT(c.`char_first_name`, ' ', c.`char_last_name`) AS 'leader_name', (SELECT COUNT(*) FROM `imta_buildings` WHERE `building_organisation` = o.`id`) AS 'building_count', (SELECT COUNT(*) FROM `imta_vehicles` WHERE `veh_owning_organisation` = o.`id`) AS 'vehicle_count', (SELECT COUNT(*) FROM `imta_organisation_groups` og JOIN `imta_organisation_group_members` ogm ON og.`id` = ogm.`group_id` WHERE `organisation_id` = o.`id`) as 'member_count' FROM `imta_organisation` o JOIN `imta_characters` c ON o.`leader_id` = c.`char_id` WHERE o.`id` = ?", oid)
	elseif i == 8 then
		returnData = exports["imta-db_server"]:getRows("SELECT ogm.`char_id`, CONCAT(c.`char_first_name`, ' ', c.`char_last_name`) as 'char_name', og.`name` as 'group_name', omp.`playtime`, WEEKDAY(omp.`start_time`) + 3 as 'column_index' FROM `imta_organisation_groups` og JOIN `imta_organisation_group_members` ogm ON og.`id` = ogm.`group_id` JOIN `imta_organisation_member_playtime` omp ON (omp.`char_id` = ogm.`char_id`) AND (og.`organisation_id` = omp.`org_id`) JOIN `imta_characters` c ON ogm.`char_id` = c.`char_id` WHERE og.`organisation_id` = ? AND DATE_ADD(omp.`start_time`, INTERVAL 7 DAY) > NOW() ORDER BY `ogm`.`char_id` ASC, `column_index` ASC", oid)
	elseif i == 9 then 
		returnData = exports["imta-db_server"]:getRows("SELECT ogm.`char_id`, ogm.`group_id`, ogm.`use_individual_rights`, COALESCE(ogm.`skin_id`, 'Z grupy') AS 'skin_id', ogm.`payout`, DATE_FORMAT(ogm.`join_time`, '%d.%m.%Y') AS 'join_time', CONCAT(c.`char_first_name`, ' ', c.`char_last_name`) as 'char_name', og.name as 'group_name', (SELECT max_pay FROM `imta_organisation` o WHERE o.`id` = og.organisation_id) AS 'max_pay' FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` JOIN `imta_characters` c ON ogm.`char_id` = c.`char_id` WHERE og.`organisation_id` = ? ORDER BY `char_name` ASC", oid)
	elseif i == 10 then
		returnData = exports["imta-db_server"]:getRows("SELECT internal_id, name, COALESCE(skin_id, 'brak') AS 'skin_id', payout, (SELECT max_pay FROM `imta_organisation` o WHERE o.`id` = organisation_id) AS 'max_pay' FROM `imta_organisation_groups` WHERE organisation_id = ? ORDER BY `internal_id` ASC", oid)
	elseif i == 11 then
		returnData = exports["imta-db_server"]:getRows("SELECT ogm.`char_id`, ogm.`group_id`, ogm.`use_individual_rights`, DATE_FORMAT(ogm.`join_time`, '%d.%m.%Y') AS 'join_time', CONCAT(c.`char_first_name`, ' ', c.`char_last_name`) as 'char_name', og.name as 'group_name' FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` JOIN `imta_characters` c ON ogm.`char_id` = c.`char_id` WHERE og.`organisation_id` = ? ORDER BY `char_name` ASC", oid)
		additionalData = exports["imta-db_server"]:getRows("SELECT `internal_id`, `name` FROM `imta_organisation_groups` WHERE `organisation_id` = ? ORDER BY `imta_organisation_groups`.`internal_id` ASC", oid)
	elseif i == 12 then
		returnData = exports["imta-db_server"]:getRows("SELECT opl.`permission_id`, og.`category`, opl.`margin`, og.`namePL`, opl.`id` FROM `imta_organisation_permission_list` opl JOIN `imta_organisation_permissions` og ON opl.`permission_id` = `og`.id WHERE opl.`id` = ? and opl.`type` = 'faction' AND og.`is_economic` = 1", oid)
		local forAdditionalData = {}
		local forAdditionalDataReversed = {}
		if #returnData > 0 then
			for j, row in ipairs(returnData) do
				forAdditionalData[row.category] = true 
			end
			for j, v in pairs(forAdditionalData) do
				table.insert(forAdditionalDataReversed, j)
			end
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` WHERE `category` IN ('"..table.concat(forAdditionalDataReversed, "', '").."') ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		else
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		end
	elseif i == 13 then 
		returnData = exports["imta-db_server"]:getRows("SELECT veh_id, veh_model, veh_special FROM `imta_vehicles` WHERE veh_owning_organisation = ? ORDER BY `imta_vehicles`.`veh_special` ASC, `imta_vehicles`.`veh_id` ASC", oid)
	elseif i == 14 then 
		returnData = exports["imta-db_server"]:getRows("SELECT int_id, int_name, int_type FROM `imta_interiors` i join `imta_buildings` b ON i.int_id = b.building_id WHERE b.building_organisation = ? ORDER BY `i`.`int_type` ASC, `i`.`int_id` ASC", oid)
	elseif i == 17 then
		if isElement(dataObj) then
			dataObj = data
		end
		local trueGid = exports["imta-db_server"]:getFirstRow("SELECT `id` FROM `imta_organisation_groups` WHERE `organisation_id` = ? AND `internal_id` = ?", oid, dataObj.gid)
		if not trueGid or not trueGid.id then
			triggerClientEvent(client, "createClientNotification", client, "Operacja nieudana!", "Wystąpił błąd. Spróbuj ponownie później. Kod błędu: 0x0002", "stop", nil, nil, 255, 204, 0)
		end
		trueGid = trueGid.id
		returnData = exports["imta-db_server"]:getRows("SELECT opl.`permission_id`, opl2.`id`, op.`namePL`, op.`category` FROM `imta_organisation_permission_list` opl LEFT OUTER JOIN `imta_organisation_permission_list` opl2 ON opl2.`id` = ? AND opl.`permission_id` = opl2.`permission_id` AND opl2.`type` = 'group' JOIN `imta_organisation_permissions` op ON opl.`permission_id` = op.`id` JOIN `imta_organisation_permisson_categories` opc ON op.`category` = opc.`category` WHERE opl.`id` = ? AND opl.`type` = 'faction' ORDER BY `opc`.`rank` ASC, `op`.`id` ASC", trueGid, oid)
		local forAdditionalData = {}
		local forAdditionalDataReversed = {}
		if #returnData > 0 then
			for j, row in ipairs(returnData) do
				forAdditionalData[row.category] = true 
			end 
			for j, v in pairs(forAdditionalData) do
				table.insert(forAdditionalDataReversed, j)
			end
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` WHERE `category` IN ('"..table.concat(forAdditionalDataReversed, "', '").."') ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		else
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		end
		additionalData.gid = dataObj.gid
		additionalData.name = dataObj.name
	elseif i == 18 then
		if isElement(dataObj) then
			dataObj = data
		end
		local wid = createPlayerWorkID(dataObj.gid, dataObj.cid)
		returnData = exports["imta-db_server"]:getRows("SELECT opl.`permission_id`, opl2.`id`, op.`namePL`, op.`category` FROM `imta_organisation_permission_list` opl LEFT OUTER JOIN `imta_organisation_permission_list` opl2 ON opl2.`id` = ? AND opl.`permission_id` = opl2.`permission_id` AND opl2.`type` = 'player' JOIN `imta_organisation_permissions` op ON opl.`permission_id` = op.`id` JOIN `imta_organisation_permisson_categories` opc ON op.`category` = opc.`category` WHERE opl.`id` = ? AND opl.`type` = 'faction' ORDER BY `opc`.`rank` ASC, `op`.`id` ASC", wid, oid)
		local forAdditionalData = {}
		local forAdditionalDataReversed = {}
		if #returnData > 0 then
			for j, row in ipairs(returnData) do
				forAdditionalData[row.category] = true 
			end
			for j, v in pairs(forAdditionalData) do
				table.insert(forAdditionalDataReversed, j)
			end
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` WHERE `category` IN ('"..table.concat(forAdditionalDataReversed, "', '").."') ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		else
			additionalData = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permisson_categories` ORDER BY `imta_organisation_permisson_categories`.`rank` ASC")
		end
		additionalData.cid = dataObj.cid
		additionalData.gid = dataObj.gid
		additionalData.name = dataObj.name
		
		--local gid, cid = retrieveCharacterWorkDataFromID(wid)
	end
	triggerClientEvent(client, "onPlayerDemandOrganisationPanelResponse", resourceRoot, i, returnData, oid, additionalData)
end)


local function isStringProperName(str)
	str = string.match(str, "[^qwertyuiopasdfghjklzxcvbnmęóąśłżźńć QWERTYUIOPASDFGHJKLZXCVBNMĘĆÓĄŚŁŻŹŃ]+") 
	if str then 
		return false
	end
	return true
end

addEvent("onPlayerEditOrganisationPanel", true)
addEventHandler("onPlayerEditOrganisationPanel", resourceRoot, function(oid, i, data)
	local cid = tonumber(getElementData(client, "character:id"))
	oid = tonumber(oid)
	if not oid or not cid  or not i then 
		return
	end
	--Check permmissions for editing organisation - only rank 9 has access for now
	local rank = isPlayerInOrganisation(client, oid)
	if rank ~= 9 then 
		triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Nie posiadasz wystarczających uprawnień, aby móc zarządzać tą organizacją!", "stop", nil, nil, 255, 204, 0)
		return
	end 
	
	if i == 9 then
		if not data.gid or not tonumber(data.gid) or not data.cid or not tonumber(data.cid) then
			return
		end
		if data.rType == "skin" then
			local skin = tonumber(data.var)
			if not skin then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wybierz ID skina z listy!", "stop", nil, nil, 255, 204, 0)
				return
			end
			skin = math.floor(tonumber(skin))
			if not exports["imta-base"]:isOrganisationSkinAllowed(skin) and skin ~= -1 then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wybrany skin nie jest poprawny! Błąd: 0x0004. Spróbuj ponownie za minutę.", "stop", nil, nil, 255, 204, 0)
				return
			end
			if data.gid % 9 == 0 and data.cid ~= cid and isPlayerOrganisationLeaderByID(data.cid, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Tylko główny lider jest w stanie zmienić swój skin!", "stop", nil, nil, 255, 204, 0)
				return
			end

			local r = exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` ogm SET ogm.`skin_id` = "..(skin == -1 and "NULL" or skin).." WHERE ogm.`char_id` = ? AND ogm.`group_id` = ?", data.cid, data.gid)
			if r ~= 0 then
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRACZ SKIN ZMIANA CID ZMIENIAJĄCY: "..cid.." CID ZMIENIANY: "..data.cid.." GID: "..data.gid.." SKIN: "..skin)
				triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "ID skina gracza został pomyślnie zmieniony." , "tick", nil, nil, 85, 204, 0)
			end

		elseif data.rType == "payout" then
			local payout = tonumber(data.var)
			if not payout or math.floor(payout) < -1 then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wysokość wynagrodzenia musi być cyfrą oraz nie może być mniejsza od 0!", "stop", nil, nil, 255, 204, 0)
				return
			end
			
			if data.gid % 9 == 0 and data.cid ~= cid and isPlayerOrganisationLeaderByID(data.cid, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Tylko główny lider jest w stanie zmienić swoje wynagrodzenie!", "stop", nil, nil, 255, 204, 0)
				return
			end
			
			payout = math.floor(payout)
			local r = exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` ogm SET ogm.`payout` = ? WHERE ogm.`char_id` = ? AND ogm.`group_id` = ?", payout, data.cid, data.gid)
			if r ~= 0 then
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRACZ WYNAGRODZENIE ZMIANA CID ZMIENIAJĄCY: "..cid.." CID ZMIENIANY: "..data.cid.." GID: "..data.gid.." WYNAGRODZENIE: "..payout)
				triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Wysokość wynagrodzenia gracza zostały pomyślnie zmieniona." , "tick", nil, nil, 85, 204, 0)
			end

		elseif data.rType == "turnOn" then
			if isPlayerOrganisationLeaderByID(data.cid, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Akcja ta jest niemożliwa do wykonania na głównym liderze organizacji!", "stop", nil, nil, 255, 204, 0)
				return
			end

			local r =exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` ogm SET ogm.`use_individual_rights` = 1 WHERE ogm.`char_id` = ? AND ogm.`group_id` = ?", data.cid, data.gid)
			if r ~= 0 then
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRACZ UPRAWNIENIA INDYWIDUALNE ZMIANA CID ZMIENIAJĄCY: "..cid.." CID ZMIENIANY: "..data.cid.." GID: "..data.gid.." UPRAWNIENIA INDYWIDUALNE WŁĄCZONE")
				triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Uprawnienia indywidualne gracza zostały pomyślnie włączone." , "tick", nil, nil, 85, 204, 0)
			end
		elseif data.rType == "turnOff" then
			if isPlayerOrganisationLeaderByID(data.cid, oid) then
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Akcja ta jest niemożliwa do wykonania na głównym liderze organizacji!", "stop", nil, nil, 255, 204, 0)
				return
			end
			
			local wid = createPlayerWorkID(data.gid, data.cid)
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE `id` = ? AND `type` = 'player'", wid)
			local r = exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` ogm SET ogm.`use_individual_rights` = 0 WHERE ogm.`char_id` = ? AND ogm.`group_id` = ?", data.cid, data.gid)
			if r ~= 0 then
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRACZ UPRAWNIENIA INDYWIDUALNE ZMIANA CID ZMIENIAJĄCY: "..cid.." CID ZMIENIANY: "..data.cid.." GID: "..data.gid.." UPRAWNIENIA INDYWIDUALNE WYŁĄCZONE")
				triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Uprawnienia indywidualne gracza "..data.name.." zostały pomyślnie usunięte. Od teraz gracz będzie dziedziczyć uprawnienia swojej grupy" , "tick", nil, nil, 85, 204, 0)
			end
		end
		triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client)
		
	elseif i == 10 then 
		if not data.gid or not tonumber(data.gid) then
			return
		end
		if data.rType == "name" then
			local name = data.var
			if not name or string.len(name) > 32 or name == "" then 
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Nazwa grupy musi być krótsza niż 32 znaki oraz nie być pusta.", "stop", nil, nil, 255, 204, 0)
				return
			elseif not isStringProperName(name) then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Nazwa grupy może zawierać tylko wielkie/małe polskie litery oraz spacje!", "stop", nil, nil, 255, 204, 0)
				return
			end
			if data.gid % 9 == 0 and not isPlayerOrganisationLeader(client, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Tylko główny lider jest w stanie zmienić wynagrodzenie grupy 9!", "stop", nil, nil, 255, 204, 0)
				return
			end
			exports["imta-db_server"]:query("UPDATE `imta_organisation_groups` og SET og.`name` = ? WHERE og.`organisation_id` = ? and og.`internal_id` = ?", name, oid, data.gid)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRUPA NAZWA ZMIANA CID: "..cid.." INT_ID: "..data.gid.." OID: "..oid.." NAZWA:"..name)
		elseif data.rType == "skin" then  --TODO: compare to list
			local skin = tonumber(data.var)
			if not skin then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wybierz ID skina z listy!", "stop", nil, nil, 255, 204, 0)
				return
			end
			skin = math.floor(tonumber(skin))
			if not exports["imta-base"]:isOrganisationSkinAllowed(skin) then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wybrany skin nie jest poprawny! Błąd: 0x0004. Spróbuj ponownie za minutę.", "stop", nil, nil, 255, 204, 0)
				return
			end
			if data.gid % 9 == 0 and not isPlayerOrganisationLeader(client, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Tylko główny lider jest w stanie zmienić skin grupy 9!", "stop", nil, nil, 255, 204, 0)
				return
			end
			exports["imta-db_server"]:query("UPDATE `imta_organisation_groups` og SET og.`skin_id` = ? WHERE og.`organisation_id` = ? and og.`internal_id` = ?", skin, oid, data.gid)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRUPA SKIN ZMIANA CID: "..cid.." INT_ID: "..data.gid.." OID: "..oid.." SKIN:"..skin)
		elseif data.rType == "payout" then
			local payout = tonumber(data.var)
			if not payout or math.floor(payout) < 0 then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wysokość wynagrodzenia musi być cyfrą oraz nie może być mniejsza od 0!", "stop", nil, nil, 255, 204, 0)
				return
			end
			if data.gid % 9 == 0 and not isPlayerOrganisationLeader(client, oid) then 
				triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Tylko główny lider jest w stanie zmienić wynagrodzenie grupy 9!", "stop", nil, nil, 255, 204, 0)
				return
			end
			payout = math.floor(payout)
			exports["imta-db_server"]:query("UPDATE `imta_organisation_groups` og SET og.`payout` = ? WHERE og.`organisation_id` = ? and og.`internal_id` = ?", payout, oid, data.gid)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRUPA WYNAGRODZENIE ZMIANA CID: "..cid.." INT_ID: "..data.gid.." OID: "..oid.." WYNAGRODZENIE: "..payout)
		end
		triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client)
	elseif i == 11 then
		if not data.gid or not tonumber(data.gid) then
			return
		end
		if isPlayerOrganisationLeaderByID(data.cid, oid) then 
			triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Akcja ta jest niemożliwa do wykonania na głównym liderze organizacji!", "stop", nil, nil, 255, 204, 0)
			return
		end
		if data.rType == "change" then
			local group = data.var
			if not group or group < 0 or group > 8 then
				triggerClientEvent(client, "createClientNotification", client, "Niepoprawne dane!", "Wybierz grupę do której gracz ma zostać przypisany!", "stop", nil, nil, 255, 204, 0)
				return
			end
			local oldGroup = exports["imta-db_server"]:getFirstRow("SELECT `char_id`, `group_id`, `use_individual_rights` FROM `imta_organisation_group_members` WHERE `char_id` = ? and `group_id` = ?", data.cid, data.gid)
			local newGroup = exports["imta-db_server"]:getFirstRow("SELECT `id` FROM `imta_organisation_groups` WHERE `organisation_id` = ? AND `internal_id` = ?", oid, group + 1)
			exports["imta-db_server"]:query("UPDATE `imta_organisation_group_members` SET `group_id` = ? WHERE `char_id` = ? AND `group_id` = ?", newGroup.id, oldGroup.char_id, oldGroup.group_id)
			if oldGroup.use_individual_rights == 1 then
				local owid = createPlayerWorkID(oldGroup.group_id, oldGroup.char_id)
				local nwid = createPlayerWorkID(newGroup.id, oldGroup.char_id)
				exports["imta-db_server"]:query("UPDATE `imta_organisation_permission_list` SET `id` = ? WHERE `id` = ? AND `type` = 'player'", nwid, owid)
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZARZĄDZANIE CZŁONKAMI GRUP - ZMIANA CID ZMIENIAJĄCY: "..cid.." CID ZMIENIANY: "..data.cid.." NOWA GID: "..newGroup.id.." STARA GID: "..oldGroup.group_id)
			end
		elseif data.rType == "remove" then
			local wid = createPlayerWorkID(data.gid, data.cid)
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE `permission_id` = ? and type = 'player'", wid)
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_group_members` WHERE `char_id` = ? AND `group_id` = ?", data.cid, data.gid)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZARZĄDZANIE CZŁONKAMI GRUP - KASACJA CID KASUJĄCY: "..cid.." CID KASOWANY: "..data.cid.." GID: "..data.gid)
			for j, player in ipairs(getElementsByType("player")) do
				if getElementData(player, "character:id") == data.cid then 
					--powiadomienie
					triggerClientEvent(player, "createClientNotification", player, "Zostałeś wyrzucony!", "To twój koniec przygody z "..getOrganisationNameFromID(oid)..".", "anger", 8000, 0.9, 255, 253, 208)

					if getElementData(player, "organisation:id") == oid then 
						--zdjęcie z duty
						endPlayerDuty(player)
					end
				end
			end
		end
		triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client)
	elseif i == 12 then
		exports["imta-db_server"]:query("UPDATE `imta_organisation_permission_list` SET `margin` = ? WHERE id = ? AND permission_id = ? AND type = 'faction'", data.margin, oid, data.pid)
		triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Marża została zaktualizowana pomyślnie." , "tick", nil, nil, 85, 204, 0)
		triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA MARŻY CID: "..cid.." PID: "..data.pid.." OID: "..oid.." MARŻA: "..data.margin)
		triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client)
	elseif i == 13 then 
		if tonumber(data.vid) then 
		-- make sure that vehicle still exists and is within organisation and player has proper rights
			if data.rType == "checkHistory" then 
				--TODO
			elseif data.rType == "removeSpecial" then 
				exports["imta-db_server"]:query("UPDATE `imta_vehicles` SET `veh_special`= 50 WHERE `veh_id` = ?", data.vid)
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA POJAZD - SPECJALNOŚĆ BRAK CID: "..cid.." VID: "..data.vid.." OID: "..oid)
			elseif data.rType == "setSpecialA" then 
				exports["imta-db_server"]:query("UPDATE `imta_vehicles` SET `veh_special`= 51 WHERE `veh_id` = ?", data.vid)
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA POJAZD - SPECJALNOŚĆ A CID: "..cid.." VID: "..data.vid.." OID: "..oid)
			elseif data.rType == "setSpecialB" then 
				exports["imta-db_server"]:query("UPDATE `imta_vehicles` SET `veh_special`= 52 WHERE `veh_id` = ?", data.vid)
				triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA POJAZD - SPECJALNOŚĆ B CID: "..cid.." VID: "..data.vid.." OID: "..oid)
			elseif data.rType == "removeVehicle" then 
				--TODO
			end
		else
			triggerClientEvent(client, "createClientNotification", client, "Wystąpił błąd!", "Kod: imta-organisations[0000]", "stop", nil, nil, 255, 204, 0) --TODO
		end
		local returnData = exports["imta-db_server"]:getRows("SELECT veh_id, veh_model, veh_special FROM `imta_vehicles` WHERE veh_owning_organisation = ? ORDER BY `imta_vehicles`.`veh_special` ASC, `imta_vehicles`.`veh_id` ASC", oid)
		triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client)
		
	elseif i == 15 then
		local rv = exports["imta-db_server"]:query("UPDATE `imta_organisation` SET `leader_note` = ? WHERE `id` = ?", data.text, oid)
		if rv then
			triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Notatka lidera została zaktualizowana.", "tick", nil, nil, 85, 204, 0)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA NOTATKA CID: "..cid.." OID: "..oid.." TEXT: "..data.text)
		else 
			triggerClientEvent(client, "createClientNotification", client, "Operacja nieudana!", "Zmiana notatki od lidera nie powiodła się", "stop", nil, nil, 255, 204, 0)
		end
	elseif i == 17 then
		--[[
			1. lista do nadania i zabrania
			2. lista ogólnych permisji frakcji
			3. kasacja permisji z listy do zebrania
			3. nadanie tylko tych z listy (ogólnej i nadanej)
		]]
		local organisationPermissionList = exports["imta-db_server"]:getRows("SELECT permission_id FROM `imta_organisation_permission_list` opl WHERE opl.`id` = ? AND opl.`type` = 'faction'", oid)
		local indexedOrganisationPermissionList = {}
		for j, row in ipairs(organisationPermissionList) do
			indexedOrganisationPermissionList[row.permission_id] = true
		end
		local filteredOrganisationList = {}
		local newOrganisationList = data.permissonListNew
		for j, perm_id in ipairs(data.permissonListNew) do
			if indexedOrganisationPermissionList[perm_id] then
				table.insert(filteredOrganisationList, perm_id)
			end
		end
		local trueGid = exports["imta-db_server"]:getFirstRow("SELECT `id` FROM `imta_organisation_groups` WHERE `organisation_id` = ? AND `internal_id` = ?", oid, data.gid)
		if not trueGid or not trueGid.id then
			triggerClientEvent(client, "createClientNotification", client, "Operacja nieudana!", "Wystąpił błąd. Spróbuj ponownie później. Kod błędu: 0x0002", "stop", nil, nil, 255, 204, 0)
		end
		trueGid = trueGid.id
		triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA UPRAWNIEŃ GRUP CID: "..cid.." OID: "..oid.." GID: "..data.gid.." LISTA UPRAWNIEŃ: "..toJSON(filteredOrganisationList))
		if #filteredOrganisationList == 0 then 
			--it's empty so we delete all of the rows related to the group
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'group'", trueGid)
			triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Uprawnienia grupy "..data.name.." zostały usunięte pomyślnie." , "tick", nil, nil, 85, 204, 0)
			triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client, {gid = data.gid, name = data.name})
		else
			--it's not empty so we use standard procedure
			local filteredOrganisationListStringToDelete = table.concat(filteredOrganisationList, ",")
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'group' AND permission_id NOT IN ("..filteredOrganisationListStringToDelete..")", trueGid)
			local filteredOrganisationListStringToInsert = "("..trueGid..", "..table.concat(filteredOrganisationList, ", 'group'), ("..trueGid..", ")..", 'group')"
			exports["imta-db_server"]:query("INSERT IGNORE INTO `imta_organisation_permission_list` (`id`, `permission_id`, `type`) VALUES "..filteredOrganisationListStringToInsert)
			triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Uprawnienia brupy "..data.name.." zostały zmienione pomyślnie." , "tick", nil, nil, 85, 204, 0)
			triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client, {gid = data.gid, name = data.name})
		end
	elseif i == 18 then
		local organisationPermissionList = exports["imta-db_server"]:getRows("SELECT permission_id FROM `imta_organisation_permission_list` opl WHERE opl.`id` = ? AND opl.`type` = 'faction'", oid)
		local indexedOrganisationPermissionList = {}
		for j, row in ipairs(organisationPermissionList) do
			indexedOrganisationPermissionList[row.permission_id] = true
		end
		local filteredOrganisationList = {}
		local newOrganisationList = data.permissonListNew
		for j, perm_id in ipairs(data.permissonListNew) do
			if indexedOrganisationPermissionList[perm_id] then
				table.insert(filteredOrganisationList, perm_id)
			end
		end
		local wid = createPlayerWorkID(data.gid, data.cid)
		triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ZMIANA UPRAWNIEŃ GRACZA CID ZMIENIAJĄCY: "..cid.." OID: "..oid.." CID ZMIENIANY: "..data.cid.." GID: "..data.gid.." LISTA UPRAWNIEŃ: "..toJSON(filteredOrganisationList))
		if #filteredOrganisationList == 0 then 
			--it's empty so we delete all of the rows related to the group
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'player'", wid)
			triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Wszystkie uprawnienia indywidualne "..data.name.." zostały usunięte pomyślnie." , "tick", nil, nil, 85, 204, 0)
			triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client, {gid = data.gid, cid = data.cid, name = data.name})
		else
			--it's not empty so we use standard procedure
			local filteredOrganisationListStringToDelete = table.concat(filteredOrganisationList, ",")
			exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE id = ? AND type = 'player' AND permission_id NOT IN ("..filteredOrganisationListStringToDelete..")", wid)
			local filteredOrganisationListStringToInsert = "("..wid..", "..table.concat(filteredOrganisationList, ", 'player'), ("..wid..", ")..", 'player')"
			exports["imta-db_server"]:query("INSERT IGNORE INTO `imta_organisation_permission_list` (`id`, `permission_id`, `type`) VALUES "..filteredOrganisationListStringToInsert)
			triggerClientEvent(client, "createClientNotification", client, "Operacja udana!", "Uprawnienia gracza "..data.name.." zostały zmienione pomyślnie." , "tick", nil, nil, 85, 204, 0)
			triggerEvent("onPlayerDemandOrganisationPanel", resourceRoot, oid, i, client, {gid = data.gid, cid = data.cid, name = data.name})
		end
		
		
	end
end)

addEvent("onPlayerAskOrganisationPanel", true)
addEventHandler("onPlayerAskOrganisationPanel", resourceRoot, function(oid, i, data)
	local cid = tonumber(getElementData(client, "character:id"))
	oid = tonumber(oid)
	if not oid or not cid  or not i then 
		return
	end	
	if i == 3 then
		returnData = exports["imta-db_server"]:getFirstRow("SELECT `veh_special` FROM `imta_vehicles` WHERE `veh_id` = ? and `veh_owning_organisation` = ?", data.vid, oid)
		if not returnData or not returnData.veh_special then 
			return
		end
		if not doesPlayerHavePermission(client, returnData.veh_special) then
			triggerClientEvent(client, "createClientNotification", client, "Brak uprawnień!", "Niestety, nie posiadasz uprawnień do tego pojazdu i nie możesz sprawdzić jego lokalizacji", "stop", nil, nil, 255, 204, 0) --TODO
		end
		local veh = exports["imta-vehicles_obsluga"]:getVehicleByID(data.vid)
		if not veh or not isElement(veh) then
			triggerClientEvent(client, "createClientNotification", client, "Pojazd nie istnieje!", "Niestety, pojazd który wybrałeś nie może zostać namierzony, ponieważ jest on zniszczony/niezespawnowany!", "stop", nil, nil, 255, 204, 0) --TODO
		end
		for j, occupant in pairs(getVehicleOccupants(veh)) do
			if j then 
				triggerClientEvent(client, "createClientNotification", client, "Pojazd zajęty!", "Niestety, pojazd który wybrałeś już jest przez kogoś używany.", "stop", nil, nil, 255, 204, 0) --TODO
				return 
			end
		end 
		exports["imta-vehicles_obsluga"]:createBlipForVehicle(client, veh)
		triggerClientEvent(client, "createClientNotification", client, "Pojazd oznaczony!", "Lokalizacja będzie zaznaczona na minimapie przez 10 sekund.", "car", 10000, nil, 0, 170, 255)
	end
end)

addEvent("onPlayerChangeDutyStatus", true)
addEventHandler("onPlayerChangeDutyStatus", resourceRoot, function(oid, i, data)
	local cid = tonumber(getElementData(client, "character:id"))
	oid = tonumber(oid)
	if not oid or not cid  or not i then 
		return
	end	
	local coid = getElementData(client, "organisation:id")
	if i == 1 then  --duty
		if coid == oid then 
			--we end duty 
			endPlayerDuty(client)
		elseif not coid then
			-- we start duty
			local orgName = getOrganisationNameFromID(oid)
			local orgColor = getOrganisationColorFromID(oid)
			setElementData(client, "organisation:id", oid, false)
			local useName = doesPlayerHavePermission(client, 9)
			setElementData(client, "organisation:name", orgName or nil, false)
			setElementData(client, "organisation:useName", useName, false)
			setElementData(client, "organisation:color", orgColor or nil, false)
			triggerEvent("onNametagsSomething", root, "setPlayerData", client)
			triggerClientEvent(client, "onPlayerChangeDutyStatusResponse", resourceRoot, 1, true, orgName, orgColor)
			triggerClientEvent(client, "createClientNotification", client, "Służba", "Pomyślnie udało ci się rozpocząć służbę!", "tick", nil, 0.6, 85, 204, 0)

		elseif coid then			
			-- we switch duty
			local orgName = getOrganisationNameFromID(oid)
			local orgColor = getOrganisationColorFromID(oid)
			setElementData(client, "organisation:id", oid, false)
			local useName = doesPlayerHavePermission(client, 9)
			setElementData(client, "organisation:name", orgName or nil, false)
			setElementData(client, "organisation:useName", useName, false)
			setElementData(client, "organisation:color", orgColor or nil, false)
			triggerEvent("onNametagsSomething", root, "setPlayerData", client)
			triggerClientEvent(client, "onPlayerChangeDutyStatusResponse", resourceRoot, 1, true, orgName, orgColor)
			exports["imta-base"]:determinePlayerSkin(client)
			triggerClientEvent(client, "createClientNotification", client, "Służba", "Pomyślnie udało ci się zmienić służbę!", "tick", nil, 0.6, 85, 204, 0)

		end 
	elseif i == 2 then  --clothes
		if coid == oid then 
			-- używamy skina organizacyjnego i switchujemy że go mamy/nie mamy
			local isUsingOrgSkin = getElementData(client, "organisation:usingSkin")
			if isUsingOrgSkin then
				removeElementData(client, "organisation:usingSkin")
				exports["imta-base"]:determinePlayerSkin(client)
				triggerClientEvent(client, "createClientNotification", client, "Przebranie", "Pomyślnie udało Ci się przebrać w ubrania prywatne!", "tick", nil, 0.6, 85, 204, 0)
			else
				setElementData(client, "organisation:usingSkin", true, false)
				exports["imta-base"]:determinePlayerSkin(client)
				triggerClientEvent(client, "createClientNotification", client, "Przebranie", "Pomyślnie udało Ci się przebrać w ubrania organizacji!", "tick", nil, 0.6, 85, 204, 0)
			end
			return
		elseif not coid then
			triggerClientEvent(client, "createClientNotification", client, "Przebranie", "Nie możesz się przebrać, ponieważ nie jesteś na służbie!", "stop", nil, 0.6, 255, 204, 0)
			return
		elseif coid ~= oid then 
			triggerClientEvent(client, "createClientNotification", client, "Przebranie", "Nie możesz się przebrać, ponieważ nie jesteś na służbie w tej organizacji!", "stop", nil, 0.6, 255, 204, 0)
			return
		end
	end
end)



addEvent("onPlayerLeaveOrganisation", true)
addEventHandler("onPlayerLeaveOrganisation", resourceRoot, function(oid)
	local cid = tonumber(getElementData(client, "character:id"))
	oid = tonumber(oid)
	if not oid or not cid then 
		return
	end	
	if isPlayerOrganisationLeaderByID(cid, oid) then 
		triggerClientEvent(client, "createClientNotification", client, "Opuszczanie", "Nie możesz opuścić organiacji, w której jesteś głównym liderem!", "stop", nil, 0.6, 255, 204, 0)
		return
	end
	local gid = getPlayerGroupByPlayerID(cid, oid)
	if not gid then
		triggerClientEvent(client, "createClientNotification", client, "Opuszczanie", "Nie możesz opuścić organiacji, w której już się nie znajdujesz!", "stop", nil, 0.6, 255, 204, 0)
		return
	end
	local wid = createPlayerWorkID(gid, cid)
	exports["imta-db_server"]:query("DELETE FROM `imta_organisation_permission_list` WHERE `permission_id` = ? and type = 'player'", wid)
	exports["imta-db_server"]:query("DELETE FROM `imta_organisation_group_members` WHERE `char_id` = ? AND `group_id` = ?", cid, gid)
	triggerClientEvent(client, "createClientNotification", client, "Opuściłeś grupę!", "Spływaj szefie! Opuściłeś grupę, chrzanić ich wszystkich, prawda? Poradzisz sobie lepiej bez nich.", "anger", 8000, 0.9, 255, 253, 208)
	if getElementData(client, "organisation:id") == oid then 
		endPlayerDuty(client)
	end
	triggerClientEvent(client, "onPlayerDemandOrganisationPanelResponse", resourceRoot, 6, true, oid)
end)


local function processPayout()
	local payoutData = {}
	local orgMultiplier = 0
	local orgPayoutSize = 0
	local prDays = exports["imta-db_server"]:getRows("SELECT org_id, start_time, SUM(playtime) as 'total', max_pay_daily FROM `imta_organisation_member_playtime` omp JOIN `imta_organisation` o ON omp.org_id = o.id WHERE payment_run = 0 GROUP BY org_id, start_time")
	triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "LOGOWANIE WYNAGRODZEŃ POCZĄTEK")
	for i, day in ipairs(prDays) do
		local players = exports["imta-db_server"]:getRows("SELECT *, (CASE WHEN playtime < 30 THEN 0 WHEN (playtime >= 30 and playtime < 60) THEN 0.5 WHEN playtime < 120 THEN 1 WHEN (playtime >= 120 and playtime < 180) THEN 1.25 ELSE 1.5 END) as 'multiplier' FROM imta_organisation_member_playtime WHERE payment_run = 0 AND org_id = ? and start_time = ? ORDER BY `imta_organisation_member_playtime`.`org_id` ASC", day.org_id, day.start_time)
		
		for j, player in ipairs(players) do
			local wage = 0
			if player.multiplier ~= 0 then 
				wage = exports["imta-db_server"]:getFirstRow("SELECT IF(ogm.payout = -1, og.payout, ogm.payout) as ' payout' FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.group_id = og.id WHERE ogm.char_id = ? AND og.organisation_id = ?", player.char_id, day.org_id)
				if not wage or not wage.payout then 
					wage = exports["imta-db_server"]:getFirstRow("SELECT ROUND(AVG(payout)) AS 'payout' FROM `imta_organisation_groups` WHERE organisation_id = ?", day.org_id)
					if not wage or not wage.payout then 
						wage = 0
					else
						wage = wage.payout
					end
				else
					wage = wage.payout
				end
				orgPayoutSize = orgPayoutSize + wage
			end
			table.insert(payoutData, {cid = player.char_id, payout = wage, mult = player.multiplier, pt = player.playtime})
		end
		local orgMultiplier = 1
		if orgPayoutSize > day.max_pay_daily then
			orgMultiplier = orgPayoutSize / day.max_pay_daily
		end
		triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "ORGANIZACJA OID: "..day.org_id.." DATA: "..day.start_time.." MNOŻNIK: "..orgMultiplier.."("..orgPayoutSize.."/"..day.max_pay_daily..")")

		for j, row in ipairs(payoutData) do
			local realWage = math.floor(row.payout * row.mult * orgMultiplier)
			triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "GRACZ CID: "..row.cid.." PAYOUT: "..row.payout.." REAL PAYOUT: "..realWage.." MNOŻNIK: "..row.mult.." CZAS GRY: "..row.pt)
			exports["imta-db_server"]:query("UPDATE `imta_characters` SET `char_bankmoney` = `char_bankmoney` + ?  WHERE `char_id` = ?", realWage, row.cid)
			exports["imta-db_server"]:query("UPDATE `imta_organisation_member_playtime` SET `payment_run` = 1 WHERE `char_id` = ? AND `org_id` = ? AND `start_time` = ?", row.cid, day.org_id, day.start_time)
		end
		
		payoutData = {}
		orgPayoutSize = 0
	end
	triggerEvent("onLogsSomething", root, "outputLogs", "organisation", "LOGOWANIE WYNAGRODZEŃ KONIEC")
end
addEventHandler("onOneHour", resourceRoot, function(h) if h == 3 then processPayout() end end) --4 am