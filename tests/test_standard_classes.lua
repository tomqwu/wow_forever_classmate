local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
local root='addons/ForeverUtilities/'
local frames,named={},{}
local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(key,value) self.scripts[key]=value end
function methods:RegisterEvent(event)
    assert(event~='LEARNED_SPELL_IN_TAB','Forever rejects the removed learned-spell event')
    self.events[event]=true
end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateFontString() return object() end
function methods:CreateTexture() return object() end
function methods:CreateMaskTexture() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetWidth(w) self.width=w end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetText(v) self.text=v end
function methods:SetFormattedText(format,value) self.formattedFormat=format;self.formattedValue=value end
function methods:SetTexture(v) self.texture=v end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetMovable(v) self.movable=v end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:SetScale(v) self.scale=v end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetShown(v) self.shown=v end
function methods:IsShown() return self.shown end
function methods:SetValue(v) self.value=v end
function methods:SetMinMaxValues(minimum,maximum) self.minimum,self.maximum=minimum,maximum end
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
UnitGetTotalAbsorbs=function() return 0 end
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
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=#book} end,
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
check(indicator.events.LEARNED_SPELL_IN_SKILL_LINE and not indicator.events.LEARNED_SPELL_IN_TAB,'class discovery uses the Forever learned-spell event')
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
    check(named[entry[2].indicatorName].events.LEARNED_SPELL_IN_SKILL_LINE,entry[1]..' registers the supported spell learning event')
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

local function Fixture(module,names,activeAuras)
    book={}
    for i,name in ipairs(names) do book[i]={spellID=4000+i,name=name,iconID=700+i,isPassive=false} end
    C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
        if unit=='player' and filter=='HELPFUL' then
            local name=activeAuras[index]
            if name then return {name=name,icon=500,sourceUnit='player'} end
        end
    end
    local frame=named[module.indicatorName]
    frame.scripts.OnEvent(frame,'SPELLS_CHANGED')
    return frame
end
local paladin=Fixture(NS.Paladin,{'Seal of Justice'},{'Seal of Justice'})
check(paladin.cells.upkeep.top.text=='1/1' and paladin.cells.upkeep.bottom.text=='OK','Seal of Justice satisfies Paladin seal upkeep')
paladin=Fixture(NS.Paladin,{'Seal of Fury'},{'Seal of Fury'})
check(paladin.cells.upkeep.bottom.text=='OK','Forever Seal of Fury satisfies tank seal upkeep')
paladin=Fixture(NS.Paladin,{'Seal of Wisdom'},{'Seal of Wisdom'})
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='target' and filter=='HARMFUL' and index==1 then return {name='Judgement of Wisdom',sourceUnit='player',expirationTime=110} end
end
paladin.Update()
check(paladin.cells.target.top.text=='10s','Paladin recognizes a judgment effect derived from its learned seal without a separate spellbook entry')

local warrior=Fixture(NS.Warrior,{'Battle Shout','Rend'},{'Battle Shout'})
check(warrior.cells.upkeep.bottom.text=='OK' and warrior.cells.target.top.text=='None','absent optional Warrior target effects are neutral rather than mandatory warnings')
local druid=Fixture(NS.Druid,{'Mark of the Wild','Thorns'},{'Gift of the Wild','Thorns'})
check(druid.cells.upkeep.top.text=='2/2','Druid accepts Gift of the Wild as Mark upkeep')
local mage=Fixture(NS.Mage,{'Frost Armor','Pyroblast'},{'Frost Armor'})
check(mage.cells.upkeep.bottom.text=='OK' and mage.cells.target.top.text=='None','Mage armor is tracked without demanding a Pyroblast on every target')
local oldExists,oldCombat=UnitExists,UnitAffectingCombat
UnitExists=function() return false end;UnitAffectingCombat=function() return false end
mage.Update()
check(mage.alpha==0.75,'Mage bar remains readable with no target outside combat')
check(not mage.cells.resource.icon.shown and mage.cells.resource.top.text=='70%' and mage.cells.resource.bottom.text==''
    and mage.cells.resource.meter.value==70 and mage.cells.resource.top.width==53,'Mage mana uses a compact vertical meter and percentage without a redundant label')
check(mage.cells.upkeep.icon.shown and mage.cells.upkeep.icon.texture==500,'active Mage armor keeps its own icon')
check(not mage.cells.target.icon.shown and mage.cells.target.top.text=='No target'
    and not mage.cells.ability.icon.shown and mage.cells.ability.top.text=='—',
    'empty target and ability slots do not duplicate the armor icon')
local savedPower,savedMax=UnitPower,UnitPowerMax
UnitPower=function() return secret end;UnitPowerMax=function() return secret end
UnitPowerPercent=function() return 0.56 end
mage.Update()
check(mage.cells.resource.top.text=='56%' and mage.cells.resource.bottom.text=='' and mage.cells.resource.meter.value==56
    and mage.cells.resource.tooltipLines[1]:find('exact values unavailable',1,true),
    'Mage shows readable mana percentage while exact current and maximum are restricted')
CurveConstants={ScaleTo100={}}
UnitPowerPercent=function() return secret end
mage.Update()
check(mage.cells.resource.top.formattedFormat=='%.0f%%' and mage.cells.resource.top.formattedValue==secret
    and mage.cells.resource.meter.value==secret
    and mage.cells.resource.tooltipLines[1]:find('displayed by the client',1,true),
    'Mage forwards a restricted native percentage only to the documented font renderer')
UnitPower,UnitPowerMax,UnitPowerPercent,CurveConstants=savedPower,savedMax,nil,nil
UnitExists=function() return true end;mage.Update()
check(mage.alpha==0.9 and mage.cells.target.icon.shown and mage.cells.target.icon.texture==702,
    'Mage target gains a learned spell icon and remains readable outside combat')
NS.Mage.spells.iceLance={id=4900,name='Ice Lance',icon=703,kind='cue'};mage.Update()
check(mage.cells.ability.icon.shown and mage.cells.ability.icon.texture==703,
    'learned Mage ability restores its own icon when available')
NS.Mage.spells.iceLance=nil
UnitAffectingCombat=function() return true end;mage.Update()
check(mage.alpha==1,'Mage bar is fully visible in combat')
UnitExists,UnitAffectingCombat=oldExists,oldCombat
mage=Fixture(NS.Mage,{'Frost Armor','Mana Shield'},{'Frost Armor','Mana Shield'})
check(mage.events.UNIT_ABSORB_AMOUNT_CHANGED and NS.Mage.db.showMageShield==true,
    'Mage subscribes to absorb changes and defaults its shield feature on')
UnitGetTotalAbsorbs=function() return 45 end
mage.Update()
check(mage.cells.upkeep.top.text=='45' and mage.cells.upkeep.bottom.text=='45% HP'
    and mage.cells.upkeep.meter.value==45 and mage.cells.upkeep.meter.maximum==100,
    'active Mage shield shows total absorbs and gradually scaled health coverage')
check(mage.cells.upkeep.tooltipLines[1]:find('Frost Armor',1,true)
    and mage.cells.upkeep.tooltipLines[3]:find('all active absorb',1,true),
    'shield display keeps armor details and explains aggregate absorbs')
UnitGetTotalAbsorbs=function() return secret end
mage.Update()
check(mage.cells.upkeep.top.formattedValue==secret and mage.cells.upkeep.meter.value==secret
    and mage.cells.upkeep.bottom.text=='Shield',
    'restricted absorb amount is handed only to native renderers')
NS.Mage.db.showMageShield=false;mage.Update()
check(mage.cells.upkeep.bottom.text=='OK' and not mage.cells.upkeep.meter.shown,
    'Mage shield toggle leaves armor upkeep intact')
NS.Mage.db.showUpkeep=false;NS.Mage.db.showMageShield=true;mage.Update()
check(mage.cells.upkeep.shown and mage.cells.upkeep.top.formattedValue==secret,
    'shield indicator stays independent when armor upkeep is hidden')
NS.Mage.db.showUpkeep=true
NS.Mage.db.showMageShield=true;UnitGetTotalAbsorbs=function() return 0 end
local priest=Fixture(NS.Priest,{'Power Word: Fortitude','Divine Spirit','Inner Fire'},{'Prayer of Fortitude','Prayer of Spirit','Inner Fire'})
check(priest.cells.upkeep.top.text=='3/3','Priest group prayers satisfy individual buff upkeep')
local warlock=Fixture(NS.Warlock,{'Demon Skin'},{'Demon Skin'})
check(warlock.cells.upkeep.top.text=='1/1','Warlock does not demand a demon before learning a summon')
warlock=Fixture(NS.Warlock,{'Demon Skin','Summon Imp'},{'Demon Skin'})
check(warlock.cells.upkeep.bottom.text=='!1','learned Warlock summon enables missing-demon warning')
local deadTarget=false
UnitIsDead=function(unit) return unit=='target' and deadTarget end
UnitIsFriend=function() return false end
deadTarget=true;warrior.Update()
check(warrior.cells.target.top.text=='Dead','dead hostile target is not mislabeled friendly')
deadTarget=false
warrior.scripts.OnEvent(warrior,'PLAYER_DEAD');warrior.scripts.OnEvent(warrior,'UNIT_AURA','player');warrior.Refresh()
check(not warrior.shown and not warrior.scripts.OnUpdate,'standard class stays suspended after death and settings refresh')
warrior.scripts.OnEvent(warrior,'PLAYER_ALIVE')
check(warrior.shown and warrior.scripts.OnUpdate,'standard class resumes after resurrection')
local reads=0
UnitPower=function() reads=reads+1;return 70 end
C_UnitAuras.GetAuraDataByIndex=function() reads=reads+1 end
C_Spell.GetSpellCooldown=function() reads=reads+1;return {startTime=0,duration=0,isEnabled=true} end
for _,key in ipairs({'showResource','showUpkeep','showTarget','showAbilities','showRacial'}) do NS.Warrior.db[key]=false end
warrior.Refresh()
check(reads==0 and not warrior.scripts.OnUpdate,'disabled standard blocks perform no resource, aura, cooldown reads or polling')
print('PASS: '..count..' standard class runtime checks')
