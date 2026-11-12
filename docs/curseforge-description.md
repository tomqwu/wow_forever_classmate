# Forever Classmate

**One compact, class-aware companion for World of Warcraft: Forever.**

Version 0.31.4 supports all nine classes. Forever Classmate detects the player class and starts only that module; other class modules create no frames, events, or polling. Every module has separate saved settings while movement, locking, scale, minimap access, and combat fading remain consistent. Full bars use the same 426-pixel rendered width as Forever's default desktop Main Hand swing timer; Hunters can switch to a 42-pixel range icon.

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

**Expanded bar:** the full bar uses the same engraved frame as the compact card, tinted in your class color, with your class crest set half into its left edge. Engraved dividers separate the slots, and slot icons sit in matching engraved frames. Confirmed missing buffs (armor, Hunter's Mark, aspect, Shaman imbue and shield) switch to the amber warning frame with an ember halo, and the whole frame warms to amber while a warning is confirmed. Food and sleeping bag reminders sit in a small tab of amber cells above the bar's right end, clear of the lock and slots. Slot positions and the 426 × 56 bar are unchanged.

**Foldable bar:** click the small **<** button to fold the bar into a compact card. A large painted crest for your class sits on top, breaking through the card's upper edge with a soft class-colored glow, and stays readable outside combat. Below an engraved divider, confirmed missing buffs appear in one row of up to four equal cells. One engraved frame, tinted in your class color, surrounds the crest and cells. Each cell keeps its own bright amber frame and a warm ember halo around a dark well with the icon inset, so warnings stand out and food, sleeping bag and class icons line up whatever their art. With no warnings the card disappears and only the glowing crest remains. The crest stays where you placed it; the card grows below and around it. Each warning clears when its buff returns, its option is disabled, or its reading becomes unavailable; existing level and combat rules apply. The crest identifies the class only and never claims a buff is active or missing. Hover lists every warning; when more than four are confirmed, the fourth cell shows how many more are hidden. **Flash missing buffs** gently pulses the cell frames and halos, never the icons; with it off, the halo stays steady. Click the card to expand, or unlock to drag. The expanded 426 × 56 bar remains inside its shared 450 × 64 frame; hiding the collapse button removes its 16-pixel rail (434 × 64). The expanded outline turns amber for confirmed warnings, and its art fades with the bar's actual opacity. **Fold outside combat, expand in combat** (off by default) switches views automatically: entering combat bursts the full bar out with a class-colored flare, and leaving combat drops the card back in. A click still overrides it until the next combat change, and an unreadable combat state never switches on its own. **Collapsed warning icon** and **Show collapse button** are independent settings. The shared container owns position and size; legacy WoW layout-cache entries cannot independently move its contents.

**Minimap button tray:** with **Group addon minimap buttons** on (the default), other addons' minimap buttons move into a framed tray behind the Classmate button, so it is the only icon around the map. Left-click Classmate to open the tray: the first cell opens Classmate settings, followed by every collected button in name order. Buttons keep their own clicks and tooltips; clicking one closes the tray, which also closes after two seconds away or with Escape. Only named, unprotected addon launchers (LibDBIcon, ForeverCore and similar) are collected. Blizzard minimap controls, map pins and protected frames are never touched, and nothing moves during combat. Turn the option off, or hide the Classmate button, to return every button to its original spot with its own dragging restored.

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

For a minimal Hunter display, enable **Icon-only range display** in `/fhunter` settings. Green means the client confirms ranged reach and red means it confirms you cannot shoot. The locked icon hides when reach is unavailable or there is no valid hostile target; unlocking keeps a neutral icon available for dragging. Use `/fhunter unlock` to move it. **Right-click the Classmate minimap button to inspect an eligible targeted player on any class**, including Hunter icon-only mode; left-click opens the addon tray (or settings when grouping is off). The right-click shortcut has its own per-class toggle. The optional Hunter full-bar Inspect button remains available. Pet hints describe family guidance; the selected pet's learned abilities remain unknown unless checked with Beast Lore.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing as the beta changes.

[Class module behavior](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/class-modules.md) · [Release history](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/changelog.md) · [Source and issue tracker](https://github.com/tomqwu/wow_forever_classmate)
