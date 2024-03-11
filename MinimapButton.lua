local appName, app = ...;

-- Create and register minimap button using LibDBIcon library
app.minimapButton = LibStub("LibDBIcon-1.0");

local data = {
	icon = "Interface\\Addons\\AllTheMogs\\Textures\\minimap_icon.blp",
	OnClick = function(self, button, down)
		InitDatabase();
		ClassicTransmogFrame:Show();
		AppearanceModelFrame_LoadWithFilter();
	end
};

app.minimapButton:Register("All The Mogs", data, { hide = false });

-- Add slash command
SLASH_ALLTHEMOGS1 = "/atm"
SlashCmdList["ALLTHEMOGS"] = function(msg, editBox)
	InitDatabase();
	ClassicTransmogFrame:Show();
	AppearanceModelFrame_LoadWithFilter();
end
