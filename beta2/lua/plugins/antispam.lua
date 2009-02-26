local MaxRepeats = 10

function AntiPropSpam( ply, mdl )
	if mdl == ply:GetNWString( "LastProp" ) then
		if ply:GetNWInt("Repeats") < MaxRepeats then
			ply:SetNWInt( "Repeats", ply:GetNWInt("Repeats") + 1 )
			Log( ply:Nick() .. " repeated a prop " .. ply:GetNWInt("Repeats") .. " times now." )
		else
			return false
		end
	else
		ply:SetNWInt( "Repeats", 0 )
	end	
	ply:SetNWString( "LastProp", mdl )
end
hook.Add( "PlayerSpawnProp", "AntiPropSpam", AntiPropSpam ) 