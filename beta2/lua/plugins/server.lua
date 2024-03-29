//Welcome message
function WelcomeMessage( ply )
	NA_Notify( "Welcome to " .. GetGlobalString("ServerName"), "NOTIFY_GENERIC", ply )
	NA_Notify( "Type !commands to get an overview of the commands!", "NOTIFY_GENERIC", ply )
	ply:PrintMessage( HUD_PRINTTALK, "Type !commands to get an overview of the commands!" )
	
	local found = false
	for i, v in pairs(plinfo) do
		if v.SteamID == ply:SteamID() then
			for _, k in pairs(player.GetAll()) do
				k:PrintMessage( HUD_PRINTTALK, ply:Nick() .. " last joined at " .. v.PrevDate .. " as " .. v.PrevNick )
			end
			
			found = true
			plinfo[i].PrevNick = ply:Nick()
			plinfo[i].PrevDate = os.date("%c")
			plinfo[i].SessionStart = os.time() //This is obviously not saved to a file
		end
	end
	
	if found == false then
		for _, k in pairs(player.GetAll()) do
			k:PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has spawned for the first time." )
		end
		
		local newitem = {}
		newitem.SteamID = ply:SteamID()
		newitem.PrevNick = ply:Nick()
		newitem.PrevDate = os.date("%c")
		newitem.PlayTime = 0
		newitem.SessionStart = os.time() //This is obviously not saved to a file
		table.insert( plinfo, newitem )
		SaveInfo()
	end
	
	timer.Simple( 1, AddPlayTime, ply:EntIndex() )
end
if SERVER then hook.Add( "PlayerInitialSpawn", "WelcomeHook", WelcomeMessage ) end

function AddPlayTime( plyid )
	local pl = player.GetByID(plyid)
	
	if pl ~= NULL then
		for i, v in pairs(plinfo) do
			if v.SteamID == pl:SteamID() then
				plinfo[i].PlayTime = plinfo[i].PlayTime + 1
			end
		end
		timer.Simple( 1, AddPlayTime, pl:EntIndex() )
	end
end

//Remember people's info
plinfo = {}

function SaveInfo(Hide)
	if !SERVER then return false end
	
	local tfile = ""
	for _, v in pairs(plinfo) do
		tfile = tfile .. v.SteamID .. "\n" .. v.PrevNick .. "\n" .. v.PrevDate .. "\n" .. v.PlayTime .. "\n"
	end
	
	file.Write( "NewAdmin/userinfo.txt", tfile )
	
	if Hide then return true end
	Log( "Saved user info file!" )
end
if SERVER then timer.Create( "UpdateInfo", 30, 0, SaveInfo, true )  end

function LoadInfo()
	if file.Exists("NewAdmin/userinfo.txt") then
		local lines = string.Explode( "\n", file.Read("NewAdmin/userinfo.txt") )
		for k = 1, #lines-1, 4 do		
			local item = {}
			item.SteamID = lines[k]
			item.PrevNick = lines[k+1]
			item.PrevDate = lines[k+2]
			item.PlayTime = lines[k+3]
			
			table.insert( plinfo, item )
		end
		
		Log( "Loaded " .. #plinfo .. " userinfo entries!" )
	else
		Log("No user info file found, making one.")
		SaveInfo()
	end
end
if SERVER then LoadInfo() end

//Reload map
function ReloadMap( ply, params )
	RunConsoleCommand( "changelevel", game.GetMap() )
end
RegisterCommand( "Reload map", "Reload the map", "reload", "reload", 2, "Overv", 4, 0, ReloadMap )
if SERVER then concommand.Add( "Reload", ReloadMap ) end

//Cleanup everything
function FullCleanup( ply, params )
	//Clean up
	cleanup.CC_AdminCleanup( ply, "", {} )	
	NA_Notify( ply:Nick() .. " has cleaned up the map", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Cleanup", "Removes every entity in the map", "cleanup", "cleanup", 2, "Overv", 4, 0, FullCleanup )

//Remove displacements
function RemoveDecals( ply, params )
	//Clean up
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("r_cleardecals 1")
	end
	
	NA_Notify( ply:Nick() .. " has cleaned up the decals", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Remove decals", "Removes decals (bullet holes, rpg explosion hits) for every player", "decals", "decals", 2, "Overv", 4, 0, RemoveDecals )

//Message
function Message( ply, params )
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
	
	for _, v in pairs(player.GetAll()) do
		if mtype == 1 then
			NA_Notify( collect, nil, v )
		elseif mtype == 2 then
			v:PrintMessage( HUD_PRINTTALK, collect )
		elseif mtype == 3 then
			v:PrintMessage( HUD_PRINTCENTER, collect )
		end
	end
end
RegisterCommand( "Message", "Send a message to all players (type 1 = Notification, 2 = Chat, 3 = Center)", "msg", "msg <type> <message>", 3, "Overv", 4, 2, Message )
RegisterCheck( "Message", 1, 2, "The message type must be a number!" )

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
	NA_Notify( "All the maps on the server have been printed to the console", nil, ply )
end
RegisterCommand( "Maps", "Prints out all the maps on the server to the console", "maps", "maps", 2, "Overv", 4, 0, ListMaps )

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
RegisterCommand( "Map", "Use this command to change the map", "map", "map <mapname>", 2, "Overv", 4, 1, ChangeMap )

//Show maps
function ListMaps()
	Msg("\n=== Maps on this server ===\n\n")
	
	for k, v in pairs(maps) do
		Msg(v .. "\n")
	end
	
	Msg("\n")
end

//Change gamemode and map
function ChangeGM( ply, params )
	RunConsoleCommand("changegamemode", params[1], params[2])
end
RegisterCommand( "Gamemode", "Use this command to change the map and gamemode", "gm", "gm <mapname> <gamemode folder name>", 2, "Overv", 4, 2, ChangeGM )

//Admin only noclip
local activated = false
function BlockNoclip( ply )
	if activated == true then
		if HasPrivilege( ply, "Noclip always" ) then
			return true
		else
			NA_Notify( "Only admins are allowed to noclip!", "NOTIFY_ERROR", ply )
			return false
		end
	end
end
hook.Add("PlayerNoClip", "AdminOnly", BlockNoclip)

function AdminNoclip( ply, params )
	if tonumber(params[1]) == 1 then
		activated = true
		NA_Notify( "Admin only noclip has been enabled by " .. ply:Nick() )
		
		//Get all players out of noclip
		for _, v in pairs(player.GetAll()) do
			v:SetMoveType( MOVETYPE_WALK )
		end
	else
		activated = false
		NA_Notify( "Admin only noclip has been disabled by " .. ply:Nick() )
	end
end
RegisterCommand( "Admin Noclip", "Enable or disable admin only noclip", "adminnoclip", "adminnoclip <0 or 1>", 2, "Overv", 4, 0, AdminNoclip )
RegisterCheck( "Admin Noclip", 1, 4, "The first argument must be 0 or 1!" )

//Countdown
local c_finishtime = 0
local c_text = "CountdownText"
local c_notedstop = false

if SERVER then
	local CCommand = ""
	local CommandPlayer = nil

	function CreateCountdown( ply, params )
		if params[1] > 86400 then
			NA_Notify( "You can't make countdowns longer than 24 hours!", "NOTIFY_ERROR", ply )
			return 
		elseif params[1] < 0 then
			NA_Notify( "The countdown has been ended by " .. ply:Nick(), "NOTIFY_CLEANUP" )
			return 
		end
	
		c_finishtime = os.time() + params[1]
		
		local reason = ""
		for k, v in pairs(params) do
			if k > 1 then reason = reason .. v .. " " end
		end
		if reason == "" then reason = "Countdown" end
		
		c_text = reason
		
		NA_Notify( ply:Nick() .. " has started a new countdown")
		c_notedstop = false
		for _, v in pairs(player.GetAll()) do
			v:SendLua("CreateCountdown(" .. params[1] .. ", \"" .. c_text .. "\")")
		end
	end
	
	//Notify people who joined after creating the countdown
	function NotifyGuys( ply )
		local timetosend = c_finishtime - os.time()
		ply:SendLua("CreateCountdown(" .. timetosend .. ", \"" .. c_text .. "\")")
	end
	hook.Add("PlayerInitialSpawn", "NotifyGuys", NotifyGuys)
	
	function CheckCountdown()
		if os.time() == c_finishtime and c_notedstop == false then
			c_notedstop = true
			NA_Notify( "The countdown has ended", "NOTIFY_CLEANUP" )
			
			if CCommand != nil then
				Log( "Calling command..." )
				CallCommand( string.sub(CCommand[1], 2), CommandPlayer, string.Explode( " ", table.concat( CCommand, " ", 2 ) ) )
			else
				Log( "It's nil wtf" )
			end
			
			CCommand = ""
			CommandPlayer = nil
		end
	end
	timer.Create("tmCheckCountdown", 1, 0, CheckCountdown)
	
	function CountdownCommand( ply, pars )
		CCommand = pars
		CommandPlayer = ply
		NA_Notify( "After countdown calling command '" .. string.sub(CCommand[1], 2) .. "' with the parameters '" .. table.concat( CCommand, " ", 2 ) .. "'", "NOTIFY_GENERIC", ply )
	end
end
RegisterCommand( "Countdown", "Create a countdown", "countdown", "countdown <seconds> <text>", 3, "Overv", 4, 1, CreateCountdown )
RegisterCheck( "Countdown", 1, 2, "The number of seconds must be a number!" )
RegisterCommand( "CountdownCommand", "Set a command which runs when the countdown has finished", "countdownc", "countdownc <command>", 3, "Overv", 4, 1, CountdownCommand )

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
end

//Execute a console command on a client
function ExecCommand( ply, params )
	local Command = TableConcat( params, " ", 1 )
	params[1]:ConCommand( Command .. "\n" )
	Log( ply:Nick() .. " executed command '" .. Command .. "' on " .. params[1]:Nick() )
end
RegisterCommand( "Remote Command", "Execute a console command on a client", "cexec", "cexec <command>", 3, "Overv", 6, 1, ExecCommand )
RegisterCheck( "Remote Command", 1, 1, "Player '%arg%' not found!" )