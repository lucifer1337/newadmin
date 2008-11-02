//Load autorun file and client engine file
AddCSLuaFile("autorun/autorun.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("module_engine.lua")
include("module_engine.lua")

//Welcome message
Msg("\n=======================================")
Msg("\nNewAdmin 1.0\n")

//Load modules and send them to the clients
local modules = file.FindInLua("modules/*.lua")
for k, v in pairs(modules) do
	AddCSLuaFile("modules/" .. v)
	include("modules/" .. v)
	Msg("\nLoaded module: " .. v)
end

//End welcome message
Msg("\n=======================================\n\n")