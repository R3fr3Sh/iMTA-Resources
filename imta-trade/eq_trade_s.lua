
--przed 
--sprawdzamy czy nie jest zakuety
--sprawdzamy czy już nie handluje
--po inicjalizacji handlu

--zbieramy hajs
--zbieramy możliwe itemki do przehandlowania
--tworzymy z graczy "parę"
--dodajemy zabezpieczenia po wyjściu z handlu
--dodajemy zabezpieczenia po śmierci
--dodajemy zabezpieczenia po wyjściu z serwera
--po zakuciu


function isPlayerEgibleForTrade(player, target)
	if not isElement(player) then
		return false, "Osoba z którą handlowałeś opuściła rozgrywkę."
	end
	local px, py, pz = getElementPosition(player)
	local tx, ty, tz = getElementPosition(target)
	local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
	if distance > 5 then 
		return false, "Osoba z którą handlowałeś jest zbyt daleko!", "Osoba z którą handlowałeś jest zbyt daleko!"
	elseif isPedDead(player) then 
		return false, "Osoba z którą handlowałeś jest martwa.", "Nie żyjesz, więc handel nie może dojść do skutku!"
	elseif getElementData(player, "group:blocked_arms") then 
		return false, "Osoba z którą handlowałeś ma skute ramiona.", "Masz skute dłonie, więc handel nie może dojść do skutku!"
	elseif getElementData(player, "group:blocked_legs") then 
		return false, "Osoba z którą handlowałeś ma skute nogi.", "Masz skute dłonie, więc handel nie może dojść do skutku!"
	elseif getElementData(player, "inhibitor:freeze") then 
		return false, "Osoba z którą handlowałeś została porażona paralizatorem.", "Zostałeś porażony paralizatorem, więc handel nie może dojść do skutku!"
	elseif getElementData(player, "player:vehicle:backseat") then 
		return false, "Osoba z którą handlowałeś znajduje się w bagażniku.", "Znajdujesz się w bagażniku, więc handel nie może dojść do skutku!"
	elseif getElementData(player, "player:animation") then
		return false, "Osoba z którą handlowałeś wykonuje właśnie animację.", "Wykonujesz animację, więc handel nie może dojść do skutku!"
	end
	return true
end
function endPlayerTrade(player)
	removeElementData(player, "tradingPartner")
	removeElementData(player, "readyToTrade")
	removeElementData(player, "EQToTrade")
	removeElementData(player, "cashToTrade")
	triggerClientEvent(player, "onPartnerEndOffer", resourceRoot)
end
local function getName(p)
	return string.gsub(getPlayerName(p), "_", " ")
end
function initializeTrade(playerStarted, playerAccepted)
	local pStartedEQ = getElementData(playerStarted, "EQ")
	local pStartedEQFiltered = exports["imta-eq"]:getEQTradeableItems(pStartedEQ)
	local pAcceptedEQ = getElementData(playerAccepted, "EQ")
	local pAcceptedFiltered = exports["imta-eq"]:getEQTradeableItems(pAcceptedEQ)
	setElementData(playerStarted, "tradingPartner", playerAccepted, false)
	setElementData(playerAccepted, "tradingPartner", playerStarted, false)
	local pStartedName = getName(playerStarted)
	local pAcceptedName = getName(playerAccepted)
	triggerClientEvent(playerStarted, "onServerInitiateTrade", resourceRoot, pStartedEQFiltered, pAcceptedName)
	triggerClientEvent(playerAccepted, "onServerInitiateTrade", resourceRoot, pAcceptedFiltered, pStartedName)
end
local rem = getPlayerFromName("Remigiusz_Maciaszek")
local rem2 = getPlayerFromName("Charlie_Boston")


--local dup, dup2 = isPlayerEgibleForTrade(rem, rem2)
--outputConsole(dup2)
	
--setTimer(function () initializeTrade(rem, rem2) end , 500, 1)

local function checkTradingRequirements(player)
	local EQToTrade = getElementData(player, "EQToTrade")
	local cash = getElementData(player, "cashToTrade")
	local EQ = getElementData(player, "EQ")
	if getPlayerMoney(player) < cash then 
		return false
	end
	for i, item in ipairs(EQToTrade) do
		item.count = item.countToTrade
		local result, ind = exports["imta-eq"]:findItem(EQ, item)
		if not result then 
			return false
		end
		if EQ[ind].isActive then
			return false 
		end
	end
	return cash, EQToTrade
end 

local function finalizeTrade(trader1, trader2)
	local cash1, EQToTrade1 = checkTradingRequirements(trader1)
	if not cash1 then
		triggerClientEvent(trader1, "createClientNotification", root, "Handel nieudany!", "Wymiana nie jest możliwa, ponieważ przedmioty/gotówka przeznaczone na wymianę przez jednego z graczy nie znajdują się już w jego ekwipunku.", "stop", 7500, 0.75, 255, 204, 0)
		triggerClientEvent(trader2, "createClientNotification", root, "Handel nieudany!", "Wymiana nie jest możliwa, ponieważ przedmioty/gotówka przeznaczone na wymianę przez jednego z graczy nie znajdują się już w jego ekwipunku.", "stop", 7500, 0.75, 255, 204, 0)
		endPlayerTrade(trader1)
		endPlayerTrade(trader2)
		return
	end
	local cash2, EQToTrade2 = checkTradingRequirements(trader2)
	if not cash2 then 
		triggerClientEvent(trader1, "createClientNotification", root, "Handel nieudany!", "Wymiana nie jest możliwa, ponieważ przedmioty/gotówka przeznaczone na wymianę przez jednego z graczy nie znajdują się już w jego ekwipunku.", "stop", 7500, 0.75, 255, 204, 0)
		triggerClientEvent(trader2, "createClientNotification", root, "Handel nieudany!", "Wymiana nie jest możliwa, ponieważ przedmioty/gotówka przeznaczone na wymianę przez jednego z graczy nie znajdują się już w jego ekwipunku.", "stop", 7500, 0.75, 255, 204, 0)
		endPlayerTrade(trader1)
		endPlayerTrade(trader2)
		return
	end
	
	for i, item in ipairs(EQToTrade1) do
		item.count = item.countToTrade
		item.countToTrade = nil
		exports["imta-eq"]:takeItem(trader1, item)
		exports["imta-eq"]:giveItem(trader2, item)
	end

	for i, item in ipairs(EQToTrade2) do
		item.count = item.countToTrade
		item.countToTrade = nil
		exports["imta-eq"]:takeItem(trader2, item)
		exports["imta-eq"]:giveItem(trader1, item)
	end
	takePlayerMoney(trader1, cash1)
	takePlayerMoney(trader2, cash2)
	givePlayerMoney(trader1, cash2)
	givePlayerMoney(trader2, cash1)
	endPlayerTrade(trader1)
	endPlayerTrade(trader2)
	triggerClientEvent(trader1, "createClientNotification", root, "Handel udany!", "Wymiana została wykonana pomyślnie.", "tick", 5000, 0.75, 50, 255, 0)
	triggerClientEvent(trader2, "createClientNotification", root, "Handel udany!", "Wymiana została wykonana pomyślnie.", "tick", 5000, 0.75, 50, 255, 0)
	local name1 = getName(trader1)
	local name2 = getName(trader2)
	--dodaj logi
	triggerEvent("onChatSomething", trader1, "do", trader2, "Gracz "..name1.." dokonał wymiany z graczem "..name2)
	

end

local function updateOffer(EQ, cash, readyToTrade, endTrade)
	local partner = getElementData(client, "tradingPartner")
	local result, textSource, textPartner = isPlayerEgibleForTrade(partner, client)
	if not result then 
		triggerClientEvent(client, "createClientNotification", root, "Handel nieudany!", textSource, "stop", 7500, 0.75, 255, 204, 0)
		endPlayerTrade(client)
		if textPartner then
			triggerClientEvent(partner, "createClientNotification", root, "Handel nieudany!", textPartner, "stop", 7500, 0.75, 255, 204, 0)
			endPlayerTrade(partner)
		end
		return
	end
	if endTrade then 
		endPlayerTrade(client)
		endPlayerTrade(partner)
		triggerClientEvent(client, "createClientNotification", root, "Handel zakończony!", "Pomyślnie zrezygnowałeś z wymiany.", "tick", 3000, 0.75, 167, 255, 0)
		triggerClientEvent(partner, "createClientNotification", root, "Handel zakończony!", "Osoba z którą handlowałeś zrezygnowała z wymiany.", "tick", 3000, 0.75, 167, 255, 0)
		return
	end
	setElementData(client, "readyToTrade", readyToTrade, false)
	setElementData(client, "EQToTrade", EQ, false)
	setElementData(client, "cashToTrade", cash, false)
	if not readyToTrade then 
		setElementData(partner, "readyToTrade", false, false)
	end
	if getElementData(client, "readyToTrade") and getElementData(partner, "readyToTrade") then 
		finalizeTrade(client, partner)
		return
	end 
	--sprawdzenie czy oboje są gotowi
	triggerClientEvent(partner, "onPartnerUpdateOffer", resourceRoot, EQ, cash, readyToTrade)
end
addEvent("updateTradeOffer", true)
addEventHandler("updateTradeOffer", resourceRoot, updateOffer)

outputConsole(toJSON(getElementData(getPlayerFromName("Remigiusz_Maciaszek"), "EQToTrade")))
addCommandHandler("dupatest", function (cmd, plr, arg)
	for k, v in ipairs(getElementsByType("player")) do 
		outputConsole(getPlayerName(v)..":"..tostring(getElementData(v, arg)))
	end 

end)

do
	for i, player in ipairs(getElementsByType("plater")) do
		endTrade(player)
	end
end