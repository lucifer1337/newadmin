//This module takes care of kicking and banning
local BannedPlayers = {}

function GetReason( params, offset )
	local reason = ""
	if offset == nil then offset = 1 end
	
	if table.Count( params ) > offset then
		for k, v in pairs(params) do
			if k > offset then reason = reason .. " " .. v end
		end
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
				item.EndTime = params[4]
				
				table.insert( BannedPlayers, item )
			end
		end
		
		ConsoleMsg( "Banfile found and loaded -> Found " .. table.Count(BannedPlayers) .. " entrys" )
	else
		ConsoleMsg( "No banfile found -> Starting with empty ban table" )
	end
end
if SERVER then LoadBans() end

//Save bans


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
			if time > 0 then bandata.EndTime = os.time() + (time * 60) else bandata.EndTime = 0 end
			table.insert( BannedPlayers, bandata )
			
			SaveBans()
			
			//Do it and notify
			if time > 0 then
				for k, v in pairs(player.GetAll()) do
					SendNotify( v, pl:Nick() .. " has been banned by " .. ply:Nick() .. " for " .. time .. " minutes", "NOTIFY_CLEANUP")
				end
				
				RunConsoleCommand("kickid", pl:UserID(), "Banned for " .. time .. " minutes!\nReason: " .. reason)
			else
				for k, v in pairs(player.GetAll()) do
					SendNotify( v, pl:Nick() .. " has been permabanned by " .. ply:Nick(), "NOTIFY_CLEANUP")
				end
				
				RunConsoleCommand("kickid", pl:UserID(), "Permanently banned!\nReason: " .. reason)
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Ban", "Ban a player for a certain amount of time or permanent", "ban", "ban <name> [time in minutes, 0 = perma] [reason]", Ban, 2, "Overv", 1)