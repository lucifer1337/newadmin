//Welcome message
Msg("\n=======================================")
Msg("\nNewAdmin 1.0")

//Load module engine
include("module_engine.lua")

//Load modules we got from the server
local modules = file.FindInLua("modules/*.lua")
for k, v in pairs(modules) do
	AddCSLuaFile("modules/" .. v)
	include("modules/" .. v)
	Msg("\nLoaded module: " .. v)
end

//End welcome message
Msg("\n=======================================\n\n")