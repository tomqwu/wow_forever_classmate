# Sleeping bag reminder

Classmate 0.28.0 includes an optional sleeping bag reminder on every class. The
user's corrected level condition is **character level < 60**: levels 1–59 qualify,
and level 60 does not.

## Behavior

- Outside combat, a small bag icon appears only after a complete readable player
  aura scan confirms that the sleeping bag's **Well-Rested** buff is absent.
- Any active stack clears the reminder. It does not warn about partial stacks,
  remaining duration, ordinary rested XP, or the separate Legacy perk.
- A confirmed reminder keeps the bar fully visible. Its border follows the
  per-class **Flash missing buffs** setting; turning flashing off leaves a static
  icon. **Sleeping bag buff reminder (below level 60)** disables it independently.
- Full bars keep their existing dimensions, with the badge above the lock area.
  Hunter's compact range display places the badge beside the range icon.
- Combat, death, world exit, disabled tracking, or unreadable data clear the icon.
  Level 60 removes the listeners immediately, including on `PLAYER_LEVEL_UP`
  before `UnitLevel` updates. There is no timer or per-frame aura polling.

Ownership of a personal bag is not required by this reminder. It recommends
obtaining the buff; it neither uses an item nor casts a spell.

## Client data and sources

Checked on November 7, 2026:

| Record | ID | Purpose |
| --- | --- | --- |
| [Cozy Sleeping Bag](https://www.wowhead.com/forever/item=211527/cozy-sleeping-bag) | 211527 | Reminder artwork |
| [Well-Rested](https://www.wowhead.com/forever/spell=429959/well-rested) | 429959 | Actual sleeping bag aura; any active stack satisfies the reminder |
| [Unroll Bag](https://www.wowhead.com/forever/spell=429961/unroll-bag) | 429961 | Item use effect, distinct from the aura being checked |
| [Well Rested](https://www.wowhead.com/forever/spell=1225478/well-rested) | 1225478 | Separate Legacy effect; does not satisfy the reminder |

These fixed IDs identify an item effect rather than a learned class action.
Matching the readable aura ID avoids depending on English spell-name lookup or
inventing a localized name. The feature does not assume a particular XP bonus,
duration, or per-stack value from the static record.

The extracted Forever
[unit aura API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua)
documents restricted aura access. A nullable `GetPlayerAuraBySpellID` lookup is
not used as proof of absence. `LevelingBuffs.lua` instead scans helpful player
auras through `C_UnitAuras.GetAuraDataByIndex` outside combat and only confirms
absence after reaching the end with readable spell IDs. An error, restricted
record or identifier, missing API, or scan that does not reach the end leaves
status unknown and produces no warning.

The regression suite covers the 59/60 boundary, one and multiple stacks,
localized/secret names, the separate Legacy aura, combat and death, world
transitions, event teardown, shared fading, compact placement, and feature
toggles. These are mocked checks; the live client still needs confirmation.

Since 0.29.0 the same service also hosts the independent [food XP reminder](food-xp.md). Both share one aura scan and event listener; disabling either leaves the other working. The food icon fits below the lock, while the bag stays above it. Compact Hunter mode puts both beside the range icon.
