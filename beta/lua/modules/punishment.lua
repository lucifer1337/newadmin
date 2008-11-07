//This module takes care of punishing people

//Slay
function Slay( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			pl:Kill()
			
			NotifyAll( ply:Nick() .. " slayed " .. pl:Nick(), "NOTIFY_CLEANUP" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Slay", "Kill a player", "slay", "slay <name>", Slay, 1, "Overv", 3)

//Jail
local JailPos = nil

function SetJailPos( ply, params )
	JailPos = ply:GetPos()
	SendNotify( ply, "Jail position set to your current position!" )
end
AddCommand( "Set jail position", "Set the jail position to your current position", "setjail", "setjail", SetJailPos, 1, "Overv", 3)

function Jail( ply, params )
	//Check if we have a jail position yet
	if JailPos == nil then
		SendNotify( ply, "The jail position hasn't been set yet!")
		return 
	end

	if params[1] ~= nil then
		local playertojail = GetPlayerByPart(params[1])
		if playertojail ~= nil then
			playertojail:SetPos( JailPos )
			playertojail:GodEnable()
			playertojail:StripWeapons()
			playertojail:SetNetworkedBool( "Jailed", true)
			
			NotifyAll( playertojail:Nick() .. " has been jailed by " .. ply:Nick(), "NOTIFY_CLEANUP" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
		end
	else
		SendNotify( ply, "Specify a player to jail!" )
	end
end
AddCommand( "Jail", "Jail the specified player", "jail", "jail <name>", Jail, 1, "Overv", 3)

function UnJail( ply, params )
	if params[1] ~= nil then
		local playertojail = GetPlayerByPart(params[1])
		if playertojail ~= nil then
			if playertojail:GetNetworkedBool( "Jailed" ) == true then
				playertojail:SetNetworkedBool( "Jailed", false)
				playertojail:GodDisable()
				playertojail:Kill()
				
				NotifyAll( playertojail:Nick() .. " has been released by " .. ply:Nick(), "NOTIFY_UNDO" )
			else
				SendNotify( ply, playertojail:Nick() .. " is not in jail!" )
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
		end
	else
		SendNotify( ply, "Specify a player to unjail!" )
	end
end
AddCommand( "UnJail", "Unjail the specified player and respawn him", "unjail", "unjail <name>", UnJail, 1, "Overv", 3)

//If a player is in jail he may not move
function BlockMove( ply )
	if ply:GetNetworkedInt( "Jailed" ) == true then
		return true
	end
end
hook.Add( "Move", "BlockMove", BlockMove )

//Block prop spawning in jail
function blockSpawnMenu( ply )
	if ply ~= nil then
		if ply:GetNetworkedBool( "Jailed" ) == true and SERVER then return false end
	end
end
hook.Add( "PlayerSpawnProp", "blockProps", blockSpawnMenu )
hook.Add( "PlayerSpawnSENT", "blockSENT", blockSpawnMenu )
hook.Add( "SpawnMenuOpen", "DisallowSpawnMenu", blockSpawnMenu)
function blockSpawnMenu2( ply, ent )
	if ply:GetNetworkedBool( "Jailed" ) == true and SERVER then ent:Remove() end
end
hook.Add( "PlayerSpawnedNPC", "blockNPC", blockSpawnMenu2 );
hook.Add( "PlayerSpawnedVehicle", "blockVehicle", blockSpawnMenu2 );
hook.Add( "PlayerSpawnedEffect", "blockEffect", blockSpawnMenu2 );
function blockSpawnMenu3( ply, model, ent )
	if ply:GetNetworkedBool( "Jailed" ) == true and SERVER then ent:Remove() end
end
hook.Add( "PlayerSpawnedRagdoll", "blockRagdoll", blockSpawnMenu3 );
function CanPlayerSuicide ( ply )
	if ply:GetNetworkedBool( "Jailed" ) == true then
		return false
	end
end
hook.Add( "CanPlayerSuicide", "BlockIt", CanPlayerSuicide )