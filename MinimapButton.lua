-- minimap button

local button = CreateFrame("BUTTON", "Test-Minimap", Minimap);
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
button.texture = texture;

-- Create the Button Tracking Border
local border = button:CreateTexture(nil, "BORDER");
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
border:SetPoint("CENTER", 12, -12);
border:SetSize(56, 56);
button.border = border;

button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD");

-- Button Configuration
local radius = 100;
local rounding = 10;
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
	local position = -10.31;
	local angle = math.rad(position) -- determine position on your own
	local x, y
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local q = 1;
	if cos < 0 then
		q = q + 1;	-- lower
	end
	if sin > 0 then
		q = q + 2;	-- right
	end
	x = cos*radius;
	y = sin*radius;
	self:SetPoint("CENTER", "Minimap", "CENTER", -math.floor(x), math.floor(y));
end
local update = function(self)
	local w, x = GetCursorPosition();
	local y, z = Minimap:GetLeft(), Minimap:GetBottom();
	local s = UIParent:GetScale();
	w = y - w / s + 70; x = x / s - z - 70;
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
button:update();
button:Show();
