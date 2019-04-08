local gui = {}
--Siwy biały dla boxu, czcionki i belek po bokach: 204, 204, 204. Czarny box: 4, 5, 3 (przezroczystość ze 100% zbita do 80%, to samo z białym). Tekst czcionki ciemnej: 65, 67, 69 (#414345)
--https://cdn.discordapp.com/attachments/399695849552085003/463800907633786880/unknown.png
local blurBoxes = {}
local sx, sy = guiGetScreenSize()
local currentOrgData = {}
local curIndex = 1
local maxIndex = 1

local function spawnBlurBox(size)
	blurBoxes[1] = exports["blur_box"]:createBlurBox(sx/2-325, sy/2-100, 650, 80, 255, 255, 255, 255, false)
	blurBoxes[2] = exports["blur_box"]:createBlurBox(sx/2-305, sy/2-20, 610, 40 * size, 255, 255, 255, 255, false)
end

local function destroyBlurBox()
	for k, v in ipairs(blurBoxes) do
		exports["blur_box"]:destroyBlurBox(v)
	end
end

local names = {{name = "The Well Stacked Pizza", time = 60}, {name = "LSPD", time = 90}, {name = "FBI", time = 120}}
do
	local font = {}
	do
		font.title = guiCreateFont("media/calibri.ttf", 48)
		font.container = guiCreateFont("media/calibri.ttf", 16)
	end
	gui = {}
	gui.win = guiCreateStaticImage(sx/2-325, sy/2-100, 650, 200, "media/pixels/transparent.png", false)
	gui.title = guiCreateStaticImage(0, 0, 650, 80, "media/pixels/grey.png", false, gui.win)
		guiSetAlpha(gui.title, 0.8)
		guiCreateStaticImage(20, 20, 40, 40, "media/icons/suitcase.png", false, gui.title)
		local title = guiCreateLabel(80, 8, 570, 70, "Grupy:", false, gui.title)
		guiLabelSetColor(title, 65, 67, 69)
		guiSetFont(title, font.title)

	gui.rows = {}
	gui.rowsData = {}
	for i = 1, 3 do
		gui.rows[i] = guiCreateStaticImage(40, 40 + i * 40, 570, 40, "media/pixels/background.png", false, gui.win)
			guiSetAlpha(gui.rows[i], 0.8)
		gui.rowsData[i] = {}
		gui.rowsData[i].l = guiCreateStaticImage(0, 0, 5, 40, "media/pixels/grey.png", false, gui.rows[i])
		gui.rowsData[i].r = guiCreateStaticImage(565, 0, 5, 40, "media/pixels/grey.png", false, gui.rows[i])
		gui.rowsData[i].nb = guiCreateLabel(10, 8, 60, 30, i..".", false, gui.rows[i])
			guiLabelSetColor(gui.rowsData[i].nb, 204, 204, 204)
			guiSetFont(gui.rowsData[i].nb, font.container)
		gui.rowsData[i].name = guiCreateLabel(10, 8, 560, 30, "", false, gui.rows[i])
			guiLabelSetColor(gui.rowsData[i].name, 204, 204, 204)
			guiSetFont(gui.rowsData[i].name, font.container)
			guiLabelSetHorizontalAlign(gui.rowsData[i].name, "center")
	end
	do
		gui.noGroup = guiCreateStaticImage(40, 80, 570, 40, "media/pixels/background.png", false, gui.win)
			guiSetAlpha(gui.noGroup, 0.8)
		local name = guiCreateLabel(5, 8, 560, 30, "Nie należysz do żadnej grupy", false, gui.noGroup) 
			guiLabelSetColor(name, 204, 204, 204)
			guiSetFont(name, font.container)
			guiLabelSetHorizontalAlign(name, "center")
	end
end

local function setBorderVisible(i, bool)
	guiSetVisible(gui.rowsData[i].l, bool)
	guiSetVisible(gui.rowsData[i].r, bool)
end

local function scrollDown()
	setBorderVisible(curIndex, false)
	if curIndex == maxIndex then 
		curIndex = 1
	else
		curIndex = curIndex + 1
	end
	setBorderVisible(curIndex, true)
end

local function scrollUp()
	setBorderVisible(curIndex, false)
	if curIndex == 1 then 
		curIndex = maxIndex
	else
		curIndex = curIndex - 1
	end
	setBorderVisible(curIndex, true)
end
local selectOrganisation =  function() end
local closeOrganisationWindow =  function() end

local function unloadOrgData()
	for i = 1, 3 do
		guiSetVisible(gui.rows[i], false)
	end
	guiSetVisible(gui.noGroup, false)
	guiSetVisible(gui.win, false)
	destroyBlurBox()
	unbindKey("mouse_wheel_down", "down", scrollDown)
	unbindKey("mouse_wheel_up", "down", scrollUp)
	unbindKey("mouse1", "up", selectOrganisation)
	unbindKey("mouse2", "up", closeOrganisationWindow)
end
unloadOrgData()

selectOrganisation = function()
	triggerServerEvent("onPlayerDemandOrganisationPanel", resourceRoot, currentOrgData[curIndex].org_id, 1)
	unloadOrgData()
end

closeOrganisationWindow = function()
	unloadOrgData()
end

local function loadOrgData(data)
	if guiGetVisible(panelWindow) then
		hideWindow()
		return
	end
	if guiGetVisible(gui.win) then
		unloadOrgData()
		return
	end
	
	currentOrgData = data
	if not data or #data == 0 then
		guiSetVisible(gui.noGroup, true)
	else
		for i, org in ipairs(data) do
			guiSetText(gui.rowsData[i].name, org.name.." ("..(org.playtime or 0).." min.)")
			guiSetText(gui.rowsData[i].nb, org.org_id..".")
			guiSetVisible(gui.rows[i], true)
			if i == 1 then
				setBorderVisible(i, true)
			else
				setBorderVisible(i, false)
			end
		end
		bindKey("mouse_wheel_down", "down", scrollDown)
		bindKey("mouse_wheel_up", "down", scrollUp)
		bindKey("mouse1", "up", selectOrganisation)
		bindKey("mouse2", "up", closeOrganisationWindow)
	end
	guiSetVisible(gui.win, true)
	spawnBlurBox(data and #data or 0)
	curIndex = 1
	maxIndex = #data
end
addEvent("onPlayerDemandItsOrganisationListResponse", true )
addEventHandler("onPlayerDemandItsOrganisationListResponse", resourceRoot, loadOrgData)

addEventHandler( "onClientResourceStop", getResourceRootElement( getThisResource()),
function()
	destroyBlurBox()
end)

bindKey("Insert", "down", "organisationList")

function ttt() 
	if not getElementData(localPlayer, "character:id") then 
		return
	end
	if guiGetVisible(gui.win) then
		unloadOrgData()
	else
		triggerServerEvent("onPlayerDemandItsOrganisationList", resourceRoot)
	end
end
