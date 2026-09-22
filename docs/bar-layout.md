# Class bar layouts

Every class bar is 426 × 56 UI pixels before the user's saved scale. This is the
rendered width of Forever's default desktop Main Hand swing timer. Forever's Edit
Mode data stores slider offsets rather than final display values: the desktop
preset stores width `213`, and `ConvertValueDiffFromMin` adds the 213-pixel slider
minimum to produce a 426-pixel frame. The preset scale value `5` converts through
the 50% minimum and 10% step to 100%.

The source references are the current Forever
[desktop preset](https://github.com/Ketho/wow-ui-source-forever/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_EditMode/Mainline/EditModePresetLayouts.lua#L669-L727),
[setting conversion](https://github.com/Ketho/wow-ui-source-forever/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSettingDisplayInfo.lua#L8-L21),
and [swing-timer slider bounds](https://github.com/Ketho/wow-ui-source-forever/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_EditMode/Shared/EditModeSettingDisplayInfo.lua#L777-L830).

## Hunter

The Hunter bar allocates stable blocks from right to left according to enabled
preferences:

| Block | Default bounds | Contents |
| --- | --- | --- |
| Range / supplies | 6–296 | 38px weapon icon; range or exact yards; pet recommendation; ammo |
| Combat | 296–352 | Hunter's Mark and aspect icons; signed facing angle |
| Pet | 352–400 | Target-of-target portrait; mend border; mood and pet-guide badges |
| Control | 400–420 | Shared lock button |

The range block expands when combat, pet, or lock features are disabled. Full
range wording remains visible at the default width, and color still identifies
the attack state. The complete diagnostic remains available through
`/fhunter status`.

Pet recommendations stay between range and ammo. Their tooltip retains family,
ability, role, level, rare origin, and location details. Blocks depend only on
preferences, so applying Hunter's Mark or changing targets never shifts the bar.

## Shaman

The Shaman bar uses three readable groups across the same footprint:

- Four aligned 38px Earth, Fire, Water, and Air totem cells appear first.
- Main-hand weapon imbue and elemental-shield cells follow the totems.
- The learned Maelstrom, Flame Shock/Lava Burst, Riptide, or Totemic Recall cue
  occupies the right group, with mana below it.
- The shared lock button occupies the final 20px.

Timers remain on their icons, and full spell or state details remain in tooltips.
Disabling information still stops its reads and polling as before.

## Standard classes

Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock use five fixed slots
before the lock control:

| Slot | Bounds | Visible status |
| --- | --- | --- |
| Resource | 7–82 | Percentage plus form, combo, health, or shard state |
| Upkeep | 82–162 | Active/required count and missing or unknown state |
| Target | 162–242 | Own target-effect timer, stacks, missing, or unknown state |
| Ability | 242–322 | Proc stacks/timer or learned ability readiness |
| Racial | 322–398 | Best learned active-racial state |
| Control | 400–420 | Shared lock button |

Full localized spell names, exact resource values, every upkeep group, and all
learned racial states are shown on hover. Target and ability slots remain
independently toggleable. Restricted values use `?`; the addon does not turn an
unreadable state into a missing warning.

Movement, scaling, fading, and saved positions apply to the whole 426 × 56 bar.
Unlocking never changes live updates or combat opacity. Tests exercise all Hunter
preference combinations and each class lifecycle; live font and texture appearance
should still be checked after `/reload` on the current beta client.
