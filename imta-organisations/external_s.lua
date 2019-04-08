function isPlayerInOrganisation(client, organisationID)
	organisationID = tonumber(organisationID)
	if not organisationID or not client then 
		return false
	end
	local cid = getElementData(client, "character:id")
	outputDebugString(cid..":"..organisationID)
	if not cid then
		return	false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT internal_id FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE ogm.`char_id` = ? and og.`organisation_id` = ?", cid, organisationID)
	if not r then
		return false
	end
	return r.internal_id
end

function getPlayerGroupByPlayerID(cid, organisationID)
	organisationID = tonumber(organisationID)
	cid = tonumber(cid)
	if not organisationID or not cid then 
		return false
	end

	local r = exports["imta-db_server"]:getFirstRow("SELECT group_id FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE ogm.`char_id` = ? and og.`organisation_id` = ?", cid, organisationID)
	if not r then
		return false
	end
	return r.group_id
end

function getPlayerOrganisationList()
	
end

function isPlayerOrganisationLeader(client, organisationID)
	organisationID = tonumber(organisationID)
	if not organisationID or not client then 
		return false
	end
	local cid = getElementData(client, "character:id")
	if not cid then
		return	false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT TRUE FROM `imta_organisation` WHERE `id` = ? and `leader_id` = ?", organisationID, cid)
	if not r then
		return false
	end
	return true
end

function isPlayerOrganisationLeaderByID(cid, organisationID)
	organisationID = tonumber(organisationID)
	cid = tonumber(cid)
	if not organisationID or not cid then 
		return false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT TRUE FROM `imta_organisation` WHERE `id` = ? and `leader_id` = ?", organisationID, cid)
	if not r then
		return false
	end
	return true
end

function addCharacterToOrganisation(cid, oid, prank, client) --client is optional
	if hasPlayerOrganisationSlot(cid, client) then
		return addPlayerToOrganisation(cid, oid, prank)
	end
	return false
end

function hasOrganisationSlots(oid)
	local orgLimit = exports["imta-db_server"]:getFirstRow("SELECT member_limit FROM `imta_organisation` WHERE `id` = ?", oid)
	if orgLimit and tonumber(orgLimit.member_limit) then
		if orgLimit.member_limit == 0 then 
			return true
		end
		
		local playerCount = exports["imta-db_server"]:getFirstRow("SELECT COUNT(*) as 'count' FROM `imta_organisation_groups` og JOIN `imta_organisation_group_members` ogm ON og.id = ogm.group_id WHERE og.organisation_id = ?", oid)
		if playerCount and playerCount.count then
			if playerCount.count < orgLimit.member_limit then 
				return true
			end
			return false
		end
		return true
	end
	return false
	
end

function isPlayerOnDuty(client, organisationID) 
	if not client then 
		return false
	end
	organisationID = tonumber(organisationID)
	local oid = getElementData(client, "organisation:id")
	if not oid or (organisationID and oid ~= organisationID) then
		return	false
	end
	return oid
end

function endPlayerDuty(client)
	removeElementData(client, "organisation:useName")
	removeElementData(client, "organisation:id")
	removeElementData(client, "organisation:name")
	removeElementData(client, "organisation:color")
	triggerEvent("onNametagsSomething", root, "setPlayerData", client)
	triggerClientEvent(client, "onPlayerChangeDutyStatusResponse", resourceRoot, 1, false, nil)
	triggerClientEvent(client, "createClientNotification", client, "Służba", "Pomyślnie udało ci się zakończyć służbę!", "tick", nil, 0.6, 85, 204, 0)
	removeElementData(client, "organisation:usingSkin")
	exports["imta-base"]:determinePlayerSkin(client)
end

function getOrganisationNameFromID(organisationID)
	organisationID = tonumber(organisationID)
	if not organisationID then 
		return false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT `name` FROM `imta_organisation` WHERE `id` = ?", organisationID)
	if not r then
		return false
	end
	return r.name
end

function getOrganisationColorFromID(organisationID)
	organisationID = tonumber(organisationID)
	if not organisationID then 
		return false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT `color` FROM `imta_organisation` WHERE `id` = ?", organisationID)
	if not r then
		return false
	end
	return r.color
end

function getOrganisationNameFromPlayer(client)
	organisationID = tonumber(isPlayerOnDuty(client))
	if not organisationID or not client then 
		return false
	end
	return getOrganisationNameFromID(organisationID)
end

function getOrganisationColorFromPlayer(client)
	organisationID = tonumber(isPlayerOnDuty(client))
	if not organisationID or not client then 
		return false
	end
	return getOrganisationColorFromID(organisationID)
end

permissionExceptionList = {
[9] = true,
}

function doesPlayerHavePermission(client, permissionID)
	permissionID = tonumber(permissionID)
	if not permissionID or not client then 
		return false
	end
	local oid = isPlayerOnDuty(client)
	local cid = getElementData(client, "character:id")
	local gdata = getPlayerGroupData(cid, oid)
	if not oid or not cid or not gdata then
		return false
	else
		if isPlayerInOrganisation(client, oid) == 9 and not permissionExceptionList[permissionID] then --faction leader doesn't give a fuck and can use everything, of course there are exceptions
			local r = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permission_list` WHERE permission_id = ? AND id = ? AND type = 'faction'", permissionID, oid)
			if r and #r > 0 then
				return true
			end
		elseif not gdata.use_individual_rights then
			local r = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permission_list` WHERE permission_id = ? AND id = ? AND type = 'group'", permissionID, gdata.group_id)
			if r and #r > 0 then
				return true
			end

		else
			local wid = createPlayerWorkID(gdata.group_id, cid)
			local r = exports["imta-db_server"]:getRows("SELECT * FROM `imta_organisation_permission_list` WHERE permission_id = ? AND ((id = ? AND type = 'group') OR (id = ? AND type = 'player'))", permissionID, gdata.group_id, wid)
			if r and #r > 0 then
				return true
			end
		end
	end
	return false
end


function doesOrganisationHavePermission(organisationID, permissionID)
	permissionID = tonumber(permissionID)
	organisationID = tonumber(organisationID)
	if not permissionID or not organisationID then 
		return false
	end
	local r = exports["imta-db_server"]:getFirstRow("SELECT id FROM `imta_organisation_permission_list` WHERE `permission_id` = ? AND `id` = ? AND `type` = 'faction'", permissionID, organisationID)
	if r and r.id then
		return true
	end
	return false
end

function getPermissionMargin(oid, pid)
	local r = exports["imta-db_server"]:getFirstRow("SELECT margin FROM `imta_organisation_permission_list` WHERE id = ? and permission_id = ? and type = 'faction'", oid, pid)
	if r and r.margin then
		return r.margin/100
	end
	return false
end
