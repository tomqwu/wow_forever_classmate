local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/ClassContext.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/ShamanContext.lua'))('ForeverUtilities',NS)
local C=NS.ShamanContext
local count=0
local function check(value,message) assert(value,message);count=count+1 end
check(C.FormatTime(0)=='0s' and C.FormatTime(9.1)=='10s','short duration rounds up')
check(C.FormatTime(60)=='1m' and C.FormatTime(61)=='2m','minute duration rounds up')
check(C.FormatTime(secret)==nil and C.FormatTime(-1)==nil,'invalid durations hidden')
local now=100
GetTime=function() return now end
GetTotemInfo=function(slot)
    if slot==2 then return true,'Strength of Earth',90,30,111 end
    return false,'',0,0,0
end
GetTotemTimeLeft=function(slot) return slot==2 and 20 or 0 end
local totem=C.Totem(2)
check(totem.active and totem.name=='Strength of Earth' and totem.icon==111 and totem.left==20,'active totem fields')
check(C.Totem(1).active==false,'empty totem slot')
GetTotemInfo=function(slot)
    if slot==2 then return false,'Earthbind Totem',90,30,111 end
    return true,'',0,0,0
end
check(C.Totem(2).active and C.Totem(2).name=='Earthbind Totem','active totem name wins when reagent flag is false')
check(C.Totem(1)==nil,'reagent flag alone does not establish an active or empty slot')
GetTotemInfo=function() return true,'',0,0,0 end
GetTotemTimeLeft=function() return 0 end
check(C.Totem(2)==nil,'owned reagent with empty slot data is unavailable, not confirmed empty')
GetTotemTimeLeft=function(slot) return slot==2 and 20 or 0 end
GetTotemInfo=function(slot)
    if slot==2 then return false,'',90,30,111 end
    return false,'',0,0,0
end
check(C.Totem(2).active and C.Totem(2).left==20,'positive time remaining identifies a totem without a readable name')
GetTotemInfo=function(slot)
    if slot==2 then return true,'Strength of Earth',90,30,111 end
    return false,'',0,0,0
end
GetTotemTimeLeft=nil;totem=C.Totem(2);check(totem.left==20,'totem time fallback')
GetTotemInfo=function() return secret end;check(C.Totem(1)==nil,'secret totem state hidden')
GetTotemInfo=function() return false,secret,0,0,0 end;check(C.Totem(1)==nil,'secret totem name does not imply an empty slot')
GetTotemInfo=function() error('restricted') end;check(C.Totem(1)==nil,'failed totem API hidden')
GetTotemInfo=function() return true,'Stoneclaw Totem',0,0,0,1,0 end
GetTotemTimeLeft=function() return 0 end;totem=C.Totem(2)
check(totem.active and totem.icon==nil and totem.spellID==nil and totem.left==nil and totem.duration==nil,
    'named active totem with zero metadata leaves icon and lifetime unavailable')
GetTotemInfo=function() return true,'Stoneclaw Totem',97,15,0,1,5730 end;totem=C.Totem(2)
check(totem.left==12 and totem.duration==15,'zero remaining placeholder falls back to readable lifetime metadata')
local itemID=700
GetInventoryItemID=function() return itemID end
GetInventoryItemTexture=function() return 222 end
Enum={WeaponSlot={MainHand=0}}
C_Item={GetWeaponEnchantInfo=function(slot)
    check(slot==0,'main hand enum')
    return {{hasEnchant=true,timeLeft=90500,charges=3,enchantIconID=333}}
end}
local imbue=C.WeaponImbue()
check(imbue.equipped and imbue.active and imbue.left==90.5 and imbue.icon==333 and imbue.charges==3,'weapon imbue data')
C_Item.GetWeaponEnchantInfo=function() return {{hasEnchant=true,timeLeft=90000,enchantIconID=0}} end
check(C.WeaponImbue().icon==222,'zero enchant icon uses weapon art instead of a blank texture')
C_Item.GetWeaponEnchantInfo=function() return {} end
imbue=C.WeaponImbue();check(imbue.equipped and not imbue.active,'readable missing imbue')
itemID=nil;check(C.WeaponImbue().equipped==false,'empty weapon slot')
itemID=secret;check(C.WeaponImbue()==nil,'secret weapon identity hidden')
itemID=700;C_Item.GetWeaponEnchantInfo=function() return secret end
check(C.WeaponImbue()==nil,'secret enchant response hidden')
local auras={}
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter) return auras[index] end}
local names={['Lightning Shield']=true}
check(C.Aura('player','HELPFUL',names,false)==false,'complete empty aura scan')
auras={{name='Lightning Shield',icon=444,applications=3,expirationTime=130,sourceUnit='player'}}
local aura=C.Aura('player','HELPFUL',names,false)
check(aura.name=='Lightning Shield' and aura.applications==3 and aura.left==30,'aura fields and time')
check(C.Aura('player','HELPFUL',names,true).name=='Lightning Shield','own aura source accepted')
auras[1].sourceUnit='party1';UnitIsUnit=function() return false end
check(C.Aura('player','HELPFUL',names,true)==false,'other caster aura rejected')
auras={{name=secret}};check(C.Aura('player','HELPFUL',names,false)==nil,'secret aura prevents missing claim')
auras={};UnitAffectingCombat=function() return true end;UnitIsDead=function() return false end
local missing=C.MissingShield(names);check(missing==true,'missing shield warns in combat')
UnitAffectingCombat=function() return false end;missing=C.MissingShield(names);check(missing==false,'missing shield quiet outside combat')
auras={{name='Lightning Shield',applications=2,expirationTime=0}};UnitAffectingCombat=function() return true end
local shieldMissing,shieldAura=C.MissingShield(names)
check(shieldMissing==false and shieldAura.applications==2,'active shield clears warning')
UnitCanAttack=function() return true end;UnitIsDead=function() return false end
auras={{name='Flame Shock',expirationTime=112,sourceUnit='player'}}
local flame=C.FlameShock('Flame Shock');check(flame.name=='Flame Shock' and flame.left==12,'target Flame Shock timer')
auras={{name='Flame Shock',sourceUnit='party1'}};check(C.FlameShock('Flame Shock')==false,'another shaman’s Flame Shock does not satisfy personal setup')
auras={};check(C.FlameShock('Flame Shock')==false,'readable missing Flame Shock')
UnitCanAttack=function() return false end;check(C.FlameShock('Flame Shock')==false,'friendly target quiet')
UnitPower=function() return 51 end;UnitPowerMax=function() return 100 end
check(C.ManaPercent()==51,'mana percentage')
UnitPower=function() return secret end;check(C.ManaPercent()==nil,'secret mana hidden')
UnitPower=function() return 10 end;UnitPowerMax=function() return 0 end
check(C.ManaPercent()==nil,'zero maximum hidden')
print('PASS: '..count..' shaman context checks')
