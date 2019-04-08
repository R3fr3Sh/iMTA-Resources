ORG_PANEL_HELP_TEXT = [[Test pomocy. Edytować w org_data_c.lua]]
BUILDINGS_TYPES_DICTIONARY = {
	["dom" ] = "Dom",
	["garaz" ] = "Garaż",
	["biznes"] = "Biznes",					
}

VEHICLES_TYPES_DICTIONARY = {
	[50 ] = "",
	[51 ] = "A",
	[52] = "B",					
}

SKIN_LIST = {

}

tabs = {
	{
		name = "Informacje",
		file = "media/icons/info-sign.png",
	},
	{
		name = "Czł. online",
		file = "media/icons/multiple-users-silhouette.png",
	},
	{
		name = "Pojazdy",
		file = "media/icons/sports-car.png",
	},
	{
		name = "Zarządzanie",
		file = "media/icons/manager.png",
	},
	{
		name = "Opuść grupę",
		file = "media/icons/exit.png",
	},
	{
		name = "Zamknij okno",
		file = "media/icons/hide-window.png",
	},
}

infoTab = {
	{
		name = "Członkowie: ",
		file = "media/icons/multiple-users-silhouette-32.png",
		base = "member_count"
	},
	{
		name = "Lider: ",
		file = "media/icons/business-person-silhouette-wearing-tie-32.png",
		base = "leader_name"
	},
	{
		name = "Pojazdów: ",
		file = "media/icons/sports-car-32.png",
		base = "vehicle_count"
	},
	{
		name = "Moje zarobki: ",
		name_before = "$",
		file = "media/icons/coins-32.png",
		base = "payout"
	},
	{
		name = "Ubranie\nsłużbowe: ",
		file = "media/icons/t-shirt-black-silhouette-32.png",
		base = "skin_id"
	},
}

infoTabManagement = {
	{
		name = "ID: ",
		base = "id"
	},
	{
		name = "Nazwa: ",
		base = "name"
	},
	{
		name = "Lider: ",
		base = "leader_name"
	},
	{
		name = "Stan konta: ",
		base = "money",
		name_after = "$"
	},
	{
		name = "Ilość członków: ",
		base = "member_count"
	},
	{
		name = "Ilość pojazdów: ",
		base = "vehicle_count"
	},
	{
		name = "Ilość budynków: ",
		base = "building_count"
	},
	{
		name = "Kolor (HEX): ",
		base = "color"
	},
	{
		name = "Średnia dzienna ilość minut na członka: ",
		base = "color"
	},
}

orgIcons = {
	[1] = {
		name = "Tarcza policyjna",
		path = "media/icons/police-shield-128.png",
	},
	[2] = {
		name = "Kapelusz",
		path = "media/icons/black-homburg-hat-128.png",
	},
	[3] = {
		name = "Kaduceusz",
		path = "media/icons/caduceus-medical-symbol-128.png",
	},
	[4] = {
		name = "Naprawa pojazdu",
		path = "media/icons/car-repair-128.png",
	},
	[5] = {
		name = "Strażak",
		path = "media/icons/firefighter-silhouette-128.png",
	},
	[6] = {
		name = "Bandana",
		path = "media/icons/kerchief-128.png",
	},
	[7] = {
		name = "Mikrofon",
		path = "media/icons/microphone-128.png",
	},
	[8] = {
		name = "Tajny agent",
		path = "media/icons/secret-agent-128.png",
	},
}
