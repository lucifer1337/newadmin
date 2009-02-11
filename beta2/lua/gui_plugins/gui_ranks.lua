//Table that holds all rank information
Ranks = {}

//Ranking code
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

function ListPrivileges()
	PrivLines = {}
	Privileges:Clear()
	
	for _, v in pairs(Commands) do
		if HasPrivilege( Groups.TextEntry:GetValue(), v.Title ) then bActivated = "Yes" else bActivated = "No" end
		local Line = Privileges:AddLine( v.Title, bActivated )
		
		local Item = {}
		Item.Title = v.Title
		Item.Activated = HasPrivilege(Groups.TextEntry:GetValue(), v.Title)
		Item.Line = Line
		table.insert( PrivLines, Item )
	end
	
	Privileges:SortByColumn( 1 )
end

function HasPrivilege( Rank, Privilege )
	for _, v in pairs(Ranks) do
		if v.Title == Rank then
			return table.HasValue(v.Privileges, Privilege)
		end
	end
end

function GetRankID( Rank )
	for i, v in pairs(Ranks) do
		if v.Title == Rank then
			return i
		end
	end
end

function table.ValueIndex( Table, Value )
	for i, v in pairs(Table) do
		if v == Value then
			return i
		end
	end
end

function PrivilegeToggle()
	if LocalPlayer():GetNWString("Owner") then
		local SelLineID = Privileges:GetSelectedLine()
		local SelLine = PrivLines[SelLineID]
		local Rank = Groups.TextEntry:GetValue()
		
		if !SelLine.Activated then
			SelLine.Line:SetColumnText( 2, "Yes" )
			PrivLines[SelLineID].Activated = true
			table.insert( Ranks[GetRankID(Rank)].Privileges, SelLine.Title )
		else
			SelLine.Line:SetColumnText( 2, "No" )
			PrivLines[SelLineID].Activated = false
			table.remove( Ranks[GetRankID(Rank)].Privileges, table.ValueIndex(Ranks[GetRankID(Rank)].Privileges, SelLine.Title) )
		end
		
		SaveRanks()
	end
end

//GUI
function RanksTab()
	//Main panel
	TabRanks = vgui.Create( "DPanel", Tabs )
	TabRanks:SetPos( 5, 10 )
	TabRanks:SetSize( w - 10, h - 15 )
	TabRanks.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabRanks:GetWide(), TabRanks:GetTall() )
	end
	
	//Group selection
	Groups = vgui.Create( "DMultiChoice", TabRanks )
	Groups:SetPos( 0, 0 )
	Groups:SetSize( TabRanks:GetWide(), 20 )
	Groups:SetEditable( false )
	Groups.OnSelect = function()
		local RankID = GetRankID(Groups.TextEntry:GetValue())
		ListPrivileges()
	end
	
	//Privileges listview
	Privileges = vgui.Create("DListView") 
	Privileges:SetParent( TabRanks )
	Privileges:SetPos( 0, 25 )
	Privileges:SetSize( TabRanks:GetWide(), TabRanks:GetTall() - 42 )
	Privileges:SetMultiSelect( false )
	Privileges.DoDoubleClick = function() PrivilegeToggle() end
	local colPrivilege = Privileges:AddColumn( "Privilege" )
	local colEnabled = Privileges:AddColumn( "Enabled" )
	colPrivilege:SetWide( 450 )
	colEnabled:SetWide( 50 )
	
	Tabs:AddSheet( "Ranks", TabRanks, "gui/silkicons/group", false, false, "Manage ranks/user groups" )
end
RegisterTab( RanksTab, 2 )

function BuildRankList()
	ListPrivileges()
	Groups:Clear()
	for _, r in pairs(Ranks) do
		Groups:AddChoice( r.Title )
		Groups:ChooseOptionID( 1 )
	end
end
RegisterOnOpen( BuildRankList )