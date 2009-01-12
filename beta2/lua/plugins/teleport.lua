//This module houses all the teleport related commands

//Goto
function Goto( ply, params )
	local pos = params[1]:GetPos()
	ply:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
	
	for k, v in pairs(player.GetAll()) do
		Notify( ply:Nick() .. " has gone to " .. params[1]:Nick(), nil, v )
	end
end
RegisterCommand( "Goto", "Teleport to a player", "goto", "goto <name>", 1, "Overv", 5, 1, Goto )
RegisterCheck( "Goto", 1, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Go to", 5, "goto" )

//Bring
function Bring( ply, params )
	if params[1]:Alive() == true then
		local pos = ply:GetPos()
		params[1]:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
		
		Notify( params[1]:Nick() .. " has been brought to " .. ply:Nick() )
	else
		Notify( params[1]:Nick() .. " is not alive!", nil, ply )
	end
end
RegisterCommand( "Bring", "Teleport a player to you", "bring", "bring <name>", 1, "Overv", 5, 1, Bring )
RegisterCheck( "Bring", 1, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Bring", 5, "bring" )

//Send
function Send( ply, params )
	local pos = params[2]:GetPos()
	params[1]:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
	
	Notify( params[1]:Nick() .. " has been brought to " .. params[2]:Nick() .. " by " .. ply:Nick() )
end
RegisterCommand( "Send", "Teleport a player to another player", "send", "send <player1> <player2>", 1, "Overv", 5, 2, Send )
RegisterCheck( "Send", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "Send", 2, 1, "Player '%arg%' not found!" )
AddPlayerMenu( "Send", 5, "send" )

//Teleport to aimed position
function Teleport( ply, params )
	local trace = ply:GetEyeTrace()
	params[1]:SetPos( trace.HitPos )
	Notify( ply:Nick() .. " has teleported " .. params[1]:Nick() )
end
RegisterCommand( "Teleport", "Teleport a player to the position you look at", "tp", "tp [name]", 1, "Overv", 5, 0, Teleport )
RegisterCheck( "Teleport", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Teleport", 5, "tp" )