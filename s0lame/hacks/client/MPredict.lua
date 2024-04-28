MPredict = MPredict or {}

MPredict.SV_MAXVEL = GetConVar("sv_maxvelocity"):GetFloat()
MPredict.SV_GRAVITY = GetConVar("sv_gravity"):GetFloat()
MPredict.SV_FRICTION = GetConVar("sv_friction"):GetFloat()
MPredict.SV_AIRACCELERATE = GetConVar("sv_airaccelerate"):GetFloat()
MPredict.SV_ACCELERATE = GetConVar("sv_accelerate"):GetFloat()
MPredict.SV_STOPSPEED = GetConVar("sv_stopspeed"):GetFloat()
MPredict.SV_UNLAG = GetConVar("sv_unlag"):GetFloat()

local STEPTIME = engine.TickInterval()
local vecOrigin = Vector(0,0,0)
local gMAX_SAMPLE_TIME = 1

function MPredict:TimeToTick(time)
    return math.floor(0.5 + (time / engine.TickInterval()))
end
function MPredict:TickToTime(tick)
    return engine.TickInterval() * tick
end
function MPredict:RoundToTick(time)
    return self:TickToTime(self:TimeToTick(time))
end

function MPredict:ServerTime()
	return self:TickToTime(LPLY:GetInternalVariable("m_nTickBase"))
end

if bHasProxi then 
    function MPredict:GetSimTime(ent)
        return proxi.__Ent_GetNetVar(ent, "DT_BaseEntity->m_flSimulationTime", 1) -- force to cast to DPT_Float
    end
    function MPredict:GetTickBase(ent)
        return proxi.__Ent_GetNetVar(ent, "DT_LocalPlayerExclusive->m_nTickBase", 0) -- force to cast to DPT_Int
    end
end

function MPredict:EstimateServerArriveTick()
	local nTick = bHasProxi and self:TimeToTick(proxi.GetFlowOutgoing()) or self:TimeToTick(LPLY:Ping()/1000)
	return nTick
end

function MPredict:GetPredictedShootPos(ent)
    local shootPos = ent:GetShootPos()
    local vel = ent:GetAbsVelocity()
    local velfix = MPredict:VelocityAfterGravity(ent, vel, 1)
    shootPos = shootPos + vel * STEPTIME
    return shootPos
end

function MPredict:VelocityAfterGravity(ent, vel, ticks)
	local bIsOnGround = ent:IsOnGround()
	local entGravity = ent:GetGravity() == 0 and 1 or ent:GetGravity() 
    if not bIsOnGround and ent:GetMoveType() ~= MOVETYPE_NOCLIP then 
    	vel.z = vel.z - (entGravity * MPredict.SV_GRAVITY * 0.5 * STEPTIME * ticks) 
    	vel.z = vel.z + (ent:GetBaseVelocity().z * STEPTIME * ticks)
        vel.z = math.Clamp(vel.z, -self.SV_MAXVEL, self.SV_MAXVEL)
        return vel * STEPTIME * ticks
    else
        return vel * STEPTIME * ticks
    end
end

function MPredict:TravelTime(dist, v0, pitch)
    return dist / (math.cos(pitch) * v0)
end

function MPredict:GetLobPitch(distLength, distLengthZ, v0, g ) -- (targetpos - shootpos):Length2D(), targetpos.z - shootpos.z, inital vel, grav
    local root = v0 * v0 * v0 * v0 - g * (g * distLength * distLength + 2.0 * distLengthZ * v0 * v0)
    if root < 0 then print(root) return 180 end
    root = root^(0.5)
    return math.atan(((v0*v0) - root) / (g * distLength))
end

function MPredict:Extrapolate(shootPos, targetPos, target, grav, v0)
    local tvel = target:GetAbsVelocity()
    local onGround = target:IsOnGround()
    local gravperTick = grav * engine.TickInterval()

    tvel.z = not onGround and tvel.z - (gravperTick) or tvel.z
    tvel.z = math.Clamp(tvel.z, -self.SV_MAXVEL, self.SV_MAXVEL)

    local dist = targetPos:Distance( shootPos )
    local comptime = (dist/v0) + self:TickToTime(self:EstimateServerArriveTick())
    local final = targetPos + (tvel * comptime)
    return final
end

local _R = debug.getregistry()
local boltResult = {}
function MPredict:simulateBolt(shootPos, ang, grav, dietime)
    local dietime = dietime or 0.05
    local predPos = shootPos
	local vel = _R.Angle.Forward(ang) * 2500
	local sub = -grav * 0.05

    local mins, maxs = Vector(-1,-1,-1), Vector(1,1,1)
	local reflections = 0
    local tData = {
        output = boltResult,
        mask = MASK_SHOT,
        filter = LPLY,
        mins = mins,
        maxs = maxs
    }

    local finalPos
	
	while true do
		local nextPos = predPos + (vel * sUtil.cRealFrameTime)
        tData.start = predPos
        tData.endpos = nextPos

        util.TraceHull(tData)

		if boltResult.Fraction ~= 1 then
            local ent = boltResult.Entity
			local hitpos = boltResult.HitPos
			local dot = _R.Vector.Dot(boltResult.HitNormal, -boltResult.Normal)
			local len = _R.Vector.Length(vel)
            if ent and ent:IsValid() and ent:IsPlayer() then
                debugoverlay.Cross(hitpos, 15, dietime, Color( 255, 0, 0 ), true)
                MsgC(Color(255,0,0), ent:Nick(), " IN BOLT TRAJECTORY")
            end
			if dot < 0.5 and len > 100 then
				vel = (2.0 * boltResult.HitNormal * dot * len + vel) * 0.75
				sub = -grav
				predPos = hitpos
				reflections = reflections + 1
				debugoverlay.Line(predPos, hitpos, dietime, Color(255,0,0), true)
				debugoverlay.Text(hitpos, reflections, dietime, false)
				--render.DrawLine(predPos, nextPos, Color(255,0,0), true)
			else
				debugoverlay.Line(predPos, hitpos, dietime, Color(0,0,255), true)
				--render.DrawLine(predPos, nextPos, Color(0,0,255), true)
				--render.DrawWireframeBox(hitpos, Angle(0,0,255), Vector(-1,-1,-1), Vector(1,1,1), Color(0,0,255), false)
                finalPos = hitpos
				break	
			end
		else
			vel.z = vel.z + (0.5 * sub * sUtil.cRealFrameTime)
			debugoverlay.Line(predPos, nextPos, dietime, Color(255,255,255), true)
			--render.DrawLine(predPos, nextPos, Color(0,255,0), true) 
			predPos = nextPos
		end
	end
    if not finalPos then return end
    return finalPos
end

function MPredict:StrafePrediction(ent, vVelocity)
    if not ent.m_vecLastVelocity then 
        ent.m_vecLastVelocity = vVelocity  
    end

    local vLastVelocity = ent.m_vecLastVelocity  
    local flCurrentYaw = math.deg( math.atan2( vVelocity.y, vVelocity.x ) )  
    local flLastYaw = math.deg( math.atan2( vLastVelocity.y, vLastVelocity.x ) )  
    local rotation = Angle( 0, math.NormalizeAngle( flCurrentYaw - flLastYaw ), 0 )  

    ent.m_vecLastVelocity = vVelocity 
    
    return rotation
end

function MPredict:PerformStrafePrediction(ent, ticks)
	local Vel = ent:GetVelocity()
	local PredPos = ent:GetNetworkOrigin()
	local Rotation = self:StrafePrediction(ent, Vel)
	local Grav = Vector(0, 0, self.SV_GRAVITY)
	
    local traceData = {}
    traceData.filter = {ent}
    traceData.mask = MASK_PLAYERSOLID
    traceData.mins = ent:OBBMins()
    traceData.maxs = ent:OBBMaxs()
    
	for i = 1, ticks do
        traceData.start = PredPos
        traceData.endpos = PredPos - Grav * STEPTIME

        local traceResult = util.TraceHull( traceData )  
		
		Vel = Vel - Grav * STEPTIME
		
        local nextPos = PredPos + Vel * STEPTIME
        
		Vel:Rotate(Rotation)
		
        traceData.start = PredPos + Vector(0, 0, ent:GetStepSize())
        traceData.endpos = nextPos  
        
        local traceResult = util.TraceHull( traceData )  
		
		PredPos = traceResult.HitPos
	end
	return PredPos
end

local tResult = {}
function MPredict:SolveProjectile(target, targetPos, targetVel, shootPos, v0)
	local data = {
        m_flCompTime = self:TickToTime(self:EstimateServerArriveTick()),
        m_flGravity = MPredict.SV_GRAVITY * 0.05
	}

    local maxvel = GetConVarNumber("sv_maxvelocity")

    local FINALPOS
    local TIME = 0
    local PITCH = 0
    local PREDPOS = targetPos
    local ORIGIN = target:GetNetworkOrigin()
    local gravTime = MPredict.SV_GRAVITY * STEPTIME

    local mins, maxs = target:OBBMins(), target:OBBMaxs()

    local offset = targetPos - ORIGIN
	
    local tData = {
        output = tResult,
        mask = MASK_SHOT,
        filter = {target},
        mins = mins,
        maxs = maxs
    }

    while TIME < 10 do
    	targetVel.z = (target:GetMoveType() ~= MOVETYPE_NOCLIP and not target:IsOnGround()) and targetVel.z - gravTime or targetVel.z
        targetVel.z = math.Clamp(targetVel.z, -maxvel, maxvel)

        local NEXTPOS = PREDPOS + (targetVel * STEPTIME)

        tData.start = PREDPOS
        tData.endpos = NEXTPOS - offset

        util.TraceHull(tData)

        local vFloorNormal = tResult.HitNormal
    	local absHitNormZ = math.abs(vFloorNormal:Dot(Vector(0,0,1)))

        NEXTPOS = absHitNormZ >= 0.7 and tResult.HitPos +  offset or NEXTPOS

        local col = HSVToColor(TIME*180%360, 1, 1)
        debugoverlay.Line(PREDPOS, NEXTPOS, 2, col, false)        
        PREDPOS = NEXTPOS

        PITCH = self:GetLobPitch((PREDPOS - shootPos):Length2D(), PREDPOS.z - shootPos.z, v0, data.m_flGravity)

        local dist = (PREDPOS - shootPos):Length2D()
        local sTime = self:TravelTime(dist, v0, PITCH) + data.m_flCompTime
        if sTime < TIME then
            FINALPOS = PREDPOS
            break
        end
        TIME = TIME + STEPTIME
    end

    if not FINALPOS then return end
    
    local ang = Angle(-math.deg(PITCH), (FINALPOS - shootPos):Angle().y, 0)
    local final = shootPos + ang:Forward() * (FINALPOS - shootPos):Length2D()
    return final
end

function MPredict:FixVelocity(ent)
	-- basically, this will try and estimate an ents velocity if there is insufficient data/loss (ping, fakelag, etc) 
	-- only use if you know the player is fakelagging, otherwise it will assume the player will stop moving when walking on the ground
    ent.m_flDrop = ent.m_flDrop or 0
    ent.m_flVelocityLength = ent.m_flVelocityLength or 0
    ent.m_flControl = ent.m_flControl or 0
    ent.m_vWishVelocity = ent.m_vWishVelocity or vecOrigin
    ent.m_vNewVelocity = ent.m_vNewVelocity or 0
    
    local vel, grnd = ent:GetAbsVelocity(), ent:IsOnGround()
    if ent:WaterLevel() < 2  then
        ent.m_flVelocityLength = vel:Length() 
        if ent.m_flVelocityLength > 0.1 then 
        	if grnd then 
                ent.m_flControl = math.max(ent.m_flVelocityLength, MPredict.SV_STOPSPEED)
                ent.m_flDrop = ent.m_flControl * MPredict.SV_FRICTION * STEPTIME
            end
            
            ent.m_vNewVelocity = ent.m_flVelocityLength - ent.m_flDrop 
            
            if ent.m_vNewVelocity < 0 then 
            	ent.m_vNewVelocity = 0 
            end 
            
            if ent.m_vNewVelocity ~= ent.m_flVelocityLength then 
                 ent.m_vNewVelocity = ent.m_vNewVelocity / ent.m_flVelocityLength 
                 vel.x = vel.x * ent.m_vNewVelocity 
                 vel.y = vel.y * ent.m_vNewVelocity 
                 vel.z = vel.z * ent.m_vNewVelocity 
            end 
        end 
        ent.m_vWishVelocity = ent.m_vNewVelocity * Vector(vel.x, vel.y, vel.z) 
    end 
    
    local wishdir, wishspeed = ent.m_vWishVelocity, ent.m_vWishVelocity:Length() 
    
    if wishspeed ~= 0 then 
        wishdir = wishdir / wishspeed 
        if (wishspeed > ent:GetMaxSpeed()) then 
            ent.m_vWishVelocity = ent.m_vWishVelocity * ( ent:GetMaxSpeed() / wishspeed ) 
            wishspeed = ent:GetMaxSpeed() 
        end 
    end 
    
    local addspeed, accelspeed, currentspeed = 0, 0, 0 
    
    currentspeed = vel:Dot(wishdir)
    addspeed = wishspeed - currentspeed
    
    if addspeed > 0 then 
        accelspeed = MPredict.SV_ACCELERATE * STEPTIME * wishspeed 
        if accelspeed > addspeed then accelspeed = addspeed end 
        vel.x = vel.x * accelspeed * wishdir.x
        vel.y = vel.y * accelspeed * wishdir.y
        vel.z = vel.z * accelspeed * wishdir.z
    end
    
    --print(ent:GetAbsVelocity():Length(), Vector(vel.x,vel.y,vel.z):Length())
	debugoverlay.Box(ent:GetPos() + (Vector(vel.x,vel.y,vel.z) * STEPTIME), Vector(-4,-4,-4), Vector(4,4,4), STEPTIME, Color( 0, 0, 255 ), true)
    return Vector(vel.x,vel.y,vel.z)
end

function MPredict:PredictMove(ent, ticks)
	local data = {
		m_vVelocity = ent:GetAbsVelocity(),
        m_vOrigin = ent:GetPos(),
        m_vAngles = ent:GetAngles(),
        m_strMoveType = ent:GetMoveType(),
        m_vStepSize = Vector(0, 0, ent:GetStepSize()),
        m_vJumpPower = Vector(0, 0, ent:GetJumpPower()),

        b_isOnGround = ent:IsOnGround(),

        bboxMins = ent:OBBMins(),
        bboxMaxs = ent:OBBMaxs(),
        
        m_vGravity = Vector(0, 0, MPredict.SV_GRAVITY)
	}

    local traceData = {}
    traceData.filter = {ent}
    traceData.mask = MASK_PLAYERSOLID
    traceData.mins = data.bboxMins
    traceData.maxs = data.bboxMaxs
    
    local vNormData = {}
    vNormData.filter = {ent}
	vNormData.mask = MASK_PLAYERSOLID
	
	local ROT = self:StrafePrediction(ent, data.m_vVelocity)
	
	for i = 1, ticks do
        traceData.start = data.m_vOrigin
        traceData.endpos = data.m_vOrigin - data.m_vGravity * STEPTIME

        local traceResult = util.TraceHull( traceData )  
        

        debugoverlay.Line(traceData.start, traceData.endpos, 5, Color(0,255,0), true)
        
        vNormData.start = data.m_vOrigin
		vNormData.endpos = data.m_vOrigin - Vector(0,0,1000)
		
        local vNormResult = util.TraceLine(vNormData)
        
        local vFloorNormal = vNormResult.HitNormal
    	local absHitNormZ = math.abs(vFloorNormal:Dot(Vector(0,0,1)))
    		
    	--debugoverlay.Line(vNormData.start, vNormResult.HitPos, STEPTIME*2, Color(0,255,0), true)
		--print(absHitNormZ)
		
    	if not traceData.Hit then
    		data.m_vVelocity = data.m_vVelocity - data.m_vGravity * STEPTIME
    	end

        if absHitNormZ < 0.7 and absHitNormZ > 0 then -- slope is too steep
        	--print(vNormResult.HitPos.z - data.m_vOrigin.z)
            debugoverlay.Cross( traceData.start, 2.5, STEPTIME, Color(255,0,0), true )
        elseif absHitNormZ > 0.7 and absHitNormZ < 1 and not traceResult.Hit then -- slope is walkable
        	if data.b_isOnGround then 
				traceData.start.z = traceData.start.z - 2 -- nail that fucker down (total hack but it works)
			end
			debugoverlay.Cross( traceData.start, 2.5, STEPTIME, Color(0,0,255), true )
		elseif absHitNormZ == 1 then -- on flat plane
			debugoverlay.Cross( traceData.start, 2.5, STEPTIME, Color(0,255,0), false )
		end
		
		data.m_vVelocity:Rotate(ROT)
		
        local vNextOrigin = data.m_vOrigin + data.m_vVelocity * STEPTIME

        traceData.start = data.m_vOrigin + data.m_vStepSize  
        traceData.endpos = vNextOrigin  
        
        local traceResult = util.TraceHull( traceData )  

        local properZDiff = data.m_vOrigin.z - vNextOrigin.z  
        local actualZDiff = traceResult.HitPos.z - vNextOrigin.z  
        local substractZ  = actualZDiff - properZDiff  

        local vProperNextOrigin = traceResult.HitPos 
        
        if substractZ >= data.m_vStepSize.z then
            vProperNextOrigin.z = vProperNextOrigin.z - substractZ 
        end
		--data.b_isOnGround = (traceResult.Fraction < 1 and traceResult.AllSolid and traceResult.StartSolid) and traceResult.Normal.z >= 0.7
        data.m_vOrigin = vProperNextOrigin  
    end
    debugoverlay.Box(data.m_vOrigin, data.bboxMins, data.bboxMaxs, STEPTIME*2, Color( 0, 0, 255, 0.1 ), false)
    return data.m_vOrigin
end


--if bHasProxi then
--	hook.Remove("PostFrameStageNotify", "asdf", function(stage)
--		--if cmd:CommandNumber() == 0 then return end
--		if stage == 5 then
--			local target = LPLY
--			local ticks = MPredict:TimeToTick(1)
--			local pos = MPredict:PredictMove(target, ticks)
--			debugoverlay.Cross(pos, 2.5, 4+MPredict:TickToTime(ticks), Color(0,255,255), false)
--            debugoverlay.Cross(target:GetPos(), 2.5, 4, Color(0,255,0), false )
--            --local pos2 = MPredict:SolveProjectile(target, target:LocalToWorld(target:OBBCenter()), target:GetAbsVelocity(), LPLY:GetShootPos(), 3500)
--            --debugoverlay.Cross(pos2, 2.5, 4, Color(0,0,255), false )
--		end
--	end)
--    hook.Add("CreateMoveEx", "asdf", function(cmd)
--		if cmd:CommandNumber() ~= 0 then
--			local target = LPLY
--			local ticks = MPredict:TimeToTick(1)
--			local pos = MPredict:PredictMove(target, ticks)
--			debugoverlay.Cross(pos, 2.5, 4+MPredict:TickToTime(ticks), Color(0,255,255), false)
--            debugoverlay.Cross(target:GetPos(), 2.5, 4, Color(0,255,0), false )
--            --local pos2 = MPredict:PerformStrafePrediction(LPLY, ticks) --MPredict:SolveProjectile(target, target:GetNetworkOrigin()--[[target:LocalToWorld(target:OBBCenter())]], target:GetAbsVelocity(), LPLY:GetShootPos(), 3500)
--            --debugoverlay.Cross(pos2, 2.5, 4, Color(0,0,255), false )
--            --debugoverlay.Line(LPLY:GetShootPos(), pos2, 1, Color( 255, 255, 255 ))
--            --local angle = (pos2 - LPLY:GetShootPos()):Angle()
--	        for k, v in next, ents.FindByClass("crossbow_bolt") do
--                local mins, maxs = v:OBBMins(), v:OBBMaxs()
--                local pos, ang = v:GetPos(), v:GetAngles()
--                debugoverlay.BoxAngles(pos, mins, maxs, ang, 1, Color( 255, 0, 0 ))
--            end
--            --cmd:SetViewAngles(angle)
--		end
--    end)
--end 


s0lame.RegisterHack("MPredict", "0.1", MPredict)