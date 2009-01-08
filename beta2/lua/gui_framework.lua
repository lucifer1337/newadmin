include("vgui_commandbutton.lua")
LCommand = nil

//This is like the plugin manager, but allows plugins to add controls to the gui
function ShowMenu( ply )
	if Flag(LocalPlayer()) < 1 then return false end
	if !AdminPanel then BuildMenu() end
	
	RefillPlayers()
	AdminPanel:SetVisible( true )
	AllowClose = true
end
concommand.Add( "+NA_Menu", ShowMenu )

function HideMenu()
	if AllowClose then AdminPanel:SetVisible( false ) end
end
concommand.Add( "-NA_Menu", HideMenu )

//Hooks for keeping the menu open when the cursor is in a textbox
function KeyboardFocusOn( pnl )
	if pnl ~= AdminPanel then return end
	
	AllowClose = false
	AdminPanel:SetKeyboardInputEnabled( true )
end
hook.Add( "OnTextEntryGetFocus", "KeyboardFocusOn", KeyboardFocusOn )

function KeyboardFocusOff( pnl )
	AllowClose = true
	AdminPanel:SetKeyboardInputEnabled( false )
end
hook.Add( "OnTextEntryLoseFocus", "KeyboardFocusOff", KeyboardFocusOff )

//Building the menu
function BuildMenu()
	w, h = 600, 400

	//Main frame
	AdminPanel = vgui.Create( "DFrame" )
	AdminPanel:SetPos( ScrW() / 2 - w / 2, ScrH() / 2 - h / 2 )
	AdminPanel:SetSize( w, h )
	AdminPanel:SetTitle( "" )
	AdminPanel:SetVisible( false )
	AdminPanel:SetDraggable( false )
	AdminPanel:ShowCloseButton( false )
	AdminPanel:MakePopup()
	AdminPanel.Paint = function()
	end
	
	//Tabs
	Tabs = vgui.Create( "DPropertySheet" )
	Tabs:SetParent( AdminPanel )
	Tabs:SetPos( 0, 0 )
	Tabs:SetSize( w, h )
	
	PlayerTab()
	PluginTab()
end

//Tab showing all plugins
function PluginTab()
	//Main panel
	TabPlugin = vgui.Create( "DPanel", Tabs )
	TabPlugin:SetPos( 5, 10 )
	TabPlugin:SetSize( w - 10, h - 15 )
	TabPlugin.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabPlugin:GetWide(), TabPlugin:GetTall() )
	end
	
	//Plugin categories
	PluginCats = vgui.Create( "DMultiChoice", TabPlugin )
	PluginCats:SetPos( 0, 0 )
	PluginCats:SetSize( TabPlugin:GetWide(), 20 )
	PluginCats:AddChoice( "All (" .. table.Count(Commands) .. ")" )
	PluginCats:AddChoice( "Administration (" .. CommandsInCategory(1) .. ")" )
	PluginCats:AddChoice( "Player Actions (" .. CommandsInCategory(2) .. ")" )
	PluginCats:AddChoice( "Punishment (" .. CommandsInCategory(3) .. ")" )
	PluginCats:AddChoice( "Server Management (" .. CommandsInCategory(4) .. ")" )
	PluginCats:AddChoice( "Teleportation (" .. CommandsInCategory(5) .. ")" )
	PluginCats:AddChoice( "Chat (" .. CommandsInCategory(6) .. ")" )
	PluginCats:AddChoice( "User Groups (" .. CommandsInCategory(7) .. ")" )
	PluginCats:AddChoice( "Other (" .. CommandsInCategory(8) .. ")" )
	PluginCats:ChooseOptionID( 1 )
	PluginCats:SetEditable( false )
	
	PluginCats.OnSelect = function()
		local id = ChoiceGetOptionID( PluginCats, 9, PluginCats.TextEntry:GetValue() )
		if id == 1 then FillPluginList() else FillPluginList( id - 1 ) end
	end
	
	//Listview with plugins
	Plugins = vgui.Create("DListView") 
	Plugins:SetParent( TabPlugin )
	Plugins:SetPos( 0, 25 )
	Plugins:SetSize( TabPlugin:GetWide(), TabPlugin:GetTall() - 42 )
	Plugins:SetMultiSelect( false )
	local colTitl = Plugins:AddColumn( "Title" )
	local colDesc = Plugins:AddColumn( "Description" )
	local colAuth = Plugins:AddColumn( "Author" )
	colTitl:SetWide( 100 )
	colDesc:SetWide( 400 )
	colAuth:SetWide( 100 )
	
	FillPluginList()
	
	Plugins:SortByColumn( 1 )
	Plugins:SelectFirstItem()
	
	Tabs:AddSheet( "Plugins", TabPlugin, "gui/silkicons/plugin", false, false, "List of all loaded plugins" ) 
end

function FillPluginList( FilterCat )
	Plugins:Clear()
	for _, v in pairs(Commands) do
		if tonumber(v.CategoryID) == tonumber(FilterCat) or FilterCat == nil then
			Plugins:AddLine( v.Title, v.Description, v.Author )
		end
	end
	Plugins:SortByColumn( 1 )
	Plugins:SelectFirstItem()
end

//Tab with all the player functions including actions and punishment
function PlayerTab()
	//Main panel
	TabPlayers = vgui.Create( "DPanel", Tabs )
	TabPlayers:SetPos( 5, 10 )
	TabPlayers:SetSize( w - 10, h - 15 )
	TabPlayers.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabPlayers:GetWide(), TabPlayers:GetTall() )
	end
	
	//Playerlist
	Players = vgui.Create( "DComboBox", TabPlayers )
	Players:SetPos( 0, 0 )
	Players:SetSize( TabPlayers:GetWide() - 150 , TabPlayers:GetTall() - 42 ) 
	Players:SetMultiple( false )
	RefillPlayers()
	
	//Filter textbox
	PlayerFilter = vgui.Create( "DTextEntry", TabPlayers )
	PlayerFilter:SetPos( 0, TabPlayers:GetTall() - 37 )
	PlayerFilter:SetTall( 20 )
	PlayerFilter:SetWide( TabPlayers:GetWide() - 150 )
	
	//Container of all the player commands
	pCommandList = vgui.Create( "DPanelList", TabPlayers )
	pCommandList:EnableVerticalScrollbar( true )
	pCommandList:SetPos( TabPlayers:GetWide() - 145, 0 )
	pCommandList:SetTall( TabPlayers:GetTall() - 17 )
	pCommandList:SetWide( 145 )
	
	CreateCategories()
	
	Tabs:AddSheet( "Players", TabPlayers, "gui/silkicons/user", false, false, "Apply actions and punishment to players" ) 
end

function RefillPlayers()
	Players:Clear()
	
	for i, v in pairs(player.GetAll()) do
		if Flag(v) < 1 then
			FPlayer = Players:AddItem( v:Nick() )
		else
			if Flag( v ) == 1 then
				Class = "Admin"
			elseif Flag( v ) == 2 then
				Class = "Superadmin"
			elseif Flag( v ) == 3 then
				Class = "Owner"
			end
			
			FPlayer = Players:AddItem( v:Nick() .. " (" .. Class .. ")" )
		end
		
		if i == 1 then Players:SelectItem( FPlayer ) end
	end
end

//Creates the command categories and list
function CreateCategories()
	//Player Administration
	catAdministration = vgui.Create( "DCollapsibleCategory", pCommandList ) 
	catAdministration:SetPos( 1, 0 )
	catAdministration:SetSize( pCommandList:GetWide() - 2, 50 )
	catAdministration:SetExpanded( 0 )
	catAdministration:SetLabel( "Administration" )
	
	CommandsAdmin = vgui.Create( "DPanelList" )
	CommandsAdmin:SetAutoSize( false )
	CommandsAdmin:SetWide( catAdministration:GetWide() )
	CommandsAdmin:SetTall( table.Count(GetCategory(1)) * 15 )
	CommandsAdmin:SetSpacing( 5 )
	CommandsAdmin:EnableHorizontal( false )
	catAdministration:SetContents( CommandsAdmin )
	
	CommandButtons = {}
	i = 0
	c = false
	for _, v in pairs( GetCategory(1) ) do
		local Temp = vgui.Create( "CommandButton", CommandsAdmin )
		Temp:SetText( v.Title )
		Temp:SetPos( 0, i * 15 )
		Temp:SetSize( CommandsAdmin:GetWide(), 15 )
		Temp.OnMousePressed = function()
			RunConsoleCommand( "say", "!" .. v.ChatCommand .. " " .. string.Explode( " (", Players:GetSelectedItems()[1]:GetValue() )[1] )
		end
		Temp:SetAlt( c )
		table.insert( CommandButtons, Temp )
		
		i = i + 1
		c = !c
	end
	
	//Player Actions
	catActions = vgui.Create( "DCollapsibleCategory", pCommandList ) 
	catActions:SetPos( 1, 23 )
	catActions:SetSize( pCommandList:GetWide() - 2, 22 )
	catActions:SetExpanded( 0 )
	catActions:SetLabel( "Actions" )
	
	CommandsActions = vgui.Create( "DPanelList" )
	CommandsActions:SetAutoSize( false )
	CommandsActions:SetWide( catActions:GetWide() )
	CommandsActions:SetTall( table.Count(GetCategory(2)) * 15 )
	CommandsActions:SetSpacing( 5 )
	CommandsActions:EnableHorizontal( false )
	catActions:SetContents( CommandsActions )
	
	i = 0
	c = false
	for _, v in pairs( GetCategory(2) ) do
		local Temp = vgui.Create( "CommandButton", CommandsActions )
		Temp:SetText( v.Title )
		Temp:SetPos( 0, i * 15 )
		Temp:SetSize( CommandsActions:GetWide(), 15 )
		Temp.OnMousePressed = function()
			RunConsoleCommand( "say", "!" .. v.ChatCommand .. " " .. string.Explode( " (", Players:GetSelectedItems()[1]:GetValue() )[1] )
		end
		Temp:SetAlt( c )
		table.insert( CommandButtons, Temp )
		
		i = i + 1
		c = !c
	end
	
	timer.Create( "tmMoveActions", 0.01, 0, function() catActions:SetPos( 0, catAdministration:GetTall() + 1 ) end )
	
	//Player Punishment
	catPunishment = vgui.Create( "DCollapsibleCategory", pCommandList ) 
	catPunishment:SetPos( 1, 46 )
	catPunishment:SetSize( pCommandList:GetWide() - 2, 22 )
	catPunishment:SetExpanded( 0 )
	catPunishment:SetLabel( "Punishment" )
	
	CommandsPunishment = vgui.Create( "DPanelList" )
	CommandsPunishment:SetAutoSize( false )
	CommandsPunishment:SetWide( catPunishment:GetWide() )
	CommandsPunishment:SetTall( table.Count(GetCategory(3)) * 15 )
	CommandsPunishment:SetSpacing( 5 )
	CommandsPunishment:EnableHorizontal( false )
	catPunishment:SetContents( CommandsPunishment )
	
	i = 0
	c = false
	for _, v in pairs( GetCategory(3) ) do
		local Temp = vgui.Create( "CommandButton", CommandsPunishment )
		Temp:SetText( v.Title )
		Temp:SetPos( 0, i * 15 )
		Temp:SetSize( CommandsPunishment:GetWide(), 15 )
		Temp.OnMousePressed = function()
			RunConsoleCommand( "say", "!" .. v.ChatCommand .. " " .. string.Explode( " (", Players:GetSelectedItems()[1]:GetValue() )[1] )
		end
		Temp:SetAlt( c )
		table.insert( CommandButtons, Temp )
		
		i = i + 1
		c = !c
	end
	
	timer.Create( "tmMovePunishment", 0.01, 0, function() catPunishment:SetPos( 0, catAdministration:GetTall() + catActions:GetTall() + 2 ) end )
	
	//Player Teleportation
	catTeleportation = vgui.Create( "DCollapsibleCategory", pCommandList ) 
	catTeleportation:SetPos( 1, 69 )
	catTeleportation:SetSize( pCommandList:GetWide() - 2, 22 )
	catTeleportation:SetExpanded( 0 )
	catTeleportation:SetLabel( "Teleporting" )
	
	CommandsTeleportation = vgui.Create( "DPanelList" )
	CommandsTeleportation:SetAutoSize( false )
	CommandsTeleportation:SetWide( catTeleportation:GetWide() )
	CommandsTeleportation:SetTall( table.Count(GetCategory(5)) * 15 )
	CommandsTeleportation:SetSpacing( 5 )
	CommandsTeleportation:EnableHorizontal( false )
	catTeleportation:SetContents( CommandsTeleportation )
	
	i = 0
	c = false
	for _, v in pairs( GetCategory(5) ) do
		local Temp = vgui.Create( "CommandButton", CommandsTeleportation )
		Temp:SetText( v.Title )
		Temp:SetPos( 0, i * 15 )
		Temp:SetSize( CommandsTeleportation:GetWide(), 15 )
		Temp.OnMousePressed = function()
			RunConsoleCommand( "say", "!" .. v.ChatCommand .. " " .. string.Explode( " (", Players:GetSelectedItems()[1]:GetValue() )[1] )
		end
		Temp:SetAlt( c )
		table.insert( CommandButtons, Temp )
		
		i = i + 1
		c = !c
	end
	
	timer.Create( "tmMoveTeleportation", 0.01, 0, function() catTeleportation:SetPos( 0, catAdministration:GetTall() + catActions:GetTall() + catPunishment:GetTall() + 3 ) end )
end