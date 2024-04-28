sMove = sMove or {}

sMove.Data = {
	viewAngle = Angle(0,0,0),
	viewOrigin = Vector(0,0,0),
	postCMoveViewAngle = Angle(0,0,0),
    preCMoveViewAngle = Angle(0,0,0),
    MousePos = Angle(0, 0, 0),
    bSendPacket = false
}

sMove.m_tSettings = {
    Toggle = true,
    AutoJump = true,
    HighJump = false,
    AutoStrafe = false,
    AntiAim = "none", --spin, fakeforward, none
    EdgeJump = false,
}

function sMove:fixMovement(cmd, flYawRotation)
    local flYaw, flSpeed
    local move = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)

    flSpeed = move:Length2D()

    local view = cmd:GetViewAngles()
    view:Normalize()
    
    local angRotation = LPLY:EyeAngles().y
    if isnumber(flYawRotation) then
        angRotation = angRotation - flYawRotation
    end

    flYaw = math.deg(math.atan2(move.y, move.x))
    flYaw = math.rad(view.y - angRotation + flYaw)

    cmd:SetForwardMove(math.cos(flYaw) * flSpeed)
    cmd:SetSideMove(math.sin(flYaw) * flSpeed)

    if view.x < -90 or view.x > 90 then
        cmd:SetForwardMove(-cmd:GetForwardMove())
        cmd:SetSideMove(-cmd:GetSideMove())
    end
end

hook.Add("InputMouseApply", "capturemouse", function(cmd, x, y, ang)
    sMove.Data.MousePos = Angle(y * .022, x * -.022, 0)
    sMove:FixAngles(cmd)
end)

local lastAngle = Angle(0,0,0)
function sMove:FixAngles(cmd)
    if self.Data.viewAngle == Angle(0,0,0) then self.Data.viewAngle = cmd:GetViewAngles() end
    
    local wep = LPLY:GetActiveWeapon():IsValid() and LPLY:GetActiveWeapon() or false
    local m_hGrabbedEntity = wep ~= false and wep:GetInternalVariable("m_hGrabbedEntity") or false

    if cmd:KeyDown(IN_USE) and wep and m_hGrabbedEntity then
        self.Data.viewAngle = lastAngle
    else
        self.Data.viewAngle = self.Data.viewAngle + self.Data.MousePos
        lastAngle = self.Data.viewAngle
    end
	
    self.Data.viewAngle.y = math.Clamp(math.NormalizeAngle( self.Data.viewAngle.y ), -180, 180)
    self.Data.viewAngle.p = math.Clamp( self.Data.viewAngle.p, -89, 89 )

    --if cmd:CommandNumber() == 0 then
    --    cmd:SetViewAngles(sAim.m_tSettings.silent and self.Data.viewAngle or self.Data.postCMoveViewAngle)
    --end
end

local jit, bFlip = false, false
function sMove:performAngles(cmd, ang)
	if cmd:CommandNumber() == 0 then return end
    if sMove.m_tSettings.AntiAim == "spin" then
        local factor = 360 / math.pi
        factor = factor * 6
        ang.y = math.fmod(MPredict:ServerTime() * factor, 360)
    elseif sMove.m_tSettings.AntiAim == "fakeforward" then
	    if jit then
	    	ang = bFlip and Angle(-ang.p + 180, ang.y + 180, 180) or Angle(-ang.p + 180, ang.y - 180, 180)
	    	jit = false
            bFlip = not bFlip
	    else
	    	jit = true
	    end
    end

    sAim.Data.bShouldEngineViewAngles = false
	cmd:SetViewAngles(ang)
end

function sMove:MoveToPos(cmd, PosOrAng)
    cmd:SetForwardMove(10000)
    
    local vDir = isvector(PosOrAng) and PosOrAng - LPLY:EyePos() or isangle(PosOrAng) and PosOrAng
    vDir:Normalize()

    local ang = vDir:Angle()
    ang:Normalize()

    if LPLY:WaterLevel() >= 2 then
        cmd:SetViewAngles(ang)
    end
    
    cmd:AddKey(IN_SPEED)
    cmd:RemoveKey(IN_DUCK)

    self:fixMovement(cmd, ang.y)
end

local fwdSpeed, sideSpeed, airAccel = GetConVarNumber("cl_forwardspeed"), GetConVarNumber("cl_sidespeed"), GetConVarNumber("sv_airaccelerate")

function sMove:AutoStrafe(cmd)
    local velLen = LPLY:GetAbsVelocity():Length2D()
    local curYaw = ( cmd:GetViewAngles().y + 180 ) % 360

    if not LPLY:IsOnGround() and prevYaw ~= nil then
        cmd:SetForwardMove((fwdSpeed) / velLen)

        local sideMove = sideSpeed / velLen 

        if prevYaw > curYaw then
            cmd:SetSideMove(sideMove)
		elseif prevYaw < curYaw then
            cmd:SetSideMove(-sideMove)
        end
    else
        cmd:SetForwardMove(fwdSpeed)
    end
    prevYaw = curYaw
end

function sMove:HighJump(cmd)
    if LPLY:GetVelocity()[3] < 35 then return end
    cmd:SetButtons(bit.bor( cmd:GetButtons(), IN_DUCK ))
end

function sMove:RabbitHop(cmd)
  if not cmd:KeyDown(IN_JUMP) then return end
    if cmd:TickCount() % 2 == 0 then
      cmd:RemoveKey(IN_JUMP) 
    else
       cmd:AddKey(IN_JUMP) 
    end
end

function sMove:EdgeJump( cmd )
    if not LPLY:IsOnGround() then return end

    local StartPos = LPLY:GetPos()
    local StepSize = LPLY:GetStepSize()
    local EndPos = LPLY:GetPos() - Vector( 0, 0, StepSize )

    local velfwd = (LPLY:GetVelocity() * engine.TickInterval() * 2)

    local First = {
        start = StartPos,
        endpos = EndPos,
        filter = LPLY,
        mask = MASK_PLAYERSOLID
    }

    local Second = {
        start = StartPos + velfwd,
        endpos = EndPos + velfwd,
        filter = LPLY,
        mask = MASK_PLAYERSOLID,
    }

    local traceOne, traceTwo = util.TraceLine( First ), util.TraceLine( Second )

    if traceOne.Fraction ~= 1 and traceTwo.Fraction == 1 then
        debugoverlay.Line(First.start, First.endpos, 5, Color(255,0,0,255), true)
        debugoverlay.Line(Second.start, Second.endpos, 5, Color(0,0,255,255), true)
        cmd:AddKey(IN_JUMP)
    end
end
    
function sMove:Init(cmd)
    if sUtil:ShouldMove(LPLY) then
        if cmd:CommandNumber() ~= 0 then
            if self.m_tSettings.AutoJump then
                self:RabbitHop(cmd)
            end
            if self.m_tSettings.HighJump then
                self:HighJump(cmd)
            end
            if cmd:KeyDown(IN_JUMP) and self.m_tSettings.AutoStrafe then
                self:AutoStrafe(cmd)
            end
            if self.m_tSettings.EdgeJump then
                self:EdgeJump( cmd )
            end
        end
    end
end

s0lame.RegisterHack("sMove", "0.1", sMove, sMove.m_tSettings)