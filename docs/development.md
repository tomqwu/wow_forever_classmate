# Forever Classmate development

Active source: `addons/ForeverUtilities/`. The folder, TOC filename, saved-variable name, and release tag prefix remain stable for upgrades. Version 0.31.4 supports all nine classes through the registry in `Core.lua`.

The [November 1 API review](forever-api-review-2026-11-01.md) compares the October client changes with Classmate's call sites and records the gap between the latest public UI source (70532) and the installed `wowf` client (70707). The launch client uses `_forever_`; detect the active product before deploying rather than assuming the historical `_classic_beta_` folder.

Run `python3 scripts/install.py --wow-root '/mnt/f/World of Warcraft'` to install the checked source. It reads the active `wowf` entry from `.build.info`, selects `_forever_`, backs up changed existing addon files under `ClassmateBackups`, and verifies installed file bytes. It leaves SavedVariables and extra local files intact. A historical beta install requires `--client _classic_beta_`; a missing active launch client never silently selects another beta product.

The public [Forever addon guide](https://tomqwu.github.io/wow_forever_classmate/) is authored in `site/` and deployed by `.github/workflows/pages.yml`. Run `python3 scripts/check_site.py` before changing its links or sections. This documentation site is separate from the versioned addon package.

`Locale.lua` selects Simplified Chinese on `GetLocale() == 'zhCN'`; other locales use English. Addon-authored labels pass through `NS.L` at the UI boundary. Keep client-provided spell/unit names, saved-variable keys, and slash commands unchanged. Add a locale check for new visible English text, including dynamic counters and tooltips. Curated pet names and ability labels may still be English where the client cannot supply them. UI translation does not localize spell discovery: catalog matching must also work when the client refuses English spell-name lookup. Warlock armor has explicit Chinese aliases, with a regression that returns nil for unknown English names.

`ClassHost.lua` owns the shared movable 426 × 56 host, lock button, scale, and position. The 426-pixel rendered width matches Forever's default desktop Main Hand swing timer. Forever stores that preset as a 213-pixel offset above the 213-pixel slider minimum. `UI.lua` owns class-aware settings, minimap, commands, and initialization. Inactive class modules may initialize saved defaults but must not create frames, register events, or poll.

`LevelingBuffs.lua` supplies the sleeping bag and food reminders through `ClassHost.lua` with one shared event listener and aura scan. `foodXPReminder` is independent of `sleepingBagReminder`; either warning overrides fading. Food observes the visible Well Fed family because the XP effect is hidden; it never claims a measured multiplier. Numeric spell-ID queries resolve the localized food-family name, with English/zhCN fallbacks; unreadable or unclassifiable auras suppress absence warnings. See [food reminder sources and limits](food-xp.md). Every class exposes both reminder preferences (default on). Only levels 1–59 with a complete readable player aura scan outside combat may warn; a readable Well-Rested spell ID clears it regardless of stack count or localized name. The service owns its listeners, removes them when both reminders are disabled or at level 60, and does not add polling. Its small badge keeps the bar footprint unchanged, uses `Core.CreateWarningPulse`, and overrides idle fading only while confirmed missing. See [the exact aura IDs, sources, and limits](sleeping-bag.md).

`MailRecipients.lua` is a shared utility initialized after class preferences by `UI.lua`. The current class's `mailRecipients` preference controls it independently of the class bar. Records live in `ForeverUtilitiesDB.mail.characters` and `.recents`. Forever names contain a first name and surname: use `GetUnitName('player')`, with a readable two-part `UnitFullName` fallback, and obtain realm context independently. The tuple's second value is a surname. Never fabricate a name/realm mail address. Since 0.30.1, `mail.nameFormat=2` archives ambiguous 0.30.0 history under `.legacyRecents`, while old alts remain hidden until their complete identity is refreshed by login. Readable matching GUIDs replace the corresponding old character entry. It observes player logins, lazy-loads its UI beside public `SendMailFrame`, and fills only `SendMailNameEditBox` on a click. A guarded `hooksecurefunc` observes the recipient argument of the native `SendMail`; only `MAIL_SEND_SUCCESS` commits history, because Blizzard clears the edit box on success. Failures, cancellation, ambiguous overlapping attempts and secret recipients cannot create history. The service uses events without polling and removes its listeners when disabled; installed secure hooks remain inert. See [the pinned Forever mail source and test boundaries](mail-recipients.md).

The [November 3 class audit](class-audit-2026-11-03.md) records launch spell changes and the decisions for all nine helpers.

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

`Folded.lua` renders confirmed warnings through the shared class host. `ClassHost.SetWarning` receives upkeep state from the standard, Shaman and Hunter modules; the summary does not query or infer aura state. Leveling reminders publish their state independently of their full-bar controls. Since 0.31.6, up to four valid warning icons use a two-column grid of equal 32-pixel artwork with two-pixel gaps. The logical host, click target and outer shell fit the occupied rows: one warning is 32 × 32; two are 66 × 32; three or four are 66 × 66. The last row is centered. Warning artwork anchors directly to the logical host, avoiding extra canvas offsets. A warning needs both an explicit active flag and valid artwork; class upkeep supplies the actual missing group's icon rather than an earlier active group's art. Unknown or disabled warnings do not appear. With no confirmed warnings, neutral addon artwork serves as the expand control; its tooltip avoids claiming all buffs are active.

The full content is reparented into a hidden visual container, which removes its hit targets. The host forwards its existing OnUpdate callback only while the logical content frame remains shown, preserving countdowns without reviving death/world suspension. Multi-target DoT tracking suspends while collapsed. The old leveling controls hide while folded. The existing mouseover updater handles reveal; folding adds no aura polling or events. Warning pulses affect only the shared outline.

`ClassHost.lua` owns one top-level image-based shell (`BackdropTemplate` with native tooltip background/border assets). The logical host is inset four pixels. The compact shell adds four-pixel padding on all sides: 40 × 40 for one warning, 74 × 40 for two, 74 × 74 for three or four. With no confirmed warnings, the neutral 64 × 64 expand icon uses a 72 × 72 shell. The saved center anchor does not change when the frame resizes. Expanded dimensions remain 450 × 64 around the unchanged 426 × 56 bar plus an internal control rail. Movement, clamping and scale belong to the shell. Its background and image outline follow fading without double-applying alpha to child content. DoT sidebars anchor beyond the shell.
