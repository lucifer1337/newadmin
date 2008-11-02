//This module holds all the commands that apply to players

//Godmode
function God( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:GodEnable()
		pl:SetNetworkedBool( "Godded", true )
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, ply:Nick() .. " has enabled godmode for " .. pl:Nick() )
		end
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "God", "Enable godmode for a player", "god", "god [name]", God, 1, "Overv", 1)

function UnGod( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	local pl = GetPlayerByPart( params[1] )

	if pl ~= nil then
		pl:GodDisable()
		pl:SetNetworkedBool( "Godded", false )
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, ply:Nick() .. " has disabled godmode for " .. pl:Nick() )
		end
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!")
	end
end
AddCommand( "UnGod", "Disable godmode for a player", "ungod", "ungod [name]", UnGod, 1, "Overv", 1)

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
			
			for k, v in pairs(player.GetAll()) do
				SendNotify( v, ply:Nick() .. " has set " .. pl:Nick() .. "'s health to " .. hp )
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "SetHealth", "Set health for a player", "hp", "hp <name> [amount=100]", SetHealth, 1, "Overv", 1)

//Unlimited ammo
function uAmmo( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	
	local pl = GetPlayerByPart(params[1])
	if pl ~= nil then
		pl:SetNetworkedBool( "uAmmo", true)
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, pl:Nick() .. " has been given unlimited ammo by " .. ply:Nick() )
		end
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
	end
end
AddCommand( "Unlimited Ammo", "Enables unlimited ammo for the player", "uammo", "uammo [name]", uAmmo, 1, "Overv", 1)

function UnuAmmo( ply, params )
	if params[1] == nil then params[1] = ply:Nick() end
	
	local pl = GetPlayerByPart(params[1])
	if pl ~= nil then
		pl:SetNetworkedBool( "uAmmo", false)
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, ply:Nick() .. " has disabled unlimited ammo for " .. pl:Nick() )
		end
	else
		SendNotify( ply, "Player '" .. params[1] .. "' not found!" )
	end
end
AddCommand( "Limited Ammo", "Disables unlimited ammo for the player", "unuammo", "unuammo [name]", UnuAmmo, 1, "Overv", 1)

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

//Slay
function Slay( ply, params )
	if params[1] ~= nil then
		local pl = GetPlayerByPart( params[1] )

		if pl ~= nil then
			pl:Kill()
			
			for k, v in pairs(player.GetAll()) do
				SendNotify( v, ply:Nick() .. " slayed " .. pl:Nick(), "NOTIFY_CLEANUP" )
			end
		else
			SendNotify( ply, "Player '" .. params[1] .. "' not found!")
		end
	end
end
AddCommand( "Slay", "Kill a player", "slay", "slay <name>", Slay, 1, "Overv", 1)