local _, NS = ...
local Core=NS.Core
local Context={}
NS.ShamanContext=Context

local Call=Core.Call

function Context.FormatTime(seconds)
    if not Core.IsNumber(seconds) or seconds<0 then return nil end
    seconds=math.ceil(seconds)
    if seconds>=60 then return math.ceil(seconds/60)..'m' end
    return seconds..'s'
end

function Context.Totem(slot)
    if type(GetTotemInfo)~='function' then return nil end
    local ok,have,name,start,duration,icon,_,spellID=pcall(GetTotemInfo,slot)
    if not ok then return nil end
    local left=Call(GetTotemTimeLeft,slot)
    local readableName=Core.IsReadable(name) and type(name)=='string'
    local active=(readableName and name~='') or (Core.IsNumber(left) and left>0)
    if not active then
        -- The first return value can mean the elemental reagent is owned,
        -- rather than that a summoned totem currently occupies this slot.
        if Core.IsReadable(have) and have==false and readableName and name=='' then
            return {active=false,slot=slot}
        end
        return nil
    end
    -- Forever can expose a name while the icon and timing fields are still 0.
    -- Such placeholders must not replace a usable cast observation or timer.
    start=Core.IsNumber(start) and start>=0 and start or nil
    duration=Core.IsNumber(duration) and duration>0 and duration or nil
    left=Core.IsNumber(left) and left>0 and left or nil
    if not left and start and duration then
        local now=Call(GetTime)
        if Core.IsNumber(now) then left=math.max(0,start+duration-now) end
    end
    return {active=true,slot=slot,name=readableName and name or '',icon=Core.Icon(icon),
        spellID=Core.IsNumber(spellID) and spellID>0 and spellID or nil,
        start=duration and start or nil,duration=duration,left=left}
end

-- True only when the client confirms the item is a weapon (not a shield or
-- held-in-off-hand item); nil when its class cannot be read.
function Context.IsWeapon(itemID)
    local weaponClass=Enum and Enum.ItemClass and Enum.ItemClass.Weapon
    if not Core.IsNumber(itemID) or not Core.IsNumber(weaponClass) then return nil end
    local ok,_,_,_,_,_,classID=pcall(C_Item and C_Item.GetItemInfoInstant,itemID)
    if not ok or not Core.IsNumber(classID) then return nil end
    return classID==weaponClass
end

-- Main hand by default; pass true for the off hand. The off hand may hold a
-- shield, so it is a warning only when the client confirms a weapon there.
function Context.WeaponImbue(offHand)
    if type(GetInventoryItemID)~='function' then return nil end
    local inventorySlot=offHand and 17 or 16
    local ok,itemID=pcall(GetInventoryItemID,'player',inventorySlot)
    if not ok or not Core.IsReadable(itemID) then return nil end
    if itemID==nil then return {equipped=false} end
    if not Core.IsNumber(itemID) or itemID<=0 then return nil end
    local texture=Call(GetInventoryItemTexture,'player',inventorySlot)
    local api=C_Item and C_Item.GetWeaponEnchantInfo
    local slots=Enum and Enum.WeaponSlot
    -- Never fall back to the main hand when the off-hand enum is missing.
    local slot=slots and (offHand and slots.OffHand or not offHand and slots.MainHand) or nil
    if type(api)~='function' or not Core.IsNumber(slot) then return nil end
    local enchants=Call(api,slot)
    if type(enchants)~='table' then return nil end
    for _,enchant in pairs(enchants) do
        if type(enchant)~='table' or not Core.IsReadable(enchant.hasEnchant) or type(enchant.hasEnchant)~='boolean' then return nil end
        if enchant.hasEnchant==true then
            local milliseconds=enchant.timeLeft
            local left=Core.IsNumber(milliseconds) and math.max(0,milliseconds/1000) or nil
            local icon=Core.Icon(enchant.enchantIconID) or Core.Icon(texture)
            return {equipped=true,active=true,left=left,icon=icon,charges=Core.IsNumber(enchant.charges) and enchant.charges or nil,
                weapon=Context.IsWeapon(itemID)}
        end
    end
    return {equipped=true,active=false,icon=Core.Icon(texture),weapon=Context.IsWeapon(itemID)}
end

function Context.Aura(unit,filter,names,requirePlayer)
    return NS.ClassContext.Aura(unit,filter,names,requirePlayer)
end

function Context.MissingShield(names)
    -- No learned shield (low level, or names not found) is unknown, not missing.
    if type(names)~='table' or not next(names) then return nil end
    local aura=Context.Aura('player','HELPFUL',names,false)
    if type(aura)=='table' then return false,aura end
    if aura==nil then return nil end
    local combat=Call(UnitAffectingCombat,'player')
    local dead=Call(UnitIsDead,'player')
    if combat==true and dead==false then return true end
    return false
end

-- Exact mana first; when that is restricted, the documented UnitPowerPercent
-- reading through the shared reader. A secret percentage stays unavailable.
function Context.ManaPercent()
    local power=NS.ClassContext.Power(0,'Mana')
    return power and power.percent or nil
end
