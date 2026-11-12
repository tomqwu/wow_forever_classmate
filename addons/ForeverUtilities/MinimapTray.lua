local _,NS=...
local Core=NS.Core
-- Optional tray that gathers other addons' minimap buttons behind the
-- Classmate minimap button. It only borrows named, unprotected addon buttons
-- parented to the Minimap; Blizzard controls, map pins and protected frames
-- are never touched. Everything borrowed is returned exactly as found when
-- grouping is turned off or the Classmate button is hidden.
local Tray={}
NS.MinimapTray=Tray
local CELL,COLUMNS,PAD,TITLE=34,4,8,16
local media='Interface\\AddOns\\ForeverUtilities\\Textures\\'

-- Blizzard minimap controls whose names do not start with Minimap/MiniMap.
local blizzard={GameTimeFrame=true,TimeManagerClockButton=true,QueueStatusMinimapButton=true,
    GarrisonLandingPageMinimapButton=true,ExpansionLandingPageMinimapButton=true,AddonCompartmentFrame=true,
    LFGMinimapFrame=true,BattlefieldMinimap=true,HelpOpenWebTicketButton=true}

local records,order,hooked={},{},{}
local tray,grid,settingsCell,emptyText,anchor,openSettings,module
local placing,pending,wanted,closeElapsed=false,false,false,0
local events=CreateFrame('Frame')

local function OutOfCombat()
    if type(InCombatLockdown)=='function' then return Core.Call(InCombatLockdown)==false end
    return Core.Call(UnitAffectingCombat,'player')==false
end

local function OwnName(name)
    for _,classModule in pairs(NS.Classes or {}) do
        if classModule.minimapName==name then return true end
    end
    return name=='ForeverClassmateMinimapTray'
end

-- A borrowable button: a named, unprotected addon Button on the Minimap that
-- looks like a minimap launcher (LibDBIcon, ForeverCore, or *Minimap* names).
function Tray.Candidate(frame)
    if type(frame)~='table' or records[frame] or frame==anchor then return false end
    if Core.Call(frame.IsObjectType,frame,'Button')~=true then return false end
    local name=Core.Call(frame.GetName,frame)
    if type(name)~='string' or name=='' or OwnName(name) then return false end
    if name:find('^MiniMap') or name:find('^Minimap') or blizzard[name] then return false end
    if Core.Call(frame.IsProtected,frame)~=false then return false end
    return name:find('^LibDBIcon10_')~=nil or rawget(frame,'minimapButtonSpec')~=nil or name:lower():find('minimap')~=nil
end

local function Visible(button) return Core.Call(button.IsShown,button)==true end

local function Layout()
    if not tray then return end
    placing=true
    local cells={settingsCell}
    for _,button in ipairs(order) do if Visible(button) then cells[#cells+1]=button end end
    local columns=math.min(COLUMNS,#cells)
    local rows=math.ceil(#cells/COLUMNS)
    for index,cell in ipairs(cells) do
        local column=(index-1)%COLUMNS
        local row=math.floor((index-1)/COLUMNS)
        cell:ClearAllPoints()
        cell:SetPoint('CENTER',grid,'TOPLEFT',column*CELL+CELL/2,-(row*CELL+CELL/2))
    end
    placing=false
    local width=math.max(columns*CELL,CELL*2)
    grid:SetSize(width,rows*CELL)
    tray:SetSize(width+PAD*2,rows*CELL+PAD*2+TITLE)
    emptyText:SetShown(#cells==1)
    tray.cells=cells
    local trayWidth,trayHeight=width+PAD*2,rows*CELL+PAD*2+TITLE
    for _,slice in ipairs(tray.slices) do
        local w=slice.column=='CENTER' and trayWidth-24 or 12
        local h=slice.row=='MIDDLE' and trayHeight-24 or 12
        local x=slice.column=='LEFT' and 0 or (slice.column=='CENTER' and 12 or trayWidth-12)
        local y=slice.row=='TOP' and 0 or (slice.row=='MIDDLE' and 12 or trayHeight-12)
        slice:SetSize(w,h);slice:ClearAllPoints();slice:SetPoint('TOPLEFT',tray,'TOPLEFT',x,-y)
    end
end
Tray.Layout=Layout

local function Grab(button)
    -- Reparenting resets the frame level, so strata and level return too.
    local record={parent=Core.Call(button.GetParent,button),points={},
        strata=Core.Call(button.GetFrameStrata,button),level=Core.Call(button.GetFrameLevel,button),
        dragStart=button:GetScript('OnDragStart'),dragStop=button:GetScript('OnDragStop')}
    for index=1,(Core.Call(button.GetNumPoints,button) or 0) do
        record.points[index]={button:GetPoint(index)}
    end
    records[button]=record;order[#order+1]=button
    -- Dragging inside the tray would fight its layout; it returns on release.
    button:SetScript('OnDragStart',nil);button:SetScript('OnDragStop',nil)
    button:SetParent(grid)
    if not hooked[button] then
        hooked[button]=true
        -- Owners re-place their buttons (login, settings, minimap shape). While
        -- borrowed, any such move is answered by re-laying out the tray.
        if type(hooksecurefunc)=='function' then
            hooksecurefunc(button,'SetPoint',function(self) if records[self] and not placing then Layout() end end)
        end
        button:HookScript('OnShow',function(self) if records[self] then Layout() end end)
        button:HookScript('OnHide',function(self) if records[self] then Layout() end end)
        button:HookScript('OnClick',function(self) if records[self] then Tray.Close() end end)
    end
end

local function Release(button)
    local record=records[button]
    if not record then return end
    records[button]=nil
    if record.parent then button:SetParent(record.parent) end
    if type(record.strata)=='string' then Core.Call(button.SetFrameStrata,button,record.strata) end
    if Core.IsNumber(record.level) then Core.Call(button.SetFrameLevel,button,record.level) end
    button:ClearAllPoints()
    for _,point in ipairs(record.points) do button:SetPoint(unpack(point)) end
    button:SetScript('OnDragStart',record.dragStart);button:SetScript('OnDragStop',record.dragStop)
end

function Tray.ReleaseAll()
    if not OutOfCombat() then pending=true;return false end
    for _,button in ipairs(order) do Release(button) end
    order={}
    if tray then Layout() end
    return true
end

function Tray.Scan()
    if not wanted or not Minimap or not tray then return end
    if not OutOfCombat() then pending=true;return end
    local ok,children=pcall(function() return {Minimap:GetChildren()} end)
    if not ok or type(children)~='table' then return end
    local added=false
    for _,child in ipairs(children) do
        if Tray.Candidate(child) then Grab(child);added=true end
    end
    if added then
        table.sort(order,function(a,b) return (Core.Call(a.GetName,a) or '')<(Core.Call(b.GetName,b) or '') end)
    end
    Layout()
end

function Tray.Close() if tray then tray:Hide() end end

local function Place()
    tray:ClearAllPoints()
    local ax,ay=Core.Call(anchor.GetCenter,anchor)
    local ux,uy=Core.Call(UIParent.GetCenter,UIParent)
    local right=Core.IsNumber(ax) and Core.IsNumber(ux) and ax>ux
    local top=not (Core.IsNumber(ay) and Core.IsNumber(uy)) or ay>uy
    -- Open toward the screen center so the tray never runs off an edge.
    local vertical=top and 'TOP' or 'BOTTOM'
    tray:SetPoint(vertical..(right and 'RIGHT' or 'LEFT'),anchor,vertical..(right and 'LEFT' or 'RIGHT'),right and -4 or 4,0)
end

-- Hovering the Classmate minimap button opens the tray; it closes two
-- seconds after the pointer leaves both, on Escape, or on any click.
function Tray.Open()
    if not wanted or not tray then return false end
    closeElapsed=0
    if not tray:IsShown() then
        Tray.Scan()
        -- Nothing to group: keep the minimap button's own tooltip.
        if #order==0 then return false end
        Place();tray:Show()
    end
    return true
end

function Tray.Toggle()
    if not wanted or not tray then return false end
    if tray:IsShown() then tray:Hide();return true end
    return Tray.Open()
end

function Tray.Active() return wanted end

local function Create()
    tray=CreateFrame('Frame','ForeverClassmateMinimapTray',UIParent)
    tray:SetFrameStrata('MEDIUM');tray:SetFrameLevel(2);tray:SetClampedToScreen(true);tray:EnableMouse(true);tray:Hide()
    if UISpecialFrames then table.insert(UISpecialFrames,'ForeverClassmateMinimapTray') end
    local fill=tray:CreateTexture(nil,'BACKGROUND')
    fill:SetPoint('TOPLEFT',tray,'TOPLEFT',3,-3);fill:SetPoint('BOTTOMRIGHT',tray,'BOTTOMRIGHT',-3,3)
    fill:SetColorTexture(0.025,0.025,0.03,0.92)
    -- Same engraved nine-slice as the compact card, in a neutral gold.
    local k=12/64;tray.slices={}
    for _,y in ipairs({{'TOP',0,k},{'MIDDLE',k,1-k},{'BOTTOM',1-k,1}}) do
        for _,x in ipairs({{'LEFT',0,k},{'CENTER',k,1-k},{'RIGHT',1-k,1}}) do
            local slice=tray:CreateTexture(nil,'BORDER');slice:SetTexture(media..'IconFrame')
            slice:SetTexCoord(x[2],x[3],y[2],y[3]);slice:SetVertexColor(1,0.88,0.6)
            slice.column,slice.row=x[1],y[1]
            tray.slices[#tray.slices+1]=slice
        end
    end
    local title=tray:CreateFontString(nil,'OVERLAY','GameFontNormalSmall')
    title:SetPoint('TOP',tray,'TOP',0,-PAD+1);title:SetText(NS.L('Addon buttons'))
    tray.title=title
    grid=CreateFrame('Frame',nil,tray);grid:SetPoint('TOPLEFT',tray,'TOPLEFT',PAD,-(PAD+TITLE))
    emptyText=tray:CreateFontString(nil,'OVERLAY','GameFontDisableSmall')
    emptyText:SetPoint('LEFT',grid,'LEFT',CELL+4,0);emptyText:SetText(NS.L('No other addon buttons'));emptyText:Hide()
    -- The first cell always opens Classmate settings.
    settingsCell=CreateFrame('Button',nil,grid);settingsCell:SetSize(30,30)
    local crest=settingsCell:CreateTexture(nil,'ARTWORK');crest:SetAllPoints()
    settingsCell.crest=crest
    settingsCell:SetScript('OnClick',function() Tray.Close();if openSettings then openSettings() end end)
    settingsCell:SetScript('OnEnter',function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(NS.L('Classmate settings'))
        -- The minimap button's own tooltip is replaced by the tray, so its hints live here.
        -- Offer inspect only while that option is on.
        local inspect=not (module and module.db and module.db.minimapInspect==false)
        GameTooltip:AddLine(NS.L(inspect and 'Click the Classmate button: settings | Right-click: inspect target'
            or 'Click the Classmate button: settings'),1,1,1,true)
        GameTooltip:Show()
    end)
    settingsCell:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    -- Close after the pointer has been away from the tray and its button for
    -- two seconds. This runs only while the tray is open.
    tray:SetScript('OnUpdate',function(self,delta)
        local over=Core.Call(self.IsMouseOver,self)==true or (anchor and Core.Call(anchor.IsMouseOver,anchor)==true)
        closeElapsed=over and 0 or closeElapsed+delta
        if closeElapsed>=2 then self:Hide() end
    end)
    tray:SetScript('OnHide',function() closeElapsed=0 end)
end

local function SetEvents(on)
    for _,event in ipairs({'PLAYER_ENTERING_WORLD','PLAYER_REGEN_ENABLED'}) do
        if on then events:RegisterEvent(event) else events:UnregisterEvent(event) end
    end
end

-- Called whenever the Classmate minimap button is refreshed.
function Tray.Apply(activeModule,button,settings)
    module,anchor,openSettings=activeModule,button,settings
    local db=module and module.db
    local want=db~=nil and db.groupMinimapButtons~=false and db.showMinimap~=false and button~=nil
    if want and not tray then Create() end
    if settingsCell and module then
        settingsCell.crest:SetTexture(module.classToken and (media..'Classes\\'..module.classToken) or (media..'ForeverClassmate'))
    end
    wanted=want
    SetEvents(want)
    if want then Tray.Scan()
    else
        Tray.Close()
        Tray.ReleaseAll()
        -- Still waiting for combat to end to return borrowed buttons.
        if pending then events:RegisterEvent('PLAYER_REGEN_ENABLED') end
    end
end

events:SetScript('OnEvent',function(_,event)
    if event=='PLAYER_REGEN_ENABLED' and pending then
        pending=false
        if wanted then Tray.Scan() else Tray.ReleaseAll();if not pending then SetEvents(false) end end
        return
    end
    if event=='PLAYER_ENTERING_WORLD' and wanted then
        Tray.Scan()
        -- Many addons create their minimap buttons shortly after login.
        if C_Timer and type(C_Timer.After)=='function' then C_Timer.After(3,Tray.Scan) end
    end
end)

function Tray.Borrowed()
    local list={}
    for _,button in ipairs(order) do list[#list+1]=button end
    return list
end
