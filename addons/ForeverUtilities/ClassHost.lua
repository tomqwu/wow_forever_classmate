local _, NS = ...
local Host={}
NS.ClassHost=Host

function Host.SetFade(host,content,alpha)
    content.baseAlpha=alpha
    content:SetAlpha(host.hovered==true and 1 or alpha)
end

function Host.Create(module,db,contentFactory)
    local height=type(module.height)=='function' and module.height(db) or (module.height or 56)
    local width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
    local host=CreateFrame('Frame',module.frameName,UIParent)
    host:SetSize(width,height);host:SetFrameStrata('MEDIUM')
    host:SetMovable(true);host:SetClampedToScreen(true);host:RegisterForDrag('LeftButton')
    host.hint=host:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    host.hint:SetPoint('BOTTOM',host,'TOP',0,4)
    local content=contentFactory(host,db)
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
        if type(host.IsMouseOver)~='function' then return nil end
        local ok,over=pcall(host.IsMouseOver,host)
        if ok and type(over)=='boolean' then return over end
    end
    local function Hover(over)
        if not db.enabled or host.hovered==over then return end
        host.hovered=over
        if content.baseAlpha then content:SetAlpha(over and 1 or content.baseAlpha) end
    end
    local hoverElapsed=0
    host:SetScript('OnEnter',function() Hover(true) end)
    host:SetScript('OnLeave',function() if MouseOver()~=true then Hover(false) end end)
    local function CheckHover(_,delta)
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
            GameTooltip:SetText(db.locked and 'Unlock bar to move' or 'Lock bar position');GameTooltip:Show()
        end
    end)
    lock:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    Apply=function()
        height=type(module.height)=='function' and module.height(db) or (module.height or 56)
        width=type(module.width)=='function' and module.width(db) or (module.width or NS.ClassBarWidth)
        host:SetShown(db.enabled);host:SetSize(width,height)
        host:SetScale(db.scale);host:ClearAllPoints();host:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
        host:EnableMouse(db.enabled)
        host:SetScript('OnUpdate',db.enabled and CheckHover or nil)
        if not db.enabled then host.hovered=false;hoverElapsed=0 end
        host.hint:SetText(db.locked and '' or ('Drag to move | '..module.command..' lock'))
        lock:SetShown(db.showLockButton~=false and (not module.lockVisible or module.lockVisible(db)))
        right:SetShown(db.locked)
        for _,texture in ipairs({body,left,top,right}) do
            if db.locked then texture:SetColorTexture(0.8,0.85,0.9,1)
            else texture:SetColorTexture(0.3,1,0.5,1) end
        end
        content.Refresh()
    end
    host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then self:StartMoving() end end)
    host:SetScript('OnDragStop',function(self)
        self:StopMovingOrSizing()
        local x,y=self:GetCenter();local cx,cy=UIParent:GetCenter()
        local ratio=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
        db.x,db.y=x-cx/ratio,y-cy/ratio
        Apply()
    end)
    return {Apply=Apply,Status=content.Status,content=content,lock=lock}
end
