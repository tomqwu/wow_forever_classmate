# Forever Classmate

**One compact, class-aware companion for World of Warcraft: Forever.**

Version 0.31.1 supports all nine classes. Forever Classmate detects the player class and starts only that module; other class modules create no frames, events, or polling. Every module has separate saved settings while movement, locking, scale, minimap access, and combat fading remain consistent. Full bars use the same 426-pixel rendered width as Forever's default desktop Main Hand swing timer; Hunters can switch to a 42-pixel range icon.

The interface follows the WoW client language: English and Simplified Chinese (`zhCN`) labels for bars, settings, warnings, and tooltips. Spell and character names come from the client; curated rare-pet names may remain in English. Other client locales use English.

## Class companions

| Class | Live helper |
| --- | --- |
| Hunter | Range brackets and validated yards or an optional red/green range icon; ammo, target of target, facing, Hunter's Mark, aspect, pet care, family guidance, and optional player Inspect |
| Shaman | Four totem slots with live or marked estimated timers, weapon imbue, elemental shield, mana, Totemic Recall, and learned Maelstrom, Riptide, Lightning Mastery, Stormstrike and Totemic Call cues |
| Paladin | Mana, active seal, target judgments, Unsealed Wrath aura, and learned Holy Strike/Holy Shock/Consecration readiness |
| Warrior | Rage, current stance, shout upkeep, Rend/Deep Wounds, and learned cues including Overpower, Slam and Reckless Swings |
| Rogue | Energy, combo points, both weapon coatings, Slice and Dice upkeep, Poised and Venom procs, target poison or bleed, and reactive abilities |
| Druid | Current form and its live power type, Mark/Thorns, target bleeds and DoTs, Poised and other readable procs, plus Primal Bite and Shifting Power |
| Mage | Live mana meter, armor and absorb-shield status, personal target setup, Hot Streak/Fingers of Frost/Arcane Blast/Missile Barrage state, and learned cooldowns |
| Priest | Mana, self buffs, Shadow target effects, Penance and other healing or Shadow abilities, and Forever's race-specific Priest spells |
| Warlock | Mana, health, Soul Shards, armor, demon presence, target DoT/Bane/Curse, and learned abilities including Amplify Curse |

The seven standard class bars discover every learned active racial and surface the one most useful now, while hover details list the others. This includes Forever racials such as Will to Survive, Elune's Light, Eureka!, Shatter Curse, Read Ley Line, and Skysight, plus the twelve race-specific Priest spells. “Context” means the game currently reports the racial unusable; the addon does not guess why.

Resource percentages use Forever’s native percent API when exact power values are restricted. Class cues come from the live spellbook and aura/cooldown APIs. They adapt to learned talents without hardcoded Classic spell IDs and do not infer a specialization, prescribe a fixed rotation, or cast anything. When the client cannot supply a useful live state, its bar status disappears; confirmed observations and explicit cast-based estimates remain visible.

Warrior, Rogue, Druid, Priest, and Warlock can show **slim multi-target DoT bars** to the right of the main bar. Each row identifies an enemy, your active effect, and its readable remaining time. The strip tracks the current target and nearby enemies that have active nameplates; it clears a row when the effect expires or its nameplate disappears. It cannot continue tracking an offscreen enemy whose aura state Forever no longer exposes. Turn it off with **Show multi-target DoT bars** in your class settings. The original 426 × 56 bar stays the same size.

Warlock armor is confirmed out of combat. Learned English and Simplified Chinese armor names are recognized even when English spell-name lookup is unavailable. A confirmed missing armor buff shows an explicit red-bordered Armor/Missing reminder at full opacity; buffing clears it. If combat hides the aura, the upkeep slot can keep the last confirmed armor icon dimmed without status text or an active claim. Other standard-class upkeep slots hide an unreadable count, and target, ability, racial, or resource slots disappear when no useful live state can be read.

**Foldable bar:** click the small **<** button beside the bar to fold it into a **64 × 64** native icon. The highest-priority confirmed upkeep, food, or sleeping-bag warning fills the icon; additional warnings form one row along the bottom. A thin amber outline pulses without obscuring the artwork. With no warnings, the icon shows class artwork. Drag instructions appear on hover. Warning borders follow **Flash missing buffs**, and active warnings keep the icon bright. Click the large icon to expand. **Collapsed warning icon** and **Show collapse button** are independent settings; each class remembers its view. Unlocking allows the icon to be dragged. Existing warning eligibility, level limits, and unreadable-data rules still apply.

## Mail recipients

Opening **Send Mail** shows a compact side panel with **Alts** and **Recent recipients**. Click a name to fill the recipient field, or right-click to forget its saved entry. Both lists have pagination; recents keep the newest 20 successful recipients for the current realm and faction, shared across your characters. Lists and recipient filling preserve the full **first name + surname**. Recent addresses are kept exactly as observed on a successful send; surnames are never treated as realm suffixes.

Log into each alt once with Classmate and its mail feature enabled to record it. After upgrading from 0.30.0, log into each alt again to replace its incomplete old name. Old first-name-only suggestions stay hidden until refreshed. The alt list shows other recorded characters on your current realm and faction; it does not discover unplayed characters from the account roster. No mail subject, body, items, or gold amounts are stored. Character and recipient records use the existing account-wide saved variables.

Toggle **Mail recipients: alts and recents** in `/fclassmate` settings independently of the class bar. The panel appears only beside the native Send Mail tab, hides in combat, and uses no polling. It fills the selected name; sending remains the normal game action.

## Setup and commands

Install the `ForeverUtilities` folder into the active Forever client’s `_forever_/Interface/AddOns/` folder. Historical beta installs used `_classic_beta_/Interface/AddOns/`. Restart WoW for first discovery or use `/reload` after an update.

Use `/fclassmate` or `/futils`, or the active class command: `/fhunter`, `/fshaman`, `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest`, or `/fwarlock`.

Subcommands: `unlock`, `lock`, `scale 0.5..2`, `on`, `off`, `reset`, and `status`.

Each information block can be switched independently. Bars use full opacity in combat; the Shaman bar also stays fully visible while a totem is active. Mage uses 90% opacity with a target and 75% while idle outside combat. Without an active totem, the other bars use 60% with a target and 20% while idle. A confirmed missing long-term upkeep buff keeps a standard-class bar fully visible outside combat; an unavailable reading does not. Rogue finisher buffs still use the normal fade between fights. Hovering a bar reveals it at full opacity, even while locked; leaving restores its normal fade. Unlocking alone does not change opacity.

Hunter ammo counts and low-ammo warnings respect the current weapon’s ammo eligibility when the client exposes it; no-ammo weapons and unreadable eligibility stay quiet.

Confirmed missing maintained buffs now pulse their warning border while the icon, text and bar stay readable. **Flash missing buffs** can be disabled independently in class settings to keep a static warning. Hunter aspects and Shaman shields retain their existing combat-only warning conditions. Warlock armor is confirmed outside combat; restricted readings, temporary Rogue finishers and missing pets do not trigger a pulse.

**Sleeping bag reminder:** for levels **1–59**, a small Cozy Sleeping Bag icon appears when the Well-Rested buff is confirmed missing outside combat, and keeps the bar fully visible. Any active stack clears it. Level 60 and above, combat, death, and unreadable aura data hide the reminder. Disable **Sleeping bag buff reminder (below level 60)** independently in class settings; **Flash missing buffs** also controls its pulsing border. The bar keeps its current size; Hunter icon-only mode places the reminder beside the range icon.

**Food XP reminder:** a separate food icon reminds levels **1–59** to eat XP-bonus food outside combat when Well Fed is confirmed absent. Seeing Well Fed clears the reminder. The XP effect is hidden, so this checks food-buff presence rather than measuring the actual bonus; choose food whose tooltip says **+5% experience from kills**. **Food XP buff reminder (below level 60)** has its own toggle. Either leveling reminder keeps the bar bright and follows **Flash missing buffs**, without changing its size.

For a minimal Hunter display, enable **Icon-only range display** in `/fhunter` settings. Green means the client confirms ranged reach and red means it confirms you cannot shoot. The locked icon hides when reach is unavailable or there is no valid hostile target; unlocking keeps a neutral icon available for dragging. Use `/fhunter unlock` to move it. **Right-click the Classmate minimap button to inspect an eligible targeted player on any class**, including Hunter icon-only mode; left-click opens settings. The right-click shortcut has its own per-class toggle. The optional Hunter full-bar Inspect button remains available. Pet hints describe family guidance; the selected pet's learned abilities remain unknown unless checked with Beast Lore.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing as the beta changes.

[Class module behavior](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/class-modules.md) · [Release history](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/changelog.md) · [Source and issue tracker](https://github.com/tomqwu/wow_forever_classmate)
