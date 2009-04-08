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
	if HasPrivilege(LocalPlayer(), "Edit messages") then cmdAdd:SetEnabled( true ) end
	
	cmdRemove = vgui.Create( "DButton", TabMessages )
	cmdRemove:SetPos( TabMessages:GetWide() - 55, 0 )
	cmdRemove:SetSize( 55, 20 )
	cmdRemove:SetText( "Remove" )
	cmdRemove.DoClick = function() RemoveMessage() end
	cmdRemove:SetEnabled( false )
	if HasPrivilege(LocalPlayer(), "Edit messages") then cmdRemove:SetEnabled( true ) end
	
	//Current messages
	cbMessages = vgui.Create( "DComboBox", TabMessages )
	cbMessages:SetPos( 0, 25 )
	cbMessages:SetSize( TabMessages:GetWide(), TabMessages:GetTall() - 41 )
	cbMessages:SetMultiple( false )
	
	Tabs:AddSheet( "Messages", TabMessages, "gui/silkicons/comments", false, false, "Set messages to be displayed every X seconds" )
end
RegisterTab( MessagesTab, 2 )

function UpdateMessageList( ForceUpdate )
	if !LocalPlayer():GetNWBool("MessagesUp2Date") or ForceUpdate then
		cbMessages:Clear()
		RunConsoleCommand( "NA_UpdateMessages" )
	end
end
RegisterOnOpen( UpdateMessageList )

function SetButtons()
	cmdAdd:SetEnabled( false )
	if HasPrivilege(LocalPlayer(), "Edit messages") then cmdAdd:SetEnabled( true ) end
	cmdRemove:SetEnabled( false )
	if HasPrivilege(LocalPlayer(), "Edit messages") then cmdRemove:SetEnabled( true ) end
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
			umsg.Start( "NA_UpdateMsgs", ply )
				umsg.Bool( i == 1)
				umsg.String( m )
			umsg.End()
		end
		//Tell ply's client he has the up to date message list now!
		ply:SetNWBool( "MessagesUp2Date", true )
	end
	concommand.Add( "NA_UpdateMessages", NA_UpdateMessages )
	
	function NA_AddMessage( ply, com, args )
		if !HasPrivilege(ply, "Edit messages") then return false end
		table.insert( Messages, args[1] )
		SaveMessages()
		
		//Tell everyone the message list has changed
		for _, v in pairs(player.GetAll()) do
			ply:SetNWBool( "MessagesUp2Date", false )
		end
	end
	concommand.Add( "NA_AddMessage", NA_AddMessage )
	
	function NA_RemoveMessage( ply, com, args )
		if !HasPrivilege(ply, "Edit messages") then return false end
		for i, e in pairs(Messages) do
			if e == args[1] then table.remove( Messages, i ) end
		end
		SaveMessages()
		
		//Tell everyone the message list has changed (Works kind of like Invalidate)
		for _, v in pairs(player.GetAll()) do
			ply:SetNWBool( "MessagesUp2Date", false )
		end
	end
	concommand.Add( "NA_RemoveMessage", NA_RemoveMessage )
	
	CurMessageID = 1
	function NextMessage()
		if #Messages > 0 then
			if CurMessageID > #Messages then CurMessageID = 1 end
			NA_Notify( Messages[CurMessageID], NOTIFY_GENERIC )
			for _, v in pairs(player.GetAll()) do v:PrintMessage( HUD_PRINTTALK, Messages[CurMessageID] ) end
			CurMessageID = CurMessageID + 1
		end
	end
	timer.Create( "MessageScroller", 120, 0, NextMessage )
end
if CLIENT then
	function NA_UpdateMsgs( um )
		local i = um:ReadBool()
		local m = um:ReadString()
		
		FI = cbMessages:AddItem( m )
		if i then cbMessages:SelectItem( FI ) end
	end
	usermessage.Hook( "NA_UpdateMsgs", NA_UpdateMsgs )
end

function AddMessage()
	if txtMessage:GetValue() == "" then return false end
	RunConsoleCommand( "NA_AddMessage", txtMessage:GetValue() )
	txtMessage:SetText( "" )
	UpdateMessageList( true )
end

function RemoveMessage()
	if cbMessages:GetSelectedItems()[1] ~= nil then
		RunConsoleCommand( "NA_RemoveMessage", cbMessages:GetSelectedItems()[1]:GetValue() )
		UpdateMessageList( true )
	end
end