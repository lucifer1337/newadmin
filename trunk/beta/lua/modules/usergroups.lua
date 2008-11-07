//This module holds functions like setting the group of a player

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
			
			NotifyAll( pl:Nick() .. " is now in the " .. trans .. " group!", "NOTIFY_UNDO" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Set Flags", "Set the flags of someone. (0 = player, 1 = admin, 2 = super admin)", "setflags", "setflags <name> <flags>", SetFlags, 2, "Overv", 7)