local _, NS = ...
local Core=NS.Core
local Context={}
NS.ShamanContext=Context

local function Call(fn,...)
    if type(fn)~='function' then return nil end
    local values={pcall(fn,...)}
    if not table.remove(values,1) then return nil end
    for _,value in ipairs(values) do if not Core.IsReadable(value) then return nil end end
    return unpack(values)
end

function Context.FormatTime(seconds)
    if not Core.IsNumber(seconds) or seconds<0 then return nil end
    seconds=math.ceil(seconds)
    if seconds>=60 then return math.ceil(seconds/60)..'m' end
    return seconds..'s'
end

function Context.Totem(slot)
    if type(GetTotemInfo)~='function' then return nil end
    local ok,have,name,start,duration,icon=pcall(GetTotemInfo,slot)
    if not ok or not Core.IsReadable(have) or type(have)~='boolean' then return nil end
    if not have then return {active=false,slot=slot} end
    for _,value in ipairs({name,start,duration,icon}) do if not Core.IsReadable(value) then return nil end end
    local left=Call(GetTotemTimeLeft,slot)
    if not Core.IsNumber(left) and Core.IsNumber(start) and Core.IsNumber(duration) then
        local now=Call(GetTime)
        if Core.IsNumber(now) then left=math.max(0,start+duration-now) end
    end
    return {active=true,slot=slot,name=type(name)=='string' and name or '',icon=Core.IsNumber(icon) and icon or nil,
        start=Core.IsNumber(start) and start or nil,duration=Core.IsNumber(duration) and duration or nil,
        left=Core.IsNumber(left) and math.max(0,left) or nil}
end

function Context.WeaponImbue()
    if type(GetInventoryItemID)~='function' then return nil end
    local ok,itemID=pcall(GetInventoryItemID,'player',16)
    if not ok or not Core.IsReadable(itemID) then return nil end
    if itemID==nil then return {equipped=false} end
    if not Core.IsNumber(itemID) or itemID<=0 then return nil end
    local texture=Call(GetInventoryItemTexture,'player',16)
    local api=C_Item and C_Item.GetWeaponEnchantInfo
    local slot=Enum and Enum.WeaponSlot and Enum.WeaponSlot.MainHand
    if type(api)~='function' or not Core.IsNumber(slot) then return nil end
    local enchants=Call(api,slot)
    if type(enchants)~='table' then return nil end
    for _,enchant in pairs(enchants) do
        if type(enchant)~='table' or not Core.IsReadable(enchant.hasEnchant) then return nil end
        if enchant.hasEnchant==true then
            local milliseconds=enchant.timeLeft
            local left=Core.IsNumber(milliseconds) and math.max(0,milliseconds/1000) or nil
            local icon=Core.IsNumber(enchant.enchantIconID) and enchant.enchantIconID or texture
            return {equipped=true,active=true,left=left,icon=icon,charges=Core.IsNumber(enchant.charges) and enchant.charges or nil}
        end
    end
    return {equipped=true,active=false,icon=texture}
end

function Context.Aura(unit,filter,names,requirePlayer)
    if type(names)~='table' or not next(names) then return nil end
    local api=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(api)~='function' then return nil end
    local unknown=false
    for index=1,255 do
        local ok,aura=pcall(api,unit,index,filter)
        if not ok or not Core.IsReadable(aura) then return nil end
        if aura==nil then if unknown then return nil end;return false end
        if type(aura)~='table' or not Core.IsReadable(aura.name) then unknown=true
        elseif names[aura.name] then
            local sourceOK=true
            if requirePlayer then
                if not Core.IsReadable(aura.sourceUnit) then return nil end
                sourceOK=aura.sourceUnit=='player' or Call(UnitIsUnit,aura.sourceUnit,'player')==true
            end
            if sourceOK then
                local left
                if Core.IsNumber(aura.expirationTime) and aura.expirationTime>0 then
                    local now=Call(GetTime);if Core.IsNumber(now) then left=math.max(0,aura.expirationTime-now) end
                end
                return {name=aura.name,icon=Core.IsNumber(aura.icon) and aura.icon or nil,
                    applications=Core.IsNumber(aura.applications) and aura.applications or 0,left=left}
            end
        end
    end
    return nil
end

function Context.MissingShield(names)
    local aura=Context.Aura('player','HELPFUL',names,false)
    if type(aura)=='table' then return false,aura end
    if aura==nil then return nil end
    local combat=Call(UnitAffectingCombat,'player')
    local dead=Call(UnitIsDead,'player')
    if combat==true and dead==false then return true end
    return false
end

function Context.FlameShock(name)
    if type(name)~='string' or name=='' then return nil end
    if Call(UnitCanAttack,'player','target')~=true or Call(UnitIsDead,'target')~=false then return false end
    return Context.Aura('target','HARMFUL',{[name]=true},false)
end

function Context.ManaPercent()
    local current=Call(UnitPower,'player',0)
    local maximum=Call(UnitPowerMax,'player',0)
    if not Core.IsNumber(current) or not Core.IsNumber(maximum) or maximum<=0 then return nil end
    return math.max(0,math.min(100,math.floor(current*100/maximum+0.5)))
end
