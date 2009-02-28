if CLIENT then include("vgui_commandbutton.lua") end
RTabs = {}
EOnOpen = {}

//This is like the plugin manager, but allows plugins to add controls to the gui
function ShowMenu( ply )
	//Listen server hack
	if LocalPlayer == nil then
		ply:SendLua( "ShowMenu()" )
		return false
	end

	if !HasPrivilege(LocalPlayer(), "Open menu") then return false end
	if !AdminPanel then BuildMenu() end
	
	//Functions that need to be ran when the menu is (re-)opened
	for _, t in pairs(EOnOpen) do
		t()
	end
	
	AdminPanel:SetVisible( true )
	AllowClose = true
end
concommand.Add( "+NA_Menu", ShowMenu )

function HideMenu( ply )
	//Listen server hack
	if LocalPlayer == nil then
		ply:SendLua( "HideMenu()" )
		return false
	end
	
	if AllowClose then AdminPanel:SetVisible( false ) end
end
concommand.Add( "-NA_Menu", HideMenu )

//Hooks for keeping the menu open when the cursor is in a textbox
function KeyboardFocusOn( pnl )
	if AdminPanel == nil then return  end
	
	AllowClose = false
	AdminPanel:SetKeyboardInputEnabled( true )
end
hook.Add( "OnTextEntryGetFocus", "KeyboardFocusOn", KeyboardFocusOn )

function KeyboardFocusOff( pnl )
	if AdminPanel == nil then return  end
	
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
	
	table.SortByMember( RTabs, "Position", true )
	for _, t in pairs(RTabs) do
		t.Function() //Build the tab with the registered function
	end
end

//Register a tab you want to add
function RegisterTab( TabBuildFunction, Position )
	local Temp = {}
	Temp.Function = TabBuildFunction
	Temp.Position = Position
	table.insert( RTabs, Temp )
end

//Register a function you want to run when a player re-opens the menu
function RegisterOnOpen( Function )
	table.insert( EOnOpen, Function )
end