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
local ContentFrame = CreateFrame("Frame", nil, ClassicTransmogFrame)
ContentFrame:SetSize(500, 470)
ContentFrame:SetPoint("LEFT")

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
end)

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
end)

-- current page
pageText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText");
pageText:SetPoint("RIGHT", pagePrevious, "LEFT", -5, 0);
pageText:SetText(currentPage .. "/x");

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


--local count = 0
--local pos = 0
--for i=1, 10000, 1 do
--	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(i)

--	-- only existing id
--	-- either type Weapon or Armor
--	if itemName and (itemType == "Weapon" or itemType == "Armor") then
--		local but = CreateFrame("Button", nil, ContentFrame, "ItemButtonTemplate");
--		but:SetPoint("TOPLEFT", ContentFrame, "TOPLEFT", 5, -pos);
--		pos = pos + 50
--		but:SetSize(50, 50);
--		but:SetNormalTexture(itemTexture)

--		but:HookScript("OnEnter", function()
--			GameTooltip:SetOwner(ClassicTransmogFrame, "ANCHOR_BOTTOMRIGHT")
--			GameTooltip:SetHyperlink(itemLink)
--			GameTooltip:Show()
--		end)
--		but:HookScript("OnLeave", function()
--			GameTooltip:Hide()
--		end)

--		count = count + 1
--	end
--end
--print(count)

-- atlas loot button
--local atlasButton = AtlasLoot.Button:Create()
--atlasButton:SetPoint("LEFT", fs, "RIGHT", 5 + x, 0);
--x = x + 200
--atlasButton:SetContentTable({ 1, itemId })

print("AllTheMogs loaded !")
