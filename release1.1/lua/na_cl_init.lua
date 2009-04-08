//Load all the files for the NewAdmin framework
include( "plugin_manager.lua" )
include( "cl_notify.lua" )
include( "framework.lua" )
include( "gui_framework.lua" )

//Loading message start
EngineLoading = true
Msg( "\n===================================================\n" )
Msg( "NewAdmin 1.1\n\n" )

//Load plugins into framework clientside
local gui_plugins = file.FindInLua("na_gui_plugins/*.lua")
for _, filename in pairs( gui_plugins ) do
	Msg( "Loading: " .. filename .. "\n" )
	include( "na_gui_plugins/" .. filename )
end

local plugins = file.FindInLua("na_plugins/*.lua")
for _, filename in pairs( plugins ) do
	Msg( "Loading: " .. filename .. "\n" )
	include( "na_plugins/" .. filename )
end

//End loading message
Msg( "===================================================\n\n" )
EngineLoading = false