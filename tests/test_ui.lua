local NS={}
local root='addons/ForeverUtilities/'
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/TargetContext.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/Layout.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local frames,named={},{}
local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:HookScript(k,v)
 local previous=self.scripts[k]
 self.scripts[k]=function(...) if previous then previous(...) end;v(...) end
end
function methods:GetFrameStrata() error('must not copy possibly secret native frame strata') end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:RegisterForClicks(...) self.clicks={...} end
function methods:UnregisterEvent(e) self.events[e]=nil end
function methods:CreateFontString() return object() end
function methods:CreateTexture() return object() end
function methods:CreateMaskTexture() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetText(v) self.text=v end
function methods:SetMovable(v) self.movable=v end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:SetScale(v) self.scale=v end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetShown(v) self.shown=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:SetPoint(_,_,_,x,y) self.x,self.y=x,y end
function methods:GetCenter() return 30,40 end
function methods:GetEffectiveScale() return 1 end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function(_,name,parent)
 local f=object();f.name=name;f.parent=parent;frames[#frames+1]=f
 if name then named[name]=f end;return f
end
UIParent=object();Minimap=object();Minimap:SetSize(200,200);UISpecialFrames={}
DEFAULT_CHAT_FRAME={AddMessage=function() end};SlashCmdList={}
ForeverUtilitiesDB={x=70,y=-123,scale=1.3,locked=false,enabled=false}
ForeverSwingDB={x=123,cue=0.7}
local refreshes=0
NS.Range={Create=function(host,db)
 check(db==ForeverUtilitiesDB.hunter,'hunter owns migrated settings')
 return {Refresh=function() refreshes=refreshes+1 end,Status=function() return 'test' end}
end}
local class='HUNTER'
UnitClass=function() return 'Hunter',class end
assert(loadfile(root..'Distance.lua'))('ForeverUtilities',NS)
local mailApplies,mailInitializations=0,0
NS.MailRecipients={Apply=function() mailApplies=mailApplies+1 end,Initialize=function(saved)
 check(saved==ForeverUtilitiesDB,'mail initializes with account-wide saved variables')
 mailInitializations=mailInitializations+1
end}
-- Tray double: grouping off by default here, so left-click keeps opening settings.
local trayActive,trayOpens,trayCloses,trayArgs=false,0,0,nil
NS.MinimapTray={Apply=function(m,b,open) trayArgs={m,b,open} end,
    Open=function() if trayActive then trayOpens=trayOpens+1 end;return trayActive end,
    Close=function() trayCloses=trayCloses+1 end,
    Active=function() return trayActive end}
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local events=frames[1]
events.scripts.OnEvent(events,'ADDON_LOADED','Unrelated')
check(not NS.Hunter.db,'ignores unrelated addon')
events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
check(mailInitializations==1,'mail service initializes once after class preferences')
local db=NS.Hunter.db
check(db.x==70 and db.y==-123 and db.scale==1.3 and not db.enabled,'flat preferences migrated')
check(not NS.Hunter.instance,'disabled bar not created')
local slash=SlashCmdList.FOREVERUTILITIES
slash('');local panel=named.ForeverHunterFriendOptions
check(panel and panel.shown and rawget(panel,'rows')==nil,'single hunter settings panel')
panel.enabled:SetChecked(true);panel.enabled.scripts.OnClick(panel.enabled)
check(db.enabled and NS.Hunter.instance,'settings enable bar')
check(named.ForeverUtilitiesDistanceFrame.width==426,'hunter host matches rendered native swing-bar width')
local compact=panel.controls.rangeIconOnly
check(compact and panel.controls.showInspect,'compact range and inspect each have a settings toggle')
check(panel.controls.sleepingBagReminder and db.sleepingBagReminder==true,'Hunter has an independent sleeping bag reminder setting')
check(panel.controls.foodXPReminder and db.foodXPReminder==true,'Hunter has an independent food XP reminder setting')
local mailToggle=panel.controls.mailRecipients
check(mailToggle and db.mailRecipients==true,'Hunter exposes mail utility preference')
local beforeMailApply=mailApplies
mailToggle:SetChecked(false);mailToggle.scripts.OnClick(mailToggle)
check(not db.mailRecipients and mailApplies>beforeMailApply,'mail toggle saves and refreshes shared service')
mailToggle:SetChecked(true);mailToggle.scripts.OnClick(mailToggle)
compact:SetChecked(true);compact.scripts.OnClick(compact)
check(db.rangeIconOnly and named.ForeverUtilitiesDistanceFrame.width==42 and named.ForeverUtilitiesDistanceFrame.height==42,'compact toggle resizes host immediately')
check(not named.ForeverHunterFriendLock.shown,'compact toggle hides the full-bar lock button')
compact:SetChecked(false);compact.scripts.OnClick(compact)
check(not db.rangeIconOnly and named.ForeverUtilitiesDistanceFrame.width==426 and named.ForeverHunterFriendLock.shown,'full mode restores host and lock button')
compact:SetChecked(true);compact.scripts.OnClick(compact)
local inspectToggle=panel.controls.showInspect
inspectToggle:SetChecked(true);inspectToggle.scripts.OnClick(inspectToggle)
NS.Hunter.Initialize(ForeverUtilitiesDB)
check(db.rangeIconOnly and db.showInspect and named.ForeverUtilitiesDistanceFrame.width==42,'new Hunter preferences survive settings reinitialization')
compact:SetChecked(false);compact.scripts.OnClick(compact)
inspectToggle:SetChecked(false);inspectToggle.scripts.OnClick(inspectToggle)
slash('scale 1.5');check(db.scale==1.5,'scale command')
slash('scale 9');check(db.scale==1.5,'invalid scale rejected')
slash('off');check(not db.enabled and not named.ForeverUtilitiesDistanceFrame.shown,'disable hides bar')
slash('unlock');check(db.enabled and not db.locked,'unlock enables dragging')
slash('lock');check(db.locked,'lock command')
slash('reset');check(db.scale==1 and db.locked,'reset defaults')
for _,key in ipairs({'petGuide','petHappinessWarning','aspectWarning','showRange','showAmmo','lowAmmoWarning','petMendWarning','markWarning','fadeOutOfCombat','showTargetTarget','showAngle'}) do
 local control=panel.controls[key]
 check(control~=nil,'feature has checkbox: '..key)
 control:SetChecked(false);control.scripts.OnClick(control)
 check(db[key]==false,'checkbox saves: '..key)
end
local lowest=0
for _,control in pairs(panel.controls) do
 if type(control.y)=='number' then lowest=math.min(lowest,control.y) end
end
for _,button in ipairs(frames) do
 if button.text=='Close' or button.text=='Reset settings' then
  check(button.y+28<lowest and -button.y+26<panel.height,'settings footer stays below all options and within panel')
 end
end
local mini=named.ForeverHunterFriendMinimap
check(mini and mini.shown,'minimap button available even when bar disabled')
check(mini.width==28 and mini.height==28,'compact minimap button')
check(math.abs(math.sqrt(mini.x^2+mini.y^2)-103)<0.01,'button sits on minimap rim')
db.minimapAngle=90;Minimap:SetSize(220,160);Minimap.scripts.OnSizeChanged(Minimap)
check(math.abs(mini.x)<0.01 and math.abs(mini.y-83)<0.01,'reskinned minimap resize keeps button on the root minimap rim')
db.minimapAngle=35;Minimap:SetSize(200,200);Minimap.scripts.OnSizeChanged(Minimap)
check(mini.clicks[1]=='LeftButtonUp' and mini.clicks[2]=='RightButtonUp','minimap registers both click buttons')
mini.scripts.OnClick(mini,'LeftButton');check(panel.shown,'minimap left-click opens settings')
check(trayArgs and trayArgs[1]==NS.Hunter and trayArgs[2]==mini and type(trayArgs[3])=='function',
    'the minimap button hands its module, itself and the settings opener to the tray')
panel:Hide();trayActive=true
local shownTooltip=false
GameTooltip={SetOwner=function() shownTooltip=true end,SetText=function() end,AddLine=function() end,Show=function() end,Hide=function() end}
mini.scripts.OnEnter(mini)
check(trayOpens==1 and not shownTooltip,'with grouping on, hovering the minimap button opens the addon tray instead of a tooltip')
local closesBefore=trayCloses;mini.scripts.OnClick(mini,'LeftButton')
check(panel.shown and trayCloses==closesBefore+1,'left-click still opens settings and closes the hover tray')
panel:Hide();trayArgs[3]();check(panel.shown,'the tray settings cell opens the same settings panel')
trayActive=false;mini.scripts.OnEnter(mini)
check(shownTooltip and trayOpens==1,'with grouping off, hovering shows the usual tooltip')
GameTooltip=nil
local inspected=0
UnitIsPlayer=function() return true end;CanInspect=function() return true end
InspectUnit=function(unit) if unit=='target' then inspected=inspected+1 end end
mini.scripts.OnClick(mini,'RightButton')
check(inspected==1 and panel.shown,'right-click inspects eligible target without changing settings')
db.rangeIconOnly=true;NS.Hunter.Apply();mini.scripts.OnClick(mini,'RightButton')
check(inspected==2,'icon-only Hunter still has Inspect via minimap')
db.rangeIconOnly=false;NS.Hunter.Apply()
local shortcut=panel.controls.minimapInspect
shortcut:SetChecked(false);shortcut.scripts.OnClick(shortcut)
mini.scripts.OnClick(mini,'RightButton')
check(inspected==2,'right-click Inspect obeys its independent toggle')
shortcut:SetChecked(true);shortcut.scripts.OnClick(shortcut)
CanInspect=function() return false end;mini.scripts.OnClick(mini,'RightButton')
check(inspected==2,'ineligible target is not inspected')
CanInspect=function() return true end
local cursorX,cursorY=60,280
GetCursorPosition=function() return cursorX,cursorY end
Minimap.GetEffectiveScale=function() return 2 end
panel:Hide();mini.scripts.OnMouseDown();mini.scripts.OnDragStart(mini)
check(math.abs(db.minimapAngle-90)<0.01,'drag uses minimap scale and cursor direction')
check(math.abs(mini.x)<0.01 and math.abs(mini.y-103)<0.01,'drag stays on rim')
cursorX=-140;cursorY=80;mini.scripts.OnUpdate()
check(math.abs(db.minimapAngle-180)<0.01,'drag follows cursor around rim')
mini.scripts.OnDragStop(mini);mini.scripts.OnClick()
check(not panel.shown and not mini.scripts.OnUpdate,'drag release neither opens panel nor keeps polling')
mini.scripts.OnMouseDown();mini.scripts.OnClick();check(panel.shown,'next normal click opens settings')
NS.Hunter.Initialize(ForeverUtilitiesDB)
check(db.minimapAngle==180 and mini.x<0,'saved minimap angle survives settings initialization')
mini.scripts.OnDragStart(mini);mini.scripts.OnHide(mini)
check(not mini.scripts.OnUpdate,'hiding stops cursor tracking')
Minimap.GetEffectiveScale=function() return 1 end
local lock=named.ForeverHunterFriendLock
local wasLocked=db.locked;lock.scripts.OnClick()
check(db.locked~=wasLocked and panel.controls.locked.checked==db.locked,'bar lock toggles and syncs settings')
lock.scripts.OnClick();check(db.locked==wasLocked,'bar lock toggles back')
local control=panel.controls.showMinimap;control:SetChecked(false);control.scripts.OnClick(control)
check(not mini.shown,'minimap button setting hides button')
control=panel.controls.showLockButton;control:SetChecked(false);control.scripts.OnClick(control)
check(not lock.shown,'lock button setting hides button')
check(panel.movable,'settings movable by default')
panel.scripts.OnDragStart(panel);check(panel.moving,'settings drag starts without unlock')
panel.scripts.OnDragStop(panel);check(not panel.moving,'settings drag stops')
panel.scripts.OnDragStart(panel);panel.scripts.OnHide(panel)
check(not panel.moving,'closing settings cancels drag')
local saved={modules={distance={enabled=false,x=81,scale=1.2,showAngle=false}},schemaVersion=1}
NS.Hunter.instance=nil;NS.Hunter.Initialize(saved)
check(NS.Hunter.db.x==81 and NS.Hunter.db.scale==1.2 and not NS.Hunter.db.showAngle,'toolbox preferences migrated')
NS.Hunter.db.x=91;NS.Hunter.Initialize(saved)
check(NS.Hunter.db.x==91,'migration is one time')
class='MAGE';NS.Hunter.instance=nil;NS.Hunter.Initialize({})
check(not NS.Hunter.instance,'non hunters never create bar')
slash('on');check(not NS.Hunter.instance,'non hunter commands cannot create bar')
print('PASS: '..count..' hunter UI and migration checks')
