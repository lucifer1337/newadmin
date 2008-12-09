if SERVER then
	
	function LogSpawn( ply )
		Log( "'" .. ply:Nick() .. "' (" .. ply:SteamID() .. ") has succesfully spawned for the first time!" )
	end
	hook.Add( "PlayerInitialSpawn", "LogSpawn", LogSpawn )

	function LogDeath( Victim, Weapon, Killer )
		if Killer:IsPlayer() then
			Log( "'" .. Killer:Nick() .. "' (" .. Killer:SteamID() .. ") has killed '" .. Victim:Nick() .. "' (" .. Victim:SteamID() .. ") with '" .. Weapon:GetClass() .. "'" )
		end
	end
	hook.Add( "PlayerDeath", "LogDeath", LogDeath )

	function LogConnect( name, address )
		Log( "'" .. name .. "' (" .. address .. ") has joined the server" )
	end
	hook.Add( "PlayerConnect", "LogConnect", LogConnect )

	Log( "Server started in map '" .. game.GetMap() .. "' running gamemode '" .. gmod.GetGamemode().Name .. "'"  )

	function LogShutDown()
		Log( "Server shutdown while running map '" .. game.GetMap() .. "' using gamemode '" .. gmod.GetGamemode().Name .. "' with " .. table.Count(player.GetAll()) .. " players" )
	end
	hook.Add( "ShutDown", "LogShutdown", LogShutdown )
	
	function LogChat( ply, text )
		Log( ply:Nick() .. ": " .. text, true ) //Hide it from the log, cause seeing the same chat message twice is confusing D:
	end
	hook.Add( "PlayerSay", "LogChat", LogChat )

end