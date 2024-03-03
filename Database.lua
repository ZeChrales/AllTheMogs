local appName, app = ...;
-- database

app.databaseLoaded = false;

-- for each item in the database, get info from ATT and update item + appearance
function InitDatabase()
	-- AllTheThings is optional
	if app.databaseLoaded or ATTC == nil then
		return;
	end

	-- improve items database from ATT
	for itemId, item in pairs(app.Items) do
		local attItem = ATTC.SearchForField("itemID", itemId);
		local appearance = app.ItemsByAppearances[item.a];

		local sourceQuest;
		local sourceCraft;
		local sourceDrop;

		for k, v in pairs(attItem) do
			-- boe
			if not v.b or v.b ~= 1 then
				item.boe = 1;
				appearance.boe = 1;
			end

			-- rwp
			if v.rwp and IsRWP(v.rwp) then
				item.rwp = 1;
				appearance.rwp = 1;
			end

			-- pvp
			if v.pvp then
				item.pvp = 1;
				appearance.pvp = 1;
			end

			-- item is directly collectible/collected
			if v.collectible and v.collected then
				item.collected = 1;
				appearance.collected = 1;
			end

			-- quest
			if v.parent and v.parent.questID then
				item.sourceQuest = 1;
				appearance.sourceQuest = 1;

				local quest = v.parent;
				if quest.collected then
					item.collected = 1;
					appearance.collected = 1;
				end
				if quest.total and quest.total ~= 0 and quest.progress == quest.total then
					item.collected = 1;
					appearance.collected = 1;
				end
				-- craft
			elseif v.parent and v.parent.parent and (v.parent.parent.professionID
					or (v.parent.parent.parent and v.parent.parent.parent.professionID)) then
				item.sourceCraft = 1;
				appearance.sourceCraft = 1;
				-- loot from npc
			elseif v.parent and (v.parent.npcID
					or (v.parent.parent and (v.parent.parent.npcID
						-- loot from instance zone
						or (v.parent.parent.parent and v.parent.parent.parent.instanceID)))) then
				item.sourceDrop = 1;
				appearance.sourceDrop = 1;
			end
		end
	end

	-- database loaded
	app.databaseLoaded = true;
end

-- check version RWP
function IsRWP(version)
	local isRWP = false;

	local major = string.sub(version, 1, 1);
	if major == "4" then
		isRWP = true;
	end

	return isRWP;
end

-- build item text : name(hyperlink with color) + bonus from ATT
function GetItemText(itemId, parentSlot, parentSubclass)
	local item = app.Items[itemId];
	local color = app.COLOR_STRINGS[item.q];
	local slot = typesToSlots[item.t];
	local subclass;
	-- armor
	if slot >= 1 and slot <= 12 then
		subclass = item.s;
		-- weapon
	elseif slot == 14 then
		subclass = typesToWeaponSubclasses[item.s];
		-- offhand
	elseif slot == 16 then
		subclass = typesToOffhandSubclasses[item.s];
	end

	-- itemlink
	local text = color .. "\124Hitem:" .. itemId .. "::::::::80:::::\124h[" .. item.n .. "]\124h\124r";

	-- different type/subclass
	if slot ~= parentSlot or subclass ~= parentSubclass then
		-- armor
		if slot >= 1 and slot <= 12 then
			local type = "Cosmetic";
			if subclass >= 1 and subclass <= 4 then
				type = armorType[subclass];
			end
			text = text .. " \124cffFF0000(" .. type .. ")\124r";
			-- weapon
		elseif slot == 14 then
			text = text .. " \124cffFF0000(" .. weaponType[subclass].name .. ")\124r";
			-- offhand
		elseif slot == 16 then
			text = text .. " \124cffFF0000(" .. offhandType[subclass].name .. ")\124r";
		end
	end

	-- special ATT infos parsed from its internal database
	local bonus = "";
	-- rwp
	if item.rwp then
		bonus = bonus .. "\124cFFFFAAAA RWP\124r";
	end
	-- pvp
	if item.pvp then
		bonus = bonus .. "\124cFF00FEDD PVP\124r";
	end
	-- boe
	if item.boe then
		bonus = bonus .. "\124r B";
	end

	-- quest
	if item.sourceQuest then
		bonus = bonus .. "\124cFFFFD700 Q\124r";
		-- craft
	elseif item.sourceCraft then
		bonus = bonus .. "\124cFFC45F06 C\124r";
		-- drop
	elseif item.sourceDrop then
		bonus = bonus .. "\124cFF3D85C6 D\124r";
	end

	text = text .. bonus;

	return text;
end
