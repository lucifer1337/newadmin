AddCSLuaFile("cl_init.lua")
include("settings.lua")

na_godmode = server_settings.Int( "sbox_godmode", 0 )
na_noclip = server_settings.Int( "sbox_noclip", 0 )
na_playernocollide = 0
na_cheats = server_settings.Int( "sv_cheats", 0)
bantable = {}

function ShowAdmin( ply, command, arguments )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		umsg.Start("adminmenu", ply)
			umsg.String( "showadminmenu" )
		umsg.End()
	end
end
concommand.Add( "+NA_Show", ShowAdmin )

function LoadBans()
	if file.Exists("NewAdmin/bans.txt") then
		//This loads every line with ban information into a table on the server
		local banfile = file.Read("NewAdmin/bans.txt")
		bantable = string.Explode("\n", banfile)
	end
	
	for k, v in pairs(player.GetAll()) do
		SendBans( v )
	end
end

function SendBans( ply )
	ply:SendLua("GetBans(\"RESET\")")
	
	for k, v in pairs(bantable) do
		ply:SendLua("GetBans(\"".. v .."\")")
	end
end

function SaveBans()
	//Get all entrys and save them
	local filetobe = ""
	for k, v in pairs(bantable) do
		if v ~= "" and v ~= "\n" then
			filetobe = filetobe .. v .. "\n"
		end
	end
	
	file.Write("NewAdmin/bans.txt", filetobe)
end

//Check if someone is banned
function CheckBan(ply)
	if bantable[1] ~= nil then
		for k, v in pairs(bantable) do
			if v ~= "" and v ~= "\n" then
				local pars = string.Explode("[split]", v)
				
				//First check if this ban hasn't expired yet
				pars[3] = string.sub(pars[3], 7)
				if tonumber(pars[3]) == 0 or tonumber(pars[3]) > os.time() then
					if string.find(pars[2], ply:SteamID()) then
						local secsrem = tonumber(pars[3])-os.time()
						if secsrem < 60 then
							if secsrem > 0 then
								time = " " .. secsrem .. " seconds"
							else
								time = "ever"
							end
						else
							time = " " .. math.floor(secsrem/60) .. " minutes"
						end
					
						RunConsoleCommand("kickid", ply:UserID(), "Banned for".. time .. "!")
						Msg("(NEWADMIN) Player \"" .. ply:Nick() .. "\" checked and found entry -> Player kicked! (".. tonumber(pars[3])-os.time() .." seconds remaining)\n")
						return 
					end
				else
					//Remove this ban, it has expired :)
					Msg("(NEWADMIN) Ban for \"" .. pars[1] .. "\" has expired. (Now: " .. os.time() .. "; Then: " .. pars[3] .. ")\n")
					table.remove(bantable, k)
					SaveBans()
				end
			end
		end
		Msg("(NEWADMIN) Player \"" .. ply:Nick() .. "\" checked -> No entry found.\n")
		return 
	end
	Msg("(NEWADMIN) Ban check failed -> Empty ban list\n")
end
hook.Add( "PlayerInitialSpawn", "CheckBan", CheckBan ) 

//Recollide when for example a player joins
function ReCollide()
	for k, v in pairs(player.GetAll()) do
		if tonumber(na_playernocollide) == 1 then
			v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		else
			v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end
	end
end

//Fix for some reason nescesarry to start cl_init.lua on the client
function FirstSpawn( ply )
	ply:SendLua("include(\"cl_init.lua\")")
	ReCollide()
	
	//Privileges/Info
	ply:SetNetworkedBool("Blinded", 0)
	ply:SetNetworkedBool("GodMode", 0)
	ply:SetNetworkedBool("Muted", 0)
	ply:SetNetworkedBool("Cloaked", 0)
	ply:SetNetworkedBool("Frozen", 0)
	ply:SendLua("na_playernocollide = " .. na_playernocollide)
	ply:SendLua("na_godmode = " .. na_godmode)
	ply:SendLua("na_noclip = " .. na_noclip)
	ply:SendLua("na_cheats = " .. na_cheats)
	ply:SendLua("hostname = \"" .. GetGlobalString("ServerName") .. "\"")
	ply:SendLua("newadmin = 1")
	ply:SendLua("CurrentMap = \"" .. game.GetMap() .. "\"")
	
	SendBans(ply)
	Msg("Sent the ban list to " .. ply:Nick() .. "\n")
	
	//Send map list
	local Maps = file.Find("../maps/*.bsp")
	for k, v in pairs(Maps) do
		ply:SendLua("AddMap(\"" .. string.Replace(v, ".bsp", "") .. "\")")
	end
	
	//Welcome player
	SendNotify(ply, "Welcome on " .. GetGlobalString("ServerName") .. "!")
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn );

function SendNotify(ply, text)
	ply:SendLua("GAMEMODE:AddNotify(\"".. text .."\", NOTIFY_HINT, 8); surface.PlaySound( \"".. "ambient/water/drip" .. math.random(1, 4) .. ".wav" .."\" )")
end

//Re-enable godmode, because this disables automatically when you die
function playerRespawn( ply )
	if ply:GetNetworkedBool("GodMode") == 1 then
		ply:GodEnable()
	end
	
	//If you die you are automatically extinguished
	ReCollide()
	ply:Extinguish()
	ply:SetNetworkedBool("Ignited", 0)
end
hook.Add( "PlayerSpawn", "playerRespawnTest", playerRespawn )

//Block moving if it is not allowed
function Moving(ply, move)
	if ply:GetNetworkedBool("Frozen") == 1 then
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

function SayToAll(message, noadminflag)
	for k, v in pairs(player.GetAll()) do
		if noadminflag == true then
			v:PrintMessage(HUD_PRINTTALK, message)
		else
			v:PrintMessage(HUD_PRINTTALK, "(ADMIN) " .. message)
		end
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
	if player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) ~= 0 then
				//First convert the text values to seconds
				local bantime = arguments[2]
				if arguments[2] == "5 Minutes" then
					bantime = 300
				elseif arguments[2] == "15 Minutes" then
					bantime = 900
				elseif arguments[2] == "30 Minutes" then
					bantime = 1800
				elseif arguments[2] == "1 Hour" then
					bantime = 3600
				elseif arguments[2] == "2 Hours" then
					bantime = 7200
				elseif arguments[2] == "6 Hours" then
					bantime = 21600
				elseif arguments[2] == "1 Day" then
					bantime = 86400
				elseif arguments[2] == "2 Days" then
					bantime = 172800
				elseif arguments[2] == "7 Days" then
					bantime = 604800
				elseif arguments[2] == "1 Month" then
					bantime = 2592000
				elseif arguments[2] == "6 Months" then
					bantime = 15552000
				elseif arguments[2] == "1 Year" then
					bantime = 31104000
				elseif tonumber(arguments[2]) ~= nil then
					if tonumber(arguments[2]) < 60 then
						if tonumber(arguments[2]) > 0 then
							arguments[2] = arguments[2] .. " Seconds"
						else
							arguments[2] = "ever"
						end
					else
						arguments[2] = math.floor(tonumber(arguments[2])/60) .. " Minutes"
					end
				else
					bantime = 1
				end
			
				SayToAll(arguments[1] .. " has been banned by " .. player:Nick() .. " for " .. arguments[2])
				RunConsoleCommand("kickid", GetPlayerbyNick(arguments[1]):UserID(), "Banned for " .. arguments[2] .. "!")
				table.insert(bantable, arguments[1] .. "[split]" .. GetPlayerbyNick(arguments[1]):SteamID() .. "[split]" .. os.time()+bantime)
			else
				SayToAll(arguments[1] .. " has been permabanned by " .. player:Nick())
				RunConsoleCommand("kickid", GetPlayerbyNick(arguments[1]):UserID(), "Permabanned!")
				table.insert(bantable, arguments[1] .. "[split]" .. GetPlayerbyNick(arguments[1]):SteamID() .. "[split]" .. 0)
			end
			
			//Add ban entry
			SaveBans()
			for k, v in pairs(player.GetAll()) do
				SendBans(v)
			end
		end
	end
end
concommand.Add( "NA_Ban", NA_Ban ) 

//Explode
function NA_Explode( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			//Create explosive and explode it
			local explosive = ents.Create( "env_explosion" )
			explosive:SetPos( GetPlayerbyNick( arguments[1] ):GetPos() )
			explosive:SetOwner( GetPlayerbyNick(arguments[1]) )
			explosive:Spawn()
			explosive:SetKeyValue( "iMagnitude", "1" )
			explosive:Fire( "Explode", 0, 0 )
			explosive:EmitSound( "ambient/explosions/explode_4.wav", 500, 500 )
			GetPlayerbyNick(arguments[1]):Kill( )
			
			SayToAll(arguments[1] .. " has been exploded by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Explode", NA_Explode ) 

//Slay
function NA_Slay( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			GetPlayerbyNick(arguments[1]):Kill()
			SayToAll(arguments[1] .. " has been slayed by " .. player:Nick())
		end
	end
end
concommand.Add( "NA_Slay", NA_Slay ) 

//Slap
function NA_Slap( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			local prehe = GetPlayerbyNick(arguments[1]):Health()
			GetPlayerbyNick(arguments[1]):TakeDamage(10)
			
			if (prehe == GetPlayerbyNick(arguments[1]):Health()) then
				GetPlayerbyNick(arguments[1]):SetHealth(GetPlayerbyNick(arguments[1]):Health()-10)
				if GetPlayerbyNick(arguments[1]):Health() < 1 then
					GetPlayerbyNick(arguments[1]):Kill()
				end
			end
			
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
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Blinded", 1)
			else
				SayToAll(arguments[1] .. " has been unblinded by " .. player:Nick())
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Blinded", 0)
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
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("GodMode", 1)
			else
				GetPlayerbyNick(arguments[1]):GodDisable()
				SayToAll(player:Nick() .. " has disabled godmode for " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("GodMode", 0)
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
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Ignited", 1)
			else
				GetPlayerbyNick(arguments[1]):Extinguish()
				SayToAll(player:Nick() .. " has extinguished " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Ignited", 0)
			end
		end
	end
end
concommand.Add( "NA_Ignite", NA_Ignite )

//Extingish when in water
function Think()
	for k, v in pairs(player.GetAll()) do
		if v:GetNetworkedBool("Ignited") == 1 then
			if v:WaterLevel() == 3 then
				v:Extinguish()
				v:SetNetworkedBool("Ignited", 0)
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
				GetPlayerbyNick(arguments[1]):SetColor(255, 255, 255, na_cloakedalpha)
				GetPlayerbyNick(arguments[1]):SetRenderMode( RENDERMODE_TRANSALPHA )
				
				SayToAll(player:Nick() .. " has cloaked " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Cloaked", 1)
			else
				GetPlayerbyNick(arguments[1]):SetColor(255, 255, 255, 255)
				GetPlayerbyNick(arguments[1]):SetRenderMode( RENDERMODE_NORMAL )
				
				SayToAll(player:Nick() .. " has uncloaked " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Cloaked", 0)
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
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Muted", 1)
			else
				SayToAll(player:Nick() .. " has unmuted " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Muted", 0)
			end
		end
	end
end
concommand.Add( "NA_Mute", NA_Mute )

function HasFlags(ply, flags)
	local fl = 0
	
	if ply:IsAdmin() then fl = 1 end
	if ply:IsSuperAdmin() then fl = 2 end
	
	if fl >= flags then
		return true
	else
		return false
	end
end

function GetPlayerByPart( namepart )
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(namepart)) then
			return v
		end
	end
	return false
end

//Chat messages + admin chat commands
function PlayerSaid( ply, text )
	if tonumber(ply:GetNetworkedBool("Muted")) == 1 then
		return ""
	elseif string.Left(text, 1) == "!" then
		//Command
		local handledcom = false
		
		if string.Left(text, 4) == "!me " then
			SayToAll(ply:Nick() .. " " .. string.sub(text, 5), true)
			handledcom = true
		elseif string.Left(text, 6) == "!goto " and HasFlags(ply, 1) then
			local args = string.Explode(" ", string.sub(text, 7))
			if args[1] ~= nil then
				local pl = GetPlayerByPart(args[1])
				if pl ~= false then
					args[1] = pl:Nick()
					NA_TeleTo(ply, "", args)
				end
			else
				ply:PrintMessage( HUD_PRINTTALK, "This command requires the playername as argument!")
			end
			handledcom = true
		elseif string.Left(text, 6) == "!kick " and HasFlags(ply, 1) then
			local args = string.Explode(" ", string.sub(text, 7))
			if args[1] ~= nil then
				local pl = GetPlayerByPart(args[1])
				if pl ~= false then
					args[1] = pl:Nick()
					NA_Kick(ply, "", args)
				end
			else
				ply:PrintMessage( HUD_PRINTTALK, "This command requires the playername as argument!")
			end
			handledcom = true
		elseif string.Left(text, 5) == "!ban " and HasFlags(ply, 2) then
			local args = string.Explode(" ", string.sub(text, 6))
			if args[1] ~= nil and tonumber(args[2]) ~= nil then
				local pl = GetPlayerByPart(args[1])
				if pl ~= false then
					args[1] = pl:Nick()
					NA_Ban(ply, "", args)
				end
			else
				ply:PrintMessage( HUD_PRINTTALK, "This command requires the playername and bantime as argument!")
			end
			handledcom = true
		end
			
		if handledcom == false then
			ply:PrintMessage( HUD_PRINTTALK, "Unknown command or unauthorised!")
		end
		
		return ""
	else
		return text
	end
end
hook.Add( "PlayerSay", "PlayerSaid", PlayerSaid );

function ReHook()
	hook.Add( "PlayerSay", "PlayerSaid", PlayerSaid );
end
timer.Create("ReHook", 1, 0, ReHook)

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
	if player:IsAdmin() or player:IsSuperAdmin() then
		if GetPlayerbyNick( arguments[1] ) ~= nil then
			if tonumber(arguments[2]) == 1 then
				SayToAll(player:Nick() .. " has frozen " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Frozen", 1)
			else
				SayToAll(player:Nick() .. " has unfrozen " .. arguments[1])
				GetPlayerbyNick(arguments[1]):SetNetworkedBool("Frozen", 0)
			end
		end
	end
end
concommand.Add( "NA_Freeze", NA_Freeze )

//Set hostname
function NA_Hostname( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		RunConsoleCommand("hostname", arguments[1])
		player:SendLua("hostname = \"" .. GetGlobalString("ServerName") .. "\"")
		SendNotify(player, "The hostname has been changed succesfully!")
	end
end
concommand.Add( "NA_Hostname", NA_Hostname )

//Change map
function NA_Map( player, command, arguments )
	if player:IsAdmin() or player:IsSuperAdmin() then
		RunConsoleCommand("changelevel", arguments[1])
	end
end
concommand.Add( "NA_Map", NA_Map )

function SendLuaToAll( lua )
	for k, v in pairs(player.GetAll()) do
		v:SendLua(lua)
	end
end

//Set no-collide setting
function NA_Nocollide( ply, command, arguments )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		//Set option
		na_playernocollide = tonumber(arguments[1])
		for k, v in pairs(player.GetAll()) do
			if na_playernocollide == 1 then
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			else
				v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			end
		end
		
		//Notify
		SendNotify(ply, "Variable 'na_playernocollide' has been set to '" .. math.floor(arguments[1]) .. "'")
		SendLuaToAll("na_playernocollide = " .. arguments[1])
	end
end
concommand.Add( "NA_Nocollide", NA_Nocollide )

//Set godmode value
function NA_Godmode( ply, command, arguments )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		//Set option
		na_playernocollide = tonumber(arguments[1])
		game.ConsoleCommand("sbox_godmode " .. math.floor(arguments[1]) .. "\n")
		
		//Notify
		SendNotify(ply, "Variable 'sbox_godmode' has been set to '" .. math.floor(arguments[1]) .. "'")
		SendLuaToAll("na_godmode = " .. arguments[1])
	end
end
concommand.Add( "NA_Godmode", NA_Godmode )

//Set noclip value
function NA_Noclip( ply, command, arguments )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		//Set option
		na_playernocollide = tonumber(arguments[1])
		game.ConsoleCommand("sbox_noclip ".. math.floor(arguments[1]) .."\n")
		
		//Notify
		SendNotify(ply, "Variable 'sbox_noclip' has been set to '" .. math.floor(arguments[1]) .. "'")
		SendLuaToAll("na_noclip = " .. arguments[1])
	end
end
concommand.Add( "NA_Noclip", NA_Noclip )

//Reset bans
concommand.Add( "NA_BanReload", LoadBans )

LoadBans()
//Load message
Msg("\n=================================================\n")
Msg("\nNewAdmin has been succesfully loaded serverside!\n")
Msg("\nLoaded " .. table.Count(bantable) .. " bans.\n")
Msg("\n=================================================\n\n")