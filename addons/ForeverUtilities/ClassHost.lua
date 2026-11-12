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

-- Half of the crest-only compact shell (32 + 2 x 4 padding).
Host.CompactHalfWidth=20

-- Expanded bars center on the saved point. Compact strips keep the crest on
-- that point and grow to the right, so warnings never move the crest.
function Host.Place(host,db)
    local shell=host.shell
    shell:ClearAllPoints()
    if db.collapsed and NS.Folded then
        shell:SetPoint('LEFT',UIParent,'CENTER',db.x-Host.CompactHalfWidth,db.y)
    else
        shell:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
    end
end

function Host.Create(module,db,contentFactory)
    local height=type(module.height)=='function' and module.height(db) or (module.height or 56)
    local width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
    local shell=CreateFrame('Frame',nil,UIParent,'BackdropTemplate')
    DetachNativePlacement(shell,true)
    shell:SetFrameStrata('MEDIUM');shell:SetClampedToScreen(true)
    shell:SetBackdrop({bgFile='Interface\\Tooltips\\UI-Tooltip-Background',tile=true,tileSize=16})
    shell:SetBackdropColor(0.04,0.045,0.055,0.55)
    local host=CreateFrame('Frame',module.frameName,shell)
    -- Older releases let this named frame move independently. Characters may
    -- still have its position/size in layout-local.txt. SavedVariables now own
    -- placement; the host must remain an inset of the anonymous shell.
    DetachNativePlacement(host,false)
    host.shell=shell
    local outline=CreateFrame('Frame',nil,shell,'BackdropTemplate');outline:SetAllPoints(shell)
    outline:SetBackdrop({edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=8})
    outline:SetBackdropBorderColor(0.65,0.65,0.65,0.85)
    host.outline=outline
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
        if db.collapsed then width,height=NS.Folded and NS.Folded.CELL or 32,NS.Folded and NS.Folded.CELL or 32 end
        shell:SetShown(db.enabled);host:SetShown(db.enabled);host:SetSize(width,height)
        -- The right rail exists only to hold the collapse button.
        local rail=not db.collapsed and NS.Folded~=nil and db.showFoldButton~=false
        shell:SetSize(width+8+(rail and 16 or 0),height+8)
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
        content.Refresh()
        if levelingBuffs then levelingBuffs.Refresh() end
        if folded then folded.Refresh() end
    end
    -- Reapply after native startup layout restoration, including old cache
    -- records left by the pre-shell implementation. Disabled hosts do no work.
    host:SetScript('OnEvent',function()
        if db.enabled then Apply() end
    end)
    host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then shell:StartMoving() end end)
    host:SetScript('OnDragStop',function(self)
        shell:StopMovingOrSizing()
        local x,y=shell:GetCenter();local cx,cy=UIParent:GetCenter()
        local ratio=shell:GetEffectiveScale()/UIParent:GetEffectiveScale()
        -- Compact mode keeps the crest fixed: store the crest-only center.
        if db.collapsed and type(shell.GetLeft)=='function' then x=shell:GetLeft()+Host.CompactHalfWidth end
        db.x,db.y=x-cx/ratio,y-cy/ratio
        Apply()
    end)
    return {Apply=Apply,Status=content.Status,content=content,lock=lock,levelingBuffs=levelingBuffs,folded=folded,visual=visual,shell=shell}
end
