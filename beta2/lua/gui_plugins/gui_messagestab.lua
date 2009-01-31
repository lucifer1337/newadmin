Messages = {}
resource.AddFile( "materials/gui/silkicons/comments.vmt" )
resource.AddFile( "materials/gui/silkicons/comments.vtf" )

//Tab for controlling messages
function MessagesTab()
	//Main panel
	TabMessages = vgui.Create( "DPanel", Tabs )
	TabMessages:SetPos( 5, 10 )
	TabMessages:SetSize( w - 10, h - 15 )
	TabMessages.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 255 )
		surface.DrawRect( 0, 0, TabMessages:GetWide(), TabMessages:GetTall() )
	end
	
	//Add message part
	txtMessage = vgui.Create( "DTextEntry", TabMessages )
	txtMessage:SetPos( 0, 0 )
	txtMessage:SetTall( 20 )
	txtMessage:SetWide( TabMessages:GetWide() - 120 )
	txtMessage.OnEnter = function() AddMessage() end
	
	cmdAdd = vgui.Create( "DButton", TabMessages )
	cmdAdd:SetPos( TabMessages:GetWide() - 115, 0 )
	cmdAdd:SetSize( 55, 20 )
	cmdAdd:SetText( "Add" )
	cmdAdd.DoClick = function() AddMessage() end
	cmdAdd:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdAdd:SetEnabled( true ) end
	
	cmdRemove = vgui.Create( "DButton", TabMessages )
	cmdRemove:SetPos( TabMessages:GetWide() - 55, 0 )
	cmdRemove:SetSize( 55, 20 )
	cmdRemove:SetText( "Remove" )
	cmdRemove.DoClick = function() RemoveMessage() end
	cmdRemove:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdRemove:SetEnabled( true ) end
	
	//Current messages
	cbMessages = vgui.Create( "DComboBox", TabMessages )
	cbMessages:SetPos( 0, 25 )
	cbMessages:SetSize( TabMessages:GetWide(), TabMessages:GetTall() - 41 )
	cbMessages:SetMultiple( false )
	
	Tabs:AddSheet( "Messages", TabMessages, "gui/silkicons/comments", false, false, "Set messages to be displayed every X seconds" )
end
RegisterTab( MessagesTab, 2 )

function UpdateMessageList()
	cbMessages:Clear()
	RunConsoleCommand( "NA_UpdateMessages" )
end
RegisterOnOpen( UpdateMessageList )

function SetButtons()
	cmdAdd:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdAdd:SetEnabled( true ) end
	cmdRemove:SetEnabled( false )
	if Flag(LocalPlayer()) > 2 then cmdRemove:SetEnabled( true ) end
end
RegisterOnOpen( SetButtons )

if SERVER then
	function SaveMessages()
		local txt = ""
		for _, m in pairs(Messages) do
			txt = txt .. m .. "\n"
		end
		file.Write( "NewAdmin/messages.txt", txt )
	end
	
	function LoadMessages()
		local fil = file.Read("NewAdmin/messages.txt")
		if fil != nil and string.find(fil, "\n") then
			Messages = string.Explode( "\n", fil )
			for i, e in pairs(Messages) do
				if e == "" then table.remove( Messages, i ) end
			end
		else
			Messages = {}
		end
	end
	LoadMessages()

	function NA_UpdateMessages( ply )
		for i, m in pairs(Messages) do
			if i == 1 then
				ply:SendLua( "FI = cbMessages:AddItem( \"" .. m .. "\" )" )
				ply:SendLua( "cbMessages:SelectItem( FI )" )
			else
				ply:SendLua( "cbMessages:AddItem( \"" .. m .. "\" )" )
			end
		end
	end
	concommand.Add( "NA_UpdateMessages", NA_UpdateMessages )
	
	function NA_AddMessage( ply, com, args )
		if Flag(ply) < 3 then return false end
		table.insert( Messages, args[1] )
		SaveMessages()
	end
	concommand.Add( "NA_AddMessage", NA_AddMessage )
	
	function NA_RemoveMessage( ply, com, args )
		if Flag(ply) < 3 then return false end
		for i, e in pairs(Messages) do
			if e == args[1] then table.remove( Messages, i ) end
		end
		SaveMessages()
	end
	concommand.Add( "NA_RemoveMessage", NA_RemoveMessage )
	
	function NA_ShowMessages( ply, com, args )
		for _, m in pairs(Messages) do
			Msg( m .. "\n" )
		end
	end
	concommand.Add( "NA_ShowMessages", NA_ShowMessages )
	
	CurMessageID = 1
	function NextMessage()
		if #Messages > 0 then
			if CurMessageID > #Messages then CurMessageID = 1 end
			Notify( Messages[CurMessageID], "NOTIFY_GENERIC" )
			for _, v in pairs(player.GetAll()) do v:PrintMessage( HUD_PRINTTALK, Messages[CurMessageID] ) end
			CurMessageID = CurMessageID + 1
		end
	end
	timer.Create( "MessageScroller", 120, 0, NextMessage )
end

function AddMessage()
	if txtMessage:GetValue() == "" then return false end
	RunConsoleCommand( "NA_AddMessage", txtMessage:GetValue() )
	txtMessage:SetText( "" )
	UpdateMessageList()
end

function RemoveMessage()
	if cbMessages:GetSelectedItems()[1] ~= nil then
		RunConsoleCommand( "NA_RemoveMessage", cbMessages:GetSelectedItems()[1]:GetValue() )
		UpdateMessageList()
	end
end