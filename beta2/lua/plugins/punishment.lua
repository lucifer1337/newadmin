//This module takes care of punishing people

//Slay
function Slay( ply, params )
		params[1]:Kill()
		params[1]:AddFrags( 1 )
		NA_Notify( ply:Nick() .. " slayed " .. params[1]:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "Slay", "Kill a player", "slay", "slay [name]", 1, "Overv", 3, 0, Slay )
RegisterCheck( "Slay", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Slay", 3, "slay [PLAYER]" )

//Slap
function Slap( ply, params )
		params[1]:SetHealth( params[1]:Health() - params[2] )
		NA_Notify( ply:Nick() .. " slapped " .. params[1]:Nick() .. " with " .. params[2] .. " HP", "NOTIFY_CLEANUP" )
		
		if params[1]:Health() < 1 then params[1]:Kill() end
end
RegisterCommand( "Slap", "Damage a player", "slap", "slap <name> <damage>", 1, "Overv", 3, 0, Slap )
RegisterCheck( "Slap", 1, 3, "Player '%arg%' not found!" )
RegisterCheck( "Slap", 2, 2, "Damage must be a number!" )
AddPlayerMenu( "Slap", 3, "slap [PLAYER] 10" )

//Mass Slap
function MassSlap( ply, params )
		timer.Create( "tmSlap" .. params[1]:Nick(), 0.5, params[3], function()
			if params[1] ~= NULL then
				params[1]:SetHealth( params[1]:Health() - params[2] )
				if params[1]:Health() < 1 then params[1]:Kill() end
			end
		end )
		
		NA_Notify( ply:Nick() .. " slaps " .. params[1]:Nick() .. " " .. params[3] .. " times with " .. params[2] .. " HP", "NOTIFY_CLEANUP" )
end
RegisterCommand( "MassSlap", "Damages a player multiple times with a short interval", "mslap", "mslap <name> <damage> <times>", 1, "Overv", 3, 0, MassSlap )
RegisterCheck( "MassSlap", 1, 3, "Player '%arg%' not found!" )
RegisterCheck( "MassSlap", 2, 2, "Damage must be a number!" )
RegisterCheck( "MassSlap", 3, 2, "Amount of times must be a number!" )
AddPlayerMenu( "Mass Slap", 3, "mslap [PLAYER] 10 10" )

//Strip weapons
function Strip( ply, params )
	params[1]:StripWeapons()
	NA_Notify( ply:Nick() .. " stripped " .. params[1]:Nick() .. "'s weapons", "NOTIFY_CLEANUP" )
end
RegisterCommand( "Strip", "Strip weapons from a player", "strip", "strip [name]", 1, "Overv", 3, 0, Strip )
RegisterCheck( "Strip", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Strip Weapons", 3, "strip [PLAYER]" )

//Jail
local JailPos = nil
function SetJailPos( ply, params )
	JailPos = ply:GetPos()
	NA_Notify( "Jail position set to your current position!", "NOTIFY_ERROR", ply )
end
RegisterCommand( "Set jail position", "Set the jail position to your current position", "setjail", "setjail", 1, "Overv", 3, 0, SetJailPos )
AddPlayerMenu( "Set Jail", 3, "setjail" )

function Jail( ply, params )
	//Check if we have a jail position yet
	if JailPos == nil then
		NA_Notify( "The jail position hasn't been set yet!", "NOTIFY_ERROR", ply )
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
	
	NA_Notify( params[1]:Nick() .. " has been jailed by " .. ply:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "Jail", "Jail the specified player", "jail", "jail [name]", 1, "Overv", 3, 0, Jail )
RegisterCheck( "Jail", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Jail", 3, "jail [PLAYER]", "unjail [PLAYER]", "Jailed" )

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
		
		NA_Notify( params[1]:Nick() .. " has been released by " .. ply:Nick(), "NOTIFY_UNDO" )
	else
		NA_Notify( params[1]:Nick() .. " is not in jail!", "NOTIFY_ERROR", ply )
	end
end
RegisterCommand( "UnJail", "Unjail the specified player and respawn him", "unjail", "unjail [name]", 1, "Overv", 3, 0, UnJail )
RegisterCheck( "UnJail", 1, 3, "Player '%arg%' not found!" )

//Ignite
function Ignite( ply, params )
	params[1]:Ignite(999, 1)
	params[1]:SetNWBool( "Ignited", true )
	NA_Notify( ply:Nick() .. " has ignited " .. params[1]:Nick() )
end
RegisterCommand( "Ignite", "Ignite a player", "ignite", "ignite [name]", 1, "Overv", 3, 0, Ignite )
RegisterCheck( "Ignite", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ignited", 3, "ignite [PLAYER]", "unignite [PLAYER]", "Ignited" )

function UnIgnite( ply, params )
	params[1]:Extinguish()
	params[1]:SetNWBool( "Ignited", false )
	NA_Notify( ply:Nick() .. " has extinguished " .. params[1]:Nick() )
end
RegisterCommand( "Extinguish", "Extinguish a player", "unignite", "unignite [name]", 1, "Overv", 3, 0, UnIgnite )
RegisterCheck( "Extinguish", 1, 3, "Player '%arg%' not found!" )

//Blind
function Blind( ply, params )
	params[1]:SetNWBool( "Blinded", true )
	NA_Notify( ply:Nick() .. " has blinded " .. params[1]:Nick() )
end
RegisterCommand( "Blind", "Blind a player", "blind", "blind [name]", 1, "Overv", 3, 0, Blind )
RegisterCheck( "Blind", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Blind", 3, "blind [PLAYER]", "unblind [PLAYER]", "Blinded" )

function UnBlind( ply, params )
	params[1]:SetNWBool( "Blinded", false )
	NA_Notify( ply:Nick() .. " has unblinded " .. params[1]:Nick() )
end
RegisterCommand( "UnBlind", "Unblind a player", "unblind", "unblind [name]", 1, "Overv", 3, 0, UnBlind )
RegisterCheck( "UnBlind", 1, 3, "Player '%arg%' not found!" )

if CLIENT then
	function BlindCheck()
		if LocalPlayer():GetNWBool( "Blinded" ) then
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
		end
	end
	hook.Add("HUDPaint", "Blind", BlindCheck)
end

//Freeze
function Freeze( ply, params )
	params[1]:SetNWBool( "Frozen", true )
	params[1]:SetSolid( false )
	NA_Notify( ply:Nick() .. " has frozen " .. params[1]:Nick() )
end
RegisterCommand( "Freeze", "Freeze a player", "freeze", "freeze [name]", 1, "Overv", 3, 0, Freeze )
RegisterCheck( "Freeze", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Freeze", 3, "freeze [PLAYER]", "unfreeze [PLAYER]", "Frozen" )

function UnFreeze( ply, params )
	params[1]:SetNWBool( "Frozen", false )
	params[1]:SetSolid( true )
	NA_Notify( ply:Nick() .. " has unfrozen " .. params[1]:Nick() )
end
RegisterCommand( "UnFreeze", "Unfreeze a player", "unfreeze", "unfreeze [name]", 1, "Overv", 3, 0, UnFreeze )
RegisterCheck( "UnFreeze", 1, 3, "Player '%arg%' not found!" )

//Ragdolling
function Ragdoll( ply, params )
	if params[1]:GetNWBool("Ragdolled") then
		NA_Notify( params[1]:Nick() .. " is already ragdolled!", "NOTIFY_ERROR", ply )
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
	
	NA_Notify( ply:Nick() .. " has ragdolled " .. params[1]:Nick() )
end
RegisterCommand( "Ragdoll", "Turn a player into a ragdoll", "ragdoll", "ragdoll [name]", 1, "Overv", 3, 0, Ragdoll )
RegisterCheck( "Ragdoll", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ragdoll", 3, "ragdoll [PLAYER]", "unragdoll [PLAYER]", "Ragdolled" )

function UnRagdoll( ply, params )
	if params[1]:GetNWBool("Ragdolled") == false then
		SendNA_Notify( params[1]:Nick() .. " is not ragdolled!", "NOTIFY_ERROR", ply )
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
	
	NA_Notify( ply:Nick() .. " has unragdolled " .. params[1]:Nick() )
end
RegisterCommand( "UnRagdoll", "Turn a ragdoll into a player again", "unragdoll", "unragdoll [name]", 1, "Overv", 3, 0, UnRagdoll )
RegisterCheck( "UnRagdoll", 1, 3, "Player '%arg%' not found!" )

//If a player is in jail or frozen he may not move
function BlockMove( ply )
	if ply:GetNetworkedBool("Frozen") == true then
		return true
	elseif ply:GetNetworkedBool( "Jailed" ) == true and ply:GetMoveType() ~= MOVETYPE_WALK then
		return true
	end
end
hook.Add( "Move", "BlockMove", BlockMove )

//Slay
function Explode( ply, params )
	//Spawn the dynamite
	local explosive = ents.Create( "env_explosion" )
	explosive:SetPos( params[1]:GetPos() )
	explosive:SetOwner( params[1] )
	explosive:Spawn()
	explosive:SetKeyValue( "iMagnitude", "1" )
	explosive:Fire( "Explode", 0, 0 )
	explosive:EmitSound( "ambient/explosions/explode_4.wav", 500, 500 )
	
	//Kill the player
	params[1]:Kill()
	params[1]:AddFrags( 1 )
	NA_Notify( ply:Nick() .. " exploded " .. params[1]:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "Explode", "Explode a player", "explode", "explode [name]", 1, "Overv", 3, 0, Explode )
RegisterCheck( "Explode", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Explode", 3, "explode [PLAYER]" )

//Mute voice
function VoiceMute( ply, params )
	for _, v in pairs(player.GetAll()) do
		umsg.Start( "NA_Mute", v )
			umsg.Entity( params[1] )
			umsg.Bool( true )
		umsg.End()
	end
	
	params[1]:SetNWBool( "VMuted", true )
	NA_Notify( ply:Nick() .. " has voice muted " .. params[1]:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "VoiceMute", "Mute the voice a player", "mutev", "mutev [name]", 1, "Overv", 3, 0, VoiceMute )
RegisterCheck( "VoiceMute", 1, 3, "Player '%arg%' not found!" )

function UnVoiceMute( ply, params )
	for _, v in pairs(player.GetAll()) do
		umsg.Start( "NA_Mute", v )
			umsg.Entity( params[1] )
			umsg.Bool( false )
		umsg.End()
	end
	
	params[1]:SetNWBool( "VMuted", false )
	NA_Notify( ply:Nick() .. " has stopped muting " .. params[1]:Nick(), "NOTIFY_CLEANUP" )
end
RegisterCommand( "UnVoiceMute", "Stop muting the voice a player", "unmutev", "unmutev [name]", 1, "Overv", 3, 0, UnVoiceMute )
RegisterCheck( "UnVoiceMute", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Mute voice", 3, "mutev [PLAYER]", "unmutev [PLAYER]", "VMuted" )

function SetMuted( ply, bMuted )
	if ply:IsMuted() != bMuted then
		ply:SetMuted()
	end
end

function NA_Mute( um )
	SetMuted( um:ReadEntity(), um:ReadBool() )
end
usermessage.Hook( "NA_Mute", NA_Mute )