RPStuff = RPStuff or {}

RPStuff.m_tSettings = {
    Toggle = false,
    grabber = false,
	user = false,
	antiarrest = false,
	keypadlogger = false,
}

RPStuff.g_flRange = 95 

RPStuff.keypads = {}
RPStuff.validkeypads = {
    Keypad = true,
    Keypad_Wire = true,
    keypad = true,
    keypad_wire = true
}

local priority = {
	["^(.+)_printer"] = 1, -- Entity:GetNWInt("PrintA")
	["spawned_shipment"] = 2,
	["spawned_weapon"] = 3,
	["spawned_money"] = 4, --Entity:Getamount()
	["spawned_ammo"] = 5,
}

local pocketEnts = {
	"spawned_shipment",
	"spawned_weapon"
}

local useEnts = {
	"spawned_money",
	"spawned_ammo"
}

local printerEnts = {
	"^(.+)_printer"
}

function RPStuff:OBBCorners(ent)
    local min, max = ent:OBBMins() * 0.75, ent:OBBMaxs() * 0.75

    local fbl = Vector(min)
    local fbr = Vector(min.x, min.y, max.z)
    local ftl = Vector(max.x, min.y, min.z)
    local ftr = Vector(max.x, min.y, max.z)

    local btr = Vector(max)
    local bbl = Vector(min.x, max.y, min.z)
    local bbr = Vector(min.x, max.y, max.z)
    local btl = Vector(max.x, max.y, min.z)

    fbl = ent:LocalToWorld(fbl)
    fbr = ent:LocalToWorld(fbr)
    ftl = ent:LocalToWorld(ftl)
    ftr = ent:LocalToWorld(ftr)
    btr = ent:LocalToWorld(btr)
    bbl = ent:LocalToWorld(bbl)
    bbr = ent:LocalToWorld(bbr)
    btl = ent:LocalToWorld(btl)

    local tab = {
        f_bl = fbl,
        f_br = fbr,
        f_tl = ftl,
        f_tr = ftr,
        b_tr = btr,
        b_bl = bbl,
        b_br = bbr,
        b_tl = btl
    }
    
    return tab
end

function RPStuff:OBBMultiPoint(ent)
    local center = ent:LocalToWorld(ent:OBBCenter())
    if sAim:IsThingVisible(ent, center) then return center end
    local OBBcorners = self:OBBCorners(ent)
    for k, v in next, OBBcorners do
    	--debugoverlay.Box(v, Vector(-1, -1, -1), Vector(1, 1, 1), 1, Color( 255, 0, 0 ) )
        if sAim:IsThingVisible(ent, v) then 
            return v
        end
    end
    return false
end

local PreviousWeapon = NULL

function RPStuff:SwapToWeapon(class)
	local hWep, hActiveWep = LPLY:GetWeapon(class), LPLY:GetActiveWeapon()
	if hWep:IsValid() and hWep:IsWeapon() then
		if hActiveWep == hWep then
			return true, hWep
		else
			PreviousWeapon = hActiveWep:GetClass() ~= class and hActiveWep or NULL
			input.SelectWeapon(hWep)
			return false
		end
	end
	return false
end

function RPStuff:PopulateEntTable(range)
	range = range or 0
	local allEnts, closest = sUtil:getEnt(range, nil)
	local pocketableEnts, useableEnts, printers = {}, {}, {}

	for _, ent in next, allEnts do
		for k, v in next, pocketEnts do
			if not string.find(ent:GetClass(), v) then continue end
			pocketableEnts[ent] = priority[v]
		end

		for k, v in next, useEnts do
			if not string.find(ent:GetClass(), v) then continue end
			useableEnts[ent] = priority[v]
		end
		
		for k, v in next, printerEnts do
			if not string.find(ent:GetClass(), v) then continue end
			printers[ent] = priority[v]
		end
	end

	local validEnts = {}
	
	for k, v in next, useableEnts do
		--print("use: ", k, v)
		table.insert(validEnts, k)
	end
	
	for k, v in next, pocketableEnts do
		--print("pocket: ", k, v)
		table.insert(validEnts, k)
	end
	
	for k, v in next, printers do
		--print("printers: ", k, v)
		table.insert(validEnts, k)
	end
	
	for k, v in next, validEnts do
		--print(#validEnts)
		if not self:OBBMultiPoint(v) then continue end	
	end

	table.sort(validEnts, function(a, b)
		local prioritya, priorityb
		local apos, bpos = a:LocalToWorld(a:OBBCenter()), b:LocalToWorld(b:OBBCenter())
		local aval, bval = string.find(a:GetClass(), "printer") and a:GetNWInt("PrintA") or 0, string.find(a:GetClass(), "printer") and b:GetNWInt("PrintA") or 0
		
		--debugoverlay.Box(apos, Vector(-1, -1, -1), Vector(1, 1, 1), 1, Color( 255, 0, 0 ) )
		--debugoverlay.Box(bpos, Vector(-1, -1, -1), Vector(1, 1, 1), 1, Color( 0, 0, 255 ) )
		
		for k, v in next, priority do
            --print(k, v)
			if prioritya and priorityb then
				break
			end

			if not prioritya then
				if string.find(a:GetClass(), k) then
					prioritya = v
				end
			end
			if not priorityb then
				if string.find(b:GetClass(), k) then
					priorityb = v
				end
			end
		end
		
		if prioritya < priorityb and aval == 0 and bval == 0 then
			return prioritya > priorityb
		elseif prioritya == priorityb and aval == 0 and bval == 0 then
			return (apos-LPLY:GetShootPos()):LengthSqr() < (bpos-LPLY:GetShootPos()):LengthSqr()
		elseif aval > 0 and bval > 0 and aval < bval then
			return aval > bval
		end
	end)
	
	if #validEnts > 0 then
		return validEnts, pocketableEnts, useableEnts, printers
	end
	return {}
end

RPStuff.Pocketing = false
function RPStuff:PerformPocketing(cmd, validEnts, pocketableEnts, printers)
	if #validEnts > 0 then
		local bOk = self:SwapToWeapon("pocket")
		if not bOk then return end

		for i, v in ipairs(validEnts) do
			if pocketableEnts[v] or printers[v] then
				if cmd:CommandNumber() ~= 0 and cmd:TickCount() % 2 == 0 then 
					--print("pocketing")
					RPStuff.Pocketing = true
					local vpos = self:OBBMultiPoint(v)
					if not vpos then continue end

					local bOkAim = sAim:PerformAim(cmd, vpos)
					if not bOkAim then continue end
					cmd:RemoveKey(IN_ATTACK)
					cmd:AddKey(IN_ATTACK)
				end
			end
		end
	elseif PreviousWeapon ~= NULL then
		RunConsoleCommand("stopsound")
		input.SelectWeapon(PreviousWeapon)
	end
end

function RPStuff:PerformUsing(cmd, validEnts, useableEnts, printers)
	if #validEnts > 0 then
		for i, v in ipairs(validEnts) do
			if RPStuff.Pocketing == false then
				if string.find(v:GetClass(), "printer") and v:GetNWInt("PrintA") == 0 then continue end

				if useableEnts[v] or printers[v] then
					if cmd:CommandNumber() ~= 0 and cmd:TickCount() % 2 == 0 then 
						--print("using")
						local vpos = self:OBBMultiPoint(v)
						if not vpos then continue end
						
						local bOkAim = sAim:PerformAim(cmd, vpos)
						if not bOkAim then continue end
						cmd:RemoveKey(IN_USE)
						cmd:AddKey(IN_USE)
					end
				end
			end
		end
	end	
end

function RPStuff:logKeypads()
    for _, v in next, player.GetAll() do
        if not v:Alive() or v:IsBot() or v:IsDormant() then continue end
        local dir = v:GetAimVector()
        local trace = {
            start = v:GetShootPos(),
            endpos = v:GetShootPos() + dir * 1000,
            filter = {v, LPLY}
        }
        
        local tr = util.TraceLine(trace)
        local keypad = tr.Entity

        if not keypad:IsValid() then continue end
        if not string.find(keypad:GetClass(), "Keypad") then continue end
        
        debugoverlay.Box(tr.HitPos, Vector(-0.25, -0.25, -0.25), Vector(0.25, 0.25, 0.25), 0.5, Color( 0, 255, 0 ) )
        
        if self.validkeypads[keypad:GetClass()] then
            local entid = keypad:EntIndex()
            local text = keypad:GetText()

            if not self.keypads[entid] then self.keypads[entid] = {keypad} end
            if not self.keypads[entid][3] then self.keypads[entid][3] = "" end
            if not self.keypads[entid][4] then self.keypads[entid][4] = {} end

            if keypad:GetStatus() == 2 or #self.keypads[entid][3] > #text then
                self.keypads[entid][3] = ""
            end
            
            if keypad:GetStatus() == 1 and self.keypads[entid][3] ~= "" then
                self.keypads[entid][4][self.keypads[entid][3]] = true
                self.keypads[entid][3] = ""
            end

            if not keypad:GetSecure() then
                self.keypads[entid][3] = text
                continue
            end

            local keys = {}
            for i = 1, 9 do
                local column = (i - 1) % 3
                local row = math.floor((i - 1) / 3)

                local chords = {
                    x = 0.075 + (0.3 * column),
                    y = 0.175 + 0.25 + 0.05 + ((0.5 / 3) * row),
                    w = 0.25,
                    h = 0.13,
                }
                keys[i] = chords
            end

            local scale = keypad.Scale
            local pos, ang = keypad:CalculateRenderPos(), keypad:CalculateRenderAng()
            local normal = keypad:GetForward()
            local intersection = util.IntersectRayWithPlane(trace.start, dir, pos, normal)

            if not intersection then
                continue
            end

            local diff = pos - intersection
            local x = diff:Dot(-ang:Forward()) / scale
            local y = diff:Dot(-ang:Right()) / scale
            local w, h = keypad.Width2D, keypad.Height2D
            for i, element in ipairs(keys) do
                local element_x = w * element.x
                local element_y = h * element.y
                local element_w = w * element.w
                local element_h = h * element.h
                if element_x < x and element_x + element_w > x and
                    element_y < y and element_y + element_h > y
                then
                    self.keypads[entid][2] = i
                    break
                end
            end
            
            if not self.keypads[entid][5] then self.keypads[entid][5] = text end
            if #self.keypads[entid][5] < #text then
                self.keypads[entid][3] = self.keypads[entid][3] .. tostring(self.keypads[entid][2])
            end
            
            self.keypads[entid][5] = text
        end
    end
end

function RPStuff:keypadDraw()
    surface.SetTextColor(255, 255, 255)
    surface.SetDrawColor(math.sin(CurTime() * 10) * 255, 0, 255)
    surface.SetFont("Default")
    for entid, v in pairs(self.keypads) do
        if not v[1]:IsValid() then self.keypads[entid] = nil continue end
        local pos3d = v[1]:GetPos() + Vector(0, 0, 5)
        if pos3d:Distance(LPLY:GetPos()) >= 2000 then continue end
        local pos = pos3d:ToScreen()
        surface.DrawRect(pos.x - 3, pos.y - 3, 6, 6)

        local execs = 0
        for i, _ in pairs(v[4]) do
            local w, h = surface.GetTextSize(i)
            surface.SetTextPos(pos.x - w / 2, pos.y - h - (h - 4) * execs - 2)
            surface.DrawText(i)
            execs = execs + 1
        end
    end
end
	
function RPStuff:AntiArrest(cmd)
	local flArrestRange = 100
	local allPly, closest = sUtil:getEnt(flArrestRange, "player")
	local lPos = LPLY:GetPos()
	for k, v in ipairs(allPly) do
		local wep = v:GetActiveWeapon()
		if not wep:IsValid() or wep:GetClass() ~= "arrest_stick" then continue end
		
		local vPos = sUtil:uninterpolate(v, v:GetPos())
		local dist = vPos:Distance(lPos)
		
		if dist > flArrestRange * 3 then continue end
		
		local tHitPos = v:GetEyeTrace().HitPos
		
		if dist < flArrestRange and lPos:Distance(tHitPos) < flArrestRange + 10 then
			LPLY:ConCommand("kill")
		end
		
		local fwdPos = vPos + (lPos - vPos):Angle():Forward() * flArrestRange * 2
		debugoverlay.Line(vPos, fwdPos, 0.1, Color(0,255,0), true)
		debugoverlay.Text(v:GetPos(), dist, 0.5, false)
		debugoverlay.Box(fwdPos, Vector(-5,-5,-5), Vector(5,5,5), 0.1, Color(255,0,255), false)
		sMove:MoveToPos(cmd, fwdPos)
	end
end

function RPStuff:Slammer(cmd)
	local weapon = LPLY:GetActiveWeapon()
	if not weapon:IsValid() or not weapon:GetClass() ~= "weapon_slam" then return end
	local exploders = {}
	local lpos = LPLY:GetPos()

	for i = 1, #Hooks.allEnts do
		local v = Hooks.allEnts[i]
		if not v:IsValid() or v:GetClass() ~= "npc_satchel" or v:IsDormant() then continue end
		local id = v:EntIndex()
		local pos = sUtil:uninterpolate(v, v:GetPos())
		debugoverlay.Box(pos, Vector(-0.5,-0.5,-0.5), Vector(0.5,0.5,0.5), 0.05, Color(255,0,0))
		exploders[id] = pos
	end

	for id1, ex in next, exploders do
		local ldist = (ex - lpos):Length()
		if ldist <= 250 then debugoverlay.Sphere(ex, 200, 0.05, Color( 255, 0, 0 ), false) continue end
		for id2, ply in next, player.GetAll() do
			if not ply:IsValid() or not ply:Alive() or ply == LPLY then continue end
			local plypos = sUtil:uninterpolate(ply, ply:GetPos())
			local dist = (ex - plypos):Length()
			if dist < 5000 then
				local predpos = plypos + MPredict:VelocityAfterGravity(ply, ply:GetAbsVelocity(), 13)
				local dist2 = (ex - predpos):Length()
				debugoverlay.Box(predpos, Vector(-5,-5,-5), Vector(5, 5, 5), 0.05, Color( 255, 0, 255))
				if dist2 < 200 then
					debugoverlay.Sphere(predpos, 100, 0.05, Color( 0, 255, 0 ), false)
					debugoverlay.Sphere(ex, 100, 0.05, Color( 255, 0, 0 ), false)
					if cmd:TickCount() % 2 == 0 then 
						cmd:AddKey(IN_ATTACK2)	
					end
				end
			end
		end
	end
end

function RPStuff:Init(cmd)
	self:AntiArrest(cmd)

	self:Slammer(cmd)

	local validEnts, pocketableEnts, useableEnts, printers = self:PopulateEntTable(RPStuff.g_flRange)
	
	if input.IsButtonDown(input.GetKeyCode("alt")) then
		self:PerformPocketing(cmd, validEnts, pocketableEnts, printers)
	else
		self.Pocketing = false
	end
	
	if input.IsButtonDown(input.GetKeyCode("e")) then
		self:PerformUsing(cmd, validEnts, useableEnts, printers)
	end
end



s0lame.RegisterHack("RPStuff", "0.1", RPStuff, RPStuff.m_tSettings)