local _, NS = ...
local Host={}
NS.ClassHost=Host

function Host.SetWarning(host,key,active,icon,label)
    host.foldWarnings=host.foldWarnings or {}
    host.foldWarnings[key]={active=active==true,icon=icon,label=label}
    if host.foldRefresh then host.foldRefresh() end
end

-- The alpha the content actually renders at. Frame art uses the same value so a
-- leveling reminder or hover never leaves bright icons inside a faded frame.
function Host.ContentAlpha(host,content)
    if host.hovered==true or host.levelingBuffMissing==true then return 1 end
    local alpha=content.baseAlpha
    return type(alpha)=='number' and alpha or 1
end

function Host.SetFade(host,content,alpha)
    content.baseAlpha=alpha
    content:SetAlpha(Host.ContentAlpha(host,content))
    if host.updatePolling then host.updatePolling() end
    if host.foldRefresh then host.foldRefresh() end
end

-- Native SetUserPlaced throws on a frame that is neither movable nor resizable,
-- so the flag is cleared while movable and the final movability restored after.
local function DetachNativePlacement(frame,movable)
    NS.Core.Call(frame.SetDontSavePosition,frame,true)
    frame:SetMovable(true)
    pcall(frame.SetUserPlaced,frame,false)
    frame:SetMovable(movable)
end

-- Distance from the compact shell's top to the crest center (4px padding
-- plus half of the 48px crest).
Host.CompactCrestOffset=28

-- Expanded bars center on the saved point. The compact card keeps the crest
-- centered on that point and grows downward and sideways around it, so
-- warnings never move the crest.
function Host.Place(host,db)
    local shell=host.shell
    shell:ClearAllPoints()
    if db.collapsed and NS.Folded then
        shell:SetPoint('TOP',UIParent,'CENTER',db.x,db.y+Host.CompactCrestOffset)
    else
        shell:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
    end
end

-- Fold or expand through the module's own Apply, so every dependent
-- feature (DoT sidebars, reminders) refreshes as it does for a click.
function Host.SetFold(module,db,collapsed)
    if db.collapsed==collapsed then return end
    db.collapsed=collapsed
    if module.Apply then module.Apply() end
end

-- Expanded in confirmed combat, folded when confirmed out of combat; an
-- unreadable combat state leaves the current view alone.
function Host.SyncCombatFold(module,db)
    local combat=NS.Core.Call(UnitAffectingCombat,'player')
    if combat==true then Host.SetFold(module,db,false)
    elseif combat==false then Host.SetFold(module,db,true) end
end

-- Scale animations exist under two names across client generations.
local function SetScaleRange(animation,from,to)
    if animation.SetScaleFrom then animation:SetScaleFrom(from,from);animation:SetScaleTo(to,to)
    elseif animation.SetFromScale then animation:SetFromScale(from,from);animation:SetToScale(to,to)
    else return false end
    return true
end

-- One-shot native animations for view changes: the new view fades and
-- scales into place while a class-colored flare blooms behind it. Nothing
-- polls; the groups stop on disable and hide.
local function CreateTransition(shell,classToken)
    local color=NS.Folded and NS.Folded.ClassColors and NS.Folded.ClassColors[classToken] or {1,0.82,0.5}
    local inert={Play=function() end,Stop=function() end}
    if type(shell.CreateAnimationGroup)~='function' or type(shell.CreateTexture)~='function' then return inert end
    local intro=shell:CreateAnimationGroup()
    if not intro then return inert end
    local fade=intro:CreateAnimation('Alpha');fade:SetFromAlpha(0);fade:SetToAlpha(1);fade:SetDuration(0.22)
    local grow=intro:CreateAnimation('Scale');grow:SetDuration(0.22)
    if grow.SetSmoothing then grow:SetSmoothing('OUT') end
    local flare=shell:CreateTexture(nil,'OVERLAY')
    flare:SetTexture('Interface\\AddOns\\ForeverUtilities\\Textures\\Glow')
    flare:SetVertexColor(color[1],color[2],color[3],1);flare:Hide()
    if flare.SetBlendMode then flare:SetBlendMode('ADD') end
    if not flare or type(flare.CreateAnimationGroup)~='function' then return inert end
    local bloom=flare:CreateAnimationGroup()
    if not bloom then return inert end
    local flash=bloom:CreateAnimation('Alpha');flash:SetFromAlpha(0.9);flash:SetToAlpha(0);flash:SetDuration(0.5)
    local spread=bloom:CreateAnimation('Scale');spread:SetDuration(0.5);SetScaleRange(spread,0.6,1.5)
    if bloom.SetScript then bloom:SetScript('OnFinished',function() flare:Hide() end) end
    local transition={intro=intro,bloom=bloom,flare=flare,grow=grow}
    function transition.Stop()
        if intro:IsPlaying() then intro:Stop() end
        if bloom:IsPlaying() then bloom:Stop() end
        flare:Hide()
    end
    -- Folding drops the card in from slightly larger; expanding bursts the
    -- bar out from slightly smaller. The flare follows the crest or the bar.
    function transition.Play(collapsed,width,height)
        transition.Stop()
        SetScaleRange(grow,collapsed and 1.12 or 0.9,1)
        flare:ClearAllPoints()
        if collapsed then
            flare:SetSize(110,110);flare:SetPoint('CENTER',shell,'TOP',0,-Host.CompactCrestOffset)
        else
            flare:SetSize(width+60,height+50);flare:SetPoint('CENTER',shell,'CENTER',0,0)
        end
        flare:Show();intro:Play();bloom:Play()
    end
    return transition
end

-- Engraved class-tinted nine-slice around the expanded bar, drawn above its
-- content edges, with the class crest clasping the left side.
function Host.CreateFrameArt(shell,classToken)
    local media=NS.Core.Media
    local art=CreateFrame('Frame',nil,shell);art:SetAllPoints(shell)
    local base=shell.GetFrameLevel and shell:GetFrameLevel()
    if type(base)=='number' and art.SetFrameLevel then art:SetFrameLevel(base+20) end
    local color=NS.Folded and NS.Folded.ClassColors and NS.Folded.ClassColors[classToken] or {0.8,0.8,0.8}
    local tint={0.55+0.45*color[1],0.55+0.45*color[2],0.55+0.45*color[3]}
    art.slices={}
    local k=12/64
    for _,y in ipairs({{'TOP',0,k},{'MIDDLE',k,1-k},{'BOTTOM',1-k,1}}) do
        for _,x in ipairs({{'LEFT',0,k},{'CENTER',k,1-k},{'RIGHT',1-k,1}}) do
            local slice=art:CreateTexture(nil,'BORDER');slice:SetTexture(media..'IconFrame')
            slice:SetTexCoord(x[2],x[3],y[2],y[3]);slice.column,slice.row=x[1],y[1]
            art.slices[#art.slices+1]=slice
        end
    end
    local glow=art:CreateTexture(nil,'ARTWORK',nil,-1);glow:SetTexture(media..'Glow');glow:SetSize(60,60)
    glow:SetVertexColor(color[1],color[2],color[3],0.5)
    if glow.SetBlendMode then glow:SetBlendMode('ADD') end
    -- The crest identifies the class only; it never represents buff state.
    local crest=art:CreateTexture(nil,'ARTWORK');crest:SetSize(40,40)
    crest:SetTexture(classToken and (media..'Classes\\'..classToken) or (media..'ForeverClassmate'))
    crest:SetPoint('CENTER',art,'LEFT',-10,0);glow:SetPoint('CENTER',crest,'CENTER',0,0)
    art.crest,art.crestGlow=crest,glow
    function art.SetWarm(warm)
        local c=warm and NS.Core.Amber or tint
        for _,slice in ipairs(art.slices) do slice:SetVertexColor(c[1],c[2],c[3],1) end
        art.warm=warm==true
    end
    function art.Layout(width,height,showCrest)
        for _,slice in ipairs(art.slices) do
            local w=slice.column=='CENTER' and width-24 or 12
            local h=slice.row=='MIDDLE' and height-24 or 12
            local sx=slice.column=='LEFT' and 0 or (slice.column=='CENTER' and 12 or width-12)
            local sy=slice.row=='TOP' and 0 or (slice.row=='MIDDLE' and 12 or height-12)
            slice:SetSize(w,h);slice:ClearAllPoints();slice:SetPoint('TOPLEFT',art,'TOPLEFT',sx,-sy)
        end
        crest:SetShown(showCrest);glow:SetShown(showCrest)
    end
    art.SetWarm(false)
    return art
end

function Host.Create(module,db,contentFactory)
    local height=type(module.height)=='function' and module.height(db) or (module.height or 56)
    local width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
    local shell=CreateFrame('Frame',nil,UIParent)
    DetachNativePlacement(shell,true)
    shell:SetFrameStrata('MEDIUM');shell:SetClampedToScreen(true)
    -- Dark well behind the bar and its control rail.
    local fill=shell:CreateTexture(nil,'BACKGROUND')
    fill:SetPoint('TOPLEFT',shell,'TOPLEFT',3,-3);fill:SetPoint('BOTTOMRIGHT',shell,'BOTTOMRIGHT',-3,3)
    fill:SetColorTexture(0.03,0.03,0.035,0.9)
    local host=CreateFrame('Frame',module.frameName,shell)
    -- Older releases let this named frame move independently. Characters may
    -- still have its position/size in layout-local.txt. SavedVariables now own
    -- placement; the host must remain an inset of the anonymous shell.
    DetachNativePlacement(host,false)
    host.shell=shell;host.shellFill=fill
    host.outline=Host.CreateFrameArt(shell,module.classToken)
    local transition=CreateTransition(shell,module.classToken)
    host.transition=transition
    shell:HookScript('OnHide',transition.Stop)
    local shownCollapsed,lastAutoFold
    host.foldWarnings={};host.hovered=false
    host:SetSize(width,height);host:SetFrameStrata('MEDIUM')
    -- Only the shell clamps to the screen; its inset host must keep its anchor
    -- as compact content grows and shrinks.
    host:RegisterForDrag('LeftButton')
    host.hint=host:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    host.hint:SetPoint('BOTTOM',host,'TOP',0,4)
    local visual=CreateFrame('Frame',nil,host);visual:SetAllPoints(host)
    local content=contentFactory(host,db)
    if NS.Folded then content:SetParent(visual) end
    local folded=NS.Folded and NS.Folded.Create(host,content,db,module)
    local levelingBuffs=NS.LevelingBuffs and NS.LevelingBuffs.Create(host,content,db)
    local lock=CreateFrame('Button',module.lockName,content)
    lock:SetSize(18,24);lock:SetPoint('RIGHT',host,'RIGHT',-7,0);lock:EnableMouse(true)
    local function Block(width,blockHeight,x,y)
        local texture=lock:CreateTexture(nil,'OVERLAY')
        texture:SetSize(width,blockHeight);texture:SetPoint('TOPLEFT',lock,'TOPLEFT',x,y)
        return texture
    end
    local body=Block(12,9,3,-11)
    local left=Block(2,7,5,-4)
    local top=Block(8,2,5,-4)
    local right=Block(2,7,11,-4)
    local function MouseOver()
        local shellOver=NS.Core.Call(shell.IsMouseOver,shell)
        if shellOver==true then return true end
        if type(host.IsMouseOver)~='function' then return nil end
        local ok,over=pcall(host.IsMouseOver,host)
        if ok and type(over)=='boolean' then return over end
        if shellOver==false then return false end
    end
    local function Hover(over)
        if not db.enabled or host.hovered==over then return end
        host.hovered=over
        if content.baseAlpha then Host.SetFade(host,content,content.baseAlpha)
        elseif host.updatePolling then host.updatePolling() end
    end
    local hoverElapsed=0
    host:SetScript('OnEnter',function() Hover(true) end)
    host:SetScript('OnLeave',function() if MouseOver()~=true then Hover(false) end end)
    local function CheckHover(_,delta)
        if db.collapsed and content:IsShown() then
            local update=content:GetScript('OnUpdate')
            if update then update(content,delta) end
        end
        hoverElapsed=hoverElapsed+delta
        if hoverElapsed<0.1 then return end
        hoverElapsed=0
        local over=MouseOver()
        if over~=nil then Hover(over) end
    end
    -- Hover only changes anything while something is faded; collapsed hosts also
    -- forward the hidden content updater. Otherwise no per-frame work runs.
    local polling=false
    host.updatePolling=function()
        local wanted=db.enabled==true and (db.collapsed==true or host.hovered==true or Host.ContentAlpha(host,content)<1)
        if wanted==polling then return end
        polling=wanted;hoverElapsed=0
        host:SetScript('OnUpdate',wanted and CheckHover or nil)
        if wanted and not db.collapsed then
            -- Pick up a pointer already resting on the bar when fading resumes.
            local over=MouseOver()
            if over~=nil then Hover(over) end
        end
    end
    local Apply
    lock:SetScript('OnClick',function() db.locked=not db.locked;module.Apply() end)
    lock:SetScript('OnEnter',function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self,'ANCHOR_TOP')
            GameTooltip:SetText(NS.L(db.locked and 'Unlock bar to move' or 'Lock bar position'));GameTooltip:Show()
        end
    end)
    lock:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    Apply=function()
        height=type(module.height)=='function' and module.height(db) or (module.height or 56)
        width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
        if db.collapsed then local crest=NS.Folded and NS.Folded.Layout.CREST or 48;width,height=crest,crest end
        shell:SetShown(db.enabled);host:SetShown(db.enabled);host:SetSize(width,height)
        -- The right rail exists only to hold the collapse button.
        local rail=not db.collapsed and NS.Folded~=nil and db.showFoldButton~=false
        shell:SetSize(width+8+(rail and 16 or 0),height+8)
        -- Full Hunter and Shaman bars get the crest clasp; standard classes draw
        -- the crest inside their first slot, and Hunter's 42px icon mode stays bare.
        host.outline.Layout(width+8+(rail and 16 or 0),height+8,not db.collapsed and width>=300 and not module.innerCrest)
        visual:SetShown(not db.collapsed)
        shell:SetScale(db.scale);Host.Place(host,db)
        host:ClearAllPoints();host:SetPoint('TOPLEFT',shell,'TOPLEFT',4,-4)
        host:EnableMouse(db.enabled)
        for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD'}) do
            if db.enabled then host:RegisterEvent(event) else host:UnregisterEvent(event) end
        end
        if not db.enabled then host.hovered=false end
        host.updatePolling()
        host.hint:SetText((db.locked or db.collapsed) and '' or NS.L('Drag to move'))
        lock:SetShown(db.showLockButton~=false and (not module.lockVisible or module.lockVisible(db)))
        right:SetShown(db.locked)
        for _,texture in ipairs({body,left,top,right}) do
            if db.locked then texture:SetColorTexture(0.8,0.85,0.9,1)
            else texture:SetColorTexture(0.3,1,0.5,1) end
        end
        -- Combat auto-fold listens only while enabled and switched on.
        for _,event in ipairs({'PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED'}) do
            if db.enabled and db.autoFold==true then host:RegisterEvent(event) else host:UnregisterEvent(event) end
        end
        content.Refresh()
        if levelingBuffs then levelingBuffs.Refresh() end
        if folded then folded.Refresh() end
        local collapsed=db.collapsed==true
        if not db.enabled then
            transition.Stop();shownCollapsed=nil
        elseif shownCollapsed~=nil and shownCollapsed~=collapsed and NS.Folded then
            transition.Play(collapsed,shell:GetWidth() or width,shell:GetHeight() or height)
        end
        if db.enabled then shownCollapsed=collapsed end
        -- Turning the option on syncs the view to the current combat state once.
        local auto=db.enabled and db.autoFold==true
        if auto and lastAutoFold==false then Host.SyncCombatFold(module,db) end
        lastAutoFold=auto
    end
    -- Reapply after native startup layout restoration, including old cache
    -- records left by the pre-shell implementation. Disabled hosts do no work.
    host:SetScript('OnEvent',function(_,event)
        if not db.enabled then return end
        if event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
            if db.autoFold==true then Host.SetFold(module,db,event=='PLAYER_REGEN_ENABLED') end
            return
        end
        Apply()
        if db.autoFold==true then Host.SyncCombatFold(module,db) end
    end)
    host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then shell:StartMoving() end end)
    host:SetScript('OnDragStop',function(self)
        shell:StopMovingOrSizing()
        local x,y=shell:GetCenter();local cx,cy=UIParent:GetCenter()
        local ratio=shell:GetEffectiveScale()/UIParent:GetEffectiveScale()
        -- Compact mode stores the crest center, not the center of the card.
        if db.collapsed and type(shell.GetTop)=='function' then y=shell:GetTop()-Host.CompactCrestOffset end
        db.x,db.y=x-cx/ratio,y-cy/ratio
        Apply()
    end)
    return {Apply=Apply,Status=content.Status,content=content,lock=lock,levelingBuffs=levelingBuffs,folded=folded,visual=visual,shell=shell}
end
