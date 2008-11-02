function Me( ply, params )
	if params[1] ~= nil then
		local collect = ""
		for k, v in pairs(params) do
			collect = collect .. v .. " "
		end
		
		for k, v in pairs(player.GetAll()) do
			v:PrintMessage( HUD_PRINTTALK, ply:Nick() .. " " .. collect )
		end
	end
end
AddCommand( "Me", "This chat command displays an action", "me", "me <message>", Me, 0, "Overv", 5)