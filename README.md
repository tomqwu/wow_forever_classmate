# Forever Classmate

<p align="center"><img src="assets/branding/forever-classmate-logo.png" width="256" alt="Forever Classmate — golden compass crest with nine class-colored gems"></p>

**One compact, class-aware companion for World of Warcraft: Forever.**

**[Build addons for Forever](https://tomqwu.github.io/wow_forever_classmate/)** is the companion GitHub Pages guide to the client API, safe reads, beta pitfalls, testing, and release practices.

Version 0.24.3 supports all nine classes. Forever Classmate detects the player class and starts only that module; other class modules create no frames, events, or polling. Every module has separate saved settings while movement, locking, scale, minimap access, and combat fading remain consistent. Full bars use the same 426-pixel rendered width as Forever's default desktop Main Hand swing timer; Hunters can switch to a 42-pixel range icon.

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

Warrior, Rogue, Druid, Priest, and Warlock can show **slim multi-target DoT bars** to the right of the main bar. Each row identifies an enemy, your active effect, and its readable remaining time. The strip tracks the current target and nearby enemies that have active nameplates; it clears a row when the effect expires or its nameplate disappears. It cannot continue tracking an offscreen enemy whose aura state Forever no longer exposes. Turn it off with **Show multi-target DoT bars** in your class settings. The original 426 × 56 bar stays the same size.

Warlock armor is confirmed out of combat. If combat hides the aura, the upkeep slot can keep the last confirmed armor icon dimmed without status text or an active claim. Other standard-class upkeep slots hide an unreadable count, and target, ability, racial, or resource slots disappear when no useful live state can be read.

## Setup and commands

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`. The folder name and `ForeverUtilitiesDB` stay stable for upgrades. Restart WoW for first discovery or use `/reload` after an update.

Left-click the round minimap button or use the active class command to open settings. Right-click it to inspect an eligible targeted player. Drag the button around the map edge. The padlock on the bar toggles movement without disabling updates or fading.

| Command | Action |
| --- | --- |
| `/fhunter`, `/fshaman`, `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest`, `/fwarlock` | Open settings for that active class |
| `/fclassmate` or `/futils` | Open settings for the active class |
| `<command> unlock` / `lock` | Move or lock the active bar |
| `<command> scale 1.2` | Set scale from 0.5 to 2 |
| `<command> on` / `off` | Enable or disable the active class helper |
| `<command> reset` | Restore that class module's defaults |
| `<command> status` | Show version and live diagnostics |

Each information block can be switched independently. Bars use full opacity in combat; the Shaman bar also stays fully visible while a totem is active. Mage uses 90% opacity with a target and 75% while idle outside combat. Without an active totem, the other bars use 60% with a target and 20% while idle. A confirmed missing long-term upkeep buff keeps a standard-class bar fully visible outside combat; an unavailable reading does not. Rogue finisher buffs still use the normal fade between fights. Unlocking does not override fading.

For a minimal Hunter display, enable **Icon-only range display** in `/fhunter` settings. Green means the client confirms ranged reach, red means it confirms you cannot shoot, and gray means the result is unknown. The icon hides without a valid hostile target while locked. Use `/fhunter unlock` to move it. **Right-click the Classmate minimap button to inspect an eligible targeted player on any class**, including Hunter icon-only mode; left-click opens settings. The right-click shortcut has its own per-class toggle. The optional Hunter full-bar Inspect button remains available. Pet hints describe family guidance; the selected pet's learned abilities remain unknown unless checked with Beast Lore.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing as the beta changes.

[Class module behavior](docs/class-modules.md) · [Shaman research](docs/shaman-module.md) · [Pet guide sources](docs/pet-guide-sources.md) · [Developer guide](docs/development.md) · [Release history](docs/changelog.md)
