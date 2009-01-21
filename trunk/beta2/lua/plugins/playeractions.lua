//This module holds all the commands that apply to players

//Godmode
function God( ply, params )
	params[1]:GodEnable()
	params[1]:SetNetworkedBool( "Godded", true )	
	Notify( ply:Nick() .. " has enabled godmode for " .. params[1]:Nick() )
end
RegisterCommand( "God", "Enable godmode for a player", "god", "god [name]", 1, "Overv", 2, 0, God )
RegisterCheck( "God", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "God", 2, "god" )

function UnGod( ply, params )
	params[1]:GodDisable()
	params[1]:SetNetworkedBool( "Godded", false )
	Notify( ply:Nick() .. " has disabled godmode for " .. params[1]:Nick() )
end
RegisterCommand( "UnGod", "Disable godmode for a player", "ungod", "ungod [name]", 1, "Overv", 2, 0, UnGod )
RegisterCheck( "UnGod", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Un-God", 2, "ungod" )

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
	
	Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s health to " .. hp )
end
RegisterCommand( "SetHealth", "Set health for a player", "hp", "hp [name] [amount]", 1, "Overv", 2, 0, SetHealth )
RegisterCheck( "SetHealth", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Health", 2, "hp" )

//Unlimited ammo
function uAmmo( ply, params )
	params[1]:SetNetworkedBool( "uAmmo", true)
	Notify( params[1]:Nick() .. " has been given unlimited ammo by " .. ply:Nick() )
end
RegisterCommand( "Unlimited Ammo", "Enables unlimited ammo for the player", "uammo", "uammo [name]", 1, "Overv", 2, 0, uAmmo )
RegisterCheck( "Unlimited Ammo", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Unlimited Ammo", 2, "uammo" )

function UnuAmmo( ply, params )
	params[1]:SetNetworkedBool( "uAmmo", false)
	Notify( ply:Nick() .. " has disabled unlimited ammo for " .. params[1]:Nick() )
end
RegisterCommand( "Limited Ammo", "Disables unlimited ammo for the player", "unuammo", "unuammo [name]", 1, "Overv", 2, 0, UnuAmmo )
RegisterCheck( "Limited Ammo", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Limited Ammo", 2, "unuammo" )

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
	Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s frags to " .. params[2] )
	params[1]:SetFrags( params[2])
end
RegisterCommand( "SetFrags", "Set the frags of a player", "frags", "frags <name> <frags>", 2, "Overv", 2, 2, SetFrags )
RegisterCheck( "SetFrags", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "SetFrags", 2, 2, "Amount of frags must be a number!" )
AddPlayerMenu( "Set Frags", 2, "frags" )

//Set frags
function SetDeaths( ply, params )
	Notify( ply:Nick() .. " has set " .. params[1]:Nick() .. "'s deaths to " .. params[2] )
	params[1]:SetDeaths( params[2])
end
RegisterCommand( "SetDeaths", "Set the deaths of a player", "deaths", "deaths <name> <deaths>", 2, "Overv", 2, 2, SetDeaths )
RegisterCheck( "SetDeaths", 1, 1, "Player '%arg%' not found!" )
RegisterCheck( "SetDeaths", 2, 2, "Amount of deaths must be a number!" )
AddPlayerMenu( "Set Deaths", 2, "deaths" )

//Collect default weapons
local defweapons = {}
function AddWeapons()
	if defweapons[1] == nil then
		for k, v in pairs(ents.GetAll()) do
			if v:IsWeapon() then
				table.insert( defweapons, v:GetClass() )
			end
		end
		
		if table.Count(defweapons) > 0 then
			Log("Added " .. table.Count(defweapons) .. " default weapons!")
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
AddPlayerMenu( "Arm", 2, "arm" )

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
	
	Notify( ply:Nick() .. " has ghosted " .. params[1]:Nick() )
end
RegisterCommand( "Ghost", "Turn a player into a ghost (invisible)", "ghost", "ghost [name]", 1, "Overv", 2, 0, Ghost )
RegisterCheck( "Ghost", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Ghost", 2, "ghost" )

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
	
	Notify( ply:Nick() .. " has unghosted " .. params[1]:Nick() )
end
RegisterCommand( "UnGhost", "Turn a ghost into a player again", "unghost", "unghost [name]", 1, "Overv", 2, 0, UnGhost )
RegisterCheck( "UnGhost", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Un-Ghost", 2, "unghost" )

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
	Notify( ply:Nick() .. " has respawned " .. params[1]:Nick() )
end
RegisterCommand( "Spawn", "Force a player to respawn", "spawn", "spawn [name]", 1, "Overv", 2, 0, Spawn )
RegisterCheck( "Spawn", 1, 3, "Player '%arg%' not found!" )
AddPlayerMenu( "Spawn", 2, "spawn" )