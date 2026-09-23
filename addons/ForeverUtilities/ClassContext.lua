local _, NS = ...
local Core=NS.Core
local Context={}
NS.ClassContext=Context

local function Call(fn,...)
    return Core.Call(fn,...)
end

function Context.FormatTime(seconds)
    if not Core.IsNumber(seconds) or seconds<0 then return nil end
    seconds=math.ceil(seconds)
    if seconds>=60 then return math.ceil(seconds/60)..'m' end
    return seconds..'s'
end

function Context.Discover(catalog)
    local spells,wanted,aliases={},{},{}
    if type(catalog)~='table' or not C_SpellBook or not C_Spell or not Enum or not Enum.SpellBookSpellBank then return spells end
    local function Want(name,entry)
        if type(name)~='string' then return end
        if not wanted[name] then wanted[name]={} end
        wanted[name][#wanted[name]+1]=entry
    end
    for _,entry in ipairs(catalog) do
        aliases[entry.key]={}
        for _,candidate in ipairs(entry.names or {}) do
            Want(candidate,entry)
            aliases[entry.key][candidate]=true
            local info=Call(C_Spell.GetSpellInfo,candidate)
            local name=type(info)=='table' and info.name
            if Core.IsReadable(name) and type(name)=='string' and name~=candidate then Want(name,entry);aliases[entry.key][name]=true end
        end
    end
    local lineCount=Call(C_SpellBook.GetNumSpellBookSkillLines)
    if not Core.IsNumber(lineCount) then return spells end
    local seen={}
    for line=1,lineCount do
        local lineInfo=Call(C_SpellBook.GetSpellBookSkillLineInfo,line)
        if type(lineInfo)=='table' and Core.IsNumber(lineInfo.itemIndexOffset) and Core.IsNumber(lineInfo.numSpellBookItems) then
            for slot=lineInfo.itemIndexOffset+1,lineInfo.itemIndexOffset+lineInfo.numSpellBookItems do
                local item=Call(C_SpellBook.GetSpellBookItemInfo,slot,Enum.SpellBookSpellBank.Player)
                local id=type(item)=='table' and item.spellID
                if Core.IsNumber(id) and not seen[id] and Core.IsReadable(item.isPassive) and Core.IsReadable(item.isOffSpec)
                    and not item.isOffSpec and (Call(C_SpellBook.IsSpellKnown,id)==true
                        or (Core.IsNumber(item.baseSpellID) and Call(C_SpellBook.IsSpellKnown,item.baseSpellID)==true)) then
                    seen[id]=true
                    local info=Call(C_Spell.GetSpellInfo,id)
                    local entries=type(info)=='table' and Core.IsReadable(info.name) and wanted[info.name]
                    if not entries and Core.IsNumber(item.baseSpellID) then
                        local base=Call(C_Spell.GetSpellInfo,item.baseSpellID)
                        entries=type(base)=='table' and Core.IsReadable(base.name) and wanted[base.name]
                    end
                    local level=Call(C_Spell.GetSpellLevelLearned,id)
                    for _,entry in ipairs(entries or {}) do
                        local previous=spells[entry.key]
                        if type(info)=='table' and Core.IsReadable(info.name) and type(info.name)=='string'
                            and (not item.isPassive or entry.allowPassive)
                            and (not previous or (Core.IsNumber(level) and Core.IsNumber(previous.level) and level>previous.level)) then
                            spells[entry.key]={id=id,name=info.name,icon=Core.Icon(info.iconID),slot=slot,
                                kind=entry.kind,priority=entry.priority or 100,passive=item.isPassive==true,level=level,auraNames=aliases[entry.key]}
                        end
                    end
                end
            end
        end
    end
    return spells
end

function Context.Names(spells,keys)
    local names={}
    for _,key in ipairs(keys or {}) do
        local spell=spells and spells[key]
        if spell and type(spell.name)=='string' then names[spell.name]=true end
        if spell then for name in pairs(spell.auraNames or {}) do names[name]=true end end
    end
    return names
end

function Context.Aura(unit,filter,names,requirePlayer)
    if type(names)~='table' or not next(names) then return false end
    local api=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(api)~='function' then return nil end
    local uncertain=false
    for index=1,255 do
        local ok,aura=pcall(api,unit,index,filter)
        if not ok or not Core.IsReadable(aura) then return nil end
        if aura==nil then if uncertain then return nil end;return false end
        if type(aura)~='table' or not Core.IsReadable(aura.name) or type(aura.name)~='string' or aura.name=='' then uncertain=true
        elseif names[aura.name] then
            local sourceOK=true
            if requirePlayer then
                if Core.IsReadable(aura.sourceUnit) and type(aura.sourceUnit)=='string' then
                    sourceOK=aura.sourceUnit=='player' or Call(UnitIsUnit,aura.sourceUnit,'player')==true
                elseif Core.IsReadable(aura.isFromPlayerOrPlayerPet) and type(aura.isFromPlayerOrPlayerPet)=='boolean' then sourceOK=aura.isFromPlayerOrPlayerPet
                else return nil end
            end
            if sourceOK then
                local left
                if Core.IsNumber(aura.expirationTime) and aura.expirationTime>0 then
                    local now=Call(GetTime)
                    if Core.IsNumber(now) then left=math.max(0,aura.expirationTime-now) end
                end
                return {name=aura.name,icon=Core.Icon(aura.icon),
                    applications=Core.IsNumber(aura.applications) and aura.applications or nil,left=left}
            end
        end
    end
    return nil
end

function Context.Power(powerType,label)
    local current=Call(UnitPower,'player',powerType)
    local maximum=Call(UnitPowerMax,'player',powerType)
    if not Core.IsNumber(current) or not Core.IsNumber(maximum) or maximum<=0 then return nil end
    return {current=math.max(0,current),maximum=maximum,percent=math.max(0,math.min(100,math.floor(current*100/maximum+0.5))),label=label}
end

function Context.CurrentPower()
    local powerType,token=Call(UnitPowerType,'player')
    if not Core.IsNumber(powerType) then return nil end
    local labels={MANA='Mana',RAGE='Rage',ENERGY='Energy'}
    return Context.Power(powerType,labels[token] or (type(token)=='string' and token or 'Power'))
end

function Context.HealthPercent(unit)
    local current=Call(UnitHealth,unit)
    local maximum=Call(UnitHealthMax,unit)
    if not Core.IsNumber(current) or not Core.IsNumber(maximum) or maximum<=0 then return nil end
    return math.max(0,math.min(100,math.floor(current*100/maximum+0.5)))
end

function Context.ComboPoints()
    local points=Call(GetComboPoints,'player','target')
    if not Core.IsNumber(points) and Enum and Enum.PowerType then points=Call(UnitPower,'player',Enum.PowerType.ComboPoints) end
    return Core.IsNumber(points) and math.max(0,points) or nil
end

function Context.Form()
    local index=Call(GetShapeshiftForm)
    if not Core.IsNumber(index) or index<=0 then return nil end
    local texture,active,_,spellID=Call(GetShapeshiftFormInfo,index)
    if active~=true then return nil end
    local info=Core.IsNumber(spellID) and Call(C_Spell and C_Spell.GetSpellInfo,spellID) or nil
    local name=type(info)=='table' and Core.IsReadable(info.name) and info.name or nil
    return {name=type(name)=='string' and name or 'Active form',icon=Core.Icon(texture),spellID=spellID}
end

function Context.WeaponCoatings()
    if not C_Item or type(C_Item.GetWeaponEnchantInfo)~='function' or not Enum or not Enum.WeaponSlot then return nil end
    local result={equipped=0,active=0,main=false,off=false}
    for _,entry in ipairs({{slot=16,enum=Enum.WeaponSlot.MainHand,key='main'},{slot=17,enum=Enum.WeaponSlot.OffHand,key='off'}}) do
        if type(GetInventoryItemID)~='function' then return nil end
        local ok,itemID=pcall(GetInventoryItemID,'player',entry.slot)
        if not ok or not Core.IsReadable(itemID) then return nil end
        if Core.IsNumber(itemID) and itemID>0 then
            result.equipped=result.equipped+1
            local enchants=Call(C_Item.GetWeaponEnchantInfo,entry.enum)
            if type(enchants)~='table' then return nil end
            for _,enchant in pairs(enchants) do
                if type(enchant)~='table' or not Core.IsReadable(enchant.hasEnchant) or type(enchant.hasEnchant)~='boolean' then return nil end
                if enchant.hasEnchant==true then result.active=result.active+1;result[entry.key]=true;break end
            end
        elseif itemID~=nil then return nil end
    end
    return result
end

function Context.ItemCount(name)
    local count=Call(C_Item and C_Item.GetItemCount,name,false,false,false)
    if not Core.IsNumber(count) then count=Call(GetItemCount,name,false) end
    return Core.IsNumber(count) and math.max(0,count) or nil
end

function Context.Cooldown(spell)
    if type(spell)~='table' or not Core.IsNumber(spell.id) then return nil end
    local start,duration,enabled
    local info=Call(C_Spell and C_Spell.GetSpellCooldown,spell.id)
    if type(info)=='table' then start,duration,enabled=info.startTime,info.duration,info.isEnabled
    elseif type(GetSpellCooldown)=='function' then start,duration,enabled=Call(GetSpellCooldown,spell.id) end
    if not Core.IsReadable(enabled) or (type(enabled)~='boolean' and enabled~=0 and enabled~=1) then return nil end
    if enabled==false or enabled==0 then return {left=nil,enabled=false} end
    if not Core.IsNumber(start) or not Core.IsNumber(duration) or start<0 or duration<0 then return nil end
    local left=0
    if duration>0 then
        local now=Call(GetTime)
        if not Core.IsNumber(now) then return nil end
        left=math.max(0,start+duration-now)
    end
    return {left=left,enabled=true}
end

function Context.SpellState(spell)
    if type(spell)~='table' then return nil end
    local cooldown=Context.Cooldown(spell)
    local usable,noResource=Call(C_Spell and C_Spell.IsSpellUsable,spell.id)
    if usable==nil and type(IsUsableSpell)=='function' then usable,noResource=Call(IsUsableSpell,spell.id) end
    if usable~=nil and type(usable)~='boolean' then usable=nil end
    if noResource~=nil and type(noResource)~='boolean' then noResource=nil end
    local left=cooldown and cooldown.left or nil
    local status='unknown'
    if Core.IsNumber(left) and left>0 then status='cooldown'
    elseif left==0 and usable==true then status='ready'
    elseif left==0 and usable==false then status='context' end
    return {spell=spell,usable=usable,noResource=noResource,left=left,status=status,ready=status=='ready'}
end

function Context.BestCue(spells,keys)
    local ready,cooling,waiting
    for _,key in ipairs(keys or {}) do
        local spell=spells and spells[key]
        if spell then
            local state=Context.SpellState(spell)
            if state and state.ready then return state end
            if state and Core.IsNumber(state.left) and state.left>0 and (not cooling or state.left<cooling.left) then cooling=state end
            waiting=waiting or state
        end
    end
    return cooling or waiting
end

local racialCatalog={
    {key='willToSurvive',names={'Will to Survive'},kind='racial',priority=1},
    {key='stoneform',names={'Stoneform'},kind='racial',priority=1},
    {key='findTreasure',names={'Find Treasure'},kind='racial',priority=3},
    {key='elunesLight',names={"Elune's Light",'Elunes Light'},kind='racial',priority=1},
    {key='eureka',names={'Eureka!','Eureka'},kind='racial',priority=1},
    {key='bloodFury',names={'Blood Fury'},kind='racial',priority=1},
    {key='shatterCurse',names={'Shatter Curse'},kind='racial',priority=2},
    {key='willForsaken',names={'Will of the Forsaken'},kind='racial',priority=1},
    {key='warStomp',names={'War Stomp'},kind='racial',priority=1},
    {key='berserking',names={'Berserking'},kind='racial',priority=1},
    {key='readLeyLine',names={'Read Ley Line'},kind='racial',priority=1},
    {key='skysight',names={'Skysight'},kind='racial',priority=1},
    {key='walkOnAir',names={'Walk on Air'},kind='racial',priority=3},
    {key='escapeArtist',names={'Escape Artist'},kind='racial',priority=2},
    {key='shadowmeld',names={'Shadowmeld'},kind='racial',priority=2},
    {key='perception',names={'Perception'},kind='racial',priority=3},
    {key='cannibalize',names={'Cannibalize'},kind='racial',priority=3},
    {key='rapidRegeneration',names={'Rapid Regeneration'},kind='racial',priority=3},
    {key='divineGrace',names={'Divine Grace'},kind='priestRacial',priority=1},
    {key='feedback',names={'Feedback'},kind='priestRacial',priority=2},
    {key='desperatePrayer',names={'Desperate Prayer'},kind='priestRacial',priority=1},
    {key='chastise',names={'Chastise'},kind='priestRacial',priority=2},
    {key='starshards',names={'Starshards'},kind='priestRacial',priority=1},
    {key='elunesGrace',names={"Elune's Grace",'Elunes Grace'},kind='priestRacial',priority=2},
    {key='confoundingFlash',names={'Confounding Flash'},kind='priestRacial',priority=1},
    {key='contingencyPlan',names={'Contingency Plan'},kind='priestRacial',priority=2},
    {key='touchWeakness',names={'Touch of Weakness'},kind='priestRacial',priority=1},
    {key='darkSacrifice',names={'Dark Sacrifice'},kind='priestRacial',priority=2},
    {key='hexWeakness',names={'Hex of Weakness'},kind='priestRacial',priority=1},
    {key='shadowguard',names={'Shadowguard'},kind='priestRacial',priority=2},
}
Context.RacialCatalog=racialCatalog

function Context.RacialStates(spells,classToken)
    local states={}
    for _,entry in ipairs(racialCatalog) do
        local spell=spells and spells[entry.key]
        if spell and (entry.kind=='racial' or classToken=='PRIEST') then
            local state=Context.SpellState(spell)
            if state then states[#states+1]=state end
        end
    end
    local rank={ready=0,cooldown=1,context=2,unknown=3}
    table.sort(states,function(a,b)
        if classToken=='PRIEST' and a.spell.kind~=b.spell.kind then
            return a.spell.kind=='priestRacial'
        end
        local ar,br=rank[a.status] or 4,rank[b.status] or 4
        if ar~=br then return ar<br end
        if ar==1 and a.left~=b.left then return a.left<b.left end
        local ap=a.spell.priority or 100
        local bp=b.spell.priority or 100
        if ap~=bp then return ap<bp end
        return (a.spell.name or '')<(b.spell.name or '')
    end)
    return states
end

function Context.Racial(spells,classToken)
    return Context.RacialStates(spells,classToken)[1]
end
