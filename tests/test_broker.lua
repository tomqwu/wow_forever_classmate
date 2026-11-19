-- LibDataBroker source for Titan Panel and other broker displays: it mirrors
-- the class host's confirmed stat and warnings, never reads game data, and
-- publishes only real changes.
local NS={}
local root='addons/ForeverUtilities/'
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local dead=false
UnitIsDead=function() return dead end
UnitIsGhost=function() return false end
UnitAffectingCombat=function() return false end
UnitClass=function() return 'Warlock','WARLOCK' end
UnitLevel=function() return 60 end
C_UnitAuras={GetAuraDataByIndex=function() return nil end}
securecallfunction=function(fn,...) return fn(...) end
geterrorhandler=function() return error end

local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event,fn)
    local previous=self.scripts[event]
    self.scripts[event]=function(...) if previous then previous(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object() end
function methods:CreateFontString() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
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
function methods:SetParent(parent) self.parent=parent end
function methods:SetMovable(value) self.movable=value end
function methods:SetUserPlaced(value)
    if not rawget(self,'movable') and not rawget(self,'resizable') then error('Frame:SetUserPlaced(): Frame is not movable or resizable') end
end
setmetatable(methods,{__index=function() return function() end end})
dofile('tests/mock_animation.lua')(methods)
CreateFrame=function() return object() end
UIParent=object()

assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'LevelingBuffs.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Folded.lua'))('ForeverUtilities',NS)
-- The exact embedded copies, in TOC order.
for _,lib in ipairs({'Libs/LibStub/LibStub.lua','Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua','Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua'}) do
    assert(loadfile(root..lib))('ForeverUtilities',NS)
end
assert(loadfile(root..'Broker.lua'))('ForeverUtilities',NS)
local toc=io.open(root..'ForeverUtilities.toc'):read('*a')
check(toc:find('Libs\\LibDataBroker%-1%.1\\LibDataBroker%-1%.1%.lua\nBroker%.lua\nUI%.lua'),'libraries and Broker load before UI')

local LDB=LibStub('LibDataBroker-1.1')
local changes={}
LDB.RegisterCallback(changes,'LibDataBroker_AttributeChanged_ForeverClassmate_text',function(_,_,_,value) changes[#changes+1]=value end)
local db={enabled=false,locked=true,x=0,y=0,scale=1,collapsed=true,flashMissingBuffs=true}
local module={name='Forever Classmate — Warlock',classToken='WARLOCK',db=db}
NS.Classes.WARLOCK=module
local opened=0
local broker=NS.Broker.Initialize(function() opened=opened+1 end)
check(broker and LDB:GetDataObjectByName('ForeverClassmate')==broker,'Classmate registers one LibDataBroker object')
check(broker.type=='data source' and broker.label=='Classmate'
    and broker.icon=='Interface\\AddOns\\ForeverUtilities\\Textures\\Classes\\WARLOCK','data source uses the class crest')
check(broker.text:find('Off'),'a disabled class says Off without creating a bar')
check(NS.Broker.Initialize(function() opened=opened+1 end)==broker,'initializing again reuses the object')

db.enabled=true
local host,content
local instance=NS.ClassHost.Create(module,db,function(owner)
    host=owner;content=object()
    content.Refresh=function() NS.ClassHost.SetFade(owner,content,0.2) end
    content.Status=function() return 'test' end
    return content
end)
module.Apply=instance.Apply;instance.Apply()
check(broker.text=='','an enabled class with nothing confirmed shows no text')
NS.ClassHost.SetStat(host,{icon='Interface\\Icons\\Shard',text='14',label='Soul Shards'})
check(broker.text=='14','the compact stat appears on the panel')
NS.ClassHost.SetWarning(host,'upkeep',true,'Interface\\Icons\\Armor','Armor missing')
check(broker.text=='14  |cffffb347Armor missing|r','a confirmed warning follows the stat')
NS.ClassHost.SetWarning(host,'pet',true,'Interface\\Icons\\Pet','Demon missing')
check(broker.text:find('Armor missing %+1'),'more warnings add a count')
local before=#changes
NS.ClassHost.SetWarning(host,'pet',true,'Interface\\Icons\\Pet','Demon missing')
NS.ClassHost.SetStat(host,{icon='Interface\\Icons\\Shard',text='14',label='Soul Shards'})
instance.Apply()
check(#changes==before,'repeated identical updates publish nothing')
NS.ClassHost.SetWarning(host,'upkeep',false,'Interface\\Icons\\Armor','Armor missing')
NS.ClassHost.SetWarning(host,'pet',true,nil,'Demon missing')
check(broker.text=='14','only confirmed warnings with an icon count, like the card')

db.collapsed=false;instance.Apply()
check(broker.text=='14','the expanded bar still publishes its stat')
NS.ClassHost.SetStat(host,{icon='Interface\\Icons\\Shard',text='0',label='Soul Shards',color={1,0.25,0.2}})
check(broker.text=='|cffff4033'..'0|r','the stat keeps its color')
content:Hide()
check(broker.text=='','hidden content publishes no stat')
content:Show()

local lines={}
local tooltip={AddLine=function(_,text) lines[#lines+1]=text end}
NS.ClassHost.SetWarning(host,'upkeep',true,'Interface\\Icons\\Armor','Armor missing')
broker.OnTooltipShow(tooltip)
local joined=table.concat(lines,'\n')
check(joined:find('Forever Classmate') and joined:find('Warlock') and joined:find('Soul Shards: 0')
    and joined:find('Armor missing') and joined:find('Left%-click: settings') and joined:find('Right%-click: fold or expand the bar'),
    'tooltip names the class, stat, warnings and both clicks')

broker.OnClick(nil,'LeftButton');check(opened==1,'left-click opens settings')
db.foldedByDeath=true
broker.OnClick(nil,'RightButton');check(db.collapsed==true and db.foldedByDeath==nil,'right-click folds as a player choice')
broker.OnClick(nil,'RightButton');check(db.collapsed==false,'right-click expands again')

dead=true;host.foldRefresh()
check(broker.text=='','a dead character publishes nothing')
broker.OnClick(nil,'RightButton');check(db.collapsed==false,'right-click cannot change the view while dead')
dead=false;host.foldRefresh()
check(broker.text:find('Armor missing'),'revival restores the published state')

local other={name='Forever Classmate — Mage',classToken='MAGE',db={enabled=true}}
NS.Broker.Refresh(other,nil,{{label='Armor missing',icon='x',active=true}})
check(broker.icon:find('WARLOCK'),'an inactive class module never publishes')

module.SetEnabled=nil;db.enabled=false;instance.Apply()
check(broker.text:find('Off'),'disabling the class publishes Off')
check(rawget(host,'scripts').OnUpdate==nil,'the broker adds no polling')
print('PASS: '..count..' broker checks')
