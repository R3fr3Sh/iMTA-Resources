local function size( t )
	if type( t ) ~= 'table' then
		return false 
	end
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end
		
function table.compare(a1, a2)
	if type( a1 ) == 'table' and type( a2 ) == 'table' then
	
		if size( a1 ) == 0 and size( a2 ) == 0 then
			return true
		elseif size( a1 ) ~= size( a2 ) then
			return false
		end
		
		for _, v in pairs( a1 ) do
			local v2 = a2[ _ ]
			if type( v ) == type( v2 ) then
				if type( v ) == 'table' and type( v2 ) == 'table' then
					if size( v ) ~= size( v2 ) then
						return false
					end
					if size( v ) > 0 and size( v2 ) > 0 then
						if not table.compare( v, v2 ) then 
							return false
						end
					end	
				elseif type(v) == 'boolean' or type(v) == 'string' or type(v) == 'number' and type(v2) == 'boolean' or type(v2) == 'string' or type(v2) == 'number'then
					if v ~= v2 then
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end
		return true
	end
	return false
end

function table.copy(tab, recursive)
	local ret = {}
	for key, value in pairs(tab) do
		if (type(value) == "table") and recursive then 
			ret[key] = table.copy(value)
		else 
			ret[key] = value 
		end
	end
	return ret
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function getItemName(itemID, coreProperties)
	if coreProperties and coreProperties.name then 
		return coreProperties.name
	else
		return ITEMS.def[itemID].name
	end
end

function isFoodBroke(item)
	if item.isCanBroke and item.coreProperties and item.coreProperties.date then
		local date = item.coreProperties.date
		local time = getRealTime()
		local result = exports["imta-db_server"]:query("SELECT '?-?-? ?:?:?'>DATE_ADD('?-?-? ?:?:?', INTERVAL 12 HOUR) as broke", time.year, time.month, time.monthday, time.hour,time.minute, time.second, date.year, date.month, date.monthday, date.hour,date.minute, date.second)
		if result.broke == 1 then
			return true
		end
		return false
	end
	return false
end
