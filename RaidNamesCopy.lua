--[[ Raid Names Copy
     Click the minimap button to grab every raid member's name into a
     ready-to-copy text box. WoW addons can't write the OS clipboard
     directly, so we select the text for you -- just press Ctrl+C.        ]]--

local ADDON_NAME = ...

-- SavedVariables (remembers the minimap button position)
RaidNamesCopyDB = RaidNamesCopyDB or {}

-- ---------------------------------------------------------------------------
-- Gather names
-- ---------------------------------------------------------------------------
local function GetGroupNames()
	local names = {}

	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local name = GetRaidRosterInfo(i)
			if name then
				-- Strip realm suffix if present (Name-Realm) for clean output
				name = name:match("^[^-]+") or name
				table.insert(names, name)
			end
		end
	elseif IsInGroup() then
		-- Party: include yourself plus party members
		table.insert(names, UnitName("player"))
		for i = 1, GetNumGroupMembers() - 1 do
			local name = UnitName("party" .. i)
			if name then
				table.insert(names, name)
			end
		end
	else
		-- Solo: just you
		table.insert(names, UnitName("player"))
	end

	return names
end

-- ---------------------------------------------------------------------------
-- Copy popup
-- ---------------------------------------------------------------------------
local copyFrame

local function CreateCopyFrame()
	local f = CreateFrame("Frame", "RaidNamesCopyFrame", UIParent, "DialogBoxFrame")
	f:SetSize(300, 240)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.title:SetPoint("TOP", 0, -12)

	local scroll = CreateFrame("ScrollFrame", "$parentScroll", f, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", -34, 40)

	local edit = CreateFrame("EditBox", nil, scroll)
	edit:SetMultiLine(true)
	edit:SetFontObject(ChatFontNormal)
	edit:SetWidth(250)
	edit:SetAutoFocus(false)
	edit:SetScript("OnEscapePressed", function() f:Hide() end)
	scroll:SetScrollChild(edit)

	f.edit = edit
	return f
end

local function ShowCopyPopup()
	if not copyFrame then
		copyFrame = CreateCopyFrame()
	end

	local names = GetGroupNames()
	local text = table.concat(names, "\n")

	copyFrame.title:SetText(("%d name(s) -- press Ctrl+C"):format(#names))
	copyFrame.edit:SetText(text)
	copyFrame.edit:HighlightText()
	copyFrame.edit:SetFocus()
	copyFrame:Show()
end

-- ---------------------------------------------------------------------------
-- Minimap button
-- ---------------------------------------------------------------------------
local function UpdateMinimapPosition(button)
	local angle = math.rad(RaidNamesCopyDB.minimapAngle or 215)
	local x = math.cos(angle) * 80
	local y = math.sin(angle) * 80
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
	local button = CreateFrame("Button", "RaidNamesCopyMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp")
	button:RegisterForDrag("LeftButton")

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetSize(20, 20)
	icon:SetTexture("Interface\\Icons\\INV_Scroll_03")
	icon:SetPoint("CENTER", 1, 1)

	-- Click: copy names
	button:SetScript("OnClick", ShowCopyPopup)

	-- Drag around the minimap edge
	button:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", function()
			local mx, my = Minimap:GetCenter()
			local px, py = GetCursorPosition()
			local scale = Minimap:GetEffectiveScale()
			px, py = px / scale, py / scale
			RaidNamesCopyDB.minimapAngle = math.deg(math.atan2(py - my, px - mx))
			UpdateMinimapPosition(self)
		end)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine("Raid Names Copy")
		GameTooltip:AddLine("Click: copy raid member names", 1, 1, 1)
		GameTooltip:AddLine("Drag: move this button", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)

	UpdateMinimapPosition(button)
	return button
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
	CreateMinimapButton()
end)
