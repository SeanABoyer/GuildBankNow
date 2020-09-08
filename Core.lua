local BankRecentlyUpdated = false
GuildBankNow = LibStub("AceAddon-3.0"):NewAddon("GuildBankNow","AceEvent-3.0","AceConsole-3.0")


function GuildBankNow:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildBankNowDB")
    -- Update Bank
    GuildBankNow:RegisterEvent("BANKFRAME_CLOSED",updateBankData)
    -- Update Bags
    GuildBankNow:RegisterEvent("PLAYER_LOGIN",updateBackpackData)
    -- Slash Commands
    GuildBankNow:RegisterChatCommand("GBNRefresh",updateBackpackData)
    GuildBankNow:RegisterChatCommand("GuildBankNowRefresh",updateBackpackData)
    
end

function getCurrentTime()
    local d = C_DateAndTime.GetTodaysDate()
    local hours, minutes = GetGameTime()
    return d.month.."/"..d.day.."/"..d.year.." "..hours..":"..minutes
end

function GuildBankNow:OnEnable()
    if(self.db.char.Bank == nil) then
        self.db.char.Bank = {
            Items = {}
        }
    end
    if(self.db.char.Bag == nil) then
    self.db.char.Bag = {
        Items = {}
    }
    end
end

function updateBankData()
    -- If we can't access the bank, then don't update anything.
    if(BankRecentlyUpdated) then
        BankRecentlyUpdated = false
        return
    end

    local items = {}

    -- Check Bank tab area
    local bankSlotCount = GetContainerNumSlots(-1);
    for k=0,bankSlotCount,1 do
        local texture, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID  = GetContainerItemInfo(-1,k)
        local item = createItemData(-1,"bankContainer",k,itemLink,itemID,itemCount)
        table.insert(items,item)
    end
    -- Check bank Bags
    for i=5,10,1 do
        -- Check if they have extra bags
        local bagName = GetBagName(i)
        if(bagName) then
            GuildBankNow.db.char.Bank.Items[tostring(i)] = {}
            local bagSlotCount = GetContainerNumSlots(i)
            for j=0,bagSlotCount,1 do
                local texture, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID  = GetContainerItemInfo(i,j)
                local item = createItemData(i,"bankContainer",j,itemLink,itemID,itemCount)
                GuildBankNow.db.char.Bank.Items[tostring(i)][tostring(j)] = item;
            end
        end
    end
    GuildBankNow.db.char.Bank.lastScanned = getCurrentTime()
    BankRecentlyUpdated = true
    
    GuildBankNow:Print("Bank Refreshed")
    updateBackpackData()
end

function updateBackpackData()
    -- If we can't access the bag, then don't update anything    
    if(GetContainerNumSlots(0) == nil) then
        return
    end

    local items = {}
    for i=0,4,1 do
        -- Check if they have bags
        local bagName = GetBagName(i)
        if(bagName) then
            GuildBankNow.db.char.Bag.Items[tostring(i)] = {}
            local bagSlotCount = GetContainerNumSlots(i)
            for j=1,bagSlotCount,1 do
                local texture, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID  = GetContainerItemInfo(i,j)
                local item = createItemData(i,"playerContainer",j,itemLink,itemID,itemCount)
                GuildBankNow.db.char.Bag.Items[tostring(i)][tostring(j)] = item;
            end
        end
    end
    GuildBankNow.db.char.Bag.lastScanned = getCurrentTime()
    GuildBankNow:Print("Bags Refreshed")
end

function createItemData(containerNumber,containerType,slotNumber,itemLink,itemID,count)
    local item = {}
    item["itemLink"] = itemLink 
    item["ID"] = itemID
    item["count"] = count
    item["containerNumber"] = containerNumber
    item["containerType"] = containerType
    item["slotNumber"] = slotNumber
    --if(item["itemLink"]) then
    --    GuildBankNow:Print("Documenting "..tostring(item["count"]).."x"..item["itemLink"])
    --end
    
    return item
end