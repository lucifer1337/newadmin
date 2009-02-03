resource.AddFile( "materials/gui/silkicons/bans.vmt" )
resource.AddFile( "materials/gui/silkicons/bans.vtf" )

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
	Bans:SetSize( TabBans:GetWide(), TabBans:GetTall() - 17 )
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
	
	Tabs:AddSheet( "Bans", TabBans, "gui/silkicons/bans", false, false, "Manage current bans" )
end
RegisterTab( BanTab, 2 )

function UpdateBanlist()
	if !LocalPlayer():GetNWBool("BansUp2Date") then
		Bans:Clear()
		RunConsoleCommand( "NA_UpdateBanlist" )
	end
end
RegisterOnOpen( UpdateBanlist )

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
		end
		ply:SendLua( "Bans:SelectFirstItem()" )
		
		//Tell ply's client he has the up to date message list now!
		ply:SetNWBool( "BansUp2Date", true )
	end
	concommand.Add( "NA_UpdateBanlist", NA_UpdateBanlist )
end

function EntDamaged( ent, ply, attacker, dmg )
	if ply != NULL and ply:IsValid() and ply:IsPlayer() and !ent:IsPlayer() then
		if dmg >= ent:Health() and ent:Health() > 0 then
			Msg( ply:Nick() .. " killed the entity " .. ent:GetClass() .. "\n" )
		end
	end
end
hook.Add( "EntityTakeDamage", "EntDamaged", EntDamaged )