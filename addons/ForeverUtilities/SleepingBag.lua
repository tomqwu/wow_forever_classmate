local _,NS=...
local Core=NS.Core
local Bag={BuffID=429959,ItemID=211527}
NS.SleepingBag=Bag

-- Forever's Well-Rested sleeping-bag aura. This is not the Legacy perk
-- "Well Rested" or the ordinary rested-XP state. See docs/sleeping-bag.md.
function Bag.Missing(level)
    if not Core.IsNumber(level) or level<1 or level>=60 then return nil end
    if Core.Call(UnitIsDeadOrGhost or UnitIsDead,'player')~=false
        or Core.Call(UnitAffectingCombat,'player')~=false then return nil end
    local scan=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(scan)~='function' then return nil end
    local unknown=false
    for index=1,255 do
        local ok,aura=pcall(scan,'player',index,'HELPFUL')
        if not ok or not Core.IsReadable(aura) then return nil end
        if aura==nil then return not unknown and true or nil end
        if type(aura)~='table' or not Core.IsNumber(aura.spellId) then unknown=true
        elseif aura.spellId==Bag.BuffID then return false end
    end
    return nil
end

function Bag.Create(host,content,db)
    local button=CreateFrame('Button',nil,host)
    button:SetSize(16,16);button:EnableMouse(true);button:Hide()
    local border=button:CreateTexture(nil,'BACKGROUND')
    border:SetAllPoints();border:SetColorTexture(1,0.4,0.08,1)
    local icon=button:CreateTexture(nil,'ARTWORK')
    icon:SetSize(12,12);icon:SetPoint('CENTER')
    icon:SetTexture(Core.Icon(Core.Call(C_Item and C_Item.GetItemIconByID,Bag.ItemID))
        or 'Interface\\Icons\\INV_Misc_Bag_BigBagofEnchantments')
    local pulse=Core.CreateWarningPulse(host,border)
    local events={'PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_REGEN_ENABLED',
        'PLAYER_REGEN_DISABLED','PLAYER_LEVEL_UP','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST','UNIT_AURA'}
    local active,suspended=false,false
    local function Clear()
        host.sleepingBagMissing=false;pulse(false);button:Hide()
        if GameTooltip and GameTooltip:IsOwned(button) then GameTooltip:Hide() end
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
    end
    local function SetEvents(wanted)
        if wanted==active then return end
        for _,event in ipairs(events) do
            if wanted then button:RegisterEvent(event) else button:UnregisterEvent(event) end
        end
        active=wanted
    end
    local function Refresh(level)
        if not db.enabled or db.sleepingBagReminder==false then SetEvents(false);Clear();return end
        level=level or Core.Call(UnitLevel,'player')
        if Core.IsNumber(level) and level>=60 then SetEvents(false);Clear();return end
        SetEvents(true)
        if Core.Call(host.IsShown,host)==false or Core.Call(host.IsVisible,host)==false then Clear();return end
        if suspended or Bag.Missing(level)~=true then Clear();return end
        button:ClearAllPoints()
        if db.rangeIconOnly then button:SetPoint('TOPLEFT',host,'TOPRIGHT',3,0)
        else button:SetPoint('TOPRIGHT',host,'TOPRIGHT',-8,1) end
        host.sleepingBagMissing=true;button:Show()
        pulse(db.flashMissingBuffs~=false)
        NS.ClassHost.SetFade(host,content,content.baseAlpha or 1)
    end
    button:SetScript('OnEvent',function(_,event,unit)
        if event=='UNIT_AURA' and (not Core.IsReadable(unit) or unit~='player') then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then suspended=true;Clear();return end
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then suspended=false end
        Refresh(event=='PLAYER_LEVEL_UP' and Core.IsNumber(unit) and unit or nil)
    end)
    button:SetScript('OnEnter',function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L('Cozy Sleeping Bag'))
        GameTooltip:AddLine(NS.L('Well-Rested is missing. Rest in a sleeping bag to gain the buff.'),1,1,1,true)
        GameTooltip:AddLine(NS.L('Any active stack clears this reminder. Shown below level 60, outside combat.'),1,0.85,0.5,true)
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    host:HookScript('OnHide',Clear)
    host:HookScript('OnShow',function() Refresh() end)
    return {Refresh=Refresh,button=button,border=border}
end
