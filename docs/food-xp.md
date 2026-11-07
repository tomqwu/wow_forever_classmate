# Food XP reminder

Classmate 0.29.0 adds **Food XP buff reminder (below level 60)** for every class,
independently of the sleeping bag reminder. It defaults on and preserves existing
saved preferences.

## What it observes

At character levels **1–59**, outside combat, a small food icon appears when a
complete readable scan confirms that the player has no recognized **Well Fed**
aura. A visible Well Fed aura clears the reminder. Food health regeneration while
eating is a different effect and does not clear it before the food buff arrives.

The tooltip recommends food whose own description explicitly grants **5% more
experience from kills**. This is a reminder to eat suitable food, not a measured
XP multiplier: the bonus spell is marked hidden in client data, and Well Fed
alone does not prove the particular meal currently grants the XP bonus. A stat
food without a confirmed XP bonus also clears the food-presence reminder; check
the food's tooltip when choosing it. No quest-XP bonus is advertised.

## Sources and matching

Checked November 7, 2026:

- [Blizzard's Forever deep dive](https://worldofwarcraft.blizzard.com/en-us/news/24303313)
  describes crafted food with experience bonuses and stat boosts.
- [Roasted Boar Meat, item 2681](https://www.wowhead.com/forever/item=2681/roasted-boar-meat)
  explicitly lists a Well Fed stat buff and a 5% kill-XP bonus. It supplies the
  reminder's artwork, without requiring this particular dish.
- [Well Fed XP Boost, spell 1243969](https://www.wowhead.com/forever/spell=1243969/well-fed-xp-boost)
  describes the kill-XP effect and has the hidden-aura flag. Its absence from a
  normal aura listing is not treated as proof that the player lacks food.
- Visible Well Fed records include
  [1248406](https://www.wowhead.com/forever/spell=1248406/well-fed),
  [1248420](https://www.wowhead.com/forever/spell=1248420/well-fed), and
  [1248421](https://www.wowhead.com/forever/spell=1248421/well-fed).
  These representative IDs recognize readable auras without needing their
  names, and numeric `C_Spell.GetSpellInfo(1248406)` resolves the client's
  localized family name for other ranks. English and Simplified Chinese
  aliases cover metadata gaps; UI localization is separate from aura matching.

If an aura or its identifier is restricted, or its name cannot be classified,
the reminder stays quiet rather than inventing absence. Unresolved food-family
metadata on another client language likewise prevents an absence warning when
an unidentified aura is present. No bonus amount or expiration is reconstructed.

## Layout and lifecycle

`LevelingBuffs.lua` owns both leveling reminders through one shared controller
and one aura scan per relevant event. Each preference is independent; either
warning keeps the bar fully visible and follows **Flash missing buffs**. Turning
flashing off retains static icons. Food fits below the lock and the bag above
it; Hunter's compact mode places both beside its range icon. Bar dimensions and
the lock control are unchanged.

Combat, death, world exit, hiding the owner, disabling tracking, or unavailable
data clear affected reminders. Both disabled removes the controller's listeners.
Reaching level 60 removes them immediately, even if a queued event sees an old
`UnitLevel` value. No polling, combat-log access, or automated item use is added.

Regression tests cover independent and simultaneous missing buffs, locale and
metadata gaps, shared fading, static/pulsing warnings, compact placement,
combat/death/loading, and the strict level limit. These are mocked tests, not
live client verification.
