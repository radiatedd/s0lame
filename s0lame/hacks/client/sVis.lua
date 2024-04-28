sVis = sVis or {}

sVis.m_tSettings = {
    Toggle = false,
	Range = 10000,
	Rate = 0.375,
    _2D = {
        Toggle = true,

		mintextlen = 95, --25
		maxtextlen = 500,

        names = true,
		names_col = Color(175,0,255),
		names_teamcol = false,
		names_col_outline = Color(0,0,0),
		names_dockX = "MIDDLE",
		names_dockY = "TOP",
		names_scroll = "NONE",

        bbox = true,
		bbox_style = "FULL",
		bbox_col =  Color(175,0,255),
		bbox_teamcol = false,
		bbox_col_outline = Color(0,0,0),
		bbox_length = 1,
		D3D9BBox = false,
		xrayBoxes = false,

        osi = true,
		osi_dist = 1,
		osi_scale = 180,
		osi_col = Color(255, 255, 255),
		osi_col_outline = Color(0, 0, 0),
		osi_teamcol = true,
		osi_shape = "TRIANGLE",

		healthbar = true,
		healthbarcolMin = Color(255,0,0),
		healthbarcolMax = Color(0,255,0),
		healthbarDock = "BOTTOM",
		healthbarThickness = 2,
		healthbarFill = "MIDDLE",

		armorbar = false,
		armorbarcolMin = Color(255,0,0),
		armorbarcolMax = Color(0,0,255),
		armorbarDock = "RIGHT",
		armorbarThickness = 2,
		armorbarFill = "RIGHT",

		dormancyPred = true,
		dormancyPred_smart = false,
    },
    _3D = {
        Toggle = true,
        chams = true,
		chams_mat = "glowy",
		chams_mat2 = "flat",
		chams_col = Color(0,160,255),
		chams_col2 = Color(255,0,0, 100),
		chams_teamcol = false,
		chams_nodraw = true,
		chams_lighting = true,

		cham_halos = true,
		cham_halo_col = Color(255, 0, 255),
		cham_halo_thickness = 2,
		cham_halo_rainbow = false,

		xray_halos = true,
		xray_halo_col = Color(0, 255, 255),
		xray_halo_thickness = 2,
		xray_halo_rainbow = false,

		xray = true,
		xray_mat = "flat",
		xray_mat2 = "glowy",
		xray_col = Color(0,0,255),
		xray_col2 = Color(255,0,0, 50),
		xray_nodraw = false,
		xray_lighting = true,

		vm_chams = true,
		vm_chams_mat = "hoverball",
		vm_chams_mat2 = "wire",
		vm_chams_col = Color(0,255,0, 150),
		vm_chams_col2 = Color(0,255,0),
		vm_chams_lighting = true,

		hand_chams = true,
		hand_chams_mat = "glowy",
		hand_chams_mat2 = "flat",
		hand_chams_col = Color(0,255,0, 200),
		hand_chams_col2 = Color(255,255,255, 255),
		hand_chams_lighting = true,

        hitboxes = false,
		LOD = 5,
    }
}

sVis.mat = {
	wire = CreateMaterial("1 " .. tostring(SysTime()), "Wireframe",{
    	["$basetexture"] = "hlmv/debugmrmwireframe",
		["$nocull"] = 1,
		["$ignorez"] = 0
	}),
	flat = CreateMaterial("2 " .. tostring(SysTime()), "VertexLitGeneric",{
		["$basetexture"] = "color/white",
		["$nocull"] = 1,
		["$ignorez"] = 0
	}),
	shiny = CreateMaterial("3 " .. tostring(SysTime()), "VertexLitGeneric",{
		["$basetexture"] = "vgui/white_additive",
		["$envmap"] = "effects/cubemapper",
		["$nocull"] = 1,
		["$ignorez"] = 0
	}),
	glowy = CreateMaterial("4 " .. tostring(SysTime()), "VertexLitGeneric",{
		["$basetexture"] = "vgui/white_additive",
		["$bumpmap"] = "vgui/white_additive",

		["$selfillum"] = 1,
		["$selfillumFresnel"] = 1,
		["$selfillumFresnelMinMaxExp"] = "[0 1 1]",
		["$selfillumtint"] = "[0 0 0]",

    	["$ignorez"] = 0
	}),
    blaze = CreateMaterial("5 " .. tostring(SysTime()), "VertexLitGeneric",{
        ["$basetexture"] = "sprites/physbeam",
        ["$nodecal"] = 1,
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$nocull"] = 1,
        ["Proxies"] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$basetexturetransform",
                ["texturescrollrate"] = 0.4,
                ["texturescrollangle"] = 70,
            }
        },
		["$ignorez"] = 0
    }),
    tiger = CreateMaterial("6 " .. tostring(SysTime()), "VertexLitGeneric", {
        ["$basetexture"] = "models/gibs/hgibs/skull1",
    --    ["$model"] = 1,
     --  ["$additive"] = 0,
    -- ["$ignorez"] = 0,
    }),
    flame = CreateMaterial("7 " .. tostring(SysTime()), "VertexLitGeneric",{
        ["$basetexture"] = "effects/tiledfire/firelayeredslowtiled512",
        ["$nodecal"] = 1,
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$nocull"] = 1,
        ["Proxies"] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$basetexturetransform",
                ["texturescrollrate"] = 0.2,
                ["texturescrollangle"] = 50,
            }
        },
		["$ignorez"] = 0
    }),
	portal = CreateMaterial("8 " .. tostring(SysTime()), "VertexLitGeneric",{
        ["$basetexture"] = "models/props_combine/portalball001_sheet",
        ["$nodecal"] = 1,
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$nocull"] = 1,
        ["Proxies"] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$basetexturetransform",
                ["texturescrollrate"] = 0.2,
                ["texturescrollangle"] = 50,
            }
        },
		["$ignorez"] = 0
    }),
	hoverball = CreateMaterial("9 " .. tostring(SysTime()), "VertexLitGeneric",{
        ["$basetexture"] = "models/dav0r/hoverball",
        ["$nodecal"] = 1,
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$nocull"] = 1,
        ["Proxies"] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$basetexturetransform",
                ["texturescrollrate"] = 0.2,
                ["texturescrollangle"] = 50,
            }
        },
		["$ignorez"] = 0
    }),
}

function sVis:BoundingBox(ent)
	if not ent:IsValid() then return end
	local min, max = ent:WorldSpaceAABB()
	local points = {
		Vector(min.x,min.y,max.z),
		Vector(min.x,max.y,max.z),
		Vector(max.x,max.y,max.z),
		Vector(max.x,min.y,max.z),
		Vector(min.x,min.y,min.z),
		Vector(min.x,max.y,min.z),
		Vector(max.x,max.y,min.z),
		Vector(max.x,min.y,min.z)
	}

	local mins, maxs = {x = ScrW() + 200, y = ScrH() + 200}, {x = -200, y = -200}

	for i = 1, 8 do
		local s = points[i]:ToScreen()
		maxs.x = math.max(maxs.x, s.x)
		maxs.y = math.max(maxs.y, s.y)
		mins.x = math.min(mins.x, s.x)
		mins.y = math.min(mins.y, s.y)
	end

	return mins.x, mins.y, maxs.x - mins.x, maxs.y - mins.y, points
end

function sVis:undecorateString(str)
	return str:gsub("[\n\t\r]", "")
end

function sVis:CreateBar(x, y, w, h, tSettings)
	tSettings = tSettings or {}
	tSettings.minVal = tSettings.minVal or 0
	tSettings.maxVal = tSettings.maxVal or 100
	tSettings.minCol = tSettings.minCol or Color(255,0,0, 100)
	tSettings.maxCol = tSettings.maxCol or Color(0,255,0, 255)
	tSettings.currentVal = tSettings.currentVal or 10
	tSettings.fill = tSettings.fill or "MIDDLE" -- TOP, MIDDLE, BOTTOM | LEFT, MIDDLE, RIGHT
	tSettings.dock = tSettings.dock or "LEFT" -- LEFT, RIGHT, | TOP, BOTTOM
	tSettings.ang = tSettings.ang or "HORIZONTAL" -- HORIZONTAL, VERTICAL
	tSettings.thickness = tSettings.thickness or 5

	local barX, barY = 0, 0

	if tSettings.dock == "TOP" then -- TOP
		self:HorizontalBar(x, y - tSettings.thickness, w, tSettings.thickness, tSettings)
	elseif tSettings.dock == "BOTTOM" then -- BOTTOM
		self:HorizontalBar(x, y + h + 1, w, tSettings.thickness, tSettings)
	end
	if tSettings.dock == "LEFT" then -- LEFT
		self:VerticalBar(x - tSettings.thickness, y, tSettings.thickness, h, tSettings)
	elseif tSettings.dock == "RIGHT" then -- RIGHT
		self:VerticalBar(x + w + 1, y, tSettings.thickness, h, tSettings)
	end
end

function sVis:VerticalBar(x, y, w, h, tSettings)
	local perc = math.Clamp(tSettings.currentVal / tSettings.maxVal, 0, 1)
	local barWidth = math.max(h * perc, 0)

	local col = (tSettings.currentVal / tSettings.maxVal)
	local color = Color(
		(tSettings.minCol.r * (1 - col)) + (tSettings.maxCol.r * col),
		(tSettings.minCol.g * (1 - col)) + (tSettings.maxCol.g * col),
		(tSettings.minCol.b * (1 - col)) + (tSettings.maxCol.b * col),
		tSettings.minCol.a + tSettings.currentVal * ((tSettings.maxCol.a-tSettings.minCol.a)/tSettings.maxVal)
	)

	draw.RoundedBox(0, x, y, w, h, color_black)

	if tSettings.fill == "LEFT" then --TOP
		draw.RoundedBox(0, x, y, w, barWidth, color)
		return
	end

	if tSettings.fill == "MIDDLE" then --MIDDLE
		draw.RoundedBox(0, x, y + ((h - barWidth) / 2), w, barWidth, color)
		return
	end

	if tSettings.fill == "RIGHT" then -- BOTTOM
		draw.RoundedBox(0, x, y + (h - barWidth), w, barWidth, color)
		return
	end
end

function sVis:HorizontalBar(x, y, w, h, tSettings)
	local perc = math.Clamp(tSettings.currentVal / tSettings.maxVal, 0, 1)
	local barWidth = math.max(w * perc, 0)

	local col = (tSettings.currentVal / tSettings.maxVal)
	local color = Color(
		(tSettings.minCol.r * (1 - col)) + (tSettings.maxCol.r * col), 
		(tSettings.minCol.g * (1 - col)) + (tSettings.maxCol.g * col), 
		(tSettings.minCol.b * (1 - col)) + (tSettings.maxCol.b * col), 
		tSettings.minCol.a + tSettings.currentVal * ((tSettings.maxCol.a-tSettings.minCol.a)/tSettings.maxVal)
	)
    
	draw.RoundedBox(0, x, y, w, h, color_black)

	if tSettings.fill == "LEFT" then -- LEFT
		draw.RoundedBox(0, x, y, barWidth, h, color)
		return
	end

	if tSettings.fill == "MIDDLE" then -- MIDDLE
		draw.RoundedBox(0, x + ((w - barWidth) / 2), y, barWidth, h, color)
		return
	end

	if tSettings.fill == "RIGHT" then -- RIGHT
		draw.RoundedBox(0, x + (w - barWidth), y, barWidth, h, color)
		return
	end
end

function sVis:DrawBoxCorners(x, y, w, h, tSettings)
	tSettings = tSettings or {}
	tSettings.col1 = tSettings.col1 or Color(255, 0, 0)
	tSettings.col2 = tSettings.col2 or Color(0, 0, 0)
	tSettings.length = tSettings.length or 5

	surface.SetDrawColor(tSettings.col2)
	surface.DrawOutlinedRect(x, y, w, h)

    local botX, botY = x + (w / 2), y + h
    local topX, topY = x + (w / 2), y
	
    local sx = (topX - (w / 2))
    local sy = topY
	local scale = math.Clamp(sx + tSettings.length, x, x+w)
	local scale2 = math.Clamp(sy + tSettings.length, y, y+h)

    surface.SetDrawColor(tSettings.col1)
    surface.DrawLine(sx, sy, scale, sy)
    surface.DrawLine(sx, sy, sx, scale2)

	local sx = (topX + (w / 2))
	local sy = topY
	local scale = math.Clamp(sx - tSettings.length, x, x+w)
	local scale2 = math.Clamp(sy + tSettings.length, y, y+h)
	
	surface.SetDrawColor(tSettings.col1)
	surface.DrawLine(sx, sy, scale, sy)
	surface.DrawLine(sx, sy, sx, scale2)

	local sx = (botX - (w / 2))
	local sy = botY
	local scale = math.Clamp(sx + tSettings.length, x, x+w)
	local scale2 = math.Clamp(sy - tSettings.length, y, y+h)

	surface.SetDrawColor(tSettings.col1)
	surface.DrawLine(sx, sy, scale, sy)
	surface.DrawLine(sx, sy, sx, scale2)	

	local sx = (botX + ( w / 2 ))
	local sy = botY
	local scale = math.Clamp(sx - tSettings.length, x, x+w)
	local scale2 = math.Clamp(sy - tSettings.length, y, y+h)

	surface.SetDrawColor(tSettings.col1)
	surface.DrawLine(sx, sy, scale, sy)
	surface.DrawLine(sx, sy, sx, scale2)
end

function sVis:Draw2DBoxes(x, y, w, h, tSettings)
	tSettings = tSettings or {}
	tSettings.style = tSettings.style or "FULL"
	tSettings.col1 = tSettings.col1 or Color(255,255,255)
	tSettings.col2 = tSettings.col2 or color_black

	if tSettings.style == "FULL" then
		local len = math.Remap(tSettings.length, 1, 200, 1, 5)
		for i = x - len, x + len, 1 do
			for j = y - len, y + len, 1 do
				surface.SetDrawColor(tSettings.col2)
				surface.DrawOutlinedRect(i,j,w,h)
			end
		end
		surface.SetDrawColor(tSettings.col1)
		surface.DrawOutlinedRect(x,y,w,h)
		return
	end
	if tSettings.style == "CORNERS" then
		self:DrawBoxCorners(x, y, w, h, tSettings)
		return
	end
end

function sVis:DrawD3D9Boxes(ent, tSettings)
	tSettings = tSettings or {}
	tSettings.col1 = tSettings.col1 or Color(255,255,255)

	local top, bot = ent:GetShootPos(), ent:GetPos()
	top.z = top.z + 8

	top = top:ToScreen()
	bot = bot:ToScreen()

	local height = math.abs(top.y - bot.y)
	
	local tl, tr = Vector( top.x - height / 4, top.y, 0), Vector( top.x + height / 4, top.y, 0)
	
	local bl, br = Vector(bot.x - height / 4, bot.y, 0), Vector(bot.x + height / 4, bot.y, 0)

	surface.SetDrawColor(tSettings.col1)
	surface.DrawLine(tl.x, tl.y, tr.x, tr.y)
	surface.DrawLine(bl.x, bl.y, br.x, br.y)
	
	surface.DrawLine(tl.x, tl.y, bl.x, bl.y)
	surface.DrawLine(tr.x, tr.y, br.x, br.y)
end

function sVis:OffScreenIndicators(ent, tSettings)
	tSettings = tSettings or {}
	tSettings.dist = tSettings.dist or 50
	tSettings.scale = tSettings.scale or 300
	tSettings.col1 = tSettings.col1 or Color(0, 0, 0)
	tSettings.col2 = tSettings.col2 or Color(255, 255, 255)
	tSettings.shape = tSettings.shape or "CIRCLE"
 
    local LocalAng = (LPLY:EyeAngles().y - Vector(LPLY:GetPos() - ent:GetPos()):Angle().y + 180 ) - 90
 
	local X1 = ScrW() / 2 + math.cos( math.rad( LocalAng ) ) * (250 + tSettings.scale / 5 + tSettings.dist )
	local Y1 = ScrH() / 2 + math.sin( math.rad( LocalAng ) ) * (250 + tSettings.scale / 5 + tSettings.dist )
 
    local X2 = ScrW() / 2 + math.cos( math.rad( LocalAng - 4 - tSettings.scale / 50 + tSettings.dist / 200 ) ) * ( 250 + tSettings.dist )
    local Y2 = ScrH() / 2 + math.sin( math.rad( LocalAng - 4 - tSettings.scale / 50 + tSettings.dist / 200 ) ) * ( 250 + tSettings.dist )
 
    local X3 = ScrW() / 2 + math.cos( math.rad( LocalAng + 4 + tSettings.scale / 50 - tSettings.dist / 200 ) ) * ( 250 + tSettings.dist )
    local Y3 = ScrH() / 2 + math.sin( math.rad( LocalAng + 4 + tSettings.scale / 50 - tSettings.dist / 200 ) ) * ( 250 + tSettings.dist )
 

	surface.SetDrawColor(tSettings.col1)

	if tSettings.shape == "CIRCLE" then
		surface.DrawCircle(X1, Y1, tSettings.scale/2)
		return
	end
	if tSettings.shape == "LINE" then
		local oTS = ent:GetPos():ToScreen()
		surface.DrawLine(X1, Y1, oTS.x, oTS.y )
		return
	end
	if tSettings.shape == "TRIANGLE" then
		surface.SetDrawColor(tSettings.col2)

		surface.DrawLine(X2, Y2, X1, Y1)
		surface.DrawLine(X3, Y3, X1, Y1)

		surface.SetDrawColor(tSettings.col1)

		surface.DrawLine((X1 + X2)/2, (Y1 + Y2)/2, X1, Y1)
		surface.DrawLine((X1 + X3)/2, (Y1 + Y3)/2, X1, Y1)
		return
	end
end

local pStep = 0
timer.Create("StepScroll", 0.3, 0, function()
    pStep = pStep + 1
end)

function sVis:CrossedHair() -- TODO: IMPROVE ME
    local wep = LPLY:GetActiveWeapon()
    if not wep:IsValid() then return end
    
    local iWidth, iHeight = ScrW(), ScrH()
    local flAspectRatio = iWidth / iHeight

    local x = iWidth / 2.0
    local y = iHeight / 2.0
    
    local cone = NS.wepcone[wep:GetClass()] or Vector()
    
    local a = math.asin(cone[1])
    local deg = math.deg(a)

    local radSpread = (deg * math.pi / 180)
    local radGameFOV = render.GetViewSetup().fov_unscaled * math.pi / 180
    local radViewFOV = 2 * math.atan( flAspectRatio * 1.5 * math.tan(radGameFOV / 2) )

    local flRadius = (math.tan(radSpread) / math.tan(radViewFOV * 0.5)) * iWidth
    local length = math.floor(flRadius + 10)

	render.OverrideBlend(true, 3, 1, 1) --BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_SUBTRACT
	surface.SetDrawColor(Color(255, 255, 255))
    surface.DrawLine( x - length, y, x - flRadius, y )
    surface.DrawLine( x + length, y, x + flRadius, y )
    surface.DrawLine( x, y - length, x, y - flRadius )
    surface.DrawLine( x, y + length, x, y + flRadius )
	render.OverrideBlend(false)

	local angle = sMove.Data.postCMoveViewAngle + LPLY:GetViewPunchAngles()

    local tr = util.QuickTrace(LPLY:GetShootPos(), angle:Forward() * 3000, LPLY)
	
    local hpos = tr.HitPos:ToScreen()

	render.OverrideBlend(true, 3, 1, 1)
    surface.SetDrawColor(Color(255, 255, 255))
    surface.DrawRect(hpos.x-1, hpos.y-1, 3, 3)
	render.OverrideBlend(false)

	local dist = (tr.HitPos - LPLY:GetShootPos())
	dist:Normalize()
	local deg = math.deg(math.acos(LPLY:EyeAngles():Forward():Dot(dist))) * 45
	
    local bounceColor = HSVToColor(deg, 1, 1)
	
    surface.SetDrawColor(bounceColor)
    surface.DrawLine(hpos.x, hpos.y, x, y)
    --debugoverlay.Cross(tr.HitPos, 1, 10, bounceColor, false)
end

function sVis:ESPText(text, x, y, W, H, tSettings)
	tSettings = tSettings or {}
	tSettings.col1 = tSettings.col1 or Color(255, 255, 255)
	tSettings.xalign = tSettings.xalign or "MIDDLE"
	tSettings.yalign = tSettings.yalign or "TOP"
	tSettings.font = tSettings.font or "font"
	tSettings.scroll = tSettings.scroll or "NONE"	

	local width = math.Clamp(math.floor(W), self.m_tSettings._2D.mintextlen, self.m_tSettings._2D.maxtextlen)
	text = sUtil:shrinkText(text, tSettings.font, width)

	surface.SetFont( tSettings.font )

	local Len = #text
	local Step = pStep % (Len + 2)

	if tSettings.scroll == "RIGHT" then
		text = text .. (" ")
		text = text:sub(1 - Step) .. text:sub(1, 1 - Step)
	elseif tSettings.scroll == "LEFT" then
		text = text .. (" ")
		text = text:sub(Step + 1) .. text:sub(1, Step)
	end

	local w, h = surface.GetTextSize( text )

	if tSettings.xalign == "MIDDLE" then
		x = x - w / 2
	elseif tSettings.xalign == "RIGHT" then
		x = x - w
	end

	if tSettings.yalign == "MIDDLE" then
		y = y - h / 2
	elseif tSettings.yalign == "BOTTOM" then
		y = y - h
	end

	surface.SetTextPos( math.ceil( x ), math.ceil( y ) )
	surface.SetTextColor(tSettings.col1.r, tSettings.col1.g, tSettings.col1.b, tSettings.col1.a)
	surface.DrawText( text )
end

function sVis:ESPTextOutlined(text, x, y, w, h, tSettings)
	tSettings = tSettings or {}
	tSettings.col1 = tSettings.col1 or Color(255, 255, 255, 255)
	tSettings.col2 = tSettings.col2 or Color(0, 0, 0, 255)
	tSettings.xalign = tSettings.xalign or "MIDDLE"
	tSettings.yalign = tSettings.yalign or "TOP"
	tSettings.outlinewidth = tSettings.outlinewidth or 1
	tSettings.font = tSettings.font or "font"

	local steps = ( tSettings.outlinewidth * 2 ) / 3
	if ( steps < 1 ) then steps = 1 end

	for _x = -tSettings.outlinewidth, tSettings.outlinewidth, steps do
		for _y = -tSettings.outlinewidth, tSettings.outlinewidth, steps do
			self:ESPText(text, x + _x, y + _y, w, h, {		
				col1 = tSettings.col2, 
				xalign = tSettings.xalign, 
				yalign = tSettings.yalign, 
				font = tSettings.font,
				scroll = tSettings.scroll,
			})
		end
	end

	self:ESPText(text, x, y, w, h, tSettings)
end

function sVis:Draw2DText(text, x, y, w, h, tSettings)
	tSettings = tSettings or {}
	tSettings.col1 = tSettings.col1 or Color(255, 255, 255, 255)
	tSettings.col2 = tSettings.col2 or Color(0, 0, 0, 255)
	tSettings.dockX = tSettings.dockX or "MIDDLE" -- LEFT, RIGHT, MIDDLE
	tSettings.dockY = tSettings.dockY or "MIDDLE" -- TOP, BOTTOM, MIDDLE
	tSettings.font = tSettings.font or "font"
	tSettings.outlinewidth = tSettings.outlinewidth or 1

	local text_x, text_y = x, y
	local xalign = "MIDDLE"
	local yalign = "TOP"

	if tSettings.dockX == "LEFT" then
		xalign = "RIGHT"
		text_x = text_x
	elseif tSettings.dockX == "RIGHT" then
		xalign = "LEFT"
		text_x = text_x + w
	elseif tSettings.dockX == "MIDDLE" then
		xalign = "MIDDLE"
		text_x = text_x + (w / 2)
	end

	if tSettings.dockY == "BOTTOM" then
		yalign = "TOP"
		text_y = text_y + h
	elseif tSettings.dockY == "TOP" then
		yalign = "BOTTOM"
		text_y = text_y
	elseif tSettings.dockY == "MIDDLE" then	
		yalign = "MIDDLE"
		text_y = text_y + (h / 2)
	end

	self:ESPTextOutlined(text, text_x, text_y, w, h, {
		xalign = xalign, 
		yalign = yalign,
		col1 = tSettings.col1, 
		col2 = tSettings.col2, 
		outlinewidth = tSettings.outlinewidth,
		font = tSettings.font,
		scroll = tSettings.scroll,
	})
end

function sVis:OnScreen(ply)
    local pos = ply:GetPos()
    local screenPos = pos:ToScreen()
    return screenPos.x > 0 and screenPos.x < ScrW() and screenPos.y > 0 and screenPos.y < ScrH()
end

local CopyMat		= Material( "pp/copy" )
local OutlineMat	= CreateMaterial( "OutlineMat", "UnlitGeneric", {
	[ "$ignorez" ] = 1,
	[ "$alphatest" ] = 1
})

local StoreTexture	= render.GetScreenEffectTexture( 0 )
local DrawTexture	= render.GetScreenEffectTexture( 1 )

local ENTS	= 1
local COLOR	= 2
local THICKNESS = 3
function sVis:draw_outlines(List)
	local scene = render.GetRenderTarget()
	render.CopyRenderTargetToTexture( StoreTexture )

	local w = ScrW()
	local h = ScrH()

	render.Clear( 0, 0, 0, 0, true, true )

	render.SetStencilEnable( true )
		cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )

		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )

		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_REPLACE )
		render.SetStencilPassOperation( STENCIL_REPLACE )

		cam.Start3D()
			for i = 1, #List do
				local v = List[ i ]
				local ents = v[ ENTS ]
				render.SetStencilReferenceValue( i )
				for j = 1, #ents do
					local ent = ents[ j ]
					if not ent:IsValid() or ent:IsDormant() then continue end
					ent:DrawModel()
				end
			end
		cam.End3D()

		render.SetStencilCompareFunction( STENCIL_EQUAL )

		cam.Start2D()
			for i = 1, #List do
				render.SetStencilReferenceValue( i )
				surface.SetDrawColor( List[ i ][ COLOR ] )
				surface.DrawRect( 0, 0, w, h )
			end
		cam.End2D()

		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
	render.SetStencilEnable( false )

	render.CopyRenderTargetToTexture( DrawTexture )

	render.SetRenderTarget( scene )
	CopyMat:SetTexture( "$basetexture", StoreTexture )
	render.SetMaterial( CopyMat )
	render.DrawScreenQuad()

	render.SetStencilEnable( true )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilCompareFunction( STENCIL_EQUAL )

		OutlineMat:SetTexture( "$basetexture", DrawTexture )
		render.SetMaterial( OutlineMat )
		for i = 1, #List do
			local SIZE = List[ i ][ THICKNESS ]
			for x = -SIZE,SIZE,1 do
				for y = -SIZE,SIZE,1 do
					render.DrawScreenQuadEx( x, y, w ,h )
				end
			end
		end
	render.SetStencilEnable( false )
end

function sVis:DrawOutlines(List, tSettings)
	tSettings = tSettings or {}
	tSettings.col = tSettings.col or Color(255, 0, 0)
	tSettings.thickness = tSettings.thickness or 1

	
	local tab = {}

	local ents = {
		[ENTS] = {},
		[COLOR] = tSettings.col,
		[THICKNESS] = tSettings.thickness
	}

	tab[#tab + 1] = ents

	for i, ent in next, List do
		if ent:IsValid() and not ent:IsDormant() then
			if ent:IsPlayer() and not ent:Alive() then continue end
			table.insert(ents[ENTS], ent)
		end
	end

	self:draw_outlines(tab)
end

s0lame.RegisterHack("sVis", "0.1", sVis, sVis.m_tSettings)