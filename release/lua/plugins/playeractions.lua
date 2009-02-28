//This module holds all the commands that apply to players

//Godmode
function God( ply, params )
	params[1]:GodEnable()
	params[1]:SetNetworkedBool( "Godded", true )	
	NA_Notify( ply:Nick() .. " has enabled godmode for " .. params[1]:Nick() )
end
RegisterCommand( "God", "Enable godmode for a player", "god", "god [name]", 1, "Overv", 2, 0, God )
RegisterCheck( "God", 1, 3, "Player '%arg%' not found!" )

function UnGod( ply, params )
	params[1]:GodDisable()
	params[1]:SetNetworkedBool( "Godded", false )
	NA_Notify( ply:Nick() .. " has disabled godmode for " .. params[1]:Nick() )
end
RegisterCommand( "UnGod", "Disable godmode for a player", "ungod", "ungod [name]", 1, "Overv", 2, 0, UnGod )
RegisterCheck( "UnGod", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Godmode", 2, "god [PLAYER]", "ungod [PLAYER]", "Godded" )

//When you respawn godmode gets disabled, this will re-enable it :)
function RestartGod( ply )
	if ply:GetNetworkedBool( "Godded" ) == true then
		ply:GodEnable()
	end
end
hook.Add( "PlayerSpawn", "ReStartGod", RestartGod )

//Set health
function SetHealth( ply, params )
	local hp = params[2]
	
	if hp ~= nil then
		if tonumber(hp) ~= nil then
			params[1]:SetHealth( hp )
		else
			params[1]:SetHealth( 100 )
			hp = 100
		end
	else
		params[1]:SetHealth( 100 )
		hp = 100
	end
	
	NA_Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s health to " .. hp )
end
RegisterCommand( "SetHealth", "Set health for a player", "hp", "hp [name] [amount]", 1, "Overv", 2, 0, SetHealth )
RegisterCheck( "SetHealth", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Health", 2, "hp [PLAYER] 100" )

//Set armor
function SetArmor( ply, params )
	local armor = params[2]
	
	if armor ~= nil then
		if tonumber(armor) ~= nil then
			params[1]:SetArmor( armor )
		else
			params[1]:SetArmor( 100 )
			armor = 100
		end
	else
		params[1]:SetArmor( 100 )
		armor = 100
	end
	
	NA_Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s armor to " .. armor )
end
RegisterCommand( "SetArmor", "Set armor for a player", "armor", "armor [name] [amount]", 1, "Overv", 2, 0, SetArmor )
RegisterCheck( "SetArmor", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Armor", 2, "armor [PLAYER] 100" )

//Unlimited ammo
function uAmmo( ply, params )
	params[1]:SetNetworkedBool( "uAmmo", true)
	NA_Notify( params[1]:Nick() .. " has been given unlimited ammo by " .. ply:Nick() )
end
RegisterCommand( "Unlimited Ammo", "Enables unlimited ammo for the player", "uammo", "uammo [name]", 1, "Overv", 2, 0, uAmmo )
RegisterCheck( "Unlimited Ammo", 1, 3, "Player '%arg%' not found!" )

function UnuAmmo( ply, params )
	params[1]:SetNetworkedBool( "uAmmo", false)
	NA_Notify( ply:Nick() .. " has disabled unlimited ammo for " .. params[1]:Nick() )
end
RegisterCommand( "Limited Ammo", "Disables unlimited ammo for the player", "unuammo", "unuammo [name]", 1, "Overv", 2, 0, UnuAmmo )
RegisterCheck( "Limited Ammo", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Unlimited Ammo", 2, "uammo [PLAYER]", "unuammo [PLAYER]", "uAmmo" )

function uAmmoGive()
	for k, v in pairs(player.GetAll()) do
		if v:GetNetworkedBool( "uAmmo" ) == true then
			//Check if this player has 999 ammo
			local curweapon = v:GetActiveWeapon()
			
			if curweapon:IsWeapon() == true then
				curweapon:SetClip1( 250 )
				curweapon:SetClip2( 250 )
				
				if curweapon:GetPrimaryAmmoType() == 10 or curweapon:GetPrimaryAmmoType() == 8 then
					v:GiveAmmo( 250 - v:GetAmmoCount( curweapon:GetPrimaryAmmoType() ), curweapon:GetPrimaryAmmoType() )
				elseif curweapon:GetSecondaryAmmoType() == 9 or curweapon:GetSecondaryAmmoType() == 2 then
					v:GiveAmmo( 250 - v:GetAmmoCount( curweapon:GetSecondaryAmmoType() ), curweapon:GetSecondaryAmmoType() )
				end
			end
		end
	end
end
if SERVER then hook.Add("Think", "uAmmoGive", uAmmoGive) end

//Set frags
function SetFrags( ply, params )
	NA_Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s frags to " .. params[2] )
	params[1]:SetFrags( params[2])
end
RegisterCommand( "SetFrags", "Set the frags of a player", "frags", "frags <name> <frags>", 2, "Overv", 2, 2, SetFrags )
RegisterCheck( "SetFrags", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "SetFrags", 2, 2, "Amount of frags must be a number!" )
AddPlayerMenu( "Set Frags", 2, "frags [PLAYER] 0" )

//Set frags
function SetDeaths( ply, params )
	NA_Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s deaths to " .. params[2] )
	params[1]:SetDeaths( params[2])
end
RegisterCommand( "SetDeaths", "Set the deaths of a player", "deaths", "deaths <name> <deaths>", 2, "Overv", 2, 2, SetDeaths )
RegisterCheck( "SetDeaths", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "SetDeaths", 2, 2, "Amount of deaths must be a number!" )
AddPlayerMenu( "Set Deaths", 2, "deaths [PLAYER] 0" )

//Collect default weapons
local defweapons = {}
function AddWeapons()
	for k, v in pairs(ents.GetAll()) do
		if v:IsWeapon() and !table.HasValue( defweapons, v:GetClass() ) then
			table.insert( defweapons, v:GetClass() )
		end
	end
end
if SERVER then hook.Add("Think", "AddWeapons", AddWeapons) end

function Arm( ply, params )
	for _, v in pairs(defweapons) do
		params[1]:Give( v )
	end
	params[1]:SelectWeapon("weapon_physgun")
end
RegisterCommand( "Arm", "Gives a player all the weapons", "arm", "arm [name]", 1, "Overv", 2, 0, Arm )
RegisterCheck( "Arm", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Arm", 2, "arm [PLAYER]" )

//Ghosting
function Ghost( ply, params )
	params[1]:SetRenderMode( RENDERMODE_NONE )
	params[1]:SetColor(255, 255, 255, 0)
	params[1]:SetNetworkedBool( "Ghosted", true )
	params[1]:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	//Make weapons invisible too
	for _, v in pairs(params[1]:GetWeapons()) do
		v:SetRenderMode( RENDERMODE_NONE )
		v:SetColor(255, 255, 255, 0)
	end
	
	NA_Notify( ply:Nick() .. " has ghosted " .. params[1]:Nick() )
end
RegisterCommand( "Ghost", "Turn a player into a ghost (invisible)", "ghost", "ghost [name]", 1, "Overv", 2, 0, Ghost )
RegisterCheck( "Ghost", 1, 3, "Player '%arg%' not found!" )

function UnGhost( ply, params )
	params[1]:SetRenderMode( RENDERMODE_NORMAL )
	params[1]:SetColor(255, 255, 255, 255)
	params[1]:SetNetworkedBool( "Ghosted", false )
	params[1]:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	
	//Make weapons visible again
	for _, v in pairs(params[1]:GetWeapons()) do
		v:SetRenderMode( RENDERMODE_NORMAL )
		v:SetColor(255, 255, 255, 255)
	end
	
	NA_Notify( ply:Nick() .. " has unghosted " .. params[1]:Nick() )
end
RegisterCommand( "UnGhost", "Turn a ghost into a player again", "unghost", "unghost [name]", 1, "Overv", 2, 0, UnGhost )
RegisterCheck( "UnGhost", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ghosted", 2, "ghost [PLAYER]", "unghost [PLAYER]", "Ghosted" )

//When you respawn you get new weapons and they're not invisible yet D:
function RestartGhost( ply )
	if ply:GetNetworkedBool( "Ghosted" ) == true then
		for _, v in pairs(pl:GetWeapons()) do
			v:SetRenderMode( RENDERMODE_NONE )
			v:SetColor(255, 255, 255, 0)
		end
	end
end
hook.Add( "PlayerSpawn", "RestartGhost", RestartGhost )

//Force a player to respawn
function Spawn( ply, params )
	params[1]:Spawn()
	NA_Notify( ply:Nick() .. " has respawned " .. params[1]:Nick() )
end
RegisterCommand( "Spawn", "Force a player to respawn", "spawn", "spawn [name]", 1, "Overv", 2, 0, Spawn )
RegisterCheck( "Spawn", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Spawn", 2, "spawn [PLAYER]" )

//Force a player to exit a vehicle
function ExitVehicle( ply, params )
	if params[1]:InVehicle() then
		params[1]:ExitVehicle()
		NA_Notify( ply:Nick() .. " has kicked " .. params[1]:Nick() .. " out of his vehicle", "NOTIFY_CLEANUP" )
	else
		NA_Notify( params[1]:Nick() .. " is not in a vehicle at the moment!", "NOTIFY_ERROR", ply )
	end
end
RegisterCommand( "ExitVehicle", "Force a player to exit a vehicle", "exit", "exit [name]", 1, "Overv", 2, 0, ExitVehicle )
RegisterCheck( "ExitVehicle", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Exit Vehicle", 2, "exit [PLAYER]" )

//Force a player to exit a vehicle
function EnterVehicle( ply, params )
	local tr = ply:GetEyeTrace()
	local Ent = tr.Entity
	
	if Ent ~= NULL and Ent:IsValid() and Ent:IsVehicle() then
		params[1]:EnterVehicle( Ent )
		NA_Notify( ply:Nick() .. " has put " .. params[1]:Nick() .. " into a vehicle", "NOTIFY_UNDO" )
	end
end
RegisterCommand( "EnterVehicle", "Force a player to enter a vehicle", "enter", "enter [name]", 1, "Overv", 2, 0, EnterVehicle )
RegisterCheck( "EnterVehicle", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Enter Vehicle", 2, "enter [PLAYER]" )

//Spectate a player
function Spectate( ply, params )
	if params[1] == ply then
		NA_Notify( "You can't spectate yourself!", "NOTIFY_ERROR", ply )
	else
		ply:Spectate( OBS_MODE_CHASE )
		ply:SpectateEntity( params[1] )
		ply:StripWeapons()
	end
end
RegisterCommand( "Spectate", "Spectate a player in third person", "spec", "spec [name]", 1, "Overv", 2, 0, Spectate )
RegisterCheck( "Spectate", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Spectate", 2, "spec [PLAYER]" )

//Unspectate
function UnSpectate( ply, params )
	ply:UnSpectate()
	local ppos = ply:GetPos()
	ply:Spawn()
	timer.Simple( .05, function() ply:SetPos( ppos + Vector( 0, 0, 10 ) ) end )
end
RegisterCommand( "UnSpectate", "Stop spectating", "unspec", "unspec", 1, "Overv", 2, 0, UnSpectate )
AddPlayerMenu( "Stop Spectating", 2, "unspec [PLAYER]" )

//AFK Mode
function AFK( ply, params )
	ply:SetNWBool( "AFK", true )
	
	local Reason = string.Replace(table.concat( params, " " ), "\n", "")
	if string.len(Reason) > 50 then Reason = string.Left(Reason, 50) end
	ply:SetNWString( "AFKReason", Reason )
end
function UnAFK( ply, params )
	ply:SetNWBool( "AFK", false )
	ply:SetNWString( "AFKReason", "" )
end
RegisterCommand( "AFK", "Let others know you're away. Reason can be max 50 characters.", "afk", "afk [reason]", 1, "Overv", 2, 0, AFK )
RegisterCommand( "UnAFK", "Let others know you're back", "unafk", "unafk", 1, "Overv", 2, 0, UnAFK )