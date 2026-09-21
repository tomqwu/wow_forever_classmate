# Forever Classmate

**Your class-aware companion for World of Warcraft: Forever.**

Forever Classmate is growing into a modular helper that detects your class and
shows the reminders, resources, and target context that class needs. The current
release includes the complete **Hunter companion**; Paladin and the remaining
Forever classes will arrive as their beta mechanics and addon APIs are validated.

## Available now: Hunter

- **Range at a glance:** a colored weapon icon and readable range text.
- **Ammunition tracking:** live carried-ammo count with a one-time warning at 200 or fewer.
- **Target context:** a target-of-target portrait and an optional facing angle.
- **Combat upkeep:** Hunter's Mark and missing-aspect reminders appear only when useful.
- **Pet care:** happiness state plus a red Mend Pet highlight at 30% health or below.
- **Pet discovery:** family guidance, rare origins, notable beasts, recommended abilities, zones, levels, and match limits for supported targets—including friendly pets.
- **Compact layout:** a movable 400 × 56 bar with independently toggleable information blocks.
- **Quiet while idle:** full opacity in combat, 60% with a target outside combat, and 20% without a target.

### Range colors

| Color | Meaning |
| --- | --- |
| Green | In ranged auto-attack range |
| Amber | In melee range |
| Orange | Confirmed too close for ranged auto attack |
| Red | Beyond ranged attack range or checked spell range |
| Blue | Estimated distance available, attack-range status unavailable |
| Gray | No target or unavailable range data |

Readings such as `~8–35 yd` are approximate spell-based brackets. Decimal yards
appear only when the client supplies validated numeric distance. Restricted
readings are hidden instead of guessed. Range and facing do not guarantee line
of sight or that an attack can fire. No combat actions are automated.

## Hunter setup

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`.
The internal folder and `ForeverUtilitiesDB` name remain stable so existing
Hunter's Friend settings migrate without being reset. The addon appears in WoW
as **Forever Classmate**. Restart for first installation, or use `/reload` after
an update.

Click the round minimap button or use `/fhunter` to open the current Hunter
settings. Drag the minimap icon around the map edge. The padlock at the right of
the bar toggles dragging without changing fading or live updates.

| Command | Action |
| --- | --- |
| `/fhunter` | Open Hunter settings |
| `/fhunter unlock` / `lock` | Move or lock the bar |
| `/fhunter scale 1.2` | Adjust size from 0.5 to 2 |
| `/fhunter on` / `off` | Enable or disable the Hunter companion |
| `/fhunter reset` | Restore Hunter defaults |
| `/fhunter status` | Show version and diagnostics |

`/futils` remains an alias. Every Hunter feature can be enabled independently.
The current runtime activates only on Hunter characters. Future class modules
will reuse the same addon installation and settings database.

## Class roadmap

Paladin is the next planned module, centered on seals, aura and blessing upkeep,
mana, facing, and melee range. Warrior, Rogue, Shaman, Druid, Mage, Priest, and
Warlock modules will follow. Features that depend on restricted or changing beta
data will stay hidden until their readings are reliable.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs;
live in-game validation remains ongoing.
