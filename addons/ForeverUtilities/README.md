# Forever Classmate

<p align="center"><img src="assets/branding/forever-classmate-logo.png" width="256" alt="Forever Classmate — golden compass crest with nine class-colored gems"></p>

**Your class-aware companion for World of Warcraft: Forever.**

Forever Classmate detects the player class and loads only its matching helper. Version 0.19.0 ships complete **Hunter** and **Shaman** companions in separate modules, with shared movement, lock, scale, minimap, settings, and fading behavior.

## Hunter companion

- Colored range state and readable spell-based distance brackets.
- Live carried ammunition with a warning at 200 or fewer.
- Target-of-target portrait and optional facing angle.
- In-combat Hunter's Mark and missing-aspect reminders.
- Pet health, happiness, family advice, rare origins, and notable-beast information.
- Movable 400 × 56 bar; every information block can be switched independently.

Decimal yards appear only when the client supplies validated numeric distance. Restricted readings are hidden instead of guessed. Range and facing do not guarantee line of sight or that an attack can fire.

## Shaman companion

- **Four-element totem rack:** Earth, Fire, Water, and Air use the live totem icon and real remaining time from the Forever API.
- **Weapon upkeep:** the equipped main-hand icon shows its temporary imbue and remaining time; a learned imbue with none active turns red.
- **Elemental shield:** shows the active learned shield, remaining time, and readable orb count; the missing warning appears only in combat.
- **Spec-aware cue:** Maelstrom Weapon stacks for Enhancement, Flame Shock timing for a learned Lava Burst, or Riptide timing on the current friendly target.
- **Mana and recall:** optional mana percentage plus a quiet out-of-combat Totemic Recall hint while totems remain active.
- **Compact layout:** the same movable 400 × 56 footprint, with every Shaman feature independently switchable.

The module discovers learned spells from the live spellbook instead of assuming Classic spell IDs. Unavailable or secret values remain blank. It never casts, targets, dismisses a totem, or changes a rotation automatically. Research and behavior notes are in [the Shaman module guide](docs/shaman-module.md).

## Setup and commands

Install the `ForeverUtilities` folder into `_classic_beta_/Interface/AddOns/`. The internal folder and `ForeverUtilitiesDB` remain stable, so existing Hunter settings continue unchanged. Restart for first discovery or use `/reload` after an update.

Click the round minimap button or use the command for the active class. Drag the minimap icon around the map edge. The padlock at the right of either bar toggles movement without changing fading or updates.

| Command | Action |
| --- | --- |
| `/fhunter` | Open the Hunter settings on a Hunter |
| `/fshaman` | Open the Shaman settings on a Shaman |
| `/fclassmate` or `/futils` | Open settings for the current supported class |
| `<command> unlock` / `lock` | Move or lock the active bar |
| `<command> scale 1.2` | Adjust size from 0.5 to 2 |
| `<command> on` / `off` | Enable or disable the active class helper |
| `<command> reset` | Restore that class module's defaults |
| `<command> status` | Show version and live diagnostics |

Full opacity is used in combat, 60% with a target outside combat, and 20% while idle. Unlocking does not override fading. Hunter and Shaman settings are stored separately.

## Class roadmap

Paladin is planned next, centered on seals, aura and blessing upkeep, mana, facing, and melee range. Warrior, Rogue, Druid, Mage, Priest, and Warlock will follow as their Forever mechanics and addon APIs are validated.

Designed for the Forever 1.60.1 beta client. Automated checks use mocked APIs; live in-game validation remains ongoing.

[Project copy](docs/project-copy.md) · [Shaman research](docs/shaman-module.md) · [Pet guide sources](docs/pet-guide-sources.md) · [Developer guide](docs/development.md) · [Release history](docs/changelog.md)
