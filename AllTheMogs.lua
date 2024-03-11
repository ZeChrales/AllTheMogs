local appName, app = ...;

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

--------------------------------------------------------------------

local ClassicTransmogFrame = CreateFrame("Frame", "ClassicTransmogFrame", UIParent,
	BackdropTemplateMixin and "BackdropTemplate")
-- register frame so it's closable
_G["MyFrame"] = ClassicTransmogFrame;
tinsert(UISpecialFrames, ClassicTransmogFrame:GetName());

ClassicTransmogFrame:SetPoint("CENTER")
ClassicTransmogFrame:SetSize(900, 500)
ClassicTransmogFrame:EnableMouse(true)
ClassicTransmogFrame:SetMovable(true)
--ClassicTransmogFrame:SetClampedToScreen(true);
ClassicTransmogFrame:SetUserPlaced(true)
ClassicTransmogFrame:RegisterForDrag("LeftButton")
ClassicTransmogFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ClassicTransmogFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
ClassicTransmogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
ClassicTransmogFrame:SetBackdrop({
	bgFile = "Interface\\Collections\\CollectionsBackgroundTile",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
--ClassicTransmogFrame:SetBackdropBorderColor(1, 1, 1, 1);
--ClassicTransmogFrame:SetBackdropColor(0, 0, 0, 1);

-- close
ClassicTransmogFrame.CloseButton = CreateFrame("Button", nil, ClassicTransmogFrame, "UIPanelCloseButton");
ClassicTransmogFrame.CloseButton:SetPoint("TOPRIGHT", ClassicTransmogFrame, "TOPRIGHT", -1, -1);
-- settings
ClassicTransmogFrame.SettingsButton = CreateFrame("Button", nil, ClassicTransmogFrame, "UIPanelButtonTemplate");
ClassicTransmogFrame.SettingsButton:SetSize(24, 24);
ClassicTransmogFrame.SettingsButton:SetPoint("RIGHT", ClassicTransmogFrame.CloseButton, "LEFT", -5, 0);
ClassicTransmogFrame.SettingsButton:SetNormalTexture("Interface\\QuestFrame\\WorldQuest");
ClassicTransmogFrame.SettingsButton:SetNormalAtlas("worldquest-icon-engineering");
ClassicTransmogFrame.SettingsButton:HookScript("OnClick", function()
	InterfaceOptionsFrame_OpenToCategory(appName);
end)

ClassicTransmogFrame:Hide();

-- content
local ContentFrame = CreateFrame("Frame", nil, ClassicTransmogFrame);
ContentFrame:SetSize(500, 470);
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

-- next page
pageNext = CreateFrame("Button", nil, ContentFrame);
pageNext:SetSize(32, 32);
pageNext:SetPoint("BOTTOMRIGHT", ContentFrame, "BOTTOMRIGHT", 5, 0);
pageNext:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
pageNext:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
pageNext:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
pageNext:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
pageNext:SetHighlightAtlas("ADD");
pageNext:HookScript("OnClick", function()
	if (currentPage < maxPage) then
		currentPage = currentPage + 1;
		AppearanceModelFrame_LoadWithFilter();
	end
end);

-- previous page
pagePrevious = CreateFrame("Button", nil, ContentFrame);
pagePrevious:SetSize(32, 32);
pagePrevious:SetPoint("RIGHT", pageNext, "LEFT", 5, 0);
pagePrevious:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
pagePrevious:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
pagePrevious:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
pagePrevious:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
pagePrevious:SetHighlightAtlas("ADD");
pagePrevious:HookScript("OnClick", function()
	if (currentPage > 1) then
		currentPage = currentPage - 1;
		AppearanceModelFrame_LoadWithFilter();
	end
end);

-- current page
pageText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText");
pageText:SetPoint("RIGHT", pagePrevious, "LEFT", -5, 0);
pageText:SetText(currentPage .. "/x");

-- source filters
function CreateFilter(texture, parent, leftFrame, tooltip, func)
	local filterFrame = CreateFrame("Button", nil, parent);
	if leftFrame then
		filterFrame:SetPoint("LEFT", leftFrame, "RIGHT", 5, 0);
	else
		filterFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 5, -5);
	end
	filterFrame:SetSize(28, 28);
	filterFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
	filterFrame:SetNormalAtlas(texture);
	filterFrame.checkButton = CreateFrame("CheckButton", nil, filterFrame);
	filterFrame.checkButton:SetPoint("BOTTOMRIGHT", filterFrame, "BOTTOMRIGHT");
	filterFrame.checkButton:SetSize(15, 14);
	filterFrame.checkButton:SetNormalAtlas("checkbox-minimal");
	filterFrame.checkButton:SetCheckedTexture("checkmark-minimal");
	filterFrame.checkButton:SetChecked(true);
	filterFrame.checkButton:HookScript("OnClick", func);
	filterFrame:HookScript("OnClick", function()
		filterFrame.checkButton:Click();
	end);
	filterFrame:HookScript("OnEnter", function()
		GameTooltip:SetOwner(filterFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText(tooltip);
		GameTooltip:Show();
	end);
	filterFrame:HookScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	return filterFrame;
end

-- rwp
local rwpFrame = CreateFilter("XMarksTheSpot", ContentFrame, nil, "Items removed in Cataclysm (RWP)", function(self)
	app.filterRWP = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);
-- boe
local boeFrame = CreateFilter("Auctioneer", ContentFrame, rwpFrame, "Bind on Equip Items (B)", function(self)
	app.filterBOE = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);
-- pvp
local pvpFrame = CreateFilter("CrossedFlags", ContentFrame, boeFrame, "PvP Items (PvP)", function(self)
	app.filterPVP = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);
-- quest
local questFrame = CreateFilter("QuestNormal", ContentFrame, pvpFrame, "Quest rewards Items (Q)", function(self)
	app.filterQuest = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);
-- quest
local craftFrame = CreateFilter("Profession", ContentFrame, questFrame, "Crafted Items (C)", function(self)
	app.filterCraft = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);
-- quest
local dropFrame = CreateFilter("DungeonSkull", ContentFrame, craftFrame, "Dropped Items (D)", function(self)
	app.filterDrop = not self:GetChecked();
	currentPage = 1;
	AppearanceModelFrame_LoadWithFilter();
end);

-- details

-- scroll
local ScrollFrame = CreateFrame("ScrollFrame", nil, ClassicTransmogFrame, "ScrollFrameTemplate")
ScrollFrame:SetSize(350, 430)
ScrollFrame:SetPoint("LEFT", ContentFrame, "RIGHT", 0, 0)
-- details
AppearanceDetailFrame = CreateFrame("Frame", "AppearanceDetailsFrame", ClassicTransmogFrame)
AppearanceDetailFrame:SetSize(350, 2000)
AppearanceDetailFrame:SetPoint("LEFT", ContentFrame, "RIGHT", 50, 0)
ScrollFrame:SetScrollChild(AppearanceDetailFrame)
AppearanceDetailFrame_Init(AppearanceDetailFrame);

-- menu
local MenuFrame = CreateFrame("Frame", nil, ClassicTransmogFrame)
MenuFrame:SetSize(850, 50)
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
end)

print("AllTheMogs loaded !")
