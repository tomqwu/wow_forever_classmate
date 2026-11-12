local _,NS=...
local Core=NS.Core
NS.Folded={}
-- Compact card: a 48 x 48 class crest on top that breaks through the card's
-- upper edge, an engraved divider, then up to four 30 x 30 warning cells.
-- One class-tinted frame surrounds everything; each cell keeps its own amber
-- frame, dark well and inset icon so item art always lines up. With no
-- warnings the card disappears and only the glowing crest remains.
local L={CREST=48,OVER=18,CELL=30,GAP=4,PAD=7,DIVIDER=10,CORNER=12,INSET=3}
NS.Folded.Layout=L
local media='Interface\\AddOns\\ForeverUtilities\\Textures\\'
-- Standard class colors; used only to tint addon-owned frame art.
local classColors={WARRIOR={0.78,0.61,0.43},PALADIN={0.96,0.55,0.73},HUNTER={0.67,0.83,0.45},
    ROGUE={1,0.96,0.41},PRIEST={1,1,1},SHAMAN={0,0.44,0.87},MAGE={0.41,0.8,0.94},
    WARLOCK={0.58,0.51,0.79},DRUID={1,0.49,0.04}}
NS.Folded.ClassColors=classColors

-- Returns width, height, cell row width and the y of the cell row.
function NS.Folded.Size(count)
    if count<=0 then return L.CREST,L.CREST,0,0 end
    local row=count*L.CELL+(count-1)*L.GAP
    local cellY=L.CREST+1+L.DIVIDER+1
    return math.max(64,row+L.PAD*2),cellY+L.CELL+L.PAD,row,cellY
end

local function Level(frame,base,offset)
    if type(base)=='number' and frame.SetFrameLevel then frame:SetFrameLevel(base+offset) end
end

function NS.Folded.Create(host,content,db,module)
    local button=CreateFrame('Button',nil,host)
    button:SetSize(L.CREST,L.CREST);button:SetPoint('TOPLEFT',host,'TOPLEFT',0,0);button:RegisterForDrag('LeftButton');button:EnableMouse(true)
    local main=CreateFrame('Frame',nil,button);main:SetAllPoints(button)
    local token=module and module.classToken
    local color=classColors[token] or {0.8,0.8,0.8}
    local light={0.55+0.45*color[1],0.55+0.45*color[2],0.55+0.45*color[3]}
    -- Draw order, back to front: card, warning halos, cells, cell frames, crest.
    local card=CreateFrame('Frame',nil,main)
    local halos=CreateFrame('Frame',nil,main);halos:SetAllPoints(main)
    local row=CreateFrame('Frame',nil,main);row:SetAllPoints(main)
    local edges=CreateFrame('Frame',nil,main);edges:SetAllPoints(main)
    local top=CreateFrame('Frame',nil,main);top:SetAllPoints(main)
    local base=main.GetFrameLevel and main:GetFrameLevel()
    Level(card,base,1);Level(halos,base,2);Level(row,base,3);Level(edges,base,4);Level(top,base,5)
    local fill=card:CreateTexture(nil,'BACKGROUND')
    fill:SetPoint('TOPLEFT',card,'TOPLEFT',3,-3);fill:SetPoint('BOTTOMRIGHT',card,'BOTTOMRIGHT',-3,3)
    fill:SetColorTexture(0.025,0.025,0.03,0.88)
    -- Nine-slice of the engraved frame: fixed corners, stretched edges.
    local slices={}
    local k=L.CORNER/64
    for _,y in ipairs({{'TOP',0,k},{'MIDDLE',k,1-k},{'BOTTOM',1-k,1}}) do
        for _,x in ipairs({{'LEFT',0,k},{'CENTER',k,1-k},{'RIGHT',1-k,1}}) do
            local slice=card:CreateTexture(nil,'BORDER');slice:SetTexture(media..'IconFrame')
            slice:SetTexCoord(x[2],x[3],y[2],y[3]);slice:SetVertexColor(light[1],light[2],light[3])
            slice.column,slice.row=x[1],y[1];slices[#slices+1]=slice
        end
    end
    local divider=card:CreateTexture(nil,'ARTWORK');divider:SetTexture(media..'Divider')
    divider:SetVertexColor(light[1],light[2],light[3])
    local glow=top:CreateTexture(nil,'BACKGROUND');glow:SetTexture(media..'Glow')
    glow:SetSize(L.CREST+28,L.CREST+28);glow:SetVertexColor(color[1],color[2],color[3],0.55)
    if glow.SetBlendMode then glow:SetBlendMode('ADD') end
    -- The crest identifies the class only. It is never a buff state claim.
    local crest=top:CreateTexture(nil,'ARTWORK');crest:SetSize(L.CREST,L.CREST)
    crest:SetTexture(token and (media..'Classes\\'..token) or (media..'ForeverClassmate'))
    glow:SetPoint('CENTER',crest,'CENTER',0,0)
    -- Spirit glow while dead or a ghost: a pale halo that slowly breathes
    -- behind a faded crest. One native looping animation, no polling.
    local spirit=top:CreateTexture(nil,'BACKGROUND',nil,1);spirit:SetTexture(media..'Glow')
    spirit:SetSize(L.CREST+44,L.CREST+44);spirit:SetPoint('CENTER',crest,'CENTER',0,0)
    spirit:SetVertexColor(0.55,0.8,1,1);spirit:Hide()
    if spirit.SetBlendMode then spirit:SetBlendMode('ADD') end
    local breathe=type(spirit.CreateAnimationGroup)=='function' and spirit:CreateAnimationGroup() or nil
    if breathe then
        local fadeAnim=breathe:CreateAnimation('Alpha')
        fadeAnim:SetFromAlpha(0.35);fadeAnim:SetToAlpha(0.95);fadeAnim:SetDuration(1.6)
        if fadeAnim.SetSmoothing then fadeAnim:SetSmoothing('IN_OUT') end
        breathe:SetLooping('BOUNCE')
    end
    local function Spirit(on)
        spirit:SetShown(on);glow:SetShown(not on)
        crest:SetDesaturated(on)
        if on then crest:SetVertexColor(0.78,0.88,1,1) else crest:SetVertexColor(1,1,1,1) end
        if breathe then
            if on and not breathe:IsPlaying() then breathe:Play()
            elseif not on and breathe:IsPlaying() then breathe:Stop() end
        end
    end
    button:HookScript('OnHide',function() Spirit(false) end)
    -- Cell frames and halos sit on their own frames so the warning pulse fades
    -- only those decorations; wells and icons stay fully readable.
    local pulseEdges=Core.CreateWarningPulse(button,edges)
    local pulseHalos=Core.CreateWarningPulse(button,halos)
    local function pulse(on) pulseEdges(on);pulseHalos(on) end
    local badges,wells,frames,glows={},{},{},{}
    for index=1,4 do
        -- A warm ember rim around each warning cell; the dark well hides its center.
        local halo=halos:CreateTexture(nil,'ARTWORK');halo:SetSize(L.CELL+12,L.CELL+12);halo:SetTexture(media..'CellGlow')
        halo:SetVertexColor(1,0.5,0.12,0.6)
        if halo.SetBlendMode then halo:SetBlendMode('ADD') end
        halo:Hide();glows[index]=halo
        local well=row:CreateTexture(nil,'BACKGROUND');well:SetSize(L.CELL-4,L.CELL-4);well:SetColorTexture(0.03,0.03,0.035,0.92)
        local badge=row:CreateTexture(nil,'ARTWORK');badge:SetSize(L.CELL-L.INSET*2,L.CELL-L.INSET*2)
        badge:SetTexCoord(0.08,0.92,0.08,0.92)
        local frame=edges:CreateTexture(nil,'OVERLAY');frame:SetSize(L.CELL,L.CELL);frame:SetTexture(media..'IconFrame')
        frame:SetVertexColor(1,0.85,0.45)
        well:Hide();badge:Hide();frame:Hide()
        badges[index],wells[index],frames[index]=badge,well,frame
    end
    -- The class stat cell (shards, ammo, Ankhs...): same template in a neutral
    -- frame. It is information, not a warning, so it never glows or pulses.
    local statEdge=CreateFrame('Frame',nil,main);statEdge:SetAllPoints(main);Level(statEdge,base,4)
    local statWell=row:CreateTexture(nil,'BACKGROUND');statWell:SetSize(L.CELL-4,L.CELL-4);statWell:SetColorTexture(0.03,0.03,0.035,0.92)
    local statIcon=row:CreateTexture(nil,'ARTWORK');statIcon:SetSize(L.CELL-L.INSET*2,L.CELL-L.INSET*2)
    statIcon:SetTexCoord(0.08,0.92,0.08,0.92)
    local statFrame=statEdge:CreateTexture(nil,'OVERLAY');statFrame:SetSize(L.CELL,L.CELL);statFrame:SetTexture(media..'IconFrame')
    statFrame:SetVertexColor(0.85,0.87,0.92)
    local statText=statEdge:CreateFontString(nil,'OVERLAY','NumberFontNormal')
    statText:SetPoint('BOTTOMRIGHT',statIcon,'BOTTOMRIGHT',1,-1)
    statWell:Hide();statIcon:Hide();statFrame:Hide();statText:Hide()
    local shownStat
    local visibleWarnings={}
    -- More than four warnings: the tooltip lists all, the last cell counts the rest.
    -- On its own frame: the pulse fades the cell edges, never this text.
    local counter=CreateFrame('Frame',nil,main);counter:SetAllPoints(main);Level(counter,base,5)
    local overflow=counter:CreateFontString(nil,'OVERLAY','NumberFontNormal')
    overflow:SetPoint('BOTTOMRIGHT',badges[4],'BOTTOMRIGHT',-1,1);overflow:Hide()
    local border=host.outline
    -- A plain glyph on the expanded shell's outline; no second button border.
    local fold=CreateFrame('Button',nil,host.shell)
    fold:SetSize(14,24);fold:SetPoint('RIGHT',host.shell,'RIGHT',-5,0)
    local glyph=fold:CreateFontString(nil,'OVERLAY','GameFontHighlight');glyph:SetPoint('CENTER',fold,'CENTER',0,0);glyph:SetText('<')
    glyph:SetTextColor(0.8,0.85,0.9)
    fold.glyph=glyph
    -- A view the player picks is theirs: revival must not undo it.
    fold:SetScript('OnClick',function() db.collapsed=true;db.foldedByDeath=nil;module.Apply() end)
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
    -- A drag on a locked crest is still a drag, never a click to expand.
    button:SetScript('OnDragStart',function() dragged=true;if not db.locked then host.shell:StartMoving() end end)
    button:SetScript('OnDragStop',function() local fn=host:GetScript('OnDragStop');if fn then fn(host) end end)
    -- While dead the bar has no live content to show; revival expands it.
    button:SetScript('OnClick',function()
        if dragged or Core.PlayerDead()==true then return end
        db.collapsed=false;db.foldedByDeath=nil;module.Apply()
    end)
    button:SetScript('OnEnter',function(self)
        host.hovered=true
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP')
        GameTooltip:SetText(NS.L(Core.PlayerDead()==true and 'Expands when you are alive' or 'Click to expand'))
        if shownStat then GameTooltip:AddLine(NS.L(shownStat.label)..': '..shownStat.text,0.85,0.9,1) end
        for _,warning in ipairs(visibleWarnings) do GameTooltip:AddLine(NS.L(warning.label),1,0.75,0.35,true) end
        if #visibleWarnings==0 then GameTooltip:AddLine(NS.L('No confirmed missing buffs'),0.75,0.75,0.75,true) end
        if not db.locked then GameTooltip:AddLine(NS.L('Drag to move'),0.75,0.75,0.75) end
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave',function()
        host.hovered=false;if GameTooltip then GameTooltip:Hide() end
        if content.baseAlpha then NS.ClassHost.SetFade(host,content,content.baseAlpha) end
    end)
    local function LayoutCard(width,height)
        card:ClearAllPoints();card:SetPoint('TOPLEFT',host,'TOPLEFT',0,-L.OVER);card:SetSize(width,height-L.OVER)
        local inner,innerH=width-L.CORNER*2,height-L.OVER-L.CORNER*2
        for _,slice in ipairs(slices) do
            local w=slice.column=='CENTER' and inner or L.CORNER
            local h=slice.row=='MIDDLE' and innerH or L.CORNER
            local x=slice.column=='LEFT' and 0 or (slice.column=='CENTER' and L.CORNER or width-L.CORNER)
            local y=slice.row=='TOP' and 0 or (slice.row=='MIDDLE' and L.CORNER or height-L.OVER-L.CORNER)
            slice:SetSize(w,h);slice:ClearAllPoints();slice:SetPoint('TOPLEFT',card,'TOPLEFT',x,-y)
        end
        divider:SetSize(width-L.PAD*2,L.DIVIDER);divider:ClearAllPoints()
        divider:SetPoint('TOPLEFT',host,'TOPLEFT',L.PAD,-(L.CREST+1))
    end
    local function Refresh()
        local collapsed=db.collapsed==true
        button:SetShown(db.enabled and collapsed)
        -- An expanded bar whose content is hidden (dead, icon-only without a
        -- target) shows no empty frame and exposes no hit target.
        local empty=not collapsed and not content:IsShown()
        fold:SetShown(db.enabled and not collapsed and not empty and db.showFoldButton~=false)
        host:EnableMouse(db.enabled==true and not empty)
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
        -- The stat comes from the class module through ClassHost.SetStat; this
        -- view never reads game data itself.
        shownStat=nil
        if collapsed and db.enabled and db.compactStat~=false and not Core.PlayerDead() and content:IsShown() then
            local stat=host.foldStat
            if type(stat)=='table' and type(stat.text)=='string' and stat.text~='' and Core.Icon(stat.icon) then shownStat=stat end
        end
        local total=collapsed and #visibleWarnings or 0
        local offset=shownStat and 1 or 0
        local shownWarnings=math.min(4-offset,total)
        local count=offset+shownWarnings
        local width,height,rowWidth,cellY=NS.Folded.Size(count)
        if collapsed then
            host:SetSize(width,height);button:SetSize(width,height)
            host.shell:SetSize(width+8,height+8)
        end
        crest:ClearAllPoints();crest:SetPoint('TOPLEFT',host,'TOPLEFT',(width-L.CREST)/2,0)
        card:SetShown(count>0);row:SetShown(count>0);halos:SetShown(count>0)
        if count>0 then LayoutCard(width,height) end
        local firstX=(width-rowWidth)/2
        for _,region in ipairs({statWell,statIcon,statFrame,statText}) do region:SetShown(shownStat~=nil) end
        if shownStat then
            statIcon:SetTexture(Core.Icon(shownStat.icon));statText:SetText(shownStat.text)
            local c=shownStat.color or {1,1,1};statText:SetTextColor(c[1],c[2],c[3])
            statIcon:ClearAllPoints();statIcon:SetPoint('TOPLEFT',host,'TOPLEFT',firstX+L.INSET,-(cellY+L.INSET))
            statWell:ClearAllPoints();statWell:SetPoint('TOPLEFT',host,'TOPLEFT',firstX+2,-(cellY+2))
            statFrame:ClearAllPoints();statFrame:SetPoint('TOPLEFT',host,'TOPLEFT',firstX,-cellY)
        end
        for index,badge in ipairs(badges) do
            local warning=visibleWarnings[index]
            local shown=warning~=nil and index<=shownWarnings
            badge:SetShown(shown);wells[index]:SetShown(shown);frames[index]:SetShown(shown);glows[index]:SetShown(shown)
            if shown then
                local x=firstX+(index-1+offset)*(L.CELL+L.GAP)
                badge:SetTexture(Core.Icon(warning.icon))
                badge:ClearAllPoints();badge:SetPoint('TOPLEFT',host,'TOPLEFT',x+L.INSET,-(cellY+L.INSET))
                wells[index]:ClearAllPoints();wells[index]:SetPoint('TOPLEFT',host,'TOPLEFT',x+2,-(cellY+2))
                frames[index]:ClearAllPoints();frames[index]:SetPoint('TOPLEFT',host,'TOPLEFT',x,-cellY)
                glows[index]:ClearAllPoints();glows[index]:SetPoint('TOPLEFT',host,'TOPLEFT',x-6,-(cellY-6))
            end
        end
        local hidden=total-shownWarnings
        overflow:SetShown(hidden>0);overflow:SetText(hidden>0 and ('+'..hidden) or '')
        if hidden>0 then overflow:ClearAllPoints();overflow:SetPoint('BOTTOMRIGHT',badges[shownWarnings],'BOTTOMRIGHT',-1,1) end
        local warning=#visibleWarnings>0
        -- Frame art follows the content's rendered alpha. The compact crest
        -- stays readable while idle; warnings stay fully visible.
        local alpha=NS.ClassHost.ContentAlpha(host,content)
        if collapsed then alpha=(warning or host.hovered) and 1 or math.max(0.8,alpha) end
        Spirit(collapsed and db.enabled==true and Core.PlayerDead())
        button:SetAlpha(alpha);fold:SetAlpha(alpha)
        -- The compact card brings its own frame; the expanded shell panel is hidden.
        if host.shellFill then host.shellFill:SetAlpha((collapsed or empty) and 0 or alpha) end
        border:SetShown(not collapsed and not empty)
        if border.SetWarm then border.SetWarm(warning) end
        pulse(collapsed and db.enabled and warning and db.flashMissingBuffs~=false)
        border:SetAlpha(alpha)
    end
    host.foldRefresh=Refresh
    content:HookScript('OnHide',Refresh);content:HookScript('OnShow',Refresh)
    return {Refresh=Refresh,overflow=overflow,button=button,fold=fold,badges=badges,wells=wells,frames=frames,glows=glows,halos=halos,
        edges=edges,card=card,slices=slices,divider=divider,glow=glow,fill=fill,border=border,
        primary=crest,crest=crest,main=main,row=row,spirit=spirit,spiritAnimation=breathe,
        stat={well=statWell,icon=statIcon,frame=statFrame,text=statText}}
end
