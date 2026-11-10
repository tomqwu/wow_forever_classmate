local _, NS = ...
local Host={}
NS.ClassHost=Host

function Host.SetWarning(host,key,active,icon,label)
    host.foldWarnings=host.foldWarnings or {}
    host.foldWarnings[key]={active=active==true,icon=icon,label=label}
    if host.foldRefresh then host.foldRefresh() end
end

function Host.SetFade(host,content,alpha)
    content.baseAlpha=alpha
    content:SetAlpha((host.hovered==true or host.levelingBuffMissing==true) and 1 or alpha)
    if host.foldRefresh then host.foldRefresh() end
end

function Host.Create(module,db,contentFactory)
    local height=type(module.height)=='function' and module.height(db) or (module.height or 56)
    local width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
    local shell=CreateFrame('Frame',nil,UIParent,'BackdropTemplate')
    shell:SetFrameStrata('MEDIUM');shell:SetMovable(true);shell:SetClampedToScreen(true)
    shell:SetBackdrop({bgFile='Interface\\Tooltips\\UI-Tooltip-Background',tile=true,tileSize=16})
    shell:SetBackdropColor(0.04,0.045,0.055,0.55)
    local host=CreateFrame('Frame',module.frameName,shell)
    host.shell=shell
    local outline=CreateFrame('Frame',nil,shell,'BackdropTemplate');outline:SetAllPoints(shell)
    outline:SetBackdrop({edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=8})
    outline:SetBackdropBorderColor(0.65,0.65,0.65,0.85)
    host.outline=outline
    host.foldWarnings={};host.hovered=false
    host:SetSize(width,height);host:SetFrameStrata('MEDIUM')
    -- Only the shell clamps to the screen; its inset host must keep its anchor
    -- as compact content grows and shrinks.
    host:SetMovable(true);host:RegisterForDrag('LeftButton')
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
        if content.baseAlpha then Host.SetFade(host,content,content.baseAlpha) end
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
        if db.collapsed then width,height=64,64 end
        shell:SetShown(db.enabled);host:SetShown(db.enabled);host:SetSize(width,height)
        shell:SetSize(width+8+(db.collapsed and 0 or 16),height+8)
        visual:SetShown(not db.collapsed)
        shell:SetScale(db.scale);shell:ClearAllPoints();shell:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
        host:ClearAllPoints();host:SetPoint('TOPLEFT',shell,'TOPLEFT',4,-4)
        host:EnableMouse(db.enabled)
        host:SetScript('OnUpdate',db.enabled and CheckHover or nil)
        if not db.enabled then host.hovered=false;hoverElapsed=0 end
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
    host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then shell:StartMoving() end end)
    host:SetScript('OnDragStop',function(self)
        shell:StopMovingOrSizing()
        local x,y=shell:GetCenter();local cx,cy=UIParent:GetCenter()
        local ratio=shell:GetEffectiveScale()/UIParent:GetEffectiveScale()
        db.x,db.y=x-cx/ratio,y-cy/ratio
        Apply()
    end)
    return {Apply=Apply,Status=content.Status,content=content,lock=lock,levelingBuffs=levelingBuffs,folded=folded,visual=visual,shell=shell}
end
