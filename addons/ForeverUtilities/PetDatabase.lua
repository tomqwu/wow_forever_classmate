local _, NS = ...
-- Curated Forever beta guide, reviewed 2026-09-20. See docs/pet-guide-sources.md.
-- These are family recommendations, NOT this creature's innate/teachable skills.
-- Numeric keys are creature family/NPC IDs, never IDs used for spell detection.
local DB={reviewed='2026-09-20',version='Forever 1.60.1 beta',families={},notable={}}
NS.PetDatabase=DB
local function Family(id,name,role,ability,effect)
    DB.families[id]={name=name,role=role,ability=ability,effect=effect}
end
Family(1,'Wolf','Group melee support','Furious Howl','Party melee attack power buff.')
Family(2,'Cat','Single-target damage / stealth','Claw / Prowl','Direct damage; stealth approach when trained.')
Family(3,'Spider','PvP control / kiting','Web','Root with Nature damage over time.')
Family(4,'Bear','Solo multi-target fighting','Swipe / Savage Rend','Multi-target attack; bleed support.')
Family(5,'Boar','Solo pulls / closing gaps','Rushing Charge','Burst movement and a stronger opening attack.')
Family(6,'Crocolisk','PvP healing pressure','Dismember','Damage with reduced healing received.')
Family(7,'Carrion Bird','Bleed-focused group support','Savage Rend','Bleed damage and increased bleed damage taken.')
Family(8,'Crab','PvP control / kiting','Pinch','Damage with a movement slow.')
Family(9,'Gorilla','Solo multi-target fighting','Thunderstomp','Area damage around the pet.')
Family(11,'Raptor','Bleed-focused damage','Savage Rend','Bleed damage and increased bleed damage taken.')
Family(12,'Tallstrider','Physical-damage group support','Dust Cloud','Armor reduction on the enemy.')
Family(20,'Scorpid','Sustained poison pressure','Scorpid Poison','Nature damage over time.')
Family(21,'Turtle','Solo pet survival','Shell Shield','Defensive damage reduction.')
Family(24,'Bat','Mobile damage','Bite / Dive','Direct damage and movement speed when trained.')
Family(25,'Hyena','PvP control / kiting','Tendon Rip','Damage over time with a movement slow.')
Family(26,'Owl / Bird of Prey','Control against weapon users','Mine!','Damage with a short disarm.')
Family(27,'Wind Serpent','Ranged Nature damage','Lightning Breath','Pet damage from outside melee range.')
Family(312,'Core Hound','Pressure against casters','Lava Breath','Fire damage and slower enemy casting; beta tame sources unconfirmed.')
Family(319,'Fox','Short bursts / pet survival',"Trickster's Dance",'Temporary dodge and faster attacks; beta tame sources unconfirmed.')
-- A small watch list, not a complete roster or a guarantee of tameability.
local function Notable(id,name,family,zone)
    DB.notable[id]={name=name,family=family,zone=zone}
end
Notable(5807,'The Rake',2,'Mulgore')
Notable(2850,'Broken Tooth',2,'Badlands')
Notable(14430,'Duskstalker',2,'Teldrassil')
Notable(3619,'Ghost Saber',2,'Darkshore')
Notable(731,'King Bangalash',2,'Stranglethorn Vale')
Notable(5823,'Death Flayer',20,'Durotar')
Notable(3068,'Mazzranache',12,'Mulgore')
Notable(10357,'Ressan the Needler',24,'Tirisfal Glades')
Notable(4425,'Blind Hunter',24,'Razorfen Kraul')
Notable(521,'Lupos',1,'Duskwood')
Notable(1132,'Timber',1,'Dun Morogh')
Notable(5356,'Snarler',1,'Feralas')
Notable(10077,'Deathmaw',1,'Burning Steppes')
Notable(9696,'Bloodaxe Worg',1,'Blackrock Spire')
Notable(8211,'Old Cliff Jumper',1,'The Hinterlands')
Notable(1130,'Bjarn',4,'Dun Morogh')
Notable(12037,"Ursol'lok",4,'Ashenvale')
Notable(3581,'Sewer Beast',6,'Stormwind City')
Notable(8213,'Ironback',21,'The Hinterlands')
Notable(14223,'Cranky Benj',21,'Alterac Mountains')
Notable(4887,'Ghamoo-ra',21,'Blackfathom Deeps')
-- Only used when the client does not return a family ID. ID matching is localized.
DB.familyNames={}
for id,family in pairs(DB.families) do DB.familyNames[family.name]=id end
DB.familyNames.Owl=26;DB.familyNames['Bird of Prey']=26
