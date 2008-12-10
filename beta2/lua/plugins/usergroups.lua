function SetGroup( ply, args )
	args[1]:SetUserGroup( args[2] )
	Notify( args[1]:Nick() .. " is now in the \'" .. args[2] .. "\' group (" .. ply:Nick() .. ")" )
end
RegisterCommand( "Set Group", "Set someone's user group (this does NOT change the flag!)", "group", "group <name> <groupname>", 3, "Overv", 7, 2, SetGroup )
RegisterCheck( "Set Group", 1, 3, "Player '%arg%' not found!" )


//Also register a RCON command for it
function SetGroup2( ply, command, args )
	if GetPlayer( args[1] ) ~= nil then
		GetPlayer( args[1] ):SetUserGroup( args[2] )
		
		Notify( GetPlayer(args[1]):Nick() .. " is now in the \'" .. args[2] .. "\' group (Console)" )
		Log( GetPlayer(args[1]):Nick() .. " is now in the \'" .. args[2] .. "\' group (Console)" )
	else
		Log( "Player '" .. params[1] .. "' not found!" )
	end
end
concommand.Add( "SetGroup", SetGroup2 )

//Handle flags for players
local FlagTable = {}

function LoadFlags()
	if file.Exists( "NewAdmin/flags.txt" ) then
		local tfile = file.Read( "NewAdmin/flags.txt" )
		local entries = string.Explode( "\n", tfile )
		
		for _, v in pairs(entries) do
			if string.len( string.Trim(v) ) > 0 then
				local pars = string.Explode( " ", v )
				local entry = {}
				entry.SteamID = pars[1]
				entry.Flag = pars[2]
				
				table.insert( FlagTable, entry )
			end
		end
		
		Log( "Flag file loaded -> Added " .. table.Count( FlagTable ) .. " entries" )
	else
		Log( "No flag file found -> Empty flag table" )
	end
end
LoadFlags()

function SaveFlags()
	local tfile = ""
	
	for _, v in pairs( FlagTable ) do
		tfile = tfile .. v.SteamID .. " " .. v.Flag .. "\n"
	end
	
	file.Write( "NewAdmin/flags.txt", tfile )
	Log( "Flag file saved." )
end

function AssignFlags( ply )
	//Some weird bug with keeping the player in TEAM_CONNECTING
	if ply:Team() == TEAM_CONNECTING then
		ply:SetTeam( TEAM_UNASSIGNED )
	end

	for _, v in pairs( FlagTable ) do
		if v.SteamID == ply:SteamID() then
			ply:SetNWInt( "Flag", v.Flag )
			
			if v.Flag == 1 then
				ply:SetUserGroup( "admin" )
			elseif v.Flag == 2 then
				ply:SetUserGroup( "superadmin" )
			elseif v.Flag == 3 then
				ply:SetUserGroup( "superadmin" )
			end
			
			Log( "Assigned the flag '" .. v.Flag .. "' to '" .. ply:Nick() .. "'" )
			return true
		end
	end
	
	Log( "No flag entry found for '" .. ply:Nick() .. "'" )
	
	if !ply:IsAdmin() and !ply:IsSuperAdmin() then
		ply:SetNWInt( "Flag", 0 ) //User
	end
	if ply:IsAdmin() then
		ply:SetNWInt( "Flag", 1 )
	end
	if ply:IsSuperAdmin() then
		ply:SetNWInt( "Flag", 2 )
	end
	if ply:IsUserGroup( "owner" ) then
		ply:SetNWInt( "Flag", 3 )
	end
	SaveFlags()
end
hook.Add( "PlayerInitialSpawn", "AssignFlags", AssignFlags )

function EditFlag( ply, newflag )
	local newentry = {}
	newentry.SteamID = ply:SteamID()
	newentry.Flag = newflag
	
	for _, v in pairs( FlagTable ) do
		if v.SteamID == newentry.SteamID then
			v.Flag = newflag
			Log( ply:Nick() .. "'s flag has been succesfully updated!" )
			SaveFlags()
			
			return true
		end
	end
	
	table.insert( FlagTable, newentry )
	Log( ply:Nick() .. "'s flag has been succesfully added!" )
	SaveFlags()
	
	if v.Flag == 1 then
		ply:SetUserGroup( "admin" )
	elseif v.Flag == 2 then
		ply:SetUserGroup( "superadmin" )
	elseif v.Flag == 3 then
		ply:SetUserGroup( "superadmin" )
	end
end

function SetFlag2( ply, command, args )
	if GetPlayer( args[1] ) ~= nil then
		GetPlayer( args[1] ):SetNWInt( "Flag", tonumber(args[2]) )
		
		Notify( GetPlayer(args[1]):Nick() .. " is now " .. string.Left(FlagName( tonumber(args[2]) ), string.len(FlagName( tonumber(args[2]) )) - 1 ) .. " (Console)" )
		Log( GetPlayer(args[1]):Nick() .. " is now " .. string.Left(FlagName( tonumber(args[2]) ), string.len(FlagName( tonumber(args[2]) )) - 1 ) .. " (Console)" )
		
		EditFlag( GetPlayer(args[1]), tonumber(args[2]) )
	else
		Log( "Player '" .. args[1] .. "' not found!" )
	end
end
concommand.Add( "SetFlag", SetFlag2 )

function SetFlag( ply, args )
	args[1]:SetNWInt( "Flag", tonumber(args[2]) )
	EditFlag( ply, tonumber(args[2]) )
	Notify( args[1]:Nick() .. " is now " .. string.Left(FlagName( tonumber(args[2]) ), string.len(FlagName( tonumber(args[2]) )) - 1 )  .. " (" .. ply:Nick() .. ")" )
end
RegisterCommand( "Set Flag", "Set someone's flag (1 = admin, 2 = superadmin)", "flag", "flag <name> <flag>", 3, "Overv", 7, 2, SetFlag )
RegisterCheck( "Set Flag", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "Set Flag", 2, 2, "The flag must be a number!" )