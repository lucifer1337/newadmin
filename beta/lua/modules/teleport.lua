//This module houses all the teleport related commands

//Goto
function Goto( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			local pos = pl:GetPos()
			ply:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
			
			for k, v in pairs(player.GetAll()) do
				SendNotify( v, ply:Nick() .. " has gone to " .. pl:Nick() )
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Goto", "Teleport to a player", "goto", "goto <name>", Goto, 1, "Overv", 5)

//Bring
function Bring( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			local pos = ply:GetPos()
			pl:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
			
			NotifyAll( pl:Nick() .. " has been brought to " .. ply:Nick() )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Bring", "Teleport a player to you", "bring", "bring <name>", Bring, 1, "Overv", 5)

//Send
function Send( ply, params )
	if params[1] ~= nil and params[2] ~= nil then
		local pl1 = GetPlayerByPart( params[1] )
		local pl2 = GetPlayerByPart( params[2] )

		if pl1 ~= nil and pl2 ~= nil then
			local pos = pl2:GetPos()
			pl1:SetPos( Vector( pos.x, pos.y, pos.z + 100 ) )
			
			NotifyAll( pl1:Nick() .. " has been brought to " .. pl2:Nick() .. " by " .. ply:Nick() )
		else
			if pl1 == nil then SendNotify( ply, "Player '" .. params[1] .. "' not found!") end
			if pl2 == nil then SendNotify( ply, "Player '" .. params[2] .. "' not found!") end
		end
	end
end
AddCommand( "Send", "Teleport a player to another player", "send", "send <player1> <player2>", Send, 1, "Overv", 5)

//Teleport to aimed position
function Teleport( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		local trace = ply:GetEyeTrace()
		pl:SetPos( trace.HitPos )
		
		NotifyAll( ply:Nick() .. " has teleported " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Teleport", "Teleport a player to the position you look at", "tele", "tele [name]", Teleport, 1, "Overv", 5)