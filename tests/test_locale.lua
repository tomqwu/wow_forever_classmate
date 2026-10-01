local root='addons/ForeverUtilities/'
local NS={}
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
local count=0
local function check(actual,expected,label)
    assert(actual==expected,label..': '..tostring(actual)..' ~= '..expected)
    count=count+1
end

GetLocale=function() return 'zhCN' end
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',NS)
check(NS.Locale,'zhCN','selected locale')
check(NS.L('No target'),'无目标','Hunter no-target label')
check(NS.L('Ammo: 525'),'弹药：525','Hunter live ammo count')
check(NS.L('Shooting | ~8-35 yd'),'射击范围内 | ~8-35 码','Hunter range bracket')
check(NS.L('Out of range | >35 yd'),'超出射程 | >35 码','Hunter out-of-range bracket')
check(NS.L('Friendly target'),'友方目标','Hunter friendly target')
check(NS.L('Low ammo — 200 remaining!'),'弹药不足——剩余 200 发！','low-ammo warning')
check(NS.L('Forever Classmate — Mage'),'永恒战友 — 法师','class panel title')
check(NS.L('Show mana percentage'),'显示法力百分比','settings option')
check(NS.L('Mana 53%'),'法力 53%','Shaman mana')
check(NS.L('Maelstrom 5/5'),'漩涡 5/5','Shaman helper')
check(NS.L('Lava Burst 12s'),'熔岩爆裂 12秒','Shaman timed helper')
check(NS.L('Earth element: no active totem'),'地系元素：没有生效的图腾','Shaman totem tooltip')
check(NS.L('Armor: Frost Armor active'),'护甲：Frost Armor 生效中','upkeep tooltip with native spell name')
check(NS.L('No tracked effect from you is active.'),'目标身上没有你施加的已追踪效果。','standard tooltip')
check(NS.L('Cat'),'猫科','pet family')
check(NS.L('Family guide: Single-target damage / stealth'),'家族指南：单目标伤害／潜行','pet guide details')
check(NS.L('Fireball'),'Fireball','spell names are not translated from guesses')
assert(loadfile(root..'PetDatabase.lua'))('ForeverUtilities',NS)
check(NS.PetDatabase.familyNames['猫科'],2,'localized pet family without readable ID')

GetLocale=function() return 'enUS' end
NS.L=function(value) return value end
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',NS)
check(NS.L('No target'),'No target','English fallback')
check(NS.L('Ammo: 525'),'Ammo: 525','English dynamic fallback')
GetLocale=function() return 'zhTW' end
assert(loadfile(root..'Locale.lua'))('ForeverUtilities',NS)
check(NS.L('No target'),'No target','non-zhCN locale uses English fallback')
print('PASS: '..count..' locale checks')
