# Forever Classmate workflow

Class-aware companion with independently maintained class modules. Active code stays in addons/ForeverUtilities/ for upgrade compatibility. Production support covers all nine Forever classes; preserve class-specific behavior and saved settings when changing shared services. Do not restore the retired swing bar.

Use verified Forever 1.60.x APIs. Respect secret values and missing APIs; never
present fabricated exact yards. Spell checks supply approximate brackets. A
failed minimum-range check can mean too close OR too far. Avoid hardcoded Classic
spell IDs and scan learned spells. Poll only while the matching class module is enabled and a live widget needs updates. Target-dependent widgets stop on target loss; timers stop on death, disable, and leaving the world.

Runtime modules use the addon's namespace, independent frame names,
ForeverUtilitiesDB, and /futils commands. Preserve Hunter and Shaman settings and their disabled lifecycles. No dependency on ForeverSwing or ForeverHunterRange.

## Delivery

For each fix/feature: implement, add meaningful checks, bump the TOC (patch fixes,
minor features), run python3 scripts/check.py and git diff --check, then build with
python3 scripts/package.py. Verify the ZIP root is ForeverUtilities/. Install the
same files in the known client's _classic_beta_/Interface/AddOns/ForeverUtilities
folder and compare bytes. Preserve unexpected local edits and live SavedVariables.
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
upload succeeded. Combat restores full visibility; the Shaman bar also stays fully visible for a confirmed active totem. Mage uses 90% opacity with a target and 75% while idle outside combat so the resource and armor remain readable. Other classes use 60% with a target and 20% while idle. Unlocking does not override fading.

Numeric distance uses UnitDistanceSquared only when checkedDistance is readable
and true and the squared value is finite/nonnegative. Never fabricate a midpoint
or use coordinates to bypass restrictions. Friendly targets may provide numeric
distance; enemy numeric readings are not guaranteed. Clear stale values promptly.

## Current class runtime and migration

Core.lua owns the class registry; ClassHost.lua owns shared movement, lock, scale, and position; UI.lua selects the active module and exposes `/fclassmate`, `/futils`, and `/f<class>`. Only the matching class may create a bar or poll.

Distance.lua owns Hunter defaults, migration, and lazy creation. `ForeverUtilitiesDB.hunter` migrates once from `modules.distance` or legacy flat settings. Ammo stays below the white range text in the 426 × 56 Hunter layout.

ShamanContext.lua owns secret-safe totem, temporary-enchant, aura, and mana reads. Shaman.lua owns spellbook discovery, defaults, event lifecycle, and its fixed 426 × 56 grouped layout. `ForeverUtilitiesDB.shaman` is independent. Track Earth/Fire/Water/Air totems, main-hand imbue, an elemental shield, mana, recall, and the learned Maelstrom/Lava Burst/Riptide cue. Never turn these cues into automated actions or unverified rotation claims.

ClassContext.lua and StandardClasses.lua own the Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock runtime. Each class has an independent database and a fixed resource, upkeep, target/ability, and active-racial block. Spellbook discovery controls class and racial availability. Preserve “Context” for learned abilities that the client reports unusable, keep Priest racial spells ahead of base racials, and never infer why an ability is unavailable.

## Bar layout

Layout.lua owns Hunter visual block allocation inside its fixed 426 × 56 bar. Shaman.lua owns the Shaman grouped allocation, and StandardClasses.lua owns the five fixed standard slots in the same outer footprint. The 426-pixel width is the rendered result of Forever's default desktop swing-timer preset: stored width offset 213 plus slider minimum 213. Keep range/ammo, combat reminders, pet portrait, and control separate. Blocks do not shift with transient warning state; only feature preferences redistribute width. See docs/bar-layout.md before adding information.

## Combat and warning review lessons

Read `docs/class-review-2026-09-23.md` when changing class, racial, or warning behavior. Keep unknown, absent, and ready states distinct. Preserve all API return positions before checking for secrets; a nil hole must not skip later returns. Do not classify short cooldowns as ready by a duration threshold. Recognize equivalent buff families and derived aura effects without turning them into learned cast actions. Suspend updates across queued events and settings refreshes while dead or outside the world. Disabled blocks must not query their hidden data. Confirm the loaded TOC version and compare installed bytes again after publishing: another process has replaced newer local files with an older release.

Keep cell backgrounds below icon artwork in explicit draw layers. Zero texture IDs are unavailable, and partial native totem fields must not overwrite usable observations. Merge slot reads through one path for polling and events; a different summon must not inherit the previous timer. Distinguish summoned lifetime from cast cooldown in UI copy and diagnostics. Regression mocks must reject removed events such as `LEARNED_SPELL_IN_TAB`.

Do not fill empty standard-class slots with the class icon: it can make one buff appear active in several unrelated blocks. Mage mana is text-only, the real armor icon belongs to upkeep, and target/ability icons appear only from their own readable state or learned spell. Keep Mage readable outside combat while retaining its fade toggle.
