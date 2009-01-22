//This module takes care of punishing people

//Slay
function Slay( ply, params )
		params[1]:Kill()
		params[1]:AddFrags( 1 )
		Notify( ply:Nick() .. " slayed " .. params[1]:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "Slay", "Kill a player", "slay", "slay [name]", 1, "Overv", 3, 0, Slay )
RegisterCheck( "Slay", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Slay", 3, "slay" )

//Slap
function Slap( ply, params )
		params[1]:TakeDamage( params[2] )
		Notify( ply:Nick() .. " slapped " .. params[1]:Nick() .. " with " .. params[2] .. " HP", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Slap", "Damage a player", "slap", "slap <name> <damage>", 1, "Overv", 3, 0, Slap )
RegisterCheck( "Slap", 1, 3, "Player '%arg%' not found!" )
RegisterCheck( "Slap", 2, 2, "Damage must be a number!" )
AddPlayerMenu( "Slap", 3, "slap" )

//Mass Slap
function MassSlap( ply, params )
		timer.Create( "tmSlap" .. params[1]:Nick(), 0.5, params[3], function() if params[1] ~= NULL then params[1]:TakeDamage( params[2] ) end end )  
		Notify( ply:Nick() .. " slaps " .. params[1]:Nick() .. " " .. params[3] .. " times with " .. params[2] .. " HP", "NOTIFY_CLEANUP" )
end
RegisterCommand( "MassSlap", "Damages a player multiple times with a short interval", "mslap", "mslap <name> <damage> <times>", 1, "Overv", 3, 0, MassSlap )
RegisterCheck( "MassSlap", 1, 3, "Player '%arg%' not found!" )
RegisterCheck( "MassSlap", 2, 2, "Damage must be a number!" )
RegisterCheck( "MassSlap", 3, 2, "Amount of times must be a number!" )
AddPlayerMenu( "Mass Slap", 3, "mslap" )

//Strip weapons
function Strip( ply, params )
	params[1]:StripWeapons()
	Notify( ply:Nick() .. " stripped " .. params[1]:Nick() .. "'s weapons", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Strip", "Strip weapons from a player", "strip", "strip [name]", 1, "Overv", 3, 0, Strip )
RegisterCheck( "Strip", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Strip Weapons", 3, "strip" )

//Jail
local JailPos = nil
function SetJailPos( ply, params )
	JailPos = ply:GetPos()
	Notify( "Jail position set to your current position!", "NOTIFY_ERROR", ply )
end
RegisterCommand( "Set jail position", "Set the jail position to your current position", "setjail", "setjail", 1, "Overv", 3, 0, SetJailPos )
AddPlayerMenu( "Set Jail", 3, "setjail" )

function Jail( ply, params )
	//Check if we have a jail position yet
	if JailPos == nil then
		Notify( "The jail position hasn't been set yet!", "NOTIFY_ERROR", ply )
		return 
	end

	if params[1]:Alive() == false then
		params[1]:Spawn()
	end
	
	params[1]:SetPos( JailPos )
	params[1]:GodEnable()
	params[1]:StripWeapons()
	params[1]:SetNetworkedBool( "Jailed", true)
	
	params[1]:SetNWBool( "NoSuicide", true )
	params[1]:SetNWBool( "NoSpawn", true )
	
	Notify( params[1]:Nick() .. " has been jailed by " .. ply:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "Jail", "Jail the specified player", "jail", "jail [name]", 1, "Overv", 3, 0, Jail )
RegisterCheck( "Jail", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Jail", 3, "jail" )

function UnJail( ply, params )
	if params[1]:GetNetworkedBool( "Jailed" ) == true then
		params[1]:SetNetworkedBool( "Jailed", false)
		params[1]:GodDisable()
		
		//Find first spawn
		local spawn = ents.FindByClass("info_player_start")
		local rspawn = math.random(1, table.Count(spawn))
		params[1]:SetPos( spawn[rspawn]:GetPos() )
		params[1]:SetAngles( spawn[rspawn]:GetAngles() )
		
		params[1]:SetNWBool( "NoSuicide", false )
		params[1]:SetNWBool( "NoSpawn", false )
		
		//Re-arm
		Arm( ply, params )
		
		Notify( params[1]:Nick() .. " has been released by " .. ply:Nick(), "NOTIFY_UNDO" )
	else
		Notify( params[1]:Nick() .. " is not in jail!", "NOTIFY_ERROR", ply )
	end
end
RegisterCommand( "UnJail", "Unjail the specified player and respawn him", "unjail", "unjail [name]", 1, "Overv", 3, 0, UnJail )
RegisterCheck( "UnJail", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Un-Jail", 3, "unjail" )

//Ignite
function Ignite( ply, params )
	params[1]:Ignite(999, 1)
	Notify( ply:Nick() .. " has ignited " .. params[1]:Nick() )
end
RegisterCommand( "Ignite", "Ignite a player", "ignite", "ignite [name]", 1, "Overv", 3, 0, Ignite )
RegisterCheck( "Ignite", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ignite", 3, "ignite" )

function UnIgnite( ply, params )
	params[1]:Extinguish()
	Notify( ply:Nick() .. " has extinguished " .. params[1]:Nick() )
end
RegisterCommand( "Extinguish", "Extinguish a player", "unignite", "unignite [name]", 1, "Overv", 3, 0, UnIgnite )
RegisterCheck( "Extinguish", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Extinguish", 3, "unignite" )

//Blind
function Blind( ply, params )
	params[1]:SetNetworkedBool( "Blinded", true )
	Notify( ply:Nick() .. " has blinded " .. params[1]:Nick() )
end
RegisterCommand( "Blind", "Blind a player", "blind", "blind [name]", 1, "Overv", 3, 0, Blind )
RegisterCheck( "Blind", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Blind", 3, "blind" )

function UnBlind( ply, params )
	params[1]:SetNetworkedBool( "Blinded", false )
	Notify( ply:Nick() .. " has unblinded " .. params[1]:Nick() )
end
RegisterCommand( "UnBlind", "Unblind a player", "unblind", "unblind [name]", 1, "Overv", 3, 0, UnBlind )
RegisterCheck( "UnBlind", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Un-Blind", 3, "unblind" )

if CLIENT then
	function BlindCheck()
		if LocalPlayer():GetNetworkedBool( "Blinded" ) then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
		end
	end
	hook.Add("HUDPaint", "Blind", BlindCheck)
end

//Freeze
function Freeze( ply, params )
	params[1]:SetNetworkedBool( "Frozen", true )
	Notify( ply:Nick() .. " has frozen " .. params[1]:Nick() )
end
RegisterCommand( "Freeze", "Freeze a player", "freeze", "freeze [name]", 1, "Overv", 3, 0, Freeze )
RegisterCheck( "Freeze", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Freeze", 3, "freeze" )

function UnFreeze( ply, params )
	params[1]:SetNetworkedBool( "Frozen", false )
	Notify( ply:Nick() .. " has unfrozen " .. params[1]:Nick() )
end
RegisterCommand( "UnFreeze", "Unfreeze a player", "unfreeze", "unfreeze [name]", 1, "Overv", 3, 0, UnFreeze )
RegisterCheck( "UnFreeze", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "UnFreeze", 3, "unfreeze" )

//Ragdolling
function Ragdoll( ply, params )
	if params[1]:GetNWBool("Ragdolled") then
		Notify( params[1]:Nick() .. " is already ragdolled!", "NOTIFY_ERROR", ply )
		return false
	end

	//Spawn ragdoll
	ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel( params[1]:GetModel() )
	ragdoll:SetPos( params[1]:GetPos() )
	ragdoll:SetAngles( params[1]:GetAngles() )
	ragdoll:Spawn() 
	ragdoll:Activate()
	ragdoll:GetPhysicsObject():SetVelocity(4 * params[1]:GetVelocity())
	ragdoll:SetNWInt( "Player", params[1]:UserID() )
	
	//Prepare player
	params[1]:DrawViewModel( false )
	params[1]:SetParent( ragdoll )
	params[1]:StripWeapons()
	params[1]:Spectate( OBS_MODE_CHASE )
	params[1]:SpectateEntity( ragdoll )
	params[1]:SetNWInt( "Ragdoll", ragdoll:EntIndex() )
	params[1].Ragdoll = ragdoll
	params[1]:SetNWBool( "Ragdolled", true )
	params[1]:GodEnable()
	
	params[1]:SetNWBool( "NoSuicide", true )
	params[1]:SetNWBool( "NoSpawn", true )
	
	Notify( ply:Nick() .. " has ragdolled " .. params[1]:Nick() )
end
RegisterCommand( "Ragdoll", "Turn a player into a ragdoll", "ragdoll", "ragdoll [name]", 1, "Overv", 3, 0, Ragdoll )
RegisterCheck( "Ragdoll", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ragdoll", 3, "ragdoll" )

function UnRagdoll( ply, params )
	if params[1]:GetNWBool("Ragdolled") == false then
		SendNotify( params[1]:Nick() .. " is not ragdolled!", "NOTIFY_ERROR", ply )
		return false
	end

	//Respawn
	params[1]:SetParent()
	local rpos = params[1].Ragdoll:GetPos()
	params[1].Ragdoll:Remove()
	params[1]:Spawn()
	params[1]:SetNoTarget( false )
	params[1].Ragdoll = nil
	params[1]:DrawViewModel( true )
	params[1]:SetNWInt( "Ragdoll", 0 )
	timer.Simple( .05, function() params[1]:SetPos( rpos + Vector( 0, 0, 10 ) ) end )
	params[1]:SetNWBool( "Ragdolled", false )
	params[1]:GodDisable()
	
	params[1]:SetNWBool( "NoSuicide", false )
	params[1]:SetNWBool( "NoSpawn", false )
	
	Notify( ply:Nick() .. " has unragdolled " .. params[1]:Nick() )
end
RegisterCommand( "UnRagdoll", "Turn a ragdoll into a player again", "unragdoll", "unragdoll [name]", 1, "Overv", 3, 0, UnRagdoll )
RegisterCheck( "UnRagdoll", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Un-Ragdoll", 3, "unragdoll" )

//If a player is in jail or frozen he may not move
function BlockMove( ply )
	if ply:GetNetworkedBool("Frozen") == true then
		return true
	elseif ply:GetNetworkedBool( "Jailed" ) == true and ply:GetMoveType() ~= MOVETYPE_WALK then
		return true
	end
end
hook.Add( "Move", "BlockMove", BlockMove )