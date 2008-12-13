//This is like the plugin manager, but allows plugins to add controls to the gui
function ShowMenu()
	if !AdminPanel then BuildMenu() end
	
	RefillPlayers()
	AdminPanel:SetVisible( true )
end
concommand.Add( "+NA_Menu", ShowMenu )

function HideMenu()
	AdminPanel:SetVisible( false )
end
concommand.Add( "-NA_Menu", HideMenu )

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
	
	Players = vgui.Create( "DComboBox", TabPlayers )
	Players:SetPos( 0, 0 )
	Players:SetSize( TabPlayers:GetWide() - 150 , TabPlayers:GetTall() - 17 ) 
	Players:SetMultiple( false )
	RefillPlayers()
	
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