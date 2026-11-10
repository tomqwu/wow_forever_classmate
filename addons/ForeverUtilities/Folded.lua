local _,NS=...
local Core=NS.Core
NS.Folded={}
function NS.Folded.Create(host,content,db,module)
    local button=CreateFrame('Button',nil,host)
    button:SetSize(64,64);button:SetPoint('TOPLEFT',host,'TOPLEFT',0,0);button:RegisterForDrag('LeftButton');button:EnableMouse(true)
    local background=button:CreateTexture(nil,'BACKGROUND');background:SetAllPoints();background:SetColorTexture(0.025,0.025,0.03,0.95)
    local logo=button:CreateTexture(nil,'ARTWORK');logo:SetPoint('TOPLEFT',3,-3);logo:SetPoint('BOTTOMRIGHT',-3,3)
    local _,token=Core.Call(UnitClass,'player')
    local classIcons={WARLOCK='Spell_Shadow_DemonArmor',MAGE='Spell_Frost_FrostArmor02',PRIEST='Spell_Holy_InnerFire',
        WARRIOR='Ability_Warrior_BattleShout',ROGUE='Ability_Stealth',DRUID='Spell_Nature_Regeneration',
        HUNTER='Ability_Hunter_BeastCall',SHAMAN='Spell_Nature_LightningShield',PALADIN='Spell_Holy_DevotionAura'}
    local fallback='Interface\\Icons\\'..(classIcons[token] or 'Spell_Holy_SealOfProtection')
    -- Pulse only a one-pixel outline, never a solid rectangle behind transparent artwork.
    local border=CreateFrame('Frame',nil,button);border:SetAllPoints()
    local edges={}
    for _,side in ipairs({'TOP','BOTTOM','LEFT','RIGHT'}) do
        local edge=border:CreateTexture(nil,'OVERLAY');edge:SetColorTexture(0.55,0.5,0.35,1)
        edge:SetPoint(side,border,side,0,0)
        edge:SetSize((side=='TOP' or side=='BOTTOM') and 64 or 1,(side=='TOP' or side=='BOTTOM') and 1 or 64)
        edges[#edges+1]=edge
    end
    local pulse=Core.CreateWarningPulse(button,border)
    local row=CreateFrame('Button',nil,button);row:SetSize(64,24)
    row:SetPoint('TOPLEFT',button,'BOTTOMLEFT',0,-6);row:RegisterForDrag('LeftButton');row:EnableMouse(true)
    local strip=row:CreateTexture(nil,'BACKGROUND');strip:SetAllPoints(row);strip:SetColorTexture(0.02,0.02,0.025,0.92)
    local badges={}
    for index=1,3 do
        local badge=row:CreateTexture(nil,'ARTWORK');badge:SetSize(20,20);badge:Hide();badges[index]=badge
    end
    local visibleWarnings={}
    local fold=CreateFrame('Button',nil,host,'UIPanelButtonTemplate')
    fold:SetSize(18,18);fold:SetPoint('BOTTOMRIGHT',host,'TOPRIGHT',0,3);fold:SetText('<')
    fold:SetScript('OnClick',function() db.collapsed=true;module.Apply() end)
    local dragged=false
    button:SetScript('OnMouseDown',function() dragged=false end)
    button:SetScript('OnDragStart',function() if not db.locked then dragged=true;host:StartMoving() end end)
    button:SetScript('OnDragStop',function() local fn=host:GetScript('OnDragStop');if fn then fn(host) end end)
    button:SetScript('OnClick',function() if not dragged then db.collapsed=false;module.Apply() end end)
    button:SetScript('OnEnter',function(self)
        host.hovered=true
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L('Click to expand'))
        for _,warning in ipairs(visibleWarnings) do GameTooltip:AddLine(NS.L(warning.label),1,0.75,0.35,true) end
        if not db.locked then GameTooltip:AddLine(NS.L('Drag to move'),0.75,0.75,0.75) end
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave',function()
        host.hovered=false;if GameTooltip then GameTooltip:Hide() end
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
    end)
    for _,event in ipairs({'OnMouseDown','OnDragStart','OnDragStop','OnClick','OnEnter','OnLeave'}) do
        row:SetScript(event,button:GetScript(event))
    end
    local function Refresh()
        local collapsed=db.collapsed==true
        button:SetShown(db.enabled and collapsed)
        fold:SetShown(db.enabled and not collapsed and db.showFoldButton~=false)
        visibleWarnings={}
        if collapsed and db.enabled and not Core.PlayerDead() then
            if content:IsShown() then
                for _,key in ipairs({'upkeep','imbue','shield','aspect'}) do
                    local warning=host.foldWarnings and host.foldWarnings[key]
                    if warning and warning.active then visibleWarnings[#visibleWarnings+1]=warning end
                end
            end
            for _,key in ipairs({'food','sleepingBag'}) do
                local warning=host.foldLevelWarnings and host.foldLevelWarnings[key]
                if warning and warning.active then visibleWarnings[#visibleWarnings+1]=warning end
            end
        end
        local primary=visibleWarnings[1]
        logo:SetTexture(primary and Core.Icon(primary.icon) or fallback)
        local count=math.min(3,math.max(0,#visibleWarnings-1))
        row:SetShown(count>0)
        for index,badge in ipairs(badges) do
            local warning=visibleWarnings[index+1]
            badge:SetShown(index<=count)
            if warning and index<=count then
                badge:SetTexture(Core.Icon(warning.icon) or fallback)
                badge:ClearAllPoints();badge:SetPoint('TOPLEFT',row,'TOPLEFT',(64-(count*22-2))/2+(index-1)*22,-2)
            end
        end
        local warning=primary~=nil
        button:SetAlpha((warning or host.hovered) and 1 or math.max(0.35,content.baseAlpha or 1))
        for _,edge in ipairs(edges) do edge:SetColorTexture(warning and 1 or 0.55,warning and 0.6 or 0.5,warning and 0.15 or 0.35,1) end
        pulse(collapsed and db.enabled and warning and db.flashMissingBuffs~=false)
    end
    host.foldRefresh=Refresh
    content:HookScript('OnHide',Refresh);content:HookScript('OnShow',Refresh)
    return {Refresh=Refresh,button=button,fold=fold,badges=badges,border=border,primary=logo,strip=strip,edges=edges,row=row}
end
