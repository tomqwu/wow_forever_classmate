# Forever Classmate

**One compact, class-aware companion for World of Warcraft: Forever.**

Version 0.22.0 supports all nine classes. Forever Classmate detects the player class and starts only that module; other class modules create no frames, events, or polling. Every module has separate saved settings while movement, locking, scale, minimap access, and combat fading remain consistent. Full bars use the same 426-pixel rendered width as Forever's default desktop Main Hand swing timer; Hunters can switch to a 42-pixel range icon.

## Class companions

| Class | Live helper |
| --- | --- |
| Hunter | Range brackets and validated yards or an optional red/green range icon; ammo, target of target, facing, Hunter's Mark, aspect, pet care, family guidance, and optional player Inspect |
| Shaman | Four totem slots with live or marked estimated timers, weapon imbue, elemental shield, mana, Totemic Recall, and learned Maelstrom/Lava Burst/Riptide cues |
| Paladin | Mana, active seal, target judgments, Twist of Light aura, and learned Holy Strike/Holy Shock/Consecration readiness |
| Warrior | Rage, current stance, shout upkeep, Rend/Deep Wounds, and real Overpower/Execute/Victory Rush/Bloodthirst usability |
| Rogue | Energy, combo points, both weapon coatings, Slice and Dice/Venom, target poison or bleed, and reactive abilities |
| Druid | Current form and its live power type, Mark/Thorns, target DoTs, Eclipse/Nature's Grace/Omen, and learned spec abilities |
| Mage | Live mana meter, armor and absorb-shield status, personal target setup, Hot Streak/Fingers of Frost/Arcane Blast state, and learned cooldowns |
| Priest | Mana, self buffs, Shadow target effects, healing or Shadow abilities, and Forever's race-specific Priest spells |
| Warlock | Mana, health, Soul Shards, armor, demon presence, target DoT/Bane/Curse, and learned abilities |

The seven standard class bars discover every learned active racial and surface the one most useful now, while hover details list the others. This includes Forever racials such as Will to Survive, Elune's Light, Eureka!, Shatter Curse, Read Ley Line, and Skysight, plus the twelve race-specific Priest spells. “Context” means the game currently reports the racial unusable; the addon does not guess why.

Resource percentages use Forever’s native percent API when exact power values are restricted. Class cues come from the live spellbook and aura/cooldown APIs. They adapt to learned talents without hardcoded Classic spell IDs and do not infer a specialization, prescribe a fixed rotation, or cast anything. Missing, restricted, or secret values remain blank or unavailable.

## Setup and commands

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`. Restart WoW for first discovery or use `/reload` after an update.

Use `/fclassmate` or `/futils`, or the active class command: `/fhunter`, `/fshaman`, `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest`, or `/fwarlock`.

Subcommands: `unlock`, `lock`, `scale 0.5..2`, `on`, `off`, `reset`, and `status`.

Each information block can be switched independently. Bars use full opacity in combat; the Shaman bar also stays fully visible while a totem is active. Mage uses 90% opacity with a target and 75% while idle outside combat. Without an active totem, the other bars use 60% with a target and 20% while idle.

For a minimal Hunter display, enable **Icon-only range display** in `/fhunter` settings. Green means the client confirms ranged reach, red means it confirms you cannot shoot, and gray means the result is unknown. The icon hides without a valid hostile target while locked. Use `/fhunter unlock` to move it. The optional **Inspect button for player targets** appears in the full bar only when WoW allows inspection. Pet hints describe family guidance; the selected pet's learned abilities remain unknown unless checked with Beast Lore.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing as the beta changes.
