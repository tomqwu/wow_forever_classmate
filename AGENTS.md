# Forever Classmate workflow

Class-aware companion with independently maintained class modules. Active code stays in addons/ForeverUtilities/ for upgrade compatibility. Production support covers all nine Forever classes; preserve class-specific behavior and saved settings when changing shared services. Do not restore the retired swing bar.

Use verified Forever 1.60.x APIs. Respect secret values and missing APIs; never
present fabricated exact yards. Spell checks supply approximate brackets. A
failed minimum-range check can mean too close OR too far. Avoid hardcoded Classic
spell IDs and scan learned spells. Poll only while the matching class module is enabled and a live widget needs updates. Target-dependent widgets stop on target loss; timers stop on death, disable, and leaving the world.

For new UI text, use `NS.L` from `Locale.lua` at the display boundary and add an English/Simplified Chinese locale check. Keep client-provided spell and character names, slash commands, and saved-variable keys unchanged. English is the fallback outside `zhCN`. UI localization does not localize learned-spell discovery. Test catalog aliases with a localized spellbook and nil results for unrecognized English spell-name queries; never assume those queries return translated metadata.

Runtime modules use the addon's namespace, independent frame names,
ForeverUtilitiesDB, and /futils commands. Preserve Hunter and Shaman settings and their disabled lifecycles. No dependency on ForeverSwing or ForeverHunterRange.

## Delivery

The static addon-writing guide lives in `site/` and deploys to GitHub Pages from `.github/workflows/pages.yml`. Run `python3 scripts/check_site.py` for site edits. Keep API advice sourced to the Forever client and distinguish documented signatures from beta observations. Site-only edits do not require an addon version bump or CurseForge upload.

For each fix/feature: implement, add meaningful checks, bump the TOC (patch fixes,
minor features), run python3 scripts/check.py and git diff --check, then build with
python3 scripts/package.py. Verify the ZIP root is ForeverUtilities/. Install the
same files in the requested/current client's Interface/AddOns/ForeverUtilities
folder and compare bytes. Detect the active product first: on 2026-11-01 `wowf`
is installed under `_forever_`; the historical installation is under `_classic_beta_`.
Preserve unexpected local edits and live SavedVariables.
Use `python3 scripts/install.py` for the local install; it detects the active
`wowf` product, backs up changed addon files, and verifies copied file bytes.
Never restart the user's game. Report unavailable installation explicitly.

Commit and push scoped changes to main, then verify CI and the GitHub release
asset. Tags are ForeverUtilities-vX.Y.Z; never overwrite existing releases.
Tooling/docs-only changes do not require a new addon version. The release checker
skips unchanged runtime versions and rejects runtime edits without a version bump.
Distinguish mocked tests from live game validation. Tell the user to restart WoW
for first addon discovery, or /reload for updates to an existing installation.

## Publishing boundary

The user explicitly requested reusing CurseForge project 1700438 for Forever
Utilities on 2026-09-18, superseding the earlier separate-project restriction.
Keep GitHub and CurseForge descriptions aligned with the shipped class modules and roadmap; never advertise an unfinished module as available. The
restored uploader accepts only ForeverUtilities-vX.Y.Z tags and standalone
ForeverUtilities ZIPs. Use CURSE_FORGE and CURSEFORGE_PROJECT_ID without reading
or exposing token values. Verify both release jobs and the upload receipt.
Never retry an uncertain upload POST before checking project Files.

CurseForge retention (user request, 2026-09-20): keep only the newest approved
version publicly available; archive older files after verifying the replacement
is approved and downloadable. Preserve the latest approved file during review.
Keep GitHub release history. The documented upload API has no archive/delete
operation: CI reports manual cleanup pending, it does not remove old files.
Use the author dashboard for cleanup; never claim an upload performed removal.
See docs/curseforge-retention.md for the publishing limitation and procedure.

Do not publish ignored addons.local.json entries or unrelated local files.

## Descriptions and release copy

Maintain docs/curseforge-description.md as the customer-facing overview. Keep the
root and packaged README aligned. Add exact-version highlights to docs/changelog.md
for every addon release. release_notes.py combines them for the GitHub release;
the CurseForge uploader uses that body as its file changelog. Project-page edits
are separate: do not claim the website description changed merely because an
upload succeeded. Combat restores full visibility; the Shaman bar also stays fully visible for a confirmed active totem. Standard-class bars stay fully visible for confirmed missing maintained buffs or weapon coatings outside combat. Unknown aura reads, missing temporary Rogue finishers, and missing pets do not override fading. Mage uses 90% opacity with a target and 75% while idle outside combat so the resource and armor remain readable. Other classes use 60% with a target and 20% while idle. Unlocking does not override fading.

Numeric distance uses UnitDistanceSquared only when checkedDistance is readable
and true and the squared value is finite/nonnegative. Never fabricate a midpoint
or use coordinates to bypass restrictions. Friendly targets may provide numeric
distance; enemy numeric readings are not guaranteed. Clear stale values promptly.

## Current class runtime and migration

Core.lua owns the class registry; ClassHost.lua owns shared movement, lock, scale, and position; UI.lua selects the active module and exposes `/fclassmate`, `/futils`, and `/f<class>`. Only the matching class may create a bar or poll.

Distance.lua owns Hunter defaults, migration, and lazy creation. `ForeverUtilitiesDB.hunter` migrates once from `modules.distance` or legacy flat settings. Ammo stays below the white range text in the 426 × 56 Hunter layout.

ShamanContext.lua owns secret-safe totem, temporary-enchant, aura, and mana reads. Shaman.lua owns spellbook discovery, defaults, event lifecycle, and its fixed 426 × 56 grouped layout. `ForeverUtilitiesDB.shaman` is independent. Track Earth/Fire/Water/Air totems, main-hand imbue, an elemental shield, mana, recall, and the learned Maelstrom, Riptide, Lightning Mastery, Stormstrike and Totemic Call cue. Never turn these cues into automated actions or unverified rotation claims.

ClassContext.lua and StandardClasses.lua own the Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock runtime. Each class has an independent database and a fixed resource, upkeep, target/ability, and active-racial block. Spellbook discovery controls class and racial availability. Preserve “Context” for learned abilities that the client reports unusable, keep Priest racial spells ahead of base racials, and never infer why an ability is unavailable. DotTracker.lua owns optional multi-target DoT sidebars for Warrior, Rogue, Druid, Priest, and Warlock. Read only current target and active nameplates; never extrapolate an offscreen aura. Clear on disappearance, expiry, world leave, and disable. Keep nameplate aura updates scoped to that unit.

## Mail recipient utility

`MailRecipients.lua` is a shared utility, controlled by the active class's
`mailRecipients` preference independently of its bar. Preserve account-wide
`ForeverUtilitiesDB.mail` character/history records. Learn alts only from observed
logins and filter them by realm/faction. Forever uses first name plus surname:
read the complete name from `GetUnitName`, with a readable two-part
`UnitFullName` fallback. The second tuple value is a surname, never a realm.
Read realm context independently. Preserve complete native recipient addresses;
do not split hyphens into supposed realm suffixes or fabricate missing surnames.
Keep incomplete 0.30.0 records out of suggestions until login refreshes them.
Fill the native recipient field only on a click. Observe
only the recipient argument with a guarded secure post-hook; commit recents only
on `MAIL_SEND_SUCCESS`, never on a draft edit or failed/cancelled attempt. Do not
read mail contents or call sending/transfer APIs. Native frames load lazily;
disable removes listeners and leaves existing hooks inert. See the pinned Forever
70862 source and lifecycle/secret handling in `docs/mail-recipients.md`.

## Minimap button tray

`MinimapTray.lua` (0.35.0) is a shared utility controlled by the active class's `groupMinimapButtons` preference (default true) and `showMinimap`. It borrows only children of `Minimap` that are named, unprotected `Button`s and look like addon launchers: `LibDBIcon10_*`, ForeverCore buttons (`minimapButtonSpec`), or names containing "minimap". Never borrow names starting with `Minimap`/`MiniMap`, listed Blizzard controls, unnamed map pins, protected frames, or Classmate's own buttons. Record each button's parent, every anchor and its drag scripts; clear drag scripts while borrowed and restore all of them on release. Borrow and release only out of combat; defer through `PLAYER_REGEN_ENABLED`. Owner `SetPoint` calls are answered by re-laying out the tray (secure post-hook, guarded while placing); hooks are installed once and inert after release. Left-click toggles the tray when active, otherwise opens settings; its first cell opens settings. The tray polls only while open (two-second away close) and closes on Escape or any borrowed click. Turning the option off or hiding the Classmate button returns everything.

## Bar layout

Layout.lua owns Hunter visual block allocation inside its fixed 426 × 56 bar. Shaman.lua owns the Shaman grouped allocation, and StandardClasses.lua owns the five fixed standard slots in the same outer footprint. The 426-pixel width is the rendered result of Forever's default desktop swing-timer preset: stored width offset 213 plus slider minimum 213. Keep range/ammo, combat reminders, pet portrait, and control separate. Blocks do not shift with transient warning state; only feature preferences redistribute width. See docs/bar-layout.md before adding information.

## Combat and warning review lessons

Read `docs/class-review-2026-09-23.md` when changing class, racial, or warning behavior. Keep unknown, absent, and ready states distinct. Preserve all API return positions before checking for secrets; a nil hole must not skip later returns. Do not classify short cooldowns as ready by a duration threshold. Recognize equivalent buff families and derived aura effects without turning them into learned cast actions. Suspend updates across queued events and settings refreshes while dead or outside the world. Disabled blocks must not query their hidden data. Confirm the loaded TOC version and compare installed bytes again after publishing: another process has replaced newer local files with an older release.

Keep cell backgrounds below icon artwork in explicit draw layers. Zero texture IDs are unavailable, and partial native totem fields must not overwrite usable observations. Merge slot reads through one path for polling and events; a different summon must not inherit the previous timer. Distinguish summoned lifetime from cast cooldown in UI copy and diagnostics. Regression mocks must reject removed events such as `LEARNED_SPELL_IN_TAB`.

The shared class host owns mouseover visibility. Hovering an enabled bar restores full opacity even while locked; leaving restores the module's saved combat/idle fade. Keep hover detection effective over child controls and stop it when disabled. Poll for hover only while collapsed, hovered, or rendered below full opacity; when fading resumes, read the pointer immediately. Locking prevents dragging but must not prevent mouseover.

Do not print an `active/total` upkeep count when any included aura is unavailable; `0/1` falsely implies the buff is absent. For Warlock armor, trust out-of-combat aura observations only. In combat, a dimmed last-confirmed Demon Skin/Armor/Fel Armor icon may identify the buff last seen, but must carry unknown current state and no active count or missing warning. Clear that identity on a readable out-of-combat absence, death, world leave, disable, or spell rediscovery. Do not treat a cached icon as evidence of a live aura.

Hide standard-class slots when the client cannot supply a meaningful live state. Never display `?`, `—`, or an empty target/ability/racial status as a tracking result. A remembered upkeep icon can remain dimmed without status text. Keep confirmed absence, ready, cooldown, and context states distinct; if the first learned cue or racial is unreadable, use another readable one. Preserve fixed slot positions when visibility changes.

Apply this to Hunter and Shaman too. Hide unreadable Shaman totem cells, totals, stacks, and readiness cues; keep confirmed inactive slots and observed casts. Hide Hunter range art/text when attack reach and numeric or bracket distance are all unavailable; the unlocked compact icon may remain neutral as a drag handle. Do not append “yards unavailable” to a confirmed attack state. Diagnostic commands and explanatory tooltips may identify a missing API, but the bar must not present it as live status.

Do not fill empty standard-class slots with the class icon: it can make one buff appear active in several unrelated blocks. The class crest (0.37.0) is the only class art inside standard bars: a bar-level 36 × 36 `frame.crest` at x 8 in the resource slot, replacing the old fixed class spell icon (which could read as a buff); it is never used as slot status. Standard-class slots: Resource 7–96 (text at 41), Upkeep 96–170, Target 170–244, Ability 244–320, Racial 320–398. Standard modules set `innerCrest`, so the frame art omits the outside clasp; Hunter and Shaman keep it. Show unusable learned abilities and racials as `Context`, never the abbreviation `Ctx`. Mage mana is text-only, the real armor icon belongs to upkeep, and target/ability icons appear only from their own readable state or learned spell. Keep Mage readable outside combat while retaining its fade toggle.

If exact UnitPower/UnitPowerMax values are restricted, use the documented UnitPowerPercent API for a readable percentage. Its uncurved value is a fraction; CurveConstants.ScaleTo100 returns 0–100. When the native percentage itself is secret, pass it directly to FontString:SetFormattedText with pcall and never inspect or calculate with that value. Do not present exact current/max numbers from a percent-only reading.

Mage uses a narrow native StatusBar for mana and a separate absorption meter when a learned Mana Shield or Ice Barrier aura is active. UnitGetTotalAbsorbs is the aggregate across all active absorb effects, not per-shield durability. Its meter is scaled to maximum health and labeled `% HP`; never call that the percentage of a specific shield left. The client does not expose the shield's original capacity. Native status bars and font strings may render secret numeric values directly, but addon Lua must not compare or calculate with them. Preserve the independent Mage shield toggle and armor details on hover.

Core.CreateWarningPulse owns gentle native alpha pulses on warning decorations, leaving icons/text readable. Every class exposes flashMissingBuffs; disabling it keeps the static warning. Only confirmed missing maintained buffs/coatings qualify; keep existing Hunter-aspect/Shaman-shield combat gating, and do not flash unknown reads, missing pets or temporary Rogue finishers. Stop animations on disable, hidden features, death/world exit and owner hide. Do not add polling solely to animate.

Collapsed presentation is owned by `Folded.lua` and `ClassHost.lua`. Keep confirmed warning decisions in the class/leveling services and feed `ClassHost.SetWarning`; the summary must not query or infer extra aura state. The host forwards existing content updates through a hidden visual container while collapsed, only while logical content remains shown. Do not revive dead/disabled/world-suspended content or expose hidden bar hit targets. Keep the class crest as the expand control, independent view/control toggles, original expanded geometry and saved positions.

Compact card (0.33.0): a 48 × 48 class crest (`Textures/Classes/<TOKEN>`) centered on top with an additive class-colored `Glow`, then an engraved `Divider`, then up to four 30 × 30 warning cells in one centered row with four-pixel gaps. One nine-slice `IconFrame` card (12px corners, class-color tint lifted toward white) surrounds everything; the crest breaks through its top edge (card starts 18px below the crest top). Each cell uses one template: bright amber-tinted `IconFrame` over a dark well, icon inset three pixels and cropped 0.08–0.92, so item art with or without a square background aligns. Card width is max(64, cells + 14); height 97 with warnings. With no warnings hide the card: only the 48 × 48 crest remains. Size the logical host, click target and shell to the card; verify cell bounds for zero through four warnings. Anchor crest, cells and divider directly to the logical host. Show only confirmed warnings with valid icons; upkeep artwork must belong to the missing group. The crest identifies the class only; it never represents buff state and never fills an empty expanded slot. Compact mode hides the expanded shell panel and outline. The shell anchors `TOP` so the crest center stays on the saved point (`ClassHost.Place`, `CompactCrestOffset` 28); compact drags save the crest center. Idle compact alpha has a 0.8 floor; warnings and hover are full. Each warning cell has a warm additive `CellGlow` halo (cell + 12, orange at 60%) on its own frame below the wells. The warning pulse animates only the cell frames (`edges`) and halos (`halos`), never icons, wells, card or crest; with flashing off the halo stays steady. More than four warnings show a `+N` count on the fourth cell. Class tint colors live in `Folded.ClassColors` and apply only to addon-owned art.

Combat auto-fold (0.34.0): per-class `autoFold` (default false, independent of `collapsed`). Register `PLAYER_REGEN_DISABLED`/`ENABLED` only while the class is enabled and `autoFold` is on; queued events after disable or opt-out do nothing. Combat start expands, combat end folds, both through `ClassHost.SetFold` → `module.Apply` so dependents refresh like a click. Login/world entry and switching the option on sync once from `UnitAffectingCombat`; an unreadable result leaves the view alone. Manual clicks override until the next combat transition. View changes play one-shot native transitions owned by `ClassHost` (`CreateTransition`): shell fade 0→1 with scale 0.9→1 when expanding or 1.12→1 when folding, plus an additive class-colored `Glow` flare at the crest or across the bar. No polling; stop and hide on disable and shell hide; no animation on first show or re-enable. Guard missing animation APIs (both `SetScaleFrom` and `SetFromScale` names).

Class art comes from the author's ForeverHUD project (`tomqwu/wow_forever_weakaura`, `assets/ai`). Re-import with `python3 scripts/import_class_art.py`; it box-filters the exported TGAs (crests and frame to 64 × 64, divider to 256 × 16), converts the frame and divider to greyscale for runtime class tinting, and generates the radial crest glow and rounded-square warning halo. It never redraws the art.

The shared image-based shell in `ClassHost.lua` owns expanded frame artwork, padding, movement, scale and clamping. Compact shell sizes: crest only 56 × 56; one warning 72 × 105; two 86 × 105; three 120 × 105; four 154 × 105. Expanded shell: 450 × 64 with a 426 × 56 content area and internal control rail; without the collapse button the rail is removed (434 × 64), centered on the saved point. The collapse button is a plain glyph with a localized tooltip, not a templated button border. Frame art uses the content's rendered alpha (`ClassHost.ContentAlpha`), including leveling-reminder full brightness. Expanded bars warm the outline for confirmed warnings without pulsing it. Expanded frame art (0.36.0): `ClassHost.CreateFrameArt` draws the class-tinted nine-slice `IconFrame` around the expanded shell above its content (frame level +20), a 40 × 40 crest with glow clasping the left edge (center 10px outside, full bars only; hidden in collapsed and Hunter icon-only views) and a dark `shellFill`. `SetWarm` swaps the tint to amber for confirmed warnings. Modules keep their own fills and layout; `Core.EngraveDivider` turns their 1px separators into 6 × 42 engraved dividers anchored to the original line, `Core.IconFrame` adds neutral frames that mirror icon visibility, and `Core.StyleWarningFrame` turns solid warning squares into amber (or red for pets) `IconFrame`s with a `CellGlow` halo, stepping a neutral cover frame aside while shown. Pulses still animate the original warning texture. Leveling reminders show as 22px amber cells packed right-to-left in a tab 10px above the host's top-right; Hunter icon-only keeps them beside the icon. Never stack another decorative border on the card or the expanded frame. Apply fading to frame art without double-fading child content.

Native layout-cache lesson (0.31.7): old movable named class hosts can have anchors and dimensions in per-character `layout-local.txt` even after a new anonymous shell takes over. Keep the inset host non-movable, opt both host/shell out of native saving with `SetDontSavePosition(true)` and clear `SetUserPlaced(false)`. The shell's position comes only from the existing per-class SavedVariables. Reapply after login/world-entry restoration while enabled; unregister those listeners when disabled. Test stale restored anchors/sizes as well as first-creation geometry. Do not delete live layout caches or reset user preferences to address this bug. Native `SetUserPlaced` throws on a frame that is neither movable nor resizable (live 0.31.7 error): clear it while movable, then restore movability. Test mocks must enforce that rule.
