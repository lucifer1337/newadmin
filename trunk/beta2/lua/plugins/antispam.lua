local MaxRepeats = 10

function AntiPropSpam( ply, mdl )
	if !HasPrivilege( ply, "No AntiSpam" ) then
		if mdl == ply:GetNWString( "LastProp" ) then
			if ply:GetNWInt("Repeats") < MaxRepeats then
				ply:SetNWInt( "Repeats", ply:GetNWInt("Repeats") + 1 )
			else
				return false
			end
		else
			ply:SetNWInt( "Repeats", 0 )
		end	
		ply:SetNWString( "LastProp", mdl )
	end
end
hook.Add( "PlayerSpawnProp", "AntiPropSpam", AntiPropSpam ) 