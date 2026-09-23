# Shaman module research and behavior

Forever's Shaman still revolves around shared upkeep—totems, a weapon imbue, an elemental shield, and mana—but each deep tree adds a different decision cue. The addon therefore tracks reliable state rather than prescribing one fixed rotation.

## Workflow behind the helper

- **All Shamans:** Forever adds Call of the Elements variants, Totemic Recall, and Totemic Projection. Keeping the four element slots visible makes placement and expiration easy to read; the out-of-combat recall hint helps recover 25% of the spent totem mana and avoids leaving an aggressive totem behind.
- **Elemental:** Lava Burst gains 20% damage while the Shaman's Flame Shock is on the target. Fire Nova now casts from an active Fire totem. The bar tracks Flame Shock only when Lava Burst is learned; the Fire-slot tooltip explains Fire Nova's totem requirement without demanding a Fire totem in every single-target fight.
- **Enhancement:** Maelstrom Weapon stacks to five and affects Lightning Bolt in the current Forever design. The helper shows the readable live stack count and highlights five stacks; it does not recommend modern Chain Lightning or healing-spell spenders that this beta talent does not support.
- **Restoration:** Riptide is instant, leaves a 15-second effect, and improves Chain Heal cast directly on that target. Water Shield uses three orbs and returns mana. The helper shows the player's Riptide on the current friendly target and tracks the active elemental shield.

Research references:

- [Wowhead — Forever Elemental Shaman overview](https://www.wowhead.com/forever/guide/classes/shaman/elemental/overview-pve-dps)
- [wow.gg — Forever Enhancement Shaman changes](https://wow.gg/guides/shaman-enhancement-forever-overview)
- [wow.gg — Forever Restoration Shaman changes](https://wow.gg/guides/shaman-restoration-forever-overview)
- [Forever Shaman spellbook snapshot](https://wowforevertalent.com/abilities/shaman/)

These beta sources can change. Runtime capability discovery remains the authority for what the addon displays.

## Verified client APIs

The extracted Forever 1.60 UI source documents and uses:

- `GetTotemInfo(slot)` and `GetTotemTimeLeft(slot)` with `PLAYER_TOTEM_UPDATE`.
- `C_Item.GetWeaponEnchantInfo(Enum.WeaponSlot.MainHand)`; its `timeLeft` is milliseconds.
- `C_UnitAuras.GetAuraDataByIndex` for readable player and target auras.
- `C_SpellBook` and `C_Spell` for learned-spell discovery, names, and icons.
- `UnitPower` and `UnitPowerMax` for mana only when both values are readable.

Totem order follows the Blizzard Shaman priority: Earth, Fire, Water, Air. `GetTotemInfo`'s first value can represent elemental reagent ownership, so the addon identifies a summoned totem from a readable name or positive time remaining instead. It never infers missing state from a secret or failed scan. Numeric timers appear only from readable API durations. Inactive class modules create no frames and perform no polling; disabling all Shaman information switches also stops its timer polling.

Forever 1.60.1 has also been observed returning `true, "", 0, 0, 0` for `GetTotemInfo(2)` and `0` for `GetTotemTimeLeft(2)` while the player's Stoneskin Totem is visibly present. This is an unavailable active-state reading: the first return only confirms the elemental reagent. The bar shows `?/4 totems` when it cannot distinguish a summoned totem from an empty slot. Combat-log tracking was removed after the client blocked the addon from a Blizzard-only action; unknown states are not counted and no unverified timer is displayed.

During combat, totem-slot values can become secret. A totem that was readable before combat keeps its last known icon and counts down from its readable start and duration until expiry. For a newly cast learned totem, the addon uses the duration last read for that exact spell ID, including a duration saved from an earlier session. Its `~` timer is an estimate based on the player’s successful cast event, and a readable slot timer replaces it when available. With no learned duration, the icon appears without a numeric guess. `PLAYER_TOTEM_UPDATE` clears a later removal. This uses only player spellcast and totem-update events, not the blocked combat-log event. Fresh casts that cannot be identified from the spellbook remain unknown.

## Bar blocks

The bar uses Forever's 426-pixel rendered desktop swing-bar width and remains 56 pixels high before scale:

| Block | Contents |
| --- | --- |
| Totems | Four aligned 38px dark cells; subdued totem art and narrow colored stripes identify inactive slots, while active totems show a full-color icon and readable timer |
| Upkeep | Dark main-hand imbue and elemental-shield icons with narrow status-colored stripes; shield charges appear as a number |
| Helper | Maelstrom, Flame Shock/Lava Burst, Riptide, or recall cue; mana below |
| Control | Shared lock toggle |

Preference changes reclaim unused space; transient combat states never resize the outer bar. Combat restores full opacity, an out-of-combat target uses 60%, and idle uses 20%.
