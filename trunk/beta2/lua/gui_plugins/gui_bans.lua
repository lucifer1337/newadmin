resource.AddFile( "materials/gui/silkicons/bans.vmt" )
resource.AddFile( "materials/gui/silkicons/bans.vtf" )
BanIDs = {}

function BanTab()
	//Main panel
	TabBans = vgui.Create( "DPanel", Tabs )
	TabBans:SetPos( 5, 10 )
	TabBans:SetSize( w - 10, h - 15 )
	TabBans.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabBans:GetWide(), TabBans:GetTall() )
	end
	
	//Listview with bans
	Bans = vgui.Create("DListView") 
	Bans:SetParent( TabBans )
	Bans:SetPos( 0, 0 )
	Bans:SetSize( TabBans:GetWide(), TabBans:GetTall() - 42 )
	Bans:SetMultiSelect( false )
	
	local colUsername = Bans:AddColumn( "Username" )
	local colSteamID = Bans:AddColumn( "SteamID" )
	local colTime = Bans:AddColumn( "Time remaining" )
	local colReason = Bans:AddColumn( "Reason" )
	local colBanner = Bans:AddColumn( "Banner" )
	colUsername:SetWide( 100 )
	colSteamID:SetWide( 100 )
	colTime:SetWide( 100 )
	colReason:SetWide( 200 )
	colBanner:SetWide( 100 )
	
	//Unban button
	cmdUnban = vgui.Create( "DButton", TabBans )
	cmdUnban:SetPos( 0, TabBans:GetTall() - 37 )
	cmdUnban:SetSize( 80, 20 )
	cmdUnban:SetText( "Unban" )
	cmdUnban.DoClick = function() Unban() end
	cmdUnban:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdUnban:SetEnabled( true ) end
	
	Tabs:AddSheet( "Bans", TabBans, "gui/silkicons/bans", false, false, "Manage current bans" )
end
RegisterTab( BanTab, 2 )

function UpdateBanlist( ForceUpdate )
	if !LocalPlayer():GetNWBool("BansUp2Date") or ForceUpdate then
		BanIDs = {}
		Bans:Clear()
		RunConsoleCommand( "NA_UpdateBanlist" )
	end
end
RegisterOnOpen( UpdateBanlist )

function SetButtonsBan()
	cmdUnban:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdUnban:SetEnabled( true ) end
end
RegisterOnOpen( SetButtonsBan )

if SERVER then
	function GetNickBySteamID( SteamID )
		for _, v in pairs(plinfo) do
			if v.SteamID == SteamID then return v.PrevNick end
		end
	end
	
	function NA_UpdateBanlist( ply )
		for i, m in pairs(BannedPlayers) do
			if tonumber(m.EndTime) == 0 then EndTime = "Permanent" else EndTime = math.ceil((m.EndTime - os.time()) / 60) .. " Minutes" end
			ply:SendLua( "Bans:AddLine( \"" .. m.Nick .. "\", \"" .. m.SteamID .. "\", \"" .. EndTime .. "\", \"" .. m.Reason .. "\", \"" .. GetNickBySteamID(m.Banner) .. "\" )" )
			ply:SendLua( "table.insert( BanIDs, \"" .. m.SteamID .. "\" )" )
		end
		ply:SendLua( "Bans:SelectFirstItem()" )
		
		//Tell ply's client he has the up to date message list now!
		ply:SetNWBool( "BansUp2Date", true )
	end
	concommand.Add( "NA_UpdateBanlist", NA_UpdateBanlist )
	
	function NA_Unban( ply, com, args )
		for i, v in pairs(BannedPlayers) do
			if v.SteamID == args[1] then
				table.remove( BannedPlayers, i )
				SaveBans()
			end
		end
	end
	concommand.Add( "NA_Unban", NA_Unban )
end

function Unban()
	if Bans:GetSelectedLine() ~= nil then
		RunConsoleCommand( "NA_Unban", BanIDs[Bans:GetSelectedLine()] )
		UpdateBanlist( true )
	end
end