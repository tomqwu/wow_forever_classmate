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
function methods:SetWidth(w) self.width=w end
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
local currentClass='PALADIN'
UnitClass=function() return currentClass,currentClass end
UnitExists=function(unit) return unit=='target' end
UnitCanAttack=function() return true end
UnitIsDead=function() return false end
UnitAffectingCombat=function() return true end
UnitPower=function() return 70 end;UnitPowerMax=function() return 100 end;UnitPowerType=function() return 0,'MANA' end
UnitHealth=function() return 90 end;UnitHealthMax=function() return 100 end
GetTime=function() return 100 end
GetComboPoints=function() return 0 end
GetShapeshiftForm=function() return 0 end
GetInventoryItemID=function() return nil end
GetItemCount=function() return 0 end
Enum={SpellBookSpellBank={Player=0},WeaponSlot={MainHand=0,OffHand=1},PowerType={ComboPoints=4}}
C_Item={GetWeaponEnchantInfo=function() return {} end,GetItemCount=function() return 0 end}
local book={
    [1]={spellID=1001,name='Seal of Righteousness',iconID=51,isPassive=false},
    [2]={spellID=1002,name='Judgement of the Crusader',iconID=52,isPassive=false},
    [3]={spellID=1003,name='Holy Strike',iconID=53,isPassive=false},
    [4]={spellID=1004,name='Will to Survive',iconID=54,isPassive=false},
}
C_Spell={
    GetSpellInfo=function(value)
        if type(value)=='number' then for _,item in pairs(book) do if item.spellID==value then return {name=item.name,iconID=item.iconID} end end end
        return {name=value,iconID=123}
    end,
    GetSpellCooldown=function() return {startTime=0,duration=0,isEnabled=true} end,
    IsSpellUsable=function() return true,false end,
}
C_SpellBook={
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=4} end,
    GetSpellBookItemInfo=function(slot) local item=book[slot];return {spellID=item.spellID,isPassive=item.isPassive,isOffSpec=false} end,
    IsSpellKnown=function() return true end,
}
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Seal of Righteousness',icon=51,expirationTime=150,sourceUnit='player'} end
    if unit=='target' and filter=='HARMFUL' and index==1 then return {name='Judgement of the Crusader',icon=52,expirationTime=112,sourceUnit='player'} end
end}
UnitIsUnit=function(a,b) return a==b end
ForeverUtilitiesDB={paladin={x=77,y=-88,scale=1.1,locked=false}}
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassContext.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'StandardClasses.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local events=frames[1];events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
check(NS.Paladin.instance~=nil,'active Paladin module creates helper')
check(NS.Warrior.instance==nil and NS.Rogue.instance==nil and NS.Druid.instance==nil and NS.Mage.instance==nil and NS.Priest.instance==nil and NS.Warlock.instance==nil,'inactive classes create no helpers')
check(NS.Paladin.db.x==77 and NS.Paladin.db.y==-88 and NS.Paladin.db.scale==1.1 and not NS.Paladin.db.locked,'saved Paladin layout retained')
check(ForeverUtilitiesDB.warrior and ForeverUtilitiesDB.rogue and ForeverUtilitiesDB.druid and ForeverUtilitiesDB.mage and ForeverUtilitiesDB.priest and ForeverUtilitiesDB.warlock,'independent class databases initialized')
check(NS.Paladin.spells.sealRighteousness and NS.Paladin.spells.judgementCrusader and NS.Paladin.spells.holyStrike and NS.Paladin.spells.willToSurvive,'class and racial spells discovered')
local host=named.ForeverClassmatePaladinFrame;local indicator=named.ForeverClassmatePaladinIndicator
check(host and host.width==426 and host.height==56 and host.shown,'standard class bar matches rendered native swing-bar width')
check(indicator and indicator.scripts.OnUpdate~=nil,'enabled helper polls live state')
check(indicator.cells.resource.icon.width==24 and indicator.cells.resource.top.width==41,'readable icon slots fit the native-width bar')
check(indicator.cells.racial.x+indicator.cells.racial.width==398,'all five class slots end before the lock control')
indicator.scripts.OnEvent(indicator,'PLAYER_LEAVING_WORLD');check(indicator.scripts.OnUpdate==nil,'world exit stops polling')
indicator.scripts.OnEvent(indicator,'PLAYER_ENTERING_WORLD');check(indicator.scripts.OnUpdate~=nil,'world entry restarts polling')
NS.Paladin.SetEnabled(false);check(not host.shown and indicator.scripts.OnUpdate==nil,'disable hides helper and stops polling')
NS.Paladin.SetEnabled(true);check(host.shown and indicator.scripts.OnUpdate~=nil,'reenable restores helper')
check(SLASH_FOREVERUTILITIES5=='/fpaladin' and SLASH_FOREVERUTILITIES11=='/fwarlock','all class command aliases registered')
SlashCmdList.FOREVERUTILITIES('status');check(#DEFAULT_CHAT_FRAME.messages>=2,'status reports live class diagnostics')
for _,entry in ipairs({{'WARRIOR',NS.Warrior},{'ROGUE',NS.Rogue},{'DRUID',NS.Druid},{'MAGE',NS.Mage},{'PRIEST',NS.Priest},{'WARLOCK',NS.Warlock}}) do
    currentClass=entry[1];entry[2].Apply()
    check(entry[2].instance~=nil,entry[1]..' creates its own helper when active')
    check(named[entry[2].frameName] and named[entry[2].indicatorName],entry[1]..' uses its own named frames')
end

local originalAuras=C_UnitAuras.GetAuraDataByIndex
C_UnitAuras.GetAuraDataByIndex=function() error('restricted aura') end
indicator.Update()
check(indicator.cells.upkeep.bottom.text=='?','restricted upkeep aura is not reported as missing')
check(indicator.cells.target.top.text=='?','restricted target aura is not reported as missing: '..tostring(indicator.cells.target.top.text))

local targetReads=0
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='target' and filter=='HARMFUL' then targetReads=targetReads+1 end
    return originalAuras(unit,index,filter)
end
NS.Paladin.db.showTarget=false;indicator.Update()
check(targetReads==0,'disabled target block does not read target auras')
check(not indicator.cells.target.shown and indicator.cells.ability.shown and indicator.cells.ability.top.text=='Ready','ability display remains independent of target display')
NS.Paladin.db.showTarget=true
NS.Paladin.db.showAbilities=false;indicator.Update()
check(indicator.cells.target.shown and not indicator.cells.ability.shown and indicator.cells.target.top.text=='12s','target display remains independent of ability display')
NS.Paladin.db.showAbilities=true

local rogueIndicator=named.ForeverClassmateRogueIndicator
NS.Rogue.spells={sliceDice={id=2001,name='Slice and Dice',icon=61,kind='upkeep'}}
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Slice and Dice',icon=61,expirationTime=130,sourceUnit='player'} end
end
rogueIndicator.Update()
check(rogueIndicator.cells.upkeep.top.text=='1/1','Rogue finisher buff is checked alongside weapon coatings')
check(rogueIndicator.cells.upkeep.tooltipLines[2] and rogueIndicator.cells.upkeep.tooltipLines[2]:find('Slice and Dice',1,true),'Rogue upkeep details name the active finisher buff')

local druidIndicator=named.ForeverClassmateDruidIndicator
NS.Druid.spells={markWild={id=2101,name='Mark of the Wild',icon=62,kind='upkeep'},thorns={id=2102,name='Thorns',icon=63,kind='upkeep'}}
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Thorns',icon=63,expirationTime=130,sourceUnit='player'} end
end
local savedPowerType=UnitPowerType;UnitPowerType=nil
local ok=pcall(druidIndicator.Update)
check(ok and druidIndicator.cells.resource.top.text=='?','Druid survives an unavailable current-power API')
check(druidIndicator.cells.upkeep.top.text=='1/2' and druidIndicator.cells.upkeep.bottom.text=='!1','Druid tracks Mark and Thorns as independent upkeep')
UnitPowerType=savedPowerType

local shadowProc=false
for _,key in ipairs(NS.Priest.procKeys) do if key=='shadowform' then shadowProc=true end end
check(not shadowProc,'persistent Shadowform is excluded from temporary proc selection')
print('PASS: '..count..' standard class runtime checks')
