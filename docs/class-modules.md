# Standard class modules

Version 0.31.4 supports Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock alongside the existing Hunter and Shaman companions. The standard modules share `ClassContext.lua` and `StandardClasses.lua`, but each has an independent `ForeverUtilitiesDB.<class>` table and command.

For every class, left-clicking the Classmate minimap button opens settings and right-clicking it opens WoW's native Inspect window for an eligible targeted player. The right-click shortcut has a per-class toggle and does not change the bar's information slots.

Every class also has an independent **Sleeping bag buff reminder (below level 60)** setting. A small bag icon warns only at levels 1–59, outside combat, after a readable scan confirms Well-Rested is absent. Any active stack clears it; level 60 and above never warn. An active reminder keeps the bar bright and follows **Flash missing buffs**. See [sleeping bag behavior and sources](sleeping-bag.md).

The separate **Food XP buff reminder (below level 60)** warns at levels 1–59 outside combat when Well Fed is confirmed absent. Visible Well Fed clears it; the hidden XP effect is not a measured multiplier, so use food whose tooltip grants +5% XP from kills. Either leveling reminder keeps the bar bright, independently of class upkeep and the other reminder. Both follow **Flash missing buffs** and retain the existing bar size. See [food reminder sources and limits](food-xp.md).

Every class exposes **Mail recipients: alts and recents**, independent of the class bar. The shared mail service records logged-in characters and successful recipients in account-wide saved variables, and offers two paginated lists beside native Send Mail. Names include both first name and surname; selection fills the complete native address. Click to fill, right-click to forget. After 0.30.0, log into each alt again to refresh incomplete legacy names. Alts are limited to the current realm and faction; recents retain up to 20 successful recipients per sending realm/faction. See [mail behavior and API sources](mail-recipients.md).

## Display model

Each standard class uses five readable icon slots inside a 426 × 56 footprint matching Forever's rendered default desktop swing-bar width:

1. **Resource:** power percentage plus a compact form, combo-point, health, or Soul Shard badge; hover shows exact values when readable. The native percentage API supplies a fallback when exact power values are restricted.
2. **Upkeep:** independently evaluated buff families, Rogue weapon coatings and finisher buffs, or Warlock armor and demon presence.
3. **Target:** the player's readable effect on the current target.
4. **Ability:** a current proc or one learned ability's real readiness or cooldown.
5. **Racial:** an available learned active racial, with all learned racial states in the tooltip. Priest racials remain ahead of base racials.

The bar does not select a specialization from a talent guess. It discovers learned spells and shows only states the client exposes. “Ready” uses the cooldown and usability APIs; “Context” means the ability is learned and off cooldown but the client currently reports it unusable. The addon does not explain an unavailable condition unless the API exposes it.

An upkeep count is shown only when every learned group in that count has a readable result. An unavailable aura removes the count instead of producing a partial `0/1`; the icon of a previously confirmed effect may stay dimmed as an identity cue, with no status mark or active claim. Warlock Demon Skin/Armor/Fel Armor is checked outside combat, and that last confirmed icon remains in the existing upkeep slot during combat. A later readable absence clears it. The icon alone is not proof the buff remains active. Unreadable target effects and cooldowns hide their slots; confirmed missing effects and known ability states still display. A confirmed missing maintained buff restores full bar opacity outside combat, making the warning readable. Unavailable auras and missing temporary Rogue finishers do not override the saved fade preference.

Warrior, Rogue, Druid, Priest, and Warlock have an independently toggleable DoT strip anchored to the main bar's right edge. It shows up to five enemies and twelve slim effect bars for the player's learned, currently observed DoTs. The current target comes first, followed by active nameplates. Bar lengths and seconds use readable aura duration and expiration values; effects with restricted timing are omitted. Target and nameplate duplicates are collapsed by readable identity. Losing a nameplate, losing an aura, disabling the option, or leaving the world clears its observation. An offscreen enemy is not retained as a speculative timer.

## Forever mechanics represented

- **Paladin:** persistent seals and target judgments, including the readable Unsealed Wrath aura for Retribution.
- **Warrior:** rage and stance changes, shout upkeep, Rend/Deep Wounds, Bloodthrill, and reactive or execute abilities. The game has its own swing display, so this module does not restore the retired swing bar.
- **Rogue:** both temporary weapon coatings, energy, combo points, Slice and Dice, Forever's Venom buff, target poison/bleed effects, and Riposte or other learned cooldowns.
- **Druid:** power changes with form, Mark of the Wild or Thorns, Moonfire/Insect Swarm/Faerie Fire/Rip, Eclipse and other learned procs, plus spec abilities such as Tiger's Fury or Swiftmend.
- **Mage:** a slim vertical mana meter with a native percentage fallback, armor upkeep and active Mana Shield/Ice Barrier absorption, personal Improved Scorch or Pyroblast effects, Forever Hot Streak stacks, Fingers of Frost, Arcane Blast, and learned cooldowns. Its bar remains readable at 75% idle opacity or 90% with a target outside combat; empty target and ability slots do not repeat the armor icon.
- **Priest:** self-buff upkeep, Shadow DoTs, Shadowform or Surge of Light, Shadow Word: Death and healing tools, plus all twelve documented Forever Priest racial spells.
- **Warlock:** mana, health, Soul Shards, armor, demon presence, Corruption/Immolate/Wrack/Banes/Curses, and learned Affliction, Demonology, or Destruction abilities.

Research was checked against current Forever 1.60.1 class guides and the current racial guide in September 2026. Beta spell names and mechanics can still change, so runtime discovery takes precedence over a static specialization table.

## Racial catalog

The catalog recognizes the active combat and utility racials currently documented for Human, Dwarf, Night Elf, Gnome, Orc, Undead, Tauren, Troll, and both Skyborne factions. Passive racials are intentionally absent because they have no actionable cooldown. Priest adds Divine Grace, Feedback, Desperate Prayer, Chastise, Starshards, Elune's Grace, Confounding Flash, Contingency Plan, Touch of Weakness, Dark Sacrifice, Hex of Weakness, and Shadowguard.

Racial recognition uses the learned spellbook. A catalog entry that is absent, renamed, passive, off-spec, or restricted stays hidden instead of being inferred from the player's race.

## Correctness review

See [the September 23 review](class-review-2026-09-23.md) for repaired warning, spell-discovery, lifecycle, and racial-readiness problems. Equivalent group buffs satisfy their individual upkeep family. Optional personal target effects display neutral absence instead of a blanket missing-spell warning.

**Foldable bar:** click the small **<** button to fold the bar into a shared image-based frame. Confirmed missing buffs appear as equal **32 × 32** icons: one or two reminders use one row; three or four use two rows. The frame fits the visible icons with four-pixel padding, and the final row is centered. Each warning clears when its buff returns, its option is disabled, or its reading becomes unavailable; existing level and combat rules apply. When there are no confirmed warnings, a dim **64 × 64** Classmate logo serves as the expand button without claiming that a class buff is active or missing. Hover reveals the frame and lists its warnings. **Flash missing buffs** controls the outline pulse; active warnings keep the frame bright. Click the compact frame to expand, or unlock to drag. The expanded 426 × 56 bar remains inside its shared 450 × 64 frame. **Collapsed warning icon** and **Show collapse button** are independent settings.
