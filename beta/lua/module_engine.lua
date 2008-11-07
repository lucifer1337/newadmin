//This file handles the module commands
Commands = {}

//Prefix for commands (e.g. !)
ComPrefix = "!"

//NewAdmin version
Version = "1.0b"

//Module categories
//
//1 - Player administration
//2 - Player Actions
//3 - Player punishment
//4 - Server management
//5 - Teleportation
//6 - Chat
//7 - User Groups
//8 - Other

//This function should be called by all modules adding commands
function AddCommand( Name, Description, ChatCommand, Usage, CallFunction, Flag, Author, CategoryID )
	//Module object
	local Command = {}
	Command.Name = Name
	Command.Description = Description
	Command.ChatCommand = ChatCommand
	Command.Function = CallFunction
	Command.Flag = Flag
	Command.Usage = Usage
	Command.Author = Author
	Command.CategoryID = CategoryID
	
	//Add module to module table
	table.insert(Commands, Command)
end

//Log commands used
function AddLog(Text)
	local curlog = ""
	if file.Exists("NewAdmin/log.txt") then curlog = file.Read("NewAdmin/log.txt") end
	
	file.Write( "NewAdmin/log.txt", curlog .. os.date("%c") .. " -> " .. Text .. "\n" )
end
AddLog("Server started in map \"" .. game.GetMap() .. "\"")

//Send notification
function SendNotify(ply, text, icon)
	if icon == nil then icon = "NOTIFY_GENERIC" end

	ply:SendLua("GAMEMODE:AddNotify(\"".. text .."\", " .. icon .. ", 8); surface.PlaySound( \"".. "ambient/water/drip" .. math.random(1, 4) .. ".wav" .."\" )")
end

function NotifyAll( text, icon )
	for k, v in pairs(player.GetAll()) do
		SendNotify( v, text, icon )
	end
end

//Get player by part of name
function GetPlayerByPart( NamePart )
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), string.lower(NamePart)) then
			return v
		end
	end
	
	return nil
end

function ConsoleMsg( Message )
	Msg( "(NEWADMIN) " .. Message .. "\n")
end

//Get flags
function GetFlags( ply )
	local flags = 0
	if ply:IsAdmin() then flags = 1 end
	if ply:IsSuperAdmin() then flags = 2 end
	
	return flags
end

//Get flag name
function GetFlagName( flagID )
	if flagID == 0 then
		return "Users"
	elseif flagID == 1 then
		return "Administrators"
	elseif flagID == 2 then
		return "Super Administrators"
	else
		return nil
	end
end

//Get parameters
function GetParameters( ChatMessage )
	params = {}
	params = string.Explode(" ", ChatMessage)
	
	for k, v in pairs(params) do
		if k < table.Count(params) then
			params[k] = params[k+1]
		else
			params[k] = nil
		end
	end
	
	return params
end

function CommandRequested( Message )
	local commandreq = Message
	if string.find( Message, " ") ~= nil then
		commandreq = string.Explode( " ", Message )[1]
	end
	
	return commandreq
end

//Handle chat
function PlayerSay( ply, Message)
	//Command?
	if string.Left( Message, 1 ) == ComPrefix then
		//Check if this command is known
		local err = 1
		
		for k, v in pairs(Commands) do
			//Way better system
			if CommandRequested(Message) == ComPrefix .. v.ChatCommand then
				if GetFlags(ply) >= v.Flag then
					err = 0
					v.Function(ply, GetParameters(Message))
					
					//Log this command
					AddLog(ply:Nick() .. " (" .. ply:SteamID() .. ") has called a command: " .. Message)
				else
					flagn = v.Flag
					err = 2
				end
			end
		end
		
		if err == 1 then
			SendNotify( ply, "Unknown command: " .. string.sub(CommandRequested(Message), 2), "NOTIFY_ERROR" )
		end
		if err == 2 then
			SendNotify( ply, "Only " .. GetFlagName( flagn ) .. " are allowed to use this command!", "NOTIFY_ERROR" )
		end
		
		return ""
	end
end
hook.Add("PlayerSay", "ChatMessage", PlayerSay)

//Rehook when anything goes wrong
function ReHook()
	hook.Remove( "PlayerSay", "ChatMessage" )
	hook.Add("PlayerSay", "ChatMessage", PlayerSay)
end
timer.Create( "Rehook", 1, 0, ReHook )