//Load all the files for the NewAdmin framework
include( "plugin_manager.lua" )
include( "framework.lua" )

//Loading message start
Msg( "\n===================================================\n" )
Msg( "NewAdmin 1.0\n\n" )

//Load plugins into framework clientside
local plugins = file.FindInLua("plugins/*.lua")
for _, filename in pairs( plugins ) do
	include( "plugins/" .. filename )
	
	Msg( "Loaded file: " .. filename .. "\n" )
end

//End loading message
Msg( "\n===================================================\n\n" )