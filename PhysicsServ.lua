local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")
local modul = {}

local function doMath(index)
	return -(2^(index-1))
end


local function FindCollisionGroup(CollisionGroup)
	pcall(function()
		for i,v in pairs(gethiddenproperty(Workspace, "CollisionGroups"):split("\\")) do
			local split = v:split("^")
			if split[1] == CollisionGroup then
				return v
			end
		end
		return false
	end)
end

local function EditCollisionGroup(Name,arg1,arg2,arg3)
	local str = ""
	local args = {arg1,arg2,arg3}

	for i,v in pairs(gethiddenproperty(Workspace, "CollisionGroups"):split("\\")) do
		local split = v:split("^")
		if split[1] == Name  then
			for i,v in pairs(args) do
				if not v then
					args[i] = split[i]
				end
			end
			str = str..string.format("%s%s^%s^%s",((i == 1 and "" ) or "\\") ,args[1], args[2], args[3])
		else	
			str = str..string.format("%s%s^%s^%s",((i == 1 and "" ) or "\\") ,split[1], split[2], split[3])
		end
	end

	sethiddenproperty(Workspace, "CollisionGroups", str)
end


local function CreateCollisionGroup(Name)
	assert(FindCollisionGroup(Name) == false, "Could not create collision group, one with that name already exists.")
	sethiddenproperty(Workspace, "CollisionGroups", string.format("%s\\%s^%s^%s", gethiddenproperty(Workspace, "CollisionGroups"),Name,tonumber(#PhysicsService:GetCollisionGroups()), "-1" ))
	return true	
end

local function CollisionGroupSetCollidable(Name1,Name2,Boolean)
	assert(typeof(Name1) == "string", string.format("Bad argument #1 to '?' (string expected, got %s)", typeof(Name1)))
	assert(typeof(Name2) == "string", string.format("Bad argument #2 to '?' (string expected, got %s)", typeof(Name1)))
	assert(typeof(Boolean) == "boolean", string.format("Bad argument #3 to '?' (boolean expected, got %s)", typeof(Name1)))
	assert(FindCollisionGroup(Name1) ~= false, "Both collision groups must be valid.")
	assert(FindCollisionGroup(Name2) ~= false, "Both collision groups must be valid.")
	local CollisionGroup1 = FindCollisionGroup(Name1)
	local CollisionGroup2 = FindCollisionGroup(Name2)
	local split1 = CollisionGroup1:split("^")
	local split2 = CollisionGroup2:split("^")
	if Boolean == false then
		if PhysicsService:CollisionGroupsAreCollidable(Name1, Name2) == true then
			if Name1 == Name2 then
				EditCollisionGroup(split1[1], false, false , (tonumber(split1[3])) + doMath(tonumber(split1[2]+1)))
			elseif Name1 ~= Name2 then
				EditCollisionGroup(split1[1], false, false , (tonumber(split1[3])) + doMath(tonumber(split2[2]+1)))
				EditCollisionGroup(split2[1], false, false , (tonumber(split2[3])) + doMath(tonumber(split1[2]+1)))
			end
		end
	elseif Boolean == true then
		if PhysicsService:CollisionGroupsAreCollidable(Name1, Name2) == false then
			if Name1 == Name2 then
				EditCollisionGroup(split1[1], false, false , (tonumber(split1[3])) - doMath(tonumber(split1[2]+1)))
			elseif Name1 ~= Name2 then
				EditCollisionGroup(split1[1], false, false , (tonumber(split1[3])) - doMath(tonumber(split2[2]+1)))
				EditCollisionGroup(split2[1], false, false , (tonumber(split2[3])) - doMath(tonumber(split1[2]+1)))
			end
		end
	end
end



local function RemoveCollisionGroup(CollisionGroup)
	string.gsub(gethiddenproperty(Workspace, "CollisionGroups"),"([%w%p]*)("..CollisionGroup.."%^%d+%^%-%d+)([%w%p]*)",function(arg1,arg2,arg3)

		local new = ""
		for index, value in pairs(string.split(arg3,"\\")) do
			new = new.."\\"..string.gsub(value,"(%w+%^)(%d+)(%^%-%d+)",function(arg1,arg2,arg3)  return arg1..math.floor(tonumber(arg2)-1)..arg3 end)

		end
		if new:sub(1,1) == "\\" then  new = new:sub(2,new:len()) end
		local toReturn = arg1..new
		if toReturn:sub(toReturn:len(),toReturn:len()) == "\\" then toReturn = toReturn:sub(1,toReturn:len()-1) end

		sethiddenproperty(Workspace, "CollisionGroups", toReturn)
	end)
end

local function RenameCollisionGroup(CollisionGroup,newName)
	assert(typeof(CollisionGroup) == "string", string.format("Bad argument #1 to '?' (string expected, got %s)", typeof(CollisionGroup)))
	assert(typeof(newName) == "string", string.format("Bad argument #1 to '?' (string expected, got %s)", typeof(newName)))
	assert(FindCollisionGroup(CollisionGroup) ~= false, "Cannot find the collision group")
	assert(FindCollisionGroup(newName) == false, "This collision group already exists!")
	string.gsub(gethiddenproperty(Workspace, "CollisionGroups"),"([%w%p]*)("..CollisionGroup.."%^%d+%^%-%d+)([%w%p]*)",function(arg1,arg2,arg3)
		local split = FindCollisionGroup(CollisionGroup):split("^")
		local str = newName.."^"..split[2].."^"..split[3]
		sethiddenproperty(Workspace, "CollisionGroups", arg1..str..arg3)
	end)
end

function modul:FindCollisionGroup(CollisionGroup) return FindCollisionGroup(CollisionGroup); end
function modul:EditCollisionGroup(Name,arg1,arg2,arg3) return EditCollisionGroup(Name,arg1,arg2,arg3); end
function modul:CreateCollisionGroup(Name) return CreateCollisionGroup(Name); end
function modul:CollisionGroupSetCollidable(Name1,Name2,Boolean) return CollisionGroupSetCollidable(Name1,Name2,Boolean); end
function modul:RemoveCollisionGroup(CollisionGroup) return RemoveCollisionGroup(CollisionGroup); end
function modul:RenameCollisionGroup(CollisionGroup,newName) return RenameCollisionGroup(CollisionGroup,newName); end


return modul
