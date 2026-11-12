-- Minimap button tray: which buttons are borrowed, how they are laid out,
-- and that everything borrowed is returned exactly as found.
local NS={}
local root='addons/ForeverUtilities/'
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,message) assert(ok,message);count=count+1 end

local methods={}
local function object(kind,name) return setmetatable({scripts={},events={},shown=true,points={},kind=kind or 'Frame',name=name},{__index=methods}) end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event,fn)
    local previous=self.scripts[event]
    self.scripts[event]=function(...) if previous then previous(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object('Texture') end
function methods:CreateFontString() return object('FontString') end
function methods:SetText(value) self.text=value end
function methods:SetTexture(value) self.texture=value end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetParent(parent) self.parent=parent end
function methods:GetParent() return self.parent end
function methods:ClearAllPoints() self.points={} end
function methods:SetPoint(...) self.points[#self.points+1]={...} end
function methods:GetNumPoints() return #self.points end
function methods:GetPoint(index) return unpack(self.points[index]) end
function methods:IsShown() return self.shown end
function methods:SetShown(value)
    local changed=self.shown~=value;self.shown=value
    if changed and self.scripts[value and 'OnShow' or 'OnHide'] then self.scripts[value and 'OnShow' or 'OnHide'](self) end
end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
function methods:IsObjectType(kind) return self.kind==kind end
function methods:GetName() return self.name end
function methods:IsProtected() return self.protected==true,false end
function methods:GetCenter() return self.cx,self.cy end
function methods:IsMouseOver() return self.over==true end
setmetatable(methods,{__index=function() return function() end end})

local created={}
CreateFrame=function(kind,name,parent)
    local frame=object(kind,name);frame.parent=parent;created[#created+1]=frame
    return frame
end
hooksecurefunc=function(target,method,fn)
    local original=target[method]
    target[method]=function(...) local result={original(...)};fn(...);return unpack(result) end
end
local inCombat=false
InCombatLockdown=function() return inCombat end
local timers={}
C_Timer={After=function(delay,fn) timers[#timers+1]={delay=delay,fn=fn} end}
UISpecialFrames={}
UIParent=object();UIParent.cx,UIParent.cy=960,540
Minimap=object('Frame','Minimap')
GameTooltip={SetOwner=function() end,SetText=function() end,Show=function() end,Hide=function() end}

local function Button(name,extra)
    local button=object('Button',name);button.parent=Minimap
    button:SetPoint('CENTER',Minimap,'CENTER',50,60)
    button.scripts.OnDragStart=function() end;button.scripts.OnDragStop=function() end
    local clicks=0;button.scripts.OnClick=function() clicks=clicks+1 end
    button.Clicks=function() return clicks end
    for key,value in pairs(extra or {}) do button[key]=value end
    return button
end
local questie=Button('LibDBIcon10_Questie')
local fishfry=Button('FishFryMinimapButton')
local forever=Button('DungeonsHub',{minimapButtonSpec={}})
local hidden=Button('LibDBIcon10_Hidden');hidden.shown=false
local tracking=Button('MiniMapTrackingButton')
local clock=Button('GameTimeFrame')
local secure=Button('SecureMinimapLauncher',{protected=true})
local pin=Button(nil)
local own=Button('ForeverHunterFriendMinimap')
local texture=object('Frame','DecorMinimapOverlay');texture.parent=Minimap
local children={tracking,questie,clock,fishfry,secure,pin,own,texture,forever,hidden}
Minimap.GetChildren=function() return unpack(children) end
local function Original(button) return button.points[1][2]==Minimap and button.points[1][4]==50 end
local originalDrag=questie.scripts.OnDragStart

NS.Classes={HUNTER={minimapName='ForeverHunterFriendMinimap',classToken='HUNTER'}}
assert(loadfile(root..'MinimapTray.lua'))('ForeverUtilities',NS)
local events=created[1]
local Tray=NS.MinimapTray
local db={showMinimap=true}
local module={db=db,classToken='HUNTER',minimapName='ForeverHunterFriendMinimap'}
local anchor=own;anchor.cx,anchor.cy=1800,1000
local settingsOpened=0
local function Settings() settingsOpened=settingsOpened+1 end

Tray.Apply(module,anchor,Settings)
local tray=_G and nil
for _,frame in ipairs(created) do if frame.name=='ForeverClassmateMinimapTray' then tray=frame end end
check(tray and Tray.Active(),'grouping is on by default and creates the tray')
local borrowed=Tray.Borrowed()
check(#borrowed==4 and borrowed[1]==forever and borrowed[2]==fishfry and borrowed[3]==hidden and borrowed[4]==questie,
    'LibDBIcon, ForeverCore and *Minimap* addon buttons are borrowed, sorted by name')
for _,button in ipairs({tracking,clock,secure,pin,own}) do
    check(button.parent==Minimap and Original(button) and button.scripts.OnDragStart~=nil,
        'Blizzard, protected, unnamed and Classmate buttons are never touched')
end
check(texture.parent==Minimap,'non-button minimap children are ignored')
check(questie.parent~=Minimap and questie.scripts.OnDragStart==nil and questie.scripts.OnDragStop==nil,
    'borrowed buttons move into the tray and stop dragging')
check(events.events.PLAYER_ENTERING_WORLD and events.events.PLAYER_REGEN_ENABLED,'tray listens for login and combat end')

check(Tray.Open() and tray.shown,'hovering the Classmate button opens the tray')
check(Tray.Open() and tray.shown,'hovering again keeps it open instead of toggling it closed')
check(#tray.cells==4 and tray.cells[2]==forever and tray.cells[4]==questie,'settings cell first, then visible buttons')
local first=tray.cells[1].points[1]
check(first[1]=='CENTER' and first[4]==17 and first[5]==-17 and questie.points[1][4]==119 and questie.points[1][5]==-17,
    'cells sit on a 34px grid')
check(tray.width==152 and tray.height==66,'one row of four fits with padding and title')
check(tray.points[1][1]=='TOPRIGHT' and tray.points[1][2]==anchor and tray.points[1][3]=='TOPLEFT' and tray.points[1][4]==-4,
    'a top-right minimap opens the tray down and to the left')

-- The owning addon re-places its button (login, settings, minimap shape).
questie:ClearAllPoints();questie:SetPoint('CENTER',Minimap,'CENTER',-70,10)
local last=questie.points[#questie.points]
check(last[2]~=Minimap and last[4]==119 and last[5]==-17,'owner moves are answered by the tray layout')
hidden:Show()
check(#tray.cells==5 and tray.height==100 and tray.width==152 and hidden.points[1][4]==119
    and questie.points[#questie.points][4]==17 and questie.points[#questie.points][5]==-51,
    'a button shown by its addon joins the grid in name order; the fifth wraps to a second row')
hidden:Hide()
check(#tray.cells==4 and tray.height==66,'a hidden button leaves the grid')

questie.scripts.OnClick(questie)
check(questie.Clicks()==1 and not tray.shown,'clicking a borrowed button runs it and closes the tray')
Tray.Toggle();tray.cells[1].scripts.OnClick(tray.cells[1])
check(settingsOpened==1 and not tray.shown,'the first cell opens Classmate settings')

Tray.Toggle();tray.over=false;anchor.over=false
tray.scripts.OnUpdate(tray,1.5);check(tray.shown,'the tray waits before closing')
tray.over=true;tray.scripts.OnUpdate(tray,1);tray.over=false;tray.scripts.OnUpdate(tray,1.5)
check(tray.shown,'pointer time over the tray resets the close timer')
tray.scripts.OnUpdate(tray,0.6);check(not tray.shown,'two seconds away closes the tray')

-- A late addon button is picked up after world entry.
local late=Button('LibDBIcon10_Gargul');children[#children+1]=late
events.scripts.OnEvent(events,'PLAYER_ENTERING_WORLD')
check(late.parent~=Minimap and #Tray.Borrowed()==5 and timers[#timers].delay==3,'world entry scans now and again after three seconds')

db.groupMinimapButtons=false;Tray.Apply(module,anchor,Settings)
for _,button in ipairs({questie,fishfry,forever,hidden,late}) do
    check(button.parent==Minimap and #button.points==1 and Original(button),'turning grouping off returns each button to its spot')
end
check(questie.scripts.OnDragStart==originalDrag and questie.scripts.OnDragStop~=nil,'original drag handlers are restored')
check(not Tray.Active() and not Tray.Toggle() and not tray.shown and not events.events.PLAYER_ENTERING_WORLD,
    'with grouping off, left-click falls back to settings and listeners stop')
questie:SetPoint('CENTER',Minimap,'CENTER',1,2)
check(questie.points[#questie.points][2]==Minimap,'released buttons are no longer re-laid out by the old hook')

-- Combat: nothing is borrowed or returned until combat ends.
inCombat=true;db.groupMinimapButtons=true;Tray.Apply(module,anchor,Settings)
check(#Tray.Borrowed()==0 and questie.parent==Minimap,'grouping waits for combat to end')
inCombat=false;events.scripts.OnEvent(events,'PLAYER_REGEN_ENABLED')
check(#Tray.Borrowed()==5,'combat end borrows the buttons')
inCombat=true;db.groupMinimapButtons=false;Tray.Apply(module,anchor,Settings)
check(questie.parent~=Minimap and events.events.PLAYER_REGEN_ENABLED,'release also waits for combat to end')
inCombat=false;events.scripts.OnEvent(events,'PLAYER_REGEN_ENABLED')
check(questie.parent==Minimap and #Tray.Borrowed()==0 and not events.events.PLAYER_REGEN_ENABLED,'combat end returns the buttons and stops listening')

-- Hiding the Classmate button also returns everything.
db.groupMinimapButtons=true;Tray.Apply(module,anchor,Settings)
check(#Tray.Borrowed()==5,'grouping can be turned back on')
db.showMinimap=false;Tray.Apply(module,anchor,Settings)
check(#Tray.Borrowed()==0 and questie.parent==Minimap,'hiding the Classmate minimap button returns every button')

-- Re-borrowing does not stack hooks: one click closes once and runs once.
db.showMinimap=true;Tray.Apply(module,anchor,Settings);Tray.Toggle()
local before=questie.Clicks();questie.scripts.OnClick(questie)
check(questie.Clicks()==before+1 and not tray.shown,'hooks are installed once per button')

GetLocale=function() return 'zhCN' end
local zh={}
assert(loadfile(root..'Core.lua'))('ForeverUtilities',zh)
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',zh)
check(zh.L('Group addon minimap buttons')=='收纳其他插件的小地图按钮' and zh.L('Addon buttons')=='插件按钮'
    and zh.L('Classmate settings')=='永恒战友设置' and zh.L('No other addon buttons')=='没有其他插件按钮',
    'tray text has Simplified Chinese translations')
print('PASS: '..count..' minimap tray checks')
