//Allow admins and super admins to pick up players
function Pickup( ply, ent )
	if ent and ent:IsValid() and ent:IsPlayer() and GetFlags(ply) > 0 then
		ent:GodEnable()
		ent:SetNetworkedBool( "PickedUp", true )
		ent:SetMoveType( MOVETYPE_NONE )
		
		return true
	end
end
if SERVER then hook.Add("PhysgunPickup", "PhysgunPickupHook", Pickup) end

function Drop( ply, ent )
	if ent and ent:IsValid() and ent:IsPlayer() and GetFlags(ply) > 0 then
		ent:GodDisable()
		ent:SetNetworkedBool( "PickedUp", false )
		ent:SetMoveType( MOVETYPE_WALK )
	end
	
	return true
end
if SERVER then hook.Add("PhysgunDrop", "PhysgunDropHook", Drop) end