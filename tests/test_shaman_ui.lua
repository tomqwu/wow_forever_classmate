local NS={}
local root='addons/ForeverUtilities/'
local frames,named={},{}
local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(key,value) self.scripts[key]=value end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateFontString() return object() end
function methods:CreateTexture() return object() end
function methods:CreateMaskTexture() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetText(v) self.text=v end
function methods:SetTexture(v) self.texture=v end
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
    local frame=object();frame.name=name;frame.parent=parent;frames[#frames+1]=frame
    if name then named[name]=frame end
    return frame
end
UIParent=object();Minimap=object();Minimap:SetSize(200,200);UISpecialFrames={}
DEFAULT_CHAT_FRAME={messages={},AddMessage=function(self,text) self.messages[#self.messages+1]=text end};SlashCmdList={}
STANDARD_TEXT_FONT='font';GameTooltip=nil
local class='SHAMAN'
UnitClass=function() return 'Shaman',class end
UnitExists=function() return false end
UnitAffectingCombat=function() return false end
UnitIsDead=function() return false end
UnitPower=function() return 80 end
UnitPowerMax=function() return 100 end
GetTime=function() return 100 end
GetTotemInfo=function() return false,'',0,0,0 end
GetTotemTimeLeft=function() return 0 end
GetInventoryItemID=function() return nil end
Enum={WeaponSlot={MainHand=0},SpellBookSpellBank={Player=0}}
C_Item={GetWeaponEnchantInfo=function() return {} end}
local book={
    [1]={spellID=1001,name='Maelstrom Weapon',iconID=501},
    [2]={spellID=1002,name='Windfury Weapon',iconID=502},
    [3]={spellID=1003,name='Lightning Shield',iconID=503},
}
C_Spell={GetSpellInfo=function(value)
    if type(value)=='number' then local item=book[value-1000];return item and {name=item.name,iconID=item.iconID} end
    return {name=value,iconID=123}
end}
C_SpellBook={
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=3} end,
    GetSpellBookItemInfo=function(slot) local item=book[slot];return {spellID=item.spellID,isPassive=false,isOffSpec=false} end,
    IsSpellKnown=function() return true end,
}
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' then
        if index==1 then return {name='Maelstrom Weapon',icon=501,applications=5,expirationTime=120,sourceUnit='player'} end
        if index==2 then return {name='Lightning Shield',icon=503,applications=3,expirationTime=600,sourceUnit='player'} end
    end
end}
ForeverUtilitiesDB={shaman={x=72,y=-101,scale=1.2,locked=false}}
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ShamanContext.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Shaman.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local events=frames[1]
events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
local db=NS.Shaman.db
check(db.x==72 and db.y==-101 and db.scale==1.2 and not db.locked,'saved shaman layout retained')
check(NS.Shaman.instance~=nil,'shaman creates active helper')
check(NS.Shaman.spells.maelstrom and NS.Shaman.spells.windfury and NS.Shaman.spells.lightningShield,'learned Shaman abilities discovered from spellbook')
local host=named.ForeverClassmateShamanFrame
local indicator=named.ForeverClassmateShamanIndicator
check(host and host.width==400 and host.height==56 and host.shown,'compact shaman bar created')
check(indicator and indicator.scripts.OnUpdate~=nil,'enabled info polls for live timers')
indicator.scripts.OnEvent(indicator,'PLAYER_LEAVING_WORLD');check(indicator.scripts.OnUpdate==nil,'world exit stops polling')
indicator.scripts.OnEvent(indicator,'PLAYER_ENTERING_WORLD');check(indicator.scripts.OnUpdate~=nil,'world entry restarts polling')
local slash=SlashCmdList.FOREVERUTILITIES
slash('')
local panel=named.ForeverClassmateShamanOptions
check(panel and panel.shown and panel.movable,'movable shaman settings panel')
for _,key in ipairs({'showTotems','showWeaponImbue','showShield','showSpecHelper','showMana','totemRecallHint','fadeOutOfCombat'}) do
    check(panel.controls[key]~=nil,'shaman option exists: '..key)
end
for _,key in ipairs({'showTotems','showWeaponImbue','showShield','showSpecHelper','showMana','totemRecallHint'}) do
    local control=panel.controls[key];control:SetChecked(false);control.scripts.OnClick(control)
    check(db[key]==false,'shaman option saves: '..key)
end
check(indicator.scripts.OnUpdate==nil,'all live information disabled stops polling')
slash('scale 1.4');check(db.scale==1.4,'shaman scale command')
slash('lock');check(db.locked,'shaman lock command')
local lock=named.ForeverClassmateShamanLock;lock.scripts.OnClick();check(not db.locked,'shaman bar lock button')
slash('off');check(not db.enabled and not host.shown and not indicator.scripts.OnUpdate,'disable stops and hides shaman bar')
check(next(indicator.events)==nil,'disable unregisters shaman events')
slash('on');check(db.enabled and host.shown,'command reenables shaman bar')
local mini=named.ForeverClassmateShamanMinimap
check(mini and mini.width==28 and mini.height==28,'shaman uses shared minimap launcher')
slash('reset');check(db.showTotems and db.showWeaponImbue and db.showShield and db.showSpecHelper and db.showMana,'reset restores shaman features')
local before=#DEFAULT_CHAT_FRAME.messages;slash('status');check(#DEFAULT_CHAT_FRAME.messages>=before+2,'status reports module diagnostics')
NS.Shaman.Initialize(ForeverUtilitiesDB);check(NS.Shaman.db.x==0 and ForeverUtilitiesDB.schemaVersion==3,'shaman preferences persist with class schema')
print('PASS: '..count..' shaman UI and lifecycle checks')
