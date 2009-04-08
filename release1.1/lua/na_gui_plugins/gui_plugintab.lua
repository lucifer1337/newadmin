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
RegisterTab( PluginTab, 3 )

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