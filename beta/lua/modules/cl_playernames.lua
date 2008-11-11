//Drawing function
function DrawHUD()
	DrawPlayers()
end
hook.Add("HUDPaint", "DrawHud", DrawHUD)

//Load star icon to draw when a player is an admin or super admin
local Star = surface.GetTextureID("gui/silkicons/star")
surface.SetTexture( Star )
surface.SetDrawColor( 255, 255, 255, 255)

//All the functions for the things drawn in DrawHUD()
function GetHeadPos( ply )
	local BoneIndx = ply:LookupBone("ValveBiped.Bip01_Head1")
	local BonePos, BoneAng = ply:GetBonePosition( BoneIndx )
	
	return BonePos
end

function DrawPlayers()
	local k = nil
	local v = nil
	local maxdistance = 2048
	local maxfullalpha = 512
	
	for k, v in pairs(player.GetAll()) do
		if v:Nick() ~= LocalPlayer():Nick() and v:GetNetworkedBool("Ghosted") == false then
			local pDistance = LocalPlayer():GetShootPos():Distance(v:GetShootPos())		
			
			//Check if the player is even visible (e.g. no wall in between)
			local tracedata = {}
			tracedata.start = LocalPlayer():GetShootPos()
			tracedata.endpos = v:GetShootPos()
			//tracedata.filter = LocalPlayer()
			local trace = util.TraceLine(tracedata)
			
			if pDistance < maxdistance and pDistance > 64 and v:Alive() and trace.HitWorld == false then
				//Calculate alpha
				local dAlpha = 128
				if pDistance > maxfullalpha then
					dAlpha = 128 - math.Clamp((pDistance - maxfullalpha) / (maxdistance-maxfullalpha)*128, 0, 128)
				end
				
				local dPos = GetHeadPos( v ):ToScreen()
				dPos.y = dPos.y - 75
				dPos.y = dPos.y + (100 * (GetHeadPos(v):Distance(LocalPlayer():GetShootPos()) / 2048)) * 0.5
				
				//Draw the box with the playername
				surface.SetFont("ScoreboardText")
				local w = surface.GetTextSize(v:Nick())
				local teamColor = team.GetColor( v:Team() )
				
				if v:IsAdmin() == false then
					draw.RoundedBox( 6, dPos.x-((w+10)/2), dPos.y-10, w+10, 25, Color(0, 0, 0, dAlpha) )
					draw.DrawText( v:Nick(), "ScoreboardText", dPos.x, dPos.y-6, Color(teamColor.r, teamColor.g, teamColor.b, dAlpha), 1 )
				else				
					//Make space and draw text
					ow = w
					w = w + 26
					
					draw.RoundedBox( 6, dPos.x-((w+10)/2), dPos.y-10, w+10, 25, Color(0, 0, 0, dAlpha) )
					draw.DrawText( v:Nick(), "ScoreboardText", dPos.x + 14, dPos.y-6, Color(teamColor.r, teamColor.g, teamColor.b, dAlpha), 1 )
					
					//Draw star
					surface.SetTexture( Star )
					surface.SetDrawColor( 255, 255, 255, dAlpha)
					surface.DrawTexturedRect(dPos.x - (ow / 2) - 12, dPos.y - 6, 16, 16) 
				end
			end
		end
	end
end