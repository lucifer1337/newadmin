//Settings
w, h = 700, 430
PFilter = ""
Blind = 0

//HUD
function DrawHud()
	if tonumber(Blind) == 1 then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
end
hook.Add("HUDPaint", "HUD_TEST", DrawHud)

//Block moving if it is not allowed (this is obviously also done on the server, but this is to prevent lag like moves)
function Moving(ply, move)
	if LocalPlayer():GetNetworkedBool("Frozen") == 1 then
		return true
	end
end
hook.Add( "Move", "Moving", Moving)

function ShowAdmin(um)
	//Build the admin panel
	AdminPanel = vgui.Create( "DFrame" )
	AdminPanel:SetPos( (ScrW()/2)-(w/2) , (ScrH()/2)-(h/2) )
	AdminPanel:SetSize( w, h )
	AdminPanel:SetTitle( "NewAdmin" )
	AdminPanel:SetVisible( true )
	AdminPanel:SetDraggable( true )
	AdminPanel:ShowCloseButton( true )
	AdminPanel:MakePopup()
	
	//Add tabs
	Categories = vgui.Create( "DPropertySheet" )
	Categories:SetParent( AdminPanel )
	Categories:SetPos( 5, 30 )
	Categories:SetSize( w-10, h-35 ) 
	
	//Create tabs
	CreatePlayerTab()
	CreateGamemodeTab()
	CreateBanListTab()
	CreateServerTab()
	
	Categories:AddSheet( "Players", TabPlayers, "gui/silkicons/user", false, false, "All the player actions, such as kicking and slapping" )
	Categories:AddSheet( "Server", TabServer, "gui/silkicons/group", false, false, "Serverwide commands" ) 
	Categories:AddSheet( "Gamemode", TabGamemode, "gui/silkicons/wrench", false, false, "Gamemode settings, such as maximum baloon amount" )
	Categories:AddSheet( "Bans", TabBans, "gui/silkicons/shield", false, false, "List with people banned using NewAdmin" )
end
usermessage.Hook("adminmenu", ShowAdmin)

function FillPlayerList()
	ListPlayers:Clear()
	//Refill it
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(PFilter)) or PFilter == "" then
			ListPlayers:AddItem(v:Nick())
		end
	end
	
	//Select first
	for k, v in pairs(ListPlayers:GetItems()) do
		ListPlayers:SelectItem(v)
		CheckBoxBlind:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Blinded"))
		CheckBoxGod:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("GodMode"))
		CheckBoxIgnite:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Ignited"))
		CheckBoxCloak:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Cloaked"))
		CheckBoxMute:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Muted"))
		CheckBoxFrozen:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Frozen"))
		break
	end
end

function GetPlayerbyNick( nick )
	for k, v in pairs(player.GetAll()) do
		if v:Nick() == nick then
			return v
		end
	end
	return nil
end

function CreatePlayerTab()
	//Container
	TabPlayers = vgui.Create( "DPanel", Categories )
	TabPlayers:SetPos( 5, 5 )
	TabPlayers:SetSize( w-20, h-45 )
	TabPlayers.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabPlayers:GetWide(), TabPlayers:GetTall() )
	end
	
	local checkboxyoffset = 225
	local controlx = 505
	
	//Blind
	CheckBoxBlind = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxBlind:SetPos( controlx, checkboxyoffset )
	CheckBoxBlind:SetText( "Blind player" )
	CheckBoxBlind:SetValue( 0 )
	CheckBoxBlind:SizeToContents()
	CheckBoxBlind.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxBlind:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Blinded") then		
				RunConsoleCommand("NA_Blind", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	CheckBoxBlind.Paint = function()
		CheckBoxBlind:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Blinded"))
		CheckBoxGod:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("GodMode"))
		CheckBoxIgnite:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Ignited"))
		CheckBoxCloak:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Cloaked"))
		CheckBoxMute:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Muted"))
		CheckBoxFrozen:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Frozen"))
	end
	
	//Godmode
	CheckBoxGod = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxGod:SetPos( controlx, checkboxyoffset+25 )
	CheckBoxGod:SetText( "Godmode for player" )
	CheckBoxGod:SetValue( 0 )
	CheckBoxGod:SizeToContents()
	CheckBoxGod.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxGod:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("GodMode") then		
				RunConsoleCommand("NA_God", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	
	//Ignite
	CheckBoxIgnite = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxIgnite:SetPos( controlx, checkboxyoffset+50 )
	CheckBoxIgnite:SetText( "Ignited" )
	CheckBoxIgnite:SetValue( 0 )
	CheckBoxIgnite:SizeToContents()
	CheckBoxIgnite.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxIgnite:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Ignited") then		
				RunConsoleCommand("NA_Ignite", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	
	//Cloak
	CheckBoxCloak = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxCloak:SetPos( controlx, checkboxyoffset+75 )
	CheckBoxCloak:SetText( "Cloaked" )
	CheckBoxCloak:SetValue( 0 )
	CheckBoxCloak:SizeToContents()
	CheckBoxCloak.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxCloak:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Cloaked") then		
				RunConsoleCommand("NA_Cloak", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	
	//Mute
	CheckBoxMute = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxMute:SetPos( controlx, checkboxyoffset+100 )
	CheckBoxMute:SetText( "Muted" )
	CheckBoxMute:SetValue( 0 )
	CheckBoxMute:SizeToContents()
	CheckBoxMute.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxMute:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Muted") then		
				RunConsoleCommand("NA_Mute", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	
	//Freeze
	CheckBoxFrozen = vgui.Create( "DCheckBoxLabel", TabPlayers )
	CheckBoxFrozen:SetPos( controlx, checkboxyoffset+125 )
	CheckBoxFrozen:SetText( "Frozen" )
	CheckBoxFrozen:SetValue( 0 )
	CheckBoxFrozen:SizeToContents()
	CheckBoxFrozen.OnChange = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			if CheckBoxFrozen:GetChecked() == true then
				checkval = 1
			else
				checkval = 0
			end
			
			if checkval ~= GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Frozen") then		
				RunConsoleCommand("NA_Freeze", ListPlayers:GetSelectedItems()[1]:GetValue(), checkval)
			end
		end
	end
	
	//Playerlist
	ListPlayers = vgui.Create( "DComboBox", TabPlayers )
	ListPlayers:SetPos( 0, 0 )
	ListPlayers:SetSize( 500, 339 )
	ListPlayers:SetMultiple( false )
	ListPlayers.DoClick = function()
		CheckBoxBlind:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Blinded"))
		CheckBoxGod:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("GodMode"))
		CheckBoxIgnite:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Ignited"))
		CheckBoxCloak:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Cloaked"))
		CheckBoxMute:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Muted"))
		CheckBoxFrozen:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Frozen"))
	end
	FillPlayerList()
	
	//Filter textbox
	PlayerFilter = vgui.Create( "DTextEntry", TabPlayers )
	PlayerFilter:SetPos( 0, 344 )
	PlayerFilter:SetTall( 20 )
	PlayerFilter:SetWide( 500 )
	PlayerFilter:SetEnterAllowed( true )
	PlayerFilter.OnTextChanged = function()
		PFilter = PlayerFilter:GetValue()
		FillPlayerList()
	end
	
	//Commands
	//Kick
	cmdKick = vgui.Create( "DButton" )
	cmdKick:SetParent( TabPlayers )
	cmdKick:SetText( "Kick" )
	cmdKick:SetPos( controlx, 0 )
	cmdKick:SetSize( 175, 20 )
	cmdKick.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Kick", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	
	//Ban for a certain amount of seconds
	cmdBan = vgui.Create( "DButton" )
	cmdBan:SetParent( TabPlayers )
	cmdBan:SetText( "Ban for" )
	cmdBan:SetPos( controlx, 25 )
	cmdBan:SetSize( 50, 20 )
	cmdBan.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil and tonumber(BanMinutes:GetValue()) ~= nil then
			RunConsoleCommand("NA_Ban", ListPlayers:GetSelectedItems()[1]:GetValue(), BanMinutes:GetValue())
		end
	end
	BanMinutes = vgui.Create( "DTextEntry", TabPlayers )
	BanMinutes:SetPos( controlx+55, 25 )
	BanMinutes:SetTall( 20 )
	BanMinutes:SetWide( 50 )
	BanMinutes:SetEnterAllowed( true )
	cmdBan2 = vgui.Create( "DButton" )
	cmdBan2:SetParent( TabPlayers )
	cmdBan2:SetText( "minutes" )
	cmdBan2:SetPos( controlx+110, 25 )
	cmdBan2:SetSize( 65, 20 )
	cmdBan2.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil and tonumber(BanMinutes:GetValue()) ~= nil then
			RunConsoleCommand("NA_Ban", ListPlayers:GetSelectedItems()[1]:GetValue(), BanMinutes:GetValue())
		end
	end
	
	//Permaban
	cmdPermaban = vgui.Create( "DButton" )
	cmdPermaban:SetParent( TabPlayers )
	cmdPermaban:SetText( "Permaban" )
	cmdPermaban:SetPos( controlx, 50 )
	cmdPermaban:SetSize( 175, 20 )
	cmdPermaban.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Ban", ListPlayers:GetSelectedItems()[1]:GetValue(), 0)
		end
	end
	
	//Kill
	cmdKill = vgui.Create( "DButton" )
	cmdKill:SetParent( TabPlayers )
	cmdKill:SetText( "Kill" )
	cmdKill:SetPos( controlx, 85 )
	cmdKill:SetSize( 175, 20 )
	cmdKill.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Kill", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	
	//Slay
	cmdSlay = vgui.Create( "DButton" )
	cmdSlay:SetParent( TabPlayers )
	cmdSlay:SetText( "Slay" )
	cmdSlay:SetPos( controlx, 110 )
	cmdSlay:SetSize( 175, 20 )
	cmdSlay.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Slay", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	
	//Slap
	cmdSlap = vgui.Create( "DButton" )
	cmdSlap:SetParent( TabPlayers )
	cmdSlap:SetText( "Slap" )
	cmdSlap:SetPos( controlx, 135 )
	cmdSlap:SetSize( 175, 20 )
	cmdSlap.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Slap", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	
	//Set health
	HealthValue = vgui.Create( "DTextEntry", TabPlayers )
	HealthValue:SetPos( controlx, 160 )
	HealthValue:SetTall( 20 )
	HealthValue:SetWide( 50 )
	HealthValue:SetEnterAllowed( true )
	HealthValue:SetValue(100)
	cmdHealth = vgui.Create( "DButton" )
	cmdHealth:SetParent( TabPlayers )
	cmdHealth:SetText( "Set health" )
	cmdHealth:SetPos( controlx+55, 160 )
	cmdHealth:SetSize( 120, 20 )
	cmdHealth.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil and tonumber(HealthValue:GetValue()) ~= nil and tonumber(HealthValue:GetValue()) >= 0 then
			RunConsoleCommand("NA_Health", ListPlayers:GetSelectedItems()[1]:GetValue(), HealthValue:GetValue())
		end
	end
	
	//Teleport
	cmdTeleto = vgui.Create( "DButton" )
	cmdTeleto:SetParent( TabPlayers )
	cmdTeleto:SetText( "Teleport to" )
	cmdTeleto:SetPos( controlx, 185 )
	cmdTeleto:SetSize( 85, 20 )
	cmdTeleto.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_TeleTo", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	cmdTeletome = vgui.Create( "DButton" )
	cmdTeletome:SetParent( TabPlayers )
	cmdTeletome:SetText( "Teleport to you" )
	cmdTeletome:SetPos( controlx+90, 185 )
	cmdTeletome:SetSize( 85, 20 )
	cmdTeletome.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_TeleToMe", ListPlayers:GetSelectedItems()[1]:GetValue())
		end
	end
	
end

function CreateServerTab()
	//Container
	TabServer = vgui.Create( "DPanel", Categories )
	TabServer:SetPos( 5, 5 )
	TabServer:SetSize( w-20, h-45 )
	TabServer.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabServer:GetWide(), TabServer:GetTall() )
		surface.SetFont( "default" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 5, 8 )
		surface.DrawText( "Hostname:" )
	end
	
	//Hostname	
	local Hostname = vgui.Create( "DTextEntry", TabServer )
	Hostname:SetPos( 65, 5 )
	Hostname:SetTall( 20 )
	Hostname:SetWide( TabServer:GetWide()-170 )
	Hostname:SetValue( hostname )
	Hostname:SetEnterAllowed( true )
	Hostname.OnEnter = function()
		RunConsoleCommand("NA_Hostname", Hostname:GetValue())
	end
	local SetHostname = vgui.Create( "DButton" )
	SetHostname:SetParent( TabServer )
	SetHostname:SetText( "Set" )
	SetHostname:SetPos( TabServer:GetWide()-100, 5 )
	SetHostname:SetSize( 100, 20 )
	SetHostname.DoClick = function ()
		RunConsoleCommand("NA_Hostname", Hostname:GetValue())
	end
	
	//No-collide players
	CheckBoxSvNocollide = vgui.Create( "DCheckBoxLabel", TabServer )
	CheckBoxSvNocollide:SetPos( 5,  40)
	CheckBoxSvNocollide:SetText( "No-collide players" )
	CheckBoxSvNocollide:SetValue( na_playernocollide )
	CheckBoxSvNocollide:SizeToContents()
	CheckBoxSvNocollide.OnChange = function ()
		if CheckBoxSvNocollide:GetChecked() == true then
			checkval = 1
		else
			checkval = 0
		end
		
		if checkval ~= na_playernocollide then	
			RunConsoleCommand("NA_Nocollide", checkval)
		end
	end
end

function CreateGamemodeTab()
	//Container
	TabGamemode = vgui.Create( "DPanel", Categories )
	TabGamemode:SetPos( 5, 5 )
	TabGamemode:SetSize( w-20, h-45 )
	TabGamemode.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabGamemode:GetWide(), TabGamemode:GetTall() )
	end
end

function CreateBanListTab()
	//Container
	TabBans = vgui.Create( "DPanel", Categories )
	TabBans:SetPos( 5, 5 )
	TabBans:SetSize( w-20, h-45 )
	TabBans.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabBans:GetWide(), TabBans:GetTall() )
	end
end