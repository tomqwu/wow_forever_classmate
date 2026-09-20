# Target pet guide database

Reviewed **2026-09-20** for the **Forever 1.60.1 beta**. This is an embedded,
offline Lua database, with 19 family profiles and a 21-creature watch list. It
makes no network requests from the game and does not scan nearby units.

## What a hint means

The blue paw badge means the selected wild creature matches a supported family.
Gold means a named watch-list match or a live rare/elite/boss classification.
Red means the readable target level exceeds the player's level. Hover for the
family, level, classification, suggested use, useful family abilities, and a
watch-list location when available. Badges fit beside the happiness badge in the
existing pet block. They do not change weapon/range colors.

"Suggested use" is our recommendation from the ability's function, not a measured
DPS ranking. A family ability is **not a claim that this creature already knows
or teaches it**. Skill ranks, innate abilities, unlock levels, spawn timers,
attack speeds, and retained elite bonuses are deliberately not inferred from
Classic Era entries. The tooltip says to check Beast Lore for tameability and
actual skills. Family matches alone cannot prove tameability. The watch list
also does not prove availability in the currently accessible beta zones.

## Evidence and limits

- [Beastmaster's Forever ability guide](https://beastmaster.io/forever/abilities)
  and [Forever family guide](https://beastmaster.io/forever/families) provide the
  beta family associations. Its roster explicitly remains preliminary. We use
  short, original functional summaries rather than importing its descriptions.
- [Beastmaster's Forever roster](https://beastmaster.io/forever/all) supplies the
  selected NPC IDs, family associations, names, and locations. We did **not**
  import its Classic-derived ranks, speed claims, rarity, timers, lore, or
  inferred skill lists. Live UnitClassification supplies rarity and elite state.
- [Wowhead's Forever Dismember record](https://www.wowhead.com/forever/spell=1264758/dismember)
  supports the healing-reduction hint.
- [Wowhead's Forever Trickster's Dance record](https://www.wowhead.com/forever/spell=1310612/tricksters-dance)
  supports the temporary dodge/attack-speed hint.
- [ForeverDiff's Swipe record](https://foreverdiff.com/recipes/swipe-56454/)
  identifies the new Bear skill in beta builds 69876, 69893, and 69913.
- [TheWoWDB's Forever family records](https://thewowdb.com/wow-forever/creature-families/)
  supply numeric family IDs. Its
  [Wolf spell data](https://thewowdb.com/wow-forever/creature-family/wolf-1/)
  also confirms the revised melee-attack-power Howl. These pages list only a
  subset of skills and include generic specialization prose; that prose is not
  used for recommendations.

Core Hound and Fox tame sources remain unconfirmed; their family hints say so.
The Bat hint uses Bite/Dive, avoiding an unverified assertion that every Forever
bat has Screech. There is no "best overall" or "elite means stronger" claim.

## Matching and maintenance

`PetDatabase.lua` contains hand-curated family and NPC tables.
`PetGuide.lua` handles guarded API reads, eligibility, and the badge tooltip.
Numeric family IDs permit matching across locales; guide copy is English. Old
API signatures fall back to known English family names. Unknown families stay
quiet. A named match must also agree with the live family.

Verified API signatures come from Blizzard's UI source mirror at
`4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069`, particularly
`Blizzard_APIDocumentationGenerated/UnitDocumentation.lua` and
`Blizzard_UnitFrame/Camelot/TargetFrame.lua`:

- UnitCreatureFamily returns name and family ID; both may be secret.
- UnitCreatureID is used when available. Only an absent API permits parsing a
  readable Creature GUID; a restricted result is never bypassed.
- UnitExists, UnitIsDead, UnitIsPlayer, and UnitPlayerControlled must explicitly
  identify a living, uncontrolled non-player target.
- UnitName, UnitLevel, and UnitClassification are optional, guarded details.

Add new facts only with a Forever-specific source and review date. Verify an
exact beast's teachable skills in the beta before adding skill ranks or marking
it as a skill source. Do not promote Classic comments into confirmed beta facts.
Regression tests cover data consistency, locale IDs, secret/missing/error APIs,
wrong-family NPCs, tooltip refresh/clearing, toggles, and the existing lifecycle.
