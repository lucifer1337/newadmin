//Allow admins and super admins to pick up players
function Pickup( ply, ent )
	if ent and ent:IsValid() and ent:IsPlayer() and HasPrivilege(ply, "Player pickup") then
		ent:GodEnable()
		ent:SetNWBool( "PickedUp", true )
		ent:SetMoveType( MOVETYPE_NONE )
		
		return true
	end
	
	//Flag to make an entity not pick up-able
	if ent:GetNWBool( "BlockPick" ) then
		return false
	end
end
if SERVER then hook.Add("PhysgunPickup", "PhysgunPickupHook", Pickup) end

function Drop( ply, ent )
	if ent and ent:IsValid() and ent:IsPlayer() and HasPrivilege(ply, "Player pickup") then
		if !ply:GetNetworkedBool( "Godded" ) then ent:GodDisable() end
		ent:SetNWBool( "PickedUp", false )
		ent:SetMoveType( MOVETYPE_WALK )
	end
	
	return true
end
if SERVER then hook.Add("PhysgunDrop", "PhysgunDropHook", Drop) end