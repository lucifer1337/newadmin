//Send the client our server ranks file as customized by the owner
//resource.AddFile( "data/NewAdmin/ranks.txt" )
//FAIL METHOD OF DOOM OH GOD FFFFFFFFFFUUUUUUUUUUUUUUUU

//Table that holds all rank information
Ranks = {}

//Parse ranks from string
function ParseRanks( FileStr )
	if !SERVER then return false end

	for _, r in pairs( string.Explode("\n", FileStr) ) do
		local RankRaw = string.Explode("|", r)
		
		local Rank = {}
		Rank.Title = RankRaw[1]
		Rank.Privileges = string.Explode(":", RankRaw[2])
		table.insert( Ranks, Rank )
		
		Log( "Loaded rank '" .. Rank.Title .. "' with access to " .. #Rank.Privileges .. " privileges" )
	end
end

//Loading and saving ranks on the server
//On the client we don't load ranks from a file.
function LoadRanks()
	if file.Exists("NewAdmin/ranks.txt") then
		//Load the user rank file
		ParseRanks( file.Read("NewAdmin/ranks.txt") )
		Log( "Loaded ranks!" )
	else
		//Load the default ranks and create a new ranks.txt file for the owner to modify
		ParseRanks( file.Read("NewAdmin/defaultranks.txt") )
		file.Write( "NewAdmin/ranks.txt", file.Read("NewAdmin/defaultranks.txt") )
		Log( "Loaded default ranks and created a new customizable rank file!" )
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

function RankExists( Rank )
	for _, v in pairs(Ranks) do
		if v.Title == Rank then return true end
	end
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