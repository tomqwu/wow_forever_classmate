# Standard class modules

Version 0.21.18 supports Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock alongside the existing Hunter and Shaman companions. The standard modules share `ClassContext.lua` and `StandardClasses.lua`, but each has an independent `ForeverUtilitiesDB.<class>` table and command.

## Display model

Each standard class uses five readable icon slots inside a 426 × 56 footprint matching Forever's rendered default desktop swing-bar width:

1. **Resource:** power percentage plus a compact form, combo-point, health, or Soul Shard badge; hover shows exact values when readable. The native percentage API supplies a fallback when exact power values are restricted.
2. **Upkeep:** independently evaluated buff families, Rogue weapon coatings and finisher buffs, or Warlock armor and demon presence.
3. **Target:** the player's readable effect on the current target.
4. **Ability:** a current proc or one learned ability's real readiness or cooldown.
5. **Racial:** an available learned active racial, with all learned racial states in the tooltip. Priest racials remain ahead of base racials.

The bar does not select a specialization from a talent guess. It discovers learned spells and shows only states the client exposes. “Ready” uses the cooldown and usability APIs; “Context” means the ability is learned and off cooldown but the client currently reports it unusable. The addon does not explain an unavailable condition unless the API exposes it.

## Forever mechanics represented

- **Paladin:** persistent seals and target judgments, including the Twist of Light aura introduced for Retribution.
- **Warrior:** rage and stance changes, shout upkeep, Rend/Deep Wounds, Bloodthrill, and reactive or execute abilities. The game has its own swing display, so this module does not restore the retired swing bar.
- **Rogue:** both temporary weapon coatings, energy, combo points, Slice and Dice, Forever's Venom buff, target poison/bleed effects, and Riposte or other learned cooldowns.
- **Druid:** power changes with form, Mark of the Wild or Thorns, Moonfire/Insect Swarm/Faerie Fire/Rip, Eclipse and other learned procs, plus spec abilities such as Tiger's Fury or Swiftmend.
- **Mage:** a text-only mana slot with a native percentage fallback, armor upkeep, personal Improved Scorch or Pyroblast effects, Forever Hot Streak stacks, Fingers of Frost, Arcane Blast, and learned cooldowns. Its bar remains readable at 75% idle opacity or 90% with a target outside combat; empty target and ability slots do not repeat the armor icon.
- **Priest:** self-buff upkeep, Shadow DoTs, Shadowform or Surge of Light, Shadow Word: Death and healing tools, plus all twelve documented Forever Priest racial spells.
- **Warlock:** mana, health, Soul Shards, armor, demon presence, Corruption/Immolate/Wrack/Banes/Curses, and learned Affliction, Demonology, or Destruction abilities.

Research was checked against current Forever 1.60.1 class guides and the current racial guide in September 2026. Beta spell names and mechanics can still change, so runtime discovery takes precedence over a static specialization table.

## Racial catalog

The catalog recognizes the active combat and utility racials currently documented for Human, Dwarf, Night Elf, Gnome, Orc, Undead, Tauren, Troll, and both Skyborne factions. Passive racials are intentionally absent because they have no actionable cooldown. Priest adds Divine Grace, Feedback, Desperate Prayer, Chastise, Starshards, Elune's Grace, Confounding Flash, Contingency Plan, Touch of Weakness, Dark Sacrifice, Hex of Weakness, and Shadowguard.

Racial recognition uses the learned spellbook. A catalog entry that is absent, renamed, passive, off-spec, or restricted stays hidden instead of being inferred from the player's race.

## Correctness review

See [the September 23 review](class-review-2026-09-23.md) for repaired warning, spell-discovery, lifecycle, and racial-readiness problems. Equivalent group buffs satisfy their individual upkeep family. Optional personal target effects display neutral absence instead of a blanket missing-spell warning.
