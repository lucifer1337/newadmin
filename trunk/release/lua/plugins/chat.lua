//Action command
function Me( ply, params )
	local collect = table.concat( params, " " )
	
	for _, v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTTALK, ply:Nick() .. " " .. collect )
	end
end
RegisterCommand( "Me", "This chat command displays an action", "me", "me <message>", 0, "Overv", 6, 1, Me )

//Private messages available for everyone to everyone
function PM( ply, params )
	local collect = ""
	for k, v in pairs(params) do
		if k > 1 then collect = collect .. v .. " " end
	end
	
	params[1]:PrintMessage( HUD_PRINTTALK, "(From " .. ply:Nick() .. ") " .. collect )
	ply:PrintMessage( HUD_PRINTTALK, "(To " .. params[1]:Nick() .. ") " .. collect )
	
	NA_Notify( "You've received a private message!", nil, params[1] )
	NA_Notify( "Private message sent", nil, ply )
end
RegisterCommand( "Private Message", "Use this command to send private messages", "pm", "pm <user> <message>", 0, "Overv", 6, 2, PM )
RegisterCheck( "Private Message", 1, 1, "Player '%arg%' not found!" )

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
			if v:GetPos():Distance( ply:GetPos() ) <= 128 and ply:UserID() ~= v:UserID() then
				v:PrintMessage( HUD_PRINTTALK, "(" .. ply:Nick() .. " whispers) " .. message )
				hearit = true
			end
		end
		ply:PrintMessage( HUD_PRINTTALK, "(You whisper) " .. message )
		
		if hearit == false then
			NA_Notify( "Nobody heard you", nil, ply )
		end
	end
end
RegisterCommand( "Whisper", "Whisper messages to people close to you", "w", "w <message>", 0, "Overv", 6, 1, Whisper )

//Admin talk
function ChatAdmin( ply, params )
	local Message = table.concat( params, " " )
	for _, v in pairs(player.GetAll()) do
		if HasPrivilege(v, "Admin Chat") then v:PrintMessage( HUD_PRINTTALK, "(ADMIN - " .. ply:Nick() .. ") " .. Message ) end
	end
end
RegisterCommand( "Admin Chat", "Send a message to all admins", "a", "a <message>", 1, "Overv", 6, 1, ChatAdmin )

//Display the time
function Time( ply, params )
	NA_Notify( "The time is now: " .. os.date("%H:%M:%S") )
end
RegisterCommand( "Time", "Display the time in the chat", "time", "time", 0, "Overv", 6, 0, Time )

//Imitate a player
function Imitate( ply, params )
	if params[1]:SteamID() == "BOT" then
		NA_Notify( "You can't imitate bots!", "NOTIFY_ERROR", ply )
		Log( ply:Nick() .. " tried to imitate a bot" )
		return false
	end

	local collect = ""
	for k, v in pairs(params) do
		if k > 1 then collect = collect .. v .. " " end
	end
	
	if ply:EntIndex() == params[1]:EntIndex() then
		timer.Simple( 1, function() makePlayerSay( params[1], collect ) end )
	else
		makePlayerSay( params[1], collect )
	end
	
	Log( ply:Nick() .. " imitated " .. params[1]:Nick() )
end
RegisterCommand( "Imitate", "Let a player say something!", "im", "im <user> <message>", 2, "Overv", 6, 2, Imitate )
RegisterCheck( "Imitate", 1, 1, "Player '%arg%' not found!" )

function makePlayerSay(ply, message)
	ply:ConCommand("say " .. message .. "\n")
end

//Muting
function Mute( ply, params )
	params[1]:SetNWBool( "Muted", true )
	NA_Notify( ply:Nick() .. " has muted " .. params[1]:Nick() )
end
RegisterCommand( "Mute", "Mute a player", "mute", "mute [name]", 1, "Overv", 3, 0, Mute )
RegisterCheck( "Mute", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Mute", 3, "mute [PLAYER]", "unmute [PLAYER]", "Muted" )

function UnMute( ply, params )
	params[1]:SetNWBool( "Muted", false )
	NA_Notify( ply:Nick() .. " has unmuted " .. params[1]:Nick() )
end
RegisterCommand( "UnMute", "Unmute a player", "unmute", "unmute [name]", 1, "Overv", 3, 0, UnMute )
RegisterCheck( "UnMute", 1, 3, "Player '%arg%' not found!" )

if SERVER then
	function MuteCheck( ply, msg )
		if ply:GetNWBool("Muted") and string.Left(msg, 1) != "!" then
			ply:PrintMessage( HUD_PRINTTALK, "You are muted!" )
			return ""
		end
	end
	hook.Add("PlayerSay", "MuteCheck", MuteCheck)
end