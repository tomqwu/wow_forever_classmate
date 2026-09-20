local NS={}
local secret={}
issecretvalue=function(v) return rawequal(v,secret) end
for _,file in ipairs({'Core','PetDatabase','PetGuide'}) do
 assert(loadfile('addons/ForeverUtilities/'..file..'.lua'))('ForeverUtilities',NS)
end
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local function Reset()
 UnitExists=function() return true end
 UnitIsDead=function() return false end
 UnitIsPlayer=function() return false end
 UnitPlayerControlled=function() return false end
 UnitCreatureFamily=function() return 'Wolf',1 end
 UnitCreatureID=function() return 1132 end
 UnitGUID=function() return 'Creature-0-1234-0-5678-1132-0000ABC123' end
 UnitClassification=function() return 'rare' end
 UnitName=function() return 'Timber' end
 UnitLevel=function(unit) return unit=='player' and 9 or 10 end
end
Reset()
local info=NS.PetGuide.ReadTarget()
check(info.notable.name=='Timber' and info.family.name=='Wolf','numeric NPC and family match')
check(info.tooHigh and info.classification=='Rare' and info.special,'live level and rarity')
local heading=NS.PetGuide.Summary(info)
check(heading=='Rare Wolf: Furious Howl','inline summary includes family ability and rarity')
local lines=table.concat(NS.PetGuide.Lines(info),'\n')
check(lines:find('Furious Howl',1,true) and lines:find('Above your level',1,true),'recommended family skill and level warning')
check(lines:find('Family guide only',1,true) and lines:find('actual skills',1,true),'family recommendation not presented as known skill')
UnitCreatureFamily=function() return '狼',1 end
check(NS.PetGuide.ReadTarget().family.name=='Wolf','family ID works on non-English clients')
UnitCreatureID=function() return 999999 end
check(not NS.PetGuide.ReadTarget().notable,'ordinary beast uses family guide')
UnitCreatureID=function() return 5807 end
check(not NS.PetGuide.ReadTarget().notable,'mismatched family rejects named pet record')
UnitCreatureFamily=function() return 'Wolf' end
check(NS.PetGuide.ReadTarget().family.name=='Wolf','English family fallback for old API signature')
UnitCreatureFamily=function() return 'Unknown',999999 end
check(not NS.PetGuide.ReadTarget(),'unlisted family stays quiet')
Reset();UnitCreatureFamily=function() return 'Fox',319 end
check(NS.PetGuide.ReadTarget().family.ability=="Trickster's Dance",'Forever fox guide')
Reset();UnitCreatureID=nil
check(NS.PetGuide.ReadTarget().notable.name=='Timber','GUID fallback when creature ID API absent')
for _,guid in ipairs({'Pet-0-1234-0-5678-1132-0000ABC123','Player-1234-1132','broken','Creature-0-1234-0-5678-bad-0000ABC123',secret,1132}) do
 UnitGUID=function() return guid end
 check(not NS.PetGuide.ReadTarget().notable,'invalid or restricted GUID never exact-matches')
end
Reset();UnitCreatureID=function() return secret end
check(not NS.PetGuide.ReadTarget().notable,'restricted creature ID never falls back around restriction')
for _,api in ipairs({'UnitExists','UnitIsDead','UnitIsPlayer','UnitCreatureFamily'}) do
 for _,mode in ipairs({'secret','error','nil','absent'}) do
  Reset()
  _G[api]=mode~='absent' and function()
   if mode=='secret' then return secret elseif mode=='error' then error('restricted') end
  end or nil
  check(not NS.PetGuide.ReadTarget(),'missing or restricted target eligibility stays quiet: '..api..' '..mode)
 end
end
for _,api in ipairs({'UnitIsDead','UnitIsPlayer'}) do
 Reset();_G[api]=function() return true end
 check(not NS.PetGuide.ReadTarget(),'dead targets and players excluded')
end
-- Friendly/owned pets provide the same advice without wild-beast claims.
Reset();UnitPlayerControlled=function() return true end
UnitName=function() return 'My renamed pet' end
UnitIsFriend=function() return true end
local pet=NS.PetGuide.ReadTarget()
check(pet and pet.owned and not pet.wild,'another player pet is eligible')
check(pet.family.name=='Wolf' and NS.PetGuide.Summary(pet):find('Furious Howl',1,true),'owned pet keeps family recommendation')
check(not pet.notable and not pet.tooHigh,'owned pet ID and level never imply a tame opportunity')
local petLines=table.concat(NS.PetGuide.Lines(pet),' ')
check(petLines:find('Player-controlled pet',1,true) and not petLines:find('Beast Lore',1,true) and not petLines:find('Watch list',1,true),'owned pet tooltip distinguishes advice from spawn intel')
UnitCreatureID=function() error('identity lookup should not run for an owned pet') end
check(NS.PetGuide.ReadTarget().owned,'owned advice does not need an NPC ID')
UnitIsFriend=function() return false end
check(NS.PetGuide.ReadTarget().owned,'enemy-owned pet also gets family advice')
for _,mode in ipairs({'secret','error','nil','absent'}) do
 Reset()
 UnitPlayerControlled=mode~='absent' and function()
  if mode=='secret' then return secret elseif mode=='error' then error('restricted') end
 end or nil
 local result=NS.PetGuide.ReadTarget()
 check(result and not result.owned and not result.wild,'unavailable ownership preserves readable family advice')
 check(not result.notable and not result.tooHigh,'unavailable ownership never implies a wild tame target')
end
Reset();UnitIsFriend=function() return true end
check(NS.PetGuide.ReadTarget().wild,'friendly wild beasts remain eligible')
Reset();UnitCreatureFamily=function() return 'Wolf',secret end
check(not NS.PetGuide.ReadTarget(),'secret family ID not bypassed through name')
Reset();UnitName=function() return '|cffff0000Test\nName' end
check(NS.PetGuide.ReadTarget().name=='||cffff0000Test Name','unit name escapes formatting')
Reset();UnitName=function() return secret end
check(NS.PetGuide.ReadTarget().name=='Timber','restricted name uses known static name')
Reset();UnitClassification=function() return 'normal' end
check(not NS.PetGuide.ReadTarget().special,'live normal classification overrides rare watch-list history')
for _,kind in ipairs({'elite','rareelite','worldboss'}) do
 UnitClassification=function() return kind end
 check(NS.PetGuide.ReadTarget().special,'live special classification '..kind)
end
UnitClassification=function() return secret end
check(not NS.PetGuide.ReadTarget().classification,'secret classification stays absent')
for _,level in ipairs({secret,-1,0,math.huge,0/0}) do
 UnitLevel=function() return level end
 local result=NS.PetGuide.ReadTarget()
 check(not result.level and not result.tooHigh,'invalid levels do not generate tame claim')
end
Reset();UnitLevel=function(unit) return unit=='player' and 20 or 10 end
check(not NS.PetGuide.ReadTarget().tooHigh,'lower-level target no level warning')
local families,notables=0,0
for id,family in pairs(NS.PetDatabase.families) do
 families=families+1
 UnitCreatureFamily=function() return family.name,id end
 local result=NS.PetGuide.ReadTarget()
 check(result and #NS.PetGuide.Lines(result)>=6,'every family yields a complete guide')
end
for _,entry in pairs(NS.PetDatabase.notable) do
 notables=notables+1
 check(NS.PetDatabase.families[entry.family] and entry.zone~='','every notable has a family and location')
end
check(families==19 and notables==21,'curated database coverage')
print('PASS: '..count..' pet guide checks')
