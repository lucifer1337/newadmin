//This module takes care of kicking and banning
BannedPlayers = {}

function GetReason( params, offset )
	local reason = ""
	if offset == nil then offset = 1 end
	
	if table.Count( params ) > offset then
		for k, v in pairs(params) do
			if k > offset then reason = reason .. " " .. v end
		end
		reason = string.Trim(reason)
	else
		reason = "N/A"
	end
	
	return reason
end

//Kick
function Kick( ply, params )
	RunConsoleCommand("kickid", params[1]:UserID(), GetReason(params))
	Notify( ply:Nick() .. " has kicked " .. params[1]:Nick() .. " (" .. GetReason(params) .. ")", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Kick", "Kick a player", "kick", "kick <name> [reason]", 1, "Overv", 1, 1, Kick )
RegisterCheck( "Kick", 1, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Kick", 1, "kick [PLAYER]" )

//Ban system
//Load saved bans from file
function LoadBans()
	if file.Exists("NewAdmin/bans.txt") then
		local banfile = file.Read("NewAdmin/bans.txt")
		Lines = string.Explode("\n", banfile)
		
		BannedPlayers = {}
		
		for i=1, math.floor(#Lines/5), 5 do
			local item = {}
			item.Nick = Lines[i]
			item.SteamID = Lines[i+1]
			item.Reason = Lines[i+2]
			item.EndTime = tonumber(Lines[i+3])
			item.Banner = Lines[i+4]
			
			table.insert( BannedPlayers, item )
		end
		
		Log( "Banfile found and loaded -> Found " .. table.Count(BannedPlayers) .. " entries" )
	else
		Log( "No banfile found -> Starting with empty ban table" )
		BannedPlayers = {}
	end
	
	for _, v in pairs(player.GetAll()) do
		v:SetNWBool( "BansUp2Date", false )
	end
end
if SERVER then LoadBans() end
concommand.Add( "ReloadBans", LoadBans ) //Console command to reload bans

function SaveBans()
	local ftext = ""
	for _, v in pairs( BannedPlayers ) do
		ftext = ftext .. v.Nick .. "\n" .. v.SteamID .. "\n" .. v.Reason .. "\n" .. v.EndTime .. "\n" .. v.Banner .. "\n"
	end
	
	file.Write( "NewAdmin/bans.txt", ftext )
	Log( "Banfile updated" )
end
if SERVER then SaveBans() end

//Ban command
function Ban( ply, params )
	//Bantime
	local time = tonumber(params[2])
	if time == nil then time = 0 end
	
	//Reason
	local reason = GetReason( params, 2 )
	
	//Insert into ban table
	local bandata = {}
	bandata.Nick = params[1]:Nick()
	bandata.SteamID = params[1]:SteamID()
	bandata.Reason = reason
	bandata.Banner = ply:SteamID()
	
	if time > 0 then bandata.EndTime = os.time() + (time * 60) else bandata.EndTime = 0 end
	table.insert( BannedPlayers, bandata )
	
	SaveBans()
	
	//Do it and notify
	if time > 0 then
		Notify( params[1]:Nick() .. " has been banned by " .. ply:Nick() .. " for " .. time .. " minutes (" .. reason .. ")", "NOTIFY_CLEANUP" )				
		RunConsoleCommand("kickid", params[1]:UserID(), "Banned for " .. time .. " minutes! (" .. reason .. ")")
	else
		Notify( params[1]:Nick() .. " has been permabanned by " .. ply:Nick() .. " (" .. reason .. ")", "NOTIFY_CLEANUP" )
		RunConsoleCommand("kickid", params[1]:UserID(), "Permabanned! (" .. reason .. ")")
	end
	
	for _, v in pairs(player.GetAll()) do
		v:SetNWBool( "BansUp2Date", false )
	end
end
RegisterCommand( "Ban", "Ban a player for a certain amount of time or permanent", "ban", "ban <name> [time in minutes, 0 = perma] [reason]", 2, "Overv", 1, 1, Ban )
RegisterCheck( "Ban", 1, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Ban", 1, "ban [PLAYER] 60" )

function KickBan( ply )
	for k, v in pairs( BannedPlayers ) do
		//Ban done?
		if v.EndTime < os.time() and tonumber(v.EndTime) > 0 then
			table.remove( BannedPlayers, k )
			SaveBans()
			Log( "Ban for '" .. v.Nick .. "' has expired!" )
			
			for _, v in pairs(player.GetAll()) do
				ply:SetNWBool( "BansUp2Date", false )
			end
		end
	
		if v.SteamID == ply:SteamID() and (v.EndTime > os.time() or tonumber(v.EndTime) == 0) then
			if tonumber(v.EndTime) == 0 then
				RunConsoleCommand("kickid", ply:UserID(), "Permabanned!" )
				return 
			end
		
			local timeleft = math.ceil((v.EndTime - os.time()) / 60)
						
			if timeleft != 1 then
				RunConsoleCommand("kickid", ply:UserID(), "Banned for " .. timeleft .. " minutes" )
				return 
			else
				RunConsoleCommand("kickid", ply:UserID(), "Banned for " .. timeleft .. " minute" )
				return 
			end
		end
	end
	
	Log( "No ban entry found for " .. ply:Nick() )
end
hook.Add( "PlayerInitialSpawn", "KickBan", KickBan )