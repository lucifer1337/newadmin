//Table that holds all rank information
Ranks = {}

function RankExists( Rank )
	for _, v in pairs(Ranks) do
		if string.lower(v.Title) == string.lower(Rank) then return v.Title end
	end
end

//Parse ranks from string
function ParseRanks( FileStr )
	if !SERVER then return false end

	for _, r in pairs( string.Explode("\n", FileStr) ) do
		local RankRaw = string.Explode("|", r)
		if !RankExists( RankRaw[1] ) then
			local Rank = {}
			Rank.Title = RankRaw[1]
			Rank.Privileges = string.Explode(":", RankRaw[2])
			table.insert( Ranks, Rank )
		else
			for _, rr in pairs( Ranks ) do
				if rr.Title == RankRaw[1] then
					for _, p in pairs( string.Explode(":", RankRaw[2]) ) do
						table.insert( rr.Privileges, p )
					end
					break
				end
			end
		end
	end
end

//Loading and saving ranks on the server
//On the client we don't load ranks from a file.
function LoadRanks()
	local rankfiles = file.Find( "NewAdmin/ranks/*.txt" )
	if #rankfiles > 0 then
		//Load the user rank files
		for _, f in pairs( rankfiles ) do
			ParseRanks( file.Read("NewAdmin/ranks/" .. f) )
			Log( "Loaded rank file: " .. f )
		end
	else
		//Load the default ranks and create a new ranks.txt file for the owner to modify
		ParseRanks( file.Read("NewAdmin/ranks.txt") )
		file.Write( "NewAdmin/ranks/ranks.txt", file.Read("NewAdmin/ranks.txt") )
		ParseRanks( file.Read("NewAdmin/weapons.txt") )
		file.Write( "NewAdmin/ranks/weapons.txt", file.Read("NewAdmin/weapons.txt") )
		ParseRanks( file.Read("NewAdmin/entities.txt") )
		file.Write( "NewAdmin/ranks/entities.txt", file.Read("NewAdmin/entities.txt") )
		
		Log( "Loaded default ranks and created new customizable rank files!" )
	end
end
if SERVER then LoadRanks() end

function SaveRanks()
	if !SERVER then return false end
	
	local Txt = ""
	for _, v in pairs(Ranks) do
		Txt = Txt .. v.Title .. "|"
		for _, k in pairs(v.Privileges) do
			Txt = Txt .. k .. ":"
		end
		Txt = Txt .. "\n"
	end
	
	file.Write( "NewAdmin/ranks.txt", string.Left(Txt, string.len(Txt)-1) )
end

//Functions to interact with privileges
function RankHasPrivilege( Rank, Privilege )
	for _, v in pairs(Ranks) do
		if v.Title == Rank then
			return table.HasValue(v.Privileges, Privilege)
		end
	end
end

function HasPrivilege( ply, Privilege )
	return RankHasPrivilege( ply:GetNWString("Rank"), Privilege )
end

function AddPrivilege( Rank, Privilege )
	table.insert( Ranks[GetRankID(Rank)].Privileges, Privilege )
	SaveRanks()
end

function RemovePrivilege( Rank, Privilege )
	for i, v in pairs(Ranks[GetRankID(Rank)].Privileges) do
		if v == Privilege then table.remove( Ranks[GetRankID(Rank)].Privileges, i ) end
	end
	if SERVER then SaveRanks() end
end

//Mapping privilege managing to console commands
function DAddPrivilege( ply, com, args )
	AddPrivilege( args[1], args[2] )
end
concommand.Add( "DAddPrivilege", DAddPrivilege )

function DRemovePrivilege( ply, com, args )
	RemovePrivilege( args[1], args[2] )
end
concommand.Add( "DRemovePrivilege", DRemovePrivilege )

function DHasPrivilege( ply, com, args )
	Log( tostring( RankHasPrivilege(args[1], args[2]) ) )
end
concommand.Add( "DHasPrivilege", DHasPrivilege )

function DListRanks( ply, com, args )
	for _, r in pairs(Ranks) do
		Log( r.Title )
	end
end
concommand.Add( "DListRanks", DListRanks )

//General useful functions
function GetRankID( Rank )
	for i, v in pairs(Ranks) do if v.Title == Rank then return i end end
end

//=== Syncing ranks with clients ===

//Serverside
function SyncRanks( pl )
	//Send the ranks and their corresponding privileges
	for _, r in pairs(Ranks) do
		//First create the rank
		umsg.Start( "NA_AddRank", pl )
			umsg.String( string.Replace(r.Title, "Owner", "Owner2") )
		umsg.End()
		
		//Now add the privileges
		for o, p in pairs(r.Privileges) do
			umsg.Start( "NA_AddPrivilege", pl )
				umsg.String( string.Replace(r.Title, "Owner", "Owner2") )
				umsg.String( p )
			umsg.End()
		end
	end
end
hook.Add( "PlayerInitialSpawn", "SyncRanks", SyncRanks )

//Clientside
function CL_AddRank( um )
	local TempRank = {}
	TempRank.Title = string.Replace(um:ReadString(), "Owner2", "Owner")
	TempRank.Privileges = {}
	
	table.insert( Ranks, TempRank )
end
usermessage.Hook( "NA_AddRank", CL_AddRank )

function CL_AddPrivilege( um )
	local Rank = string.Replace(um:ReadString(), "Owner2", "Owner")
	local Privilege = um:ReadString()
	
	for _, r in pairs(Ranks) do
		if r.Title == Rank then
			table.insert( r.Privileges, Privilege )
			return 
		end
	end
end
usermessage.Hook( "NA_AddPrivilege", CL_AddPrivilege )