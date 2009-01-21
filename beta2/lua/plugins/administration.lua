//This module takes care of kicking and banning
local BannedPlayers = {}

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
AddPlayerMenu( "Kick", 1, "kick" )

//Ban system
//Load saved bans from file
function LoadBans()
	if file.Exists("NewAdmin/bans.txt") then
		local banfile = file.Read("NewAdmin/bans.txt")
		temp = string.Explode("\n", banfile)
		
		BannedPlayers = {}
		
		for k, v in pairs(temp) do
			if string.find( v, "[split]" ) ~= nil then
				local params = string.Explode( "[split]", v )
				local item = {}
				
				item.Nick = string.sub( params[1], string.len("[split]") )
				item.SteamID = string.sub( params[2], string.len("[split]") )
				item.Reason = string.sub( params[3], string.len("[split]") )
				item.EndTime = tonumber( string.sub( params[4], string.len("[split]") ) )
				item.Banner = string.sub( params[5], string.len("[split]") )
				
				table.insert( BannedPlayers, item )
			end
		end
		
		Log( "Banfile found and loaded -> Found " .. table.Count(BannedPlayers) .. " entries" )
	else
		Log( "No banfile found -> Starting with empty ban table" )
		BannedPlayers = {}
	end
end
if SERVER then LoadBans() end
concommand.Add( "ReloadBans", LoadBans ) //Console command to reload bans

function SaveBans()
	local ftext = ""
	for _, v in pairs( BannedPlayers ) do
		ftext = ftext .. v.Nick .. "[split]" .. v.SteamID .. "[split]" .. v.Reason .. "[split]" .. v.EndTime .. "[split]" .. v.Banner .. "\n"
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
		Notify( params[1]:Nick() .. " has been banned by " .. ply:Nick() .. " for " .. time .. " minutes", "NOTIFY_CLEANUP" )				
		RunConsoleCommand("kickid", params[1]:UserID(), "Banned for " .. time .. " minutes! (" .. reason .. ")")
	else
		Notify( params[1]:Nick() .. " has been permabanned by " .. ply:Nick(), "NOTIFY_CLEANUP" )
		
		RunConsoleCommand("kickid", params[1]:UserID(), "Permabanned! (" .. reason .. ")")
	end
end
RegisterCommand( "Ban", "Ban a player for a certain amount of time or permanent", "ban", "ban <name> [time in minutes, 0 = perma] [reason]", 2, "Overv", 1, 1, Ban )
RegisterCheck( "Ban", 1, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Ban", 1, "ban" )

function KickBan( ply )
	if ply:GetNWBool("BanChecked") ~= true then return  end

	for k, v in pairs( BannedPlayers ) do
		//Ban done?
		if v.EndTime < os.time() and tonumber(v.EndTime) > 0 then
			table.remove( BannedPlayers, k )
			SaveBans()
			Log( "Ban for '" .. v.Nick .. "' has expired!" )
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
	ply:SetNWBool( "BanChecked", true )
end
hook.Add( "PlayerSpawn", "KickBan", KickBan )

function LolDeb()
	Msg( table.Count(BannedPlayers) .. "\n" )
end
concommand.Add( "Debug", LolDeb )