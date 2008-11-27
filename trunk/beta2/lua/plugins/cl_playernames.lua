//Drawing function
function DrawHUD()
	if pn_enabled then DrawPlayers() end
end
if CLIENT then hook.Add("HUDPaint", "DrawHud", DrawHUD) end

//Enable and disable playernames
pn_enabled = true
function PlayerNames( ply, params )
	if tonumber(params[1]) == 1 then
		pn_enabled = true
		Notify( "Playernames have been enabled by " .. ply:Nick() )
	elseif tonumber(params[1]) == 0 then
		pn_enabled = false
		Notify( "Playernames have been disabled by " .. ply:Nick() )
	end
	
	for _, v in pairs(player.GetAll()) do
		if pn_enabled then
			v:SendLua("pn_enabled = true")
		else
			v:SendLua("pn_enabled = false")
		end
	end
end
RegisterCommand( "Playernames", "Enable or disable playernames", "playernames", "playernames <1 or 0>", 2, "Overv", 4, 1, PlayerNames )
RegisterCheck( "Playernames", 1, 4, "You need to specify either 1 to enable or 0 to disable playernames!" )

function Sync( ply )
	if pn_enabled then
		ply:SendLua("pn_enabled = true")
	else
		ply:SendLua("pn_enabled = false")
	end
end
hook.Add("PlayerInitialSpawn", "SyncInfo", Sync)

//Load icons
if CLIENT then
	Owner = surface.GetTextureID("gui/silkicons/star")
	User = surface.GetTextureID("gui/silkicons/user")
	Admin = surface.GetTextureID("gui/silkicons/shield")
end

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
		
			Position = v:GetShootPos()
			if v:GetNetworkedBool("Ragdolled") then
				r = ents.GetByIndex( v:GetNetworkedInt( "Ragdoll" ) )
				Position = r:GetPos()
			end
		
			local pDistance = LocalPlayer():GetShootPos():Distance( Position )
			
			//Check if the player is even visible (e.g. no wall in between)
			local tracedata = {}
			tracedata.start = LocalPlayer():GetShootPos()
			tracedata.endpos = Position
			local trace = util.TraceLine(tracedata)
			
			if pDistance < maxdistance and pDistance > 64 and v:Alive() and trace.HitWorld == false then
				//Calculate alpha
				local dAlpha = 128
				if pDistance > maxfullalpha then
					dAlpha = 128 - math.Clamp((pDistance - maxfullalpha) / (maxdistance-maxfullalpha)*128, 0, 128)
				end
				
				if v:GetNetworkedBool("Ragdolled") then
					dPos = GetHeadPos( r ):ToScreen()
				else
					dPos = GetHeadPos( v ):ToScreen()
				end
				
				dPos.y = dPos.y - 75
				dPos.y = dPos.y + (100 * (GetHeadPos(v):Distance(LocalPlayer():GetShootPos()) / 2048)) * 0.5
				
				//Icon
				if Flag(v) == 0 then
					Icon = User
				elseif Flag(v) > 0 and Flag(v) < 3 then
					Icon = Admin
				elseif Flag(v) == 3 then
					Icon = Owner
				end
				
				//Draw the box with the playername
				local w = surface.GetTextSize(v:Nick())
				local teamColor = team.GetColor( v:Team() )
				ow = w
				w = w + 26
				
				draw.RoundedBox( 6, dPos.x-((w+10)/2), dPos.y-10, w+10, 25, Color(0, 0, 0, dAlpha) )
				draw.DrawText( v:Nick(), "ScoreboardText", dPos.x + 14, dPos.y-6, Color(teamColor.r, teamColor.g, teamColor.b, dAlpha), 1 )
				surface.SetTexture( Icon )
				surface.SetDrawColor( 255, 255, 255, dAlpha)
				surface.DrawTexturedRect(dPos.x - (ow / 2) - 12, dPos.y - 6, 16, 16)
			end
		end
	end
end

//Rehook when anything goes wrong
function DrawReHook()
	//hook.Remove( "HUDPaint", "DrawHud" )
	hook.Add("HUDPaint", "DrawHud", DrawHUD)
end
timer.Create( "DrawRehook", 1, 0, DrawReHook )