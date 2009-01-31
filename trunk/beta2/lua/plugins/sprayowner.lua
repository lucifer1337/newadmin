function ResetSpray( ply )
	ply:SetNWVector( "SprayPos", Vector( 0, 0, 0 ) )
end
hook.Add( "PlayerInitialSpawn", "ResetSpray", ResetSpray )

function OnSpray( ply )
	local pos = ply:GetEyeTrace().HitPos
	ply:SetNWVector( "SprayPos", pos )
end
hook.Add( "PlayerSpray", "HandleSpray", OnSpray )

function ShowSprayOwner()
	local Trace = LocalPlayer():GetEyeTrace()
	local LookAt = Trace.HitPos
	
	for _, pl in pairs(player.GetAll()) do
		local SPos = pl:GetNWVector( "SprayPos" )
		
		if SPos != Vector(0, 0, 0) and LookAt:Distance( SPos ) < 32 and Trace.HitWorld and LocalPlayer():GetPos():Distance( SPos ) < 1024 then
			local Text = pl:Nick() .. "'s Spray"
			surface.SetFont( "ScoreboardText" )
			local w, h = surface.GetTextSize( Text )
			w = w + 5
			h = h + 5
			
			draw.WordBox( 8, ScrW() / 2 - w / 2, ScrH() / 2 - h / 2, Text, "ScoreboardText", Color( 0, 0, 0, 128 ), team.GetColor( pl:Team() ) )
		end
	end
end
hook.Add( "HUDPaint", "ShowSprayOwner", ShowSprayOwner )