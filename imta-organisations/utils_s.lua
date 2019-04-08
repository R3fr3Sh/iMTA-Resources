function createPlayerWorkID(group_id, character_id) --created for permissions
	return group_id + 16777215 * character_id
end 

function retrieveCharacterWorkDataFromID(id)
	local group_id = id % 16777215
	return group_id, (id - group_id) / 16777215
end 

function getPlayerGroupData(cid, organisationID, field)
	local r = exports["imta-db_server"]:getFirstRow("SELECT ogm.`group_id`, ogm.`use_individual_rights` FROM `imta_organisation_group_members` ogm JOIN `imta_organisation_groups` og ON ogm.`group_id` = og.`id` WHERE ogm.`char_id` = ? and og.`organisation_id` = ?", cid, organisationID)
	if not r then
		return false
	end
	if not field then
		return r
	end
	return r[field]
end

function hasPlayerOrganisationSlot(cid, client, modifier)
	local orgLimit = 2 + (modifier or 0)
	local premiumResult = exports["imta-db_server"]:getFirstRow("SELECT (u.acc_premium > NOW()) as 'p' FROM `imta_characters` c JOIN `imta_users` u ON c.char_owner = u.acc_id WHERE c.char_id = ?", cid)
	if premiumResult and premiumResult.p then
		orgLimit = orgLimit + 1
	end
	local currentOrgs = exports["imta-db_server"]:getFirstRow("SELECT count(*) as amount FROM `imta_organisation_group_members` WHERE char_id = ?", cid)
	if not currentOrgs or not currentOrgs.amount then
		if client then
			triggerClientEvent(client, "createClientNotification", root, "Błąd bazy", "Wystąpił błąd bazy! #x01", "stop", 5000, 0.75, 255, 204, 0)
		end
		return false
	elseif currentOrgs.amount >= orgLimit then
		if client then
			triggerClientEvent(client, "createClientNotification", root, "Limit organizacji", "Postać na której próbujesz wykonać akcję osiągnęła swój limit organizacji!", "stop", 5000, 0.75, 255, 204, 0)
		end
		return false
	end
	return true
end

function addPlayerToOrganisation(cid, organisation_id, player_rank)
	
	local rv = exports["imta-db_server"]:query("SELECT TRUE FROM `imta_organisation_group_members` WHERE char_id = ? AND group_id IN (SELECT id FROM `imta_organisation_groups` WHERE organisation_id = ?)", cid, organisation_id)
	if rv > 0 then 
		return false
	else 
		local r = exports["imta-db_server"]:query("INSERT INTO `imta_organisation_group_members`(`char_id`, `group_id`) VALUES (?, (SELECT id FROM `imta_organisation_groups` WHERE organisation_id = ? and internal_id = ?))", cid, organisation_id, player_rank)
		return r > 0
	end
end