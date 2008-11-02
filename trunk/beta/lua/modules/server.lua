//This module houses all the things like welcome messages etc.

//Welcome message
function WelcomeMessage( ply )
	SendNotify( ply, "Welcome to " .. GetGlobalString("ServerName") .. "!", "NOTIFY_GENERIC" )
	SendNotify( ply, "Type !listcommands to get an overview of the commands!", "NOTIFY_GENERIC" )
	ply:PrintMessage( HUD_PRINTTALK, "Type !listcommands to get an overview of the commands!" )
end
hook.Add( "PlayerInitialSpawn", "WelcomeHook", WelcomeMessage )

//Reload map
function ReloadMap( ply, params )
	RunConsoleCommand( "changelevel", game.GetMap() )
end
AddCommand( "ReloadMap", "Reloads the map", "reloadmap", "reloadmap", ReloadMap, 2, "Overv", 3)

//Cleanup everything
function FullCleanup( ply, params )
	//Clean up
	for k, v in pairs(ents.FindByClass("prop_*")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("npc_*")) do v:Remove() end
	
	for k, v in pairs(player.GetAll()) do
		SendNotify( v, ply:Nick() .. " has cleaned up the map", "NOTIFY_CLEANUP" )
	end
end
AddCommand( "Cleanup", "Removes every entity in the map", "cleanup", "cleanup", FullCleanup, 2, "Overv", 3)

//Message
function Message( ply, params )
	if tonumber(params[1]) ~= nil and params[2] ~= nil then
		//Type
		if tonumber(params[1]) > 4 or tonumber(params[1]) < 1 then
			mtype = 1
		else
			mtype = tonumber(params[1])
		end
		
		local collect = ""
		for k, v in pairs(params) do
			if k > 1 then collect = collect .. v .. " " end
		end
		
		for k, v in pairs(player.GetAll()) do
			if mtype == 1 then
				SendNotify( v, collect )
			elseif mtype == 2 then
				v:PrintMessage( HUD_PRINTTALK, collect )
			elseif mtype == 3 then
				v:PrintMessage( HUD_PRINTCENTER, collect )
			end
		end
	end
end
AddCommand( "Message", "This command allows admins to send a message to all players (type 1 = Notification, 2 = Chat, 3 = Center)", "message", "message <type> <message>", Message, 2, "Overv", 3)