//Temporary fix
resource.AddFile( "data/defaultranks.txt" )

//Table that holds all rank information
Ranks = {}

//Loading and saving ranks
function LoadRanks()
	if file.Exists("NewAdmin/ranks.txt") then
		local File = file.Read("NewAdmin/ranks.txt")
		for _, r in pairs( string.Explode("\n", File) ) do
			local RankRaw = string.Explode("|", r)
			
			local Rank = {}
			Rank.Title = RankRaw[1]
			Rank.Privileges = string.Explode(":", RankRaw[2])
			table.insert( Ranks, Rank )
			
			Log( "Loaded rank '" .. Rank.Title .. "' with access to " .. #Rank.Privileges .. " privileges" )
		end
	else
		Log( "No rank file found, installing default ranks!" )
		file.Write( "NewAdmin/ranks.txt", file.Read( "NewAdmin/defaultranks.txt" ) )
		LoadRanks()
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