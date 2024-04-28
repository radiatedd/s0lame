sAim = sAim or {}

sAim.Data = {
    bulletTime = 0,
    activeTarget = NULL,
    activePos = Vector(0, 0, 0),
    shootPos = Vector(0, 0, 0),
    bShouldEngineViewAngles = true
}

sAim.m_tSettings = {
    Toggle = false,
    Priority = "proximity",
    FireKey = 81,
    bulletWait = 0,
    slowFire = false,
    silent = true,
    NoSpread = true,
    Range = 10000000,
    AutoFire = false,
    MultiPoint = true,
    MultiPointDist = 1,
    SimulateBolt = true,
    ForceSeed = false,
}

-- from leme : )
sAim.ShootChecks = {
    ["bobs"] = function(weapon) -- M9K
        if not weapon:IsValid() then return false end
    
        if not weapon:GetOwner():IsPlayer() then return false end
        if weapon:GetOwner():KeyDown(IN_SPEED) or weapon:GetOwner():KeyDown(IN_RELOAD) then return false end
        if weapon:GetNWBool("Reloading", false) then return false end
        if weapon:Clip1() < 1 then return false end
    
        return true
    end,
    
    ["cw"] = function(weapon)
        if not weapon:IsValid() then return false end
    
        if not weapon:canFireWeapon(1) or not weapon:canFireWeapon(2) or not weapon:canFireWeapon(3) then return false end
        if weapon:GetOwner():KeyDown(IN_USE) and CustomizableWeaponry.quickGrenade.canThrow(weapon) then return false end
        if weapon.dt.State == CW_AIMING and weapon.dt.M203Active and weapon.M203Chamber then return false end
        if weapon.dt.Safe then return false end
        if weapon:Clip1() == 0 then return false end
        if weapon.BurstAmount and weapon.BurstAmount > 0 then return false end
    
        return true
    end,
    
    ["fas2"] = function(weapon)
        if not weapon:IsValid() then return false end
    
        if weapon.FireMode == "safe" then return false end
        if weapon.BurstAmount > 0 and weapon.dt.Shots >= weapon.BurstAmount then return false end
        if weapon.ReloadState ~= 0 then return false end
        if weapon.dt.Status == FAS_STAT_CUSTOMIZE then return false end
        if weapon.Cooking or weapon.FuseTime then return false end
        if weapon:GetOwner():KeyDown(IN_USE) and weapon:CanThrowGrenade() then return false end
        if weapon.dt.Status == FAS_STAT_SPRINT or weapon.dt.Status == FAS_STAT_QUICKGRENADE then return false end
        if weapon:Clip1() <= 0 or weapon:GetOwner():WaterLevel() >= 3 then return false end
        if weapon.CockAfterShot and not weapon.Cocked then return false end
    
        return true
    end,
    
    ["tfa"] = function(weapon)
        if not weapon:IsValid() then return false end
    
        local Weapon2 = weapon:GetTable()
    
        local v = hook.Run("TFA_PreCanPrimaryAttack", weapon)
        if v ~= nil then return v end
    
        local stat = weapon:GetStatus()
        if stat == TFA.Enum.STATUS_RELOADING_WAIT or stat == TFA.Enum.STATUS_RELOADING then return false end
    
        if weapon:IsSafety() then return false end
        if weapon:GetSprintProgress() >= 0.1 and not weapon:GetStatL("AllowSprintAttack", false) then return false end
        if weapon:GetStatL("Primary.ClipSize") <= 0 and weapon:Ammo1() < weapon:GetStatL("Primary.AmmoConsumption") then return false end
        if weapon:GetPrimaryClipSize(true) > 0 and weapon:Clip1() < weapon:GetStatL("Primary.AmmoConsumption") then return false end
        if Weapon2.GetStatL(weapon, "Primary.FiresUnderwater") == false and weapon:GetOwner():WaterLevel() >= 3 then return false end
    
        v = hook.Run("TFA_CanPrimaryAttack", self)
        if v ~= nil then return v end
    
        if weapon:CheckJammed() then return false end
    
        return true
    end,
    
    ["arccw"] = function(weapon)
        if not weapon:IsValid() then return false end
    
        if weapon:GetHolster_Entity():IsValid() then return false end
        if weapon:GetHolster_Time() > 0 then return false end
        if weapon:GetReloading() then return false end
        if weapon:GetWeaponOpDelay() > CurTime() then return false end
        if weapon:GetHeatLocked() then return false end
        if weapon:GetState() == ArcCW.STATE_CUSTOMIZE then return false end
        if weapon:BarrelHitWall() > 0 then return false end
        if weapon:GetNWState() == ArcCW.STATE_SPRINT and not (weapon:GetBuff_Override("Override_ShootWhileSprint", weapon.ShootWhileSprint)) then return false end
        if (weapon:GetBurstCount() or 0) >= weapon:GetBurstLength() then return false end
        if weapon:GetNeedCycle() then return false end
        if weapon:GetCurrentFiremode().Mode == 0 then return false end
        if weapon:GetBuff_Override("Override_TriggerDelay", weapon.TriggerDelay) and weapon:GetTriggerDelta() < 1 then return false end
        if weapon:GetBuff_Hook("Hook_ShouldNotFire") then return false end
        if weapon:GetBuff_Hook("Hook_ShouldNotFireFirst") then return false end
    
        return true
    end
}

sAim.wepBlacklist = { 
    ["hands"] = true,
    ["none"] = true,
    ["pocket"] = true,
    ["inventory"] = true,
    ["weapon_physcannon"] = true,
    ["weapon_physgun"] = true,
    ["bomb"] = true,
    ["c4"] = true,
    ["climb"] = true,
    ["fist"] = true,
    ["grenade"] = true,
    ["hand"] = true,
    ["ied"] = true,
    ["knife"] = true,
    ["slam"] = true,
    ["sword"] = true
}

sAim.GetViewPunchGuns = {
    Bases = {
        ["cw"] = true,
        ["fas2"] = true,
        ["tfa"] = true,
        ["arccw"] = true,
    },
	Classes = {
		["weapon_ar2"] = true,
		["weapon_smg1"] = true,
        ["weapon_357"] = true,
	}
}

function sAim:PerformAim(cmd, ang)
    if self.m_tSettings.silent then
        self.Data.bShouldEngineViewAngles = false
    end

	cmd:SetViewAngles(ang)
	return true
end

function sAim:PerformFire(cmd)
    cmd:AddKey(IN_ATTACK)
    return true
end

-- stolen from leme : )
sAim.ShouldPenetrate = {
    ["ArcCW"] = GetConVar("arccw_enable_penetration"),
    ["M9K"] = GetConVar("M9KDisablePenetration"),
    ["TFA"] = GetConVar("sv_tfa_bullet_penetration"),
    ["TFA_Multiplier"] = GetConVar("sv_tfa_bullet_penetration_power_mul")
}

sAim.AmmoPenetration = {
    ["M9K"] = {
        ["357"] = 144,
        ["AR2"] = 256,
        ["Buckshot"] = 25,
        ["Pistol"] = 81,
        ["SMG1"] = 196,
        ["SniperPenetratedRound"] = 400
    }
}

function sAim:GetWeaponAmmoPenetration(weapon, tracedata)
	if not weapon:IsValid() then return nil end

	local AmmoType = weapon:GetPrimaryAmmoType()
	if not AmmoType then return nil end
	
	local AmmoName = game.GetAmmoName(AmmoType)
	if not AmmoName then return nil end
	
	if self:GetWeaponBase(weapon) == "bobs" then -- M9K is Bob's base
		if self.ShouldPenetrate["M9K"]:GetBool() then
			return nil
		end
	
		return self.AmmoPenetration["M9K"][AmmoName] or nil
	end
	
	if self:GetWeaponBase(weapon) == "tfa" then
		if not self.ShouldPenetrate["TFA"]:GetBool() then
			return nil
		end
        
		local AmmoForceMultiplier = weapon.GetAmmoForceMultiplier
		local PenetrationMultiplier = weapon.GetPenetrationMultiplier
		if not AmmoForceMultiplier or not PenetrationMultiplier then return nil end
		
        local Multiplier = self.ShouldPenetrate["TFA_Multiplier"]:GetFloat()
		
		return ((AmmoForceMultiplier(weapon) / PenetrationMultiplier(weapon, tracedata.MatType)) * Multiplier) * 0.875
	end
	
	if self:GetWeaponBase(weapon) == "arccw" then
		if not self.ShouldPenetrate["ArcCW"]:GetBool() then
			return nil
		end

		return math.pow(weapon.Penetration or math.huge, 2)
	end
	
	if self:GetWeaponBase(weapon) == "fas2" then
		if not weapon.PenetrationEnabled or not weapon.PenStr then
			return nil
		end
		
		return math.pow(weapon.PenStr, 2) + (weapon.PenStr * 0.25)
	end
	
	if self:GetWeaponBase(weapon) == "cw" then
		if not weapon.CanPenetrate or not weapon.PenStr then
			return nil
		end
		
		return math.pow(weapon.PenStr, 2) + (weapon.PenStr * 0.25)
	end
	
	return nil
end

function sAim:WeaponCanPenetrate(weapon, tracedata)
	if not weapon:IsValid() then return false end

	if self:GetWeaponBase(weapon) == "fas2" or self:GetWeaponBase(weapon) == "cw" then
		local Entity = tracedata.Entity
		
		if tracedata.MatType == MAT_SLOSH or (Entity:IsValid() and (Entity:IsPlayer() or Entity:IsNPC())) then
			return false
		end
	end
	
	local AmmoPen = self:GetWeaponAmmoPenetration(weapon, tracedata)
	if not AmmoPen then return false end
	
	local HitPos = tracedata.HitPos
	local Forward = tracedata.Normal
	local EndPos
	
	local pTraceData = {}
	
	for i = 1, 75 do
		local cur = HitPos + (Forward * i)
		
		pTraceData.start = cur
		pTraceData.endpos = cur
		local tr = util.TraceLine(pTraceData)
		
		if not tr.Hit then
			EndPos = cur
		
			break
		end
	end
	
	if EndPos then
		local decimals = tostring(AmmoPen):Split(".")
		decimals = decimals[2] and #decimals[2] or 0
		
		if self:GetWeaponBase(weapon) == "tfa" then
			return math.Round(HitPos:Distance(EndPos) / 100, decmials) <= AmmoPen / 2, EndPos
		end
		
		return math.Round(HitPos:DistToSqr(EndPos), decimals) < AmmoPen, EndPos
	end
    
	return false
end

local tResult = {}
function sAim:IsThingVisible(thing, thingpos, hitgroup)
	local tData = {
		output = tResult,
		start = self:GetShootPos(LPLY),
		endpos = thingpos,
		mask = MASK_SHOT,
		filter = {LPLY},
	}
	
	util.TraceLine(tData)

    local result = false
--
	if thing:IsValid() then
		if hitgroup ~= nil then
			result = tResult.Entity == thing and tResult.HitGroup == hitgroup or tResult.Fraction == 1
		else
			result = tResult.Entity == thing or tResult.Fraction == 1
		end
	else
		result = tResult.Fraction == 1
	end

	if not result then
		CanPen, PenPos = self:WeaponCanPenetrate(LPLY:GetActiveWeapon(), tResult)
		if PenPos then
			tData.start = PenPos
		end
		
		util.TraceLine(tData)
        if CanPen then
        debugoverlay.Line(tData.start, tData.endpos, 5, Color(255,255,255), true)
        end
		if thing:IsValid() then
			if hitgroup ~= nil then
				result = CanPen and tResult.Entity == thing and tResult.HitGroup == hitgroup
			else
				result = CanPen and tResult.Entity == thing
			end
		else
			result = CanPen and tResult.Fraction == 1
		end
	end

    return result
end

function sAim:GetValidHitboxPos(ply, min, max, matrix, hitgroup)
    local center = Vector(0,0,0)
    center = (min + max) * 0.5
    sUtil:VectorTransform(center, matrix, center)

    if self:IsThingVisible(ply, center, hitgroup) then     
        return center 
    end
    
    if not sAim.m_tSettings.MultiPoint then return end

    local dist = sAim.m_tSettings.MultiPointDist

    local bt = {min, max}
    for a = 1, 2 do
        local x = matrix:GetRight() * ( -bt[a].y + ( -bt[a].y < 0 and 0.5 or -0.5 )/dist)
        for b = 1, 2 do
            local y = matrix:GetForward() * ( bt[b].x + ( bt[b].x < 0 and 0.5 or -0.5 )/dist)
            for c = 1, 2 do
                local z = matrix:GetUp() * ( bt[c].z + ( bt[c].z < 0 and 0.5 or -0.5 )/dist)
                local pos = matrix:GetTranslation()+x+y+z
                debugoverlay.Cross(pos, 1, 1, Color(255,0,0), true)
                if self:IsThingVisible(ply, pos, hitgroup) then 
                    return pos 
                end
            end
        end
    end
end

function sAim:GetHitBoxPoint(b, ply)
    for group = 0, ply:GetHitBoxGroupCount()-1 do
        for hitbox = 0, ply:GetHitBoxCount(group)-1 do
            local bone = ply:GetHitBoxBone(hitbox, group)
            if bone and bone == b then
                local matrix = ply:GetBoneMatrix(bone)
                if not matrix then continue end
                local headpos, headang = matrix:GetTranslation(), matrix:GetAngles()
                local min, max = ply:GetHitBoxBounds(hitbox, group)
                local hitgroup = ply:GetHitBoxHitGroup(hitbox, group)

                min:Mul(matrix:GetScale())
                max:Mul(matrix:GetScale())

                local pos = self:GetValidHitboxPos(ply, min, max, matrix, hitgroup)
                if not pos then return false end
                return pos
            end
        end
    end
end

function sAim:GetWeaponBase(wep)
	if not wep.Base then return "" end
	return string.Split(string.lower(wep.Base), "_")[1]
end

function sAim:CanFire(wep)
    local class = wep:GetClass()
    if self.wepBlacklist[class] then return false end
    if string.find( wep:GetClass(), "vape" ) then return false end
    if not self.m_tSettings.toolspam and wep == "gmod_tool" then return false end
    if wep:GetActivity() == ACT_RELOAD or wep:Clip1() ~= -1 and wep:Clip1() <= 0 then return false end
    if sAim.m_tSettings.slowFire and LPLY:GetViewPunchAngles() ~= Angle(0, 0, 0) then return false end
	local Base = self:GetWeaponBase(wep)
    local bCanShoot = (self.ShootChecks[Base] and self.ShootChecks[Base](wep)) or self.ShootChecks[Base] == nil and true

    return bCanShoot
end

function sAim:CanPrimaryAttack(wep)
    local wait = math.Remap(self.m_tSettings.bulletWait, 0, 1000, 0, 1)
    return wep:GetNextPrimaryFire() + wait <= self.Data.bulletTime
end

local o_setviewangles = FindMetaTable( "CUserCmd" ).SetViewAngles
FindMetaTable("CUserCmd").SetViewAngles = function(cmd, ang)
    local src = debug.getinfo(2).short_src
    if src == "gamemodes/base/gamemode/player_class/taunt_camera.lua" then
        return
    end
    return o_setviewangles(cmd, ang)
end

FindMetaTable("CUserCmd").ClearButtons = function() end
FindMetaTable("CUserCmd").ClearMovement = function() end

FindMetaTable("Player").IsPlayingTaunt = function() return false end
FindMetaTable("Player").SetEyeAngles = function(self, ang) return end

function sAim:predictTarget(pos, trg, type)
    -- Entity:GetAbsVelocity() in client returns networked velocity, works with prediction, and is the most accurate/current measure of velocity
    -- Entity:GetVelocity() returns position change over delta time ( an estimate CALCULATED CLIENT SIDE ) 
    if not pos then return false end
    local step = engine.TickInterval()
    local tvel = trg:GetAbsVelocity()--MPredict:VelocityAfterGravity(trg, trg:GetAbsVelocity(), 1)
    local lerp = sUtil:GetLerpTime()
    local lat = MPredict:TickToTime(MPredict:EstimateServerArriveTick())
    local frm = sUtil.cRealFrameTime

    if type == 'none' then return pos end 
    if type == 'ping'  then return pos+(tvel*lat) end 
    if type == 'engine'  then return tvel:LengthSqr() == 0 and pos or pos + tvel * step end
    if type == 'thing' then return tvel:LengthSqr() == 0 and pos or (pos + (tvel * frm)) end
end 

function sAim:GetShootPos(ent)
    return bHasProxi and ent:GetShootPos() or MPredict:GetPredictedShootPos(ent)
end

function sAim:ForceSpreadSeed(cmd, seed)
    seed = seed % 256
    cmd:SetRandomSeed(seed)
end

function sAim:RapidFire(cmd, wep)
    local wep = LPLY:GetActiveWeapon()
    if not wep:IsValid() then return end
    if cmd:KeyDown(IN_ATTACK) and LPLY:Alive() then
        if not self:CanFire(wep) then
            cmd:RemoveKey( IN_ATTACK )
        end
    end
end

function sAim:Init(cmd)
    if not self.m_tSettings.Toggle or cmd:CommandNumber() == 0 then return end
    local wep = LPLY:GetActiveWeapon()
    if not wep:IsValid() then return end
    local class = wep:GetClass()
    local bHasCrossBow = class == "weapon_crossbow"

    if bHasCrossBow and self.m_tSettings.SimulateBolt then
        MPredict:simulateBolt(self:GetShootPos(LPLY), LPLY:EyeAngles(), MPredict.SV_GRAVITY)
    end

    if not self:CanFire(wep) then return end

    if not self:CanPrimaryAttack(wep) then cmd:RemoveKey(IN_ATTACK) return end

    if wep:Clip1() ~= -1 and wep:Clip1() <= 0 then
        if wep:GetNextPrimaryFire() < MPredict:ServerTime() then
            cmd:RemoveKey(bit.bor(IN_ATTACK, IN_ATTACK2))
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_RELOAD))
        end
    end

    local bttndown = input.IsButtonDown(self.m_tSettings.FireKey)
    
    if bHasProxi then
        proxi.StartPrediction(cmd)
    end
    
    if self.m_tSettings.silent and cmd:KeyDown(IN_ATTACK) and not bttndown and sUtil:ShouldMove(LPLY) then
        local ang = cmd:GetViewAngles()

        if self.m_tSettings.NoSpread then
            if bHasProxi and self.m_tSettings.ForceSeed then
                self:ForceSpreadSeed(cmd, 33)
            end
            ang = NS:CalculateSpread(cmd, wep, ang )
        end

        local base = self:GetWeaponBase(wep)
        if self.GetViewPunchGuns.Bases[base] then
            ang = ang - LPLY:GetViewPunchAngles()
        elseif self.GetViewPunchGuns.Classes[class] then
            ang = ang - LPLY:GetViewPunchAngles()
        end
        
        self.Data.bShouldEngineViewAngles = false

        local bOkAim = self:PerformAim(cmd, ang) or false
        if bOkAim then
            bOkAim = false
        end
    end

    if self.m_tSettings.AutoFire or bttndown then
        local closestTab, target = sUtil:getEnt(self.m_tSettings.Range, "player", 1)
        self.Data.activeTarget = target

        if #closestTab < 1 then 
            self.Data.activeTarget = NULL
            self.Data.activePos = Vector(0, 0, 0)
            return
        end

        local aimPos = Vector(0,0,0)

        if bHasCrossBow then
            local tcenter = target:LocalToWorld(target:OBBCenter())
            local ulerptc = sUtil:uninterpolate(target, tcenter)
            aimPos = MPredict:SolveProjectile(target, ulerptc, target:GetAbsVelocity(), self:GetShootPos(LPLY), 3500)
            if not self:IsThingVisible(target, aimPos, nil) then return end
        else
            local b = target:LookupBone("ValveBiped.Bip01_Head1")
            aimPos = self:GetHitBoxPoint(b, target)
            --aimPos = bHasProxi and aimPos or self:predictTarget(aimPos, target, "engine")
        end

        if not aimPos or aimPos == Vector(0,0,0) then return end

        local ang = (aimPos - self:GetShootPos(LPLY)):Angle()

        if self.m_tSettings.NoSpread then
            if bHasProxi and self.m_tSettings.ForceSeed then
                self:ForceSpreadSeed(cmd, 33)
            end
            ang = NS:CalculateSpread(cmd, wep, ang )
        end

        local base = self:GetWeaponBase(wep)
        if self.GetViewPunchGuns.Bases[base] then
            ang = ang - LPLY:GetViewPunchAngles()
        elseif self.GetViewPunchGuns.Classes[class] then
            ang = ang - LPLY:GetViewPunchAngles()
        end

        local bOkAim = ang and self:PerformAim(cmd, ang) or false
        if bOkAim then
            if bHasProxi then
                local time = MPredict:GetSimTime(target)
                local tick = MPredict:TimeToTick(time)
                cmd:SetTickCount(tick)
            end
            local bOkFire = self:PerformFire(cmd) or false
            if bOkFire then
                debugoverlay.Cross(aimPos, 15, 2, Color( 255, 0, 255), true)
                --debugoverlay.Line(aimPos, shootPos, 1, Color(100, 170, 100), false)
                --debugoverlay.Line(LPLY:GetShootPos(), aimPos, 0.5, Color(0,0,255), true)
                --debugoverlay.Line(sAim.Data.shootPos, aimPos, 0.5, Color(0,255,0), true)
                self.Data.activePos = aimPos
                bOkFire = false
            end
            bOkAim = false
        end
    end

    if bHasProxi then
        proxi.EndPrediction()
    end
end

s0lame.RegisterHack("sAim", "0.1", sAim, sAim.m_tSettings)