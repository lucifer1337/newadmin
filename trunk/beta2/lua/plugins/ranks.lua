//Send the client our server ranks file as customized by the owner
resource.AddFile( "data/NewAdmin/ranks.txt" )

//Table that holds all rank information
Ranks = {}

//Parse ranks from string
function ParseRanks( FileStr )
	for _, r in pairs( string.Explode("\n", FileStr) ) do
		local RankRaw = string.Explode("|", r)
		
		local Rank = {}
		Rank.Title = RankRaw[1]
		Rank.Privileges = string.Explode(":", RankRaw[2])
		table.insert( Ranks, Rank )
		
		Log( "Loaded rank '" .. Rank.Title .. "' with access to " .. #Rank.Privileges .. " privileges" )
	end
end

//Loading and saving ranks
function LoadRanks()
	if SERVER then
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
	else
		if file.Exists("NewAdmin/ranks.txt") then
			//Load the server rank file
			ParseRanks( file.Read("NewAdmin/ranks.txt") )
			Log( "Loaded ranks received from server!" )
		else
			Log( "Server did not send a rank file!" )
		end
	end
end
LoadRanks()

function SaveRanks()
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
	SaveRanks()
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

//General useful functions
function GetRankID( Rank )
	for i, v in pairs(Ranks ) do if v.Title == Rank then return i end end
end