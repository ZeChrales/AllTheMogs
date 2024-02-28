local appName, app = ...;
-- Appearance models

local gender = UnitSex("player") - 1;
local _, _, race = UnitRace("player");

local ModelFrames = {};
local selected = 0;

-- create empty frames and hide them
function AppearanceModelFrame_Init(parentFrame)
	local lastFrame;
	for i = 0, 19 do
		local line = math.floor(i / 5) + 1;
		local column = i % 5 + 1;

		-- to debug, ModelWithControlsTemplate + EnableMouse
		local ModelFrame = CreateFrame("DressUpModel", "AppearanceModelFrameL" .. line .. "C" .. column, parentFrame,
			"ModelTemplate");
		--local ModelFrame = CreateFrame("Frame", "AppearanceModelFrameL" .. line .. "C" .. column, parentFrame);
		if lastFrame == nil then
			ModelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, -20);
		elseif column == 1 then
			ModelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, -((line - 1) * 105) - 20);
		else
			ModelFrame:SetPoint("LEFT", lastFrame, "RIGHT", 10, 0);
		end
		lastFrame = ModelFrame;
		ModelFrame:SetSize(78, 104);
		local lightValues = {
			omnidirectional = false,
			point = CreateVector3D(-1, 1, -1),
			ambientIntensity = 1.05,
			ambientColor =
				CreateColor(1, 1, 1),
			diffuseIntensity = 0,
			diffuseColor = CreateColor(1, 1, 1)
		};
		ModelFrame:SetLight(true, lightValues);
		--ModelFrame.EnableMouse(false);

		-- background
		ModelFrame.background = ModelFrame:CreateTexture(nil, "BACKGROUND");
		ModelFrame.background:SetColorTexture(0, 0, 0);
		ModelFrame.background:SetAllPoints();

		-- border
		ModelFrame.border = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.border:SetPoint("CENTER", 0, -3);
		ModelFrame.border:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.border:SetAtlas("transmog-wardrobe-border-uncollected", true);
		ModelFrame.border:SetDrawLayer("OVERLAY", -1);

		-- highlight
		ModelFrame.highlight = ModelFrame:CreateTexture(nil, "HIGHLIGHT");
		ModelFrame.highlight:SetPoint("CENTER");
		ModelFrame.highlight:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.highlight:SetAtlas("transmog-wardrobe-border-highlighted", true);
		ModelFrame.highlight:SetBlendMode("ADD");

		-- selected
		ModelFrame.selected = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.selected:SetPoint("CENTER");
		ModelFrame.selected:SetTexture("Interface\\Transmogrify\\Transmogrify");
		ModelFrame.selected:SetAtlas("transmog-wardrobe-border-current", true);
		ModelFrame.selected:SetBlendMode("ADD");

		-- to debug, ModelWithControlsTemplate + EnableMouse
		--ModelFrame.modelFrame = CreateFrame("DressUpModel", nil, ModelFrame, "ModelTemplate");
		--ModelFrame.modelFrame:SetSize(85, 85);
		--ModelFrame.modelFrame:SetSize(85, 100);
		--ModelFrame.modelFrame:SetPoint("CENTER");
		--ModelFrame.modelFrame:EnableMouse(false);
		--ModelFrame.modelFrame:SetModel("Item/ObjectComponents/Head/Helm_Goggles_Xray_A_01_BeF.m2");
		--ModelFrame.modelFrame:SetPortraitZoom(0.8);
		--ModelFrame.modelFrame:SetRotation(0.2);
		--ModelFrame.modelFrame:FreezeAnimation(60, 0, 55);
		--ModelFrame.modelFrame:SetUnit("player", false);
		--ModelFrame.modelFrame:Undress();
		--ModelFrame.modelFrame:SetDoBlend(false);
		--ModelFrame.modelFrame:SetKeepModelOnHide(true);
		--ModelFrame.modelFrame:MakeCurrentCameraCustom();
		--ModelFrame.modelFrame:SetSheathed(false);
		--ModelFrame.modelFrame:TryOn("item:"..38276);
		--ModelFrame.modelFrame:SetUseTransmogSkin(true);

		-- rwp
		ModelFrame.rwp = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.rwp:SetPoint("TOPLEFT", ModelFrame, "TOPLEFT", 0, 0);
		ModelFrame.rwp:SetSize(28, 28);
		ModelFrame.rwp:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.rwp:SetAtlas("XMarksTheSpot");

		-- boe
		ModelFrame.boe = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.boe:SetPoint("TOP", ModelFrame, "TOP", 0, 0);
		ModelFrame.boe:SetSize(24, 24);
		ModelFrame.boe:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.boe:SetAtlas("Banker");

		-- pvp
		ModelFrame.pvp = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.pvp:SetPoint("TOPRIGHT", ModelFrame, "TOPRIGHT", 0, 0);
		ModelFrame.pvp:SetSize(28, 28);
		ModelFrame.pvp:SetTexture("Interface\\Minimap\\objecticonsatlas");
		if UnitFactionGroup("player") == "Horde" then
			ModelFrame.pvp:SetAtlas("poi-horde");
		else
			ModelFrame.pvp:SetAtlas("poi-alliance");
		end

		-- quest
		ModelFrame.quest = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.quest:SetPoint("BOTTOMLEFT", ModelFrame, "BOTTOMLEFT", -5, 0);
		ModelFrame.quest:SetSize(32, 32);
		ModelFrame.quest:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.quest:SetAtlas("QuestNormal");

		-- craft
		ModelFrame.craft = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.craft:SetPoint("BOTTOM", ModelFrame, "BOTTOM", 0, 0);
		ModelFrame.craft:SetSize(32, 32);
		ModelFrame.craft:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.craft:SetAtlas("Profession");

		-- drop
		ModelFrame.drop = ModelFrame:CreateTexture(nil, "OVERLAY");
		ModelFrame.drop:SetPoint("BOTTOMRIGHT", ModelFrame, "BOTTOMRIGHT", 0, 0);
		ModelFrame.drop:SetSize(32, 32);
		ModelFrame.drop:SetTexture("Interface\\Minimap\\objecticonsatlas");
		ModelFrame.drop:SetAtlas("DungeonSkull");

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

	ModelFrame:SetUnit("player", false);
	ModelFrame:Undress();
	ModelFrame:SetDoBlend(false);
	ModelFrame:SetKeepModelOnHide(true);

	-- change zoom/position depending on slot
	--ModelFrame.modelFrame:SetPortraitZoom(0.8);
	--ModelFrame.modelFrame:SetRotation(CAM_POS[filterSlot].Rotation);
	--ModelFrame.modelFrame:SetPosition(CAM_POS[filterSlot].Position[1], CAM_POS[filterSlot].Position[2],
	--	CAM_POS[filterSlot].Position[3]);
	--	ModelFrame.modelFrame:SetPortraitZoom(CAM_POS[filterSlot].Zoom);

	local camera = app.WEAPONS_CAMERAS[13];
	if filterSlot < 13 then
		camera = app.CLASSES_CAMERAS[race][gender][filterSlot];
	elseif filterSlot == 14 then
		camera = app.WEAPONS_CAMERAS[filterWeaponType];
	elseif filterSlot == 16 then
		camera = app.OFFHANDS_CAMERAS[filterOffhandType];
	end
	-- camera position from blizzard constants
	ModelFrame:MakeCurrentCameraCustom();
	ModelFrame:SetPosition(camera[1], camera[2], camera[3]);
	ModelFrame:SetFacing(camera[4]);
	ModelFrame:SetPitch(camera[5]);
	ModelFrame:SetRoll(camera[6]);
	ModelFrame:UseModelCenterToTransform(false);

	-- move camera
	local cameraX, cameraY, cameraZ = ModelFrame:TransformCameraSpaceToModelSpace(
		MODELFRAME_UI_CAMERA_POSITION):GetXYZ();
	local targetX, targetY, targetZ = ModelFrame:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_TARGET)
		:GetXYZ();
	ModelFrame:SetCameraPosition(cameraX, cameraY, cameraZ);
	ModelFrame:SetCameraTarget(targetX, targetY, targetZ);

	-- freeze
	if (camera[7] and camera[8] ~= -1 and camera[9] ~= -1) then
		ModelFrame:FreezeAnimation(camera[7], camera[9], camera[8]);
	else
		ModelFrame:SetAnimation(0, 0);
	end

	--ModelFrame.modelFrame:Undress();

	-- get first item of an appearance
	local itemId = app.ItemsByAppearances[appearanceId].i[1];

	if filterSlot < 13 then
		ModelFrame:TryOn("item:" .. itemId);
	else
		--ModelFrame:SetItemAppearance(appearanceId);
		ModelFrame:SetItem(itemId);
	end

	-- collected
	ModelFrame.border:SetAtlas("transmog-wardrobe-border-uncollected", true);
	ModelFrame.rwp:Hide();
	ModelFrame.boe:Hide();
	ModelFrame.pvp:Hide();
	ModelFrame.quest:Hide();
	ModelFrame.craft:Hide();
	ModelFrame.drop:Hide();

	for k, v in pairs(app.ItemsByAppearances[appearanceId].i) do
		local subclass = app.Items[v].s;
		if app.filterGrey and app.Items[v].q <= 1 then
			-- filter grey
		elseif filterSlot >= 1 and filterSlot <= 12 and subclass ~= filterArmorType and subclass ~= 0 then
			-- filter armor of different type
		else
			-- collected
			if app.Items[v].collected or ATM_ItemCache[v] then
				ModelFrame.border:SetAtlas("transmog-wardrobe-border-collected", true);
			end
			-- rwp
			if app.Items[v].rwp then
				ModelFrame.rwp:Show();
			end
			-- boe
			if app.Items[v].boe then
				ModelFrame.boe:Show();
			end
			-- pvp
			if app.Items[v].pvp then
				ModelFrame.pvp:Show();
			end
			-- quest
			if app.Items[v].sourceQuest then
				ModelFrame.quest:Show();
			end
			-- craft
			if app.Items[v].sourceCraft then
				ModelFrame.craft:Show();
			end
			-- drop
			if app.Items[v].sourceDrop then
				ModelFrame.drop:Show();
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
	pageText:SetText(currentPage .. " / " .. maxPage);

	local count = 0;
	-- 1 : 1...20 / 2 : 21...40
	for i = (currentPage - 1) * 20 + 1, currentPage * 20 do
		ModelFrames[count].selected:Hide();
		if listAppearances[i] then
			ModelFrames[count]:Show();
			--ModelFrames[count].modelFrame:Show();
			AppearanceModelFrame_Load(count, listAppearances[i]);
		else
			ModelFrames[count]:Hide();
			--ModelFrames[count].modelFrame:Hide();
		end
		count = count + 1;
	end
end

-- get list of appearances with filters
function AppearanceModelFrame_GetListOfAppearances(type, subclass)
	local list = {};
	local count = 1;

	local listAppearances = app.AppearancesByTypes[type][subclass];
	for i = 1, #listAppearances do
		local found = false;
		local appearanceId = listAppearances[i];

		if app.ItemsByAppearances[appearanceId] then
			local listItems = app.ItemsByAppearances[appearanceId].i;

			for j = 1, #listItems do
				local item = app.Items[listItems[j]];
				if app.filterGrey and (item.q == 0 or item.q == 1) then
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
