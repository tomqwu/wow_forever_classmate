local _,NS=...
local Core=NS.Core
NS.Folded={}
function NS.Folded.Create(host,content,db,module)
    local button=CreateFrame('Button',nil,host)
    button:SetAllPoints(host);button:RegisterForDrag('LeftButton');button:EnableMouse(true)
    local border=button:CreateTexture(nil,'BACKGROUND');border:SetAllPoints();border:SetColorTexture(0.65,0.52,0.22,1)
    local logo=button:CreateTexture(nil,'ARTWORK');logo:SetPoint('TOPLEFT',3,-3);logo:SetPoint('BOTTOMRIGHT',-3,3)
    logo:SetTexture('Interface\\AddOns\\ForeverUtilities\\Textures\\ForeverClassmate')
    local pulse=Core.CreateWarningPulse(button,border)
    local badges={}
    for index=1,2 do
        local badge=button:CreateTexture(nil,'OVERLAY');badge:SetSize(22,22)
        badge:SetPoint('TOPLEFT',button,'TOPLEFT',3,-3-(index-1)*36);badge:Hide();badges[index]=badge
    end
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
        for _,warning in pairs(host.foldWarnings or {}) do
            if warning.active and content:IsShown() and not Core.PlayerDead() then GameTooltip:AddLine(NS.L(warning.label),1,0.5,0.2,true) end
        end
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave',function()
        host.hovered=false;if GameTooltip then GameTooltip:Hide() end
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
    end)
    local function Refresh()
        local collapsed=db.collapsed==true
        button:SetShown(db.enabled and collapsed)
        fold:SetShown(db.enabled and not collapsed and db.showFoldButton~=false)
        local count=0
        if collapsed and db.enabled and content:IsShown() and not Core.PlayerDead() then
            for _,key in ipairs({'upkeep','imbue','shield','aspect'}) do
                local warning=host.foldWarnings and host.foldWarnings[key]
                if warning and warning.active and count<2 then
                    count=count+1;badges[count]:SetTexture(Core.Icon(warning.icon) or 'Interface\\Icons\\Spell_Holy_SealOfProtection');badges[count]:Show()
                end
            end
        end
        for index=count+1,2 do badges[index]:Hide() end
        local warning=count>0 or host.levelingBuffMissing==true
        button:SetAlpha((warning or host.hovered) and 1 or math.max(0.35,content.baseAlpha or 1))
        border:SetColorTexture(warning and 1 or 0.65,warning and 0.25 or 0.52,warning and 0.08 or 0.22,1)
        pulse(collapsed and db.enabled and warning and db.flashMissingBuffs~=false)
    end
    host.foldRefresh=Refresh
    content:HookScript('OnHide',Refresh);content:HookScript('OnShow',Refresh)
    return {Refresh=Refresh,button=button,fold=fold,badges=badges,border=border}
end
