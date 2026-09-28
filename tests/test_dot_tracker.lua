local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/DotTracker.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local now=100
GetTime=function() return now end
local units={target={guid='A',name='First',auras={}},nameplate1={guid='A',name='First',auras={}},
    nameplate2={guid='B',name='Second',auras={}}}
UnitExists=function(unit) return units[unit]~=nil end
UnitCanAttack=function() return true end
UnitIsDead=function() return false end
UnitIsUnit=function(a,b) return a==b end
UnitGUID=function(unit) return units[unit].guid end
UnitName=function(unit) return units[unit].name end
local reads={}
C_UnitAuras={GetAuraDataByIndex=function(unit,index)
    reads[unit]=(reads[unit] or 0)+1
    return units[unit].auras[index]
end}
local names={Corruption={key='corruption'},Immolate={key='immolate'}}
units.target.auras={
    {name='Corruption',sourceUnit='player',duration=20,expirationTime=120},
    {name='Immolate',sourceUnit='party1',duration=20,expirationTime=125},
    {name='Immolate',isFromPlayerOrPlayerPet=true,duration=10,expirationTime=108},
}
units.nameplate1.auras=units.target.auras
units.nameplate2.auras={{name='Corruption',sourceUnit='player',duration=20,expirationTime=118}}
local first=NS.DotTracker.ReadUnit('target',names,now)
check(first and first.guid=='A' and first.effects.corruption.left==20 and first.effects.immolate.left==8,
    'reader keeps only player-owned readable DoTs with exact duration')
units.target.auras[1].expirationTime=secret
first=NS.DotTracker.ReadUnit('target',names,now)
check(first and not first.effects.corruption and first.effects.immolate,'secret timer is omitted without a guessed bar')
units.target.auras[1].expirationTime=120
units.target.auras[2].sourceUnit=secret
first=NS.DotTracker.ReadUnit('target',names,now)
check(first and first.effects.corruption and first.effects.immolate,'another restricted aura does not erase confirmed player effects')
units.target.auras[2].sourceUnit='party1'
units.target.auras[1].name=secret
first=NS.DotTracker.ReadUnit('target',names,now)
check(first and not first.effects.corruption and first.effects.immolate,
    'secret aura identity is skipped without hiding another readable player DoT')
units.target.auras[1].name='Corruption'

local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(key,value) self.scripts[key]=value end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object() end
function methods:CreateFontString() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetPoint() end
function methods:SetText(value) self.text=value end
function methods:SetShown(value) self.shown=value end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetMinMaxValues(a,b) self.minimum,self.maximum=a,b end
function methods:SetValue(value) self.value=value end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function() return object() end
local parent=object();local db={showMultiDots=true}
local module={spells={corruption={name='Corruption'},immolate={name='Immolate'}}}
local tracker=NS.DotTracker.Create(parent,db,module,{'corruption','immolate'},{0.5,0.4,0.9})
tracker.Refresh(true)
check(tracker.shown and tracker.events.NAME_PLATE_UNIT_ADDED and tracker.events.UNIT_AURA,
    'enabled tracker listens for nameplate and aura changes')
check(tracker.bars[1].shown and tracker.bars[2].shown and tracker.bars[3].shown
    and not tracker.bars[4].shown,'target and one distinct nameplate produce three slim bars')
check(tracker.heading.text=='DoTs' and tracker.bars[3].label.text:find('Second',1,true)
    and tracker.bars[1].time.text=='20s','duplicate target nameplate is suppressed by GUID and timer has reserved space')
reads={}
tracker.scripts.OnEvent(tracker,'UNIT_AURA','nameplate2')
check(reads.nameplate2 and not reads.target and not reads.nameplate1,
    'one nameplate aura event does not rescan every other target')
units.target.auras={}
tracker.scripts.OnEvent(tracker,'UNIT_AURA','target')
check(tracker.bars[1].shown and tracker.bars[1].label.text:find('Second',1,true)
    and not tracker.bars[2].shown,'a removed target aura clears its bar')
units.target.auras=units.nameplate1.auras
tracker.scripts.OnEvent(tracker,'UNIT_AURA','target')
now=105;tracker.scripts.OnUpdate(tracker,0.11)
check(tracker.bars[1].value==15 and tracker.bars[1].time.text=='15s',
    'bar and separate timer shrink against verified expiration time')
tracker.scripts.OnEvent(tracker,'NAME_PLATE_UNIT_REMOVED','nameplate2')
check(not tracker.bars[3].shown and tracker.heading.text=='DoTs',
    'removed nameplate clears its bars immediately')
now=126;tracker.scripts.OnUpdate(tracker,0.11)
check(not tracker.shown and not tracker.scripts.OnUpdate,
    'expired DoTs disappear without retaining stale target claims')
db.showMultiDots=false;tracker.Refresh(true)
check(not tracker.shown and not tracker.scripts.OnUpdate and not next(tracker.events),
    'disabled feature unregisters events and stops updates')
print('PASS: '..count..' multi-target DoT checks')
