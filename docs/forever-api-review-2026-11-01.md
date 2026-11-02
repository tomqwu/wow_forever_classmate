# Forever addon API review — 2026-11-01

This review compares the APIs Classmate uses with newer Forever client documentation. The initial research did not establish live combat behavior. The follow-up compatibility fixes are recorded below.

## Evidence and version limits

- Installed product metadata in `F:/World of Warcraft/.build.info` lists `wowf` **1.60.1.70707**. The local `_forever_/Interface/AddOns/` folder exists. This is installed-build evidence, not a successful in-game test.
- The latest `forever` snapshot in Gethe's extracted Blizzard UI source is **1.60.1 build 70532**, commit [`ca8368f2f2380cbe696854f7f2646387c278a61b`](https://github.com/Gethe/wow-ui-source/commit/ca8368f2f2380cbe696854f7f2646387c278a61b), dated October 22 UTC. Ketho's `forever` resource branch also identifies build 70532. Neither source establishes that build 70707 has identical APIs.
- The comparison baseline is build **70124**, September 30, commit [`966519cf0ad2`](https://github.com/Gethe/wow-ui-source/commit/966519cf0ad2). The complete Git diff covers 37 generated API documentation files; the GitHub compare API's file list was capped, so this review used a local Git comparison.
- Blizzard's addon-author notes dated October 8 and 16 are [reproduced on Warcraft Wiki](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes). Their announcement text is distinguished below from independently inspected declarations. The original Discord messages were not independently retrieved.
- The official [development-notes thread](https://eu.forums.blizzard.com/en/wow/t/631316) includes October 26 racial changes and October 27 additions. General gameplay notes are not an API compatibility guarantee.

## October changes that matter

| Change | Evidence | Effect on Classmate |
| --- | --- | --- |
| `UnitUsesAmmo(unit)` added in build 70170, October 1 | [Unit API declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua) | A useful optional gate for Hunter ammo display and warnings. Current `AmmoCount()` checks the ammo slot and returns zero for a Hunter with no selected ammo; it does not consult this function. Probe it and test no-ammo weapons before changing that behavior. |
| `C_Spell.GetItemCooldown(itemID)` added in build 70170 | [Spell API declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua) | Returns a `SpellCooldownInfo` structure or nothing. Potential future item/consumable helper; it is not a reason to replace class-spell cooldown calls. The declaration's nil-case wording is ambiguous; validate semantics before relying on it. |
| `FrameStrata` becomes a secret aspect in build 70291, October 8 | [Frame API declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua) | `GetFrameStrata()` can return a secret value for affected frames. Classmate sets literal strata on its own frames and does not copy strata from Blizzard frames; no current call-site change identified. |
| `_Forever.toc`, `[Game]` and game-folder alias accepted alongside Camelot; Lua `require` renamed to `import` | October 8 Blizzard addon-author notes | Our plain `ForeverUtilities.toc` remains the stable package entry point. Classmate uses TOC ordering and the addon namespace, not `require`. No loader migration is needed for this addon. |
| Trial accounts lose addon-message sending; addon `EMOTE` sending outside instances requires a hardware event; minimap rotation access tightened during encounters | October 8 Blizzard addon-author notes | Classmate does not send addon messages/chat or read minimap rotation. Its minimap drag angle is cursor geometry, not map rotation. |
| Creature/pet/vehicle/game-object GUID server and spawn portions obfuscated in build 70425, October 16 | October 16 Blizzard addon-author notes | Treat the GUID as a session identity. Do not derive a layer or persist its obfuscated components as a stable identity. The notes say format stays unchanged and IDs remain stable within the session. Classmate's DoT deduplication compares whole GUIDs within the session; its pet guide prefers `UnitCreatureID` and extracts only the creature-ID component in its fallback. No server/spawn parsing is present. Recheck both behaviors in build 70707. |
| Vertical filtering for non-target nameplates; redesigned player/target/pet/target-of-target/totem/focus frames and minimap header | October 16 Blizzard addon-author notes; [client UI comparison](https://github.com/Gethe/wow-ui-source/compare/966519cf0ad2...ca8368f2f238) | The DoT strip only tracks current target and active nameplates, so vertically filtered non-target units will not supply rows. Continue clearing on nameplate removal. Classmate uses its own frames and the root Minimap, but minimap placement and native Inspect still need a live smoke test. |
| Group-buff entries gain `displaySpellID`; rank handling changes | [Cooldown Viewer declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/CooldownViewerDocumentation.lua), [aura declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua) | The group-buff `spellID` is a persistent key shared across ranks; `displaySpellID` chooses the known rank for display. Hidden/group-buff alert lists now include linked ranks, and their list-size constants rise from 32 to 128. This is useful if we integrate the native manager; it does not unrestrict arbitrary aura reads. |
| `GetPetCritChance`, `GetPetDodgeChance`, `GetGlancingBlowChance`, `GetGlancingBlowPenalty`, `GetOffhandHitModifier` added | [Player API declaration](https://github.com/Gethe/wow-ui-source/blob/ca8368f2f2380cbe696854f7f2646387c278a61b/Interface/AddOns/Blizzard_APIDocumentationGenerated/PlayerScriptDocumentation.lua) | Potential character/pet statistics displays. These are marked secret when unit stats are restricted. They do not enumerate an individual pet's learned abilities. |

## What did not change in the inspected declarations

Exact function/event blocks for the following are unchanged between builds 70124 and 70532:

- `C_UnitAuras.GetAuraDataByIndex`.
- `C_Spell.GetSpellCooldown`, `C_Spell.IsSpellUsable`.
- `UnitDistanceSquared`, `UnitPowerPercent`, `UnitGetTotalAbsorbs`.
- `GetTotemInfo`, `GetTotemTimeLeft`, `C_Item.GetWeaponEnchantInfo`.
- `UnitGUID`, `UnitCreatureID`, `LEARNED_SPELL_IN_SKILL_LINE`.

This establishes unchanged documented signatures/annotations, not unchanged server behavior. In particular, the GUID behavioral change was announced without changing the `UnitGUID` declaration. No inspected source or announcement establishes a general relaxation of combat aura, cooldown, resource, or hostile-distance restrictions. Keep unreadable status hidden and use only documented native renderers for secret values.

## Gameplay changes that affect helper data

Blizzard's [October 8 post](https://eu.forums.blizzard.com/en/wow/t/631316/5) extends the native Cooldown Manager to all classes, racials, and trinkets. Its [October 16 post](https://eu.forums.blizzard.com/en/wow/t/631316/6) consolidates spell ranks into a single manager entry. Prefer these supported data/display paths where appropriate; their availability does not make arbitrary combat logic readable.

The [October 26 racial pass](https://eu.forums.blizzard.com/en/wow/t/631316/7), amended [October 27](https://eu.forums.blizzard.com/en/wow/t/631316/8), changes Blood Fury to a two-minute cooldown, Berserking to a 15-second duration, and Touch of the Grave's internal cooldown to 15 seconds. Skyborne Read Leyline and Skysight have 15-second benefits with separate hour-long Attuned/Charged states. Classmate reads real cooldowns rather than storing these durations, which should accommodate the tuning. Do not turn a passive internal cooldown into an invented readiness cue.

One catalog question needs a client check: the official notes write **Read Leyline**, while our racial catalog contains **Read Ley Line**. This is a spelling mismatch, not proof of an actual spell rename. Confirm the readable spellbook name and add an alias if needed.

## Recommended follow-up

1. Smoke-test the actual build 70707: login and `/reload` persistence, all-class bar lifecycle, Hunter reach/ammo, Shaman totems, Mage mana/absorbs, minimap movement and Inspect, and nameplate removal above/below the player.
2. Feature-detect `UnitUsesAmmo` and test its readable true/false states before using it to gate Hunter ammo warnings.
3. Verify the Read Leyline spelling against the actual spellbook. Preserve semantic discovery rather than hardcoding the newer spell IDs.
4. Update deployment tooling to detect the installed `wowf` product and `_forever_` location. The historical `_classic_beta_` installation is not the installed launch client's AddOns folder. No files or saved settings were migrated as part of this research.

## Follow-up implementation — 0.25.1

The follow-up patch gates Hunter ammo reads on a readable true `UnitUsesAmmo` result when the function exists, adds both Read Leyline spellings to learned racial discovery, and adds `scripts/install.py` for active-product detection, addon backups and byte verification. Tests cover no-ammo weapons, restricted/missing eligibility, empty ammo, equipment updates, localized spell discovery, obfuscated session GUIDs, returning nameplates, and native minimap resizing without reading frame strata. These are mocked checks, not live build 70707 validation. Combat restrictions and native-data guards remain in place.
