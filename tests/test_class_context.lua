local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/ClassContext.lua'))('ForeverUtilities',NS)
local C=NS.ClassContext
local count=0
local function check(value,message) assert(value,message);count=count+1 end

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
C_Spell.GetSpellCooldown=nil;C_Spell.IsSpellUsable=nil
racial=C.Racial(spells,'WARRIOR');check(not racial.ready and racial.left==nil,'missing readiness APIs do not invent ready state')
C_Spell.GetSpellCooldown=function() return {startTime=0,duration=0,isEnabled=true} end
C_Spell.IsSpellUsable=function() return true,false end

local auras={{name='Battle Shout',icon=44,applications=1,expirationTime=130,sourceUnit='player'}}
C_UnitAuras={GetAuraDataByIndex=function(_,index) return auras[index] end}
UnitIsUnit=function(a,b) return a==b end
local aura=C.Aura('player','HELPFUL',{['Battle Shout']=true},true)
check(aura.name=='Battle Shout' and aura.left==30,'own aura and timer')
auras={{name='Battle Shout',icon=44,expirationTime=130,isFromPlayerOrPlayerPet=true}}
check(C.Aura('target','HARMFUL',{['Battle Shout']=true},true).name=='Battle Shout','player-origin flag accepted')
auras={{name=secret}};check(C.Aura('player','HELPFUL',{['Battle Shout']=true},false)==nil,'secret aura does not become missing')

UnitPower=function(_,power) return power==4 and 5 or 60 end
UnitPowerMax=function() return 100 end
UnitPowerType=function() return 3,'ENERGY' end
check(C.Power(1,'Rage').percent==60,'fixed power percentage')
check(C.CurrentPower().label=='Energy' and C.CurrentPower().current==60,'current form power')
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

UnitHealth=function() return 75 end;UnitHealthMax=function() return 100 end
check(C.HealthPercent('player')==75,'health percentage')
GetShapeshiftForm=function() return 2 end
GetShapeshiftFormInfo=function() return 777,'Bear Form',true,true end
local form=C.Form();check(form.name=='Bear Form' and form.icon==777,'active form')
print('PASS: '..count..' shared class context checks')
