local _,NS=...
local Core=NS.Core
NS.Folded={}
-- Compact strip: a fixed 32 x 32 class crest, then up to four 32 x 32 warning
-- cells in one row. Every cell uses one template (dark well, engraved frame,
-- inset cropped icon), so item art with or without its own square background
-- lines up the same way.
local CELL,GAP,CREST_GAP,INSET=32,2,4,3
NS.Folded.CELL,NS.Folded.GAP,NS.Folded.CREST_GAP=CELL,GAP,CREST_GAP
local media='Interface\\AddOns\\ForeverUtilities\\Textures\\'
function NS.Folded.Width(count)
    if count<=0 then return CELL end
    return CELL+CREST_GAP+count*CELL+(count-1)*GAP
end
function NS.Folded.Create(host,content,db,module)
    local button=CreateFrame('Button',nil,host)
    button:SetSize(CELL,CELL);button:SetPoint('TOPLEFT',host,'TOPLEFT',0,0);button:RegisterForDrag('LeftButton');button:EnableMouse(true)
    local main=CreateFrame('Frame',nil,button);main:SetAllPoints(button)
    -- The class crest identifies the module. It is never a buff state claim.
    local crest=main:CreateTexture(nil,'ARTWORK');crest:SetSize(CELL,CELL);crest:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    local token=module and module.classToken
    local crestTexture=token and (media..'Classes\\'..token) or (media..'ForeverClassmate')
    crest:SetTexture(crestTexture)
    local row=CreateFrame('Frame',nil,main);row:SetAllPoints(main)
    -- Frames sit on their own child so the warning pulse fades only the
    -- engraved edges; wells and icons stay fully readable.
    local edges=CreateFrame('Frame',nil,row);edges:SetAllPoints(row)
    local cells=CreateFrame('Frame',nil,row);cells:SetAllPoints(row)
    local pulse=Core.CreateWarningPulse(button,edges)
    local badges,wells,frames={},{},{}
    for index=1,4 do
        local well=cells:CreateTexture(nil,'BACKGROUND');well:SetSize(CELL-4,CELL-4);well:SetColorTexture(0.03,0.03,0.035,0.88)
        local badge=cells:CreateTexture(nil,'ARTWORK');badge:SetSize(CELL-INSET*2,CELL-INSET*2)
        badge:SetTexCoord(0.08,0.92,0.08,0.92)
        local frame=edges:CreateTexture(nil,'OVERLAY');frame:SetSize(CELL,CELL);frame:SetTexture(media..'IconFrame')
        frame:SetVertexColor(1,0.78,0.45)
        well:Hide();badge:Hide();frame:Hide()
        badges[index],wells[index],frames[index]=badge,well,frame
    end
    -- Edges draw above the icon so the engraving overlaps a clean icon crop.
    if edges.SetFrameLevel and cells.GetFrameLevel then edges:SetFrameLevel((cells:GetFrameLevel() or 0)+1) end
    local visibleWarnings={}
    -- More than four warnings: the tooltip lists all, the last icon counts the rest.
    local overflow=edges:CreateFontString(nil,'OVERLAY','NumberFontNormal')
    overflow:SetPoint('BOTTOMRIGHT',badges[4],'BOTTOMRIGHT',-1,1);overflow:Hide()
    local border=host.outline
    -- A plain glyph on the shell's own outline; no second button border.
    local fold=CreateFrame('Button',nil,host.shell)
    fold:SetSize(14,24);fold:SetPoint('RIGHT',host.shell,'RIGHT',-5,0)
    local glyph=fold:CreateFontString(nil,'OVERLAY','GameFontHighlight');glyph:SetPoint('CENTER',fold,'CENTER',0,0);glyph:SetText('<')
    glyph:SetTextColor(0.8,0.85,0.9)
    fold.glyph=glyph
    fold:SetScript('OnClick',function() db.collapsed=true;module.Apply() end)
    fold:SetScript('OnEnter',function(self)
        glyph:SetTextColor(1,1,1)
        if GameTooltip then
            GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L('Collapse to warning icons'));GameTooltip:Show()
        end
    end)
    fold:SetScript('OnLeave',function()
        glyph:SetTextColor(0.8,0.85,0.9)
        if GameTooltip then GameTooltip:Hide() end
    end)
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
        -- Collected in both views: collapsed shows the icons, expanded only
        -- warms the outline (its slots already carry the detail and pulse).
        if db.enabled and not Core.PlayerDead() then
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
        local total=collapsed and #visibleWarnings or 0
        local count=math.min(4,total)
        local width=NS.Folded.Width(count)
        if collapsed then
            host:SetSize(width,CELL);button:SetSize(width,CELL)
            host.shell:SetSize(width+8,CELL+8)
        end
        row:SetShown(count>0)
        for index,badge in ipairs(badges) do
            local warning=visibleWarnings[index]
            local shown=warning~=nil and index<=count
            badge:SetShown(shown);wells[index]:SetShown(shown);frames[index]:SetShown(shown)
            if shown then
                local x=CELL+CREST_GAP+(index-1)*(CELL+GAP)
                badge:SetTexture(Core.Icon(warning.icon))
                badge:ClearAllPoints();badge:SetPoint('TOPLEFT',host,'TOPLEFT',x+INSET,-INSET)
                wells[index]:ClearAllPoints();wells[index]:SetPoint('TOPLEFT',host,'TOPLEFT',x+2,-2)
                frames[index]:ClearAllPoints();frames[index]:SetPoint('TOPLEFT',host,'TOPLEFT',x,0)
            end
        end
        overflow:SetShown(total>4);overflow:SetText(total>4 and ('+'..(total-4)) or '')
        local warning=#visibleWarnings>0
        -- Frame art follows the content's rendered alpha. The compact crest
        -- stays readable while idle; warnings stay fully visible.
        local alpha=NS.ClassHost.ContentAlpha(host,content)
        if collapsed then alpha=(warning or host.hovered) and 1 or math.max(0.8,alpha) end
        button:SetAlpha(alpha);fold:SetAlpha(alpha)
        -- Compact mode has no panel behind the crest and cells.
        host.shell:SetBackdropColor(0.04,0.045,0.055,collapsed and 0 or 0.55*alpha)
        border:SetShown(not collapsed)
        border:SetBackdropBorderColor(warning and 1 or 0.65,warning and 0.65 or 0.65,warning and 0.2 or 0.65,0.9)
        pulse(collapsed and db.enabled and warning and db.flashMissingBuffs~=false)
        border:SetAlpha(alpha)
    end
    host.foldRefresh=Refresh
    content:HookScript('OnHide',Refresh);content:HookScript('OnShow',Refresh)
    return {Refresh=Refresh,overflow=overflow,button=button,fold=fold,badges=badges,wells=wells,frames=frames,
        edges=edges,border=border,primary=crest,crest=crest,main=main,row=row}
end
