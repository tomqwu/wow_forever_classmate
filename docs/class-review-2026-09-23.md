# Class and racial review — 0.21.15

Reviewed every shipped class catalog, racial selection, warning, API guard, and event lifecycle after the Shaman combat/totem failures. Validation uses mocked Forever APIs; this is not a claim of live gameplay validation on all classes or races.

## Confirmed problems repaired

| Area | Problem and repair |
| --- | --- |
| Shared API reads | A nil return could stop secret-value checking of later return values. Calls now preserve every return position and check the entire result. Missing aura names, stack counts, and weapon reads remain unknown. |
| Spell discovery | Standard modules could miss override IDs or choose the first low rank. They also examine a readable base spell and prefer a higher readable learned level. All three discovery paths accept a known base ID and refresh on the documented `LEARNED_SPELL_IN_SKILL_LINE` event; the deprecated standard-class event was removed. |
| Ability/racial readiness | Every cooldown of 1.6 seconds or less was treated as ready. Short cooldowns now count down; missing enabled-state data remains unknown. Passive racial entries are still excluded. |
| Lifecycle | Later target/aura events or settings refreshes could revive updates after death or world exit. All class bars suspend and hide until the appropriate return event; disabled standard blocks stop reading their data. |
| Hunter | Added resurrection events and explicit suspension. Localized aspect names are recognized when the client resolves their metadata. All target widgets disabled means no target polling. Existing ammo, mark, pet-care, range, and guide tests remain green. |
| Shaman | Passive Maelstrom Weapon is discoverable. Restricted stacks no longer become `0/5`. Riptide uses actual readiness/cooldown data. Flame Shock must be the player's. Recall is only suggested if learned. Ending combat does not erase an observed totem when the slot API remains unavailable. |
| Paladin | Added Seal of Justice and Forever's Seal of Fury to upkeep. Judgments can be recognized as aura effects of learned seals without pretending they are separate learned actions. |
| Warrior | Missing optional personal target effects are neutral instead of demanding Rend on every target. Stance, shout, proc, and reactive ability paths retain their readable-state guards. |
| Rogue | Restricted or malformed weapon-coating reads no longer count as empty equipment. Finisher buffs, personal effects, combo points, and readiness retain their separate checks. |
| Druid | Gift of the Wild satisfies Mark of the Wild upkeep, including when received before the player learns Gift. Thorns is still evaluated separately. |
| Mage | Armor and proc checks retain independent state. Optional target effects such as Pyroblast no longer generate blanket missing-effect warnings. |
| Priest | Prayer of Fortitude and Prayer of Spirit satisfy their individual buff families. Priest racial priority remains intact; missing/secret readiness remains unknown. |
| Warlock | The missing-demon reminder starts only after a supported summon is learned. Armor, health/mana, shards, and personal effects retain their guards. |
| Target labels | A dead hostile target no longer appears as “Friend.” Optional personal effects display “None” when absent and `?` when unavailable. |
| Racials | Audited the shared catalog for Human, Dwarf, Night Elf, Gnome, Orc, Undead, Tauren, Troll, and Skyborne abilities plus Priest racials. Added the missing Find Treasure utility entry. Selection uses learned spells, never assumptions from race. |
| Diagnostics/settings | The displayed version now comes from the loaded TOC and appears at startup. Hunter/Shaman initialization can no longer downgrade the shared saved-data schema after another class initialized it. |

## Limits that remain explicit

- The seven standard class bars have racial slots. Hunter and Shaman retain their existing layouts without a racial slot; this review does not claim otherwise.
- “Ready” means the client reports the spell off cooldown and usable. It is not a recommendation to use a defensive/dispel racial or a particular rotation.
- Catalogs are selective helpers, not complete spell databases. An unrecognized talent/aura name or unavailable spellbook entry may still stay hidden. Passive stat racials have no readiness display.
- Restricted live data is not reconstructed. Totems seen before combat retain their readable timing; newly observed casts use `~` estimates only after the exact spell duration has been learned. A cast before reload cannot be recovered when native slot data is unavailable.
- No prohibited combat-log registration, action automation, or coordinate-based recovery of restricted range was added.
- The local install must be compared with the release after publishing. Another process was observed replacing a newer install with 0.21.11; a successful earlier copy is not enough. `/fclassmate status` now reports the actual loaded version.

## Evidence and verification

- [Blizzard's Forever deep dive](https://worldofwarcraft.blizzard.com/en-us/news/24303313) confirms Seal of Fury, persistent seals, the class/race additions, and the reworked racial design. Spell availability still comes from the client's learned spellbook.
- Blizzard's extracted API documentation in the local `wow-ui-source` checkout documents `SpellBookItemInfo.baseSpellID`, cooldown enabled state, and secret return behavior. [Spell documentation mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua) documents learned-level lookup. Mainline documentation is not treated as proof that an optional API exists on Forever: every optional call is guarded.
- Regression scenarios cover nil-hole secret returns, short cooldowns, unknown stack/owner fields, equivalent buffs, learned summon gating, derived judgments, override discovery, rank choice, disabled reads, death/loading suspension, resurrection, and totem retention across combat exit.
- Release workflow: full repository checks, diff whitespace validation, package root and file comparison, local installation comparison, GitHub checks/release, and CurseForge receipt/hash verification.
