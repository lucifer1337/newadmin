//The framework file holds handy functions so you don't have to rewrite them yourself :3

//Send notifications
function Notify( Message, Icon, Filter )
	for _, v in pairs(player.GetAll()) do
		//Player passes filter or no filter?
		if Filter == nil or v:UserID() == Filter:UserID() then
			if Icon == nil then Icon = "NOTIFY_GENERIC" end
			v:SendLua("GAMEMODE:AddNotify(\"".. Message .."\", " .. Icon .. ", 8); surface.PlaySound( \"".. "ambient/water/drip" .. math.random(1, 4) .. ".wav" .."\" )")
		end
	end
end

//Get command name from chat message
function GetCommand( Message )
	local Com = string.sub( Message, 2 )
	
	if string.find( Com, " ") ~= nil then
		Com = string.Explode( " ", Com )[1]
	end
	
	return string.lower(Com)
end

//Get arguments from chat message
function GetArguments( Message )
	if string.find( Message, " ") ~= nil then
		local Arguments = string.Explode( " ", Message )
		for i, v in pairs(Arguments) do
			if i == table.Count(Arguments) then
				Arguments[i] = nil
			else
				Arguments[i] = Arguments[i + 1]
			end
		end
		
		return Arguments
	end
end

//NewAdmin console message
function Log( Message, Hide )
	if !Hide then
		if EngineLoading == false then
			Msg( "(NEWADMIN) " .. Message .. "\n" )
		else
			Msg( "-> " .. Message .. "\n" ) //Looks better between the loading module messages :]
		end
	end
	
	//Add to log
	local ftext = ""
	if file.Exists( "NewAdmin/log.txt" ) then ftext = file.Read( "NewAdmin/log.txt" ) end
	file.Write( "NewAdmin/log.txt", ftext .. os.date("%c") .. " : " .. Message .. "\n" )
end

//Format the time in 00:00:00 format
function FormatTime( time )
	local seconds = 0
	local minutes = 0
	local hours = 0
	local timeleft = time
	
	//Hours
	while timeleft >= 3600 do
		hours = hours + 1
		timeleft = timeleft - 3600
	end
	//Minutes
	while timeleft >= 60 do
		minutes = minutes + 1
		timeleft = timeleft - 60
	end
	//Seconds
	seconds = timeleft
	
	//Format it
	if string.len(seconds) < 2 then seconds = "0" .. seconds end
	if string.len(minutes) < 2 then minutes = "0" .. minutes end
	if string.len(hours) < 2 then hours = "0" .. hours end
	
	return hours .. ":" .. minutes .. ":" .. seconds
end

//Get player by part of name
function GetPlayer( Part )
	for _, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(Part)) then
			return v
		end
	end
	
	return nil
end

function Flag( ply )
	//Old chizzle D:
	//local flags = 0
	//if ply:IsAdmin() then flags = 1 end
	//if ply:IsSuperAdmin() then flags = 2 end
	
	return tonumber( ply:GetNWInt( "Flag" ) )
end

function FlagName( flagID )
	if flagID == 0 then
		return "Users"
	elseif flagID == 1 then
		return "Administrators"
	elseif flagID == 2 then
		return "Super Administrators"
	elseif flagID == 3 then
		return "Owners"
	else
		return flagID
	end
end

//Shared function to block a player from spawning
function blockSpawnMenu( ply )
	if ply ~= nil then
		if ply:GetNetworkedBool( "NoSpawn" ) == true and SERVER then return false end
	end
end
hook.Add( "PlayerSpawnProp", "blockProps", blockSpawnMenu )
hook.Add( "PlayerSpawnSENT", "blockSENT", blockSpawnMenu )
hook.Add( "SpawnMenuOpen", "DisallowSpawnMenu", blockSpawnMenu)
function blockSpawnMenu2( ply, ent )
	if ply:GetNetworkedBool( "NoSpawn" ) == true and SERVER then ent:Remove() end
end
hook.Add( "PlayerSpawnedNPC", "blockNPC", blockSpawnMenu2 )
hook.Add( "PlayerSpawnedVehicle", "blockVehicle", blockSpawnMenu2 )
hook.Add( "PlayerSpawnedEffect", "blockEffect", blockSpawnMenu2 )
function blockSpawnMenu3( ply, model, ent )
	if ply:GetNetworkedBool( "NoSpawn" ) == true and SERVER then ent:Remove() end
end
hook.Add( "PlayerSpawnedRagdoll", "blockRagdoll", blockSpawnMenu3 )

//Shared function to block suicide
function CanPlayerSuicide ( ply )
	if ply:GetNetworkedBool( "NoSuicide" ) == true then
		return false
	end
end
hook.Add( "CanPlayerSuicide", "BlockIt", CanPlayerSuicide )

//Sync server time with clients
if CLIENT then
	tdiff = 0
	function SyncTimeCL( STime )
		tdiff = os.clock() - STime
	end
	
	function ServerTime()
		return tdiff
	end
end

function SyncTime( ply )
	ply:SendLua("SyncTimeCL(" .. os.clock() .. ")")
end
hook.Add( "PlayerInitialSpawn", "SyncTime", SyncTime )