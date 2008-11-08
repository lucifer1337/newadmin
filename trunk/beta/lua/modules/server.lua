//This module houses all the things like welcome messages etc.

//Welcome message
function WelcomeMessage( ply )
	SendNotify( ply, "Welcome to " .. GetGlobalString("ServerName") .. "!", "NOTIFY_GENERIC" )
	SendNotify( ply, "Type " .. ComPrefix .. "listcommands to get an overview of the commands!", "NOTIFY_GENERIC" )
	ply:PrintMessage( HUD_PRINTTALK, "Type " .. ComPrefix .. "listcommands to get an overview of the commands!" )
end
hook.Add( "PlayerInitialSpawn", "WelcomeHook", WelcomeMessage )

//Reload map
function ReloadMap( ply, params )
	RunConsoleCommand( "changelevel", game.GetMap() )
end
AddCommand( "ReloadMap", "Reloads the map", "reload", "reload", ReloadMap, 2, "Overv", 4)

//Cleanup everything
function FullCleanup( ply, params )
	//Clean up
	for k, v in pairs(ents.FindByClass("prop_*")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("npc_*")) do v:Remove() end
	
	NotifyAll( ply:Nick() .. " has cleaned up the map", "NOTIFY_CLEANUP" )
end
AddCommand( "Cleanup", "Removes every entity in the map", "cleanup", "cleanup", FullCleanup, 2, "Overv", 4)

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
AddCommand( "Message", "This command allows admins to send a message to all players (type 1 = Notification, 2 = Chat, 3 = Center)", "message", "message <type> <message>", Message, 2, "Overv", 4)

local maps = {}

//List maps on server
function ListMaps( ply, params )
	//Populate maps table if it isn't yet
	if maps[1] == nil then maps = file.Find("../maps/*.bsp") end
	
	if ply:GetNetworkedBool("ReceivedMaps") ~= true then
		for _, v in pairs(maps) do
			ply:SendLua( "AddMap(\"" .. string.Left( v, string.len(v) - 4) .. "\")" )
		end
	end
	ply:SendLua("ListMaps()")
	
	//Inform player
	SendNotify( ply, "All the maps on the server have been printed to the console" )
end
AddCommand( "Maps", "Prints out all the maps on the server to the console", "maps", "maps", ListMaps, 0, "Overv", 4)

//Clientside map list receiving
function AddMap( mapname )
	table.insert( maps, mapname )
	Msg( mapname .. "\n" )
end

//Go to other map
function ChangeMap( ply, params )
	if params[1] ~= nil then
		RunConsoleCommand("changelevel", params[1])
	end
end
AddCommand( "Map", "Use this command to change the map", "map", "map <mapname>", ChangeMap, 2, "Overv", 4)

//Show maps
function ListMaps()
	Msg("\n=== Maps on this server ===\n\n")
	
	for k, v in pairs(maps) do
		Msg(v .. "\n")
	end
	
	Msg("\n")
end

//Logging
function LogJoin( ply )
	ply:SetNetworkedInt( "JoinTime", os.time() )
	AddLog( ply:Nick() .. " (" .. ply:SteamID() .. ") has spawned for the first time (Succesful join)" )
end
function LogLeave( ply )
	AddLog( ply:Nick() .. " (" .. ply:SteamID() .. ") has left the server" )
end
hook.Add("PlayerInitialSpawn", "LogJoin", LogJoin)
hook.Add("PlayerDisconnected", "LogLeave", LogLeave)