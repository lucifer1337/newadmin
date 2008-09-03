AddCSLuaFile("cl_init.lua")
include("settings.lua")

function ShowAdmin( ply, command, arguments )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		umsg.Start("adminmenu", ply)
			umsg.String( "showadminmenu" )
		umsg.End()
	end
end
concommand.Add( "NA_Show", ShowAdmin )

//Fix for some reason nescesarry to start cl_init.lua on the client
function FirstSpawn( ply )
	ply:SendLua("include(\"cl_init.lua\")")
	
	//Privileges/Info
	ply:SetNetworkedInt("Blinded", 0)
	ply:SetNetworkedInt("GodMode", 0)
	ply:SetNetworkedInt("Muted", 0)
	ply:SetNetworkedInt("Frozen", 0)
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn );

//Re-enable godmode, because this disables automatically when you die
function playerRespawn( ply )
	if ply:GetNetworkedInt("GodMode") == 1 then
		ply:GodEnable()
	end
	
	//If you die you are automatically extinguished
	ply:Extinguish()
	ply:SetNetworkedInt("Ignited", 0)
end
hook.Add( "PlayerSpawn", "playerRespawnTest", playerRespawn )

//Block moving if it is not allowed
function Moving(ply, move)
	if ply:GetNetworkedInt("Frozen") == 1 then
		return true
	end
end
hook.Add( "Move", "Moving", Moving)

//Admin commands from admin client
function GetPlayerbyNick( nick )
	for k, v in pairs(player.GetAll()) do
		if v:Nick() == nick then
			return v
		end
	end
	return nil
end

function SayToAll(message)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTTALK, "(ADMIN) " .. message)
	end
end

//Kick
function NA_Kick( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			RunConsoleCommand("kick", arguments[1])
			SayToAll(arguments[1] .. " has been kicked by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Kick", NA_Kick ) 

//Ban
function NA_Ban( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			RunConsoleCommand("addip", arguments[1], GetPlayerbyNick(arguments[1]):IPAddress())
			if tonumber(arguments[2]) ~= 0 then
				SayToAll(arguments[1] .. " has been banned by " .. player:Nick() .. " for " .. arguments[2] .. " minutes")
			else
				SayToAll(arguments[1] .. " has been permabanned by " .. player:Nick())
			end
		end
	end
end
concommand.Add( "NA_Ban", NA_Ban ) 

//Kill
function NA_Kill( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):Kill()
			SayToAll(arguments[1] .. " has been killed by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Kill", NA_Kill ) 

//Slay
function NA_Slay( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):TakeDamage(10)
			SayToAll(arguments[1] .. " has been slayed by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Slay", NA_Slay ) 

//Slay
function NA_Slap( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):ViewPunch( Angle( -5, 0, 0 ) )
			SayToAll(arguments[1] .. " has been slapped by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Slap", NA_Slap )

//Blind
function NA_Blind( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):SendLua("Blind = " .. tonumber(arguments[2]))
			if tonumber(arguments[2]) == 1 then
				SayToAll(arguments[1] .. " has been blinded by " .. player:Nick())
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Blinded", 1)
			else
				SayToAll(arguments[1] .. " has been unblinded by " .. player:Nick())
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Blinded", 0)
			end
		end
	end
end
concommand.Add( "NA_Blind", NA_Blind )

//Player specific godmode
function NA_God( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				GetPlayerbyNick(arguments[1]):GodEnable()
				SayToAll(player:Nick() .. " has enabled godmode for " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("GodMode", 1)
			else
				GetPlayerbyNick(arguments[1]):GodDisable()
				SayToAll(player:Nick() .. " has disabled godmode for " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("GodMode", 0)
			end
		end
	end
end
concommand.Add( "NA_God", NA_God )

//Kill
function NA_Health( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):SetHealth(arguments[2])
			SayToAll(player:Nick() .. " has set the health of " .. arguments[1] .. " to " .. arguments[2])
		end
	end
end
concommand.Add( "NA_Health", NA_Health )

//Ignite
function NA_Ignite( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				GetPlayerbyNick(arguments[1]):Ignite(99, 2)
				SayToAll(player:Nick() .. " has ignited " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Ignited", 1)
			else
				GetPlayerbyNick(arguments[1]):Extinguish()
				SayToAll(player:Nick() .. " has extinguished " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Ignited", 0)
			end
		end
	end
end
concommand.Add( "NA_Ignite", NA_Ignite )

//Extingish when in water
function Think()
	for k, v in pairs(player.GetAll()) do
		if v:GetNetworkedInt("Ignited") == 1 then
			if v:WaterLevel() == 3 then
				v:Extinguish()
				v:SetNetworkedInt("Ignited", 0)
				SayToAll(v:Nick() .. " has extinguished himself by jumping into water")
			end
		end
	end
end
hook.Add("Think", "Think", Think)

//Cloak
function NA_Cloak( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				GetPlayerbyNick(arguments[1]):SetColor(255, 255, 255, 128)
				GetPlayerbyNick(arguments[1]):SetRenderMode( RENDERMODE_TRANSALPHA )
				
				SayToAll(player:Nick() .. " has cloaked " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Cloaked", 1)
			else
				GetPlayerbyNick(arguments[1]):SetColor(255, 255, 255, 255)
				GetPlayerbyNick(arguments[1]):SetRenderMode( RENDERMODE_NORMAL )
				
				SayToAll(player:Nick() .. " has uncloaked " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Cloaked", 0)
			end
		end
	end
end
concommand.Add( "NA_Cloak", NA_Cloak )

//Mute
function NA_Mute( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				SayToAll(player:Nick() .. " has muted " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Muted", 1)
			else
				SayToAll(player:Nick() .. " has unmuted " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Muted", 0)
			end
		end
	end
end
concommand.Add( "NA_Mute", NA_Mute )

//Chat messages
function PlayerSaid( ply, text )
	if tonumber(ply:GetNetworkedInt("Muted")) == 1 then
		return ""
	else
		return text
	end
end
hook.Add( "PlayerSay", "PlayerSaid", PlayerSaid );

//Teleport to other player
function NA_TeleTo( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			local goto = GetPlayerbyNick(arguments[1]):GetPos()
			goto.z = goto.z + 124
			
			//Teleport
			player:SetPos(goto)
			
			SayToAll(player:Nick() .. " has gone to " .. arguments[1])
		end
	end
end
concommand.Add( "NA_TeleTo", NA_TeleTo )

//Teleport to other player
function NA_TeleToMe( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			local goto = player:GetPos()
			goto.z = goto.z + 124
			
			//Teleport
			GetPlayerbyNick(arguments[1]):SetPos(goto)
			
			SayToAll(arguments[1] .. " has been brought to " .. player:Nick())
		end
	end
end
concommand.Add( "NA_TeleToMe", NA_TeleToMe )

//Freeze
function NA_Freeze( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				SayToAll(player:Nick() .. " has frozen " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Frozen", 1)
			else
				SayToAll(player:Nick() .. " has unfrozen " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedInt("Frozen", 0)
			end
		end
	end
end
concommand.Add( "NA_Freeze", NA_Freeze )

//Set hostname
function NA_Hostname( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() or player:IsSuperAdmin() or player:IsSuperAdmin() then
		RunConsoleCommand("hostname", arguments[1])
	end
end
concommand.Add( "NA_Hostname", NA_Hostname )