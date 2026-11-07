local NS={}
local root='addons/ForeverUtilities/'
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'SleepingBag.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local level,combat,dead=59,false,false
local auras={};local reads=0
UnitLevel=function(unit) assert(unit=='player');return level end
UnitIsDead=function() return dead end
UnitAffectingCombat=function() return combat end
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)
    assert(unit=='player' and filter=='HELPFUL');reads=reads+1;return auras[index]
end}
local Bag=NS.SleepingBag
check(Bag.Missing(59)==true,'level 59 with readable absence needs a reminder')
check(Bag.Missing(1)==true,'level 1 is below 60; ownership of a personal bag is not required')
reads=0
for _,value in ipairs({60,61,0,-1,secret,0/0,math.huge}) do
    check(Bag.Missing(value)==nil,'ineligible or unreadable level cannot warn')
end
check(reads==0,'level 60 and above do not scan auras')
auras={{spellId=429959,name=secret,applications=1}}
check(Bag.Missing(59)==false,'one stack with a restricted name still clears the reminder by readable ID')
auras={{spellId=429959,name='酣睡',applications=3}}
check(Bag.Missing(59)==false,'localized active sleeping-bag buff clears the reminder')
auras={{spellId=1225478,name='Well Rested'}}
check(Bag.Missing(59)==true,'Legacy rested perk does not satisfy the sleeping-bag buff')
auras={{spellId=secret,name='Well-Rested'}}
check(Bag.Missing(59)==nil,'restricted IDs do not imply absence from a name')
auras={secret};check(Bag.Missing(59)==nil,'restricted aura object is unknown')
auras={};combat=true;reads=0
check(Bag.Missing(59)==nil and reads==0,'combat suppresses the out-of-combat reminder without scanning')
combat=false;dead=true
check(Bag.Missing(59)==nil and reads==0,'dead player does not warn or scan')
dead=false
local scan=C_UnitAuras.GetAuraDataByIndex
C_UnitAuras.GetAuraDataByIndex=function() error('restricted') end
check(Bag.Missing(59)==nil,'failed scan never becomes missing')
C_UnitAuras.GetAuraDataByIndex=nil
check(Bag.Missing(59)==nil,'missing aura API stays quiet')
C_UnitAuras.GetAuraDataByIndex=scan

local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:HookScript(event,fn)
    local previous=self.scripts[event]
    self.scripts[event]=function(...) if previous then previous(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object() end
function methods:CreateFontString() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetPoint(point,relative,relativePoint,x,y) self.point,self.x,self.y=point,x,y end
function methods:SetAlpha(value) self.alpha=value end
function methods:IsShown() return self.shown end
function methods:IsVisible() return self.shown end
function methods:SetShown(value)
    if self.shown==value then return end
    self.shown=value
    local handler=self.scripts[value and 'OnShow' or 'OnHide']
    if handler then handler(self) end
end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
setmetatable(methods,{__index=function() return function() end end})
dofile('tests/mock_animation.lua')(methods)
CreateFrame=function() return object() end
UIParent=object()
local db={enabled=true,locked=true,x=0,y=0,scale=1,sleepingBagReminder=true,flashMissingBuffs=true}
local content,host
local module={command='/fclassmate',Apply=function() end}
local instance=NS.ClassHost.Create(module,db,function(owner)
    host=owner;content=object()
    content.Refresh=function() NS.ClassHost.SetFade(host,content,0.2) end
    content.Status=function() return 'test' end
    return content
end)
instance.Apply()
local bag=instance.sleepingBag
check(bag and bag.button.shown and host.sleepingBagMissing and content.alpha==1,'shared host displays the reminder at full opacity')
check(host.width==426 and host.height==56 and bag.button.point=='TOPRIGHT','sleeping-bag reminder does not resize the full bar')
check(bag.border.warningPulseGroup.playing,'missing sleeping-bag buff uses the saved flash preference')
check(not bag.button.scripts.OnUpdate and not content.scripts.OnUpdate,'sleeping-bag checks add no polling')
NS.ClassHost.SetFade(host,content,0.6)
check(content.alpha==1,'class refresh cannot dim an active sleeping-bag warning')
auras={{spellId=429959}}
bag.button.scripts.OnEvent(bag.button,'UNIT_AURA','player')
check(not bag.button.shown and not host.sleepingBagMissing and content.alpha==0.6
    and not bag.border.warningPulseGroup.playing,'buff return stops warning and restores normal fade')
auras={};bag.button.scripts.OnEvent(bag.button,'UNIT_AURA','player')
reads=0;bag.button.scripts.OnEvent(bag.button,'UNIT_AURA','target')
check(reads==0,'non-player aura changes do not scan the player')
combat=true;bag.button.scripts.OnEvent(bag.button,'PLAYER_REGEN_DISABLED')
check(not bag.button.shown and not host.sleepingBagMissing,'combat immediately hides the reminder')
combat=false;bag.button.scripts.OnEvent(bag.button,'PLAYER_REGEN_ENABLED')
check(bag.button.shown,'leaving combat rechecks the current buff state')
auras={{spellId=secret}};bag.Refresh()
check(not bag.button.shown and not host.sleepingBagMissing,'unreadable aura state clears a prior warning')
auras={};db.flashMissingBuffs=false;bag.Refresh()
check(bag.button.shown and not bag.border.warningPulseGroup.playing,'static sleeping-bag warning respects the flash toggle')
db.rangeIconOnly=true;bag.Refresh()
check(bag.button.point=='TOPLEFT' and host.width==426,'compact-mode reminder uses a separate icon beside the range widget')
bag.button.scripts.OnEvent(bag.button,'PLAYER_LEAVING_WORLD')
bag.button.scripts.OnEvent(bag.button,'UNIT_AURA','player')
check(not bag.button.shown,'world leave suspends the reminder across later events')
bag.button.scripts.OnEvent(bag.button,'PLAYER_ENTERING_WORLD')
check(bag.button.shown,'entering the world resumes fresh buff checks')
bag.button.scripts.OnEvent(bag.button,'PLAYER_DEAD')
check(not bag.button.shown,'death clears the reminder')
bag.button.scripts.OnEvent(bag.button,'PLAYER_ALIVE')
check(bag.button.shown,'resurrection rechecks rather than assuming a missing buff')
host:Hide();bag.button.scripts.OnEvent(bag.button,'UNIT_AURA','player')
check(not bag.button.shown and not host.sleepingBagMissing,'events cannot revive a reminder on a hidden bar')
host:Show();check(bag.button.shown,'showing the host refreshes the reminder')
reads=0;bag.button.scripts.OnEvent(bag.button,'PLAYER_LEVEL_UP',60)
check(not bag.button.shown and not host.sleepingBagMissing and not next(bag.button.events) and reads==0,
    'level-up payload 60 clears the reminder before UnitLevel catches up and unregisters listeners')
level=60;bag.Refresh();check(not bag.button.shown,'level 60 stays excluded')
level=59;bag.Refresh();db.sleepingBagReminder=false;bag.Refresh()
check(not bag.button.shown and not next(bag.button.events),'disabling the feature removes its listeners')
db.sleepingBagReminder=true;db.enabled=false;bag.Refresh()
check(not bag.button.shown and not next(bag.button.events),'disabling the class removes sleeping-bag listeners')
print('PASS: '..count..' sleeping-bag reminder checks')
