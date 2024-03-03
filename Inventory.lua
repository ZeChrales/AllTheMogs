local appName, app = ...;
-- item cache : bags, equipment, mail, bank, guildbank
ItemCacheMixin = {};

-- player GUID
local playerGuid = UnitGUID("player");


-- init
function ItemCacheMixin:OnLoad()
    -- savedvariables cache
    if ATM_ItemCache == nil then
        ATM_ItemCache = {};
    end
    if ATM_CharacterInventory == nil then
        ATM_CharacterInventory = {};
    end
    if ATM_CharacterInventory[playerGuid] == nil then
        ATM_CharacterInventory[playerGuid] = {};
    end
    if ATM_CharacterInventory[playerGuid]["e"] == nil then
        ATM_CharacterInventory[playerGuid]["e"] = {};
    end
    if ATM_CharacterInventory[playerGuid]["b"] == nil then
        ATM_CharacterInventory[playerGuid]["b"] = {};
    end
    if ATM_CharacterInventory[playerGuid]["m"] == nil then
        ATM_CharacterInventory[playerGuid]["m"] = {};
    end
    if ATM_GuildBankInventory == nil then
        ATM_GuildBankInventory = {};
    end

    -- bag updated
    self:RegisterEvent("BAG_UPDATE");
    -- bag replaced
    self:RegisterEvent("BAG_CONTAINER_UPDATE");
    -- bank opened
    self:RegisterEvent("BANKFRAME_OPENED");
    -- bank closed
    self:RegisterEvent("BANKFRAME_CLOSED");
    -- bank updated
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
    -- equipment updated
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    -- mail updated
    self:RegisterEvent("MAIL_INBOX_UPDATE");
    -- guildbank updated
    self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");

    self:ParseBags();
    self:ParseEquipment();
end

-- event trigger
function ItemCacheMixin:OnEvent(eventName, ...)
    --print("debug event ", eventName);
    local start = debugprofilestop();
    if eventName == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = ...;
        if slot >= C_Container.ContainerIDToInventoryID(1) then
            return;
        end
        local itemId = GetInventoryItemID("player", slot);
        self:UpdateItem(itemId, ATM_CharacterInventory, "e", slot, 1, playerGuid);
    elseif eventName == "BAG_UPDATE" then
        local bag = ...;
        self:ParseBag(bag);
    elseif eventName == "BANKFRAME_OPENED" then
        self:ParseBankBags();
    elseif eventName == "MAIL_INBOX_UPDATE" then
        self:ParseMails();
    elseif eventName == "GUILDBANKBAGSLOTS_CHANGED" then
        self:ParseGuildBank();
    end
    --print("event done", debugprofilestop() - start);
end

-- parse all equipment
function ItemCacheMixin:ParseEquipment()
    for slot = 0, C_Container.ContainerIDToInventoryID(1) - 1 do
        local itemId = GetInventoryItemID("player", slot);
        self:UpdateItem(itemId, ATM_CharacterInventory, "e", slot, 1, playerGuid);
    end
end

-- parse all mails
function ItemCacheMixin:ParseMails()
    for mail = 1, (GetInboxNumItems()) do
        for attachment = 1, ATTACHMENTS_MAX do
            local link = GetInboxItemLink(mail, attachment);
            if link then
                local _, itemId = GetInboxItem(mail, attachment)
                self:UpdateItem(itemId, ATM_CharacterInventory, "m", mail, attachment, playerGuid);
                -- item mail has been retrieved, so delete it
            elseif ATM_CharacterInventory[playerGuid]["m"][mail] and ATM_CharacterInventory[playerGuid]["m"][mail][attachment] then
                local previous = ATM_CharacterInventory[playerGuid]["m"][mail][attachment];
                local key = playerGuid .. "-m" .. mail;
                self:RemoveItemFromCache(previous, mail);
            end
        end
    end
end

-- parse all guidbank
function ItemCacheMixin:ParseGuildBank()
    -- player realm
    local playerRealm = GetNormalizedRealmName();
    local bankGuid = GetGuildInfo("player").."-"..playerRealm;

    if ATM_GuildBankInventory[bankGuid] == nil then
        ATM_GuildBankInventory[bankGuid] = {};
    end
    if ATM_GuildBankInventory[bankGuid]["g"] == nil then
        ATM_GuildBankInventory[bankGuid]["g"] = {};
    end

    for tab = 1, GetNumGuildBankTabs() do
        for slot = 1, 98 do
            local link = GetGuildBankItemLink(tab, slot);
            if link then
                local itemId = GetItemInfoInstant(link);
                self:UpdateItem(itemId, ATM_GuildBankInventory, "g", tab, slot, bankGuid);
            end
        end
    end
end

-- parse all bank bags
function ItemCacheMixin:ParseBankBags()
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        self:ParseBag(bag);
    end
end

-- parse all bags
function ItemCacheMixin:ParseBags()
    for bag = 0, NUM_BAG_SLOTS do
        self:ParseBag(bag);
    end
end

-- parse bag
function ItemCacheMixin:ParseBag(bag)
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
        local itemId = C_Item.DoesItemExist(location) and C_Item.GetItemID(location)
        self:UpdateItem(itemId, ATM_CharacterInventory, "b", bag, slot, playerGuid);
    end
end

-- update item
-- table : ATM_CharacterInventory, ATM_GuildBankInventory
-- name : b=bag, e=equipment, m=mail ...
-- container : bag id or equipement id
-- slot : bag slot id or 1 for equipment
-- guid : player or guild GUID
function ItemCacheMixin:UpdateItem(itemId, table, name, container, slot, guid)
    -- only if item is in database
    if not self:IsItemInDatabase(itemId) then
        return;
    end
    --print("updateitem", itemId, table, name, container, slot, guid);

    local key = guid .. "-" .. name .. container;

    if table[guid][name][container] == nil then
        table[guid][name][container] = {};
    end

    local previous = table[guid][name][container][slot];
    if previous and previous ~= itemId then
        ItemCacheMixin:RemoveItemFromCache(previous, key);
    end
    if ATM_ItemCache[itemId] == nil then
        ATM_ItemCache[itemId] = {};
    end
    if ATM_ItemCache[itemId][key] then
        ATM_ItemCache[itemId][key] = ATM_ItemCache[itemId][key] + 1;
    else
        ATM_ItemCache[itemId][key] = 1;
    end
    table[guid][name][container][slot] = itemId;
end

-- remove item from cache
function ItemCacheMixin:RemoveItemFromCache(itemId, key)
    if ATM_ItemCache[itemId] and ATM_ItemCache[itemId][key] then
        local previousCount = ATM_ItemCache[itemId][key];
        local newCount = previousCount - 1;
        if newCount <= 0 then
            --table.removekey(ATM_ItemCache[itemId], key);
            --print("removing "..key);
            ATM_ItemCache[itemId][key] = nil;
        else
            ATM_ItemCache[itemId][key] = newCount;
        end
    end
end

-- check if an item is in database (with an appearance)
function ItemCacheMixin:IsItemInDatabase(itemId)
    return itemId and app.Items[itemId] and app.ItemsByAppearances[app.Items[itemId].a];
end
