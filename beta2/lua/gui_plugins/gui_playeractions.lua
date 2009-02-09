//Tab with all the player functions including actions and punishment
LCommand = nil
CommandList = {}

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
	Players.OnMousePressed = function()
		for _, v in pairs(PlayerMenuItems) do v:InvalidateLayout() end
		Msg( "Redrawn!\n" )
	end
	
	//Filter textbox
	PlayerFilter = vgui.Create( "DTextEntry", TabPlayers )
	PlayerFilter:SetPos( 0, TabPlayers:GetTall() - 37 )
	PlayerFilter:SetTall( 20 )
	PlayerFilter:SetWide( TabPlayers:GetWide() - 150 )
	PlayerFilter.OnTextChanged = function()
		RefillPlayers()
	end
	RefillPlayers()
	
	//Container of all the player commands
	pCommandList = vgui.Create( "DPanelList", TabPlayers )
	pCommandList:EnableVerticalScrollbar( true )
	pCommandList:SetPos( TabPlayers:GetWide() - 145, 0 )
	pCommandList:SetTall( TabPlayers:GetTall() - 17 )
	pCommandList:SetWide( 145 )
	
	CreateCategories()
	
	//Building command list
	table.SortByMember( CommandList, "Text", true )
	for _, v in pairs(CommandList) do
		RegisterPlayerMenu( v.Text, v.CategoryID, v.OnCommand, v.OffCommand, v.CheckBoolean )
	end
	
	Tabs:AddSheet( "Players", TabPlayers, "gui/silkicons/user", false, false, "Apply actions and punishment to players" ) 
end
RegisterTab( PlayerTab, 1 )

function RefillPlayers()
	Players:Clear()
	local Filter = PlayerFilter:GetValue()
	PListItems = {}
	
	for i, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(Filter)) or v:Nick() == Filter then
			if Flag(v) < 1 then
				FPlayer = Players:AddItem( v:Nick() .. " (Guest)" )
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
			
			local ListItem = {}
			ListItem.Item = FPlayer
			ListItem.Ply = v:EntIndex()
			table.insert( PListItems, ListItem )
			
			if i == 1 then Players:SelectItem( FPlayer ) end
			if v == LocalPlayer() then Players:SelectItem( FPlayer ) end
		end
	end
end
RegisterOnOpen( RefillPlayers )

//Functions to handle the player command list
PlayerMenuItems = {}
Categories = {}
function RegisterPlayerMenu( Text, CategoryID, OnCommand, OffCommand, CheckBoolean )
	if !AdminPanel then BuildMenu() end

	//First collect some info
	local temp = {}
	temp.Text = Text
	temp.CategoryID = CategoryID
	temp.CheckBoolean = CheckBoolean
	temp.OnCommand = OnCommand
	temp.OffCommand = OffCommand
	
	//Now make the item itself
	local Temp = vgui.Create( "CommandButton", GetCategoryControlByCategoryID(CategoryID) )
	Temp:SetText( Text )
	Temp:SetPos( 0, MenuItemsInCategory(CategoryID) * 15 )
	Temp:SetSize( pCommandList:GetWide() - 2, 15 )
	if CheckBoolean ~= nil then
		Temp:AddCheckBox()
		Temp.OffCommand = OffCommand
		Temp.CheckBoolean = CheckBoolean
	end
	Temp.OnCommand = OnCommand
	
	//Set the color
	if MenuItemsInCategory(CategoryID) / 2 == math.floor(MenuItemsInCategory(CategoryID) / 2) then
		Temp:SetAlt( true )
	end
	
	temp.Control = Temp
	table.insert( PlayerMenuItems, temp )
	Temp = nil
	GetCategoryControlByCategoryID(CategoryID):SetTall( 15 * MenuItemsInCategory(CategoryID) )
end

//The delay system that unfortunately is nescesarry
function AddPlayerMenu( Text, CategoryID, OnCommand, OffCommand, CheckBoolean )
	if !CLIENT then return false end
	
	local Temp = {}
	Temp.Text = Text
	Temp.CategoryID = CategoryID
	Temp.CheckBoolean = CheckBoolean
	Temp.OnCommand = OnCommand
	Temp.OffCommand = OffCommand
	
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

//Get the real nick from the listbox
function GetSelectedPlayer()
	//Get the raw item from the listbox
	local SelItem = Players:GetSelected()
	for _, v in pairs(PListItems) do
		if v.Item == SelItem then
			return player.GetByID(v.Ply)
		end
	end
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