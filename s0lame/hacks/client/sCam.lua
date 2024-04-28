sCam = sCam or {}

sCam.m_tSettings = {
    Toggle = true,
    c_collision = false,
    c_height = 0,
    c_yaw = 0,
    c_pitch = 0,
    c_fov = 100,
    showlocalplayer = false,
    thirdpersonKey = 83
}
local lastAngle = Angle(0,0,0)
function sCam:Init( ply, pos, angles, fov )
    if not self.m_tSettings.Toggle or LPLY:GetVehicle():IsValid() then return end

    local yaw = self.m_tSettings.c_yaw
    local pitch = self.m_tSettings.c_pitch
    local heightoff = self.m_tSettings.c_height

    local offsetangle = Angle( pitch, yaw, 0 )

    local view = {
        origin = pos,
        angles = angles,
        fov = fov,
        drawviewer = self.m_tSettings.showlocalplayer
    }

    --if sAim.m_tSettings.silent then
    --    view.angles = bHasProxi and angles or sMove.Data.viewAngle
    --elseif not sAim.m_tSettings.silent then
    --    view.angles = bHasProxi and angles or sMove.Data.postCMoveViewAngle
    --end

    view.angles:Sub(LPLY:GetViewPunchAngles())

    local fovfixed = GetConVar("fov_desired"):GetFloat() - view.fov
    view.fov = math.Clamp(self.m_tSettings.c_fov - fovfixed, 1, 179)
    
    if self.m_tSettings.c_collision then 
        local endpos = pos - ( (view.angles - offsetangle):Forward() * heightoff )
        local tr = util.TraceHull({
            start = pos,
            endpos = endpos,
            mask = MASK_PLAYERSOLID,
            filter = LPLY,
            mins = Vector(-8, -8, -8),
            maxs = Vector(8, 8, 8)
        })
        view.origin = tr.HitPos
    else
        view.origin = pos - ( (view.angles - offsetangle):Forward() * heightoff )
    end

    return view
end

s0lame.RegisterHack("sCam", "0.1", sCam, sCam.m_tSettings)