# Forever Classmate

**One compact, class-aware companion for World of Warcraft: Forever.**

Version 0.21.5 supports all nine classes. Forever Classmate detects the player class and starts only that module; other class modules create no frames, events, or polling. Every module has separate saved settings while movement, locking, scale, minimap access, and combat fading remain consistent. Every class bar uses the same 426-pixel rendered width as Forever's default desktop Main Hand swing timer.

## Class companions

| Class | Live helper |
| --- | --- |
| Hunter | Range brackets and validated yards, ammo, target of target, facing, Hunter's Mark, aspect, pet care, and notable beast intelligence |
| Shaman | Four live totem timers, weapon imbue, elemental shield, mana, Totemic Recall, and learned Maelstrom/Lava Burst/Riptide cues |
| Paladin | Mana, active seal, target judgments, Twist of Light aura, and learned Holy Strike/Holy Shock/Consecration readiness |
| Warrior | Rage, current stance, shout upkeep, Rend/Deep Wounds, and real Overpower/Execute/Victory Rush/Bloodthirst usability |
| Rogue | Energy, combo points, both weapon coatings, Slice and Dice/Venom, target poison or bleed, and reactive abilities |
| Druid | Current form and its live power type, Mark/Thorns, target DoTs, Eclipse/Nature's Grace/Omen, and learned spec abilities |
| Mage | Mana, armor upkeep, personal target setup, Hot Streak/Fingers of Frost/Arcane Blast state, and learned cooldowns |
| Priest | Mana, self buffs, Shadow target effects, healing or Shadow abilities, and Forever's race-specific Priest spells |
| Warlock | Mana, health, Soul Shards, armor, demon presence, target DoT/Bane/Curse, and learned abilities |

The seven standard class bars discover every learned active racial and surface the one most useful now, while hover details list the others. This includes Forever racials such as Will to Survive, Elune's Light, Eureka!, Shatter Curse, Read Ley Line, and Skysight, plus the twelve race-specific Priest spells. “Context” means the game currently reports the racial unusable; the addon does not guess why.

Class cues come from the live spellbook and aura/cooldown APIs. They adapt to learned talents without hardcoded Classic spell IDs and do not infer a specialization, prescribe a fixed rotation, or cast anything. Missing, restricted, or secret values remain blank or unavailable.

## Setup and commands

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`. Restart WoW for first discovery or use `/reload` after an update.

Use `/fclassmate` or `/futils`, or the active class command: `/fhunter`, `/fshaman`, `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest`, or `/fwarlock`.

Subcommands: `unlock`, `lock`, `scale 0.5..2`, `on`, `off`, `reset`, and `status`.

Each information block can be switched independently. Bars use full opacity in combat, 60% with a target outside combat, and 20% while idle.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing as the beta changes.
