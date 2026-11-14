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
function methods:SetVertexColor(r,g,b,a) self.vertexColor={r,g,b,a} end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetMovable(v) self.movable=v end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:SetScale(v) self.scale=v end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetShown(v) self.shown=v end
function methods:IsShown() return self.shown end
function methods:SetValue(v) self.value=v end
function methods:SetStatusBarColor(r,g,b) self.color={r,g,b} end
function methods:SetTextColor(r,g,b) self.textColor={r,g,b} end
function methods:SetColorTexture(r,g,b,a) self.color={r,g,b,a} end
function methods:SetMinMaxValues(minimum,maximum) self.minimum,self.maximum=minimum,maximum end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:SetPoint(_,_,_,x,y) self.x,self.y=x,y end
function methods:GetCenter() return 30,40 end
function methods:GetEffectiveScale() return 1 end
setmetatable(methods,{__index=function() return function() end end})
dofile('tests/mock_animation.lua')(methods)
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
UnitAffectingCombat=function() return false end
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
assert(loadfile(root..'SpellAliases.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassContext.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'DotTracker.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'StandardClasses.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local events=frames[1];events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
check(NS.Paladin.instance~=nil,'active Paladin module creates helper')
check(NS.Warrior.instance==nil and NS.Rogue.instance==nil and NS.Druid.instance==nil and NS.Mage.instance==nil and NS.Priest.instance==nil and NS.Warlock.instance==nil,'inactive classes create no helpers')
check(NS.Paladin.db.x==77 and NS.Paladin.db.y==-88 and NS.Paladin.db.scale==1.1 and not NS.Paladin.db.locked,'saved Paladin layout retained')
check(ForeverUtilitiesDB.warrior and ForeverUtilitiesDB.rogue and ForeverUtilitiesDB.druid and ForeverUtilitiesDB.mage and ForeverUtilitiesDB.priest and ForeverUtilitiesDB.warlock,'independent class databases initialized')
for _,module in pairs(NS.Classes) do
    check(module.db.sleepingBagReminder==true,'sleeping bag reminder defaults on for '..module.name)
    local hasBagOption=false
    for _,option in ipairs(module.options) do
        if option.key=='sleepingBagReminder' then hasBagOption=option.kind=='toggle' end
    end
    check(hasBagOption,'sleeping bag reminder has a settings toggle for '..module.name)
    check(module.db.foodXPReminder==true,'food reminder defaults on for '..module.name)
    local hasFoodOption=false
    for _,option in ipairs(module.options) do
        if option.key=='foodXPReminder' then hasFoodOption=option.kind=='toggle' end
    end
    check(hasFoodOption,'food reminder has a settings toggle for '..module.name)
    check(module.db.mailRecipients==true,'mail utility defaults on for '..module.name)
    local hasMailOption=false
    for _,option in ipairs(module.options) do
        if option.key=='mailRecipients' then hasMailOption=option.kind=='toggle' end
    end
    check(hasMailOption,'mail utility has a settings toggle for '..module.name)
    if module~=NS.Paladin then
        check(module.db.minimapInspect==true,'Inspect shortcut defaults on for '..module.name)
    end
end
check(NS.Paladin.db.minimapInspect==true,'Paladin Inspect shortcut defaults on')
check(NS.Paladin.spells.sealRighteousness and NS.Paladin.spells.judgementCrusader and NS.Paladin.spells.holyStrike and NS.Paladin.spells.willToSurvive,'class and racial spells discovered')
local host=named.ForeverClassmatePaladinFrame;local indicator=named.ForeverClassmatePaladinIndicator
check(host and host.width==426 and host.height==56 and host.shown,'standard class bar matches rendered native swing-bar width')
check(indicator and indicator.scripts.OnUpdate~=nil,'enabled helper polls live state')
check(indicator.alpha==0.6,'standard bar starts at its out-of-combat target fade')
host.scripts.OnEnter(host);check(indicator.alpha==1,'mouseover reveals the standard bar')
indicator.Update();check(indicator.alpha==1,'live updates preserve the mouseover reveal')
host.scripts.OnLeave(host);check(indicator.alpha==0.6,'leaving restores the standard fade')
host.IsMouseOver=function() return true end
host.scripts.OnUpdate(host,0.11)
check(indicator.alpha==1,'hover check keeps the bar visible across child controls')
host.scripts.OnLeave(host);check(indicator.alpha==1,'entering a child control does not dim the bar')
host.IsMouseOver=function() return false end
host.scripts.OnUpdate(host,0.11)
check(indicator.alpha==0.6,'hover check restores fade after leaving the whole bar')
host.IsMouseOver=nil
NS.Paladin.db.locked=true;NS.Paladin.Apply()
check(host.mouse==true,'locked standard bar still receives mouseover')
host.scripts.OnEnter(host);check(indicator.alpha==1,'locked bar reveals on hover')
host.scripts.OnDragStart(host);check(rawget(host,'moving')==nil,'locked bar remains immovable')
host.scripts.OnLeave(host);NS.Paladin.db.locked=false;NS.Paladin.Apply()
check(rawget(indicator,'dotTracker')==nil and not NS.Paladin.db.showMultiDots,'Paladin has no DoT side strip')
check(indicator.events.LEARNED_SPELL_IN_SKILL_LINE and not indicator.events.LEARNED_SPELL_IN_TAB,'class discovery uses the Forever learned-spell event')
check(indicator.cells.resource.top.text=='' and not indicator.cells.resource.icon.shown and rawget(indicator,'crest')==nil
    and indicator.cells.resource.meter.shown and indicator.cells.resource.meter.value==70,
    'the resource slot is text only: no duplicate class spell icon inside the bar')
-- A meter-only class gives the room its resource slot does not need to the cards.
check(indicator.cells.resource.width==35 and indicator.cells.upkeep.x==42 and indicator.cells.ability.x==131
    and indicator.cells.racial.x==220 and indicator.cells.target.x==309,
    'the target-dependent slot is last and always-present slots stay together')
for _,key in ipairs({'upkeep','ability','racial','target'}) do
    local cell=indicator.cells[key]
    check(cell.width==89 and cell.bottom.width==cell.width-10 and cell.bottom.x==5 and cell.bottom.y==-34
        and cell.icon.width==22 and cell.icon.x==6 and cell.iconFrame.width==26,
        key..' card puts the name on its own row across the whole slot')
end
check(host.outline.crest.shown and host.outline.crest.width==44 and host.outline.crest.x==0
    and host.outline.crest.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\Classes\\PALADIN',
    'the class crest is centered on the frame edge, half inside, ending before the resource text')
check(indicator.cells.target.x+indicator.cells.target.width==398,'all five class slots end before the lock control')
indicator.scripts.OnEvent(indicator,'PLAYER_LEAVING_WORLD');check(indicator.scripts.OnUpdate==nil,'world exit stops polling')
indicator.scripts.OnEvent(indicator,'PLAYER_ENTERING_WORLD');check(indicator.scripts.OnUpdate~=nil,'world entry restarts polling')
NS.Paladin.SetEnabled(false);check(not host.shown and indicator.scripts.OnUpdate==nil,'disable hides helper and stops polling')
check(host.mouse==false and host.scripts.OnUpdate==nil,'disabled bar stops hover checking')
NS.Paladin.SetEnabled(true);check(host.shown and indicator.scripts.OnUpdate~=nil,'reenable restores helper')
check(SLASH_FOREVERUTILITIES5=='/fpaladin' and SLASH_FOREVERUTILITIES11=='/fwarlock','all class command aliases registered')
SlashCmdList.FOREVERUTILITIES('status');check(#DEFAULT_CHAT_FRAME.messages>=2,'status reports live class diagnostics')
for _,entry in ipairs({{'WARRIOR',NS.Warrior},{'ROGUE',NS.Rogue},{'DRUID',NS.Druid},{'MAGE',NS.Mage},{'PRIEST',NS.Priest},{'WARLOCK',NS.Warlock}}) do
    currentClass=entry[1];entry[2].Apply()
    check(entry[2].instance~=nil,entry[1]..' creates its own helper when active')
    check(named[entry[2].frameName] and named[entry[2].indicatorName],entry[1]..' uses its own named frames')
    check(named[entry[2].indicatorName].events.LEARNED_SPELL_IN_SKILL_LINE,entry[1]..' registers the supported spell learning event')
end
for _,module in ipairs({NS.Warrior,NS.Rogue,NS.Druid,NS.Priest,NS.Warlock}) do
    local dots=named[module.indicatorName].dotTracker
    check(dots and dots.events.NAME_PLATE_UNIT_ADDED and module.db.showMultiDots,
        module.name..' has an active, toggleable multi-target DoT strip')
end
check(rawget(named[NS.Mage.indicatorName],'dotTracker')==nil,'Mage keeps its existing layout without an unverified DoT list')
local minimap=named.ForeverClassmatePaladinMinimap
local inspected=0
UnitIsPlayer=function() return true end;CanInspect=function() return true end
InspectUnit=function(unit) if unit=='target' then inspected=inspected+1 end end
check(minimap.module==NS.Warlock,'shared minimap follows active standard class')
minimap.scripts.OnClick(minimap,'RightButton')
check(inspected==1,'standard class can inspect a player through minimap')
NS.Warlock.db.minimapInspect=false;minimap.scripts.OnClick(minimap,'RightButton')
check(inspected==1,'standard class can disable its Inspect shortcut')
NS.Warlock.Initialize(ForeverUtilitiesDB)
check(NS.Warlock.db.minimapInspect==false,'Inspect preference survives class initialization')
NS.Warlock.db.minimapInspect=true

local originalAuras=C_UnitAuras.GetAuraDataByIndex
C_UnitAuras.GetAuraDataByIndex=function() error('restricted aura') end
indicator.Update()
check(indicator.cells.upkeep.shown and indicator.cells.upkeep.icon.shown
    and indicator.cells.upkeep.top.text=='' and indicator.cells.upkeep.bottom.text=='',
    'restricted upkeep keeps only the previously confirmed buff icon')
check(not indicator.cells.target.shown and indicator.cells.target.top.text=='',
    'restricted target aura hides the effect slot rather than showing a question mark')
local savedCooldown=C_Spell.GetSpellCooldown
C_Spell.GetSpellCooldown=function() return nil end
indicator.Update()
check(not indicator.cells.racial.shown and not indicator.cells.ability.shown,
    'unreadable cooldowns hide racial and ability slots instead of showing unknown status')
C_Spell.GetSpellCooldown=savedCooldown;indicator.Update()

local targetReads=0
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='target' and filter=='HARMFUL' then targetReads=targetReads+1 end
    return originalAuras(unit,index,filter)
end
NS.Paladin.db.showTarget=false;indicator.Update()
check(targetReads==0,'disabled target block does not read target auras')
check(not indicator.cells.target.shown and indicator.cells.ability.shown and indicator.cells.ability.top.text=='Ready','ability display remains independent of target display')
local usableCheck=C_Spell.IsSpellUsable
C_Spell.IsSpellUsable=function() return false,false end;indicator.Update()
check(indicator.cells.ability.top.text=='Context','an ability the client reports unusable reads Context in full, not Ctx')
C_Spell.IsSpellUsable=usableCheck;indicator.Update()
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
check(rogueIndicator.cells.upkeep.top.text=='30s' and rogueIndicator.cells.upkeep.bottom.text=='Slice and Dice',
    'a single active upkeep shows its own name and time instead of 1/1')
check(rogueIndicator.cells.upkeep.tooltipLines[2] and rogueIndicator.cells.upkeep.tooltipLines[2]:find('Slice and Dice',1,true),'Rogue upkeep details name the active finisher buff')
C_UnitAuras.GetAuraDataByIndex=function() return nil end
rogueIndicator.Update()
check(rogueIndicator.cells.upkeep.top.text=='Missing' and rogueIndicator.cells.upkeep.bottom.text=='Slice and Dice' and rogueIndicator.alpha==0.6,
    'a missing temporary Rogue finisher does not keep the bar bright between fights')

local druidIndicator=named.ForeverClassmateDruidIndicator
NS.Druid.spells={markWild={id=2101,name='Mark of the Wild',icon=62,kind='upkeep'},thorns={id=2102,name='Thorns',icon=63,kind='upkeep'}}
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Thorns',icon=63,expirationTime=130,sourceUnit='player'} end
end
-- An earlier active upkeep group must not supply a later missing group's icon.
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Mark of the Wild',icon=62,sourceUnit='player'} end
end
druidIndicator.Update()
check(druidIndicator.cells.upkeep.bottom.text=='Thorns' and druidIndicator.cells.upkeep.icon.texture==63,
    'the upkeep icon belongs to the missing Thorns, not to the active Mark of the Wild')
-- Thorns is cast situationally: missing between fights never wakes the bar.
check(not named.ForeverClassmateDruidFrame.foldWarnings.upkeep.active,
    'missing Thorns raises no maintained-buff warning')
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Thorns',icon=63,expirationTime=130,sourceUnit='player'} end
end
local savedPowerType=UnitPowerType;UnitPowerType=nil
local ok=pcall(druidIndicator.Update)
check(ok and not druidIndicator.cells.resource.meter.shown and not druidIndicator.cells.resource.cue.shown
    and not druidIndicator.cells.resource.shown,
    'with no readable power and no form, the Druid resource slot shows nothing rather than a vague Base label')
check(druidIndicator.cells.upkeep.top.text=='Missing' and druidIndicator.cells.upkeep.bottom.text=='Mark of the Wild'
    and druidIndicator.alpha==1,'a confirmed missing Druid buff keeps the full bar visible outside combat')
UnitAffectingCombat=function() return true end
C_UnitAuras.GetAuraDataByIndex=function() error('restricted combat aura') end
druidIndicator.Update()
check(druidIndicator.cells.upkeep.top.text=='' and druidIndicator.cells.upkeep.bottom.text==''
    and druidIndicator.cells.upkeep.icon.texture==63
    and druidIndicator.cells.upkeep.tooltipLines[2]:find('last seen',1,true),
    'a combat aura gap shows the last observed icon without a partial count or missing warning')
UnitAffectingCombat=function() return false end
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
check(paladin.cells.upkeep.top.text=='Active' and paladin.cells.upkeep.bottom.text=='Seal of Justice','Seal of Justice satisfies Paladin seal upkeep and is named on the bar')
paladin=Fixture(NS.Paladin,{'Seal of Fury'},{'Seal of Fury'})
check(paladin.cells.upkeep.bottom.text=='Seal of Fury','Forever Seal of Fury satisfies tank seal upkeep')
paladin=Fixture(NS.Paladin,{'Seal of Wisdom'},{'Seal of Wisdom'})
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='target' and filter=='HARMFUL' and index==1 then return {name='Judgement of Wisdom',sourceUnit='player',expirationTime=110} end
end
paladin.Update()
check(named.ForeverClassmatePaladinFrame.foldStat.text=='70%' and named.ForeverClassmatePaladinFrame.foldStat.label=='Mana',
    'Paladin compact stat is mana')
check(paladin.cells.target.top.text=='10s','Paladin recognizes a judgment effect derived from its learned seal without a separate spellbook entry')

-- A shout is cast in combat; missing between fights it names itself but never wakes the bar.
local quietWarrior=Fixture(NS.Warrior,{'Battle Shout','Rend'},{})
check(quietWarrior.cells.upkeep.top.text=='Missing' and quietWarrior.cells.upkeep.bottom.text=='Battle Shout'
    and not named.ForeverClassmateWarriorFrame.foldWarnings.upkeep.active,'a missing shout raises no maintained-buff warning')
local warrior=Fixture(NS.Warrior,{'Battle Shout','Rend'},{'Battle Shout'})
check(warrior.cells.upkeep.bottom.text=='Battle Shout' and warrior.cells.target.top.text=='None' and warrior.cells.target.bottom.text=='Rend','absent optional Warrior target effects are neutral rather than mandatory warnings')
local druid=Fixture(NS.Druid,{'Mark of the Wild','Thorns'},{'Gift of the Wild','Thorns'})
check(druid.cells.upkeep.top.text=='2/2' and druid.cells.upkeep.bottom.text=='All active','Druid accepts Gift of the Wild as Mark upkeep')
local mage=Fixture(NS.Mage,{'Frost Armor','Pyroblast'},{'Frost Armor'})
local waterCount=C_Item.GetItemCount
C_Item.GetItemCount=function(id) return id==8079 and 12 or id==8078 and 3 or 0 end;mage.Update()
check(named.ForeverClassmateMageFrame.foldStat.text=='15' and named.ForeverClassmateMageFrame.foldStat.label=='Conjured water',
    'Mage compact stat totals every rank of conjured water')
C_Item.GetItemCount=waterCount;mage.Update()
check(mage.cells.upkeep.bottom.text=='Frost Armor' and mage.cells.target.top.text=='None','Mage armor is tracked without demanding a Pyroblast on every target')
local oldExists,oldCombat=UnitExists,UnitAffectingCombat
UnitExists=function() return false end;UnitAffectingCombat=function() return false end
mage.Update()
check(mage.alpha==0.75,'Mage bar remains readable with no target outside combat')
check(not mage.cells.resource.icon.shown and mage.cells.resource.top.text=='' and mage.cells.resource.bottom.text==''
    and mage.cells.resource.meter.shown and mage.cells.resource.meter.value==70
    and mage.cells.resource.tooltipLines[1]=='Mana: 70 / 100 (70%)',
    'Mage mana is a vertical meter with no percentage text; exact values are in the tooltip')
check(mage.cells.upkeep.icon.shown and mage.cells.upkeep.icon.texture==500,'active Mage armor keeps its own icon')
check(not mage.cells.target.shown and not mage.cells.ability.shown,
    'empty target and ability slots disappear instead of displaying placeholder status')
local savedPower,savedMax=UnitPower,UnitPowerMax
UnitPower=function() return secret end;UnitPowerMax=function() return secret end
UnitPowerPercent=function() return 0.56 end
mage.Update()
check(mage.cells.resource.top.text=='' and mage.cells.resource.meter.shown and mage.cells.resource.meter.value==56
    and mage.cells.resource.tooltipLines[1]:find('exact values unavailable',1,true),
    'Mage shows readable mana percentage while exact current and maximum are restricted')
CurveConstants={ScaleTo100={}}
UnitPowerPercent=function() return secret end
mage.Update()
check(rawget(mage.cells.resource.top,'formattedValue')~=secret
    and mage.cells.resource.shown and mage.cells.resource.meter.shown and mage.cells.resource.meter.value==secret
    and mage.cells.resource.tooltipLines[1]:find('drawn by the client',1,true),
    'a restricted native percentage is handed only to the native meter, never inspected or printed')
UnitPowerPercent=nil;CurveConstants=nil;mage.Update()
check(not mage.cells.resource.shown and not mage.cells.resource.meter.shown,
    'Mage hides resource status when neither Lua nor a native renderer can display a reading')
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
check(mage.cells.upkeep.bottom.text=='Frost Armor' and not mage.cells.upkeep.meter.shown,
    'Mage shield toggle leaves armor upkeep intact')
NS.Mage.db.showUpkeep=false;NS.Mage.db.showMageShield=true;mage.Update()
check(mage.cells.upkeep.shown and mage.cells.upkeep.top.formattedValue==secret,
    'shield indicator stays independent when armor upkeep is hidden')
NS.Mage.db.showUpkeep=true
NS.Mage.db.showMageShield=true;UnitGetTotalAbsorbs=function() return 0 end
local priest=Fixture(NS.Priest,{'Power Word: Fortitude','Divine Spirit','Inner Fire'},{'Prayer of Fortitude','Prayer of Spirit','Inner Fire'})
check(priest.cells.upkeep.top.text=='3/3','Priest group prayers satisfy individual buff upkeep')
-- Names and readable resource lines replace slot labels and abbreviations.
check(paladin.cells.target.bottom.text=='Judgement of Wisdom','the target slot names the effect instead of "Effect"')
local namedWarrior=Fixture(NS.Warrior,{'Battle Shout','Overpower','Battle Stance'},{'Battle Shout'})
check(namedWarrior.cells.ability.top.text=='Ready' and namedWarrior.cells.ability.bottom.text=='Overpower'
    and namedWarrior.cells.ability.tooltipTitle=='Overpower','the ability slot names the spell, and its tooltip is titled with it')
-- Cooldown timers are left to the game's Cooldown Manager.
local savedCooldown=C_Spell.GetSpellCooldown
C_Spell.GetSpellCooldown=function() return {startTime=GetTime()-2,duration=12,isEnabled=true} end
namedWarrior.Update()
check(not namedWarrior.cells.ability.shown and not namedWarrior.cells.racial.shown,
    'abilities and racials on cooldown show no timer and leave their slots empty')
C_Spell.GetSpellCooldown=savedCooldown;namedWarrior.Update()
check(namedWarrior.cells.ability.top.text=='Ready','the slot returns when the ability is ready')
GetShapeshiftForm=function() return 1 end
GetShapeshiftFormInfo=function() return 132349,true,nil,4003 end
namedWarrior.Update()
check(namedWarrior.cells.resource.cue.shown and namedWarrior.cells.resource.cue.texture==132349 and namedWarrior.cells.resource.bottom.text==''
    and namedWarrior.cells.resource.meter.color[1]==0.9
    and table.concat(namedWarrior.cells.resource.tooltipLines,'\n'):find('Battle Stance',1,true),
    'Warrior shows a red rage meter and the stance icon, with the stance name in the tooltip')
check(named.ForeverClassmateWarriorFrame.foldStat.text=='90%' and named.ForeverClassmateWarriorFrame.foldStat.label=='Health',
    'Warrior compact stat is health')
GetShapeshiftForm=function() return 0 end;namedWarrior.Update()
check(not namedWarrior.cells.resource.cue.shown,'no stance icon is invented when none is active or readable')
local comboRogue=Fixture(NS.Rogue,{},{})
GetComboPoints=function() return 3 end;comboRogue.Update()
local lit=0
for _,pip in ipairs(comboRogue.cells.resource.pips) do if pip.shown and pip.color[1]==1 then lit=lit+1 end end
check(lit==3 and #comboRogue.cells.resource.pips==5 and comboRogue.cells.resource.pips[5].shown,
    'combo points show as five pips with three lit')
GetComboPoints=function() return 0 end
local savedItemID,savedEnchant=GetInventoryItemID,C_Item.GetWeaponEnchantInfo
GetInventoryItemID=function(_,slot) return 100+slot end
C_Item.GetWeaponEnchantInfo=function(slot)
    if slot==Enum.WeaponSlot.MainHand then return {{hasEnchant=true,timeLeft=600000}} end
    return {{hasEnchant=false}}
end
comboRogue.Update()
local poisonLines=table.concat(comboRogue.cells.upkeep.tooltipLines,'\n')
check(comboRogue.cells.upkeep.top.text=='Missing' and comboRogue.cells.upkeep.bottom.text=='Off-hand poison'
    and poisonLines:find('Main hand: 10m',1,true) and poisonLines:find('Off hand: no poison',1,true),
    'Rogue poisons are tracked per weapon, naming the hand that needs a coating')
C_Item.GetWeaponEnchantInfo=function(slot) return {{hasEnchant=true,charges=40,timeLeft=slot==Enum.WeaponSlot.MainHand and 600000 or 120000}} end
comboRogue.Update()
check(comboRogue.cells.upkeep.top.text=='2m' and comboRogue.cells.upkeep.bottom.text=='Poison',
    'with both weapons coated, the bar shows the poison that expires first')
check(named.ForeverClassmateRogueFrame.foldStat.text=='2m' and named.ForeverClassmateRogueFrame.foldStat.label=='Poison time left',
    'Rogue compact stat is the shortest poison time left')
-- A sharpening stone has no charges: it is a coating, never called a poison.
C_Item.GetWeaponEnchantInfo=function(slot) return {{hasEnchant=true,charges=slot==Enum.WeaponSlot.MainHand and 40 or 0,timeLeft=600000}} end
comboRogue.Update()
check(comboRogue.cells.upkeep.bottom.text=='Weapon coating','an uncharged temporary enchant is a weapon coating, not a poison')
GetInventoryItemID,C_Item.GetWeaponEnchantInfo=savedItemID,savedEnchant
local savedCount,savedExists,savedHealth=C_Item.GetItemCount,UnitExists,UnitHealth
C_Item.GetItemCount=function(id) return id==6265 and 5 or 0 end
UnitExists=function(unit) return unit=='target' or unit=='pet' end
UnitHealth=function(unit) return unit=='pet' and 80 or 90 end
local petLock=Fixture(NS.Warlock,{'Demon Skin','Summon Imp','Will to Survive'},{'Demon Skin'})
check(petLock.cells.resource.cue.shown and petLock.cells.resource.count.text=='5' and petLock.cells.resource.bottom.text==''
    and table.concat(petLock.cells.resource.tooltipLines,'\n'):find('Health: 90%',1,true),
    'Warlock shards show as the shard icon with a count; player health stays in the tooltip')
check(petLock.cells.upkeep.top.text=='2/2' and petLock.cells.upkeep.bottom.text=='Demon 80%',
    'with armor and demon both up, the upkeep line shows the demon health')
check(petLock.cells.racial.bottom.text=='Will to Survive','the racial slot names the racial instead of "Racial"')
local lockStat=named.ForeverClassmateWarlockFrame.foldStat
check(lockStat and lockStat.text=='5' and lockStat.label=='Soul Shards' and lockStat.color==nil,'Warlock compact stat counts soul shards')
NS.Warlock.db.compactStat=false;petLock.Update()
check(rawget(named.ForeverClassmateWarlockFrame,'foldStat')==nil,'turning the stat off clears it')
NS.Warlock.db.compactStat=true
C_Item.GetItemCount=function() return 0 end;petLock.Update()
check(named.ForeverClassmateWarlockFrame.foldStat.text=='0' and named.ForeverClassmateWarlockFrame.foldStat.color[1]==1,
    'zero soul shards shows in red')
check(petLock.cells.resource.count.text=='0' and petLock.cells.resource.count.textColor[1]==1 and petLock.cells.resource.count.textColor[2]==0.25,
    'the bar shows an empty shard count in red too')
C_Item.GetItemCount,UnitExists,UnitHealth=savedCount,savedExists,savedHealth
local warlock=Fixture(NS.Warlock,{'Demon Armor','Demon Skin'},{'Demon Skin'})
check(warlock.cells.upkeep.top.text=='Active' and warlock.cells.upkeep.bottom.text=='Demon Skin' and warlock.alpha==0.6,
    'confirmed Warlock armor uses the normal out-of-combat target fade')
local observedArmorRead=C_UnitAuras.GetAuraDataByIndex
C_UnitAuras.GetAuraDataByIndex=function() error('restricted aura') end
warlock.Update()
check(warlock.cells.upkeep.top.text=='' and warlock.alpha==0.6,
    'an unavailable armor reading does not force a full-opacity missing-buff warning')
C_UnitAuras.GetAuraDataByIndex=observedArmorRead;warlock.Update()
local armorReads=0
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' then armorReads=armorReads+1 end
end
UnitAffectingCombat=function() return true end;warlock.Update()
check(armorReads==0 and warlock.cells.upkeep.top.text=='' and warlock.cells.upkeep.bottom.text==''
    and warlock.cells.upkeep.icon.shown and warlock.cells.upkeep.icon.texture==500
    and warlock.cells.upkeep.icon.vertexColor[1]==0.42
    and warlock.cells.upkeep.tooltipLines[1]:find('Demon Skin last seen',1,true),
    'Warlock keeps the confirmed Demon Skin icon but makes no combat aura read or 0/1 claim')
UnitAffectingCombat=function() return false end;warlock.Update()
check(warlock.cells.upkeep.top.text=='Missing' and warlock.cells.upkeep.bottom.text=='Demon Armor'
    and warlock.cells.upkeep.armorWarning.shown and warlock.alpha==1,
    'a readable out-of-combat absence shows an explicit armor warning at full visibility')
local upkeepCell=warlock.cells.upkeep
check(upkeepCell.armorWarning.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\IconFrame'
    and upkeepCell.armorWarning.halo and upkeepCell.armorWarning.halo.shown and upkeepCell.iconFrame.alpha==0,
    'the armor warning is an engraved amber frame with an ember halo, replacing the neutral icon frame')
check(warlock.cells.resource.line.engraved and warlock.cells.resource.line.engraved.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\Divider'
    and warlock.cells.resource.line.engraved.width==6,'slot separators are engraved dividers')
-- Shard icon frame ends at 60 and a two-digit 13px count needs about 18 more.
check(warlock.cells.resource.width==83 and warlock.cells.upkeep.x==90 and warlock.cells.upkeep.width==77
    and warlock.cells.target.x+warlock.cells.target.width==398,
    'the shard count has room inside its own slot and four equal cards fill the rest')
upkeepCell.armorWarning:Hide()
check(not upkeepCell.armorWarning.halo.shown and upkeepCell.iconFrame.alpha==1,'clearing the warning restores the neutral icon frame')
upkeepCell.icon:SetShown(false)
check(not upkeepCell.iconFrame.shown,'an icon frame never shows without its icon')
warlock.Update()
check(upkeepCell.armorWarning.shown and upkeepCell.armorWarning.halo.shown,'the next update restores the confirmed warning')
NS.Warlock.db.showUpkeep=false;warlock.Update()
check(warlock.alpha==0.6,'turning off upkeep removes the missing-buff fade override')
NS.Warlock.db.showUpkeep=true
UnitAffectingCombat=function() return true end;warlock.Update()
check(warlock.cells.upkeep.top.text=='' and not warlock.cells.upkeep.shown,
    'combat without a prior confirmed armor hides the unsupported upkeep slot')
UnitAffectingCombat=function() return false end
warlock=Fixture(NS.Warlock,{'Demon Skin','Summon Imp'},{'Demon Skin'})
check(warlock.cells.upkeep.top.text=='Missing' and warlock.cells.upkeep.bottom.text=='Demon' and warlock.alpha==0.6,
    'missing demon warns without treating it as a missing buff for the fade override')
warlock=Fixture(NS.Warlock,{'Demon Skin','Corruption','Will to Survive'},{'Demon Skin'})
local readableCooldown=C_Spell.GetSpellCooldown
C_UnitAuras.GetAuraDataByIndex=function(unit)
    if unit=='target' then error('restricted target auras') end
end
C_Spell.GetSpellCooldown=function() return nil end
UnitAffectingCombat=function() return true end;warlock.Update()
check(warlock.cells.resource.shown and warlock.cells.upkeep.shown and warlock.cells.upkeep.icon.shown
    and not warlock.cells.target.shown and not warlock.cells.ability.shown and not warlock.cells.racial.shown
    and warlock.cells.upkeep.top.text=='' and warlock.cells.upkeep.bottom.text=='',
    'restricted Warlock combat state shows only usable resource and remembered armor identity')
for _,cell in pairs(warlock.cells) do
    if cell.shown then
        check(not tostring(cell.top.text):find('?',1,true) and not tostring(cell.bottom.text):find('?',1,true),
            'visible Warlock cells contain no unknown-status question marks')
    end
end
C_Spell.GetSpellCooldown=readableCooldown;UnitAffectingCombat=function() return false end
local deadTarget=false
UnitIsDead=function(unit) return unit=='target' and deadTarget end
UnitIsFriend=function() return false end
deadTarget=true;warrior.Update()
check(not warrior.cells.target.shown,'dead targets hide effect tracking instead of showing a placeholder')
deadTarget=false
warrior.scripts.OnEvent(warrior,'PLAYER_DEAD');warrior.scripts.OnEvent(warrior,'UNIT_AURA','player');warrior.Refresh()
check(not warrior.shown and not warrior.scripts.OnUpdate,'standard class stays suspended after death and settings refresh')
warrior.scripts.OnEvent(warrior,'PLAYER_ALIVE')
check(warrior.shown and warrior.scripts.OnUpdate,'standard class resumes after resurrection')
local reads=0
UnitPower=function() reads=reads+1;return 70 end
CurveConstants={ScaleTo100={}}
UnitPowerPercent=function() reads=reads+1;return secret end
C_UnitAuras.GetAuraDataByIndex=function() reads=reads+1 end
C_Spell.GetSpellCooldown=function() reads=reads+1;return {startTime=0,duration=0,isEnabled=true} end
for _,key in ipairs({'showResource','showUpkeep','showTarget','showAbilities','showRacial','showMultiDots'}) do NS.Warrior.db[key]=false end
warrior.Refresh()
check(reads==0 and not warrior.scripts.OnUpdate,'disabled standard blocks perform no resource, aura, cooldown reads or polling')
check(not warrior.dotTracker.shown and not next(warrior.dotTracker.events),'disabled DoT strip removes its own listeners')
local updatedPaladin=Fixture(NS.Paladin,{'Twist of Light','Unsealed Wrath'},{'Unsealed Wrath'})
check(not NS.Paladin.spells.twistLight and updatedPaladin.cells.ability.top.text=='Proc',
    'Paladin surfaces the readable replacement aura and drops the retired talent')
local updatedRogue=Fixture(NS.Rogue,{'Slice and Dice','Venom','Shank','Death Mark','Thousand Cuts','Cutthroat'},{'Slice and Dice'})
check(updatedRogue.cells.upkeep.bottom.text=='Slice and Dice' and NS.Rogue.spells.deathMark
    and not NS.Rogue.spells.thousandCuts and not NS.Rogue.spells.cutthroat,
    'absent Venom is not missing upkeep and retired Rogue talents are ignored')
local updatedDruid=Fixture(NS.Druid,{"Tiger's Fury",'Berserk','Primal Bite','Lacerate','Shifting Power'},{})
check(not NS.Druid.spells.berserk and not NS.Druid.spells.tigersFury and NS.Druid.spells.lacerate
    and updatedDruid.cells.ability.top.text=='Ready','Druid replaces stale cues with learned Feral abilities')
local missingDruid=Fixture(NS.Druid,{'Mark of the Wild'},{})
local druidPulse=missingDruid.cells.upkeep.armorWarning.warningPulseGroup
check(druidPulse.playing and missingDruid.alpha==1,'a confirmed missing Druid maintained buff uses the shared pulse')
Fixture(NS.Druid,{'Mark of the Wild'},{'Mark of the Wild'})
check(not druidPulse.playing,'restoring the Druid buff clears the shared pulse')
local temporary=Fixture(NS.Rogue,{'Slice and Dice'},{})
local temporaryPulse=rawget(temporary.cells.upkeep.armorWarning,'warningPulseGroup')
check(not temporaryPulse or not temporaryPulse.playing,'a missing temporary Rogue finisher does not trigger maintained-buff flashing')
-- Class coverage (0.42.0).
for _,module in ipairs({NS.Paladin,NS.Druid,NS.Mage,NS.Warlock,NS.Rogue,NS.Priest}) do
    for _,key in ipairs({'showUpkeep','showAbilities','showRacial','showTarget','showResource'}) do module.db[key]=true end
end
UnitAffectingCombat=function() return false end
UnitExists=function(unit) return unit=='target' end
-- Paladin: a missing aura is a maintained-buff warning; a missing blessing is not.
local auraPaladin=Fixture(NS.Paladin,{'Seal of Wisdom','Devotion Aura','Blessing of Might'},{'Seal of Wisdom','Blessing of Might'})
check(auraPaladin.cells.upkeep.bottom.text=='Devotion Aura' and named.ForeverClassmatePaladinFrame.foldWarnings.upkeep.active,
    'a learned Paladin aura that is missing warns')
auraPaladin=Fixture(NS.Paladin,{'Seal of Wisdom','Devotion Aura','Blessing of Might'},{'Seal of Wisdom','Devotion Aura'})
check(auraPaladin.cells.upkeep.bottom.text=='Blessing of Might' and not named.ForeverClassmatePaladinFrame.foldWarnings.upkeep.active,
    'a missing blessing is named without waking the bar')
-- Druid: combo pips replace the form icon in an energy form.
UnitPowerType=function() return 3,'ENERGY' end;GetComboPoints=function() return 2 end
local catDruid=Fixture(NS.Druid,{'Rake'},{})
check(catDruid.cells.resource.pips[1].shown and not catDruid.cells.resource.cue.shown,'Cat Form shows combo pips')
UnitPowerType=function() return 0,'MANA' end;GetComboPoints=function() return 0 end
catDruid.Update()
check(not catDruid.cells.resource.pips[1].shown,'caster form hides combo pips')
-- Druid: Clearcasting only follows a learned Omen of Clarity.
local omenDruid=Fixture(NS.Druid,{'Omen of Clarity'},{'Omen of Clarity','Clearcasting'})
check(omenDruid.cells.ability.bottom.text=='Clearcasting' and omenDruid.cells.upkeep.bottom.text=='Omen of Clarity',
    'Omen of Clarity is upkeep and Clearcasting is its proc')
-- Mage: Arcane Blast stacks are a harmful aura on the player.
local blastMage=Fixture(NS.Mage,{'Mage Armor','Arcane Blast'},{'Mage Armor'})
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' and index==1 then return {name='Mage Armor',icon=500,sourceUnit='player'} end
    if unit=='player' and filter=='HARMFUL' and index==1 then return {name='Arcane Blast',icon=77,applications=3,expirationTime=110} end
end
blastMage.Update()
check(blastMage.cells.ability.bottom.text=='Arcane Blast' and blastMage.cells.ability.top.text=='×3','Arcane Blast stacks are read from the harmful self-aura')
-- Warlock: a Demonic Sacrifice buff stands in for the demon.
UnitExists=function(unit) return unit=='target' end
local sacrificeLock=Fixture(NS.Warlock,{'Demon Skin','Summon Imp','Demonic Sacrifice'},{'Demon Skin','Burning Shadow'})
check(sacrificeLock.cells.upkeep.top.text=='2/2' and not table.concat(sacrificeLock.cells.upkeep.tooltipLines,'\n'):find('Demon: missing',1,true),
    'a sacrifice buff counts as the demon')
sacrificeLock=Fixture(NS.Warlock,{'Demon Skin','Summon Imp'},{'Demon Skin','Burning Shadow'})
check(sacrificeLock.cells.upkeep.bottom.text=='Demon','without the talent learned, a missing demon is still missing')
-- Rogue: crafted poisons are read on the target by name, from you only.
local poisonRogue=Fixture(NS.Rogue,{},{})
UnitCanAttack=function() return true end
C_UnitAuras.GetAuraDataByIndex=function(unit,index,filter)
    if unit=='target' and filter=='HARMFUL' and index==1 then return {name='Deadly Poison',icon=88,applications=4,expirationTime=112,sourceUnit='player'} end
end
poisonRogue.Update()
check(poisonRogue.cells.target.bottom.text=='Deadly Poison' and poisonRogue.cells.target.top.text=='×4','a poison debuff from you shows on the target slot')
C_UnitAuras.GetAuraDataByIndex=function() return nil end;poisonRogue.Update()
check(not poisonRogue.cells.target.shown,'no learned target spell means no "None" placeholder for an unlearned poison')

-- Reproduce a localized-only spell lookup: English names return nil when
-- only Chinese spells are learned. No Classic spell IDs are assumed.
local nativeSpellInfo=C_Spell.GetSpellInfo
C_Spell.GetSpellInfo=function(value)
    if type(value)=='number' then return nativeSpellInfo(value) end
    for _,item in pairs(book) do
        if item.name==value then return {name=item.name,iconID=item.iconID} end
    end
end
UnitAffectingCombat=function() return false end
UnitExists=function(unit) return unit=='target' end
for _,armorName in ipairs({'Demon Skin','Demon Armor','Fel Armor','恶魔皮肤','魔甲术','邪甲术'}) do
    local checked=Fixture(NS.Warlock,{armorName},{})
    local cell=checked.cells.upkeep
    check(cell.shown and cell.top.text=='Missing' and cell.bottom.text==armorName
        and cell.armorWarning.shown and checked.alpha==1,
        'learned armor warns out of combat with localized-only lookup: '..armorName)
    local pulse=cell.armorWarning.warningPulseGroup
    check(pulse.playing,'confirmed missing Warlock armor pulses')
    NS.Warlock.db.flashMissingBuffs=false;checked.Update()
    check(not pulse.playing and cell.armorWarning.shown and checked.alpha==1,
        'turning off flashing keeps the static warning and full readability')
    NS.Warlock.db.flashMissingBuffs=true;checked.Update()
    UnitAffectingCombat=function() return true end;checked.Update()
    check(not cell.armorWarning.shown and not pulse.playing and cell.top.text~='Missing',
        'unknown combat armor state never carries a stale missing warning')
    UnitAffectingCombat=function() return false end
    checked=Fixture(NS.Warlock,{armorName},{armorName})
    check(not cell.armorWarning.shown and not pulse.playing and cell.top.text=='Active' and cell.bottom.text==armorName,
        'applying any recognized armor clears its warning')
    C_UnitAuras.GetAuraDataByIndex=function() return {name=secret} end
    checked.Update()
    check(not cell.armorWarning.shown and not pulse.playing and cell.top.text~='Missing' and checked.alpha==0.6,
        'restricted aura names do not create a false missing-armor warning')
end
-- A zhCN spellbook with English lookups returning nil: the generated client
-- aliases still find upkeep, target, cue and racial spells.
for _,key in ipairs({'showUpkeep','showAbilities','showRacial','showTarget'}) do NS.Warrior.db[key]=true;NS.Warlock.db[key]=true end
local zhWarrior=Fixture(NS.Warrior,{'战斗怒吼','撕裂','压制','生存意志'},{})
check(NS.Warrior.spells.battleShout and NS.Warrior.spells.rend and NS.Warrior.spells.overpower and NS.Warrior.spells.willToSurvive,
    'Chinese spellbook names are discovered through the generated aliases')
check(zhWarrior.cells.upkeep.top.text=='Missing' and zhWarrior.cells.upkeep.bottom.text=='战斗怒吼'
    and zhWarrior.cells.ability.bottom.text=='压制' and zhWarrior.cells.racial.bottom.text=='生存意志',
    'a localized Warrior bar names its own learned spells')
zhWarrior=Fixture(NS.Warrior,{'战斗怒吼'},{'战斗怒吼'})
check(zhWarrior.cells.upkeep.top.text=='Active' and zhWarrior.cells.upkeep.bottom.text=='战斗怒吼','a Chinese aura name satisfies its upkeep')
check(next(Fixture(NS.Warrior,{'Not A Real Spell'},{}) and NS.Warrior.spells or {})==nil,'an unrecognized spell name finds nothing')
-- Aura-only effects follow their learned source: Shadow Trance needs Nightfall.
local zhLock=Fixture(NS.Warlock,{'夜幕'},{'暗影冥思'})
check(NS.Warlock.spells.shadowTrance and zhLock.cells.ability.bottom.text=='暗影冥思','the Nightfall proc is read as Shadow Trance')
zhLock=Fixture(NS.Warlock,{'Corruption'},{'暗影冥思'})
check(NS.Warlock.spells.shadowTrance==nil,'without Nightfall learned, Shadow Trance is not tracked')
local checked=Fixture(NS.Warlock,{'恶魔皮肤','Summon Imp'},{})
UnitExists=function(unit) if unit=='pet' then return secret end;return unit=='target' end
checked.Update()
check(checked.cells.upkeep.top.text=='Missing' and checked.cells.upkeep.bottom.text=='恶魔皮肤'
    and checked.cells.upkeep.armorWarning.shown and checked.alpha==1,
    'confirmed missing armor remains explicit when demon existence is unavailable')
NS.Warlock.db.showUpkeep=false;checked.Update()
check(not checked.cells.upkeep.shown and not checked.cells.upkeep.armorWarning.shown and checked.alpha==0.6,
    'disabling upkeep disables the localized armor reminder and its fade override')
check(not checked.cells.upkeep.armorWarning.warningPulseGroup.playing,'disabled upkeep stops its native animation')
NS.Warlock.db.showUpkeep=true;checked.Update()
local pulse=checked.cells.upkeep.armorWarning.warningPulseGroup
check(pulse.playing,'reenabling upkeep restores the confirmed missing-buff pulse')
checked.scripts.OnEvent(checked,'PLAYER_DEAD')
check(not pulse.playing,'death stops the pulse even while missing armor')
checked.scripts.OnEvent(checked,'PLAYER_ALIVE')
check(pulse.playing,'resurrection refreshes the warning from current readable state')
NS.Warlock.db.enabled=false;checked.Refresh()
check(not pulse.playing,'disabling the whole addon stops warning animations')
print('PASS: '..count..' standard class runtime checks')
