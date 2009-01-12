include("vgui_commandbutton.lua")
LCommand = nil
CommandList = {}

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
	
	//Building command list
	for _, v in pairs(CommandList) do
		RegisterPlayerMenu( v.Text, v.CategoryID, v.ChatString )
	end
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

//Functions to handle the player command list
//ChatString should be like this for for example !god:
//!god [gui.playername]
//The framework will then automatically fill in [gui.playername] :)
PlayerMenuItems = {}
Categories = {}
function RegisterPlayerMenu( Text, CategoryID, ChatString )
	if !AdminPanel then BuildMenu() end

	//First collect some info
	local temp = {}
	temp.Text = Text
	temp.CategoryID = CategoryID
	temp.ChatString = ChatString
	
	//Now make the item itself
	local Temp = vgui.Create( "CommandButton", GetCategoryControlByCategoryID(CategoryID) )
	Temp:SetText( Text )
	Temp:SetPos( 0, MenuItemsInCategory(CategoryID) * 15 )
	Temp:SetSize( pCommandList:GetWide() - 2, 15 )
	Temp.OnMousePressed = function()
		RunConsoleCommand( "say", "!" .. ChatString .. " " .. string.Explode( " (", Players:GetSelectedItems()[1]:GetValue() )[1] )
	end
	if MenuItemsInCategory(CategoryID) / 2 == math.floor(MenuItemsInCategory(CategoryID) / 2) then
		Temp:SetAlt( true )
	end
	
	temp.Control = Temp
	table.insert( PlayerMenuItems, temp )
	Temp = nil
	GetCategoryControlByCategoryID(CategoryID):SetTall( 15 * MenuItemsInCategory(CategoryID) )
end

//The delay system that unfortunately is nescesarry
function AddPlayerMenu( Text, CategoryID, ChatString )
	if !CLIENT then return false end
	
	local Temp = {}
	Temp.Text = Text
	Temp.CategoryID = CategoryID
	Temp.ChatString = ChatString
	table.insert( CommandList, Temp )
end

//Add a category header like "Administration"
function AddCategory( Text, CategoryID )
	local CatTempHeader = vgui.Create( "DCollapsibleCategory", pCommandList ) 
	CatTempHeader:SetPos( 1, #Categories * 23 )
	CatTempHeader:SetSize( pCommandList:GetWide() - 2, 50 )
	CatTempHeader:SetExpanded( 0 )
	CatTempHeader:SetLabel( Text )
	
	local CatTempContainer = vgui.Create( "DPanelList" )
	CatTempContainer:SetAutoSize( false )
	CatTempContainer:SetWide( CatTempHeader:GetWide() )
	CatTempContainer:SetTall( 0 )
	CatTempContainer:SetSpacing( 5 )
	CatTempContainer:EnableHorizontal( false )
	
	CatTempHeader:SetContents( CatTempContainer )
	
	local Temp = {}
	Temp.Text = Text
	Temp.CategoryID = CategoryID
	Temp.Header = CatTempHeader
	Temp.Container = CatTempContainer
	
	table.insert( Categories, Temp )
end

//Get a category control by its category ID
function GetCategoryControlByCategoryID( CategoryID )
	for _, i in pairs( Categories ) do
		if i.CategoryID == CategoryID then
			return i.Container
		end
	end
end

//Get the amount of menu items in a category
function MenuItemsInCategory( CategoryID )
	amount = 0
	for _, i in pairs(PlayerMenuItems) do
		if i.CategoryID == CategoryID then amount = amount + 1 end
	end
	
	return amount
end

//Create the base categories
function CreateCategories()
	AddCategory( "Administration", 1 )
	AddCategory( "Actions", 2 )
	AddCategory( "Teleportation", 5 )
	AddCategory( "Punishment", 3 )
end

//Timer to move the categories when expanding etc.
function MoveCategories()
	local CurrentTop = 0
	for _, v in pairs(Categories) do
		v.Header:SetPos( 0, CurrentTop )
		CurrentTop = CurrentTop + v.Header:GetTall() + 1
	end
end
timer.Create( "MoveStuff", 0.01, 0, MoveCategories )