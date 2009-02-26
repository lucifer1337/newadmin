//Load all the files for the NewAdmin framework and share them with clients
AddCSLuaFile( "autorun/na_autorun.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "plugin_manager.lua" )
AddCSLuaFile( "framework.lua" )
AddCSLuaFile( "gui_framework.lua" ) //No include, cause this is client only ;)
AddCSLuaFile( "vgui_commandbutton.lua" )
AddCSLuaFile( "cl_notify.lua" )
include( "plugin_manager.lua" )
include( "framework.lua" )
include( "gui_framework.lua" )
include( "beta_manager.lua" ) //BETA FUNCTIONS

//Loading message start
EngineLoading = true
Msg( "\n===================================================\n" )
Msg( "NewAdmin 1.0\n\n" )

//Load plugins into framework serverside
local gui_plugins = file.FindInLua("gui_plugins/*.lua")
for _, filename in pairs( gui_plugins ) do
	Msg( "Loading: " .. filename .. "\n" )
	AddCSLuaFile( "gui_plugins/" .. filename )
	include( "gui_plugins/" .. filename )
end

local plugins = file.FindInLua("plugins/*.lua")
for _, filename in pairs( plugins ) do
	Msg( "Loading: " .. filename .. "\n" )
	AddCSLuaFile( "plugins/" .. filename )
	include( "plugins/" .. filename )
end

//End loading message
Msg( "===================================================\n\n" )
EngineLoading = false

//Scan chatmessages for function calls
function CheckCalls( ply, Message )
	//Command?
	if string.Left( Message, 1 ) == "!" then
		for _, v in pairs( Commands ) do
			if GetCommand(Message) == v.ChatCommand then
				CallCommand( GetCommand(Message), ply, GetArguments(Message) )
				return ""
			end
		end
		
		NA_Notify( "Unknown command '" .. GetCommand(Message) .. "'", "NOTIFY_ERROR", ply )
		return ""
	end
end
hook.Add( "PlayerSay", "CheckCalls", CheckCalls )

//Commands can also be called using a console command (used for the menu to work faster)
function NA_CallCommand( ply, com, args )
	local Message = args[1]
	local Caller = ply
	CheckCalls( Caller, Message )
end
concommand.Add( "NA_CallCommand", NA_CallCommand )

//Let clients know we're running NewAdmin on the server
function EnableNA( ply )
	ply:SendLua( "NAOnServer = true" )
end
hook.Add( "PlayerInitialSpawn", "EnableNA", EnableNA )

function ReHook()
	hook.Remove( "PlayerSay", "CheckCalls" )
	hook.Add( "PlayerSay", "CheckCalls", CheckCalls )
end
timer.Create( "tmRehook", 1, 0, ReHook )