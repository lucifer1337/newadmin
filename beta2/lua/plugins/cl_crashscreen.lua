//This file produces a white screen on the clients when the server disconnects without notice

if SERVER then
	function Ping( ply )
		umsg.Start( "PingMsg", ply )
			umsg.Long( os.time() )
		umsg.End()
	end
	concommand.Add( "PingServer", Ping )
end

if CLIENT then
	local PrevTime = -1
	local LastTime = 0
	local Disconnected = false
	local StTime = nil
	
	function PingServer()
		if PrevTime == LastTime then
			Disconnected = true
		else
			Disconnected = false
		end
		PrevTime = LastTime
	
		RunConsoleCommand( "PingServer" )
	end
	timer.Create( "Server Pinger", 3, 0, PingServer )
	
	function ReceivePing( um )
		LastTime = um:ReadLong()
	end
	usermessage.Hook( "PingMsg", ReceivePing )
	
	function DrawMessage()
		if StTime and os.time() > StTime + 10 then //Prevent the screen from showing up at initially spawning
			if Disconnected then
				surface.SetDrawColor( Color( 255, 255, 255 ) )
				surface.DrawRect( 0, 0, ScrW(), ScrH() )
				draw.SimpleText( "You have been disconnected from the server!", "Trebuchet22", ScrW() / 2, ScrH() / 2, Color(121, 121, 121, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Just disconnect and reconnect as soon as the server is back :)", "Default", ScrW() / 2, (ScrH() / 2) + 15, Color(121, 121, 121, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
	end
	hook.Add( "HUDPaint", "DrawMessage", DrawMessage )
	
	function SetSTime()
		local StTime = os.time()
	end
	timer.Simple( 1, SetSTime )
end