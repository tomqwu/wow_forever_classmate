local NS={}
local secret={}
C_AddOns={GetAddOnMetadata=function() return 'test-version' end}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/ClassContext.lua'))('ForeverUtilities',NS)
local C=NS.ClassContext
local count=0
local function check(value,message) assert(value,message);count=count+1 end

check(NS.Version=='test-version','status version comes from installed TOC metadata')
check(NS.Core.Icon(0)==nil and NS.Core.Icon(-1)==nil and NS.Core.Icon(secret)==nil and NS.Core.Icon('')==nil,'invalid and secret icon values stay unavailable')
check(NS.Core.Icon(123)==123 and NS.Core.Icon('Interface\\Icons\\Spell_Nature_LightningShield')~=nil,'positive file IDs and texture paths remain usable')
local function hole() return nil,'second',nil,'fourth' end
local a,b,c,d=NS.Core.Call(hole)
check(a==nil and b=='second' and c==nil and d=='fourth','safe call preserves nil holes and trailing returns')
check(NS.Core.Call(function() return 'public',nil,secret end)==nil,'safe call rejects secret returns after a nil hole')

local savedSchema={schemaVersion=4};NS.Core.EnsureSchema(savedSchema,3)
check(savedSchema.schemaVersion==4,'initializing older class settings cannot downgrade shared schema')
local book={
    [1]={spellID=1001,name='Battle Shout',iconID=11,isPassive=false},
    [2]={spellID=1002,name='Bloodthrill',iconID=12,isPassive=true},
    [3]={spellID=1003,name='Will to Survive',iconID=13,isPassive=false},
}
Enum={SpellBookSpellBank={Player=0},WeaponSlot={MainHand=0,OffHand=1},PowerType={ComboPoints=4}}
C_Spell={
    GetSpellInfo=function(value)
        if type(value)=='number' then for _,spell in pairs(book) do if spell.spellID==value then return {name=spell.name,iconID=spell.iconID} end end end
        return {name=value,iconID=99}
    end,
    GetSpellCooldown=function(id) return {startTime=id==1003 and 90 or 0,duration=id==1003 and 30 or 0,isEnabled=true} end,
    IsSpellUsable=function(id) return id~=1003,false end,
}
C_SpellBook={
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=3} end,
    GetSpellBookItemInfo=function(slot) local item=book[slot];return {spellID=item.spellID,isPassive=item.isPassive,isOffSpec=false} end,
    IsSpellKnown=function() return true end,
}
local catalog={
    {key='shout',names={'Battle Shout'},kind='upkeep'},
    {key='proc',names={'Bloodthrill'},kind='proc',allowPassive=true},
    {key='ignoredPassive',names={'Bloodthrill'},kind='cue'},
    {key='willToSurvive',names={'Will to Survive'},kind='racial',priority=1},
}
local spells=C.Discover(catalog)
check(spells.shout and spells.shout.id==1001,'active spell discovered')
check(spells.proc and spells.proc.passive,'allowed passive proc discovered')
check(spells.ignoredPassive==nil,'passive action ignored')
check(spells.willToSurvive and spells.willToSurvive.icon==13,'racial discovered')

local now=100
GetTime=function() return now end
local cooldown=C.Cooldown(spells.willToSurvive)
check(cooldown.left==20,'real cooldown remaining')
local racial=C.Racial(spells,'WARRIOR')
check(racial and racial.spell.name=='Will to Survive' and not racial.ready and racial.left==20,'racial state uses cooldown')
C_Spell.GetSpellCooldown=function() return {startTime=secret,duration=30,isEnabled=true} end
check(C.Cooldown(spells.willToSurvive)==nil,'secret cooldown hidden')
C_Spell.GetSpellCooldown=function() return {startTime=0,duration=0,isEnabled=true} end
C_Spell.IsSpellUsable=function() return false,false end
racial=C.Racial(spells,'WARRIOR');check(not racial.ready and racial.left==0,'context restriction retained')
check(racial.status=='context','off-cooldown unusable spell is identified as context restricted')
C_Spell.GetSpellCooldown=nil;C_Spell.IsSpellUsable=nil
racial=C.Racial(spells,'WARRIOR');check(not racial.ready and racial.left==nil and racial.status=='unknown','missing readiness APIs stay unknown')
C_Spell.GetSpellCooldown=function() return {startTime=0,duration=0,isEnabled=true} end
C_Spell.IsSpellUsable=function() return true,false end

local auras={{name='Battle Shout',icon=44,applications=1,expirationTime=130,sourceUnit='player'}}
C_UnitAuras={GetAuraDataByIndex=function(_,index) return auras[index] end}
UnitIsUnit=function(a,b) return a==b end
local aura=C.Aura('player','HELPFUL',{['Battle Shout']=true},true)
check(aura.name=='Battle Shout' and aura.left==30,'own aura and timer')
auras[1].icon=0;check(C.Aura('player','HELPFUL',{['Battle Shout']=true},true).icon==nil,'zero aura icon cannot override a learned spell fallback')
auras={{name='Battle Shout',icon=44,expirationTime=130,isFromPlayerOrPlayerPet=true}}
check(C.Aura('target','HARMFUL',{['Battle Shout']=true},true).name=='Battle Shout','player-origin flag accepted')
auras={{name=secret}};check(C.Aura('player','HELPFUL',{['Battle Shout']=true},false)==nil,'secret aura does not become missing')

UnitPower=function(_,power) return power==4 and 5 or 60 end
UnitPowerMax=function() return 100 end
UnitPowerType=function() return 3,'ENERGY' end
check(C.Power(1,'Rage').percent==60,'fixed power percentage')
check(C.CurrentPower().label=='Energy' and C.CurrentPower().current==60,'current form power')
local originalPower,originalMax=UnitPower,UnitPowerMax
UnitPower=function() return secret end;UnitPowerMax=function() return secret end
UnitPowerPercent=function(unit,powerType)
    check(unit=='player' and powerType==0,'percentage fallback reads the same player power type')
    return 0.56
end
local percentOnly=C.Power(0,'Mana')
check(percentOnly and percentOnly.percent==56 and percentOnly.current==nil and percentOnly.maximum==nil,
    'fractional percentage remains usable when exact player mana is restricted')
CurveConstants={ScaleTo100={}}
UnitPowerPercent=function(_,_,_,curve) check(curve==CurveConstants.ScaleTo100,'client scale curve requested');return 56 end
check(C.Power(0,'Mana').percent==56,'scaled native percentage is not multiplied twice')
UnitPowerPercent=function() return secret end
check(C.Power(0,'Mana')==nil,'secret percentage is not converted to a fabricated number')
UnitPower,UnitPowerMax,UnitPowerPercent,CurveConstants=originalPower,originalMax,nil,nil
GetComboPoints=function() return 4 end
check(C.ComboPoints()==4,'combo points')

GetInventoryItemID=function(_,slot) return slot==16 and 501 or (slot==17 and 502 or nil) end
C_Item={GetWeaponEnchantInfo=function(slot)
    if slot==0 then return {{hasEnchant=true,timeLeft=1000}} end
    return {{hasEnchant=false}}
end,GetItemCount=function(name) return name=='Soul Shard' and 7 or 0 end}
local coating=C.WeaponCoatings()
check(coating.equipped==2 and coating.active==1 and coating.main and not coating.off,'dual weapon coating state')
check(C.ItemCount('Soul Shard')==7,'item count')

spells.desperatePrayer={id=2001,name='Desperate Prayer',icon=20,kind='priestRacial',priority=1}
C_Spell.GetSpellCooldown=function() return {startTime=0,duration=0,isEnabled=true} end
C_Spell.IsSpellUsable=function() return true,false end
check(C.Racial(spells,'PRIEST').spell.name=='Desperate Prayer','Priest racial takes priority on Priest')
spells.chastise={id=2002,name='Chastise',icon=21,kind='priestRacial',priority=2}
C_Spell.GetSpellCooldown=function(id)
    if id==2001 then return {startTime=90,duration=30,isEnabled=true} end
    return {startTime=0,duration=0,isEnabled=true}
end
check(C.Racial(spells,'PRIEST').spell.name=='Chastise','ready secondary Priest racial supersedes one on cooldown')

spells.bloodFury={id=3001,name='Blood Fury',icon=30,kind='racial',priority=1}
spells.shatterCurse={id=3002,name='Shatter Curse',icon=31,kind='racial',priority=2}
C_Spell.GetSpellCooldown=function(id)
    if id==3002 then return {startTime=0,duration=0,isEnabled=true} end
    return {startTime=90,duration=30,isEnabled=true}
end
C_Spell.IsSpellUsable=function() return true,false end
check(C.Racial(spells,'WARRIOR').spell.name=='Shatter Curse','ready racial supersedes higher-priority racial on cooldown')

UnitHealth=function() return 75 end;UnitHealthMax=function() return 100 end
check(C.HealthPercent('player')==75,'health percentage')
GetShapeshiftForm=function() return 2 end
GetShapeshiftFormInfo=function() return 777,true,true,4001 end
C_Spell.GetSpellInfo=function(id) if id==4001 then return {name='Bear Form',iconID=777} end end
local form=C.Form();check(form.name=='Bear Form' and form.icon==777 and form.spellID==4001,'active form uses current API signature')

C_Spell.GetSpellCooldown=function() return {startTime=99.5,duration=1.2,isEnabled=true} end
check(C.SpellState({id=10}).status=='cooldown','short real cooldowns are not reported ready')
C_Spell.GetSpellCooldown=function() return {startTime=0,duration=0} end
check(C.SpellState({id=10}).status=='unknown','incomplete cooldown result does not invent readiness')
auras={{name='Battle Shout',applications=secret,sourceUnit='player',isFromPlayerOrPlayerPet=secret}}
local partial=C.Aura('player','HELPFUL',{['Battle Shout']=true},true)
check(partial and partial.applications==nil,'readable owner is enough while hidden stacks stay unknown')
auras={{icon=55}}
check(C.Aura('player','HELPFUL',{['Battle Shout']=true},false)==nil,'malformed aura prevents a false missing warning')
GetInventoryItemID=function() error('unavailable') end
check(C.WeaponCoatings()==nil,'unavailable weapon inventory is not treated as unequipped')
C_SpellBook.GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=1} end
C_SpellBook.GetSpellBookItemInfo=function() return {spellID=102,baseSpellID=101,isPassive=false,isOffSpec=false} end
C_SpellBook.IsSpellKnown=function(id) return id==101 end
C_Spell.GetSpellInfo=function(id) return {name=id==102 and 'Empowered Battle Shout' or 'Battle Shout',iconID=1} end
local override=C.Discover(catalog)
check(override.shout and override.shout.id==102,'known base identifies an overridden spell with a different name')
C_SpellBook.GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=2} end
C_SpellBook.GetSpellBookItemInfo=function(slot) return {spellID=slot,isPassive=false,isOffSpec=false} end
C_SpellBook.IsSpellKnown=function() return true end
C_Spell.GetSpellInfo=function() return {name='Power Word: Fortitude',iconID=1} end
C_Spell.GetSpellLevelLearned=function(id) return id*10 end
local ranks=C.Discover({{key='fortitude',names={'Power Word: Fortitude','Prayer of Fortitude'}}})
check(ranks.fortitude.id==2,'highest readable learned rank supplies spell readiness')
check(C.Names(ranks,{'fortitude'})['Prayer of Fortitude'],'equivalent group buff is accepted even before the group spell is learned')
print('PASS: '..count..' shared class context checks')
