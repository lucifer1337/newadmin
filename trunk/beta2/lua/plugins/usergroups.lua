//Grouping
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
local RankTable = {}

//Saving and loading ranks
function LoadUserRanks()
	RankTable = {}
	
	if file.Exists( "NewAdmin/userranks.txt" ) then
		local tfile = file.Read( "NewAdmin/userranks.txt" )
		local entries = string.Explode( "\n", tfile )
		
		for _, v in pairs(entries) do
			if string.len( string.Trim(v) ) > 0 then
				local pars = string.Explode( " ", v )
				local entry = {}
				entry.SteamID = pars[1]
				entry.Rank = table.concat(pars, " ", 2)
				
				table.insert( RankTable, entry )
			end
		end
		
		Log( "User ranks file loaded -> Added " .. table.Count( RankTable ) .. " entries" )
	else
		Log( "No user rank file found -> Empty rank table" )
	end
end
LoadUserRanks()
concommand.Add( "ReloadRanks", LoadRanks )

function SaveUserRanks()
	local tfile = ""
	
	for _, v in pairs( RankTable ) do
		tfile = tfile .. v.SteamID .. " " .. v.Rank .. "\n"
	end
	
	file.Write( "NewAdmin/userranks.txt", tfile )
	Log( "Flag file saved." )
end

//Assigning ranks on spawning
function AssignRanks( ply )
	if ply:GetNWBool( "Ranked" ) == true then return  end

	//Some weird bug with keeping the player in TEAM_CONNECTING
	if ply:Team() == TEAM_CONNECTING then
		ply:SetTeam( TEAM_UNASSIGNED )
	end

	for _, v in pairs( RankTable ) do
		if v.SteamID == ply:SteamID() then
			ply:SetNWString( "Rank", v.Rank )
			Log( "Set " .. ply:Nick() .. "'s rank to '" .. v.Rank .. "'" )
			RankGrouping( ply )
			ply:SetNWBool( "Ranked", true )
			return 
		end
	end
	
	Log( "No rank entry found for " .. ply:Nick() )
	ply:SetNWString( "Rank", "Guest" )
	RankGrouping( ply )
	ply:SetNWBool( "Ranked", true )
	
	SaveUserRanks()
end
hook.Add( "PlayerSpawn", "AssignRanks", AssignRanks )

//Base the group on the rank
function RankGrouping( ply )
	if HasPrivilege( ply, "Admin group" ) then
		ply:SetUserGroup( "admin" )
	elseif HasPrivilege( ply, "Super Admin group" ) then
		ply:SetUserGroup( "superadmin" )
	else
		ply:SetUserGroup( "undefined" )
	end
end

//Internal function to edit someone's rank
function EditRank( ply, newrank )
	local newentry = {}
	newentry.SteamID = ply:SteamID()
	newentry.Rank = newrank
	
	for _, v in pairs( RankTable ) do
		if v.SteamID == newentry.SteamID then
			v.Rank = newrank
			Log( ply:Nick() .. "'s rank has been succesfully updated to '" .. newrank .. "'!" )
			RankGrouping( ply )
			SaveUserRanks()
			
			return true
		end
	end
	
	table.insert( RankTable, newentry )
	Log( ply:Nick() .. "'s rank (" .. newrank .. ") has been succesfully added!" )
	RankGrouping( ply )
	SaveUserRanks()
end

//Set people's ranks
function SetRank2( ply, command, args )
	if GetPlayer( args[1] ) ~= nil then
		if RankExists(table.concat(args, " ", 2)) then
			GetPlayer( args[1] ):SetNWString( "Rank", table.concat(args, " ", 2) )
			
			Notify( GetPlayer(args[1]):Nick() .. " is now " .. GetPlayer(args[1]):GetNWString("Rank") .. " (Console)" )
			Log( GetPlayer(args[1]):Nick() .. " is now " .. GetPlayer(args[1]):GetNWString("Rank") .. " (Console)" )
			
			EditRank( GetPlayer(args[1]), GetPlayer(args[1]):GetNWString("Rank") )
		else
			Log( "The rank '" .. table.concat(args, " ", 2) .. "' doesn't exist!" )
		end
	else
		Log( "Player '" .. args[1] .. "' not found!" )
	end
end
concommand.Add( "SetRank", SetRank2 )

function SetRank( ply, args )
	if RankExists(table.concat(args, " ", 2)) then
		args[1]:SetNWString( "Rank", table.concat(args, " ", 2) )
		EditRank( args[1], table.concat(args, " ", 2) )
		Notify( args[1]:Nick() .. " is now " .. args[1]:GetNWString("Rank")  .. " (" .. ply:Nick() .. ")" )
	else
		Notify( "The rank '" .. table.concat(args, " ", 2) .. "' doesn't exist!", "NOTIFY_ERROR", ply )
	end
end
RegisterCommand( "Set Rank", "Set someone's rank", "rank", "rank <name> <rank>", 3, "Overv", 7, 2, SetRank )
RegisterCheck( "Set Rank", 1, 1, "Player '%arg%' not found!" )

//=== Special limits ===

//Weapons allowed?
function LimitGuns( ply )
	if !HasPrivilege( ply, "Weapons allowed" ) then
		ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_physgun" )
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:SelectWeapon( "weapon_physgun" )
		
		return true
	end
end
hook.Add( "PlayerLoadout", "LimitGuns", LimitGuns )

function BlockGuns( ply, wep )
	if !HasPrivilege( ply, "Weapons allowed" ) then
		local wepc = wep:GetClass()
		if wepc != "weapon_physcannon" and wepc != "weapon_physgun" and wepc != "gmod_tool" and wepc != "gmod_camera" then
			wep:Remove()
			return false
		end
	end
end
hook.Add( "PlayerCanPickupWeapon", "NoGuns", BlockGuns )

//Entities allowed?
function NoSENTs( ply )
	if !HasPrivilege( ply, "Entities allowed" ) then return false end
end
hook.Add( "PlayerSpawnSENT", "NoSENTs", NoSENTs )