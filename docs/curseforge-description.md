# Forever Classmate

**One compact, class-aware companion for World of Warcraft: Forever.**

Forever Classmate detects your class and shows the compact information that class needs, in one engraved bar that folds into a small card when you don't need it. It supports all nine classes. Only your class's module runs; the others create no frames, events or polling. Every class keeps its own saved settings.

The interface follows the WoW client language: English and Simplified Chinese (`zhCN`). Spell and character names come from the client. Spell tracking works on Chinese clients too: every spell and aura the addon watches is matched by its Chinese name from the Forever client's own spell table. Other locales use English.

## Highlights

- **Engraved class bar.** A 426 × 56 bar (the width of Forever's default swing timer) in an engraved frame tinted in your class color, with your class crest set half into its left edge. Your resource is a colored meter (blue mana, red rage, yellow energy) with your shard count, combo pips or stance icon beside it, and the other slots name what they show, like "Ready / Overpower", "12s / Rend", "Missing / Thorns" or "28m / Seal of Command".
- **Compact card.** Fold the bar into a small card: your class crest on top, then one class stat and any confirmed missing buffs, each in a matching framed cell with an ember glow.
- **Class stat at a glance.** The card always shows the number your class watches most: Hunter ammo, Warlock soul shards, Shaman Ankhs, Mage conjured water, Rogue poison time, mana for Paladin, Priest and Druid, and health for Warrior.
- **Fold outside combat, expand in combat.** Optional automatic switching with a class-colored flare as the bar bursts out or the card drops in.
- **One minimap icon.** Other addons' minimap buttons gather into a tray that opens when you hover over the Classmate button.
- **Leveling reminders** for the sleeping bag and XP food buffs below level 60, and an **alt and recent recipient list** beside Send Mail.

## Class companions

| Class | Live helper |
| --- | --- |
| Hunter | Range brackets and validated yards, or an optional red/green range icon; ammo, target of target, facing ("12° left"), Hunter's Mark, aspect (including Cheetah or Pack left on in combat), pet care, family guidance and optional player Inspect |
| Shaman | Four totem slots with live or marked estimated timers, weapon imbue with charges (including a dual-wielded off-hand weapon), elemental shield with its last charge in red, mana, Totemic Recall, and learned Maelstrom, Riptide, Lightning Mastery, Stormstrike and Totemic Call cues |
| Paladin | Mana, active seal by name and time, your aura, blessings and Righteous Fury, target judgments, Unsealed Wrath, and learned Holy Strike, Holy Shock and Consecration readiness |
| Warrior | Rage, your stance by name, shout upkeep, Rend, Deep Wounds, Sunder Armor, Thunder Clap, Demoralizing Shout and Hamstring, Enrage and Flurry, and learned cues including Overpower, Slam, Reckless Swings and Bloodrage |
| Rogue | Energy, combo points, poison on each weapon with time left, Slice and Dice, Poised and Venom procs, your poisons, bleeds and Expose Armor on the target, and reactive abilities |
| Druid | Current form and its live power, combo points in Cat Form, Mark of the Wild, Thorns and Omen of Clarity with its Clearcasting proc, target bleeds and DoTs, readable procs, plus Primal Bite and Shifting Power |
| Mage | Live mana meter, armor and absorb-shield status, Fire Vulnerability and other target setup, Hot Streak, Fingers of Frost, Clearcasting, Arcane Blast stacks and Missile Barrage, and learned abilities when ready |
| Priest | Mana, Shadowform, Inner Fire, Fortitude, Divine Spirit and Shadow Protection upkeep, Shadow target effects, Penance, Inner Focus and other learned abilities, and Forever's race-specific Priest spells |
| Warlock | Mana, soul shards, armor, demon presence and health (or your Demonic Sacrifice buff), every target DoT and curse, Nightfall's Shadow Trance proc, and learned abilities including Amplify Curse |

The standard class bars find every active racial you have learned and show one that is ready now, by name, with the others on hover. Cooldown timers are left to the game's Cooldown Manager: an ability or racial on cooldown simply drops off the bar until it is ready again. This includes Forever racials such as Will to Survive, Elune's Light, Eureka!, Shatter Curse, Read Ley Line and Skysight. "Context" means the game reports that ability unusable right now; the addon does not guess why.

Everything comes from your live spellbook, auras and cooldowns, so it adapts to the talents you have learned. Classmate never casts anything, never prescribes a rotation, and never shows a guess as fact: when the game doesn't report a value, that slot stays empty rather than showing a placeholder.

Warrior, Rogue, Druid, Priest and Warlock can show **slim multi-target DoT bars** to the right of the main bar, for your target and enemies with visible nameplates. Turn them off with **Show multi-target DoT bars**.

## The bar

Engraved dividers separate the slots, and every icon sits in a matching frame. A confirmed missing buff (armor, seal, Hunter's Mark, aspect, Shaman imbue or shield) switches to an amber frame with an ember glow, and the whole frame warms to amber. **Flash missing buffs** gently pulses those frames; turn it off for a steady warning. Unreadable states, missing pets and temporary Rogue finishers never trigger a warning.

Bars are fully visible in combat and fade between fights: 60% with a target and 20% when idle (Mage 90% and 75% so mana and armor stay readable). A confirmed missing buff, an active Shaman totem or hovering the bar brings it back to full opacity.

## Compact card

Click the small **<** on the bar to fold it into a card. Your class crest sits on top, breaking through the card's upper edge with a soft class-colored glow. Below an engraved divider, one row holds your class stat followed by up to three confirmed missing buffs; any further warnings are counted on the last cell and listed on hover. Zero shards, water or Ankhs and low ammo show in red. With nothing to report, only the glowing crest remains. The crest stays exactly where you place it.

When you die the bar folds down to your crest, which fades to a ghostly tint inside a slowly breathing spirit glow, and it expands again when you're back on your feet. Click the card to expand again. Turn on **Fold outside combat, expand in combat** to switch automatically; a click still overrides it until your next combat change. **Show class stat in compact card**, **Collapsed warning icon** and **Show collapse button** are separate settings.

## Minimap button tray

With **Group addon minimap buttons** on (the default), other addons' minimap buttons move into a framed tray behind the Classmate button, so it is the only icon around your map. Hover over Classmate to open the tray; its first cell opens Classmate settings. Left-click Classmate for settings and right-click to inspect your target. Buttons keep their own clicks and tooltips, and the tray closes on a click, on Escape, or two seconds after you move away.

Only named addon launchers (LibDBIcon, ForeverCore and similar) are collected. Blizzard minimap controls, map pins and protected frames are never touched, and nothing moves during combat. Turn the option off to return every button to its original spot.

## Leveling reminders

Below level 60 and outside combat, two independent reminders sit in a small tab above the bar (or in the compact card):

- **Sleeping bag:** shown when the Well-Rested buff is confirmed missing; any active stack clears it.
- **Food XP:** shown when Well Fed is confirmed missing. Choose food whose tooltip says **+5% experience from kills**; the hidden XP bonus itself is not measured.

Combat, death, level 60 and unreadable aura data hide both.

## Mail recipients

Opening **Send Mail** shows a side panel with **Alts** and **Recent recipients**. Click a name to fill the recipient field, or right-click to forget it. Recents keep your newest 20 successful recipients for the current realm and faction, shared across your characters, with full first name and surname. Log into each alt once to record it. No mail contents, items or gold amounts are stored. Toggle **Mail recipients: alts and recents** independently of the class bar.

## Setup and commands

Install the `ForeverUtilities` folder into `_forever_/Interface/AddOns/`. Restart WoW the first time, and use `/reload` after updates.

Use `/fclassmate` or `/futils`, or your class command: `/fhunter`, `/fshaman`, `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest` or `/fwarlock`. Subcommands: `unlock`, `lock`, `fold`, `expand`, `autofold on|off`, `tray on|off`, `scale 0.5..2`, `on`, `off`, `reset` and `status`. The settings panel's **Reset settings** asks for a second click.

Hunters can switch to a minimal **Icon-only range display**: green when you can shoot, red when you can't. Use `/fhunter unlock` to move it.

Designed for the Forever 1.60.1 client. Automated checks use mocked game APIs; live in-game validation continues as the client changes.

[Class module behavior](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/class-modules.md) · [Release history](https://github.com/tomqwu/wow_forever_classmate/blob/main/docs/changelog.md) · [Source and issue tracker](https://github.com/tomqwu/wow_forever_classmate)
