local _,NS=...
local Core=NS.Core
NS.Folded={}
function NS.Folded.Create(host,content,db,module)
    local button=CreateFrame('Button',nil,host)
    button:SetSize(64,64);button:SetPoint('TOPLEFT',host,'TOPLEFT',0,0);button:RegisterForDrag('LeftButton');button:EnableMouse(true)
    local main=CreateFrame('Frame',nil,button);main:SetAllPoints(button)
    local logo=main:CreateTexture(nil,'ARTWORK');logo:SetPoint('TOPLEFT',3,-3);logo:SetPoint('BOTTOMRIGHT',-3,3);logo:SetTexCoord(0.08,0.92,0.08,0.92)
    -- Neutral identity art is never a claim that a class buff is missing/active.
    local fallback='Interface\\AddOns\\ForeverUtilities\\Textures\\ForeverClassmate'
    -- Both views use the same image-based frame, owned by the host.
    local border=host.outline
    local pulse=Core.CreateWarningPulse(button,border)
    local row=CreateFrame('Frame',nil,main);row:SetAllPoints(main)
    local badges={}
    for index=1,4 do
        local badge=row:CreateTexture(nil,'ARTWORK');badge:SetSize(32,32)
        badge:SetTexCoord(0.08,0.92,0.08,0.92);badge:Hide();badges[index]=badge
    end
    local visibleWarnings={}
    local fold=CreateFrame('Button',nil,host.shell,'UIPanelButtonTemplate')
    fold:SetSize(14,18);fold:SetPoint('RIGHT',host.shell,'RIGHT',-5,0);fold:SetText('<')
    fold:SetScript('OnClick',function() db.collapsed=true;module.Apply() end)
    local dragged=false
    button:SetScript('OnMouseDown',function() dragged=false end)
    button:SetScript('OnDragStart',function() if not db.locked then dragged=true;host.shell:StartMoving() end end)
    button:SetScript('OnDragStop',function() local fn=host:GetScript('OnDragStop');if fn then fn(host) end end)
    button:SetScript('OnClick',function() if not dragged then db.collapsed=false;module.Apply() end end)
    button:SetScript('OnEnter',function(self)
        host.hovered=true
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L('Click to expand'))
        for _,warning in ipairs(visibleWarnings) do GameTooltip:AddLine(NS.L(warning.label),1,0.75,0.35,true) end
        if #visibleWarnings==0 then GameTooltip:AddLine(NS.L('No confirmed missing buffs'),0.75,0.75,0.75,true) end
        if not db.locked then GameTooltip:AddLine(NS.L('Drag to move'),0.75,0.75,0.75) end
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
        visibleWarnings={}
        if collapsed and db.enabled and not Core.PlayerDead() then
            if content:IsShown() then
                for _,key in ipairs({'upkeep','imbue','shield','aspect'}) do
                    local warning=host.foldWarnings and host.foldWarnings[key]
                    if warning and warning.active==true and Core.Icon(warning.icon) then visibleWarnings[#visibleWarnings+1]=warning end
                end
            end
            for _,key in ipairs({'food','sleepingBag'}) do
                local warning=host.foldLevelWarnings and host.foldLevelWarnings[key]
                if warning and warning.active==true and Core.Icon(warning.icon) then visibleWarnings[#visibleWarnings+1]=warning end
            end
        end
        logo:SetTexture(fallback)
        local count=math.min(4,#visibleWarnings)
        -- Size the actual host and shell to the visible rows, not an empty
        -- square above/below them. The saved shell center remains unchanged.
        local columns=math.min(2,count)
        local rows=math.ceil(count/2)
        local width=count>0 and columns*34-2 or 64
        local height=count>0 and rows*34-2 or 64
        if collapsed then
            host:SetSize(width,height);button:SetSize(width,height)
            host.shell:SetSize(width+8,height+8)
        end
        logo:SetShown(count==0)
        row:SetShown(count>0)
        for index,badge in ipairs(badges) do
            local warning=visibleWarnings[index]
            badge:SetShown(index<=count)
            if warning and index<=count then
                badge:SetTexture(Core.Icon(warning.icon))
                local line=math.floor((index-1)/2)
                local lineColumns=math.min(2,count-line*2)
                badge:ClearAllPoints();badge:SetPoint('TOPLEFT',host,'TOPLEFT',
                    (width-(lineColumns*34-2))/2+((index-1)%2)*34,-line*34)
            end
        end
        local warning=count>0
        local alpha=(warning or host.hovered) and 1 or (collapsed and math.max(0.35,content.baseAlpha or 1) or (content.baseAlpha or 1))
        button:SetAlpha(alpha);fold:SetAlpha(alpha)
        host.shell:SetBackdropColor(0.04,0.045,0.055,0.55*alpha)
        border:SetBackdropBorderColor(warning and 1 or 0.65,warning and 0.65 or 0.65,warning and 0.2 or 0.65,0.9)
        pulse(collapsed and db.enabled and warning and db.flashMissingBuffs~=false)
        border:SetAlpha(alpha)
    end
    host.foldRefresh=Refresh
    content:HookScript('OnHide',Refresh);content:HookScript('OnShow',Refresh)
    return {Refresh=Refresh,button=button,fold=fold,badges=badges,border=border,primary=logo,main=main,row=row}
end
