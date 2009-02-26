//Keep track of loaded commands
Commands = {}

//Categories
//1 - Player administration
//2 - Player Actions
//3 - Player punishment
//4 - Server management
//5 - Teleportation
//6 - Chat
//7 - User Groups
//8 - Other

//Main register function
function RegisterCommand( Title, Description, ChatCommand, Usage, Flag, Author, CategoryID, RequiredArguments, Callback )
	local Command = {}
	Command.Title = Title
	Command.Description = Description
	Command.ChatCommand = ChatCommand
	Command.Usage = Usage
	Command.Flag = Flag //0 = Everyone can use, 1 = Admin only, 2 = Super Admin only, 3 = Owner only
	Command.Author = Author
	Command.CategoryID = CategoryID
	Command.RequiredArguments = RequiredArguments //Minimal required arguments, will output description when under this
	Command.Callback = Callback
	Command.Checks = {} //See RegisterCheck
	
	table.insert( Commands, Command )
end

//Registering argument checks
//With this nifty function you can let the framework do stuff like checking if a player specified exists!
//Types are:
//
//1 = PLAYEREXISTS
//2 = ISNUMBER
//3 = PLAYEREXISTS_AND_NIL_IS_CALLER
//4 = ON/OFF (Only allows 0 or 1)

function RegisterCheck( CommandTitle, ArgumentID, CheckType, ErrorMsg )
	for _, v in pairs( Commands ) do
		if v.Title == CommandTitle then
			local Check = {}
			Check.Argument = ArgumentID
			Check.CheckType = CheckType
			Check.ErrorMsg = ErrorMsg
			table.insert( v.Checks, Check )
			
			return true
		end
	end
	
	Msg("ERROR: Tried to register callback of undefined command '" .. CommandTitle .. "'\n")
end

//Handles calling
function CallCommand( ChatCommand, Caller, Args )
	if Args == nil then Args = {} end

	for _, v in pairs( Commands ) do
		if v.ChatCommand == ChatCommand then
			if !HasPrivilege( Caller, v.Title ) then
				NA_Notify( "You're not allowed to use this command!", "NOTIFY_ERROR", Caller )
				return false
			end
		
			if table.Count(Args) < v.RequiredArguments then
				t = ""
				if tonumber(v.RequiredArguments) != 1 then t = "s" end
				
				NA_Notify( "The command " .. v.Title .. " requires atleast " .. v.RequiredArguments .. " argument" .. t .. "!", "NOTIFY_ERROR", Caller )
			else
				//Check arguments
				if table.Count( v.Checks ) > 0 then
					for _, c in pairs(v.Checks) do
						//Replacements to make error messages dynamic
						ErrorMsg = c.ErrorMsg
						if Args[c.Argument] ~= nil then ErrorMsg = string.Replace( c.ErrorMsg, "%arg%", Args[ c.Argument ] ) end
					
						if c.CheckType == 1 then
							if GetPlayer( Args[ c.Argument ] ) then
								Args[ c.Argument ] = GetPlayer( Args[ c.Argument ] )
							elseif tonumber(Args[c.Argument]) and player.GetByID(Args[c.Argument]) != NULL then
								Args[ c.Argument ] = player.GetByID(Args[c.Argument])
							else
								NA_Notify( ErrorMsg, "NOTIFY_ERROR", Caller )
								return false
							end
						elseif c.CheckType == 2 then
							if tonumber( Args[ c.Argument ] ) == nil then
								NA_Notify( ErrorMsg, "NOTIFY_ERROR", Caller )
								return false
							else
								Args[ c.Argument ] = tonumber( Args[ c.Argument ] )
							end
						elseif c.CheckType == 3 then
							//Same as 1, but if no player is specified, automatically select the caller!
							if Args[ c.Argument ] == nil then
								Args [ c.Argument ] = Caller
							else
								if GetPlayer( Args[ c.Argument ] ) then
									Args[ c.Argument ] = GetPlayer( Args[ c.Argument ] )
								elseif tonumber(Args[c.Argument]) and player.GetByID(Args[c.Argument]) != NULL then
									Args[ c.Argument ] = player.GetByID(Args[c.Argument])
								else
									NA_Notify( ErrorMsg, "NOTIFY_ERROR", Caller )
									return false
								end
							end
						elseif c.CheckType == 4 then
							if tonumber( Args[ c.Argument ] ) == nil then
								NA_Notify( ErrorMsg, "NOTIFY_ERROR", Caller )
								return false
							else
								if tonumber( Args[ c.Argument ] ) == 0 or tonumber( Args[ c.Argument ] ) == 1 then
									Args[ c.Argument ] = tonumber( Args[ c.Argument ] )
								else
									NA_Notify( ErrorMsg, "NOTIFY_ERROR", Caller )
									return false
								end
							end
						else
							Log( "ERROR: Unknown check registered for argument " .. c.Argument .. " for command '" .. v.Title .. "'!" )
						end
					end
				end
				
				v.Callback( Caller, Args )
			end
			
			return true
		end
	end
end