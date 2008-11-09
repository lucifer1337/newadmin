//Action command
function Me( ply, params )
	if params[1] ~= nil then
		local collect = ""
		for k, v in pairs(params) do
			collect = collect .. v .. " "
		end
		
		for k, v in pairs(player.GetAll()) do
			v:PrintMessage( HUD_PRINTTALK, ply:Nick() .. " " .. collect )
		end
	end
end
AddCommand( "Me", "This chat command displays an action", "me", "me <message>", Me, 0, "Overv", 6)

//Private messages available for everyone to everyone
function PM( ply, params )
	if params[1] ~= nil and params[2] ~= nil then
		local pl = GetPlayerByPart( params[1] )
		
		if pl ~= nil then
			local collect = ""
			for k, v in pairs(params) do
				if k > 1 then collect = collect .. v .. " " end
			end
			
			pl:PrintMessage( HUD_PRINTTALK, "(" .. ply:Nick() .. ") " .. collect )
			ply:PrintMessage( HUD_PRINTTALK, "(To " .. pl:Nick() .. ") " .. collect )
			
			SendNotify( pl, "You've received a private message!")
			SendNotify( ply, "Private message sent")
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Private Message", "Use this command to send private messages", "pm", "pm <user> <message>", PM, 0, "Overv", 6)

//Whisper to anyone within 64 inches
function Whisper( ply, params )
	if params[1] ~= nil then
		local message = ""
		for _, v in pairs(params) do
			message = message .. v .. " "
		end
	
		//Find players near you
		local hearit = false
		for k, v in pairs(player.GetAll()) do
			if v:GetPos():Distance( ply:GetPos() ) <= 64 and ply:UserID() ~= v:UserID() then
				v:PrintMessage( HUD_PRINTTALK, "(" .. ply:Nick() .. " whispers) " .. message )
				hearit = true
			end
		end
		ply:PrintMessage( HUD_PRINTTALK, "(You whisper) " .. message )
		
		if hearit == false then
			SendNotify( ply, "Nobody heard you" )
		end
	end
end
AddCommand( "Whisper", "Whisper messages to people close to you", "w", "w <message>", Whisper, 0, "Overv", 6)

//Imitate someone
function Imitate( ply, params )
	if params[1] ~= nil and params[2] ~= nil then
		local pl = GetPlayerByPart( params[1] )
		
		if pl ~= nil then
			local collect = ""
			for k, v in pairs(params) do
				if k > 1 then collect = collect .. v .. " " end
			end
			
			gamemode.Call("PlayerSay", pl, "test")
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Imitate", "Use this command to let someone of your choice say something", "imitate", "imitate <user> <message>", Imitate, 1, "Overv", 6)

//Display the time
function Time( ply, params )
	NotifyAll( "The time is now: " .. os.date("%H:%M:%S") )
end
AddCommand( "Time", "Display the time in the chat", "time", "time", Time, 0, "Overv", 6)