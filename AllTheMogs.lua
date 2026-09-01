local appName, app = ...;

-- Color palette for consistent dark theme
local ATM_BG_DARK = {0.05, 0.05, 0.08};
local ATM_BG_MID = {0.1, 0.1, 0.15};
local ATM_BG_HOVER = {0.18, 0.18, 0.25};
local ATM_BG_ACTIVE = {0.22, 0.22, 0.3};
local ATM_BORDER = {0.3, 0.3, 0.4};
local ATM_ACCENT = {0.2, 0.35, 0.55};

--------------------------------------------------------------------
-- globals

-- current selected slot (default Head)
filterSlot = 1;
-- current selected armor type (default Cloth)
filterArmorType = 1;
-- current selected weapon type (default One-Hand Axes)
filterWeaponType = 0;
-- current selected offhand type (default Shield)
filterOffhandType = 6;

-- current page
currentPage = 1;
-- max page
maxPage = 1;

-- helper to update page text display
function UpdatePageText()
	pageText:SetText(currentPage .. " / " .. maxPage);
end

--------------------------------------------------------------------

local ClassicTransmogFrame = CreateFrame("Frame", "ClassicTransmogFrame", UIParent,
	BackdropTemplateMixin and "BackdropTemplate")
-- register frame so it's closable
_G["MyFrame"] = ClassicTransmogFrame;
tinsert(UISpecialFrames, ClassicTransmogFrame:GetName());

ClassicTransmogFrame:SetPoint("CENTER")
ClassicTransmogFrame:SetSize(1050, 540)
ClassicTransmogFrame:EnableMouse(true)
ClassicTransmogFrame:SetMovable(true)
--ClassicTransmogFrame:SetClampedToScreen(true);
ClassicTransmogFrame:SetUserPlaced(true)
ClassicTransmogFrame:RegisterForDrag("LeftButton")
ClassicTransmogFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ClassicTransmogFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
ClassicTransmogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
ClassicTransmogFrame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 12,
	insets = { left = 6, right = 6, top = 6, bottom = 6 }
});
ClassicTransmogFrame:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.8);
ClassicTransmogFrame:SetBackdropColor(0.05, 0.05, 0.08, 0.95);

-- close
ClassicTransmogFrame.CloseButton = CreateFrame("Button", nil, ClassicTransmogFrame, "UIPanelCloseButton");
ClassicTransmogFrame.CloseButton:SetPoint("TOPRIGHT", ClassicTransmogFrame, "TOPRIGHT", -1, -1);
-- settings
ClassicTransmogFrame.SettingsButton = CreateFrame("Button", nil, ClassicTransmogFrame, "UIPanelButtonTemplate");
ClassicTransmogFrame.SettingsButton:SetSize(24, 24);
ClassicTransmogFrame.SettingsButton:SetPoint("RIGHT", ClassicTransmogFrame.CloseButton, "LEFT", -5, 0);
ClassicTransmogFrame.SettingsButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton-Up");
ClassicTransmogFrame.SettingsButton:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton-Down");
ClassicTransmogFrame.SettingsButton:HookScript("OnClick", function()
	InterfaceOptionsFrame_OpenToCategory(appName);
end)

-- title text
ClassicTransmogFrame.Title = ClassicTransmogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
ClassicTransmogFrame.Title:SetPoint("LEFT", ClassicTransmogFrame.SettingsButton, "RIGHT", 10, 2);
ClassicTransmogFrame.Title:SetPoint("RIGHT", ClassicTransmogFrame.CloseButton, "LEFT", -10, 0);
ClassicTransmogFrame.Title:SetText("AllTheMogs");

-- divider line under title bar
ClassicTransmogFrame.Divider = ClassicTransmogFrame:CreateTexture(nil, "OVERLAY");
ClassicTransmogFrame.Divider:SetHeight(2);
ClassicTransmogFrame.Divider:SetPoint("TOPLEFT", ClassicTransmogFrame, "TOPLEFT", 12, -40);
ClassicTransmogFrame.Divider:SetPoint("RIGHT", ClassicTransmogFrame.CloseButton, "LEFT", -12, 0);
ClassicTransmogFrame.Divider:SetColorTexture(ATM_BORDER[1], ATM_BORDER[2], ATM_BORDER[3], 0.6);

ClassicTransmogFrame:Hide();

-- content
local ContentFrame = CreateFrame("Frame", nil, ClassicTransmogFrame);
ContentFrame:SetSize(640, 480);
ContentFrame:SetPoint("LEFT");
ContentFrame:HookScript("OnMouseWheel", function(self, delta)
	if (delta == -1 and currentPage < maxPage) then
		currentPage = currentPage + 1;
		AppearanceModelFrame_LoadWithFilter();
	elseif (delta == 1 and currentPage > 1) then
		currentPage = currentPage - 1;
		AppearanceModelFrame_LoadWithFilter();
	end
end);

-- bottom

-- bottom pagination - anchored to ClassicTransmogFrame so they render above ScrollFrame
pageNext = CreateFrame("Button", nil, ClassicTransmogFrame);
pageNext:SetSize(32, 32);
pageNext:SetPoint("BOTTOMRIGHT", ClassicTransmogFrame, "BOTTOMRIGHT", -15, 10);
pageNext.bg = pageNext:CreateTexture(nil, "BACKGROUND");
pageNext.bg:SetAllPoints();
pageNext.bg:SetColorTexture(ATM_BG_MID[1], ATM_BG_MID[2], ATM_BG_MID[3], 0.8);
pageNext:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
pageNext:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
pageNext:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
pageNext:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
pageNext:HookScript("OnClick", function()
	if (currentPage < maxPage) then
		currentPage = currentPage + 1;
		AppearanceModelFrame_LoadWithFilter();
	end
end);

-- previous page
pagePrevious = CreateFrame("Button", nil, ClassicTransmogFrame);
pagePrevious:SetSize(32, 32);
pagePrevious:SetPoint("RIGHT", pageNext, "LEFT", -5, 0);
pagePrevious.bg = pagePrevious:CreateTexture(nil, "BACKGROUND");
pagePrevious.bg:SetAllPoints();
pagePrevious.bg:SetColorTexture(ATM_BG_MID[1], ATM_BG_MID[2], ATM_BG_MID[3], 0.8);
pagePrevious:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
pagePrevious:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
pagePrevious:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
pagePrevious:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
pagePrevious:HookScript("OnClick", function()
	if (currentPage > 1) then
		currentPage = currentPage - 1;
		AppearanceModelFrame_LoadWithFilter();
	end
end);

-- current page text - positioned BETWEEN prev and next buttons
pageText = ClassicTransmogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
pageText:SetPoint("CENTER", pagePrevious, "RIGHT", 8, 0);
pageText:SetPoint("CENTER", pageNext, "LEFT", -8, 0);

-- source filters
function CreateFilter(texture, parent, leftFrame, tooltip, func, label)
	local filterFrame = CreateFrame("Button", nil, parent);
	filterFrame:SetSize(32, 32);

	-- dark background
	filterFrame.bg = filterFrame:CreateTexture(nil, "BACKGROUND");
	filterFrame.bg:SetAllPoints();
	filterFrame.bg:SetColorTexture(0.12, 0.12, 0.18, 0.8);

	filterFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
	filterFrame:SetNormalAtlas(texture);
	filterFrame.checkButton = CreateFrame("CheckButton", nil, filterFrame);
	filterFrame.checkButton:SetPoint("BOTTOMRIGHT", filterFrame, "BOTTOMRIGHT", -2, 2);
	filterFrame.checkButton:SetSize(14, 14);
	filterFrame.checkButton:SetNormalAtlas("checkbox-minimal");
	filterFrame.checkButton:SetCheckedTexture("checkmark-minimal");
	filterFrame.checkButton:SetChecked(true);
	filterFrame.checkButton:HookScript("OnClick", func);
	filterFrame:HookScript("OnClick", function()
		filterFrame.checkButton:Click();
	end);
	filterFrame:HookScript("OnEnter", function(self)
		self.bg:SetColorTexture(0.2, 0.2, 0.3, 0.9);
		GameTooltip:SetOwner(filterFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText(tooltip);
		GameTooltip:Show();
	end);
	filterFrame:HookScript("OnLeave", function(self)
		self.bg:SetColorTexture(0.12, 0.12, 0.18, 0.8);
		GameTooltip:Hide();
	end);

	-- label below icon
	if label then
		filterFrame.label = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		filterFrame.label:SetPoint("BOTTOM", filterFrame, "TOP", 0, -2);
		filterFrame.label:SetText(label);
		filterFrame.label:SetScale(0.8);
	end

	return filterFrame;
end

-- rwp
local rwpFrame = CreateFilter("XMarksTheSpot", ContentFrame, nil, "Exclude items removed in Cataclysm (RWP)", function(self)
	app.filterRWP = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "RWP");
rwpFrame:SetPoint("BOTTOMLEFT", ContentFrame, "BOTTOMLEFT", 15, 10);
-- boe
local boeFrame = CreateFilter("Auctioneer", ContentFrame, rwpFrame, "Exclude Bind on Equip Items (B)", function(self)
	app.filterBOE = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "BoE");
boeFrame:SetPoint("LEFT", rwpFrame, "RIGHT", 8, 0);
-- pvp
local pvpFrame = CreateFilter("CrossedFlags", ContentFrame, boeFrame, "Exclude PvP Items (PvP)", function(self)
	app.filterPVP = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "PvP");
pvpFrame:SetPoint("LEFT", boeFrame, "RIGHT", 8, 0);
-- quest
local questFrame = CreateFilter("QuestNormal", ContentFrame, pvpFrame, "Exclude Quest rewards Items (Q)", function(self)
	app.filterQuest = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "Quest");
questFrame:SetPoint("LEFT", pvpFrame, "RIGHT", 8, 0);
-- craft
local craftFrame = CreateFilter("Profession", ContentFrame, questFrame, "Exclude Crafted Items (C)", function(self)
	app.filterCraft = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "Craft");
craftFrame:SetPoint("LEFT", questFrame, "RIGHT", 8, 0);
-- drop
local dropFrame = CreateFilter("DungeonSkull", ContentFrame, craftFrame, "Exclude Dropped Items (D)", function(self)
	app.filterDrop = self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end, "Drop");
dropFrame:SetPoint("LEFT", craftFrame, "RIGHT", 8, 0);

-- vertical divider between content and detail panel
local DividerLine = ClassicTransmogFrame:CreateTexture(nil, "OVERLAY");
DividerLine:SetSize(2, 480);
DividerLine:SetPoint("TOPLEFT", ContentFrame, "TOPRIGHT", 0, 0);
DividerLine:SetColorTexture(0.25, 0.25, 0.35, 0.6);

-- scroll region — uses ScrollFrameTemplate for native scrollbar UI
local ScrollFrame = CreateFrame("ScrollFrame", nil, ClassicTransmogFrame, "ScrollFrameTemplate")
ScrollFrame:SetSize(350, 480)
ScrollFrame:SetPoint("LEFT", ContentFrame, "RIGHT", 10, 0)
app.ScrollFrame = ScrollFrame; -- expose for AppearanceDetailFrame.lua

-- detail panel — sibling of ScrollFrame, anchored within its coordinate space
AppearanceDetailFrame = CreateFrame("Frame", "AppearanceDetailsFrame", ClassicTransmogFrame)
AppearanceDetailFrame:SetSize(320, 2000)
AppearanceDetailFrame:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 5, -5)

-- scroll region background (so detail panel has a visible container)
ScrollFrame.bg = ScrollFrame:CreateTexture(nil, "BACKGROUND");
ScrollFrame.bg:SetAllPoints();
ScrollFrame.bg:SetColorTexture(ATM_BG_DARK[1], ATM_BG_DARK[2], ATM_BG_DARK[3], 0.5);

-- manual scroll state
local scrollOffset = 0;
local scrollStep = 40; -- pixels per step (matches item height + gap)
local scrollMax = 0;   -- computed when items are loaded

ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
	if delta == -1 and scrollOffset < scrollMax then
		scrollOffset = math.min(scrollOffset + scrollStep * 3, scrollMax);
		AppearanceDetailFrame:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 5, -5 - scrollOffset);
	elseif delta == 1 and scrollOffset > 0 then
		scrollOffset = math.max(scrollOffset - scrollStep * 3, 0);
		AppearanceDetailFrame:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 5, -5 - scrollOffset);
	end
end);

-- sync native scrollbar dragging with manual scroll offset
local function OnScrollBarValueChanged(value)
	scrollOffset = math.floor(value);
	AppearanceDetailFrame:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 5, -5 - scrollOffset);
end
app.ScrollBar_OnValueChanged = OnScrollBarValueChanged; -- called from SetScrollVisible when scrollbar exists

-- show/hide scrollbar based on whether there's content to scroll
local function SetScrollVisible()
	if ScrollFrame and ScrollFrame.ScrollBar then
		-- count visible items
		local totalItems = 0;
		for i = 1, #AppearanceDetailFrame.items do
			if AppearanceDetailFrame.items[i]:IsVisible() then
				totalItems = i;
			end
		end
		local visibleItems = math.floor(480 / 40);
		if totalItems > visibleItems then
			scrollMax = math.ceil((totalItems - visibleItems) * 40);
			ScrollFrame.ScrollBar:SetMinMaxValues(0, scrollMax);
			ScrollFrame.ScrollBar:SetValue(scrollOffset);
			ScrollFrame.ScrollBar:Show();
			-- hook the scrollbar value changed script (only available when scrolling is needed)
			if not ScrollFrame.ScrollBar.__atm_scrolled_hooked then
				ScrollFrame.ScrollBar:HookScript("OnValueChanged", OnScrollBarValueChanged);
				ScrollFrame.ScrollBar.__atm_scrolled_hooked = true;
			end
		else
			ScrollFrame.ScrollBar:Hide();
			scrollMax = 0;
			scrollOffset = 0;
			AppearanceDetailFrame:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 5, -5);
		end
	end
end
app.SetScrollVisible = SetScrollVisible;
AppearanceDetailFrame_Init(AppearanceDetailFrame);

-- menu
local MenuFrame = CreateFrame("Frame", nil, ClassicTransmogFrame)
MenuFrame:SetSize(1000, 50)
MenuFrame:SetPoint("TOPLEFT", ClassicTransmogFrame, "TOPLEFT", 5, -5)

-- items number
local MenuTotal = MenuFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
MenuTotal:SetPoint("TOPRIGHT", MenuFrame, "TOPRIGHT", -10, -10);

-- build menu
CreateMenu(MenuFrame);

-- init appearances
AppearanceModelFrame_Init(ContentFrame);

-- init after player login event completed
local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:SetScript("OnEvent", function()
	-- init item cache
	local itemCache = CreateFrame("Frame");
	Mixin(itemCache, ItemCacheMixin);
	itemCache:OnLoad();
	itemCache:SetScript("OnEvent", itemCache.OnEvent);

	-- init interface options
	app.interfaceOptions = CreateFrame("Frame");
	Mixin(app.interfaceOptions, InterfaceOptionsMixin);
	app.interfaceOptions:OnLoad();

	InitializeMiniMapButton();
end);
