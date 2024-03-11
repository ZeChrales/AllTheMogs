local appName, app = ...;

-- Interface options
InterfaceOptionsMixin = {};

-- savedvariables
if ATM_InterfaceOptions == nil then
    ATM_InterfaceOptions = {};
    ATM_InterfaceOptions.filterGrey = true;
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        ATM_InterfaceOptions.filterGrey = false;
    end

    ATM_InterfaceOptions.minimapPos = 193.47782;
end

-- init
function InterfaceOptionsMixin:OnLoad()
    -- Interface Options for addon
    self.name = appName;
    InterfaceOptions_AddCategory(self);

    -- add widgets to the panel as desired
    local title = self:CreateFontString("ARTWORK", nil, "GameFontNormalLarge");
    title:SetPoint("TOP");
    title:SetText(appName);

    -- grey/white filter
    app.filterGrey = ATM_InterfaceOptions.filterGrey;

    -- checkbox
    local checkbox = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate");
    checkbox:SetPoint("TOPLEFT", 20, -20);
    checkbox.Text:SetText("Filter grey & white items (disabled for Retail)");
    checkbox:HookScript("OnClick", function(_, btn, down)
        app.filterGrey = checkbox:GetChecked();
        ATM_InterfaceOptions.filterGrey = app.filterGrey;
    end)
    checkbox:SetChecked(app.filterGrey);
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        checkbox:SetEnabled(false);
    end
end
