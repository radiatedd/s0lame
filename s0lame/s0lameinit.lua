local is_windows = system.IsWindows()
local is_linux = system.IsLinux()
local is_osx = system.IsOSX()
local is_x64 = jit.arch == "x64"

local dll_prefix = CLIENT and "gmcl" or "gmsv"
local dll_suffix = assert(
    (is_windows and (is_x64 and "win64" or "win32")) or
    (is_linux and (is_x64 and "linux64" or "linux")) or
    (is_osx and (is_x64 and "osx64" or "osx"))
)

-- metaman (danielga) unrequire
do
    local _MODULES = _MODULES
    local package_loaded = package.loaded
    local _R = debug.getregistry()
    local _LOADLIB = _R._LOADLIB

    local separator = is_windows and "\\" or "/"

    local fmt = string.format(
        "^LOADLIB: .+%sgarrysmod%slua%sbin%s%s_%%s_%s.dll$",
        separator,
        separator,
        separator,
        separator,
        dll_prefix,
        dll_suffix
    )

    function unrequire(name)
        _MODULES[name] = nil
        package_loaded[name] = nil

        local loadlib = string.format(fmt, name)
        for name, mod in pairs(_R) do
            if type(name) == "string" and string.find(name, loadlib) then
                _LOADLIB.__gc(mod)
                _R[name] = nil
                break
            end
        end
    end
end

do
    local _MODULES = _MODULES
    local package_loaded = package.loaded
    local _R = debug.getregistry()
    local _LOADLIB = _R._LOADLIB

    local separator = is_windows and "\\" or "/"

    local fmt = string.format(
        "^LOADLIB: .+%sgarrysmod%slua%sbin%s%s_%%s_%s.dll$",
        separator,
        separator,
        separator,
        separator,
        dll_prefix,
        dll_suffix
    )

    function unrequire(name)
        _MODULES[name] = nil
        package_loaded[name] = nil

        local loadlib = string.format(fmt, name)
        for name, mod in pairs(_R) do
            if type(name) == "string" and string.find(name, loadlib) then
                _LOADLIB.__gc(mod)
                _R[name] = nil
                break
            end
        end
    end
end

/*
stop using metatable lookups!

this was checking player:IsAlive() vs _R.Player.Alive(ply)
syntactic:    0.014000000192027
meta:    0.0027000000955013
*/

--------------------------- Menu State Fixes ---------------------------

TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT or 0
TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER or 1
TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT or 2
TEXT_ALIGN_TOP = TEXT_ALIGN_TOP or 3
TEXT_ALIGN_BOTTOM = TEXT_ALIGN_BOTTOM or 4

MOUSE_LEFT = MOUSE_LEFT or 107
MOUSE_RIGHT = MOUSE_RIGHT or 108
MOUSE_WHEEL_UP = MOUSE_WHEEL_UP or 112
MOUSE_WHEEL_DOWN = MOUSE_WHEEL_DOWN or 113

STENCIL_NEVER = STENCIL_NEVER or 1
STENCIL_LESS = STENCIL_LESS or 2
STENCIL_EQUAL = STENCIL_EQUAL or 3
STENCIL_LESSEQUAL = STENCIL_LESSEQUAL or 4
STENCIL_GREATER = STENCIL_GREATER or 5
STENCIL_NOTEQUAL = STENCIL_NOTEQUAL or 6
STENCIL_GREATEREQUAL = STENCIL_GREATEREQUAL or 7
STENCIL_ALWAYS = STENCIL_ALWAYS or 8

STENCIL_KEEP = STENCIL_KEEP or 1
STENCIL_ZERO = STENCIL_ZERO or 2
STENCIL_REPLACE = STENCIL_REPLACE or 3
STENCIL_INCRSAT = STENCIL_INCRSAT or 4
STENCIL_DECRSAT = STENCIL_DECRSAT or 5
STENCIL_INVERT = STENCIL_INVERT or 6
STENCIL_INCR = STENCIL_INCR or 7
STENCIL_DECR = STENCIL_DECR or 8

STENCILOPERATION_KEEP = STENCILOPERATION_KEEP or 1
STENCILOPERATION_ZERO = STENCILOPERATION_ZERO or 2
STENCILOPERATION_REPLACE = STENCILOPERATION_REPLACE or 3
STENCILOPERATION_INCRSAT = STENCILOPERATION_INCRSAT	 or 4
STENCILOPERATION_DECRSAT = STENCILOPERATION_DECRSAT or 5
STENCILOPERATION_INVERT = STENCILOPERATION_INVERT or 6
STENCILOPERATION_INCR = STENCILOPERATION_INCR or 7
STENCILOPERATION_DECR = STENCILOPERATION_DECR or 8

STENCILCOMPARISONFUNCTION_NEVER = STENCILCOMPARISONFUNCTION_NEVER or 1
STENCILCOMPARISONFUNCTION_LESS = STENCILCOMPARISONFUNCTION_LESS or 2
STENCILCOMPARISONFUNCTION_EQUAL = STENCILCOMPARISONFUNCTION_EQUAL or 3
STENCILCOMPARISONFUNCTION_LESSEQUAL = STENCILCOMPARISONFUNCTION_LESSEQUAL or 4
STENCILCOMPARISONFUNCTION_GREATER = STENCILCOMPARISONFUNCTION_GREATER or 5
STENCILCOMPARISONFUNCTION_NOTEQUAL = STENCILCOMPARISONFUNCTION_NOTEQUAL or 6
STENCILCOMPARISONFUNCTION_GREATEREQUAL = STENCILCOMPARISONFUNCTION_GREATEREQUAL	or 7
STENCILCOMPARISONFUNCTION_ALWAYS = STENCILCOMPARISONFUNCTION_ALWAYS or 8

MENU_DLL = MENU_DLL or false
--------------------------- Localization ---------------------------

local Color = Color
local ErrorNoHalt = ErrorNoHalt
local IsValid = IsValid
local Material = Material
local MsgC = MsgC
local error = error
local getmetatable = getmetatable
local include = hn_detours and hn_detours.detours_to_original[include] or include
local require = hn_detours and hn_detours.detours_to_original[require] or require
local ipairs = ipairs
local pairs = pairs
local setmetatable = setmetatable
local tobool = tobool
local tostring = tostring
local type = type
local xpcall = xpcall

local input_IsMouseDown = input.IsMouseDown

local debug_getinfo = debug.getinfo
local debug_getregistry = debug.getregistry


local string_format = string.format

local file_Find = hn_detours and hn_detours.detours_to_original[file.Find] or file.Find
local file_Exists = hn_detours and hn_detours.detours_to_original[file.Exists] or file.Exists
local file_Read = hn_detours and hn_detours.bak.file.Read or file.Read

local table_Copy = table.Copy
local table_Count = table.Count
local table_KeyFromValue = table.KeyFromValue
local table_remove = table.remove

local render_SetScissorRect = render.SetScissorRect

local gui_MouseX = gui.MouseX
local gui_MouseY = gui.MouseY

local vgui_CursorVisible = vgui.CursorVisible

LPLY = LocalPlayer()
bHasProxi = _G.proxi and true or false

local ENV = table_Copy(_G) -- lazy hack for now : )

--------------------------- Main stuffs ---------------------------

ENV.s0lame = ENV.s0lame or {}

ENV.s0lame.__type = "S0LAME"

ENV.s0lame.Registry = debug_getregistry()

ENV.s0lame.Colors = {
    Black = Color(0, 0, 0, 255),
    White = Color(255, 255, 255, 255),
    Red = Color(255, 0, 0, 255),
    Crimson = Color(175, 0, 42, 255),
    Green = Color(0, 255, 0, 255),
    BrightGreen = Color(132, 222, 2, 255),
    Blue = Color(0, 0, 255, 255),
    Lightblue = Color(114, 160, 193, 255),
    Darkblue = Color(17, 0, 102, 255),
    Lightred = Color(193, 160, 114, 255),
    Grey = Color(155, 155, 155, 255),
    Orange = Color(255, 126, 0, 255),
    Purple = Color(160, 32, 240, 255), 
    Violet = Color(178, 132,190, 255),
    Seafoam = Color(201, 255, 229, 255),
    Darkgrey = Color(50, 50, 50, 255),
    Aliceblue = Color(240, 248, 255, 255),
    Pink = Color(241, 156, 187, 255),
    Gold = Color(255, 215, 0, 255),
    Ultramarine = Color(85,0, 255, 255),
    Purpink = Color(255, 0, 85, 255),
    Grey = Color(155, 155, 155, 255),
    Yellow = Color(255, 255, 0, 255),

	Control = Color(240, 240, 240, 255),
	ControlMedium = Color(172, 172, 172, 255),
	ControlDark = Color(45, 45, 45, 255),

	Error = Color(255, 222, 102)
}

ENV.s0lame.Materials = {
	Gradients = {
		Right = Material("vgui/gradient-r"),
		Down = Material("vgui/gradient-d")
	}
}

ENV.s0lame.MenuLoadOrder = {
	"sPanel",
	"sLabel",
	"sButton",
	"sFrame",
	"sCheckBox",
	"sSlider",
	"sLabelSlider",
	"sDropDown",
	"sScrollBar",
	"sTextBox",
	"sBinder",
	"sListRow",
	"sList",
	"sColorHueBar",
	"sColorAlphaBar",
	"sColorPicker",
	"sColorButton"
}

ENV.s0lame.CStateLoadOrder = {
	"sCam",
	"sVis",
	"sUtil",
	"MPredict",
	"sAim",
	"sMove",
	"RPStuff",
	"md5spread",
	"Hooks",
	"sMenu"
}

ENV.s0lame.Elements = {}

ENV.s0lame.Hacks = {}

ENV.s0lame.Data = {
	versionnumber = "0.6",
}

ENV.s0lame.RenderStack = {}

ENV.s0lame.SuppressErrors = false
ENV.s0lame.FocusedObject = nil
ENV.s0lame.LastObjectID = -2147483648

ENV.s0lame.Mouse = {
	CanClickThisFrame = false,
	ClickedThisFrame = nil,

	Left = false,
	Right = false,
	
	Scroll = {
		Up = false,
		Down = false
	},
	
	Dragging = {
		Active = false,
		Object = nil,

		Origin = {
			X = 0,
			Y = 0
		}
	}
}

ENV.s0lame.KeyBoard = {
	Typing = false,
	ActiveTyper = nil,

	Chars = { -- Translations because input.GetKeyName isn't good enough; Slightly out of order because yeah; This game sucks
		[KEY_A] = "a",
		[KEY_B] = "b",
		[KEY_C] = "c",
		[KEY_D] = "d",
		[KEY_E] = "e",
		[KEY_F] = "f",
		[KEY_G] = "g",
		[KEY_H] = "h",
		[KEY_I] = "i",
		[KEY_J] = "j",
		[KEY_K] = "k",
		[KEY_L] = "l",
		[KEY_M] = "m",
		[KEY_N] = "n",
		[KEY_O] = "o",
		[KEY_P] = "p",
		[KEY_Q] = "q",
		[KEY_R] = "r",
		[KEY_S] = "s",
		[KEY_T] = "t",
		[KEY_U] = "u",
		[KEY_V] = "v",
		[KEY_W] = "w",
		[KEY_X] = "x",
		[KEY_Y] = "y",
		[KEY_Z] = "z",
		[KEY_0] = "0",
		[KEY_1] = "1",
		[KEY_2] = "2",
		[KEY_3] = "3",
		[KEY_4] = "4",
		[KEY_5] = "5",
		[KEY_6] = "6",
		[KEY_7] = "7",
		[KEY_8] = "8",
		[KEY_9] = "9",
		[KEY_SPACE] = " ",
		[KEY_SLASH] = "/",
		[KEY_BACKSLASH] = "\\",
		[KEY_PAD_0] = "0",
		[KEY_PAD_1] = "1",
		[KEY_PAD_2] = "2",
		[KEY_PAD_3] = "3",
		[KEY_PAD_4] = "4",
		[KEY_PAD_5] = "5",
		[KEY_PAD_6] = "6",
		[KEY_PAD_7] = "7",
		[KEY_PAD_8] = "8",
		[KEY_PAD_9] = "9",
		[KEY_PAD_DIVIDE] = "/",
		[KEY_PAD_MULTIPLY] = "*",
		[KEY_PAD_MINUS] = "-",
		[KEY_PAD_PLUS] = "+",
		[KEY_PAD_DECIMAL] = ".",
		[KEY_APOSTROPHE] = "'",
		[KEY_BACKQUOTE] = "`",
		[KEY_COMMA] = ",",
		[KEY_PERIOD] = ".",
		[KEY_MINUS] = "-",
		[KEY_EQUAL] = "=",
		[KEY_LBRACKET] = "[",
		[KEY_RBRACKET] = "]",
		[KEY_SEMICOLON] = ";"
	},

	ExitChars = {
		[MOUSE_FIRST] = true,
		[MOUSE_LEFT] = true,
		[MOUSE_RIGHT] = true,
		[MOUSE_MIDDLE] = true,
		[KEY_ENTER] = true
	},

	HardExitChars = {
		[KEY_ESCAPE] = true
	}
}

surface.CreateFont( "font", {
	font = "Segoe UI", 
	extended = false,
	additive = false,
	size = 24,
	weight = 800,
	outline = false,
	antialias = false,
	shadow = true
} )

surface.CreateFont( "fontUI", {
	font = "Segoe UI", 
	extended = false,
	size = 13,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "fontAlpha", {
	font = "Segoe UI", 
	extended = false,
	additive = true,
	size = 24,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	outline = true,
	antialias = true,
	shadow = true
} )

if file_Exists("lua/bin/gmcl_proxi_win64.dll", "GAME") then
	unrequire("proxi")
	if jit.arch == "x64" then
	    MsgC(ENV.s0lame.Colors.BrightGreen, "\nproxi found! :^)\n")
		pcall(require, "proxi")
	elseif jit.arch == "x32" then
	    MsgC(ENV.s0lame.Colors.BrightGreen, "\nproxi found! :^)\n. .. . 32 bit gamer mode")
		pcall(require, "proxi")
	end
	GetConVar("cl_interpolate"):ForceBool(false)
	GetConVar("cl_interp"):ForceFloat(0)
	GetConVar("cl_interp"):ForceInt(0)
else
    MsgC(ENV.s0lame.Colors.Crimson, "\nproxi not found. .  noob.\n")
end

--------------------------- Functions ---------------------------

--[[
	Gets s0lame's __type
]]

function ENV.s0lame.GetType()
	return tostring(ENV.s0lame.__type)
end

--[[
	Gets type using __type
]]

function ENV.s0lame.GetRealType(Object)
	local ObjectMeta = getmetatable(Object)

	if ObjectMeta and ObjectMeta.__type then
		if type(ObjectMeta.__type) == "function" then
			return ObjectMeta.__type(Object)
		else
			return ObjectMeta.__type
		end
	end

	return type(Object)
end

--[[
	Easy argument checking
]]

function ENV.s0lame.CheckValueType(Index, Value, Desired)
	if not ENV.s0lame.Assert(type(Index) == "number", "Bad argument #1 to 'CheckValueType' (number expected, got " .. type(Index) .. ")") then return end
	if not ENV.s0lame.Assert(type(Desired) == "string", "Bad argument #3 to 'CheckValueType' (string expected, got " .. type(Desired) .. ")") then return end

	local dbg = debug_getinfo(2)
	local dbgname = dbg and (dbg.name or dbg.short_src or dbg.source) or "UNKNOWN"

	local ProvidedReal = ENV.s0lame.GetRealType(Value)
	local Provided = type(Value)

	if ProvidedReal ~= Desired and Provided ~= Desired then
		ENV.s0lame.Error(string_format("Bad argument #%d to '%s' (%s expected, got %s)", Index, dbgname, Desired, Provided))
	end
end

--[[
	Controls if errors should be announced normally or quietly printed
]]

function ENV.s0lame.SetSuppressErrors(NewState)
	ENV.s0lame.CheckValueType(1, NewState, "boolean")

	ENV.s0lame.SuppressErrors = NewState
end

function ENV.s0lame.GetSuppressErrors()
	return ENV.s0lame.SuppressErrors
end

--[[
	Handy error function
]]
function ENV.s0lame.funcTraceback(err)
	local spaces = "\n "
	for lvl = 2, math.huge do
		local info = debug_getinfo(lvl, "Slnf")
		if not info then break end
		err = err .. Format("%s%d. %s - %s:%d ",
							spaces,
							lvl - 1,
							info.name ~= "" and info.name or "(noob)",
							info.short_src,
							info.currentline
                        )
		spaces = spaces .. " "
	end
	return err
end

function ENV.s0lame.Error(Message, Halt, err)
	if ENV.s0lame.GetSuppressErrors() then
		if err then
			MsgC(ENV.s0lame.Colors.Error, self:funcTraceback(err))
		else
			MsgC(ENV.s0lame.Colors.Error, Message)
		end
	else -- Regular erroring
		if not Halt then
			ErrorNoHalt(Message)
		else
			error(Message)
		end
	end

	return not Halt
end

--[[
	Handy assert function
]]

function ENV.s0lame.Assert(Condition, Message, Halt)
	Message = Message or "Assertion failed"
	Halt = tobool(Halt)

	if not Condition then
		ENV.s0lame.Error(Message)
		return false
	end

	return true
end

--[[
	Puts an element into the element table
	Can also be used to create custom elements
]]

function ENV.s0lame.RegisterElement(ElementName, ElementMeta, InheritName)
	ENV.s0lame.CheckValueType(1, ElementName, "string")
	ENV.s0lame.CheckValueType(2, ElementMeta, "table")

	ElementMeta.__eq = function(A, B)
		if A._UID == nil or B._UID == nil then return false end
		return A._UID == B._UID
	end

	ENV.s0lame.LastObjectID = ENV.s0lame.LastObjectID + 1

	ElementMeta.__sName = ElementName
	ElementMeta.__type = ENV.s0lame.GetType()
	ElementMeta.__index = ElementMeta

	ElementMeta.__tostring = function(self)
		return ElementMeta.__type .. " [ " .. ElementMeta.__sName .. " ]"
	end

	if InheritName ~= nil then
		ENV.s0lame.CheckValueType(3, InheritName, "string")

		ENV.s0lame.Elements[ElementName] = setmetatable(ElementMeta, ENV.s0lame.Elements[InheritName])
	else
		ENV.s0lame.Elements[ElementName] = ElementMeta
	end
end
--[[
	Puts a hack into the hacks table
]]

function ENV.s0lame.RegisterHack(HackName, Version, HackMeta, HackSettings)
	ENV.s0lame.CheckValueType(1, HackName, "string")
	ENV.s0lame.CheckValueType(2, HackMeta, "table")

	HackMeta.__sName = HackName
	HackMeta.__type = ENV.s0lame.GetType()
	HackMeta.__index = HackMeta
	HackMeta.__vers = Version

	if HackSettings ~= nil then
		ENV.s0lame.CheckValueType(3, HackSettings, "table")
		HackMeta.__tSettings = HackSettings
	end

	HackMeta.__tostring = function(self)
		return HackMeta.__type .. " [ " .. HackMeta.__sName .. " ]"
	end

	ENV.s0lame.Hacks[HackName] = HackMeta
	PrintTable(ENV.s0lame.Hacks[HackName])
end


--[[
	Registers default elements
]]

function ENV.s0lame.RegisterElements()
	local files, _ = file_Find("lua/s0lame/elements/*", "GAME")
	if not MENU_DLL then
		for i, v in ipairs(ENV.s0lame.MenuLoadOrder) do
			local path = "lua/s0lame/elements/".. v .. ".lua"
			if file_Exists(path, "GAME") then 
				local content = file_Read(path, "GAME")
				local func = CompileString(content, v, false)
				if isfunction(func) then
					setfenv(func, ENV)
					xpcall(func, function(e)
						ENV.s0lame.Error(e, false, e)
					end)
				end
			else
				ENV.s0lame.Error("\ns0lame - Failed to load hack" .. v .. " " .. path, false)
				continue
			end
		end
	end

	local comCount = table_Count(ENV.s0lame.Elements)

	if comCount < #files then
		local dif = #files - comCount
		ENV.s0lame.Error("s0lame - Failed to regsiter " .. dif .. " component" .. (dif ~= 1 and "s" or ""), false)
	end
end

--[[
	Registers hacks
]]

function ENV.s0lame.RegisterHacks()
	local files, _ = file_Find("lua/s0lame/hacks/*", "GAME")
	if not MENU_DLL then
		for i, v in ipairs(ENV.s0lame.CStateLoadOrder) do
			local path = "lua/s0lame/hacks/client/".. v .. ".lua"
			if file_Exists(path, "GAME") then 
				local content = file_Read(path, "GAME")
				local func = CompileString(content, v, false)
				if isfunction(func) then
					setfenv(func, ENV)
					xpcall(func, function(e)
						ENV.s0lame.Error(e, false, e)
					end)
				end
			else
				ENV.s0lame.Error("\ns0lame - Failed to load hack" .. v .. " " .. path, false)
				continue
			end
		end
	end

	local comCount = table_Count(ENV.s0lame.Hacks)

	if comCount < #files then
		local dif = #files - comCount

		ENV.s0lame.Error("s0lame - Failed to regsiter " .. dif .. " component" .. (dif ~= 1 and "s" or ""), false)
	end
end

--[[
	Used to create elements
]]

function ENV.s0lame.Create(ElementType, ElementParent)
	ENV.s0lame.CheckValueType(1, ElementType, "string")

	local ElementMeta = ENV.s0lame.Elements[ElementType]

	if not ENV.s0lame.Assert(ElementMeta ~= nil, "Bad argument #1 to 'CreateObject' (Invalid element specified)") then return end
	if not ENV.s0lame.Assert(ElementMeta.__type == ENV.s0lame.GetType(), "Bad argument #1 to 'CreateObject' (Invalid element specified)") then return end

	local NewElement = setmetatable({
		_UID = ENV.s0lame.LastObjectID
	}, ElementMeta)

	ENV.s0lame.LastObjectID = ENV.s0lame.LastObjectID + 1

	for k, v in pairs(ElementMeta) do
		if type(v) == "table" then
			NewElement[k] = table_Copy(v)
		end
	end

	NewElement:Init()
	NewElement:PostInit()

	if IsValid(ElementParent) then
		NewElement:SetParent(ElementParent)
		NewElement:PostParentInit(ElementParent)
	end

	return NewElement
end


--[[
	Used to update an object's render state
]]

function ENV.s0lame.UpdateRenderState(Object, NewState)
	ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())
	ENV.s0lame.CheckValueType(2, NewState, "boolean")

	local ObjectKey = table_KeyFromValue(ENV.s0lame.RenderStack, Object)

	if NewState then
		if not ObjectKey then
			ENV.s0lame.RenderStack[#ENV.s0lame.RenderStack + 1] = Object
		end
	else
		if ObjectKey then
			table_remove(ENV.s0lame.RenderStack, ObjectKey)
		end
	end
end

--[[
	Check if an object is within another
]]

function ENV.s0lame.ObjectInBounds(Object, pObject)
	if Object:GetIgnoreParentBounds() or not IsValid(pObject) then return true end

	ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())
	ENV.s0lame.CheckValueType(2, pObject, ENV.s0lame.GetType())

	local XPos, YPos = Object:GetPos()
	local Left, Top, _, _ = Object:GetMargin()

	XPos = XPos + Left
	YPos = YPos + Top

	local pXPos, pYPos, pWidth, pHeight = pObject:GetX(), pObject:GetY(), pObject:GetWidth(), pObject:GetHeight()
	local pLeft, pTop, pRight, pBottom = pObject:GetMargin()

	pXPos = pXPos + pLeft
	pYPos = pYPos + pTop

	pWidth = pWidth - pRight
	pHeight = pHeight - pBottom

	return XPos >= pXPos and XPos <= pXPos + pWidth and YPos >= pYPos and YPos <= pYPos + pHeight
end

--[[
	Used to safely render objects
]]

function ENV.s0lame.RenderObject(Object, UpdateClipping)
	if not IsValid(Object) then return false end
	if not Object:GetVisible() then return false end

	if not Object:ShouldPaint() then return true end -- Can't paint, but don't remove from render stack
	if not ENV.s0lame.ObjectInBounds(Object, Object:GetParent()) then return true end

	xpcall(function()
		xOffset = xOffset or 0
		yOffset = yOffset or 0

		local XPos, YPos, Width, Height = Object:GetX(), Object:GetY(), Object:GetWidth(), Object:GetHeight()
		local Left, Top, Right, Bottom = Object:GetMargin()

		if UpdateClipping then
			render_SetScissorRect(XPos, YPos, XPos + Width, YPos + Height, true) -- Can't have more than 1 of these at a time :(
		end

		local oPush = false
		local pPush = false

		if Object:GetHasStencil() then
			oPush = true
			Object:PushStencil()
		end

		if Object:GetParentHasStencil() then
			pPush = true
			Object:GetParent():PushStencil()
		end

		Object:PaintBackground(XPos, YPos, Width, Height)
		Object:Paint(XPos, YPos, Width, Height)
		Object:PaintOverlay(XPos, YPos, Width, Height)

		if oPush then Object:PopStencil() end
		if pPush then Object:GetParent():PopStencil() end
		
		if ENV.s0lame.Mouse.CanClickThisFrame and Object:GetClickable() and ENV.s0lame.CursorInObject(Object) then
			ENV.s0lame.Mouse.ClickedThisFrame = Object
		end

		if UpdateClipping then
			render_SetScissorRect(XPos + Left, YPos + Top, XPos + Width - Right, YPos + Height - Bottom, true)
		end

		for _, v in ipairs(Object:GetChildren()) do
			ENV.s0lame.RenderObject(v, false)
		end

		Object:NoClipPaint(XPos, YPos, Width, Height)

		if UpdateClipping then
			render_SetScissorRect(0, 0, 0, 0, false)
		end

		Object:Think()
	end, function(e)
		ENV.s0lame.Error(e, false, e)
	end)

	return true
end

--[[
	Used to test if the cursor is within a box
]]

function ENV.s0lame.CursorInBounds(x1, y1, x2, y2)
	ENV.s0lame.CheckValueType(1, x1, "number")
	ENV.s0lame.CheckValueType(2, y1, "number")
	ENV.s0lame.CheckValueType(3, x2, "number")
	ENV.s0lame.CheckValueType(4, y2, "number")

	local MouseX, MouseY = gui_MouseX(), gui_MouseY()

	return MouseX >= x1 and MouseY >= y1 and MouseX <= x2 and MouseY <= y2
end

--[[
	Used to test if the cursor is within an object's bounds
]]

function ENV.s0lame.CursorInObject(Object)
	ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())

	local x, y = Object:GetPos()
	local w, h = Object:GetSize()

	return ENV.s0lame.CursorInBounds(x, y, x + w, y + h)
end

--[[
	Returns if something is being drug
]]

function ENV.s0lame.GetDragging()
	return ENV.s0lame.Mouse.Dragging.Active
end

--[[
	Sets if something is being drug
]]

function ENV.s0lame.SetDragging(NewState)
	ENV.s0lame.CheckValueType(1, NewState, "boolean")

	ENV.s0lame.Mouse.Dragging.Active = NewState
end

--[[
	Returns what is currently being drug (If anything)
]]

function ENV.s0lame.GetDraggingObject()
	return ENV.s0lame.Mouse.Dragging.Object
end

--[[
	Sets what is currently being drug (If anything)
]]

function ENV.s0lame.SetDraggingObject(Object)
	if Object ~= nil then
		ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())
	end

	ENV.s0lame.Mouse.Dragging.Object = Object
end

--[[
	Gets the dragging origin
]]

function ENV.s0lame.GetDraggingOrigin()
	return ENV.s0lame.Mouse.Dragging.Origin.X, ENV.s0lame.Mouse.Dragging.Origin.Y
end

--[[
	Sets the dragging origin
]]

function ENV.s0lame.SetDraggingOrigin(NewX, NewY)
	ENV.s0lame.CheckValueType(1, NewX, "number")
	ENV.s0lame.CheckValueType(2, NewY, "number")

	ENV.s0lame.Mouse.Dragging.Origin.X = NewX
	ENV.s0lame.Mouse.Dragging.Origin.Y = NewY
end

--[[
	Used to request dragging
]]

function ENV.s0lame.RequestDragging(Object)
	ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())

	if not ENV.s0lame.GetDragging() or not IsValid(ENV.s0lame.GetDraggingObject()) then
		ENV.s0lame.SetDraggingOrigin(gui_MouseX(), gui_MouseY())
		ENV.s0lame.SetDraggingObject(Object)
		ENV.s0lame.SetDragging(true)

		return true
	else
		return false
	end
end

--[[
	Returns if typing is active
]]

function ENV.s0lame.GetTyping()
	return ENV.s0lame.KeyBoard.Typing
end

--[[
	Sets if typing is active
]]

function ENV.s0lame.SetTyping(NewState)
	ENV.s0lame.CheckValueType(1, NewState, "boolean")

	ENV.s0lame.KeyBoard.Typing = NewState
end

--[[
	Returns what is being typed to, if anything
]]

function ENV.s0lame.GetTypingObject()
	return ENV.s0lame.KeyBoard.ActiveTyper
end

--[[
	Sets what is being typed to, if anything
]]

function ENV.s0lame.SetTypingObject(Object)
	if Object ~= nil then
		ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())
	end

	ENV.s0lame.KeyBoard.ActiveTyper = Object
end

--[[
	Requests typing to the given object
]]

function ENV.s0lame.RequestTyping(Object)
	ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())

	if not ENV.s0lame.GetTyping() or not IsValid(ENV.s0lame.GetTypingObject()) then
		ENV.s0lame.SetTypingObject(Object)
		ENV.s0lame.SetTyping(true)

		return true
	else
		return false
	end
end

--[[
	Checks if the given key code is valid or not
]]

function ENV.s0lame.CheckKeyCode(Code)
	ENV.s0lame.CheckValueType(1, Code, "number")

	return ENV.s0lame.KeyBoard.Chars[Code] ~= nil
end

--[[
	Gets the key code from the char table
]]

function ENV.s0lame.GetKeyCode(Code)
	ENV.s0lame.CheckValueType(1, Code, "number")

	if not ENV.s0lame.CheckKeyCode(Code) then
		return ""
	end

	return ENV.s0lame.KeyBoard.Chars[Code]
end

--[[
	Checks if a key code is a hard exit key
]]

function ENV.s0lame.IsHardExitKeyCode(Code)
	ENV.s0lame.CheckValueType(1, Code, "number")

	return ENV.s0lame.KeyBoard.HardExitChars[Code] ~= nil
end

--[[
	Checks if a key code is an exit key
]]

function ENV.s0lame.IsExitKeyCode(Code)
	ENV.s0lame.CheckValueType(1, Code, "number")

	return ENV.s0lame.KeyBoard.ExitChars[Code] ~= nil or ENV.s0lame.IsHardExitKeyCode(Code)
end

--[[
	Resets typing
]]

function ENV.s0lame.ResetTyping()
	ENV.s0lame.SetTyping(false)
	ENV.s0lame.SetTypingObject(nil)
end

--[[
	Sets focused object
]]

function ENV.s0lame.SetFocusedObject(Object)
	if Object ~= nil then
		ENV.s0lame.CheckValueType(1, Object, ENV.s0lame.GetType())
	end

	ENV.s0lame.FocusedObject = Object
end

--[[
	Gets focused object
]]

function ENV.s0lame.GetFocusedObject()
	return ENV.s0lame.FocusedObject
end

--------------------------- Final Setup ---------------------------

do
	ENV.s0lame.Registry.Color.__type = "Color" -- Awesome video game Garry quite amazing honestly the custom `type()` function doesn't work for Colors fantastic

	ENV.s0lame.RegisterElements()

	ENV.s0lame.RegisterHacks()

	--[[
		Handles scrolling
		Why does input.IsMouseDown(MOUSE_WHEEL_x) not work, Garry?
		These are janky as fuck because of the whole Derma keyboard focus makes these hooks not work thing
	]]

	hook.Add("PlayerButtonDown", "s0lame_Scroll", function(_, button)
		if button == MOUSE_WHEEL_UP then
			ENV.s0lame.Mouse.Scroll.Up = true
		end

		if button == MOUSE_WHEEL_DOWN then
			ENV.s0lame.Mouse.Scroll.Down = true
		end
	end)

	hook.Add("PlayerButtonUp", "s0lame_Scroll", function(_, button)
		if button == MOUSE_WHEEL_UP then
			ENV.s0lame.Mouse.Scroll.Up = false
		end

		if button == MOUSE_WHEEL_DOWN then
			ENV.s0lame.Mouse.Scroll.Down = false
		end
	end)

	--[[
		Renders everything
	]]

	hook.Add("DrawOverlay", "s0lame_Render", function()
		local Invalid = {}

		ENV.s0lame.Mouse.CanClickThisFrame = false
		ENV.s0lame.Mouse.ClickedThisFrame = nil

		local InputLeftDown = input_IsMouseDown(MOUSE_LEFT)
		local InputRightDown = input_IsMouseDown(MOUSE_RIGHT)

		local LeftDown = false
		local RightDown = false
		local Scroll = ENV.s0lame.Mouse.Scroll.Up or ENV.s0lame.Mouse.Scroll.Down

		local CursorVisible = vgui_CursorVisible()

		if InputLeftDown then
			if not ENV.s0lame.Mouse.Left and CursorVisible then
				LeftDown = true
				ENV.s0lame.Mouse.Left = true
			end
		else
			ENV.s0lame.Mouse.Left = false
		end

		if InputRightDown then
			if not ENV.s0lame.Mouse.Right and CursorVisible then
				RightDown = true
				ENV.s0lame.Mouse.Right = true
			end
		else
			ENV.s0lame.Mouse.Right = false
		end

		ENV.s0lame.Mouse.CanClickThisFrame = LeftDown or RightDown or Scroll

		if ENV.s0lame.GetDragging() and not (InputLeftDown or InputRightDown) then
			ENV.s0lame.SetDraggingObject(nil)
			ENV.s0lame.SetDragging(false)
		end

		for i = 1, #ENV.s0lame.RenderStack do
			if not ENV.s0lame.RenderObject(ENV.s0lame.RenderStack[i], true) then
				Invalid[#Invalid + 1] = i
			end
		end

		if IsValid(ENV.s0lame.Mouse.ClickedThisFrame) then
			ENV.s0lame.SetFocusedObject(ENV.s0lame.Mouse.ClickedThisFrame)

			if LeftDown then
				ENV.s0lame.Mouse.ClickedThisFrame:OnLeftClick()
			end

			if RightDown then
				ENV.s0lame.Mouse.ClickedThisFrame:OnRightClick()
			end

			if Scroll and IsValid(ENV.s0lame.Mouse.ClickedThisFrame.ScrollBar) then
				local ScrollOrigin = ENV.s0lame.Mouse.ClickedThisFrame.ScrollBar:GetValue()

				if ENV.s0lame.Mouse.Scroll.Up then
					ENV.s0lame.Mouse.ClickedThisFrame.ScrollBar:SetValue(ScrollOrigin - 30)
				end

				if ENV.s0lame.Mouse.Scroll.Down then
					ENV.s0lame.Mouse.ClickedThisFrame.ScrollBar:SetValue(ScrollOrigin + 30)
				end
			end
		end

		for i = 1, #Invalid do
			table_remove(ENV.s0lame.RenderStack, Invalid[i])
		end
	end)
end