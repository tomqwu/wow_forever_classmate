# Forever Classmate development

Active source: `addons/ForeverUtilities/`. The folder, TOC filename, saved-variable name, and release tag prefix remain stable for upgrades. Version 0.25.0 supports all nine classes through the registry in `Core.lua`.

The public [Forever addon guide](https://tomqwu.github.io/wow_forever_classmate/) is authored in `site/` and deployed by `.github/workflows/pages.yml`. Run `python3 scripts/check_site.py` before changing its links or sections. This documentation site is separate from the versioned addon package.

`Locale.lua` selects Simplified Chinese on `GetLocale() == 'zhCN'`; other locales use English. Addon-authored labels pass through `NS.L` at the UI boundary. Keep client-provided spell/unit names, saved-variable keys, and slash commands unchanged. Add a locale check for new visible English text, including dynamic counters and tooltips. Curated pet names and ability labels may still be English where the client cannot supply them.

`ClassHost.lua` owns the shared movable 426 × 56 host, lock button, scale, and position. The 426-pixel rendered width matches Forever's default desktop Main Hand swing timer. Forever stores that preset as a 213-pixel offset above the 213-pixel slider minimum. `UI.lua` owns class-aware settings, minimap, commands, and initialization. Inactive class modules may initialize saved defaults but must not create frames, register events, or poll.

Hunter runtime:

- `TargetContext.lua` supplies facing, ammo, pet, aspect, and mark readings.
- `Range.lua` owns the Hunter display and active event/update lifecycle.
- `Distance.lua` owns Hunter defaults, migration, class registration, and lazy creation.
- Existing flat or `modules.distance` settings migrate once to `ForeverUtilitiesDB.hunter`.

Shaman runtime:

- `ShamanContext.lua` reads secret-safe totem, temporary-enchant, aura, and mana state.
- `Shaman.lua` owns Shaman discovery, its modular blocks, defaults, class registration, and event/update lifecycle.
- Shaman preferences live in `ForeverUtilitiesDB.shaman`; Hunter preferences are unchanged.

Standard class runtime:

- `ClassContext.lua` owns shared spellbook discovery, aura reads, resources, forms, combo points, temporary weapon coatings, item counts, cooldowns, usability, and the active-racial catalog.
- `StandardClasses.lua` registers Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock with independent databases and semantic spell catalogs.
- `DotTracker.lua` draws optional slim DoT timers for Warrior, Rogue, Druid, Priest, and Warlock. It reads only current target and active nameplate aura state, and drops observations on removal, expiry, world leave, or disable. It updates the changed unit on `UNIT_AURA` instead of polling every nameplate.
- The standard 426 × 56 strip uses fixed resource, upkeep, target, ability, and racial slots. Every slot is independently toggleable.
- Passive proc talents are accepted only when their catalog entry explicitly permits passive discovery. Passive racial bonuses are not displayed.

Use learned spellbook discovery and localized spell metadata. Never guess an exact timer, aura, resource, range, or specialization state when an API is absent or secret. No module may automate combat actions.

Run `python3 scripts/check.py`, `git diff --check`, and `python3 scripts/package.py`. Follow `AGENTS.md` for local installation, versioned GitHub releases, CurseForge receipts, synchronized descriptions, and file retention.

CurseForge publishing follows the [file retention policy](curseforge-retention.md). Cleanup requires the author dashboard; CI reports it as pending.
