local appName, app = ...;
-- appearance details

local AppearanceDetailFrame;

function AppearanceDetailFrame_Init(parentFrame)
	AppearanceDetailFrame = parentFrame;

	AppearanceDetailFrame.text = AppearanceDetailFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText");
	AppearanceDetailFrame.text:SetPoint("TOP", AppearanceDetailFrame, "TOP", 0, -10);
	AppearanceDetailFrame.text:SetText("AppearanceDetailFrame_appearanceId");

	AppearanceDetailFrame.items = {};
	for i = 1, 10 do
		--AppearanceDetailItem_Get(i);
	end
end

function AppearanceDetailFrame_Load(appearanceId)
	AppearanceDetailFrame.text:SetText(appearanceId);
	AppearanceDetailItem_Reset();

	local listItems = app.ItemsByAppearances[appearanceId].i;

	local count = 1;
	for i = 1, #listItems do
		local itemId = listItems[i];
		local name = app.Items[itemId].n;
		local quality = app.Items[itemId].q;
		if filterGrey and quality <= 1 then
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
			item.itemLink = COLOR_STRINGS[quality] .. "\124Hitem:" ..
			itemId .. "::::::::80:::::\124h[" .. name .. "]\124h\124r";

			local text = GetItemText(itemId, filterSlot, parentSubclass);
			item.text:SetText(text);
			item:Show();

			count = count + 1;
		end
	end
end

-- get or create a detail
function AppearanceDetailItem_Get(num)
	local item = AppearanceDetailFrame.items[num];
	if item == nil then
		AppearanceDetailFrame.items[num] = CreateFrame("Frame", "ItemDetail" .. num, AppearanceDetailFrame);
		item = AppearanceDetailFrame.items[num];
		item:SetPoint("TOP", AppearanceDetailFrame, "TOP", 0, -20 * (num + 1));
		item:SetSize(300, 20);

		--item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");

		item.text = item:CreateFontString(nil, "OVERLAY", "GameTooltipText");
		item.text:SetPoint("CENTER");
		item.text:SetText("AppearanceDetailFrame_itemId" .. num);

		item:SetHyperlinksEnabled(true)
		item:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

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
