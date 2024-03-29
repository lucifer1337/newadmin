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
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			RunConsoleCommand("kickid", pl:UserID(), GetReason(params))
			NotifyAll( ply:Nick() .. " has kicked " .. pl:Nick() .. " (" .. GetReason(params) .. ")", "NOTIFY_CLEANUP" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Kick", "Kick a player", "kick", "kick <name> [reason]", Kick, 1, "Overv", 1)

//Ban system
//Load saved bans from file
function LoadBans()
	if file.Exists("NewAdmin/bans.txt") then
		local banfile = file.Read("NewAdmin/bans.txt")
		temp = string.Explode("\n", banfile)
		
		for k, v in pairs(temp) do
			if string.find( v, "[split]" ) ~= nil then
				local params = string.Explode( "[split]", v )
				local item = {}
				
				item.Nick = params[1]
				item.SteamID = params[2]
				item.Reason = params[3]
				item.EndTime = tonumber(params[4])
				item.Banner = params[5]
				
				table.insert( BannedPlayers, item )
			end
		end
		
		ConsoleMsg( "Banfile found and loaded -> Found " .. table.Count(BannedPlayers) .. " entrys" )
	else
		ConsoleMsg( "No banfile found -> Starting with empty ban table" )
	end
end
if SERVER then LoadBans() end

function SaveBans()
	local ftext = ""
	for _, v in pairs( BannedPlayers ) do
		ftext = ftext .. v.Nick .. "[split]" .. v.SteamID .. "[split]" .. v.Reason .. "[split]" .. v.EndTime .. "[split]" .. v.Banner .. "\n"
	end
	
	file.Write( "NewAdmin/bans.txt", ftext )
end
if SERVER then SaveBans() end

//Ban command
function Ban( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			//Bantime
			local time = tonumber(params[2])
			if time == nil then time = 0 end
			
			//Reason
			local reason = GetReason( params, 2 )
			
			//Insert into ban table
			local bandata = {}
			bandata.Nick = pl:Nick()
			bandata.SteamID = pl:SteamID()
			bandata.Reason = reason
			bandata.Banner = ply:SteamID()
			
			if time > 0 then bandata.EndTime = os.time() + (time * 60) else bandata.EndTime = 0 end
			table.insert( BannedPlayers, bandata )
			
			SaveBans()
			
			//Do it and notify
			if time > 0 then
				NotifyAll( pl:Nick() .. " has been banned by " .. ply:Nick() .. " for " .. time .. " minutes", "NOTIFY_CLEANUP" )				
				RunConsoleCommand("kickid", pl:UserID(), "Banned for " .. time .. " minutes! (" .. reason .. ")")
			else
				NotifyAll( pl:Nick() .. " has been permabanned by " .. ply:Nick(), "NOTIFY_CLEANUP" )
				
				RunConsoleCommand("kickid", pl:UserID(), "Permanently banned! (" .. reason .. ")")
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Ban", "Ban a player for a certain amount of time or permanent", "ban", "ban <name> [time in minutes, 0 = perma] [reason]", Ban, 2, "Overv", 1)

function KickBan( ply )
	for k, v in pairs( BannedPlayers ) do
		//Ban done?
		if v.EndTime < os.time() then
			table.remove( k )
			SaveBans()
		end
	
		if v.SteamID == ply:SteamID() and v.EndTime > os.time() then
			local timeleft = math.floor((v.EndTime - os.time()) / 60)
			RunConsoleCommand("kickid", ply:UserID(), "Banned for " .. timeleft .. " minutes" )
		else
			ConsoleMsg( "Wrong! ('" .. ply:SteamID() .. "' != '" .. v.SteamID .. "')" )
		end
	end
end
hook.Add( "PlayerInitialSpawn", "KickBan", KickBan )