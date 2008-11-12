//Drawing function
function DrawHUD()
	if pn_enabled then DrawPlayers() end
end
if CLIENT then hook.Add("HUDPaint", "DrawHud", DrawHUD) end

//Enable and disable playernames
pn_enabled = true
function PlayerNames( ply, params )
	if params[1] == "1" then
		pn_enabled = true
		NotifyAll( "Playernames have been enabled by " .. ply:Nick() )
	elseif params[1] == "0" then
		pn_enabled = false
		NotifyAll( "Playernames have been disabled by " .. ply:Nick() )
	end
	
	for _, v in pairs(player.GetAll()) do
		if pn_enabled then
			v:SendLua("pn_enabled = true")
		else
			v:SendLua("pn_enabled = false")
		end
	end
end
AddCommand( "Playernames", "Enable or disable playernames", "playernames", "playernames <1 or 0>", PlayerNames, 2, "Overv", 4)

function Sync( ply )
	if pn_enabled then
		ply:SendLua("pn_enabled = true")
	else
		ply:SendLua("pn_enabled = false")
	end
end
hook.Add("PlayerInitialSpawn", "SyncInfo", Sync)

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
		if v:Nick() ~= LocalPlayer():Nick() and v:GetNetworkedBool("Ghosted") == false and v:GetNetworkedBool("Ragdolled") == false then
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