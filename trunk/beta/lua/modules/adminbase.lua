//This module protects the admin base :D
local maxnocliph = 1043
local enabled = true

ConsoleMsg( "Adminbase protector inialized!" )

function SetUp( ply )
	ply:SetNetworkedBool( "InZone", false )
end
if SERVER then hook.Add( "PlayerInitialSpawn", "SetUp", SetUp) end

function CheckH( ply )
	if enabled == true then
		local pos = ply:GetPos()
		
		if pos.z > maxnocliph then
			ply:SetMoveType( MOVETYPE_WALK )
			
			if ply:GetNetworkedBool( "InZone" ) == false then
				SendNotify( ply, "You're not allowed to noclip in the admin base zone!", "NOTIFY_ERROR" )
			end
			
			ply:SetNetworkedBool( "InZone", true )
		else
			ply:SetNetworkedBool( "InZone", false )
		end
	end
end
if SERVER then hook.Add( "Move", "CheckH", CheckH ) end

function ProtectBase( ply, params )
	if params[1] == "1" then
		enabled = true
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, "Admin base protection has been enabled by " .. ply:Nick() )
		end
	elseif params[1] == "0" then
		enabled = false
		
		for k, v in pairs(player.GetAll()) do
			SendNotify( v, "Admin base protection has been disabled by " .. ply:Nick() )
		end
	end
end
AddCommand( "Base Protect", "Enable or disable the noclip limit", "protectbase", "protectbase <1 or 0>", ProtectBase, 2, "Overv", 3)