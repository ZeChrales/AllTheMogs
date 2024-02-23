local appName, app = ...;
-- Appearance models

local ModelFrames = {};
local selected = 0;

-- create empty frames and hide them
function AppearanceModelFrame_Init(parentFrame)
	local lastFrame;
	for i = 0, 19 do
		local line = math.floor(i / 5) + 1;
		local column = i % 5 + 1;
		local ModelFrame = CreateFrame("Frame", "AppearanceModelFrameL"..line.."C"..column, parentFrame);
		if lastFrame == nil then
			ModelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -5);
		elseif column == 1 then
			ModelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -(line-1)*100-5);
		else
			ModelFrame:SetPoint("LEFT", lastFrame, "RIGHT", 0, 0);
		end
		lastFrame = ModelFrame;
		ModelFrame:SetSize(100, 100);

		-- background
		ModelFrame.background = ModelFrame:CreateTexture(nil, "BACKGROUND");
		ModelFrame.background:SetPoint("CENTER")
		ModelFrame.background:SetSize(100, 100);
		ModelFrame.background:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.background:SetAtlas("transmog-wardrobe-border-uncollected");

		-- highlight
		ModelFrame.highlight = ModelFrame:CreateTexture(nil, "HIGHLIGHT");
		ModelFrame.highlight:SetPoint("CENTER")
		ModelFrame.highlight:SetSize(100, 100);
		ModelFrame.highlight:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.highlight:SetAtlas("transmog-wardrobe-border-highlighted");
		ModelFrame.highlight:SetBlendMode("ADD");

		-- selected
		ModelFrame.selected = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.selected:SetPoint("CENTER")
		ModelFrame.selected:SetSize(100, 100);
		ModelFrame.selected:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.selected:SetAtlas("transmog-wardrobe-border-current");
		ModelFrame.selected:SetBlendMode("ADD");

		-- to debug, ModelWithControlsTemplate + EnableMouse
		ModelFrame.modelFrame = CreateFrame("DressUpModel", nil, ModelFrame, "ModelTemplate");
		ModelFrame.modelFrame:SetSize(85, 85);
		ModelFrame.modelFrame:SetPoint("CENTER");
		ModelFrame.modelFrame:EnableMouse(false);
		--ModelFrame.modelFrame:SetModel("Item/ObjectComponents/Head/Helm_Goggles_Xray_A_01_BeF.m2");
		ModelFrame.modelFrame:SetPortraitZoom(0.8);
		ModelFrame.modelFrame:SetRotation(0.2);
		ModelFrame.modelFrame:FreezeAnimation(60, 0, 55);
		ModelFrame.modelFrame:SetUnit("player");
		ModelFrame.modelFrame:Undress();
		--ModelFrame.modelFrame:SetSheathed(false);
		--ModelFrame.modelFrame:TryOn("item:"..38276);
		--ModelFrame.modelFrame:SetUseTransmogSkin(true);

		-- rwp
		ModelFrame.modelFrame.rwp = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.rwp:SetPoint("TOPLEFT", ModelFrame, "TOPLEFT", 0, 0);
		ModelFrame.modelFrame.rwp:SetSize(28, 28);
		ModelFrame.modelFrame.rwp:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.modelFrame.rwp:SetAtlas("XMarksTheSpot");

		-- boe
		ModelFrame.modelFrame.boe = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.boe:SetPoint("TOP", ModelFrame, "TOP", 0, 0);
		ModelFrame.modelFrame.boe:SetSize(24, 24);
		ModelFrame.modelFrame.boe:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.modelFrame.boe:SetAtlas("Banker");

		-- pvp
		ModelFrame.modelFrame.pvp = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.pvp:SetPoint("TOPRIGHT", ModelFrame, "TOPRIGHT", 0, 0);
		ModelFrame.modelFrame.pvp:SetSize(28, 28);
		ModelFrame.modelFrame.pvp:SetTexture("Interface\\Minimap\\objecticonsatlas");
		if UnitFactionGroup("player") == "Horde" then
			ModelFrame.modelFrame.pvp:SetAtlas("poi-horde");
		else
			ModelFrame.modelFrame.pvp:SetAtlas("poi-alliance");
		end

		-- quest
		ModelFrame.modelFrame.quest = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.quest:SetPoint("BOTTOMLEFT", ModelFrame, "BOTTOMLEFT", -5, 0);
		ModelFrame.modelFrame.quest:SetSize(32, 32);
		ModelFrame.modelFrame.quest:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.modelFrame.quest:SetAtlas("QuestNormal");

		-- craft
		ModelFrame.modelFrame.craft = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.craft:SetPoint("BOTTOM", ModelFrame, "BOTTOM", 0, 0);
		ModelFrame.modelFrame.craft:SetSize(32, 32);
		ModelFrame.modelFrame.craft:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.modelFrame.craft:SetAtlas("Profession");

		-- drop
		ModelFrame.modelFrame.drop = ModelFrame.modelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.modelFrame.drop:SetPoint("BOTTOMRIGHT", ModelFrame, "BOTTOMRIGHT", 0, 0);
		ModelFrame.modelFrame.drop:SetSize(32, 32);
		ModelFrame.modelFrame.drop:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.modelFrame.drop:SetAtlas("DungeonSkull");

		ModelFrame:SetScript("OnMouseDown", function()
			if selected ~= i then
				-- select current appearance
				ModelFrames[selected].selected:Hide();
				ModelFrame.selected:Show();
				selected = i;

				-- display details
				AppearanceDetailFrame_Load(ModelFrame.appearanceId);
			end
		end)

		ModelFrames[i] = ModelFrame;
	end
end

-- fill a frame with an id
function AppearanceModelFrame_Load(frameId, appearanceId)
	local ModelFrame = ModelFrames[frameId];
	ModelFrame.appearanceId = appearanceId;

	-- change zoom/position depending on slot
	ModelFrame.modelFrame:SetPortraitZoom(CAM_POS[filterSlot].Zoom);
	ModelFrame.modelFrame:SetRotation(CAM_POS[filterSlot].Rotation);
	ModelFrame.modelFrame:SetPosition(CAM_POS[filterSlot].Position[1], CAM_POS[filterSlot].Position[2], CAM_POS[filterSlot].Position[3]);

	ModelFrame:Show();
	ModelFrame.modelFrame:Undress();

	-- get first item of an appearance
	local itemId = app.ItemsByAppearances[appearanceId].i[1];
	ModelFrame.modelFrame:TryOn("item:"..itemId);

	-- collected
	ModelFrame.background:SetAtlas("transmog-wardrobe-border-uncollected");
	if app.ItemsByAppearances[appearanceId].collected then
		ModelFrame.background:SetAtlas("transmog-wardrobe-border-collected");
	else
		for k, v in pairs(app.ItemsByAppearances[appearanceId].i) do
			if filterGrey and app.Items[v].q <= 1 then
				-- filter grey
			elseif app.Items[v].c or (ItemCache[v] and ItemCache[v].c) then
				ModelFrame.background:SetAtlas("transmog-wardrobe-border-collected");
				break;
			end
		end
	end
	ModelFrame.modelFrame.rwp:Hide();
	ModelFrame.modelFrame.boe:Hide();
	ModelFrame.modelFrame.pvp:Hide();
	ModelFrame.modelFrame.craft:Hide();
	ModelFrame.modelFrame.drop:Hide();

	for k, v in pairs(app.ItemsByAppearances[appearanceId].i) do
		local subclass = app.Items[v].s;
		if filterGrey and app.Items[v].q <= 1 then
			-- filter grey
		elseif filterSlot >= 1 and filterSlot <= 12 and subclass ~= filterArmorType and subclass ~= 0 then
			-- filter armor of different type
		else
			-- collected
			if app.Items[v].c or (ItemCache[v] and ItemCache[v].c) then
				ModelFrame.background:SetAtlas("transmog-wardrobe-border-collected");
			end
			-- rwp
			if app.Items[v].rwp then
				ModelFrame.modelFrame.rwp:Show();
			end
			-- boe
			if app.Items[v].boe then
				ModelFrame.modelFrame.boe:Show();
			end
			-- pvp
			if app.Items[v].pvp then
				ModelFrame.modelFrame.pvp:Show();
			end
			-- craft
			if app.Items[v].sourceCraft then
				ModelFrame.modelFrame.craft:Show();
			end
			-- drop
			if app.Items[v].sourceDrop then
				ModelFrame.modelFrame.drop:Show();
			end
		end
	end
end

-- fill frames
function AppearanceModelFrame_LoadWithFilter()
	-- init from globals
	local type = filters[filterSlot]["Type"];
	local subclass = 1;
	-- for shirt or tabard
	if filterSlot == 5 or filterSlot == 6 then
		subclass = 0;
	-- for back
	elseif filterSlot == 3 then
		subclass = 1;
	-- armor
	elseif filterSlot >= 1 and filterSlot <= 12 then
		subclass = filterArmorType;
	-- weapon+ranged
	elseif filterSlot == 14 then
		type = filters[filterSlot][1]["Type"];
		-- ranged
		if filterWeaponType == 2 or filterWeaponType == 3 or filterWeaponType == 16 or filterWeaponType == 18 or filterWeaponType == 19 then
			type = filters[filterSlot][2]["Type"];
		end
		subclass = filterWeaponType;
	-- shield+offhand
	elseif filterSlot == 16 then
		type = filters[filterSlot][1]["Type"];
		-- ranged
		if filterOffhandType ~= 6 then
			type = filters[filterSlot][2]["Type"];
		end
		subclass = filterOffhandType;
	end

	-- get list of filtered appearances
	local listAppearances = AppearanceModelFrame_GetListOfAppearances(type, subclass);

	local bonusPage = 0;
	if #listAppearances % 20 > 0 then
		bonusPage = 1;
	end
	maxPage = math.floor(#listAppearances / 20) + bonusPage;
	pageText:SetText(currentPage.." / "..maxPage);

	local count = 0;
	-- 1 : 1...20 / 2 : 21...40
	for i = (currentPage-1)*20+1, currentPage*20 do
		ModelFrames[count].selected:Hide();
		if listAppearances[i] then
			ModelFrames[count]:Show();
			AppearanceModelFrame_Load(count, listAppearances[i]);
		else
			ModelFrames[count]:Hide();
		end
		count = count + 1;
	end
end

-- get list of appearances with filters
function AppearanceModelFrame_GetListOfAppearances(type, subclass)
	local list = {};
	local count = 1;
	
	local listAppearances = app.AppearancesByTypes[type][subclass];
	for i=1, #listAppearances do
		local found = false;
		local appearanceId = listAppearances[i];

		if app.ItemsByAppearances[appearanceId] then
			local listItems = app.ItemsByAppearances[appearanceId].i;

			for j=1, #listItems do
				local item = app.Items[listItems[j]];
				if filterGrey and (item.q == 0 or item.q == 1) then
					-- filter grey
				else
					found = true;
				end
			end
		end

		if found then
			list[count] = listAppearances[i];
			count = count + 1;
		end
	end
	
	return list;
end