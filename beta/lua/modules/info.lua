//This module is for NewAdmin functions like table of commands and version

function GetCatName( id )
	if id == 1 then
		return "Administration"
	elseif id == 2 then
		return "Player Actions"
	elseif id == 3 then
		return "Punishment"
	elseif id == 4 then
		return "Server Management"
	elseif id == 5 then
		return "Teleporting"
	elseif id == 6 then
		return "Chat"
	elseif id == 7 then
		return "User Groups"
	elseif id == 8 then
		return "Other"
	end
end

function ListCommands( ply, params )
	if SERVER then
		ply:SendLua("ListCommands(nil, nil)")
		SendNotify( ply, "All the commands have been printed out in the console.")
		return 
	end

	Msg("\n=== NewAdmin command list ===\n\n")
	for c = 1, 8 do
		local first = true
	
		for k, v in pairs(Commands) do
			if v.CategoryID == c then
				if first == true then
					Msg("o " .. GetCatName(c) .. "\n\n")
					first = false
				end
			
				if v.Flag == 0 then
					ReqFlag = "*"
				elseif v.Flag == 1 then
					ReqFlag = "A"
				else
					ReqFlag = "SA"
				end
				
				Msg("	" .. ComPrefix .. v.Usage .. " - " .. v.Description .. " (" .. ReqFlag .. ")\n")
			end
		end
		
		if first == false then Msg("\n") end
	end
end
AddCommand( "List Commands", "List all the commands in the console", "commands", "commands", ListCommands, 0, "Overv", 8)

//NewAdmin version
function Info( ply, params )
	SendNotify( ply, "This server is running NewAdmin " .. Version )
end
AddCommand( "Info", "Shows info about NewAdmin, such as the version running", "info", "info", Info, 0, "Overv", 8)