local appName, app = ...;
-- adapted from WardrobeItemsCollectionMixin:CreateSlotButtons in Blizzard_Wardrobe.lua
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0");
local spacingNoSmallButton = 2;
local defaultSectionSpacing = 24;
local xOffset = spacingNoSmallButton;
local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist",
	"legs", "feet", defaultSectionSpacing, "mainhand", defaultSectionSpacing, "secondaryhand" };

typesToSlots = {
	[0] = 1,
	[1] = 2,
	[9] = 3,
	[3] = 4,
	[2] = 5,
	[10] = 6,
	[7] = 7,
	[8] = 9,
	[4] = 10,
	[5] = 11,
	[6] = 12,
	[11] = 14,
	[12] = 14,
	[13] = 16,
	[15] = 16
};

filters = {
	-- head
	[1] = { ["Type"] = 0, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- shoulder
	[2] = { ["Type"] = 1, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- back
	[3] = { ["Type"] = 9, ["Subclasses"] = { 1 } },
	-- chest
	[4] = { ["Type"] = 3, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- shirt
	[5] = { ["Type"] = 2, ["Subclasses"] = { 1 } },
	-- tabard
	[6] = { ["Type"] = 10, ["Subclasses"] = { 0 } },
	-- wrist
	[7] = { ["Type"] = 7, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- hands
	[9] = { ["Type"] = 8, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- waist
	[10] = { ["Type"] = 4, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- legs
	[11] = { ["Type"] = 5, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- feet
	[12] = { ["Type"] = 6, ["Subclasses"] = { 1, 2, 3, 4 } },
	-- one-hand
	[14] = { { ["Type"] = 11, ["Subclasses"] = { 0, 1, 4, 5, 6, 7, 8, 10, 13, 15, 20 } },
		-- ranged
		{ ["Type"] = 12, ["Subclasses"] = { 2, 3, 16, 18, 19 } } },
	-- shield
	[16] = { { ["Type"] = 13, ["Subclasses"] = { 6 } },
		-- offhands
		{ ["Type"] = 15, ["Subclasses"] = { 0 } } },
};

armorType = { "Cloth", "Leather", "Mail", "Plate" };
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	armorType = { "Cloth", "Leather", "Mail", "Plate", "Cosmetic" };
end

typesToWeaponSubclasses = {
	[0] = 1,
	[7] = 2,
	[4] = 3,
	[1] = 4,
	[8] = 5,
	[5] = 6,
	[10] = 7,
	[6] = 8,
	[13] = 9,
	[15] = 10,
	[2] = 11,
	[3] = 12,
	[16] = 13,
	[18] = 14,
	[19] = 15,
	[20] = 16
};

weaponType = {
	[1] = { type = 0, name = "One-Hand Axes" },
	[2] = { type = 7, name = "One-Handed Swords" },
	[3] = { type = 4, name = "One-Handed Maces" },
	[4] = { type = 1, name = "Two-Handed Axes" },
	[5] = { type = 8, name = "Two-Handed Swords" },
	[6] = { type = 5, name = "Two-Handed Maces" },
	[7] = { type = 10, name = "Staves" },
	[8] = { type = 6, name = "Polearms" },
	[9] = { type = 13, name = "Fist Weapons" },
	[10] = { type = 15, name = "Daggers" },
	-- ranged
	[11] = { type = 2, name = "Bows" },
	[12] = { type = 3, name = "Guns" },
	[13] = { type = 16, name = "Throwns" },
	[14] = { type = 18, name = "Crossbows" },
	[15] = { type = 19, name = "Wands" },
	-- bonus poles
	[16] = { type = 20, name = "Fishing Poles" },
};

typesToOffhandSubclasses = {
	[6] = 1,
	[0] = 2
};

offhandType = {
	[1] = { type = 6, name = "Shields" },
	[2] = { type = 0, name = "Held In Off-hand" },
};

-- build Menu Buttons
function CreateMenu(parentFrame)
	local lastButton;

	-- create item slots buttons
	for i = 1, #slots do
		local value = tonumber(slots[i]);
		if (value) then
			-- this is a spacer
			xOffset = value;
		else
			local menuButton = CreateFrame("Button", "MenuButton" .. i, parentFrame);
			if lastButton then
				menuButton:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				menuButton:SetPoint("TOPLEFT");
			end
			lastButton = menuButton;
			xOffset = spacingNoSmallButton;
			menuButton:SetSize(31, 31)
			menuButton.icon = menuButton:CreateTexture(nil, "ARTWORK")
			menuButton.icon:SetPoint("CENTER")
			menuButton.icon:SetSize(31, 31)
			menuButton.icon:SetTexture("Interface\\Transmogrify\\Transmogrify")
			menuButton.icon:SetAtlas("transmog-nav-slot-" .. slots[i])
			menuButton.highlight = menuButton:CreateTexture(nil, "ARTWORK")
			menuButton.highlight:SetPoint("CENTER")
			menuButton.highlight:SetSize(31, 31)
			menuButton.highlight:SetTexture("Interface\\Transmogrify\\Transmogrify")
			menuButton.highlight:SetAtlas("bags-roundhighlight")
			menuButton.highlight:Hide()

			menuButton:HookScript("OnEnter", function()
				if filterSlot ~= i then
					--highlight
					menuButton.highlight:Show()
				end
			end)
			menuButton:HookScript("OnLeave", function()
				if filterSlot ~= i then
					--highlight
					menuButton.highlight:Hide()
				end
			end)

			menuButton:HookScript("OnClick", function()
				if filterSlot ~= i then
					--refresh
					filterSlot = i;
					currentPage = 1;

					local type = filters[i]["Type"];
					local subclass = 1;
					-- for shirt or tabard or back
					if filterSlot == 3 or filterSlot == 5 or filterSlot == 6 then
						subclass = filters[i]["Subclasses"][1];
						-- armor
					elseif filterSlot >= 1 and filterSlot <= 12 then
						subclass = filters[i]["Subclasses"][filterArmorType];
						-- weapon
					elseif filterSlot == 14 then
						type = filters[i][1]["Type"];
						subclass = filters[i][1]["Subclasses"][filterWeaponType];
						-- offhand
					elseif filterSlot == 16 then
						type = filters[i][1]["Type"];
						subclass = filters[i][1]["Subclasses"][filterOffhandType];
					end
					AppearanceModelFrame_LoadWithFilter(type, subclass, currentPage);

					-- display associated dropdown
					dropDownArmorType:Hide();
					dropDownWeaponType:Hide();
					dropDownOffhandType:Hide();
					-- armor
					if filterSlot == 1 or filterSlot == 2 or filterSlot == 4 or filterSlot == 7 or filterSlot == 9 or filterSlot == 10 or filterSlot == 11 or filterSlot == 12 then
						dropDownArmorType:Show();
						-- weapon
					elseif filterSlot == 14 then
						dropDownWeaponType:Show();
						-- offhand
					elseif filterSlot == 16 then
						dropDownOffhandType:Show();
					end
				end
			end)
		end
	end

	dropDownArmorType = LibDD:Create_UIDropDownMenu("DromDownArmorType", parentFrame);
	dropDownArmorType:SetPoint("LEFT", lastButton, "RIGHT", 5, 0);
	LibDD:UIDropDownMenu_SetWidth(dropDownArmorType, 75);
	dropDownArmorType.initialize = function(dropDownArmorType)
		for i = 1, #armorType do
			local type = armorType[i];
			local info = LibDD:UIDropDownMenu_CreateInfo();
			info.text = type;
			info.value = i;
			info.func = function(self)
				filterArmorType = self.value;
				currentPage = 1;
				LibDD:UIDropDownMenu_SetSelectedValue(dropDownArmorType, filterArmorType);
				AppearanceModelFrame_LoadWithFilter(1);
			end
			LibDD:UIDropDownMenu_AddButton(info);
		end
		LibDD:UIDropDownMenu_SetSelectedValue(dropDownArmorType, filterArmorType or 1);
	end
	dropDownArmorType:HookScript("OnShow", dropDownArmorType.initialize);

	dropDownWeaponType = LibDD:Create_UIDropDownMenu("DromDownWeaponType", parentFrame);
	dropDownWeaponType:SetPoint("LEFT", lastButton, "RIGHT", 5, 0);
	LibDD:UIDropDownMenu_SetWidth(dropDownWeaponType, 150);
	dropDownWeaponType.initialize = function(dropDownWeaponType)
		for i = 1, #weaponType do
			local info = LibDD:UIDropDownMenu_CreateInfo();
			info.text = weaponType[i].name;
			info.value = weaponType[i].type;
			info.func = function(self)
				filterWeaponType = self.value;
				currentPage = 1;
				LibDD:UIDropDownMenu_SetSelectedValue(dropDownWeaponType, filterWeaponType);
				AppearanceModelFrame_LoadWithFilter();
			end
			LibDD:UIDropDownMenu_AddButton(info);
		end
		LibDD:UIDropDownMenu_SetSelectedValue(dropDownWeaponType, filterWeaponType or 0);
	end
	dropDownWeaponType:HookScript("OnShow", dropDownWeaponType.initialize);
	dropDownWeaponType:Hide();

	dropDownOffhandType = LibDD:Create_UIDropDownMenu("DromDownOffhandType", parentFrame);
	dropDownOffhandType:SetPoint("LEFT", lastButton, "RIGHT", 5, 0);
	LibDD:UIDropDownMenu_SetWidth(dropDownOffhandType, 125);
	dropDownOffhandType.initialize = function(dropDownOffhandType)
		for i = 1, #offhandType do
			local info = LibDD:UIDropDownMenu_CreateInfo();
			info.text = offhandType[i].name;
			info.value = offhandType[i].type;
			info.func = function(self)
				filterOffhandType = self.value;
				currentPage = 1;
				LibDD:UIDropDownMenu_SetSelectedValue(dropDownOffhandType, filterOffhandType);
				AppearanceModelFrame_LoadWithFilter();
			end
			LibDD:UIDropDownMenu_AddButton(info);
		end
		LibDD:UIDropDownMenu_SetSelectedValue(dropDownOffhandType, filterOffhandType or 6);
	end
	dropDownOffhandType:HookScript("OnShow", dropDownOffhandType.initialize);
	dropDownOffhandType:Hide();
end
