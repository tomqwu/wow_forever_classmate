# Compact hunter bar layout

The bar remains 400 × 56 UI pixels before the user's saved scale. These are
visual groups inside one hunter addon, not a return to the generic module system.

## Blocks, left to right

| Block | Default horizontal bounds | Contents |
| --- | --- | --- |
| Range / supplies | 6–270 | Weapon icon; white one-line range; ammo directly underneath |
| Combat | 270–326 | Highlighted Mark icon above signed facing angle |
| Pet | 326–374 | Target-of-target portrait; red health border; small red/yellow mood badge; target pet-guide paw badge |
| Control | 374–394 | Small lock button |

Six pixels remain as outer padding. Subtle dividers mark block boundaries.
Range text starts at x=66 and has 196 pixels with all blocks enabled. It uses
16px type when possible, scaling to 12px for long readings without wrapping.
Ammo keeps its usual position unless a pet recommendation is shown. Disabling range removes its icon and moves supplies
left. Disabling combat, all pet displays (portrait, happiness, and pet guide), or lock returns that width to range/supplies.

Blocks are allocated from preferences, not transient warning state. Applying
Hunter's Mark or changing targets never shifts other icons or text. Combat icons
stay separate from pet health. Existing fading and movement settings apply to the
whole bar, including its lock button.

## Future additions (design only)

- Pet care belongs in the pet block. Health danger should outrank missing-pet,
  revive, and feeding notices; do not draw several competing borders.
- Combat reminders can use up to two small icon slots in the combat block.
  Use a deterministic priority (urgent defensive state, required debuff, aspect).
  Secondary details belong in a tooltip or settings, not extra permanent rows.
- Ammo remains in supplies; low ammunition changes its emphasis rather than
  creating another text row.
- New features require individual switches and should not expand the outer bar.
- Do not claim future pet-care or cooldown tracking exists yet.

Layout.lua centralizes the allocation rules. Tests exercise all 256 combinations
of range, mark, aspect, angle, portrait, happiness, pet guide, and control settings for bounds and overlap. Live
in-game font appearance should still be checked after /reload.

## Target pet guide

The recommendation is a FontString on the main indicator, just like range and
ammo. It does not depend on a floating panel or an off-frame child. On a matching
beast or player-owned pet, the range/supplies block uses three rows:

| Row | Top offset | Height |
| --- | --- | --- |
| Range | 3 | 20 |
| Pet recommendation | 23 | 16 |
| Ammo | 39 | 14 |

All rows fit in 56px, and use the block's existing text width. The recommendation
uses 11px gold text, shrinking down to 9px only for long family/ability names.
Wild targets above player level use red text. Rare and elite classifications prefix
the family. Full details, including role and named-beast locations, are in the
hover tooltip. The original range and ammo positions return when no hint applies.

The 18px guide badge stays at pet block x+3, y=-31 beside the happiness badge
at x+27. The guide has one switch for text, badge, and hover areas. Everything
inherits main-bar scale and fading, and the outside drag instructions remain
unobstructed. See [data sources](pet-guide-sources.md).
