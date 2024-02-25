local appName, app = ...;
-- item cache : bags, equipment, mail, bank, guildbank
ItemCacheMixin = {};

-- played GUID
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
    if GuildBankInventory == nil then
        GuildBankInventory = {};
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
    self:RegisterEvent("MAIL_INBOX_UPDATE")

    self:ParseBags();
    self:ParseEquipment();
end

-- event trigger
function ItemCacheMixin:OnEvent(eventName, ...)
    --print("debug event "..eventName);
    if eventName == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = ...;
        if slot >= C_Container.ContainerIDToInventoryID(1) then
            return;
        end
        local itemId = GetInventoryItemID("player", slot);
        self:UpdateItem(itemId, ATM_CharacterInventory, "e", slot, 1);
    elseif eventName == "BAG_UPDATE" then
        local bag = ...;
        self:ParseBag(bag);
    elseif eventName == "BANKFRAME_OPENED" then
        self:ParseBankBags();
    elseif eventName == "MAIL_INBOX_UPDATE" then
        self:ParseMails();
    end
end

-- parse all equipment
function ItemCacheMixin:ParseEquipment()
    for slot = 0, C_Container.ContainerIDToInventoryID(1) - 1 do
        local itemId = GetInventoryItemID("player", slot);
        self:UpdateItem(itemId, ATM_CharacterInventory, "e", slot, 1);
    end
end

-- parse all mails
function ItemCacheMixin:ParseMails()
    for mail = 1, (GetInboxNumItems()) do
        for attachment = 1, ATTACHMENTS_MAX do
            local link = GetInboxItemLink(mail, attachment);
            if link then
                local _, itemId = GetInboxItem(mail, attachment)
                self:UpdateItem(itemId, ATM_CharacterInventory, "m", mail, attachment);
                -- item mail has been retrieved, so delete it
            elseif ATM_CharacterInventory[playerGuid]["m"][mail] and ATM_CharacterInventory[playerGuid]["m"][mail][attachment] then
                local previous = ATM_CharacterInventory[playerGuid]["m"][mail][attachment];
                local key = playerGuid .. "-m" .. mail;
                self:RemoveItemFromCache(previous, mail);
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
        self:UpdateItem(itemId, ATM_CharacterInventory, "b", bag, slot);
    end
end

-- update item
-- table : ATM_CharacterInventory, ATM_GuildBankInventory
-- name : b=bag, e=equipment, m=mail ...
-- container : bag id or equipement id
-- slot : bag slot id or 1 for equipment
function ItemCacheMixin:UpdateItem(itemId, table, name, container, slot)
    -- only if item is in database
    if not self:IsItemInDatabase(itemId) then
        return;
    end
    --print("updateitem "..itemId.." "..name.." "..container.." "..slot);

    local key = playerGuid .. "-" .. name .. container;

    if table[playerGuid][name][container] == nil then
        table[playerGuid][name][container] = {};
    end

    local previous = table[playerGuid][name][container][slot];
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
    table[playerGuid][name][container][slot] = itemId;
end

-- update mail
function ItemCacheMixin:UpdateMailInventory(itemId)
end

-- update cache
function ItemCacheMixin:UpdateItemCache(itemId)
    -- check if item is in database
    if itemId and app.Items[itemId] and app.ItemsByAppearances[app.Items[itemId].a] then
        if ATM_ItemCache[itemId] == nil then
            ATM_ItemCache[itemId] = {};
        end
        if ATM_ItemCache[itemId].c == nil then
            ATM_ItemCache[itemId].c = {};
        end
        ATM_ItemCache[itemId].c[playerGuid] = 1;
    end
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
