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

local completedFrame = CreateFrame("CheckButton", nil, ContentFrame);
--completedFrame:SetNormalTexture();

local rwpFrame = CreateFrame("Button", nil, ContentFrame);
rwpFrame:SetPoint("BOTTOMLEFT", ContentFrame, "BOTTOMLEFT", 5, -5);
rwpFrame:SetSize(28, 28);
rwpFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
rwpFrame:SetNormalAtlas("XMarksTheSpot");
rwpFrame.checkButton = CreateFrame("CheckButton", nil, rwpFrame);
rwpFrame.checkButton:SetPoint("BOTTOMRIGHT", rwpFrame, "BOTTOMRIGHT");
rwpFrame.checkButton:SetSize(15, 14);
rwpFrame.checkButton:SetNormalAtlas("checkbox-minimal");
rwpFrame.checkButton:SetCheckedTexture("checkmark-minimal");
rwpFrame.checkButton:SetChecked(true);
rwpFrame.checkButton:HookScript("OnClick", function()
	app.filterRWP = not rwpFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
rwpFrame:HookScript("OnClick", function()
	rwpFrame.checkButton:Click();
end);

local boeFrame = CreateFrame("Button", nil, ContentFrame);
boeFrame:SetPoint("LEFT", rwpFrame, "RIGHT", 5, 0);
boeFrame:SetSize(28, 28);
boeFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
boeFrame:SetNormalAtlas("Auctioneer");
boeFrame.checkButton = CreateFrame("CheckButton", nil, boeFrame);
boeFrame.checkButton:SetPoint("BOTTOMRIGHT", boeFrame, "BOTTOMRIGHT");
boeFrame.checkButton:SetSize(15, 14);
boeFrame.checkButton:SetNormalAtlas("checkbox-minimal");
boeFrame.checkButton:SetCheckedTexture("checkmark-minimal");
boeFrame.checkButton:SetChecked(true);
boeFrame.checkButton:HookScript("OnClick", function()
	app.filterBOE = not boeFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
boeFrame:HookScript("OnClick", function()
	boeFrame.checkButton:Click();
end);

local pvpFrame = CreateFrame("Button", nil, ContentFrame);
pvpFrame:SetPoint("LEFT", boeFrame, "RIGHT", 5, 0);
pvpFrame:SetSize(28, 28);
pvpFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
pvpFrame:SetNormalAtlas("CrossedFlags");
pvpFrame.checkButton = CreateFrame("CheckButton", nil, pvpFrame);
pvpFrame.checkButton:SetPoint("BOTTOMRIGHT", pvpFrame, "BOTTOMRIGHT");
pvpFrame.checkButton:SetSize(15, 14);
pvpFrame.checkButton:SetNormalAtlas("checkbox-minimal");
pvpFrame.checkButton:SetCheckedTexture("checkmark-minimal");
pvpFrame.checkButton:SetChecked(true);
pvpFrame.checkButton:HookScript("OnClick", function()
	app.filterPVP = not pvpFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
pvpFrame:HookScript("OnClick", function()
	pvpFrame.checkButton:Click();
end);

local questFrame = CreateFrame("Button", nil, ContentFrame);
questFrame:SetPoint("LEFT", pvpFrame, "RIGHT", 5, 0);
questFrame:SetSize(28, 28);
questFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
questFrame:SetNormalAtlas("QuestNormal");
questFrame.checkButton = CreateFrame("CheckButton", nil, questFrame);
questFrame.checkButton:SetPoint("BOTTOMRIGHT", questFrame, "BOTTOMRIGHT");
questFrame.checkButton:SetSize(15, 14);
questFrame.checkButton:SetNormalAtlas("checkbox-minimal");
questFrame.checkButton:SetCheckedTexture("checkmark-minimal");
questFrame.checkButton:SetChecked(true);
questFrame.checkButton:HookScript("OnClick", function()
	app.filterQuest = not questFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
questFrame:HookScript("OnClick", function()
	questFrame.checkButton:Click();
end);

local craftFrame = CreateFrame("Button", nil, ContentFrame);
craftFrame:SetPoint("LEFT", questFrame, "RIGHT", 5, 0);
craftFrame:SetSize(28, 28);
craftFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
craftFrame:SetNormalAtlas("Profession");
craftFrame.checkButton = CreateFrame("CheckButton", nil, craftFrame);
craftFrame.checkButton:SetPoint("BOTTOMRIGHT", craftFrame, "BOTTOMRIGHT");
craftFrame.checkButton:SetSize(15, 14);
craftFrame.checkButton:SetNormalAtlas("checkbox-minimal");
craftFrame.checkButton:SetCheckedTexture("checkmark-minimal");
craftFrame.checkButton:SetChecked(true);
craftFrame.checkButton:HookScript("OnClick", function()
	app.filterCraft = not craftFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
craftFrame:HookScript("OnClick", function()
	craftFrame.checkButton:Click();
end);

local dropFrame = CreateFrame("Button", nil, ContentFrame);
dropFrame:SetPoint("LEFT", craftFrame, "RIGHT", 5, 0);
dropFrame:SetSize(28, 28);
dropFrame:SetNormalTexture("Interface\\Minimap\\objecticonsatlas");
dropFrame:SetNormalAtlas("DungeonSkull");
dropFrame.checkButton = CreateFrame("CheckButton", nil, dropFrame);
dropFrame.checkButton:SetPoint("BOTTOMRIGHT", dropFrame, "BOTTOMRIGHT");
dropFrame.checkButton:SetSize(15, 14);
dropFrame.checkButton:SetNormalAtlas("checkbox-minimal");
dropFrame.checkButton:SetCheckedTexture("checkmark-minimal");
dropFrame.checkButton:SetChecked(true);
dropFrame.checkButton:HookScript("OnClick", function()
	app.filterDrop = not dropFrame.checkButton:GetChecked();
	AppearanceModelFrame_LoadWithFilter();
end);
dropFrame:HookScript("OnClick", function()
	dropFrame.checkButton:Click();
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

	app.minimapButton:update();
	app.minimapButton:Show();
end)

print("AllTheMogs loaded !")
