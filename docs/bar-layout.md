# Compact class bar layouts

Every class bar is 213 × 56 UI pixels before the user's saved scale. The width
matches Forever's default desktop Edit Mode swing-timer preset. The separate
Forever gamepad preset is narrower and is not used because the class helpers need
room for several independent states. The pinned [Forever UI source](https://github.com/Ketho/wow-ui-source-forever/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_EditMode/Mainline/EditModePresetLayouts.lua#L669-L727)
defines the desktop swing-timer width as 213 pixels.

## Hunter

The Hunter bar allocates stable blocks from right to left according to enabled
preferences:

| Block | Default width | Contents |
| --- | ---: | --- |
| Range / supplies | 109px | 24px weapon icon; range or exact yards; pet recommendation; ammo |
| Combat | 36px | Hunter's Mark and aspect icons; signed facing angle |
| Pet | 38px | Target-of-target portrait; mend border; mood and pet-guide badges |
| Control | 20px | Shared lock button |

The range block expands when combat, pet, or lock features are disabled. With all
blocks visible, long range text collapses to its useful numeric or approximate
bracket, such as `23.4 yd` or `~8–35 yd`; color still identifies the attack state.
The complete diagnostic remains available through `/fhunter status`.

Pet recommendations stay on the bar. At narrow widths the text drops redundant
classification words before reducing font size; the tooltip retains family,
ability, role, level, rare origin, and location details. Blocks depend only on
preferences, so applying Hunter's Mark or changing targets never shifts the bar.

## Shaman

The Shaman bar uses two rows:

- The top row contains four 25px Earth, Fire, Water, and Air totem cells followed
  by compact weapon-imbue and elemental-shield cells.
- The bottom row contains the current Maelstrom, Flame Shock/Lava Burst, Riptide,
  or Totemic Recall cue, with mana aligned at the right.
- The shared lock button occupies the final 20px.

Timers remain on their icons, and full spell or state details remain in tooltips.
Disabling information still stops its reads and polling as before.

## Standard classes

Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock use five fixed icon slots
before the lock control:

| Slot | Bounds | Visible status |
| --- | --- | --- |
| Resource | 5–39 | Percentage plus form, combo, health, or shard badge |
| Upkeep | 39–73 | Active/required count and compact missing or unknown state |
| Target | 73–111 | Own target-effect timer, stacks, missing, or unknown state |
| Ability | 111–149 | Proc stacks/timer or learned ability readiness |
| Racial | 149–187 | Best learned active-racial state |
| Control | 187–207 | Shared lock button |

Full localized spell names, exact resource values, every upkeep group, and all
learned racial states are shown on hover. Target and ability slots remain
independently toggleable. Restricted values use `?`; the addon does not turn an
unreadable state into a missing warning.

Movement, scaling, fading, and saved positions apply to the whole 213 × 56 bar.
Unlocking never changes live updates or combat opacity. Tests exercise all Hunter
preference combinations and each class lifecycle; live font and texture appearance
should still be checked after `/reload` on the current beta client.
