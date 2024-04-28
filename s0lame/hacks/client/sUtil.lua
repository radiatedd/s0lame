sUtil = sUtil or {}

sUtil.cRealFrameTime = 0
sUtil.LastQuery = 0

function sUtil:IntersectBoxWithBox(boxAPos, boxAMins, boxAMaxs, boxBPos, boxBMins, boxBMaxs)
    local boxAExtents = boxAMaxs - boxAMins

    local boxBExtents = boxBMaxs - boxBMins

    boxAExtents = boxAExtents / 2
    boxBExtents = boxBExtents / 2

    if math.abs(boxAPos.x - boxBPos.x) > boxAExtents.x + boxBExtents.x then
        return false
    end
    if math.abs(boxAPos.y - boxBPos.y) > boxAExtents.y + boxBExtents.y then
        return false
    end
    if math.abs(boxAPos.z - boxBPos.z) > boxAExtents.z + boxBExtents.z then
        return false
    end

    debugoverlay.Box(boxAPos, boxAMins, boxAMaxs, 4, Color( 255, 0, 0, 25))
    debugoverlay.Box(boxBPos, boxBMins, boxBMaxs, 4, Color( 0, 0, 255, 25))

    return true
end

function sUtil:intersectRayWithBox(boxMins, boxMaxs, rayStart, rayDirection, rayLength)
    local tmin = 0
    local tmax = rayLength
    local t1 = (boxMins.x - rayStart.x) / rayDirection.x
    local t2 = (boxMaxs.x - rayStart.x) / rayDirection.x
    if t1 > t2 then
        t1, t2 = t2, t1
    end
    if t1 > tmin then
        tmin = t1
    end
    if t2 < tmax then
        tmax = t2
    end
    local t3 = (boxMins.y - rayStart.y) / rayDirection.y
    local t4 = (boxMaxs.y - rayStart.y) / rayDirection.y
    if t3 > t4 then
        t3, t4 = t4, t3
    end
    if t3 > tmin then
        tmin = t3
    end
    if t4 < tmax then
        tmax = t4
    end
    local t5 = (boxMins.z - rayStart.z) / rayDirection.z
    local t6 = (boxMaxs.z - rayStart.z) / rayDirection.z
    if t5 > t6 then
        t5, t6 = t6, t5
    end
    if t5 > tmin then
        tmin = t5
    end
    if t6 < tmax then
        tmax = t6
    end
    if tmin > tmax then
        return nil
    end
    return rayStart + rayDirection * tmin
end

function sUtil:ClampVector(vec, min, max)
    vec.x = math.Clamp(vec.x, min, max)
    vec.y = math.Clamp(vec.y, min, max)
    vec.z = math.Clamp(vec.z, min, max)
    return vec
end

function sUtil:uninterpolate(ent, pos)
	if not ent.GetNetworkOrigin then return pos end
	
    pos = ent:GetNetworkOrigin() + (pos-ent:GetPos())
    return pos
end

local cl_updaterate = GetConVar("cl_updaterate"):GetInt()
local sv_minupdaterate = GetConVar("sv_minupdaterate")
local sv_maxupdaterate = GetConVar("sv_maxupdaterate")
local cl_interp_ratio = GetConVar("cl_interp_ratio")
local cl_interp = GetConVar("cl_interp")
local sv_client_min_interp_ratio = GetConVar("sv_client_min_interp_ratio")
local sv_client_max_interp_ratio = GetConVar("sv_client_max_interp_ratio")
local cl_interpolate = GetConVar("cl_interpolate")

function sUtil:GetLerpTime()
    if not cl_interpolate:GetBool() then
        return 0
    end

    if sv_minupdaterate and sv_maxupdaterate then
        cl_updaterate = sv_maxupdaterate:GetInt()
    end

    local ratio = cl_interp_ratio:GetFloat()
    if ratio == 0 then
        ratio = 1
    end

    local lerp = cl_interp:GetFloat()
    if sv_client_max_interp_ratio and sv_client_max_interp_ratio and sv_client_min_interp_ratio:GetFloat() ~= 1 then
        ratio = math.Clamp(ratio, sv_client_min_interp_ratio:GetFloat(), sv_client_max_interp_ratio:GetFloat())
    end

    return math.max(lerp, ratio / cl_updaterate)
end

function sUtil:VectorTransform(vecIn, matrixIn, vecOut)
    if not matrixIn then return vecIn end

    local vecRet = Vector()

    local one = Vector(matrixIn:GetField(1, 1), matrixIn:GetField(1, 2), matrixIn:GetField(1, 3))
    local two = Vector(matrixIn:GetField(2, 1), matrixIn:GetField(2, 2), matrixIn:GetField(2, 3))
    local three = Vector(matrixIn:GetField(3, 1), matrixIn:GetField(3, 2), matrixIn:GetField(3, 3))

    vecRet.x = vecIn:Dot(one) + matrixIn:GetField(1, 4)
    vecRet.y = vecIn:Dot(two) + matrixIn:GetField(2, 4)
    vecRet.z = vecIn:Dot(three) + matrixIn:GetField(3, 4)

    if vecOut then
        vecOut:Set(vecRet)
        return
    end

    return vecRet
end

function sUtil:RemapClamped(val, A, B, C, D)
    if A == B then
        return val >= B and D or C
    end
    local cVal = (val - A) / (B - A)
    cVal = math.Clamp(cVal, 0.0, 1.0)
    return C + (D - C) * cVal
end

function sUtil:degFromCrosshair(pos)
    if not pos then return 360 end

    local aimDir = LPLY:EyeAngles():Forward()
    local dist = pos - LPLY:GetShootPos()
    dist:Normalize()

    local degreesfromcrosshair = math.deg(math.acos(aimDir:Dot(dist)))
    return math.abs(degreesfromcrosshair)
end

function sUtil:otherdegFromCrosshair(target, pos)
    if not pos then return 360 end
    local ang = target:EyeAngles()
    local aimDir = ang:Forward()
    local dist = pos - target:GetShootPos()
    dist:Normalize()

    local degreesfromcrosshair = math.deg(math.acos(aimDir:Dot(dist)))
    return math.abs(degreesfromcrosshair)
end

function sUtil:getEnt(rad, class, sort, bIgnoreZ)
	rad = rad or 1
    local pltbl = {}
    local lpos = LPLY:GetShootPos()
    
    if isstring(class) then
    	if class == "player" then
            local players = player.GetAll()
    		for i = 1, #players do
                local v = players[i]
    			if not v:IsValid() or not v:Alive() or v == LPLY then continue end
    			if not sVis:OnScreen(v) then continue end
				local vPos = v:GetShootPos()
                if not bIgnoreZ and not sAim:IsThingVisible(v, vPos, nil) then continue end
    			if (lpos - vPos):LengthSqr() > rad * rad then continue end

        		pltbl[#pltbl+1] = v
    		end
		else
            local entsByClass = ents.FindByClass(class)
    		for i = 1, #entsByClass do
                local v = entsByClass[i]
    			if not v:IsValid() or v == LPLY then continue end
        		pltbl[#pltbl+1] = v
    		end
		end
	else
        local entsInSphere = ents.FindInSphere(lpos, rad)
    	for i = 1, #entsInSphere do
            local v = entsInSphere[i]
    	    if not v:IsValid() or v == LPLY then continue end
    	    pltbl[#pltbl+1] = v
    	end
	end
	if sort == 1 then -- xhair
        table.sort(pltbl, function(a, b)
            local apos, bpos = a:LocalToWorld(a:OBBCenter()), b:LocalToWorld(b:OBBCenter())
            return self:degFromCrosshair(apos) > self:degFromCrosshair(bpos)
        end)
	elseif sort == 2 then -- aimvec
		local headpos = LPLY:GetBonePosition(LPLY:LookupBone("ValveBiped.Bip01_Head1"))
		table.sort(pltbl, function(a,b)
			return self:otherdegFromCrosshair(a, headpos) > self:otherdegFromCrosshair(b, headpos)
		end)
	else -- pos
		table.sort(pltbl, function(a, b)
			local apos, bpos = a:LocalToWorld(a:OBBCenter()), b:LocalToWorld(b:OBBCenter())
			return (apos-lpos):LengthSqr() > (bpos-lpos):LengthSqr()
		end)
	end
    
    return pltbl, pltbl[#pltbl]
end

function sUtil:NearestPointOnCircle(cCenter, cRadius, pVec)
    local pcDist = pVec - cCenter
    local pcLength = pcDist:Length()
    
    local pcDot = pcDist:Dot(pcDist)
    
    local cNormal = pcDist / pcLength
    local circleNormalLength = math.sqrt(pcDot - pcLength * pcLength)
    
    return cCenter + cNormal * (cRadius - circleNormalLength)
end

function sUtil:debugCone(entity, pos, direction, length, spread, time, color1, color2)
	local heading = direction:Angle()
	local forward, right, up = heading:Forward(), heading:Right(), heading:Up()
	local lastpos = nil
	local traceResult = {}
	local traceData = {}
	traceData.start = pos
	traceData.endpos = pos + forward * length
	traceData.filter = entity
	traceData.mask = MASK_SHOT
	traceData.output = traceResult

	util.TraceLine(traceData)

	local coneCenter = traceResult.HitPos

	for i = 0, 16 do
		local sin = math.sin(math.rad((360 / 16) * i)) * spread.x
		local cos = math.cos(math.rad((360 / 16) * i)) * spread.y
		local dir = forward + right * sin + up * cos
		traceData.endpos = traceData.start + dir * length

		util.TraceLine(traceData)

		if lastpos then
			debugoverlay.Line(traceResult.HitPos, lastpos, time, color1, true)
		end
        debugoverlay.Cross(coneCenter, 5, time, color2, true)

		lastpos = traceResult.HitPos
	end
end

function sUtil:ShouldMove(ent)
    if ent:IsTyping() then return false end
    if ent:GetMoveType() ~= MOVETYPE_WALK then return false end 
    if ent:InVehicle() then return false end
    if ent:WaterLevel() > 2 then return false end
    return true
end

function sUtil:InvertColor(col)
    return Color(255 - col.r, 255 - col.g, 255 - col.b, 255)
end

function sUtil:shrinkText(text, font, w)
	surface.SetFont(font)
	
	text = text or ""
	local newtext = text
	
	local tw, th = surface.GetTextSize(newtext)
	
	while tw + 5 > w do
		newtext = string.sub(newtext, 1, string.len(newtext) - 1)
		tw, th = surface.GetTextSize(newtext .. "...")
	end
	
	if newtext ~= text then
		newtext = newtext .. "..."
	end
	
	return newtext
end

-- UniformRandomStream
-- homonovus made this :)

do
    local META = {
        m_iv = {}, -- array, size == NTAB
    }
    META.__index = META
    META.__tostring = function(self)
        return "UniformRandomStream [" .. self.m_idum .. "]"
    end

    function UniformRandomStream(seed)
        local obj = setmetatable({}, META)
        obj:SetSeed(tonumber(seed) or 0)
        return obj
    end

    -- https://github.com/VSES/SourceEngine2007/blob/master/src_main/vstdlib/random.cpp#L16

    local IA = 16807
    local IM = 2147483647
    local IQ = 127773
    local IR = 2836
    local NTAB = 32
    local NDIV = (1 + (IM - 1) / NTAB)
    local MAX_RANDOM_RANGE = 0x7FFFFFFF

    -- fran1 -- return a random floating-point number on the interval [0,1])
    local AM = (1 / IM)
    local EPS = 1.2e-7
    local RNMX = (1 - EPS)

    function META:SetSeed(iSeed)
        self.m_idum = iSeed < 0 and iSeed or -iSeed
        self.m_iy = 0
    end

    local int = math.floor
    function META:GenerateRandomNumber()
        local j, k
        if (self.m_idum <= 0 or not self.m_iy) then
            if (-self.m_idum < 1) then
                self.m_idum = 1
            else
                self.m_idum = -self.m_idum
            end

            j = NTAB + 8
            while 1 do
                if j <= 0 then break end
                j = j - 1

                k = int(self.m_idum / IQ)
                self.m_idum = int(IA * (self.m_idum-k * IQ) - IR * k)
                if (self.m_idum < 0)  then
                    self.m_idum = int(self.m_idum + IM)
                end
                if (j < NTAB) then
                    self.m_iv[j] = int(self.m_idum)
                end
            end
            self.m_iy = self.m_iv[0]
        end

        k = int(self.m_idum / IQ)
        self.m_idum = int(IA * (self.m_idum-k * IQ) - IR * k)
        if (self.m_idum < 0) then
            self.m_idum = int(self.m_idum + IM)
        end
        j = int(self.m_iy / NDIV)

        -- We're seeing some strange memory corruption in the contents of s_pUniformStream. 
        -- Perhaps it's being caused by something writing past the end of this array? 
        -- Bounds-check in release to see if that's the case.
        if (j >= NTAB or j < 0) then
            ErrorNoHalt(string.format("CUniformRandomStream had an array overrun: tried to write to element %d of 0..31.", j))
            j = int(bit.band( j % NTAB, 0x7fffffff))
        end

        self.m_iy = int(self.m_iv[j])
        self.m_iv[j] = int(self.m_idum)

        return self.m_iy
    end

    function META:RandomFloat(flLow, flHigh)
        flLow = flLow or 0
        flHigh = flHigh or 1

        local fl = AM * self:GenerateRandomNumber()
        if fl > RNMX then
            fl = RNMX
        end

        return (fl * ( flHigh - flLow ) ) + flLow -- float in [low,high]
    end

    function META:RandomFloatExp(flMinVal, flMaxVal, flExponent)
        flMinVal = flMinVal or 0
        flMaxVal = flMaxVal or 1
        flExponent = flExponent or 1

        local fl = AM * self:GenerateRandomNumber()
        fl = math.min(fl, RNMX)

        if flExponent ~= 1 then
            fl = math.pow(fl, flExponent)
        end

        return (fl * ( flMaxVal - flMinVal ) ) + flMinVal
    end

    function META:RandomInt(iLow, iHigh)
        iLow = iLow or 0 iHigh = iHigh or 100
        iLow = math.floor(iLow) iHigh = math.floor(iHigh)
        local iMaxAcceptable, n
        local x = iHigh - iLow + 1

        if x <= 1 or MAX_RANDOM_RANGE < x-1 then
            return iLow
        end

        iMaxAcceptable = math.floor(MAX_RANDOM_RANGE - ((MAX_RANDOM_RANGE + 1) % x ))
        n = self:GenerateRandomNumber()
        while n > iMaxAcceptable do
            n = self:GenerateRandomNumber()
        end

        return iLow + (n % x)
    end
end

s0lame.RegisterHack("sUtil", "0.1", sUtil)