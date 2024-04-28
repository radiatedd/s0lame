Hooks = Hooks or {}

Hooks.CurrentCUserCMD = 0
Hooks.CurrentTick = 0

Hooks.allEnts = {}
Hooks.closest = NULL

function Hooks:CreateMove(cmd)
	if cmd:CommandNumber() ~= 0 then
		Hooks.CurrentCUserCMD = cmd:CommandNumber()
		Hooks.CurrentTick = cmd:TickCount()
	end

	if not LPLY:Alive() then return end

	sMove.Data.preCMoveViewAngle = cmd:GetViewAngles()
	
	if sAim.m_tSettings.Toggle then sAim:Init(cmd) end
	if RPStuff.m_tSettings.Toggle then RPStuff:Init(cmd) end
	if sMove.m_tSettings.Toggle then sMove:Init(cmd) end
		
	sMove.Data.postCMoveViewAngle = cmd:GetViewAngles()
end

local WasCalled = false

if bHasProxi then
	hook.Remove("CreateMoveEx", "cmoveExstuff")
	hook.Remove("CreateMove", "cmovestuff")

	hook.Add("CreateMoveEx", "cmoveExstuff", function(cmd) -- CreateMoveEx has updated prediction by default and is ran after regular CreateMove is called
		Hooks:CreateMove(cmd)
		if sMove.m_tSettings.AntiAim then
			sMove:performAngles(cmd, sMove.Data.postCMoveViewAngle)
		end
		sMove:fixMovement(cmd)
		return true, sAim.Data.bShouldEngineViewAngles
	end)
else
	hook.Remove("CreateMoveEx", "cmoveExstuff")
	hook.Remove("CreateMove", "cmovestuff")

	hook.Add("CreateMove", "cmovestuff", function(cmd)
		cmd:SetViewAngles(sMove.Data.viewAngle)
		Hooks:CreateMove(cmd)
		if sMove.m_tSettings.AntiAim then
			sMove:performAngles(cmd, sMove.Data.postCMoveViewAngle)
		end
		sMove:fixMovement(cmd)
		--sMove:FixAngles(cmd)
	end)
end

hook.Add("EntityFireBullets", "firebullets", function(ent, bul)
    if ent ~= LPLY then return end
	local src, spread, dir, dist = bul.Src, bul.Spread, bul.Dir, bul.Distance

	local wep = ent:GetActiveWeapon()
	if not wep:IsValid() then return end

    local class = wep:GetClass()

	if not NS.wepcone[class] or (wep:IsScripted() and NS.wepcone[class] ~= spread) then
		NS.wepcone[class] = spread
	end

	if spread:LengthSqr() ~= 0 then
		sUtil:debugCone(ent, src, dir, dist, spread, 1, Color(255,0,0))
	end
end)

hook.Add("Move", "movestuff", function()
    if IsFirstTimePredicted() then
        sAim.Data.bulletTime = CurTime() + engine.TickInterval()
    end
end)

hook.Add("CalcView", "cviewstuff", function( ply, pos, angles, fov )
	return sCam:Init( ply, pos, angles, fov )
end)

hook.Add("PostDrawHUD", "balls", function()
    sVis:CrossedHair()
end)

--[[
		cam.Start3D()
		-- top
		render.DrawLine(points_3d[1], points_3d[2], tSettings.col1)
		render.DrawLine(points_3d[2], points_3d[3], tSettings.col1)
		render.DrawLine(points_3d[3], points_3d[4], tSettings.col1)
		render.DrawLine(points_3d[4], points_3d[1], tSettings.col1)
		-- bottom
		render.DrawLine(points_3d[5], points_3d[6], tSettings.col1)
		render.DrawLine(points_3d[6], points_3d[7], tSettings.col1)
		render.DrawLine(points_3d[7], points_3d[8], tSettings.col1)
		render.DrawLine(points_3d[8], points_3d[5], tSettings.col1)
		-- corners
		render.DrawLine(points_3d[1], points_3d[5], tSettings.col1)
		render.DrawLine(points_3d[2], points_3d[6], tSettings.col1)
		render.DrawLine(points_3d[3], points_3d[7], tSettings.col1)
		render.DrawLine(points_3d[4], points_3d[8], tSettings.col1)
		cam.End3D()
]]

hook.Remove("PostDrawTranslucentRenderables", "ass", function(bd, bs)
	if bd or bs then return end
end)

local steps = {}
hook.Add("HUDPaint", "hudpaintstuff", function()
	local XRayEnts = {}
	local ChamEnts = {}
	if #Hooks.allEnts > 1 then
		for i = 1, #Hooks.allEnts do
			local ent = Hooks.allEnts[i]
			if not ent or not ent:IsValid() then continue end
		
			--local bOnScreen = sVis:OnScreen(ent)
			--if not bOnScreen then continue end
		
			if sMenu.WhiteListEnts[ent:GetClass()] == true then
				XRayEnts[#XRayEnts + 1] = ent
			end

			if ent:IsPlayer() and ent:Alive() then
				ChamEnts[#ChamEnts + 1] = ent
			end
		end
	end

	cam.Start3D()
	if sVis.m_tSettings._3D.Toggle then
		if sVis.m_tSettings._3D.xray then
			render.SuppressEngineLighting(sVis.m_tSettings._3D.xray_lighting)
			if #XRayEnts > 0 then
				for i = 1, #XRayEnts do
					local ent = XRayEnts[i]
					if not ent:IsValid() then continue end

					local mattype = sVis.m_tSettings._3D.xray_mat
					local mattype2 = sVis.m_tSettings._3D.xray_mat2

					local mat1 = sVis.mat[mattype]
					local mat2 = sVis.mat[mattype2]

					local col = sVis.m_tSettings._3D.xray_col
					local col2 = sVis.m_tSettings._3D.xray_col2

					local colinv1 = sUtil:InvertColor(col)
					local colinv2 = sUtil:InvertColor(col2)

					if sVis.m_tSettings._3D.xray_nodraw then
						ent:SetRenderMode(RENDERMODE_ENVIROMENTAL)
					else
						ent:SetRenderMode(RENDERMODE_NORMAL)
					end

					ent:SetLOD(sVis.m_tSettings._3D.LOD)

					if mattype ~= "none" then
						mat1:SetVector("$envmaptint", Vector(colinv1.r/255,colinv1.g/255,colinv1.b/255)) 
						render.ModelMaterialOverride(mat1)
						render.SetColorModulation(col.r/255,col.g/255,col.b/255)
						render.SetBlend(col.a/255)
						ent:DrawModel()
						render.SetColorModulation(1, 1, 1)
						render.SetBlend(1)
						render.ModelMaterialOverride(nil)
					end

					if mattype2 ~= "none" then
						render.ModelMaterialOverride(mat2)
						render.SetColorModulation(col2.r/255,col2.g/255,col2.b/255)
						render.SetBlend(col2.a/255)
						ent:DrawModel()
						render.SetColorModulation(1, 1, 1)
						render.SetBlend(1)
						render.ModelMaterialOverride(nil)
					end
				end
			end
			render.SuppressEngineLighting(false)
		end
		if sVis.m_tSettings._3D.chams then
			render.SuppressEngineLighting(sVis.m_tSettings._3D.chams_lighting)
			if #ChamEnts > 0 then
				for i = 1, #ChamEnts do
					local ent = ChamEnts[i]
					if not ent:IsValid() then continue end

					local mattype = sVis.m_tSettings._3D.chams_mat
					local mattype2 = sVis.m_tSettings._3D.chams_mat2

					local mat1 = sVis.mat[mattype]
					local mat2 = sVis.mat[mattype2]

					local team = team.GetColor(ent:Team())

					local col = ent:IsDormant() and Color(100, 100, 100, 100) or sVis.m_tSettings._3D.chams_teamcol and Color(team.r, team.g, team.b, sVis.m_tSettings._3D.chams_col.a) or sVis.m_tSettings._3D.chams_col
					local col2 = ent:IsDormant() and Color(100, 100, 100, 100) or sVis.m_tSettings._3D.chams_teamcol and Color(team.r, team.g, team.b, sVis.m_tSettings._3D.chams_col2.a) or sVis.m_tSettings._3D.chams_col2

					local colinv1 = sUtil:InvertColor(col)
					local colinv2 = sUtil:InvertColor(col2)

					if sVis.m_tSettings._3D.chams_nodraw then
						ent:SetRenderMode(RENDERMODE_ENVIROMENTAL)
					else
						ent:SetRenderMode(RENDERMODE_NORMAL)
					end

					ent:SetLOD(sVis.m_tSettings._3D.LOD)

					if mattype ~= "none" then
						--mat1:SetVector("$envmaptint", Vector(colinv1.r/255,colinv1.g/255,colinv1.b/255)) 
						--mat2:SetInt("$ignorez", 1)
						render.ModelMaterialOverride(mat1)
						render.SetColorModulation(col.r/255,col.g/255,col.b/255)
						render.SetBlend(col.a/255)
						ent:DrawModel()
						render.SetColorModulation(1, 1, 1)
						render.SetBlend(1)
						render.ModelMaterialOverride(nil)
					end

					if mattype2 ~= "none" then
						--mat2:SetVector("$envmaptint", Vector(colinv2.r/255,colinv2.g/255,colinv2.b/255))
						--mat2:SetInt("$ignorez", 1)
						render.ModelMaterialOverride(mat2)
						render.SetColorModulation(col2.r/255,col2.g/255,col2.b/255)
						render.SetBlend(col2.a/255)
						ent:DrawModel()
						render.SetColorModulation(1, 1, 1)
						render.SetBlend(1)
						render.ModelMaterialOverride(nil)
					end
				end
			end
			render.SuppressEngineLighting(false)
		end
		if sVis.m_tSettings._3D.cham_halos then
			local col = sVis.m_tSettings._3D.cham_halo_col

			if sVis.m_tSettings._3D.cham_halo_rainbow then
				col = HSVToColor(SysTime() * 50 % 360, 1, 1)
			end

			sVis:DrawOutlines(ChamEnts, {
				col = col,
				thickness = sVis.m_tSettings._3D.cham_halo_thickness
			})
		end
		if sVis.m_tSettings._3D.xray_halos then
			local col = sVis.m_tSettings._3D.xray_halo_col

			if sVis.m_tSettings._3D.xray_halo_rainbow then
				col = HSVToColor(SysTime() * 50 % 360, 1, 1)
			end

			sVis:DrawOutlines(XRayEnts, {
				col = col,
				thickness = sVis.m_tSettings._3D.xray_halo_thickness
			})
		end
	end
	cam.End3D()

	if sVis.m_tSettings._2D.Toggle then
		if #XRayEnts > 0 then
			for i = 1, #XRayEnts do
				local ent = XRayEnts[i]
				if not ent:IsValid() then continue end
				local x, y, w, h, points_3d = sVis:BoundingBox(ent)
				if not x then continue end
				if sVis.m_tSettings._2D.xrayBoxes then
					local col1 = sVis.m_tSettings._2D.bbox_col
					local col2 = sVis.m_tSettings._2D.bbox_col_outline
	
					if ent:IsDormant() then
						col1 = Color(200, 200, 200, 75)
						col2.a = 75
					end			

					sVis:Draw2DBoxes(x, y, w, h, {
						style = sVis.m_tSettings._2D.bbox_style, -- CORNERS, FULL
						col1 = col1,
						col2 = col2,
						length = sVis.m_tSettings._2D.bbox_length,
					})
				end
			end
		end

		for k, ply in ipairs(Hooks.allEnts) do
			if not ply or not ply:IsValid() or not ply:IsPlayer() or not ply:Alive() then continue end
			local x, y, w, h, points_3d = sVis:BoundingBox(ply)
			if not x then continue end

			local box_2d_x, box_2d_y = (x + w + x) / 2,(y + h + y) / 2
			local bOnScreen = sVis:OnScreen(ply)

			if sVis.m_tSettings._2D.osi and not bOnScreen then
				local col1 = sVis.m_tSettings._2D.osi_teamcol and team.GetColor(ply:Team()) or sVis.m_tSettings._2D.osi_col
				sVis:OffScreenIndicators(ply, {
					dist = sVis.m_tSettings._2D.osi_dist,
					scale = sVis.m_tSettings._2D.osi_scale,
					col1 = col1,
					col2 = sVis.m_tSettings._2D.osi_col_outline,
					shape = sVis.m_tSettings._2D.osi_shape
				})
			end

			if not bOnScreen then continue end

			if sVis.m_tSettings._2D.bbox then
				local col1 = sVis.m_tSettings._2D.bbox_teamcol and team.GetColor(ply:Team()) or sVis.m_tSettings._2D.bbox_col
				local col2 = sVis.m_tSettings._2D.bbox_col_outline	

				if ply:IsDormant() then
					col1 = Color(200, 200, 200, 75)
					col2.a = 75
				end			

				if sVis.m_tSettings._2D.D3D9BBox then
					sVis:DrawD3D9Boxes(ply, {
						col1 = col1
					})
				else
					sVis:Draw2DBoxes(x, y, w, h, {
						style = sVis.m_tSettings._2D.bbox_style, -- CORNERS, FULL
						col1 = col1,
						col2 = col2,
						length = sVis.m_tSettings._2D.bbox_length,
					})
				end
			end

			if sVis.m_tSettings._2D.dormancyPred then 
				local ppos = ply:GetPos()
				if ply:IsDormant() then
					if ply:GetAbsVelocity():Length() > 0 then
						steps[ply] = steps[ply] or 0
						steps[ply] = steps[ply] + (1 * sUtil.cRealFrameTime)
						steps[ply] = math.Clamp(steps[ply], 0, 1)
					end
					if not steps[ply] then return end
					local ticks = 1/engine.TickInterval()
					local nextpos = sVis.m_tSettings._2D.dormancyPred_smart and MPredict:PredictMove(ply, ticks) or ppos + ply:GetAbsVelocity() * engine.TickInterval() * ticks
					local newpos = LerpVector(steps[ply], ppos, nextpos):ToScreen()

					local col1 = sVis.m_tSettings._2D.bbox_teamcol and team.GetColor(ply:Team()) or sVis.m_tSettings._2D.bbox_col
					local col2 = sVis.m_tSettings._2D.bbox_col_outline	

					sVis:Draw2DBoxes(newpos.x - (w / 2), newpos.y - h, w, h, {
						style = sVis.m_tSettings._2D.bbox_style,
						col1 = col1,
						col2 = col2,
						length = sVis.m_tSettings._2D.bbox_length,
					})
				else
					steps[ply] = 0
				end
			end

			if sVis.m_tSettings._2D.healthbar then
				sVis:CreateBar(x, y, w, h, {
					minVal = 0,
					maxVal = ply:GetMaxHealth(),
					minCol = sVis.m_tSettings._2D.healthbarcolMin,
					maxCol = sVis.m_tSettings._2D.healthbarcolMax,
					currentVal = ply:Health(),
					fill = sVis.m_tSettings._2D.healthbarFill, -- TOP, MIDDLE, BOTTOM | LEFT, MIDDLE, RIGHT
					dock = sVis.m_tSettings._2D.healthbarDock, -- LEFT, RIGHT, | TOP, BOTTOM
					--ang = sVis.m_tSettings._2D.healthbarAng, -- HORIZONTAL, VERTICAL
					thickness = sVis.m_tSettings._2D.healthbarThickness,
				})
			end

			if sVis.m_tSettings._2D.armorbar then
				sVis:CreateBar(x, y, w, h, {
					minVal = 0,
					maxVal = ply:GetMaxArmor(),
					minCol = sVis.m_tSettings._2D.armorbarcolMin,
					maxCol = sVis.m_tSettings._2D.armorbarcolMax,
					currentVal = ply:Armor(),
					fill = sVis.m_tSettings._2D.armorbarFill, -- TOP, MIDDLE, BOTTOM | LEFT, MIDDLE, RIGHT
					dock = sVis.m_tSettings._2D.armorbarDock, -- LEFT, RIGHT, | TOP, BOTTOM
					--ang = sVis.m_tSettings._2D.armorbarAng, -- HORIZONTAL, VERTICAL
					thickness = sVis.m_tSettings._2D.armorbarThickness,
				})
			end

			if sVis.m_tSettings._2D.names then
				local col1 = sVis.m_tSettings._2D.names_teamcol and team.GetColor(ply:Team()) or sVis.m_tSettings._2D.names_col
				local col2 = sVis.m_tSettings._2D.names_col_outline
				local font = "font"

				if ply:IsDormant() then
					font = "fontAlpha"
					col1 = Color(200, 200, 200, 75)
					col2.a = 75
				end

				local str = sVis:undecorateString(ply:Nick())
				sVis:Draw2DText(str, x, y, w, h, {
					dockX = sVis.m_tSettings._2D.names_dockX, -- LEFT, RIGHT, MIDDLE
					dockY = sVis.m_tSettings._2D.names_dockY, -- TOP, BOTTOM, MIDDLE
					col1 = col1,
					col2 = col2,
					font = font,
					scroll = sVis.m_tSettings._2D.names_scroll,
					ent = ply
				})
				if sAim.Data.activeTarget == ply then
					surface.SetDrawColor(HSVToColor(CurTime()*100%360, 1, 1))
					surface.DrawRect(box_2d_x-3, box_2d_y-3, 6, 6)
				end
			end
		end
		--RPStuff:keypadDraw()
	end
end)

--hook.Add("PlayerFootstep", "footsteps", function(ply, pos)
--	debugoverlay.Box(pos, Vector(-1,-1,-1), Vector(1,1,1), 0.25, Color( 255, 255, 255 ))
--end)

local IsDrawingBase = false
local IsDrawingOverlay = false

hook.Add("PreDrawViewModel", "vmstuff", function(vm, ply, wep)
	if not sVis.m_tSettings._3D.vm_chams or not wep:IsValid() then return end
	local mattype = sVis.m_tSettings._3D.vm_chams_mat
	local mattype2 = sVis.m_tSettings._3D.vm_chams_mat2

	local mat1 = sVis.mat[mattype]
	local mat2 = sVis.mat[mattype2]

	local col = sVis.m_tSettings._3D.vm_chams_col
	local col2 = sVis.m_tSettings._3D.vm_chams_col2

	local colinv1 = sUtil:InvertColor(col)
	local colinv2 = sUtil:InvertColor(col2)

	render.SuppressEngineLighting(sVis.m_tSettings._3D.vm_chams_lighting)

	if IsDrawingBase then
		if mattype ~= "none" then 
			mat1:SetVector("$envmaptint", Vector(colinv1.r/255,colinv1.g/255,colinv1.b/255)) 
			render.SetColorModulation(col.r/255, col.g/255, col.b/255)
			render.ModelMaterialOverride(mat1) 
			render.SetBlend(col.a/255)
		end
	elseif IsDrawingOverlay then
		if mattype2 ~= "none" then	
			mat2:SetVector("$envmaptint", Vector(colinv2.r/255,colinv2.g/255,colinv2.b/255)) 
			render.SetColorModulation(col2.r/255, col2.g/255, col2.b/255) 
			render.ModelMaterialOverride(mat2) 
			render.SetBlend(col2.a/255)
		end
	elseif not IsDrawingBase and not IsDrawingOverlay then
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
	end
end)

hook.Add("PostDrawViewModel", "vmstuff", function(vm, ply, wep)
	if not sVis.m_tSettings._3D.vm_chams or not wep:IsValid() then return end
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)
	render.SetBlend(1)
	render.SuppressEngineLighting(false)
 
	if not IsDrawingBase then
		IsDrawingBase = true
		LocalPlayer():GetViewModel():DrawModel()
		IsDrawingBase = false
	end

	if not IsDrawingOverlay then
		IsDrawingOverlay = true
		LocalPlayer():GetViewModel():DrawModel()
		IsDrawingOverlay = false
	end
end)

hook.Add("PreDrawPlayerHands", "handstuff", function(hands, vm, ply, wep)
	if not sVis.m_tSettings._3D.hand_chams or not hands:IsValid() then return end
	local mattype = sVis.m_tSettings._3D.hand_chams_mat
	local mattype2 = sVis.m_tSettings._3D.hand_chams_mat2

	local mat1 = sVis.mat[mattype]
	local mat2 = sVis.mat[mattype2]

	local col = sVis.m_tSettings._3D.hand_chams_col
	local col2 = sVis.m_tSettings._3D.hand_chams_col2

	local colinv1 = sUtil:InvertColor(col)
	local colinv2 = sUtil:InvertColor(col2)

	render.SuppressEngineLighting(sVis.m_tSettings._3D.hand_chams_lighting)

	if IsDrawingBase then
		if mattype ~= "none" then 
			mat1:SetVector("$envmaptint", Vector(colinv1.r/255,colinv1.g/255,colinv1.b/255))
			render.SetColorModulation(col.r/255, col.g/255, col.b/255)
			render.ModelMaterialOverride(mat1) 
			render.SetBlend(col.a/255)
		end
	elseif IsDrawingOverlay then
		if mattype2 ~= "none" then	
			mat2:SetVector("$envmaptint", Vector(colinv2.r/255,colinv2.g/255,colinv2.b/255)) 
			render.SetColorModulation(col2.r/255, col2.g/255, col2.b/255) 
			render.ModelMaterialOverride(mat2) 
			render.SetBlend(col2.a/255)
		end
	elseif not IsDrawingBase and not IsDrawingOverlay then
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
	end
end)

hook.Add("PostDrawPlayerHands", "handstuff", function(hands, vm, ply, wep)
	if not sVis.m_tSettings._3D.hand_chams or not hands:IsValid() then return end
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)
	render.SetBlend(1)
	render.SuppressEngineLighting(false)
 
	if not IsDrawingBase then
		IsDrawingBase = true
		LocalPlayer():GetViewModel():DrawModel()
		IsDrawingBase = false
	end

	if not IsDrawingOverlay then
		IsDrawingOverlay = true
		LocalPlayer():GetViewModel():DrawModel()
		IsDrawingOverlay = false
	end
end)

--hook.Add("PrePlayerDraw", "preplydrawstuff", function(ply)
--	if ply == LPLY then return end
--	render.SuppressEngineLighting(true)
--	cam.IgnoreZ(true)
--
--	ply:SetLOD(sVis.m_tSettings._3D.LOD)
--end)
--
--hook.Add("PostPlayerDraw", "postplydrawstuff", function(ply)
--	if ply == LPLY then return end
--
--	cam.IgnoreZ(false)
--	render.SuppressEngineLighting(false)
--end)

--hook.Add("PostDrawTranslucentRenderables", "pdtrstuff", function(bD, bS)
--	if bD or bS then return end
--	if not LPLY:Alive() then return end
--	if not sVis.m_tSettings._3D.Toggle then return end
--	--if input.IsButtonDown(input.GetKeyCode("alt")) or input.IsButtonDown(input.GetKeyCode("e")) then
--	--	local validEnts, pocketableEnts, useableEnts = RPStuff:PopulateEntTable(g_flRange)
--	--	if #validEnts > 0 then
--	--		for i, v in ipairs(validEnts) do
--	--			render.SetColorMaterial()
--	--			local col = Color(0, (i/#validEnts)*255, (1-(i/#validEnts))*255, 255)
--	--			col.a = (i/#validEnts)*100
--	--			render.DrawBox( v:GetPos(), v:GetAngles(), v:OBBMins(), v:OBBMaxs(), col)
--	--		end
--	--	end
--	--end
--end)

concommand.Add("nightmode", function()--sky_halloween
    local col = Color(50,50,50)
    for k, v in pairs(game.GetWorld():GetMaterials()) do
        Material(v):SetVector("$color",Vector(col.r/255,col.g/255,col.b/255))
    end
    render.SuppressEngineLighting( true )
    render.ResetModelLighting(1,1,1)
    render.SuppressEngineLighting( false )
end)
concommand.Add("daymode", function()
    for k, v in pairs(game.GetWorld():GetMaterials()) do
        Material(v):SetVector("$color",Vector(1,1,1))
    end
    render.SuppressEngineLighting( false )
    render.ResetModelLighting(1, 1, 1)
end)

hook.Add("PostDraw2DSkyBox", "skyboxstuff", function()
	return render.Clear(0, 0, 0, 255)
end)

gameevent.Listen("player_hurt")
hook.Add("player_hurt", "playerhurt", function(event)
    local attacker = Player(event.attacker)       
    local victim = Player(event.userid)
    local health = event.health
    if not victim:IsValid() or not attacker:IsValid() or victim == attacker or attacker ~= LPLY or not victim:IsPlayer() then return end
    surface.PlaySound("garrysmod/balloon_pop_cute.wav")
end)

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "entkilled", function(event)
    local attacker = Entity(event.entindex_attacker)       
    local victim = Entity(event.entindex_killed)    
    if not victim:IsValid() or not attacker:IsValid() or victim == attacker or attacker ~= LPLY or not victim:IsPlayer() then return end
    surface.PlaySound("buttons/blip1.wav")
end)

hook.Add("Think", "clock", function()
	--RPStuff:logKeypads()
	sUtil.cRealFrameTime = math.Clamp( SysTime( ) - sUtil.LastQuery, 0, 0.1 )
	sUtil.LastQuery = SysTime()
end)

local nextTick = engine.TickCount()
hook.Add("Tick", "plyclock", function()
	for k, v in next, ents.FindByClass("crossbow_bolt") do
		local mins, maxs = v:OBBMins(), v:OBBMaxs()
		local pos, ang = v:GetNetworkOrigin(), v:GetNetworkAngles()
		local col = HSVToColor(CurTime()*100%360, 1, 1)
		col.a = 1
		debugoverlay.BoxAngles(pos, mins, maxs, ang, 0.5, col)
	end
	local int = sVis.m_tSettings.Rate/engine.TickInterval()
	if int ~= 0 and nextTick <= engine.TickCount() then
		Hooks.allEnts, Hooks.closest = sUtil:getEnt(sVis.m_tSettings.Range, nil)

        nextTick = engine.TickCount() + int
    end
end)

local hide = {
	["CHudZoom"] = true
}
hook.Add("HUDShouldDraw", "shouldhud", function(name)
	if ( hide[ name ] ) then
		return false
	end
end)

RunConsoleCommand("cl_interp_ratio", "1")
RunConsoleCommand("cl_interp", MPredict:RoundToTick(GetConVar("cl_interp"):GetFloat()))
RunConsoleCommand("engine_no_focus_sleep", "0")
RunConsoleCommand("developer", "1")
RunConsoleCommand("cl_updaterate", tostring(GetConVar("sv_maxupdaterate"):GetFloat()))
RunConsoleCommand("cl_cmdrate", tostring(GetConVar("sv_maxupdaterate"):GetFloat()))

s0lame.RegisterHack("Hooks", "0.1", Hooks)