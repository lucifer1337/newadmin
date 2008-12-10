//This is like the plugin manager, but allows plugins to add controls to the gui
function ShowMenu()
	if !AdminPanel then BuildMenu() end
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
	
	//Listview with plugins
	Plugins = vgui.Create("DListView") 
	Plugins:SetParent( TabPlugin )
	Plugins:SetPos( 0, 0 )
	Plugins:SetSize( TabPlugin:GetWide(), TabPlugin:GetTall() - 16 )
	Plugins:SetMultiSelect( false )
	local colTitl = Plugins:AddColumn( "Title" )
	local colDesc = Plugins:AddColumn( "Description" )
	local colAuth = Plugins:AddColumn( "Author" )
	colTitl:SetWide( 100 )
	colDesc:SetWide( 400 )
	colAuth:SetWide( 100 )
	
	
	for _, v in pairs(Commands) do
		Plugins:AddLine( v.Title, v.Description, v.Author )
		Msg("Line added: " .. v.Title .. " - " .. v.Description .. " - " .. v.Author .. "\n")
	end
	
	Plugins:SelectFirstItem()
	
	Tabs:AddSheet( "Plugins", TabPlugin, "gui/silkicons/plugin", false, false, "List of all loaded plugins" ) 
end