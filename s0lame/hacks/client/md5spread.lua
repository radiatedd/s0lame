NS = NS or {}

NS.wepcone = {
    ["weapon_smg1"] = {0.04362, 0.04362},
    ["weapon_ar2"] = {0.02618, 0.02618},
    ["weapon_shotgun"] = {0.08716, 0.08716},
    ["weapon_pistol"] = {0.00873, 0.00873}
}

NS.HOMONOVUS = {}

local rand = UniformRandomStream()

local ai_shot_bias_min = GetConVar"ai_shot_bias_min"
local ai_shot_bias_max = GetConVar"ai_shot_bias_max"

for iSeed = 0, 255 do
    rand:SetSeed(iSeed)

    local x,y,z = 0, 0, 0
    local bias = 1

    local shotBiasMin = ai_shot_bias_min:GetFloat()
    local shotBiasMax = ai_shot_bias_max:GetFloat()

    local shotBias = ( ( shotBiasMax - shotBiasMin ) * bias ) + shotBiasMin
    local flatness = math.abs(shotBias) * 0.5

    repeat
        x = rand:RandomFloat(-1, 1) * flatness + rand:RandomFloat(-1, 1) * (1 - flatness)
        y = rand:RandomFloat(-1, 1) * flatness + rand:RandomFloat(-1, 1) * (1 - flatness)

        if shotBias < 0 then
            x = (x >= 0) and 1.0 - x or -1.0 - x
            y = (y >= 0) and 1.0 - y or -1.0 - y
        end

        z = (x * x) + (y * y)
    until z <= 1

    NS.HOMONOVUS[iSeed] = {x, y, z}
end

NS.Const = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
    0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
}

local md5_f = function (x,y,z) return bit.bor(bit.band(x,y),bit.band(-x-1,z)) end
local md5_g = function (x,y,z) return bit.bor(bit.band(x,z),bit.band(y,-z-1)) end
local md5_h = function (x,y,z) return bit.bxor(x,bit.bxor(y,z)) end
local md5_i = function (x,y,z) return bit.bxor(y,bit.bor(x,-z-1)) end

NS.MD5 = {}

function NS.MD5.z(f, a, b, c, d, x, s, ac)
    a = bit.band(a + f(b, c, d) + x + ac, 0xffffffff)
    return bit.bor(bit.lshift(bit.band(a, bit.rshift(0xffffffff, s)), s), bit.rshift(a, 32 - s)) + b
end

function NS.MD5.Fix(a)
    if (a > 2 ^ 31) then
        return a - 2 ^ 32
    end
    return a
end

function NS.MD5.Transform(A, B, C, D, X) 
    local a, b, c, d = A, B, C, D
    a = NS.MD5.z(md5_f, a, b, c, d, X[0], 7, NS.Const[1])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_f, d, a, b, c, X[1], 12, NS.Const[2])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_f, c, d, a, b, X[2], 17, NS.Const[3])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_f, b, c, d, a, X[3], 22, NS.Const[4])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_f, a, b, c, d, X[4], 7, NS.Const[5])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_f, d, a, b, c, X[5], 12, NS.Const[6])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_f, c, d, a, b, X[6], 17, NS.Const[7])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_f, b, c, d, a, X[7], 22, NS.Const[8])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_f, a, b, c, d, X[8], 7, NS.Const[9])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_f, d, a, b, c, X[9], 12, NS.Const[10])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_f, c, d, a, b, X[10], 17, NS.Const[11])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_f, b, c, d, a, X[11], 22, NS.Const[12])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_f, a, b, c, d, X[12], 7, NS.Const[13])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_f, d, a, b, c, X[13], 12, NS.Const[14])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_f, c, d, a, b, X[14], 17, NS.Const[15])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_f, b, c, d, a, X[15], 22, NS.Const[16])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_g, a, b, c, d, X[1], 5, NS.Const[17])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_g, d, a, b, c, X[6], 9, NS.Const[18])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_g, c, d, a, b, X[11], 14, NS.Const[19])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_g, b, c, d, a, X[0], 20, NS.Const[20])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_g, a, b, c, d, X[5], 5, NS.Const[21])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_g, d, a, b, c, X[10], 9, NS.Const[22])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_g, c, d, a, b, X[15], 14, NS.Const[23])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_g, b, c, d, a, X[4], 20, NS.Const[24])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_g, a, b, c, d, X[9], 5, NS.Const[25])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_g, d, a, b, c, X[14], 9, NS.Const[26])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_g, c, d, a, b, X[3], 14, NS.Const[27])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_g, b, c, d, a, X[8], 20, NS.Const[28])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_g, a, b, c, d, X[13], 5, NS.Const[29])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_g, d, a, b, c, X[2], 9, NS.Const[30])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_g, c, d, a, b, X[7], 14, NS.Const[31])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_g, b, c, d, a, X[12], 20, NS.Const[32])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_h, a, b, c, d, X[5], 4, NS.Const[33])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d) 
    d = NS.MD5.z(md5_h, d, a, b, c, X[8], 11, NS.Const[34])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_h, c, d, a, b, X[11], 16, NS.Const[35])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_h, b, c, d, a, X[14], 23, NS.Const[36])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_h, a, b, c, d, X[1], 4, NS.Const[37])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_h, d, a, b, c, X[4], 11, NS.Const[38])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_h, c, d, a, b, X[7], 16, NS.Const[39])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_h, b, c, d, a, X[10], 23, NS.Const[40])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_h, a, b, c, d, X[13], 4, NS.Const[41])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_h, d, a, b, c, X[0], 11, NS.Const[42])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_h, c, d, a, b, X[3], 16, NS.Const[43])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_h, b, c, d, a, X[6], 23, NS.Const[44])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    a = NS.MD5.z(md5_h, a, b, c, d, X[9], 4, NS.Const[45])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    d = NS.MD5.z(md5_h, d, a, b, c, X[12], 11, NS.Const[46])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    c = NS.MD5.z(md5_h, c, d, a, b, X[15], 16, NS.Const[47])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    b = NS.MD5.z(md5_h, b, c, d, a, X[2], 23, NS.Const[48])
    a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_i, a, b, c, d, X[0], 6, NS.Const[49])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_i, d, a, b, c, X[7], 10, NS.Const[50])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_i ,c, d, a, b, X[14], 15, NS.Const[51])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_i, b, c, d, a, X[5], 21, NS.Const[52])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_i, a, b, c, d, X[12], 6, NS.Const[53])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_i, d, a, b, c, X[3], 10, NS.Const[54])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_i, c, d, a, b, X[10], 15, NS.Const[55])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_i, b, c, d, a, X[1], 21, NS.Const[56])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_i, a, b, c, d, X[8], 6, NS.Const[57])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_i, d, a, b, c, X[15], 10, NS.Const[58])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_i, c, d, a, b, X[6], 15, NS.Const[59])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_i, b, c, d, a, X[13], 21, NS.Const[60])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     a = NS.MD5.z(md5_i, a, b, c, d, X[4], 6, NS.Const[61])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     d = NS.MD5.z(md5_i, d, a, b, c, X[11], 10, NS.Const[62])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     c = NS.MD5.z(md5_i, c, d, a, b, X[2], 15, NS.Const[63])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
     b = NS.MD5.z(md5_i, b, c, d, a, X[9], 21, NS.Const[64])
     a = NS.MD5.Fix(a) b = NS.MD5.Fix(b) c = NS.MD5.Fix(c) d = NS.MD5.Fix(d)
    return A + a, B + b, C + c, D + d
end

function NS.MD5.PseudoRandom(number)
    local a, b, c, d = NS.MD5.Fix(NS.Const[65]), NS.MD5.Fix(NS.Const[66]), NS.MD5.Fix(NS.Const[67]), NS.MD5.Fix(NS.Const[68])
    local m = {}
    for iter = 0, 15 do
        m[iter] = 0
    end
        m[0] = number
        m[1] = 128
        m[14] = 32
        a, b, c, d = NS.MD5.Transform(a, b, c, d, m)
    return bit.rshift(NS.MD5.Fix(b), 16) % 256
end

function NS:CalculateSpread(cmd, wep, ang)
    local class = wep:GetClass()
    local cone = NS.wepcone[class]

    if not cone then return ang end
    --print(cone[1], cone[2])

    if class == "weapon_pistol" then
        local ramp = sUtil:RemapClamped(wep:GetInternalVariable("m_flAccuracyPenalty"), 0, 1.5, 0, 1)
        cone = LerpVector(ramp, Vector(0.00873, 0.00873, 0.00873), Vector(0.05234, 0.05234, 0.05234))
    end

    if weapons.IsBasedOn( class, "bobs_gun_base") then 
        if wep:GetIronsights() or cmd:KeyDown(IN_ATTACK2) then
            cone = Vector(wep.Primary.IronAccuracy, wep.Primary.IronAccuracy, 0)
        else
            cone = Vector(wep.Primary.Spread, wep.Primary.Spread, 0) 
        end
    end

    local seed = bHasProxi and cmd:GetRandomSeed() or NS.MD5.PseudoRandom(cmd:CommandNumber())
    local x, y = NS.HOMONOVUS[seed][1], NS.HOMONOVUS[seed][2]

    local forward, right, up = ang:Forward(), ang:Right(), ang:Up()

    local RetVec = forward + (x * cone[1] * right * -1) + (y * cone[2] * up * -1)
    local spreadAngles =  RetVec:Angle()

    spreadAngles:Normalize()
    
    return spreadAngles
end

s0lame.RegisterHack("md5spread", "0.1", NS, NS.m_tSettings)