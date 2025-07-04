local appName, app = ...;
-- hook gametooltip and add appearances info

-- display tooltip lines
local function ShowAppearances(tooltip)
	InitDatabase();

	tooltip = tooltip or GameTooltip;
	-- get item and ignore others
	local itemName, itemLink = tooltip:GetItem();
	if not itemLink then
		return;
	end
	local itemId = GetItemInfoFromHyperlink(itemLink);
	-- ignore munitions
	if app.Items[itemId] and app.Items[itemId].t ~= 14 then
		local appearanceId = app.Items[itemId].a;
		local parentSlot = typesToSlots[app.Items[itemId].t];
		local parentSubclass;
		-- armor
		if parentSlot >= 1 and parentSlot <= 12 then
			parentSubclass = app.Items[itemId].s;
			-- weapon
		elseif parentSlot == 14 then
			parentSubclass = typesToWeaponSubclasses[app.Items[itemId].s];
			-- offhand
		elseif parentSlot == 16 then
			parentSubclass = typesToOffhandSubclasses[app.Items[itemId].s];
		end

		local listItems = app.ItemsByAppearances[appearanceId].i;

		-- add lines
		tooltip:AddLine();
		if #listItems == 1 then
			tooltip:AddLine("\124cFFFF8000Unique\124r Appearance : ");
		else
			tooltip:AddLine("Shared Appearances : ");
		end

		for i = 1, #listItems do
			local sharedItemId = listItems[i];
			local quality = app.Items[sharedItemId].q;
			if app.filterGrey and quality <= 1 then
				-- filter grey
			else
				local text = GetItemText(sharedItemId, parentSlot, parentSubclass);

				-- completed state
				local check = "\124T" .. "Interface\\AddOns\\AllTheThings\\assets\\unknown" .. ":0\124t";
				if app.Items[sharedItemId].collected or ATM_ItemCache[sharedItemId] then
					check = "\124T" .. "Interface\\AddOns\\AllTheThings\\assets\\known_circle" .. ":0\124t";
				end

				-- display item name + att infos
				tooltip:AddDoubleLine("  " .. text, check);
			end
		end

		tooltip:Show();
	end
end

-- hook tooltip only before cataclysm
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and WOW_PROJECT_ID ~= WOW_PROJECT_CATACLYSM_CLASSIC and WOW_PROJECT_ID ~= WOW_PROJECT_MISTS_CLASSIC then
	GameTooltip:HookScript("OnTooltipSetItem", ShowAppearances);
	ItemRefTooltip:HookScript("OnTooltipSetItem", ShowAppearances);
end
