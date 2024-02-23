-- minimap button
local button = CreateFrame("BUTTON", "AllTheMogsMinimap", Minimap);
button:SetPoint("CENTER", 0, 0);
button:SetFrameStrata("HIGH");
button:SetMovable(true);
button:EnableMouse(true);
button:RegisterForDrag("LeftButton", "RightButton");
button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
button:SetSize(32, 32);

-- Create the Button Texture
local texture = button:CreateTexture(nil, "BACKGROUND");
texture:SetPoint("CENTER", 1, 0);
texture:SetTexture("Interface\\Minimap\\objecticonsatlas");
texture:SetAtlas("poi-transmogrifier");
texture:SetSize(21, 21);

-- Create the Button Tracking Border
local border = button:CreateTexture(nil, "BORDER");
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
border:SetPoint("CENTER", 12, -12);
border:SetSize(56, 56);

-- Hightlight texture on mouseOver
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD");

-- Button Configuration
local rounding = 10;
local position = 193.47782;
local MinimapShapes = {
	-- quadrant booleans (same order as SetTexCoord)
	-- {bottom-right, bottom-left, top-right, top-left}
	-- true = rounded, false = squared
	["ROUND"]			= {true,  true,  true,  true },
	["SQUARE"]			= {false, false, false, false},
	["CORNER-TOPLEFT"]		= {false, false, false, true },
	["CORNER-TOPRIGHT"]		= {false, false, true,  false},
	["CORNER-BOTTOMLEFT"]		= {false, true,  false, false},
	["CORNER-BOTTOMRIGHT"]		= {true,  false, false, false},
	["SIDE-LEFT"]			= {false, true,  false, true },
	["SIDE-RIGHT"]			= {true,  false, true,  false},
	["SIDE-TOP"]			= {false, false, true,  true },
	["SIDE-BOTTOM"]		= {true,  true,  false, false},
	["TRICORNER-TOPLEFT"]		= {false, true,  true,  true },
	["TRICORNER-TOPRIGHT"]		= {true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]	= {true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"]	= {true,  true,  true,  false},
};
button.update = function(self)
	local angle = math.rad(position);
	local x, y, q = math.cos(angle), math.sin(angle), 1;
	if x < 0 then q = q + 1; end
	if y > 0 then q = q + 2; end
	local radius = 0;
	local width = (Minimap:GetWidth() * 0.5) + radius;
	local height = (Minimap:GetHeight() * 0.5) + radius;
	if MinimapShapes[GetMinimapShape and GetMinimapShape() or "ROUND"][q] then
		x, y = x * width, y * height;
	else
		x = math.max(-width, math.min(x*(math.sqrt(2*(width)^2)-rounding), width));
		y = math.max(-height, math.min(y*(math.sqrt(2*(height)^2)-rounding), height));
	end
	self:SetPoint("CENTER", "Minimap", "CENTER", math.floor(x), math.floor(y));
end
local update = function(self)
	local mx, my = Minimap:GetCenter();
	local px, py = GetCursorPosition();
	local scale = Minimap:GetEffectiveScale();
	position = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)) % 360;
	self:Raise();
	self:update();
end

-- Register for Frame Events
button:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", update);
end);
button:SetScript("OnDragStop", function(self)
	self:SetScript("OnUpdate", nil);
end);
button:SetScript("OnClick", function()
	InitDatabase();
	ClassicTransmogFrame:Show();
	AppearanceModelFrame_LoadWithFilter();
end);
button:SetScript("OnEvent", button.update);
button:update();
button:Show();
