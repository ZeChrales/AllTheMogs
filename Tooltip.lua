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
	if Items[itemId] then
		local appearanceId = Items[itemId].a;
		local parentSlot = typesToSlots[Items[itemId].t];
		local parentSubclass;
		-- armor
		if parentSlot >= 1 and parentSlot <= 12 then
			parentSubclass = Items[itemId].s;
		-- weapon
		elseif parentSlot == 14 then
			parentSubclass = typesToWeaponSubclasses[Items[itemId].s];
		-- offhand
		elseif parentSlot == 16 then
			parentSubclass = typesToOffhandSubclasses[Items[itemId].s];
		end

		local listItems = ItemsByAppearances[appearanceId].i;

		-- add lines
		tooltip:AddLine();
		if #listItems == 1 then
			tooltip:AddLine("\124cFFFF8000Unique\124r Appearance : ");
		else
			tooltip:AddLine("Shared Appearances : ");
		end

		for i=1, #listItems do
			local sharedItemId = listItems[i];
			local quality = Items[sharedItemId].q;
			if filterGrey and quality <= 1 then
				-- filter grey
			else
				local text = GetItemText(sharedItemId, parentSlot, parentSubclass);

				-- completed state
				local check = "\124T".."Interface\\\AddOns\\AllTheThings\\assets\\unknown"..":0\124t";
				if Items[sharedItemId].collected or (ItemCache[sharedItemId] and ItemCache[sharedItemId].c) then
					check = "\124T".."Interface\\\AddOns\\AllTheThings\\assets\\known_circle"..":0\124t";
				end

				-- display item name + att infos
				tooltip:AddDoubleLine("  "..text, check);
			end
		end

		tooltip:Show();
	end
end

-- hook tooltip only on classic
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
	GameTooltip:HookScript("OnTooltipSetItem", ShowAppearances);
end
