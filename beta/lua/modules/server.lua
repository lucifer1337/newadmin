//This module houses all the things like welcome messages etc.

//Welcome message
function WelcomeMessage( ply )
	SendNotify( ply, "Welcome to " .. GetGlobalString("ServerName") .. "!", "NOTIFY_GENERIC" )
	SendNotify( ply, "Type " .. ComPrefix .. "listcommands to get an overview of the commands!", "NOTIFY_GENERIC" )
	ply:PrintMessage( HUD_PRINTTALK, "Type " .. ComPrefix .. "commands to get an overview of the commands!" )
end
hook.Add( "PlayerInitialSpawn", "WelcomeHook", WelcomeMessage )

//Reload map
function ReloadMap( ply, params )
	RunConsoleCommand( "changelevel", game.GetMap() )
end
AddCommand( "ReloadMap", "Reloads the map", "reload", "reload", ReloadMap, 2, "Overv", 4)

//Cleanup everything
//When the first player spawns it will save all the entities that are in the map by default, eg the player spawns. Those should not be removed ofcourse!
local defaultents = {}

function AddEnts()
	if defaultents[1] == nil then
		for k, v in pairs(ents.GetAll()) do
			table.insert( defaultents, v )
		end
		
		ConsoleMsg("Added " .. table.Count(defaultents) .. " default entities!")
	end
end
if SERVER then hook.Add("PlayerInitialSpawn", "AddEnts", AddEnts) end

function FullCleanup( ply, params )
	//Clean up
	for k, v in pairs(ents.GetAll()) do
		if v:IsPlayer() == false and table.HasValue( defaultents, v ) == false and v:IsWeapon() == false and v:GetClass() ~= "predicted_viewmodel" then
			v:Remove()
		end
	end
	
	NotifyAll( ply:Nick() .. " has cleaned up the map", "NOTIFY_CLEANUP" )
end
AddCommand( "Cleanup", "Removes every entity in the map", "cleanup", "cleanup", FullCleanup, 2, "Overv", 4)

//Debug function
function Debug( ply, params )
	for k, v in pairs(ents.GetAll()) do
		if ply:GetShootPos():Distance(v:GetPos()) < 512 then
			ply:PrintMessage( HUD_PRINTTALK, v:GetClass() .. "\n")
		end
	end
end
AddCommand( "Debug", "Debug function: Testing what entities to not remove", "debug", "debug", Debug, 2, "Overv", 4)

//Remove displacements
function RemoveDecals( ply, params )
	//Clean up
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("r_cleardecals 1")
	end
	
	NotifyAll( ply:Nick() .. " has cleaned up the decals", "NOTIFY_CLEANUP" )
end
AddCommand( "Remove decals", "Removes decals (bullet holes, rpg explosion hits) for every player", "decals", "decals", RemoveDecals, 2, "Overv", 4)

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
AddCommand( "Message", "Send a message to all players (type 1 = Notification, 2 = Chat, 3 = Center)", "message", "message <type> <message>", Message, 2, "Overv", 4)

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

//Admin only noclip
local activated = false
function BlockNoclip( ply )
	if activated == true then
		if ply:IsAdmin() then
			return true
		else
			SendNotify( ply, "Only admins are allowed to noclip!", "NOTIFY_ERROR" )
			return false
		end
	end
end
hook.Add("PlayerNoClip", "AdminOnly", BlockNoclip)

function AdminNoclip( ply, params )
	if params[1] == "1" then
		activated = true
		NotifyAll( "Admin only noclip has been enabled by " .. ply:Nick() )
		
		//Get all players out of noclip
		for _, v in pairs(player.GetAll()) do
			v:SetMoveType( MOVETYPE_WALK )
		end
	elseif params[1] == "0" then
		activated = false
		NotifyAll( "Admin only noclip has been disabled by " .. ply:Nick() )
	end
end
AddCommand( "Admin Noclip", "Enable or disable admin only noclip", "adminnoclip", "adminnoclip <1 or 0>", AdminNoclip, 2, "Overv", 4)

//Countdown
local c_finishtime = 0
local c_text = "CountdownText"

if SERVER then
	function CreateCountdown( ply, params )
		if tonumber(params[1]) ~= nil then
			c_finishtime = os.time() + tonumber(params[1])
			
			local reason = ""
			for k, v in pairs(params) do
				if k > 1 then reason = reason .. v .. " " end
			end
			
			if reason == "" then reason = "Countdown" end
			
			c_text = reason
			
			NotifyAll( ply:Nick() .. " has started a new countdown")
			for _, v in pairs(player.GetAll()) do
				v:SendLua("CreateCountdown(" .. params[1] .. ", \"" .. c_text .. "\")")
			end
		end
	end
	
	//Notify people who joined after creating the countdown
	function NotifyGuys( ply )
		local timetosend = c_finishtime - os.time()
		ply:SendLua("CreateCountdown(" .. timetosend .. ", \"" .. c_text .. "\")")
	end
	hook.Add("PlayerInitialSpawn", "NotifyGuys", NotifyGuys)
end
AddCommand( "Countdown", "Create a countdown", "countdown", "countdown <seconds> <text>", CreateCountdown, 2, "Overv", 4)

if CLIENT then
	//Create countdown on client
	function CreateCountdown( time, text )
		c_finishtime = os.time() + time
		c_text = text
	end
	
	//Display countdown
	function DrawCountdown()
		if os.time() < c_finishtime then
			local timeremaining = c_finishtime - os.time()
			
			surface.SetFont("ScoreboardText")
			local w = surface.GetTextSize( c_text .. ": " )
			local w2 = surface.GetTextSize( FormatTime(timeremaining) )
			local cYellow = Color(255, 255, 100, 255)
			
			draw.RoundedBox( 6, 10, 10, w+w2+10, 25, Color(0, 0, 0, 127) )
			draw.DrawText( c_text .. ": ", "ScoreboardText", 15, 15, Color(255, 255, 100, 255), 0 )
			draw.DrawText( FormatTime(timeremaining), "ScoreboardText", 15+w, 15, Color(255, 255, 255, 255), 0 )
		end
	end
	hook.Add("HUDPaint", "Countdown", DrawCountdown)
	
	function FormatTime( time )
		local seconds = 0
		local minutes = 0
		local hours = 0
		local timeleft = time
		
		//Hours
		while timeleft >= 3600 do
			hours = hours + 1
			timeleft = timeleft - 3600
		end
		//Minutes
		while timeleft >= 60 do
			minutes = minutes + 1
			timeleft = timeleft - 60
		end
		//Seconds
		seconds = timeleft
		
		//Format it
		if string.len(seconds) < 2 then seconds = "0" .. seconds end
		if string.len(minutes) < 2 then minutes = "0" .. minutes end
		if string.len(hours) < 2 then hours = "0" .. hours end
		
		return hours .. ":" .. minutes .. ":" .. seconds
	end
end