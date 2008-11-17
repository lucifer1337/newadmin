//This module holds functions like setting the group of a player
usergroups = {}
function LoadGroups()
	if file.Exists("NewAdmin/groups.txt") then
		local entries = string.Explode("\n", file.Read("NewAdmin/groups.txt"))
		
		for k, v in pairs(entries) do
			if v ~= "" then
				local params = string.Explode( " -> ", v )
				local item = {}
				item.SteamID = params[1]
				item.Flags = string.sub(params[2], 4)
				
				table.insert( usergroups, item )
			end
		end
	else
		ConsoleMsg("No group file found!")
	end
	
	ConsoleMsg("Loaded " .. table.Count(usergroups) .. " group entries!")
end
LoadGroups()

function SaveGroups()
	local ftext = ""
	for _, v in pairs(usergroups) do
		ftext = ftext .. v.SteamID .. " -> " .. v.Flags .. "\n"
	end
	ftext = ftext .. "\n"
	
	file.Write( "NewAdmin/groups.txt", ftext )
end

function Entry( SteamID, Flags )
	local found = false
	local id = 0
	
	for k, v in pairs(usergroups) do
		if v.SteamID == SteamID then
			found = true
			id = k
		end
	end
	
	if found then
		usergroups[id].Flags = Flags
	else
		local entr = {}
		entr.SteamID = SteamID
		entr.Flags = Flags
		
		table.insert( usergroups, entr )
	end
	
	SaveGroups()
end

function SetFlags( ply, params )
	if params[1] ~= nil and params[2] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			//Translate flags
			if params[2] == "0" then
				trans = "User"
				pl:SetUserGroup("unknown")
			elseif params[2] == "1" then
				trans = "Administrator"
				pl:SetUserGroup("admin")
			elseif params[2] == "2" then
				trans = "Super Administrator"
				pl:SetUserGroup("superadmin")
			else
				SendNotify( ply, "Unknown flag: " .. params[2])
				return 
			end
			
			Entry( pl:SteamID(), params[2] )
			NotifyAll( pl:Nick() .. " is now in the " .. trans .. " group!", "NOTIFY_UNDO" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Set Flags", "Set the flags of someone. (0 = player, 1 = A, 2 = SA, 3 = temp A, 4 = temp SA)", "setflags", "setflags <name> <flags>", SetFlags, 2, "Overv", 7)

//Console command to set someone's flags
function SetFlags2( ply, command, params )
	local pl = GetPlayerByPart( params[1] )
	
	if pl ~= nil then
		//Translate flags
		if params[2] == "0" then
			trans = "User"
			pl:SetUserGroup("unknown")
		elseif params[2] == "1" then
			trans = "Administrator"
			pl:SetUserGroup("admin")
		elseif params[2] == "2" then
			trans = "Super Administrator"
			pl:SetUserGroup("superadmin")
		elseif params[2] == "3" then
			trans = "Temporary Administrator"
			pl:SetUserGroup("admin")
		elseif params[2] == "4" then
			trans = "Temporary Super Administrator"
			pl:SetUserGroup("superadmin")
		else
			ConsoleMsg( "Unknown flag: " .. params[2])
			return 
		end
		
		if tonumber(params[2]) < 3 then
			Entry( pl:SteamID(), params[2] )
		end
		
		NotifyAll( pl:Nick() .. " is now in the " .. trans .. " group!", "NOTIFY_UNDO" )
		ConsoleMsg( pl:Nick() .. " is now in the " .. trans .. " group" )
	else
		ConsoleMsg( "Player '" .. params[1] .. "' not found!")
	end
end
if SERVER then concommand.Add( "SetFlags", SetFlags2 ) end

//Override someone's group on spawn
function UpdateGroup( ply )
	for _, v in pairs(usergroups) do
		ConsoleMsg("Comparing '" .. v.SteamID .. " and " .. ply:SteamID() )
		if v.SteamID == ply:SteamID() then
			if v.Flags == "0" then
				ply:SetUserGroup("unknown")
				ConsoleMsg("Set '" .. ply:Nick() .. "' to the group 'Users'")
			elseif v.Flags == "1" then
				ply:SetUserGroup("admin")
				ConsoleMsg("Set '" .. ply:Nick() .. "' to the group 'Administrators'")
			elseif v.Flags == "2" then
				ply:SetUserGroup("superadmin")
				ConsoleMsg("Set '" .. ply:Nick() .. "' to the group 'Super Administrators'")
			end
			ConsoleMsg("Unknown group found for '" .. ply:Nick() .. "' (" .. v.Flags .. ")")
			
			return
		end
	end
	
	ConsoleMsg("No group entry found for '" .. ply:Nick() .. "'")
end
hook.Add( "PlayerInitialSpawn", "UpdateGroup", UpdateGroup )