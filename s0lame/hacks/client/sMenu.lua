sMenu = sMenu or {}
_G.sMenu = sMenu 

sMenu.index = {
	ActiveTab = nil,
	DesiredTab = nil,
	ActiveSubTab = nil,
	DesiredSubTab = nil,
	CheckBoxes = {},
	Frames = {},
	Buttons = {},
	Lists = {},
	Sliders = {},
	ColorButtons = {},
	Binders = {},
	DropDowns = {},
	TextBoxes = {}
}

local mats = {
	[1] = "wire",
	[2] = "flat",
	[3] = "shiny",
	[4] = "glowy",
	[5] = "blaze",
	[6] = "tiger",
	[7] = "flame",
	[8] = "portal",
	[9] = "hoverball",
	[10] = "none"
}

function sMenu:CreateFrame(x, y, w, h, strTitle, bShouldScrollBar, Color1, Color2, Gradient, parent)
	parent = parent or Gradient
	self.index.Frames[strTitle] = s0lame.Create("sFrame", parent)
	self.index.Frames[strTitle]:SetSize(w, h)
	self.index.Frames[strTitle]:SetPos(x, y)
	self.index.Frames[strTitle]:SetVisible(false)
	self.index.Frames[strTitle]:SetTitle(strTitle)
	self.index.Frames[strTitle]:SetBackgroundColor(Color1, Color2, Gradient)
	if bShouldScrollBar then
		self.index.Frames[strTitle.."_SCROLLBAR"] = s0lame.Create("sScrollBar", self.index.Frames[strTitle])
		self.index.Frames[strTitle.."_SCROLLBAR"]:SetVisible(true)
	end
	return self.index.Frames[strTitle]
end

function sMenu:CreateCBox(x, y, str, tab, var, parent)
	self.index.CheckBoxes[var] = s0lame.Create("sCheckBox", parent)
	self.index.CheckBoxes[var]:SetPos(x, y)
	self.index.CheckBoxes[var]:SetVisible(true)
	self.index.CheckBoxes[var]:SetText(str)
	self.index.CheckBoxes[var]:SetChecked(tab[var])
	self.index.CheckBoxes[var].OnValueChanged = function(self, value)
		tab[var] = value
	end
	return self.index.CheckBoxes[var]
end

function sMenu:CreateSlider(x, y, min, max, width, str, tab, var, parent)
	self.index.Sliders[var] = s0lame.Create("sLabelSlider", parent)
	self.index.Sliders[var]:SetPos(x, y)
	self.index.Sliders[var]:SetVisible(true)
	self.index.Sliders[var]:SetMinValue(min)
	self.index.Sliders[var]:SetMaxValue(max)
	self.index.Sliders[var]:SetWidth(width)
	self.index.Sliders[var]:SetText(" "..str.." ")
	self.index.Sliders[var]:SetValue(tab[var])
	self.index.Sliders[var]:SetFont("fontUI")
	self.index.Sliders[var]:SetTextColor(s0lame.Colors.Control)
	self.index.Sliders[var].OnValueChanged = function(self, value)
		tab[var] = value
	end
end

function sMenu:CreateButton(x, y, str, parent, func)
	self.index.Buttons[str] = s0lame.Create("sButton", parent)
	self.index.Buttons[str]:SetPos(x, y)
	self.index.Buttons[str]:SetVisible(true)
	self.index.Buttons[str]:SetText(str)
	self.index.Buttons[str]:SetFont("DermaDefaultBold")
	self.index.Buttons[str]:SetTextColor(s0lame.Colors.ControlDark)
	self.index.Buttons[str].OnLeftClick = function(self)
		func()
	end
	return self.index.Buttons[str]
end

function sMenu:CreateBinder(x, y, tab, var, parent)
	self.index.Binders[var] = s0lame.Create("sBinder", parent)
	self.index.Binders[var]:SetPos(x, y)
	self.index.Binders[var]:SetVisible(true)
	self.index.Binders[var]:SetValue(tab[var])
	self.index.Binders[var]:SetFont("DermaDefaultBold")
	self.index.Binders[var]:SetTextColor(s0lame.Colors.ControlDark)
	self.index.Binders[var].OnValueChanged = function(self, value)
		tab[var] = value
	end
	return self.index.Binders[var]
end

function sMenu:CreateColorButton(x, y, tab, var, parent)
	self.index.ColorButtons[var] = s0lame.Create("sColorButton", parent)
	self.index.ColorButtons[var]:SetPos(x, y)
	self.index.ColorButtons[var]:SetVisible(true)
	self.index.ColorButtons[var]:SetColor(tab[var])
	self.index.ColorButtons[var].OnColorChanged = function(self, NewColor)
		tab[var] = NewColor
	end
	return self.index.ColorButtons[var]
end

function sMenu:CreateDropDown(x, y, tab, var, options, parent)
	self.index.DropDowns[var] = s0lame.Create("sDropDown", parent)
	self.index.DropDowns[var]:SetPos(x, y)
	self.index.DropDowns[var]:SetVisible(true)
	self.index.DropDowns[var]:SetFont("DermaDefaultBold")
	self.index.DropDowns[var]:SetTextColor(s0lame.Colors.Control)
	self.index.DropDowns[var]:SetBackgroundColor(s0lame.Colors.ControlDark)

	for i = 1, #options do
		if tab[var] == options[i] then
			self.index.DropDowns[var]:SelectOption(i)
		end
		self.index.DropDowns[var]:AddOption(options[i])
	end
	self.index.DropDowns[var].OnSelectionChanged = function(self, OldIndex, NewIndex)
		tab[var] = options[NewIndex]
	end
	return self.index.DropDowns[var]
end

function sMenu:CreateTextBox(x, y, tab, var, parent)
	self.index.TextBoxes[var] = s0lame.Create("sTextBox", parent)
	self.index.TextBoxes[var]:SetPos(x, y)
	self.index.TextBoxes[var]:SetVisible(true)
	self.index.TextBoxes[var]:SetFont("DermaDefaultBold")
	self.index.TextBoxes[var].OnValueChanged = function(self, value)
		tab[var] = value
	end
	return self.index.TextBoxes[var]
end

local x, xgap = 30, 110
local y, ygap = 20, 10

local framew, frameh = 600, 500
local subw, subh = 590, 445

local sw, sh = ScrW(), ScrH()

--/parent
sMenu.index.sFrameParent = sMenu:CreateFrame((sw/2)-(framew/2), (sh/2)-(frameh/2), framew, frameh, "s0lame v: "..s0lame.Data.versionnumber, false, Color(150, 150, 150, 255), Color(5, 5, 5, 255), "vertical")
sMenu.index.sFrameParent.Think = function(self)
	if self:GetDragging() then
		local ox = s0lame.Mouse.Dragging.Origin.X
		local oy = s0lame.Mouse.Dragging.Origin.Y

		self:SetPos(gui.MouseX() - ox, gui.MouseY() - oy)
	end
	if sMenu.index.DesiredTab ~= nil or sMenu.index.ActiveTab ~= sMenu.index.DesiredTab then
		if not sMenu.index.DesiredTab:GetVisible() then
			if sMenu.index.ActiveTab ~= nil then
				sMenu.index.ActiveTab:SetVisible(false)
			end
			sMenu.index.DesiredTab:SetVisible(true)
			sMenu.index.ActiveTab = sMenu.index.DesiredTab
		end
	end
	if sMenu.index.DesiredSubTab ~= nil then
		if not sMenu.index.DesiredSubTab:GetVisible() then
			if sMenu.index.ActiveSubTab ~= nil and sMenu.index.ActiveSubTab ~= sMenu.index.DesiredSubTab then
				sMenu.index.ActiveSubTab:SetVisible(false)
			end
			sMenu.index.DesiredSubTab:SetVisible(true)
			sMenu.index.ActiveSubTab = sMenu.index.DesiredSubTab
		end
	end
end

sMenu.index.sFrameParent.PaintBackground = function(self, x, y, w, h)
	local Color1, Color2 = self:GetBackgroundColor()
	local strAngle = self:GetBackgroundGradientAngle()
	self:DrawBlur(10, Color1, x, y)
	self:DoGradient(x, y, w, h, Color1, Color2, strAngle)
end

--\parent

--/aim panel
sMenu.index.sAimFrame = sMenu:CreateFrame(5, 50, subw, subh, "Aim", true, Color(0, 0, 0, 0), Color(255, 0, 0, 255), "vertical", sMenu.index.sFrameParent)
sMenu.index.sAimFrame:SetDraggable(false)
sMenu.index.sAimFrame:SetShowCloseButton(false)

sMenu:CreateButton(x, y+ygap, "Aim", sMenu.index.sFrameParent, function()
	sMenu.index.DesiredTab = sMenu.index.sAimFrame
end)

sMenu:CreateCBox(20, 30, "Enable", sAim.m_tSettings, "Toggle", sMenu.index.sAimFrame)
sMenu:CreateCBox(20, 60, "Auto Fire", sAim.m_tSettings, "AutoFire", sMenu.index.sAimFrame)

sMenu:CreateCBox(115, 30, "Silent", sAim.m_tSettings, "silent", sMenu.index.sAimFrame)
sMenu:CreateCBox(115, 60, "No Spread", sAim.m_tSettings, "NoSpread", sMenu.index.sAimFrame)

sMenu:CreateSlider(20, 120, 1, 100000, 450, "Aim Range", sAim.m_tSettings, "Range", sMenu.index.sAimFrame)

sMenu:CreateBinder(20, 90, sAim.m_tSettings, "FireKey", sMenu.index.sAimFrame)
--\aim panel

--/move panel
sMenu.index.sMoveFrame = sMenu:CreateFrame(5, 50, subw, subh, "Move", true, Color(0, 0, 0, 0), Color(0, 0, 255, 255), "vertical", sMenu.index.sFrameParent)
sMenu.index.sMoveFrame:SetDraggable(false)
sMenu.index.sMoveFrame:SetShowCloseButton(false)

sMenu:CreateButton(x+xgap, y+ygap, "Movement", sMenu.index.sFrameParent, function()
	sMenu.index.DesiredTab = sMenu.index.sMoveFrame
end)

sMenu:CreateCBox(20, 30, "Enable", sMove.m_tSettings, "Toggle", sMenu.index.sMoveFrame)
--sMenu:CreateCBox(115, 30, "Anti Aim", sMove.m_tSettings, "AntiAim", sMenu.index.sMoveFrame)

sMenu:CreateCBox(220, 30, "Edge Jump", sMove.m_tSettings, "EdgeJump", sMenu.index.sMoveFrame)
sMenu:CreateCBox(20, 60, "Auto Jump", sMove.m_tSettings, "AutoJump", sMenu.index.sMoveFrame)
sMenu:CreateCBox(115, 60, "Auto Strafe", sMove.m_tSettings, "AutoStrafe", sMenu.index.sMoveFrame)
sMenu:CreateCBox(220, 60, "High Jump", sMove.m_tSettings, "HighJump", sMenu.index.sMoveFrame)
sMenu:CreateDropDown(115, 30, sMove.m_tSettings, "AntiAim", {[1] = "none", [2] = "spin", [3] = "fakeforward"}, sMenu.index.sMoveFrame)
--\move panel

--/visual panel
sMenu.index.sVisFrame = sMenu:CreateFrame(5, 50, subw, subh, "Visuals", false, Color(0, 0, 0, 0), Color(0, 100, 100, 255), "vertical", sMenu.index.sFrameParent)
sMenu.index.sVisFrame:SetDraggable(false)
sMenu.index.sVisFrame:SetShowCloseButton(false)

sMenu:CreateButton(x+(xgap * 2), y+ygap, "Visuals", sMenu.index.sFrameParent, function()
	sMenu.index.DesiredTab = sMenu.index.sVisFrame
end)

sMenu:CreateSlider(10, 50, 1, 100000, 450, "Range", sVis.m_tSettings, "Range", sMenu.index.sVisFrame)

sMenu.index.s2DVisFrame = sMenu:CreateFrame(0, 70, subw, subh-70, "2D Visual Settings", true, Color(0, 25, 25, 0), Color(0, 100, 100, 0), "horizontal", sMenu.index.sVisFrame)
sMenu.index.s2DVisFrame:SetDraggable(false)
sMenu.index.s2DVisFrame:SetShowCloseButton(false)

sMenu:CreateButton(115, 30, "2D Settings", sMenu.index.sVisFrame, function()
	sMenu.index.DesiredSubTab = sMenu.index.s2DVisFrame
end)

sMenu:CreateCBox(20, 30, "Enable", sVis.m_tSettings._2D, "Toggle", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 90, "2D Boxes", sVis.m_tSettings._2D, "bbox", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(100, 90, sVis.m_tSettings._2D, "bbox_col", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(120, 90, sVis.m_tSettings._2D, "bbox_col_outline", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(140, 90, "Team Color", sVis.m_tSettings._2D, "bbox_teamcol", sMenu.index.s2DVisFrame)
sMenu:CreateSlider(350, 90, 1, 200, 100, "Length", sVis.m_tSettings._2D, "bbox_length", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(460, 90, "D3D9 Style(players)", sVis.m_tSettings._2D, "D3D9BBox", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(460, 70, "XRay Boxes", sVis.m_tSettings._2D, "xrayBoxes", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 120, "Names", sVis.m_tSettings._2D, "names", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(100, 120, sVis.m_tSettings._2D, "names_col", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(120, 120, sVis.m_tSettings._2D, "names_col_outline", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(140, 120, "Team Color", sVis.m_tSettings._2D, "names_teamcol", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 150, "Health Bar", sVis.m_tSettings._2D, "healthbar", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(100, 150, sVis.m_tSettings._2D, "healthbarcolMin", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(120, 150, sVis.m_tSettings._2D, "healthbarcolMax", sMenu.index.s2DVisFrame)
sMenu:CreateSlider(140, 150, 1, 50, 100, "Length", sVis.m_tSettings._2D, "healthbarThickness", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 180, "Armor Bar", sVis.m_tSettings._2D, "armorbar", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(100, 180, sVis.m_tSettings._2D, "armorbarcolMin", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(120, 180, sVis.m_tSettings._2D, "armorbarcolMax", sMenu.index.s2DVisFrame)
sMenu:CreateSlider(140, 180, 1, 50, 100, "Length", sVis.m_tSettings._2D, "armorbarThickness", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 210, "OSI", sVis.m_tSettings._2D, "osi", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(100, 210, sVis.m_tSettings._2D, "osi_col", sMenu.index.s2DVisFrame)
sMenu:CreateColorButton(120, 210, sVis.m_tSettings._2D, "osi_col_outline", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(140, 210, "Team Color", sVis.m_tSettings._2D, "osi_teamcol", sMenu.index.s2DVisFrame)

sMenu:CreateSlider(240, 210, 1, 200, 100, "Dist", sVis.m_tSettings._2D, "osi_dist", sMenu.index.s2DVisFrame)
sMenu:CreateSlider(350, 210, 1, 180, 100, "Scale", sVis.m_tSettings._2D, "osi_scale", sMenu.index.s2DVisFrame)

sMenu:CreateCBox(20, 240, "Dormancy Prediction", sVis.m_tSettings._2D, "dormancyPred", sMenu.index.s2DVisFrame)
sMenu:CreateCBox(150, 240, "Smart Prediction ( LAGGY )", sVis.m_tSettings._2D, "dormancyPred_smart", sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(460, 210, sVis.m_tSettings._2D, "osi_shape", {[1] = "CIRCLE", [2] = "LINE", [3] = "TRIANGLE"}, sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(240, 180, sVis.m_tSettings._2D, "armorbarDock", {[1] = "LEFT", [2] = "RIGHT", [3] = "TOP", [4] = "BOTTOM"}, sMenu.index.s2DVisFrame)
sMenu:CreateDropDown(350, 180, sVis.m_tSettings._2D, "armorbarFill", {[1] = "LEFT", [2] = "MIDDLE", [3] = "RIGHT"}, sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(240, 150, sVis.m_tSettings._2D, "healthbarDock", {[1] = "LEFT", [2] = "RIGHT", [3] = "TOP", [4] = "BOTTOM"}, sMenu.index.s2DVisFrame)
sMenu:CreateDropDown(350, 150, sVis.m_tSettings._2D, "healthbarFill", {[1] = "LEFT", [2] = "MIDDLE", [3] = "RIGHT"}, sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(240, 120, sVis.m_tSettings._2D, "names_dockX", {[1] = "LEFT", [2] = "MIDDLE", [3] = "RIGHT"}, sMenu.index.s2DVisFrame)
sMenu:CreateDropDown(350, 120, sVis.m_tSettings._2D, "names_dockY", {[1] = "TOP", [2] = "MIDDLE", [3] = "BOTTOM"}, sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(240, 90, sVis.m_tSettings._2D, "bbox_style", {[1] = "FULL", [2] = "CORNERS"}, sMenu.index.s2DVisFrame)

sMenu:CreateDropDown(460, 120, sVis.m_tSettings._2D, "names_scroll", {[1] = "LEFT", [3] = "NONE", [2] = "RIGHT"}, sMenu.index.s2DVisFrame)


sMenu.index.s3DVisFrame = sMenu:CreateFrame(0, 70, subw, subh-70, "3D Visual Settings", true, Color(0, 100, 100, 0), Color(0, 25, 25, 0), "horizontal", sMenu.index.sVisFrame)
sMenu.index.s3DVisFrame:SetDraggable(false)
sMenu.index.s3DVisFrame:SetShowCloseButton(false)

sMenu:CreateButton(220, 30, "3D Settings", sMenu.index.sVisFrame, function()
	sMenu.index.DesiredSubTab = sMenu.index.s3DVisFrame
end)
sMenu:CreateCBox(20, 30, "Enable", sVis.m_tSettings._3D, "Toggle", sMenu.index.s3DVisFrame)
--sMenu:CreateSlider(20, 120, 1, 100000, 450, "Range", sVis.m_tSettings._3D, "Range", sMenu.index.s3DVisFrame)
sMenu:CreateSlider(100, 30, -1, 4, 150, "LOD", sVis.m_tSettings._3D, "LOD", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 210, "Hand Mat", sVis.m_tSettings._3D, "hand_chams", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(100, 210, sVis.m_tSettings._3D, "hand_chams_mat", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 210, sVis.m_tSettings._3D, "hand_chams_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 210, "Lighting", sVis.m_tSettings._3D, "hand_chams_lighting", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(300, 210, sVis.m_tSettings._3D, "hand_chams_mat2", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(405, 210, sVis.m_tSettings._3D, "hand_chams_col2", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 180, "VM Mat", sVis.m_tSettings._3D, "vm_chams", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(100, 180, sVis.m_tSettings._3D, "vm_chams_mat", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 180, sVis.m_tSettings._3D, "vm_chams_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 180, "Lighting", sVis.m_tSettings._3D, "vm_chams_lighting", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(300, 180, sVis.m_tSettings._3D, "vm_chams_mat2", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(405, 180, sVis.m_tSettings._3D, "vm_chams_col2", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 150, "XRay Halos", sVis.m_tSettings._3D, "xray_halos", sMenu.index.s3DVisFrame)
sMenu:CreateSlider(105, 150, 1, 10, 100, "Thickness", sVis.m_tSettings._3D, "xray_halo_thickness", sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 150, sVis.m_tSettings._3D, "xray_halo_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 150, "Rainbow", sVis.m_tSettings._3D, "xray_halo_rainbow", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 120, "Cham Halos", sVis.m_tSettings._3D, "cham_halos", sMenu.index.s3DVisFrame)
sMenu:CreateSlider(105, 120, 1, 10, 100, "Thickness", sVis.m_tSettings._3D, "cham_halo_thickness", sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 120, sVis.m_tSettings._3D, "cham_halo_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 120, "Rainbow", sVis.m_tSettings._3D, "cham_halo_rainbow", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 90, "Chams", sVis.m_tSettings._3D, "chams", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(100, 90, sVis.m_tSettings._3D, "chams_mat", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 90, sVis.m_tSettings._3D, "chams_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 90, "Lighting", sVis.m_tSettings._3D, "chams_lighting", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(300, 90, sVis.m_tSettings._3D, "chams_mat2", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(405, 90, sVis.m_tSettings._3D, "chams_col2", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(425, 90, "No Draw", sVis.m_tSettings._3D, "chams_nodraw", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(495, 90, "Team Color", sVis.m_tSettings._3D, "chams_teamcol", sMenu.index.s3DVisFrame)

sMenu:CreateCBox(20, 60, "XRay", sVis.m_tSettings._3D, "xray", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(100, 60, sVis.m_tSettings._3D, "xray_mat", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(210, 60, sVis.m_tSettings._3D, "xray_col", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(230, 60, "Lighting", sVis.m_tSettings._3D, "xray_lighting", sMenu.index.s3DVisFrame)
sMenu:CreateDropDown(300, 60, sVis.m_tSettings._3D, "xray_mat2", mats, sMenu.index.s3DVisFrame)
sMenu:CreateColorButton(405, 60, sVis.m_tSettings._3D, "xray_col2", sMenu.index.s3DVisFrame)
sMenu:CreateCBox(425, 60, "No Draw", sVis.m_tSettings._3D, "xray_nodraw", sMenu.index.s3DVisFrame)

sMenu.index.sVisLayerFrame = sMenu:CreateFrame(0, 70, subw, subh-70, "Layer Editor", true, Color(0, 100, 100, 0), Color(0, 25, 25, 0), "horizontal", sMenu.index.sVisFrame)
sMenu.index.sVisLayerFrame:SetDraggable(false)
sMenu.index.sVisLayerFrame:SetShowCloseButton(false)

sMenu:CreateButton(325, 30, "Layer Editor", sMenu.index.sVisFrame, function()
	sMenu.index.DesiredSubTab = sMenu.index.sVisLayerFrame
end)
--sMenu:CreateCBox(20, 30, "Enable", sVis.m_tSettings._3D, "Toggle", sMenu.index.sVisLayerFrame)

--\visual panel

--/ent viewer panel
sMenu.index.sViewerWLFrame = sMenu:CreateFrame((sw/2)-(subw/2), (sh/2)+(subh/1.75), subw, subh/2, "Whitelist", true, Color(0, 100, 100, 255), Color(0, 25, 25, 255), "vertical")

sMenu.WhiteListEnts = {["prop_physics"] = true}
local classes = {}
local dupes = {}

sMenu:CreateButton(10, 30, "ESP List", sMenu.index.sVisFrame, function()
	sMenu.index.sViewerWLFrame.ScrollBar:SetValue(0)
	local visBoolWL = not sMenu.index.sViewerWLFrame:GetVisible()
	sMenu.index.sViewerWLFrame:SetVisible(visBoolWL)

	local cboxes = {}
	for i = 1, #classes do
		cboxes[i] = s0lame.Create("sCheckBox", sMenu.index.sViewerWLFrame)
		cboxes[i]:SetPos(10, y*i+ygap)
		cboxes[i]:SetVisible(true)

		local str = classes[i]

		cboxes[i]:SetText(str)

		cboxes[i]:SetChecked(sMenu.WhiteListEnts[str] == true)
		
		cboxes[i].OnValueChanged = function(self, value)
			sMenu.WhiteListEnts[classes[i]] = value
		end
	end
end)

sMenu.index.Buttons["ESP List"].Think = function()
	local allEnts, closest = sUtil:getEnt(1000, nil)
	for i = 1, #allEnts do
		local class = allEnts[i]:GetClass()
		if dupes[class] then continue end
		dupes[class] = true
		classes[#classes+1] = class
	end
end
--\ent viewer panel

--/cam panel
sMenu.index.sCamFrame = sMenu:CreateFrame(5, 50, subw, subh, "Cam", true, Color(0, 0, 0, 0), Color(0, 255, 0, 255),  "vertical", sMenu.index.sFrameParent)
sMenu.index.sCamFrame:SetDraggable(false)
sMenu.index.sCamFrame:SetShowCloseButton(false)

sMenu:CreateButton(x+(xgap * 3), y+ygap, "Cam", sMenu.index.sFrameParent, function()
	--local visBool = not sMenu.index.sCamFrame:GetVisible()
	--sMenu.index.sCamFrame:SetVisible(visBool)
	sMenu.index.DesiredTab = sMenu.index.sCamFrame
end)

sMenu:CreateCBox(20, 30, "Enable", sCam.m_tSettings, "Toggle", sMenu.index.sCamFrame)
sMenu:CreateCBox(115, 30, "Collision", sCam.m_tSettings, "c_collision", sMenu.index.sCamFrame)
sMenu:CreateCBox(210, 30, "Show LocalPlayer", sCam.m_tSettings, "showlocalplayer", sMenu.index.sCamFrame)

sMenu:CreateSlider(20, 60, 0, 1000, 250, "Cam Height", sCam.m_tSettings, "c_height", sMenu.index.sCamFrame)
sMenu:CreateSlider(20, 90, -180, 180, 250, "Cam Yaw     ", sCam.m_tSettings, "c_yaw", sMenu.index.sCamFrame)
sMenu:CreateSlider(20, 120, -90, 90, 250, "Cam Pitch   ", sCam.m_tSettings, "c_pitch", sMenu.index.sCamFrame)
sMenu:CreateSlider(20, 150, 45, 179, 250, "Cam FOV    ", sCam.m_tSettings, "c_fov", sMenu.index.sCamFrame)

--\cam panel

--\spectator list panel -- WIP
sMenu.index.sSpecListFrame = sMenu:CreateFrame((sw/2)-(subw/2), (sh/2)-(subh/2), subw, subh, "Spectators", false, Color(0, 0, 0, 255), Color(0, 0, 0, 255), "horizontal")

lister = s0lame.Create("sList", sMenu.index.sSpecListFrame)
lister:SetSize(400, 200)
lister:SetVisible(true)
lister:SetBackgroundColor(s0lame.Colors.ControlDark)
lister:AddColumn("waht the")
lister:AddColumn("friak")
lister:AddColumn("f!")
local rows = {}
for i = 1, 5 do
	rows[i] = lister:AddRow("what", "the", "heck")
	 --SetBackgroundColor(s0lame.Colors.ControlDark)
end

for i = 1, #lister:GetChildren() do
	local child = lister:GetChildren()[i]
	child:SetBackgroundColor(s0lame.Colors.ControlDark)
end


sMenu:CreateButton(20, 180, "Spectator List", sMenu.index.sCamFrame, function()
	local visBool = not sMenu.index.sSpecListFrame:GetVisible()
	sMenu.index.sSpecListFrame:SetVisible(visBool)

	if lister:IsValid() then print(" it's valid ! ") end
end)
--\cam panel

concommand.Add( "s0lame", function()
	local visBool = not sMenu.index.sFrameParent:GetVisible()
	sMenu.index.sFrameParent:SetVisible(visBool)
end )

concommand.Add( "s0lame_registerhacks", function()
	s0lame.RegisterHacks()
end )

--/cam panel
sMenu.index.sMiscFrame = sMenu:CreateFrame(5, 50, subw, subh, "Misc", true, Color(0, 0, 0, 0), Color(0, 255, 0, 255),  "vertical", sMenu.index.sFrameParent)
sMenu.index.sMiscFrame:SetDraggable(false)
sMenu.index.sMiscFrame:SetShowCloseButton(false)

sMenu:CreateButton(x+(xgap * 4), y+ygap, "Misc", sMenu.index.sFrameParent, function()
	--local visBool = not sMenu.index.sMiscFrame:GetVisible()
	--sMenu.index.sMiscFrame:SetVisible(visBool)
	sMenu.index.DesiredTab = sMenu.index.sMiscFrame
end)

--sMenu:CreateCBox(20, 30, "Enable", sCam.m_tSettings, "Toggle", sMenu.index.sMiscFrame)
--sMenu:CreateSlider(20, 60, 0, 1000, 250, "Cam Height", sCam.m_tSettings, "c_height", sMenu.index.sMiscFrame)

--\cam panel

/*
sMenu.index.sExampleChildCheckbox = s0lame.Create("sCheckBox", sMenu.index.sFrameParent)
sMenu.index.sExampleChildCheckbox:SetPos(x, y*3+ygap)
sMenu.index.sExampleChildCheckbox:SetVisible(true)
sMenu.index.sExampleChildCheckbox:SetText("qrehyektul")
function sMenu.index.sExampleChildCheckbox:OnValueChanged(value)
	sMove.m_tSettings.BunnyHop = value
end

sMenu.index.sExamplesLabel = s0lame.Create("sLabel", sMenu.index.sFrameParent)
sMenu.index.sExamplesLabel:SetPos(x, y*4+ygap)
sMenu.index.sExamplesLabel:SetVisible(true)
sMenu.index.sExamplesLabel:SetText("text")

sMenu.index.sExampleSlider = s0lame.Create("sSlider", sMenu.index.sFrameParent)
sMenu.index.sExampleSlider:SetPos(x, y*5+ygap)
sMenu.index.sExampleSlider:SetVisible(true)
sMenu.index.sExampleSlider:SetMinValue(-200)
sMenu.index.sExampleSlider:SetWidth(300)
sMenu.index.sExampleSlider:SetText("Slider")

sMenu.index.sExampleTextBox = s0lame.Create("sTextBox", sMenu.index.sFrameParent)
sMenu.index.sExampleTextBox:SetPos(x, y*7+ygap)
sMenu.index.sExampleTextBox:SetVisible(true)

sMenu.index.sExamplesBinder= s0lame.Create("sBinder", sMenu.index.sFrameParent)
sMenu.index.sExamplesBinder:SetPos(x, y*8+ygap)
sMenu.index.sExamplesBinder:SetVisible(true)

sMenu.index.sExampleDropDown= s0lame.Create("sDropDown", sMenu.index.sFrameParent)
sMenu.index.sExampleDropDown:SetPos(x, y*6+ygap)
sMenu.index.sExampleDropDown:SetVisible(true)
sMenu.index.sExampleDropDown:AddOption("asd")
sMenu.index.sExampleDropDown:AddOption("asdf")
sMenu.index.sExampleDropDown:AddOption("asdfg")
sMenu.index.sExampleDropDown:AddOption("asdfgh")

sMenu.index.sColorButton = s0lame.Create("sColorButton", sMenu.index.sVisFrame)
sMenu.index.sColorButton:SetPos(50, 120)
sMenu.index.sColorButton:SetVisible(true)

function sMenu.index.sColorButton:OnColorChanged(NewColor)
	-- yay we got a new color woohooooooooooooooooo
	print(tostring(NewColor))
end

local lister = s0lame.Create("sList", sf)
lister:SetSize(200, 200)
lister:SetPos(50, 420)
lister:SetVisible(true)
lister:AddColumn("waht the")
lister:AddColumn("friak")
lister:AddColumn("f!")

for i = 1, 30 do
lister:AddRow("what", "the", "heck")
end

function lister:OnRowLeftClicked(Row)

end

function lister:OnRowRightClicked(Row)

end
*/