local _,NS=...
local Core=NS.Core
local Buffs={SleepingBagID=429959,FoodXPID=1243969}
NS.LevelingBuffs=Buffs

-- The XP effect is hidden. Observe Well Fed as a food reminder, without
-- claiming a measured XP multiplier or assuming every meal grants XP.
-- The representative IDs also resolve the client's localized family name.
local foodIDs={[Buffs.FoodXPID]=true,[1248406]=true,[1248420]=true,[1248421]=true}
local foodNames={['Well Fed']=true,['进食充分']=true}
local foodNameResolved=false
local function ResolveFoodName()
    if foodNameResolved then return end
    local info=Core.Call(C_Spell and C_Spell.GetSpellInfo,1248406)
    if type(info)=='table' and Core.IsReadable(info.name) and type(info.name)=='string' and info.name~='' then
        foodNames[info.name]=true;foodNameResolved=true
    end
end

-- Returns true for confirmed absence, false for an observed aura, nil for
-- unavailable data. Only requested features inspect their aura fields.
function Buffs.Missing(level,wantBag,wantFood)
    if not wantBag and not wantFood then return nil,nil end
    if not Core.IsNumber(level) or level<1 or level>=60 then return nil,nil end
    if Core.Call(UnitIsDeadOrGhost or UnitIsDead,'player')~=false
        or Core.Call(UnitAffectingCombat,'player')~=false then return nil,nil end
    local scan=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(scan)~='function' then return nil,nil end
    if wantFood then ResolveFoodName() end
    local locale=wantFood and Core.Call(GetLocale)
    local canClassifyFoodName=foodNameResolved or locale=='enUS' or locale=='enGB' or locale=='zhCN'
    local bag,food,bagUnknown,foodUnknown
    for index=1,255 do
        local ok,aura=pcall(scan,'player',index,'HELPFUL')
        if not ok or not Core.IsReadable(aura) then return bag,food end
        if aura==nil then
            if wantBag and bag==nil and not bagUnknown then bag=true end
            if wantFood and food==nil and not foodUnknown then food=true end
            return bag,food
        end
        if type(aura)~='table' then bagUnknown=true;foodUnknown=true
        else
            local id=Core.IsNumber(aura.spellId) and aura.spellId or nil
            if wantBag and bag==nil then
                if not id then bagUnknown=true
                elseif id==Buffs.SleepingBagID then bag=false end
            end
            if wantFood and food==nil then
                if id and foodIDs[id] then food=false
                elseif Core.IsReadable(aura.name) and type(aura.name)=='string' and aura.name~='' then
                    if foodNames[aura.name] then food=false end
                    if not id or not canClassifyFoodName then foodUnknown=true end
                else foodUnknown=true end
            end
        end
        if (not wantBag or bag==false) and (not wantFood or food==false) then return bag,food end
    end
    return bag,food
end

function Buffs.Create(host,content,db)
    local controller=CreateFrame('Frame',nil,host)
    local indicators={}
    host.foldLevelWarnings={}
    local definitions={
        {key='sleepingBag',option='sleepingBagReminder',itemID=211527,title='Cozy Sleeping Bag',
            fallback='Interface\\Icons\\INV_Misc_Bag_BigBagofEnchantments',
            hint='Well-Rested is missing. Rest in a sleeping bag to gain the buff.',
            detail='Any active stack clears this reminder. Shown below level 60, outside combat.'},
        {key='food',option='foodXPReminder',itemID=2681,title='Food XP buff (+5% from kills)',
            fallback='Interface\\Icons\\INV_Misc_Food_18',
            hint='Well Fed is missing. Eat food whose tooltip grants +5% XP from kills.',
            detail='Checks Well Fed; the hidden XP bonus is not measured. Shown below level 60, outside combat.'},
    }
    for _,definition in ipairs(definitions) do
        local button=CreateFrame('Button',nil,host)
        button:SetSize(16,16);button:EnableMouse(true);button:Hide()
        -- Same amber cell as the compact card: engraved frame, ember halo, cropped icon.
        local border=button:CreateTexture(nil,'ARTWORK')
        border:SetAllPoints();Core.StyleWarningFrame(border,button)
        local icon=button:CreateTexture(nil,'ARTWORK')
        icon:SetSize(16,16);icon:SetPoint('CENTER');icon:SetTexCoord(0.08,0.92,0.08,0.92)
        icon:SetTexture(Core.Icon(Core.Call(C_Item and C_Item.GetItemIconByID,definition.itemID)) or definition.fallback)
        indicators[definition.key]={button=button,border=border,icon=icon,pulse=Core.CreateWarningPulse(host,border)}
        host.foldLevelWarnings[definition.key]={active=false,icon=Core.Icon(Core.Call(C_Item and C_Item.GetItemIconByID,definition.itemID)) or definition.fallback,label=definition.hint}
        button:SetScript('OnEnter',function(self)
            if not GameTooltip then return end
            GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L(definition.title))
            GameTooltip:AddLine(NS.L(definition.hint),1,1,1,true)
            GameTooltip:AddLine(NS.L(definition.detail),1,0.85,0.5,true)
            GameTooltip:Show()
        end)
        button:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
    local events={'PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_REGEN_ENABLED',
        'PLAYER_REGEN_DISABLED','PLAYER_LEVEL_UP','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST'}
    local active,suspended,retired=false,false,false
    local function Fade()
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
        -- Reminder changes are card changes even when the fade is unchanged.
        if host.foldRefresh then host.foldRefresh() end
    end
    local function Clear()
        host.levelingBuffMissing=false
        for _,warning in pairs(host.foldLevelWarnings) do warning.active=false end
        for _,indicator in pairs(indicators) do
            indicator.pulse(false);indicator.button:Hide()
            if GameTooltip and GameTooltip:IsOwned(indicator.button) then GameTooltip:Hide() end
        end
        Fade()
    end
    local function SetEvents(wanted)
        if wanted==active then return end
        for _,event in ipairs(events) do
            if wanted then controller:RegisterEvent(event) else controller:UnregisterEvent(event) end
        end
        -- Only the player's own auras matter; other units never wake this.
        if wanted then
            if controller.RegisterUnitEvent then controller:RegisterUnitEvent('UNIT_AURA','player') else controller:RegisterEvent('UNIT_AURA') end
        else controller:UnregisterEvent('UNIT_AURA') end
        active=wanted
    end
    local function Refresh(level)
        local wantBag=db.sleepingBagReminder~=false
        local wantFood=db.foodXPReminder~=false
        if not db.enabled or retired or (not wantBag and not wantFood) then SetEvents(false);Clear();return end
        level=level or Core.Call(UnitLevel,'player')
        if Core.IsNumber(level) and level>=60 then retired=true;SetEvents(false);Clear();return end
        SetEvents(true)
        if suspended or Core.Call(host.IsShown,host)==false or Core.Call(host.IsVisible,host)==false then Clear();return end
        local bag,food=Buffs.Missing(level,wantBag,wantFood)
        local states={sleepingBag=bag,food=food}
        host.levelingBuffMissing=false
        local slot=0
        for index,definition in ipairs(definitions) do
            local indicator=indicators[definition.key]
            host.foldLevelWarnings[definition.key].active=db[definition.option]~=false and states[definition.key]==true
            if host.foldLevelWarnings[definition.key].active then
                slot=slot+1
                indicator.button:ClearAllPoints()
                local size=db.rangeIconOnly and 18 or 22
                indicator.button:SetSize(size,size);indicator.icon:SetSize(size-6,size-6)
                if db.collapsed then indicator.button:SetPoint('TOPRIGHT',host,'TOPRIGHT',-3,-3-38*(index-1))
                elseif db.rangeIconOnly then indicator.button:SetPoint('TOPLEFT',host,'TOPRIGHT',3,-20*(index-1))
                else
                    -- A small tab above the bar's right end, clear of the lock and slots.
                    indicator.button:SetPoint('BOTTOMRIGHT',host,'TOPRIGHT',-26*(slot-1),10)
                end
                indicator.button:SetShown(not db.collapsed);indicator.pulse(not db.collapsed and db.flashMissingBuffs~=false)
                host.levelingBuffMissing=true
            else
                indicator.pulse(false);indicator.button:Hide()
                if GameTooltip and GameTooltip:IsOwned(indicator.button) then GameTooltip:Hide() end
            end
        end
        Fade()
    end
    controller:SetScript('OnEvent',function(_,event,unit)
        if event=='UNIT_AURA' and (not Core.IsReadable(unit) or unit~='player') then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then suspended=true;Clear();return end
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then suspended=false end
        Refresh(event=='PLAYER_LEVEL_UP' and Core.IsNumber(unit) and unit or nil)
    end)
    host:HookScript('OnHide',Clear)
    host:HookScript('OnShow',function() Refresh() end)
    return {Refresh=Refresh,indicators=indicators,controller=controller}
end
