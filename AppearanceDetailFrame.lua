local appName, app = ...;
-- appearance details

local AppearanceDetailFrame;

function AppearanceDetailFrame_Init(parentFrame)
	AppearanceDetailFrame = parentFrame;

	AppearanceDetailFrame.text = AppearanceDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	AppearanceDetailFrame.text:SetPoint("TOPLEFT", AppearanceDetailFrame, "TOPLEFT", 10, -10);
	AppearanceDetailFrame.text:SetPoint("RIGHT", AppearanceDetailFrame, "RIGHT", -10, 0);
	AppearanceDetailFrame.text:SetJustifyH("CENTER");
	AppearanceDetailFrame.text:SetText("");
	AppearanceDetailFrame.text:Hide();

	AppearanceDetailFrame.items = {};
	for i = 1, 10 do
		--AppearanceDetailItem_Get(i);
	end
end

function AppearanceDetailFrame_Load(appearanceId)
	-- show detail panel
	AppearanceDetailFrame:Show();
	app.ScrollFrame:Show();
	scrollOffset = 0; -- reset scroll when loading new appearance
	AppearanceDetailFrame:SetPoint("TOPLEFT", app.ScrollFrame, "TOPLEFT", 5, -5);
	AppearanceDetailFrame.text:SetText(appearanceId);
	AppearanceDetailFrame.text:Show();

	-- safety check — appearance may not exist in data yet
	local appearance = app.ItemsByAppearances[appearanceId];
	if not appearance or not appearance.i then
		return;
	end

	-- hide any previously shown items
	for i = 1, #AppearanceDetailFrame.items do
		local item = AppearanceDetailFrame.items[i];
		item:Hide();
	end

	local listItems = appearance.i;
	local count = 1;
	for i = 1, #listItems do
		local itemId = listItems[i];
		local name = app.Items[itemId].n;
		local quality = app.Items[itemId].q;
		if app.filterGrey and quality <= 1 then
			-- grey filter
		else
			local parentSubclass;
			-- armor
			if filterSlot >= 1 and filterSlot <= 12 then
				parentSubclass = filterArmorType;
				-- weapon
			elseif filterSlot == 14 then
				parentSubclass = filterWeaponType;
				-- offhand
			elseif filterSlot == 16 then
				parentSubclass = filterOffhandType;
			end

			local item = AppearanceDetailItem_Get(count);
			
			item.itemLink = app.COLOR_STRINGS[quality] .. "\124Hitem:" ..
			itemId .. "::::::::80:::::\124h[" .. name .. "]\124h\124r";

			local text = GetItemText(itemId, filterSlot, parentSubclass);
			item.text:SetText(text);
			local check = "\124T" .. "Interface\\AddOns\\AllTheThings\\assets\\unknown" .. ":0\124t";
			if app.Items[itemId].collected or ATM_ItemCache[itemId] then
				check = "\124T" .. "Interface\\AddOns\\AllTheThings\\assets\\known_circle" .. ":0\124t";
			end
			item.collected:SetText(check);
			item:Show();

			count = count + 1;
		end
	end

	-- update scrollbar visibility
	if app.SetScrollVisible then
		app.SetScrollVisible();
	end
end

-- get or create a detail
function AppearanceDetailItem_Get(num)
	local item = AppearanceDetailFrame.items[num];
	if item == nil then
		AppearanceDetailFrame.items[num] = CreateFrame("Frame", "ItemDetail" .. num, AppearanceDetailFrame);
		item = AppearanceDetailFrame.items[num];
		if num == 1 then
			item:SetPoint("TOPLEFT", AppearanceDetailFrame, "TOPLEFT", 10, -10);
			item:SetPoint("RIGHT", AppearanceDetailFrame, "RIGHT", -10, 0);
		else
			item:SetPoint("TOPLEFT", AppearanceDetailFrame.items[num - 1], "BOTTOMLEFT", 0, -8);
			item:SetPoint("RIGHT", AppearanceDetailFrame.items[num - 1], "BOTTOMRIGHT", 0, -8);
		end
		item:SetSize(320, 32);
		item:EnableMouse(true);

		-- card background
		item.bg = item:CreateTexture(nil, "BACKGROUND");
		item.bg:SetAllPoints();
		item.bg:SetColorTexture(0.1, 0.1, 0.15, 0.6);

		-- highlight (always present for hover feedback)
		item.highlight = item:CreateTexture(nil, "HIGHLIGHT");
		item.highlight:SetAllPoints();
		item.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		item.highlight:SetBlendMode("ADD");
		item.highlight:SetColorTexture(0.2, 0.2, 0.3, 0.4);
		item.highlight:Hide();

		-- hover effects — frame-level tooltip (hyperlinks don't trigger OnEnter)
		item:SetScript("OnEnter", function(self)
			self.bg:SetColorTexture(0.15, 0.15, 0.22, 0.8);
			self.highlight:Show();
			if self.itemLink then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip:SetHyperlink(self.itemLink);
				GameTooltip:Show();
			end
		end);
		item:SetScript("OnLeave", function(self)
			self.bg:SetColorTexture(0.1, 0.1, 0.15, 0.6);
			self.highlight:Hide();
			GameTooltip:Hide();
		end);

		item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		item.text:SetPoint("CENTER");
		item.text:SetText("AppearanceDetailFrame_itemId" .. num);
		item.text:SetTextColor(1, 1, 1);

		item.collected = item:CreateFontString(nil, "OVERLAY", "GameTooltipText");
		item.collected:SetPoint("RIGHT");
		item.collected:SetSize(16, 16);

		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
			item:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
		else
			item:SetScript("OnHyperlinkClick", function(self, link, text)
				ChatFrame_OnHyperlinkClick(self, link, text)
			end)
		end

		item:HookScript("OnHyperlinkEnter", function()
			GameTooltip:SetOwner(item, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(item.itemLink);
			GameTooltip:Show();
		end);
		item:HookScript("OnHyperlinkLeave", function()
			GameTooltip:Hide();
		end);
	end

	return item;
end

function AppearanceDetailItem_Reset()
	for i = 1, #AppearanceDetailFrame.items do
		local item = AppearanceDetailFrame.items[i];
		item:Hide();
	end
end
