//This module holds all the commands that apply to players

//Godmode
function God( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:GodEnable()
		pl:SetNetworkedBool( "Godded", true )
		
		NotifyAll( ply:Nick() .. " has enabled godmode for " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "God", "Enable godmode for a player", "god", "god [name]", God, 1, "Overv", 2)

function UnGod( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:GodDisable()
		pl:SetNetworkedBool( "Godded", false )
		
		NotifyAll( ply:Nick() .. " has disabled godmode for " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnGod", "Disable godmode for a player", "ungod", "ungod [name]", UnGod, 1, "Overv", 2)

//When you respawn godmode gets disabled, this will re-enable it :)
function RestartGod( ply )
	if ply:GetNetworkedBool( "Godded" ) == true then
		ply:GodEnable()
	end
end
hook.Add( "PlayerSpawn", "ReStartGod", RestartGod )

//Set health
function SetHealth( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			local hp = params[2]
			if hp ~= nil then
				if math.floor(hp) ~= nil then
					pl:SetHealth( hp )
				else
					pl:SetHealth( 100 )
					hp = 100
				end
			else
				pl:SetHealth( 100 )
				hp = 100
			end
			
			NotifyAll( ply:Nick() .. " has set " .. pl:Nick() .. "'s health to " .. hp )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "SetHealth", "Set health for a player", "hp", "hp <name> [amount=100]", SetHealth, 1, "Overv", 2)

//Unlimited ammo
function uAmmo( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	
	local pl = GetPlayerByPart(params[1])
	if pl ~= nil then
		pl:SetNetworkedBool( "uAmmo", true)
		NotifyAll( pl:Nick() .. " has been given unlimited ammo by " .. ply:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
	end
end
AddCommand( "Unlimited Ammo", "Enables unlimited ammo for the player", "uammo", "uammo [name]", uAmmo, 1, "Overv", 2)

function UnuAmmo( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	
	local pl = GetPlayerByPart(params[1])
	if pl ~= nil then
		pl:SetNetworkedBool( "uAmmo", false)
		NotifyAll( ply:Nick() .. " has disabled unlimited ammo for " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
	end
end
AddCommand( "Limited Ammo", "Disables unlimited ammo for the player", "unuammo", "unuammo [name]", UnuAmmo, 1, "Overv", 2)

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
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			if tonumber(params[2]) == nil then
				frags = pl:Frags()
			else
				frags = tonumber(params[2])
				NotifyAll( ply:Nick() .. " has set " .. pl:Nick() .. "'s frags to " .. frags )
			end
			
			pl:SetFrags( frags )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "SetFrags", "Set the frags of a player", "setfrags", "setfrags <name> <frags>", SetFrags, 1, "Overv", 2)

//Set frags
function SetDeaths( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			if tonumber(params[2]) == nil then
				frags = pl:Deaths()
			else
				frags = tonumber(params[2])
				NotifyAll( ply:Nick() .. " has set " .. pl:Nick() .. "'s deaths to " .. frags )
			end
			
			pl:SetDeaths( frags )
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "SetDeaths", "Set the deaths of a player", "setdeaths", "setdeaths <name> <deaths>", SetDeaths, 1, "Overv", 2)

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
			ConsoleMsg("Added " .. table.Count(defweapons) .. " default weapons!")
		end
	end
end
if SERVER then hook.Add("Think", "AddWeapons", AddWeapons) end

function Arm( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			for _, v in pairs(defweapons) do
				pl:Give( v )
			end
			pl:SelectWeapon("weapon_physgun")
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Arm", "Gives a player all the weapons", "arm", "arm <name>", Arm, 1, "Overv", 2)

//Ghosting
function Ghost( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetRenderMode( RENDERMODE_NONE )
		pl:SetColor(255, 255, 255, 0)
		pl:SetNetworkedBool( "Ghosted", true )
		
		//Make weapons invisible too
		for _, v in pairs(pl:GetWeapons()) do
			v:SetRenderMode( RENDERMODE_NONE )
			v:SetColor(255, 255, 255, 0)
		end
		
		NotifyAll( ply:Nick() .. " has ghosted " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "Ghost", "Turn a player into a ghost (invisible)", "ghost", "ghost [name]", Ghost, 1, "Overv", 2)

function UnGhost( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:SetRenderMode( RENDERMODE_NORMAL )
		pl:SetColor(255, 255, 255, 255)
		pl:SetNetworkedBool( "Ghosted", false )
		
		//Make weapons visible again
		for _, v in pairs(pl:GetWeapons()) do
			v:SetRenderMode( RENDERMODE_NORMAL )
			v:SetColor(255, 255, 255, 255)
		end
		
		NotifyAll( ply:Nick() .. " has unghosted " .. pl:Nick() )
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnGhost", "Turn a ghost into a player again", "unghost", "unghost [name]", UnGhost, 1, "Overv", 2)

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