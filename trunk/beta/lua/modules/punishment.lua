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

//Strip weapons
function Strip( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			pl:StripWeapons()
			
			NotifyAll( ply:Nick() .. " stripped " .. pl:Nick() .. "'s weapons", "NOTIFY_CLEANUP" )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Strip", "Strip weapons from a player", "strip", "strip <name>", Strip, 1, "Overv", 3)

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
		
		if playertojail ~= nil and playertojail:Alive() == true then
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
				
				//Find first spawn
				local spawn = ents.FindByClass("info_player_start")
				playertojail:SetPos(spawn[1]:GetPos())
				playertojail:SetAngles(spawn[1]:GetAngles())
				
				//Re-arm
				Arm( ply, params )
				
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

//Ignite
function Ignite( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:Ignite(999, 1)
		
		NotifyAll( ply:Nick() .. " has ignited " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Ignite", "Ignite a player", "ignite", "ignite <name>", Ignite, 1, "Overv", 3)

function UnIgnite( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:Extinguish()
		
		NotifyAll( ply:Nick() .. " has extinguished " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Extinguish", "Extinguish a player", "unignite", "unignite <name>", UnIgnite, 1, "Overv", 3)

//Blind
function Blind( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetNetworkedBool( "Blinded", true )
		
		NotifyAll( ply:Nick() .. " has blinded " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Blind", "Blind a player", "blind", "blind <name>", Blind, 1, "Overv", 3)

function UnBlind( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetNetworkedBool( "Blinded", false )
		
		NotifyAll( ply:Nick() .. " has unblinded " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnBlind", "Unblind a player", "unblind", "unblind <name>", UnBlind, 1, "Overv", 3)

if CLIENT then
	function BlindCheck()
		if LocalPlayer():GetNetworkedBool( "Blinded" ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
		end
	end
	hook.Add("HUDPaint", "Blind", BlindCheck)
end

//Freeze
function Freeze( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetNetworkedBool( "Frozen", true )
		
		NotifyAll( ply:Nick() .. " has frozen " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Freeze", "Freeze a player", "freeze", "freeze <name>", Freeze, 1, "Overv", 3)

function UnFreeze( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetNetworkedBool( "Frozen", false )
		
		NotifyAll( ply:Nick() .. " has unfrozen " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnFreeze", "Unfreeze a player", "unfreeze", "unfreeze <name>", UnFreeze, 1, "Overv", 3)

//Ragdolling (experimental)
function Ragdoll( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		//Spawn ragdoll
		ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel( pl:GetModel() )
		ragdoll:SetPos( pl:GetPos() )
		ragdoll:SetAngles( pl:GetAngles() )
		ragdoll:Spawn() 
		ragdoll:Activate()
		ragdoll:GetPhysicsObject():SetVelocity(4 * pl:GetVelocity())
		ragdoll:SetNetworkedInt( "Player", pl:UserID() )
		
		//Prepare player
		pl:DrawViewModel( false )
		pl:SetParent( ragdoll )
		pl:StripWeapons()
		pl:Spectate( OBS_MODE_CHASE )
		pl:SpectateEntity( ragdoll )
		pl:SetNetworkedInt( "Ragdoll", ragdoll:EntIndex() )
		pl.Ragdoll = ragdoll
		pl:SetNetworkedBool( "Ragdolled", true )
		
		NotifyAll( ply:Nick() .. " has ragdolled " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Ragdoll", "Turn a player into a ragdoll", "ragdoll", "ragdoll <name>", Ragdoll, 1, "Overv", 3)

function UnRagdoll( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		//Respawn
		pl:SetParent()
		local rpos = pl.Ragdoll:GetPos()
		pl.Ragdoll:Remove()
		pl:Spawn()
		pl:SetNoTarget( false )
		pl.Ragdoll = nil
		pl:DrawViewModel( true )
		pl:SetNetworkedInt( "Ragdoll", 0 )
		timer.Simple( .05, function() pl:SetPos( rpos + Vector( 0, 0, 10 ) ) end )
		pl:SetNetworkedBool( "Ragdolled", false )
		
		NotifyAll( ply:Nick() .. " has unragdolled " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnRagdoll", "Turn a ragdoll into a player again", "unragdoll", "unragdoll <name>", UnRagdoll, 1, "Overv", 3)

//If a player is in jail or frozen he may not move
function BlockMove( ply )
	if ply:GetNetworkedBool( "Jailed" ) == true or ply:GetNetworkedBool("Frozen") == true then
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