-- globals

-- texts
Texts = {
	["Types"] = {"Head", "Shoulder", "Shirt", "Chest", "Wraist", "Legs", "Feet", "Bracers", "Hands", "Cape", "Tabards", "Weapons"}
};

-- init quality colors
COLOR_STRINGS = {};
for i=0,7 do
	local _, _, _, itemQuality = GetItemQualityColor(i);
	COLOR_STRINGS[i] = "\124c"..itemQuality;
end

-- camera position for each slot
CAM_POS = {
	-- head
	[1] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0, -0.2}},
	-- shoulder
	[2] = {["Zoom"]=0.7, ["Rotation"]=0.3, ["Position"]={0, 0.4, -0.2}},
	-- back
	[3] = {["Zoom"]=0.6, ["Rotation"]=2.5, ["Position"]={0, 0.1, 0}},
	-- chest
	[4] = {["Zoom"]=0.6, ["Rotation"]=0.2, ["Position"]={0, 0, 0}},
	-- shirt
	[5] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.2, 0}},
	-- tabard
	[6] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.2, 0}},
	-- wrist
	[7] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.6, 0.3}},
	-- hands
	[9] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.6, 0.5}},
	-- waist
	[10] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.1, 0.3}},
	-- legs
	[11] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.1, 0.7}},
	-- feet
	[12] = {["Zoom"]=0.8, ["Rotation"]=0.2, ["Position"]={0, 0.1, 1.2}},
	-- one-hand + ranged
	[14] = {["Zoom"]=0.4, ["Rotation"]=0.4, ["Position"]={0, 0.2, 0.5}},
	-- shield + offhands
	[16] = {["Zoom"]=0.4, ["Rotation"]=4.5, ["Position"]={0, 0.2, 0.5}},
};