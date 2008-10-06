//Settings
w, h = 700, 430
PFilter = ""
Blind = 0
MapList = {}
AllowClose = true
PlayerGone = ""
bantable = {}
MenuOpen = false

function GetHeadPos( ply )
	local BoneIndx = ply:LookupBone("ValveBiped.Bip01_Head1")
	local BonePos, BoneAng = ply:GetBonePosition( BoneIndx )
	
	return BonePos
end

//Another attempt to block the npc exploit
CreateClientConVar("npc_create", "0", false, false)

//Get ban list from server
function GetBans( sentence )
	if sentence == "RESET" then
		bantable = nil
		bantable = {}
	elseif sentence ~= "" then
		table.insert(bantable, sentence)
	end
end

//HUD
function DrawHud()
	if newadmin == 1 then
	
	//Blind?
	if tonumber(Blind) == 1 then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
	
	//Draw playernames in hud shamelessly copied from uberHUD
	for k, v in pairs(player.GetAll()) do
		if v:Nick() ~= LocalPlayer():Nick() then
			local iHealth = v:Health()
			
			if iHealth > 1 then
					//Get the information
					local iTeam = team.GetName(v:Team())
					local iTeamC = team.GetColor(v:Team())
					local iName = v:Nick()
					local iDistance = LocalPlayer():GetShootPos():Distance(v:GetShootPos())
				
					//Convert distance to meters
					iDistance = iDistance * 30.48 / 100 / 16
					
					//Display the info
					local scrpos = v:GetShootPos():ToScreen()
					scrpos.y = scrpos.y - 75
					scrpos.y = scrpos.y + (75 * (GetHeadPos(v):Distance(LocalPlayer():GetShootPos()) / 2048)) * 0.5
					
					local alpha = 0
					if iDistance < 200 then
						alpha = 255
					elseif iDistance < 2000 then
						alpha = 255 - (255 * (iDistance-200) / 2200)
					else
						alpha = 0
					end
					
					local w, h = surface.GetTextSize( iName )
					iTeamC.a = alpha
					draw.DrawText( iName , "ScoreboardText", scrpos.x + 1, scrpos.y + 1, Color(0, 0, 0), 1)
					draw.DrawText( iName , "ScoreboardText", scrpos.x, scrpos.y, iTeamC, 1)
					draw.DrawText( math.floor(iDistance) .. " Meters - " .. iHealth .. "%" , "DefaultSmall", scrpos.x + 1, scrpos.y+16, Color(0, 0, 0), 1)
					draw.DrawText( math.floor(iDistance) .. " Meters - " .. iHealth .. "%" , "DefaultSmall", scrpos.x, scrpos.y+15, iTeamC, 1)
			end
		end
	end
	
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
	//Do not open the menu twice
	if MenuOpen == true then return  end
	MenuOpen = true
	
	AllowClose = true

	//Build the admin panel
	AdminPanel = vgui.Create( "DFrame" )
	AdminPanel:SetPos( (ScrW()/2)-(w/2) , (ScrH()/2)-(h/2) )
	AdminPanel:SetSize( w, h )
	AdminPanel:SetTitle( "NewAdmin" )
	AdminPanel:SetVisible( true )
	AdminPanel:SetDraggable( false )
	AdminPanel:ShowCloseButton( false )
	AdminPanel:MakePopup()
	AdminPanel.Paint = function()
	end
	
	//Add tabs
	Categories = vgui.Create( "DPropertySheet" )
	Categories:SetParent( AdminPanel )
	Categories:SetPos( 5 , 5 )
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

function CloseAdmin()
	if AllowClose == true then
		AdminPanel:Remove()
		PFilter = ""
		MenuOpen = false
	end
end
concommand.Add( "-NA_Show", CloseAdmin )

//Hold open and close system
function KeyboardFocusOn( pnl )
	AllowClose = false
end
hook.Add( "OnTextEntryGetFocus", "KeyboardFocusOn", KeyboardFocusOn )

function KeyboardFocusOff( pnl )
	AllowClose = true
	AdminPanel:SetKeyboardInputEnabled( false )
	//CloseAdmin()
end
hook.Add( "OnTextEntryLoseFocus", "KeyboardFocusOff", KeyboardFocusOff )

function UpdateCheckboxes()
	if ListPlayers:GetSelectedItems()[1] ~= nil then
		CheckBoxBlind:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Blinded"))
		CheckBoxGod:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("GodMode"))
		CheckBoxIgnite:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Ignited"))
		CheckBoxCloak:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Cloaked"))
		CheckBoxMute:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Muted"))
		CheckBoxFrozen:SetValue(GetPlayerbyNick(ListPlayers:GetSelectedItems()[1]:GetValue()):GetNetworkedBool("Frozen"))
	end
end

function FillPlayerList()
	ListPlayers:Clear()
	//Refill it
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(PFilter)) or PFilter == "" then
			if PlayerGone ~= v:Nick() then ListPlayers:AddItem(v:Nick()) end
		end
	end
	
	//Select first
	for k, v in pairs(ListPlayers:GetItems()) do
		ListPlayers:SelectItem(v)
		UpdateCheckboxes()
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
		UpdateCheckboxes()
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
		UpdateCheckboxes()
	end
	FillPlayerList()
	
	//Filter textbox
	PlayerFilter = vgui.Create( "DTextEntry", TabPlayers )
	PlayerFilter:AllowInput(true)
	PlayerFilter:SetPos( 0, 344 )
	PlayerFilter:SetTall( 20 )
	PlayerFilter:SetWide( 500 )
	PlayerFilter:SetEnterAllowed( true )
	PlayerFilter.OnTextChanged = function()
		PFilter = PlayerFilter:GetValue()
		FillPlayerList()
	end
	PlayerFilter.StartKeyFocus = function()
		AllowClose = false
		AdminPanel:SetKeyboardInputEnabled( true )
	end
	PlayerFilter.EndKeyFocus = function()
		AdminPanel:SetKeyboardInputEnabled( false )
		AllowClose = true
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
			PlayerGone = ListPlayers:GetSelectedItems()[1]:GetValue()
			FillPlayerList()
		end
	end
	
	//Ban for a certain amount of seconds
	ListBTimes = vgui.Create( "DMultiChoice", TabPlayers )
	ListBTimes:SetPos( controlx, 25 )
	ListBTimes:SetSize( 105, 20 )
	ListBTimes:SetEditable(false)
	//Add ban times
	ListBTimes:AddChoice("5 Minutes")
	ListBTimes:AddChoice("15 Minutes")
	ListBTimes:AddChoice("30 Minutes")
	ListBTimes:AddChoice("1 Hour")
	ListBTimes:AddChoice("2 Hours")
	ListBTimes:AddChoice("6 Hours")
	ListBTimes:AddChoice("1 Day")
	ListBTimes:AddChoice("2 Days")
	ListBTimes:AddChoice("7 Days")
	ListBTimes:AddChoice("1 Month")
	ListBTimes:AddChoice("6 Months")
	ListBTimes:AddChoice("1 Year")
	ListBTimes:AddChoice("Forever")
	ListBTimes:ChooseOptionID(1)
	ListBTimes:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		ListBTimes:SetEnabled(true)
	end
	
	
	cmdBan2 = vgui.Create( "DButton" )
	cmdBan2:SetParent( TabPlayers )
	cmdBan2:SetText( "Ban" )
	cmdBan2:SetPos( controlx+110, 25 )
	cmdBan2:SetSize( 65, 20 )
	cmdBan2.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			local bantime = 0
			if ListBTimes.TextEntry:GetValue() ~= "Forever" then bantime = ListBTimes.TextEntry:GetValue() end
			RunConsoleCommand("NA_Ban", ListPlayers:GetSelectedItems()[1]:GetValue(), bantime)
			PlayerGone = ListPlayers:GetSelectedItems()[1]:GetValue()
			FillPlayerList()
		end
	end
	cmdBan2:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		cmdBan2:SetEnabled(true)
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
			PlayerGone = ListPlayers:GetSelectedItems()[1]:GetValue()
			FillPlayerList()
		end
	end
	cmdPermaban:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		cmdPermaban:SetEnabled(true)
	end
	
	//Explode
	cmdKill = vgui.Create( "DButton" )
	cmdKill:SetParent( TabPlayers )
	cmdKill:SetText( "Explode" )
	cmdKill:SetPos( controlx, 85 )
	cmdKill:SetSize( 175, 20 )
	cmdKill.DoClick = function ()
		if ListPlayers:GetSelectedItems()[1] ~= nil then
			RunConsoleCommand("NA_Explode", ListPlayers:GetSelectedItems()[1]:GetValue())
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
		
		surface.SetTextPos( 5, 38 )
		surface.DrawText( "Map:" )
		
		surface.SetTextPos( 5, 78 )
		surface.DrawText( "Options:" )
		
		surface.SetTextPos( 5, 162 )
		surface.DrawText( "Messages:" )
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
	SetHostname:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		SetHostname:SetEnabled(true)
	end
	
	//Map list
	ListMaps = vgui.Create( "DMultiChoice", TabServer )
	ListMaps:SetPos( 65, 35 )
	ListMaps:SetSize( TabServer:GetWide()-170, 20 )
	ListMaps:SetEditable(false)
	local curmap = 1
	for k, v in pairs(MapList) do
		ListMaps:AddChoice(v)
		
		if v == CurrentMap then
			curmap = k
		end
	end
	ListMaps:ChooseOptionID(curmap)
	
	local SetMap = vgui.Create( "DButton" )
	SetMap:SetParent( TabServer )
	SetMap:SetText( "Change" )
	SetMap:SetPos( TabServer:GetWide()-100, 35 )
	SetMap:SetSize( 100, 20 )
	SetMap.DoClick = function ()
		if ListMaps.TextEntry:GetValue() ~= nil then
			RunConsoleCommand("NA_Map", ListMaps.TextEntry:GetValue())
		end
	end
	SetMap:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		SetMap:SetEnabled(true)
	end
	
	checkboxoffset = 75
	//No-collide players
	CheckBoxSvNocollide = vgui.Create( "DCheckBoxLabel", TabServer )
	CheckBoxSvNocollide:SetPos( 65,  checkboxoffset)
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
	
	//Serverwide godmode
	CheckBoxSvGodmode = vgui.Create( "DCheckBoxLabel", TabServer )
	CheckBoxSvGodmode:SetPos( 65,  checkboxoffset+25)
	CheckBoxSvGodmode:SetText( "Godmode" )
	CheckBoxSvGodmode:SetValue( na_godmode )
	CheckBoxSvGodmode:SizeToContents()
	CheckBoxSvGodmode.OnChange = function ()
		if CheckBoxSvGodmode:GetChecked() == true then
			checkval = 1
		else
			checkval = 0
		end
		
		if checkval ~= na_godmode then	
			RunConsoleCommand("NA_Godmode", checkval)
		end
	end
	CheckBoxSvGodmode:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		CheckBoxSvGodmode:SetEnabled(true)
	end
	
	//Noclip
	CheckBoxSvNoclip = vgui.Create( "DCheckBoxLabel", TabServer )
	CheckBoxSvNoclip:SetPos( 65,  checkboxoffset+50)
	CheckBoxSvNoclip:SetText( "Noclip" )
	CheckBoxSvNoclip:SetValue( na_noclip )
	CheckBoxSvNoclip:SizeToContents()
	CheckBoxSvNoclip.OnChange = function ()
		if CheckBoxSvNoclip:GetChecked() == true then
			checkval = 1
		else
			checkval = 0
		end
		
		if checkval ~= na_noclip then	
			RunConsoleCommand("NA_Noclip", checkval)
		end
	end
	CheckBoxSvNoclip:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		CheckBoxSvNoclip:SetEnabled(true)
	end
	
	//Notifications
	local lvNotifications = vgui.Create("DListView")
	lvNotifications:SetParent(TabServer)
	lvNotifications:SetPos(65, checkboxoffset+85)
	lvNotifications:SetSize(TabServer:GetWide()-65, 180)
	lvNotifications:SetMultiSelect(false)
	cMessage = lvNotifications:AddColumn("Message")
	cInterval = lvNotifications:AddColumn("Interval (seconds)")
	cMessage:SetWide(500)
	cMessage:SetTall(20)
	cInterval:SetWide(100)
	cInterval:SetTall(20)
	
	local Message = vgui.Create( "DTextEntry", TabServer )
	Message:SetPos( 65, checkboxoffset+269 )
	Message:SetTall( 20 )
	Message:SetWide( TabServer:GetWide()-65-50-100-10 )
	Message:SetEnterAllowed( true )
	
	local Interval = vgui.Create( "DTextEntry", TabServer )
	Interval:SetPos( TabServer:GetWide()-155, checkboxoffset+269 )
	Interval:SetTall( 20 )
	Interval:SetWide( 50 )
	Interval:SetValue(60)
	Interval:SetEnterAllowed( true )
	
	local AddMessage = vgui.Create( "DButton" )
	AddMessage:SetParent( TabServer )
	AddMessage:SetText( "Add" )
	AddMessage:SetPos( TabServer:GetWide()-100, checkboxoffset+269 )
	AddMessage:SetSize( 100, 20 )
	AddMessage.DoClick = function ()
		//Console command here
	end
	AddMessage:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		AddMessage:SetEnabled(true)
	end
end

function AddMap(name)
	//Add map to maplist
	table.insert(MapList, name)
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
	
	//Ban list
	local lvBans = vgui.Create("DListView")
	lvBans:SetParent(TabBans)
	lvBans:SetPos(0, 0)
	lvBans:SetSize(TabBans:GetWide(), 339)
	lvBans:SetMultiSelect(false)
	
	local cNick = lvBans:AddColumn("Nickname")
	local cSteamID = lvBans:AddColumn("SteamID")
	local cReason = lvBans:AddColumn("Reason")
	local cUnban = lvBans:AddColumn("Unban")
	
	cNick:SetWide(200)
	cSteamID:SetWide(100)
	cUnban:SetWide(100)
	cReason:SetWide(200)
	
	//Fill ban list
	for k, v in pairs(bantable) do
		local pars = string.Explode("[split]", v)
		if pars[3] == 0 then
			unbannedwhen = "Never"
		else
			if os.date("%x", pars[3]) == os.date("%x", os.time()) then
				unbannedwhen = os.date("Today %X", tonumber(pars[3]))
			else
				unbannedwhen = os.date("%x", tonumber(pars[3]))
			end
		end
		lvBans:AddLine(pars[1], pars[2], "", unbannedwhen)
	end
	
	//Filter textbox
	BanFilter = vgui.Create( "DTextEntry", TabBans )
	BanFilter:SetPos( 0, 344 )
	BanFilter:SetTall( 20 )
	BanFilter:SetWide( TabBans:GetWide() )
	BanFilter:SetEnterAllowed( true )
	BanFilter.OnTextChanged = function()
		BFilter = BanFilter:GetValue()
		FillBanList()
	end
end