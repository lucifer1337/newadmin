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

//List commands in console
function ListCommands( ply, params )
	if SERVER then
		ply:SendLua("ListCommands(nil, nil)")
		Notify( "All the commands have been printed out in the console.", "NOTIFY_GENERIC", ply )
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
				elseif v.Flag == 2 then
					ReqFlag = "SA"
				elseif v.Flag == 3 then
					ReqFlag = "O"
				else
					RegFlaq = "*"
				end
				
				Msg("	!" .. v.Usage .. " - " .. v.Description .. " (" .. ReqFlag .. ")\n")
			end
		end
		
		if first == false then Msg("\n") end
	end
end
RegisterCommand( "List Commands", "List all the commands in the console", "commands", "commands", 0, "Overv", 8, 0, ListCommands )

//NewAdmin version
function Info( ply, params )
	Notify( "This server is running NewAdmin 1.0 R66", "NOTIFY_GENERIC", ply )
end
RegisterCommand( "Info", "Shows info about NewAdmin, such as the version running", "info", "info", 0, "Overv", 8, 0, Info )