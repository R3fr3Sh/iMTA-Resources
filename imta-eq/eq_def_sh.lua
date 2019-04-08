ITEMS = {}
ITEMS.categories = {
	guns = 10,
	ammo = 20,
	gunparts = 30,
	--phone = 40,
	electronics = 40,
	food = 50,
	drinks = 60,
	drugs = 70,
	steroids = 80,
	luxury = 90,
	clothes = 100,
	spray = 110,
	vehicle_components = 120, 
	other = 130,
}

ITEMS.def = {
	--dorobić wyłączanie itemów z zewnątrz
--[[
EXAMPLE
	saved in DB:
	itemID, health, subtype, count[not present here], coreProperties
	EQ is saved as JSON table converted to base64
	If item has health or coreProperties it CANNOT be stacked.
[ID] = {
	name = "",
	description = "",
	iconPath = "",
	category = "",
	isStackable = true,
	OPTIONAL: 
	subtype = 0
	functions = {
		[functionName]  = {
			args,
		},
		[functionName]  = {
			args,
		},
		
	},
	forbiddenTrade = false,
	forbiddenDrop = false,
	forbiddenUse = false,
	orgRestricted = {
		orgID,
	},
	weaponID = 0,
	allowedIN = {}, -- for weapons
	health = 0,
	pickModel = 0, --model id used to create a dropped item
	coreProperties = {
		WEAPON:
			UID = x
			aim = nil/1/2 -- 0.125, 0.25
			laser = nil/{r, g, b}
			stock = nil/true
			grip = nil/1/2 -- ergo, pionowy
			barrel = nil/1/2 -- silencer, heavy barrel
			ammo = x
			skin = ID tekstury albo nil
			camouflageID = 0,
			magazineSize = 0,
		PREMIUM SKIN:
			skinData = tablica [3-N][N-N][N-N]
			skinGender = "M" or "F"
		WEARABLE OBJECTS:
			woModel = int
			woModelTexture = string -- nazwa tekstury, ktora ma zamienic shader
			woBone = int -- kość z bone_attach
			woPermission = int/nil -- id permisji, przy ktorej mozna zalozyc item
			woIndex = {int, int, int} -- indeksy z tablicy
			woLuxury = boolean -- czy ma miec ikone diamentu
			woPosition = {int, int, int} -- x,y,z od kosci
			woRotation = {int, int, int} -- rx,ry,rz od kosci
			woScale = {int, int, int} -- sx,sy,sz modelu
		PHONE:
			phNumber = int -- numer telefonu
			phCasing = string -- nazwa .png obudowy,	domyślnie "iPhone"
			phIcons = string -- folder, w którym znajdują się ikony na pulpicie, 	domyślnie "standard"
			phWallpaper = string -- nazwa .jpg tapety, 		domyślnie "wp1"
			phRingtone = string -- nazwa .mp3 dzwonka, 		domyślnie "standard"
			phNotificationSound = string -- nazwa .mp3 notyfikacji, 	domyślnie "standard"
		OTHER:
			name = "" --is used first when it exists
			orgRestricted = { -- ???????????
				orgID,
			},
			isActive = boolean, do not set manually, only used on save/load and sets isActive property
	}
	Customization Package:
		allowCustomization = true, --shows customization button
		exportedFunctionResource = "", --resource to be called
		exportedFunctionName = "", --function to be called

	isLostOnUse = true,
	NONDEFINITIVE, BUT USED PROPERTIES
	isActive = true, --if item is active, then it has the same attributes as forbiddenTrade OR forbiddenDrop, additionally when item isactive and is used again it triggers 
		functions = {
			[functionName.."Stop"]  = {
				args,
			},
			[functionName.."Stop"]  = {
				args,
			},
			
		},
		instead of standard set of functions
	saveActiveInDatabase = boolean, -- if true then the item will rememember isActive property even after disconnect
}
]]
	[1] = {
		name = "Jabłko",
		description = "Świeże i zdrowe - od lokalnego rolnika.",
		iconPath = "ammo.png",
		category = "guns",
		isStackable = true,
		isLostOnUse = true,
		forbiddenTrade = true,
		functions = {
			["addHealth"]  = {
				3
			},
			["addFood"]  = {
				10
			},
		},
	},
	[2] = {
		name = "Gruszka",
		description = "Świeża i zdrowa - od lokalnego rolnika.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"]  = {
				3
			},
			["addFood"]  = {
				10
			},
		},
	},
	[3] = {
		name = "Banan",
		description = "Świeży i zdrowy - od lokalnego rolnika.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"]  = {
				3
			},
			["addFood"]  = {
				10
			},
		},
	},
	[4] = {
		name = "Marchewka",
		description = "Świeża i zdrowa - od lokalnego rolnika.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"]  = {
				3
			},
			["addFood"]  = {
				10
			},
		},
	},
	[5] = {
		name = "Porzeczka",
		description = "Świeża i zdrowa - od lokalnego rolnika.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"]  = {
				3
			},
			["addFood"]  = {
				10
			},
		},
	},
	[6] = {
		name = "Potrawka z chrząszcza",
		description = "Popisowe danie najlepszego kucharza w kolonii, Snafa.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"] = {
				100, 100
			},
			["addFood"] = {
				100	
			},
			["addWater"] = {
				100
			},
		},
	},
	[6] = {
		name = "Potrawka z chrząszcza",
		description = "Popisowe danie najlepszego kucharza w kolonii, Snafa.",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		functions = {
			["addHealth"] = {
				100, 100
			},
			["addFood"] = {
				100	
			},
			["addWater"] = {
				100
			},
		},
	},
	[7] = {
		name = "Colt 45",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 22,
	},
	[8] = {
		name = "Deagle",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 24,
	},
	[9] = {
		name = "Combat Shotgun",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 27,
	},
	[10] = {
		name = "Uzi",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 28,
	},
	[11] = {
		name = "MP5",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 29,
	},
	[12] = {
		name = "AK-47",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 30,
	},
	[13] = {
		name = "M4",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 31,
	},
	[14] = {
		name = "TEC-9",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 32,
	},
	[15] = {
		name = "Sniper",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 34,
	},
	[16] = {
		name = "Rifle",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 33,
	},
	[17] = {
		name = "Celownik kolimatorowy",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {
				["name"] = "aim",
				["args"] = 1,
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29,  31, 30, 33, 34},
	},
	[18] = {
		name = "Celownik ACOG",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {
				["name"] = "aim",
				["args"] = 2,
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29,  31, 30, 33, 34},
	},
	[19] = {
		name = "Tłumik",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {22, 24, 28, 29, 30, 31, 32, 33, 34},
	},
	[20] = {
		name = "Ciężka lufa",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29,  31, 30, 33},

	},
	[21] = {
		name = "Powiększony magazynek",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {22, 24, 28, 29, 30, 31, 32, 33, 34},
	},
	[22] = {
		name = "Chwyt pochylony",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29, 31, 30, 34},
	},
	[23] = {
		name = "Chwyt ERGO",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29, 31, 30, 33},

	},
	[24] = {
		name = "Kolba",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		allowedIN = {29, 31, 30, 25, 27},
	},
	[25] = {
		name = "Shotgun",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = {
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 25,
	},
	[26] = {
		name = "Laser",
		description = "",
		iconPath = "gunparts.png",
		category = "gunparts",
		functions = {
			["upgradeWeapon"]  = {},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
	},
	[27] = {
		name = "Marihuana",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"marihuana", 3
			}
		},
	},	
	[28] = {
		name = "Ecstasy",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"ecstasy", 3
			}
		},
	},		
	[29] = {
		name = "LSD",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"LSD", 3
			}
		},
	},
	[30] = {
		name = "Haszysz",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"haszysz", 3
			}
		},
	},
	[31] = {
		name = "Kokaina",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"kokaina", 10
			}
		},
	},
	[32] = {
		name = "Kodeina",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"kodeina", 10
			}
		},
	},
	[33] = {
		name = "Heroina",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"heroina", 10
			}
		},
	},		
	[34] = {
		name = "Opium",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"opium", 10
			}
		},
	},	
	[35] = {
		name = "Crack",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"crack", 10
			}
		},
	},
	[36] = {
		name = "Amfetamina",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"amfetamina", 10
			}
		},
	},
	[37] = {
		name = "Metamfetamina",
		description = "",
		iconPath = "drugs.png",
		category = "drugs",
		isStackable = true,
		functions = {
			["drug_effect"] = {
				"metaamfetamina", 10
			}
		},
	},
	[38] = {
		name = "Ubranie premium",
		description = "",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		--forbiddenTrade = true,
		--forbiddenDrop = true,
		functions = {
			["premiumSkinWear"] = {},
		},
		saveActiveInDatabase = true,
	},
	[39] = {
		name = "Dodatek do ubrania - głowa",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[40] = {
		name = "Dodatek do ubrania - szyja",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[41] = {
		name = "Dodatek do ubrania - kręgosłup",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[42] = {
		name = "Dodatek do ubrania - miednica",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[43] = {
		name = "Dodatek do ubrania - lewy obojczyk",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[44] = {
		name = "Dodatek do ubrania - prawy obojczyk",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[45] = {
		name = "Dodatek do ubrania - lewe ramię",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[46] = {
		name = "Dodatek do ubrania - prawe ramię",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[47] = {
		name = "Dodatek do ubrania - lewy łokieć",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[48] = {
		name = "Dodatek do ubrania - prawy łokieć",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[49] = {
		name = "Dodatek do ubrania - lewa ręka",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[50] = {
		name = "Dodatek do ubrania - prawa ręka",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[51] = {
		name = "Dodatek do ubrania - lewe biodro",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[52] = {
		name = "Dodatek do ubrania - prawe biodro",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[53] = {
		name = "Dodatek do ubrania - lewe kolano",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[54] = {
		name = "Dodatek do ubrania - prawe kolano",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[55] = {
		name = "Dodatek do ubrania - lewa kostka",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[56] = {
		name = "Dodatek do ubrania - prawa kostka",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[57] = {
		name = "Dodatek do ubrania - lewa stopa",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[58] = {
		name = "Dodatek do ubrania - prawa stopa",
		description = "Gracz bez konta premium może założyć 3 takie przedmioty, gracz bez konta premium może założyć 2.",
		iconPath = "clothes.png",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		forbiddenDrop = true,
		allowCustomization = true,
		exportedFunctionResource = "imta-wearable_objects",
		exportedFunctionName = "startModifyingWearableObject",
		functions = {
			["wearableObjectsWear"] = {},
		},
	},
	[59] = {
        name = "Obniżenie zawieszenia 90%",
        description = "Komponent gotowy do zainstalowania w Twoim pojeździe, przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "suspension",
        arguments = {-90}, -- obniżanie zawieszenia, + x% do obnizenia
    },
	[60] = {
        name = "Obniżenie zawieszenia 85%",
        description = "Komponent gotowy do zainstalowania w Twoim pojeździe, przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "suspension",
        arguments = {-85}, -- obniżanie zawieszenia, + x% do obnizenia
    },
	[61] = {
        name = "Obniżenie zawieszenia 80%",
        description = "Komponent gotowy do zainstalowania w Twoim pojeździe, przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "suspension",
        arguments = {-80}, -- obniżanie zawieszenia, + x% do obnizenia
    },
	[62] = {
        name = "Podniesienie zawieszenia 50%",
        description = "Komponent gotowy do zainstalowania w Twoim pojeździe, przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "suspension",
        arguments = {50}, -- obniżanie zawieszenia, + x% do obnizenia
    },
	[63] = {
        name = "Napęd AWD",
        description = "Kluczowy element dostosowujący Twój pojazd do napędu na wszystkie koła. Gotowe do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "drive",
        arguments = {AWD}, -- kind of drive (x in {"AWD", "RWD", "FWD"})
    },
	[64] = {
        name = "Napęd RWD",
        description = "Kluczowy element dostosowujący Twój pojazd do napędu na tylne koła. Gotowe do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "drive",
        arguments = {RWD}, -- kind of drive (x in {"AWD", "RWD", "FWD"})
    },
	[65] = {
        name = "Napęd FWD",
        description = "Kluczowy element dostosowujący Twój pojazd do napędu na przednie koła. Gotowe do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "drive",
        arguments = {FWD}, -- kind of drive (x in {"AWD", "RWD", "FWD"})
    },
	[66] = {
        name = "Filtr stożkowy",
        description = "Komponent o atrakcyjnej bryle. Gotowy do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "conical_filter",
        arguments = {5}, -- filtr stożkowy, + x% do accelaration
    },
	[67] = {
        name = "Metalowy układ dolotowy",
        description = "Duże pudło z jakimiś połyskującymi rurkami. Komponent do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "metal_intake_system",
        arguments = {5}, -- metalowy układ dolotowy, + x% do accelaration
    },
	[68] = {
        name = "Sportowy katalizator",
        description = "Komponent do zainstalowania przez wykwalifikowanego mechanika samochodowego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "sport_catalyst",
        arguments = {3}, -- sportowy katalizator, + x% do accelaration
    },
	[69] = {
        name = "Modyfikacja silnika, poz.1",
        description = "Komponent tuningowy.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "mod_engine",
        arguments = {10, 1, 1}, -- {x, y, number levelOfMod}, -- + x% do accelaration oraz + y$ do velocity
    },
	[70] = {
        name = "Nielegalna modyfikacja silnika",
        description = "Komponent wyglądający luksusowo. Nieobeznana osoba nie wie do czego to służy.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "mod_engine",
        arguments = {25, 25, 1}, -- {x, y, number levelOfMod}, -- + x% do accelaration oraz + y$ do velocity
    },
	[71] = {
        name = "Modyfikacja silnika, poz.2",
        description = "Komponent tuningowy.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "mod_engine",
        arguments = {12, 6, 1}, -- {x, y, number levelOfMod}, -- + x% do accelaration oraz + y$ do velocity
    },
	[72] = {
        name = "Modyfikacja silnika, poz.3",
        description = "Komponent tuningowy.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "mod_engine",
        arguments = {15, 12, 1}, -- {x, y, number levelOfMod}, -- + x% do accelaration oraz + y$ do velocity
    },
	[73] = {
        name = "Niestandardowe ECU",
        description = "Czip modyfikujący parametry silnika. Wykwalifikowany mechanik jest zdolny zainstalować ten komponent.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "ECU",
        arguments = {15}, -- + x% do accelaration
    },
	[74] = {
        name = "Turbosprężarka",
        description = "Ładny, błyszczący przedmiot o kształcie ogromnego ślimaka. Liczne mocowania na śruby na całej powierzchni",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "turbocharger",
        arguments = {30, false}, -- + x% do accelaration
    },
	[75] = {
        name = "Podwójna turbosprężarka",
        description = "Ładny, błyszczący przedmiot o kształcie ogromnych, dwóch ślimaków złączonych ze sobą. ",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "turbocharger",
        arguments = {x, true}, -- + x% do accelaration
    },
	[76] = {
        name = "Sportowy układ wydechowy",
        description = "Duże pudło z metalowymi elementami wewnątrz niego.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "sport_exhaust",
        arguments = {10}, -- + x% do accelaration
    },
	[77] = {
        name = "Drifterskie opony",
        description = "Opony.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "drift_tires",
        arguments = {3, 10},-- + x% do accelaration, +- y% do tractionLoss
    },
	[78] = {
        name = "Sportowe opony",
        description = "Opony.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "sport_tires",
        arguments = {3, -10},-- + x% do accelaration, +- y% do tractionLoss
    },
	[79] = {
        name = "Nawiercane tarcze hamulcowe",
        description = "Okrągła, wypukła z dziurą na środku tarcza hamulcowa. Po stronie obwodowej dużo małych dziurek, natomiast na wypukłej jego części siedem, nierównomiernie przewierconych większych dziur.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "brake_discs",
        arguments = {5}, -- + x% do siły hamowania
    },
	[80] = {
        name = "Ceramiczne tarcze hamulcowe",
        description = "Dwuwarstwowa, okrągła tarcza hamulcowa w kolorze wyblakłego matu na jej obwodowej stronie. Na środku wypukła, lakierowana część w kształcie ściętego stożka.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "brake_discs",
        arguments = {10}, -- + x% do siły hamowania
    },
	[81] = {
        name = "Poszerzanie opon, poz. 1",
        description = "Paczka z jakimiś elementami wewnątrz.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "bigger_tires",
        arguments = {1}, -- x in {1,2}
    },
	[82] = {
        name = "Poszerzanie opon, poz. 2",
        description = "Paczka z jakimiś elementami wewnątrz.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "handling",
        part = "bigger_tires",
        arguments = {2}, -- x in {1,2}
    },
	[83] = {
        name = "Kamera",
        description = "Specjalny sprzęt, wyglądający dosyć masywnie.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "camera",
        arguments = {true}
    },
	[84] = {
        name = "Wideorejestrator",
        description = "Pudełko ze sprzęcikiem.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "DVR",
        arguments = {true}
    },
	[85] = {
        name = "Sprzęt do przyciemnienia szyb",
        description = "Pudełko ze sprzęcikiem.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "black_window_all",
        arguments = {true}
    },
	[86] = {
        name = "Zestaw Lambo Doors",
        description = "Masywne pudło.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "up_door",
        arguments = {true}
    },
	[87] = {
        name = "Światła o barwie 3000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {254,238,102} -- feee66
    },
	[88] = {
        name = "Światła o barwie 4500k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {178,183,167} -- b2b7a7
    },
	[89] = {
        name = "Światła o barwie 5000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {205,205,205} -- cdcdcd
    },
	[90] = {
        name = "Światła o barwie 6000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {195,204,211} -- c3ccd3
    },
	[91] = {
        name = "Światła o barwie 8000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {151,187,235} -- 97bbeb
    },
	[92] = {
        name = "Światła o barwie 10000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {88,144,203} -- 5890cb
    },
	[93] = {
        name = "Światła o barwie 12000k",
        description = "Pudło z żarówkami do Twojego auta.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "light_color",
        arguments = {22,111,241} -- 166ff1
    },
	[94] = {
        name = "Kuloodporne szyby",
        description = "",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "bulletproof_glass",
        arguments = {true},
    },
	[95] = {
        name = "Alarm samochodowy",
        description = "",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "alarm",
        arguments = {true},
    },
	[96] = {
        name = "Samochodowy zestaw audio",
        description = "Zawiera komplet głośników oraz tubę",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "audio",
        arguments = {true},
    },
	[97] = {
        name = "Anti-lag System",
        description = "",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "anti_lag",
        arguments = {true},
    },
	[98] = {
        name = "Tempomat",
        description = "Paczka, dosyć cięzka.",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "visual",
        part = "cruise_control",
        arguments = {true},
    },
	[99] = {
        name = "System wtrysku podtlenka azotu poz.1",
        description = "",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "oryginal_parts",
        part = "nitro",
        arguments = {true, 1, 50},
    },
	[100] = {
        name = "System wtrysku podtlenka azotu poz.2",
        description = "",
        iconPath = "carparts.png",
        category = "vehicle_components",
        isStackable = false,
        functions = {
        },
        partCategory = "oryginal_parts",
        part = "nitro",
        arguments = {true, 2, 75},
    },
	[101] = {
		name = "Smartfon",
		description = "",
		iconPath = "phone.png",
		category = "electronics",
		saveActiveInDatabase = true,
		isStackable = false,
		--forbiddenTrade = true,
		--forbiddenDrop = true,
		allowCustomization = false,
		functions = {
			["phoneUse"] = {},
		},
	},
	[102] = {
		name = "Boombox",
		description = "",
		iconPath = "phone.png",
		category = "electronics",
		isStackable = false,
		forbiddenTrade = true,
		--forbiddenDrop = true,
		allowCustomization = false,
		functions = {
			["boombox"] = {},
		},
	},
	[103] = {
		name = "Kominiarka",
		description = "",
		iconPath = "",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = true,
		--forbiddenDrop = true,
		allowCustomization = false,
		functions = {
			["balaclave"] = {},
		},
	},
	[104] = {
		name = "Pozwolenie na broń",
		description = "",
		iconPath = "",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = false,
		forbiddenDrop = false,
		functions = {},
	},
	[105] = {
		name = "Dowód osobisty",
		description = "",
		iconPath = "",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = false,
		forbiddenDrop = false,
		functions = {},
	},
	[106] = {
		name = "Prawo jazdy",
		description = "",
		iconPath = "",
		category = "clothes",
		isStackable = false,
		forbiddenTrade = false,
		forbiddenDrop = false,
		functions = {},
	},
	[107] = {
		name = "Jedzenie zdrowe",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 2,
		functions = {
			["addHealth"]  = {
				3
			},
			["addMaxHealth"] = {},
		},
	},
	[108] = {
		name = "Jedzenie niezdrowe",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 2,
		functions = {
			["addHealth"]  = {
				3
			},
			["takeMaxHealth"] = {},
		},
	},
	[109] = {
		name = "Zapiekanka",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 5,
		functions = {
			["addHealth"]  = {
				20
			},
			["takeMaxHealth"] = {},
		},
	},
	[110] = {
		name = "Hot-dog",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 2,
		functions = {
			["addHealth"]  = {
				10
			},
			["takeMaxHealth"] = {},
		},
	},
	[111] = {
		name = "Hamburger",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 8,
		functions = {
			["addHealth"]  = {
				32
			},
			["takeMaxHealth"] = {},
		},
	},
	[112] = {
		name = "Chicken Burger",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				40
			},
			["takeMaxHealth"] = {},
		},
	},
	[113] = {
		name = "Pączek",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 2,
		functions = {
			["addHealth"]  = {
				6
			},
			["takeMaxHealth"] = {},
		},
	},
	[114] = {
		name = "Pizza",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 5,
		functions = {
			["addHealth"]  = {
				20
			},
			["takeMaxHealth"] = {},
		},
	},
	[115] = {
		name = "Taco",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 9,
		functions = {
			["addHealth"]  = {
				36
			},
			["takeMaxHealth"] = {},
		},
	},
	[116] = {
		name = "Hot Wings",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				40
			},
			["takeMaxHealth"] = {},
		},
	},
	[117] = {
		name = "Strips",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				40
			},
			["takeMaxHealth"] = {},
		},
	},
	[118] = {
		name = "Burrito",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				42
			},
			["takeMaxHealth"] = {},
		},
	},
	[119] = {
		name = "Lody na patyku",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 3,
		functions = {
			["addHealth"]  = {
				9
			},
			["takeMaxHealth"] = {},
		},
	},
	[120] = {
		name = "Tortilla",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 9,
		functions = {
			["addHealth"]  = {
				36
			},
			["takeMaxHealth"] = {},
		},
	},
	[121] = {
		name = "Wrap",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				40
			},
			["takeMaxHealth"] = {},
		},
	},
	[122] = {
		name = "Brownie z lodami",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 5,
		functions = {
			["addHealth"]  = {
				20
			},
			["takeMaxHealth"] = {},
		},
	},
	[123] = {
		name = "Curry z ryżem",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				45
			},
		},	
	},
	[124] = {
		name = "Kurczak BBQ",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 12,
		functions = {
			["addHealth"]  = {
				36
			},
		},	
	},
	[125] = {
		name = "Chilli Con Carne",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 11,
		functions = {
			["addHealth"]  = {
				33
			},
		},	
	},
	[126] = {
		name = "Lazania",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 10,
		functions = {
			["addHealth"]  = {
				30
			},
		},	
	},
	[127] = {
		name = "Tiramisu",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 9,
		functions = {
			["addHealth"]  = {
				27
			},
		},	
	},
	[128] = {
		name = "Sernik",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 6,
		functions = {
			["addHealth"]  = {
				18
			},
		},	
	},
	[129] = {
		name = "Szarlotka",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 5,
		functions = {
			["addHealth"]  = {
				15
			},
		},	
	},
	[130] = {
		name = "Spaghetti",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 12,
		functions = {
			["addHealth"]  = {
				36
			},
		},
	},
	[131] = {
		name = "Stek",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 25,
		functions = {
			["addHealth"]  = {
				75
			},
		},
	},
	[132] = {
		name = "Kurczak tikka masala",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 17,
		functions = {
			["addHealth"]  = {
				51
			},
		},
	},
	[133] = {
		name = "Pieczone ziemniaki",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 25,
		functions = {
			["addHealth"]  = {
				20
			},
			["addMaxHealth"] = {},
		},
	},
	[134] = {
		name = "Vege hamburger",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[135] = {
		name = "Sałatka cesar",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[136] = {
		name = "Sałatka owocowa",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[137] = {
		name = "Kanapka z indykiem",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[138] = {
		name = "Kanapka z kurczakiem",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[139] = {
		name = "Kanapka z łososiem",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 15,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[140] = {
		name = "Pizza wegetariańska",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 40,
		functions = {
			["addHealth"]  = {
				30
			},
			["addMaxHealth"] = {},
		},
	},
	[141] = {
		name = "Makaron ze szpinakiem",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 35,
		functions = {
			["addHealth"]  = {
				30
			},
			["addMaxHealth"] = {},
		},
	},
	[142] = {
		name = "Koktajl owocowy",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 20,
		functions = {
			["addHealth"]  = {
				10
			},
			["addMaxHealth"] = {},
		},
	},
	[137] = {
		name = "Granola",
		description = "",
		iconPath = "food.png",
		category = "food",
		isStackable = true,
		isLostOnUse = true,
		isCanBroke = true,
		cost = 25,
		functions = {
			["addHealth"]  = {
				20
			},
			["addMaxHealth"] = {},
		},
	},
	[138] = {
		name = "Paralizator",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["chooseWeapon"]  = { 
				flag = 64, -- permisja by wyciągnąć
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
		weaponID = 23,
	},
	[139] = {
		name = "Kamizelka",
		description = "",
		iconPath = "guns.png",
		category = "guns",
		functions = {
			["wearArmor"]  = { 
				flag = 65, -- permisja by wyciągnąć
			},
		},
		forbiddenTrade = false,
		forbiddenDrop = false,
	},
}

function getItemData(id)
	return table.copy(ITEMS.def[id])
end

