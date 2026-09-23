## 0.21.13

- Keep the Shaman bar fully visible while a confirmed totem is active, including outside combat. It dims again when the last known totem expires or is removed.

Use `/reload` after updating.

## 0.21.12

- Shaman totems cast in combat now show a countdown after the addon has observed a readable duration for that exact learned spell. The `~` prefix marks it as estimated while Forever restricts live timing; a readable slot timer takes over when available.
- Learned durations persist across reloads. A totem with no readable duration yet continues to show its icon without a numeric guess.

Use `/reload` after updating.

## 0.21.11

- Replaced the large Earth/Fire/Water/Air placeholder letters with subdued totem icons on dark tiles. Thin colored edges still identify each element.
- Removed the redundant letter badges from active totems, weapon imbue, and shield; shield charges remain visible.

Use `/reload` after updating.

## 0.21.10

- Keep a previously readable Shaman totem icon and countdown visible when Forever hides live slot values in combat.
- Recognize the player's learned totem spellcasts during combat and clear observed casts on a later totem-removal event. Newly cast totems show no numeric timer until the client provides a readable one.
- Continue avoiding the Blizzard-only combat-log event that caused the blocked-action warning.

Use `/reload` after updating.

## 0.21.9

- Removed combat-log event tracking after Forever blocked the addon from a Blizzard-only action.
- When Forever reports an elemental reagent but an empty totem name and zero time, show the slot as unavailable instead of claiming zero active totems.

Use `/reload` after updating. Totems that Forever does not expose through its slot API remain unknown; the bar does not guess their active state or timer.

## 0.21.8

- Track your own totems from summon and removal combat-log events when Forever's totem-slot API reports an empty name and zero time for a visible totem.
- Show the tracked totem's icon and include it in the four-element count. Do not show an estimated timer when the client supplies none.

Use `/reload` after updating, then place a fresh totem so the addon sees its summon event.

## 0.21.7

- Detect active Shaman totems from their reported name or remaining time, including cases where Forever reports the first `GetTotemInfo` value as false.
- Keep empty and unreadable totem slots distinct so an Earthbind Totem can light the Earth cell and count toward the totem total when the client provides readable evidence.

Use `/reload` after updating.

## 0.21.6

- Replaced solid-colored Shaman totem, weapon-imbue, and shield tiles with dark cells and narrow status-colored stripes.
- Inactive totems now show a clear element letter without dim fallback art. Active totems still show their live icon and timer.

Use `/reload` after updating.

## 0.21.5

- Fit the Shaman helper text to its available width so the Totemic Recall hint stays readable beside the lock.
- Shorten the on-bar cue only when even the smaller font does not fit. The complete status remains available through `/fshaman status`.

Use `/reload` after updating.

## 0.21.4

- Aligned the Shaman totem and weapon/shield cells to the same 38-pixel size and top edge.
- Centered the helper icon on the same horizontal axis as the square cells and separators.

Use `/reload` after updating. The element, upkeep, helper, and lock groups now share a consistent vertical rhythm inside the 56-pixel bar.

## 0.21.3

- Replaced the Shaman bar's navy background and blue separators with a neutral dark surface so blue is no longer the only prominent visual.
- Added large element-colored E/F/W/A markers over inactive or unavailable totem slots, with brighter fallback art and distinct element borders.
- Active totems still replace their marker with the live icon and readable remaining time.

Use `/reload` after updating. The four element slots should remain recognizable even when Forever exposes no active totem state.

## 0.21.2

- Kept all four Shaman element cells visible as dim placeholders when no totem is active or Forever withholds the current slot state.
- Removed the large empty reserved area at the left of the Shaman bar while preserving honest unavailable-state handling and active totem timers.

Use `/reload` after updating. The placeholders identify Earth, Fire, Water, and Air without claiming an unreadable totem state is missing.

## 0.21.1

- Corrected every class bar to the 426-pixel rendered width of Forever's default desktop Main Hand swing timer.
- Fixed the Edit Mode interpretation: the stored desktop width value `213` is an offset added to the 213-pixel slider minimum, rather than the final frame width.
- Restored readable Hunter icons and text, full-size Shaman totem/upkeep groups, and five evenly distributed standard-class blocks across the corrected footprint.
- Preserved every feature toggle, position, scale, lock state, combat fade, and disabled polling behavior.

Use `/reload` after updating. Automated checks validate the 426 × 56 footprint and block bounds; final visual validation remains in the live Forever client.

## 0.21.0

- Matched every class bar to Forever's 213-pixel default desktop swing-timer width while retaining the existing 56-pixel readable height.
- Reflowed Hunter into compact range, combat, pet, and control blocks. Exact numeric yards stay visible; approximate classifications collapse to the useful range bracket when space is tight, and full pet details remain available on hover.
- Reflowed Shaman into a top row of four totems plus weapon/shield upkeep and a bottom row for the learned class cue and mana.
- Replaced the seven standard-class text blocks with five stable icon/status slots for resource, upkeep, target effect, learned ability, and racial state. Full names and exact details remain in tooltips.
- Preserved every feature toggle, movement, lock button, scale, fading, saved position, and disabled polling behavior.

Use `/reload` after updating. This release interpreted the stored Edit Mode width as the final frame width; version 0.21.1 corrects that conversion.

## 0.20.1

- Fixed Druid startup when the current-power API is unavailable and updated form detection for the current shapeshift API signature.
- Kept restricted aura, cooldown, and usability reads explicitly unknown instead of showing false missing or context warnings.
- Reworked upkeep into independent groups so Druid Mark/Thorns, Priest self buffs, and Rogue coatings plus Slice and Dice/Venom cannot hide one another.
- Made target-effect and learned-ability displays truly independent, and removed persistent Shadowform from temporary proc selection.
- Made racial selection state-aware so a ready active racial can replace one on cooldown; Priest racials still remain ahead of base racials and hover details list every learned racial.
- Compacted permanent block labels and moved full spell names and exact values into tooltips, preserving the 400 × 56 bar without clipped long names.

Use `/reload` after updating. Automated checks cover the reported failure paths; live validation is still needed on the Forever 1.60.1 beta client.

## 0.20.0

- Added production Paladin, Warrior, Rogue, Druid, Mage, Priest, and Warlock companions, completing support for all nine Forever classes while preserving the existing Hunter and Shaman modules.
- Added a shared 400 × 56 class layout for live resources, form/stance/combo context, class upkeep, target auras and procs, learned ability readiness, and active racial state. Every information block has its own setting.
- Added spellbook-discovered Forever mechanics including Twist of Light, Bloodthrill, Venom, Eclipse, Hot Streak, Fingers of Frost, Shadow Word: Death, Wrack, Banes, and other learned spec abilities without inferring a talent build.
- Added active racial discovery for the seven new class bars, including new Forever racials and all twelve race-specific Priest spells. Cooldown and usability come from the client; “Context” is shown when a learned off-cooldown ability is not currently usable.
- Added secret-safe shared readers for auras, resources, health, forms, combo points, dual weapon coatings, Soul Shards, spell cooldowns, and usability. Unavailable states are hidden instead of guessed, and the addon never performs an action.
- Added per-class databases and commands: `/fpaladin`, `/fwarrior`, `/frogue`, `/fdruid`, `/fmage`, `/fpriest`, and `/fwarlock`.

Use `/reload`, then `/fclassmate` or the active class command. Live validation is still needed on each class in the changing 1.60.1 beta.

## 0.19.0

- Added the Shaman companion: four live Earth/Fire/Water/Air totem icons with real remaining time, main-hand imbue state, elemental-shield state and stacks, mana, and a post-combat Totemic Recall hint.
- Added learned-spec cues: Maelstrom Weapon stacks up to five, Flame Shock timing when Lava Burst is learned, and the player's Riptide duration on a friendly target.
- Refactored movement, lock, scale, minimap, settings, commands, and class selection into shared services while preserving the Hunter bar, preferences, layout, and behavior.
- Every Shaman information block can be disabled independently. Inactive classes create no frames or polling; disabling every live Shaman block stops its timer polling.
- Guarded all new totem, enchant, aura, mana, spellbook, and target readings against unavailable or secret client values. No actions are automated.

Use `/reload`, then `/fshaman` on a Shaman. `/fhunter` continues to open the unchanged Hunter module on a Hunter.

## 0.18.0

- Rebranded the addon as **Forever Classmate**, the class-aware home for the current Hunter companion and future class modules.
- Added a new original compass-and-nine-gems logo for GitHub, CurseForge, the WoW addon list, and the movable minimap button.
- Updated the in-game title, settings heading, chat prefix, release copy, project summary, and publishing labels while retaining the `ForeverUtilities` folder, saved variables, tags, and existing Hunter settings.
- Reframed the project pages around what is available now: the complete Hunter toolkit. Paladin and other class modules are presented as a roadmap rather than shipped features.

Use `/reload` to load the new name and artwork. Hunter features and settings are unchanged.

## 0.17.0

- Expanded the offline guide to 70 rare pets from the Forever roster, including new Forever rares, with family, source zone, and wild-level details.
- Friendly and owned pets now recover rare-origin information through an exact English name plus live-family match. The Rake now displays as “Rare The Rake | Cat: Claw / Prowl” instead of only “Cat.”
- Hover details explain that controlled-pet identification is a name match, not proof of origin or current learned skills. Renamed pets safely fall back to family advice.
- Wild rare matching continues to use numeric NPC IDs and live classification; restricted identity values are not bypassed.

Use /reload, then target The Rake or another unrenamed rare pet.

## 0.16.3

- Pet recommendations now include friendly targets, your own pet, and other players' pets. The player-controlled exclusion no longer hides their family guide.
- The recommendation remains visible between range and ammo even when the range readout says “Friendly target.”
- Owned pets receive family/ability advice without wild-spawn locations, watch-list matches, or above-level taming warnings. The tooltip identifies a player-controlled pet.
- Missing or restricted ownership information still permits readable family advice without inferring tameability. Players, dead targets, and unsupported families stay excluded.

Use `/reload`, then select a friendly hunter pet.

## 0.16.2

- Moved the automatic pet recommendation directly into the main bar, using the same text-rendering path as range and ammo. The separate floating hint is removed.
- Supported wild targets show a gold line such as “Hyena: Tendon Rip”; rare/elite classifications appear before the family. Hover the line or badge for role, level, and known-beast locations.
- Range, pet intel, and ammo occupy three non-overlapping rows within the original 400 × 56 bar. Normal spacing returns when no hint applies.
- Kept independent toggles, combat fading, movable mode, and target-loss/death cleanup. Added the current pet-guide match to `/fhunter status` diagnostics.

Use `/reload`. The recommendation now appears between range and ammo, without hovering.

## 0.16.1

- Pet matches now show a compact two-line hint automatically above the bar; you no longer need to discover and hover the small badge.
- The hint shows family, useful family abilities, suggested role, level, and live rare/elite status. For example, a Hecklefang Hyena shows Hyena — Tendon Rip.
- Hover either the hint or badge for the full guide. These remain family recommendations, not a claim that the selected beast teaches that skill.
- The main bar remains 400 × 56. The attached hint follows its scale and fading, clears on target loss/death/disable, and uses the existing pet-guide toggle.
- Unlocked drag instructions move above the hint so they do not overlap.

Use `/reload`, then select a wild beast. No hover is required for the summary.

## 0.16.0

- Added an offline target pet guide with 19 family profiles and 21 named beasts.
- A small paw badge sits beside pet happiness in the existing pet block. Hover for family, useful family abilities, suggested role, level, and live rare/elite status; known beasts also show their watch-list location.
- Gold highlights named or special targets; red flags targets above your level. Ordinary family hints use blue. Weapon/range colors are unchanged.
- The guide has its own toggle and works with range or target-of-target displays disabled. The bar remains 400 × 56.
- Target changes, death, disable, and leaving the world clear the badge and its tooltip. Restricted or unavailable eligibility stays quiet.
- Documented beta data sources and limits: these are family recommendations, not guaranteed innate skills, skill ranks, tameability, or a universal DPS ranking.
- Settings now size their two columns and footer to fit the available options.

Use `/reload`, then `/fhunter` → Target pet guide / notable beasts.

## 0.15.0

- Added an optional pet mood badge: red for unhappy, yellow for content, hidden when happy.
- Works outside combat, without a target, and with the target-of-target portrait disabled.
- Updates on pet happiness changes and dismissal without adding idle polling. Dead pets and unavailable readings stay quiet.
- The badge uses the existing pet block; the bar remains 400 × 56. Hover for the feeding reminder.

Use `/reload`, then `/fhunter` for the Pet happiness warning toggle.

## 0.14.1

- The minimap button now uses the same lynx-and-bow logo as the GitHub project.
- Added the matching icon to WoW’s addon list.
- Bundled a game-compatible TGA texture; minimap dragging, position, and click behavior are unchanged.

Use `/reload` to load the new artwork.

## 0.14.0

- Added an independently toggleable missing-aspect icon, shown only in combat when no learned aspect buff is active.
- Any recognized learned aspect clears the warning; it does not force Hawk over other choices.
- Shares the combat block with Mark in two compact icon slots; the bar stays 400 × 56.
- Works without a selected target, updates on player aura changes, and stays quiet for dead players or restricted buff data.
- Aspect discovery currently recognizes English spellbook names beginning “Aspect of”; other locales remain quiet rather than guessing.

Use `/reload`, then `/fhunter` to configure the reminder.

## 0.13.3

- Hunter’s Mark reminder now appears only while you are in combat with a living enemy target selected.
- Entering/leaving combat updates the icon immediately; selecting enemies outside combat stays quiet.

Use `/reload` to apply the change.

## 0.13.2

- Left-drag the minimap icon around the minimap edge; its angle is saved between sessions.
- Respects minimap scale, and stops cursor tracking when released or hidden.
- Releasing a drag does not open settings; a normal click still does.

Use `/reload`, then drag the round icon to your preferred position.

## 0.13.1

- Replaced the square minimap spell button with a small round, gold-rimmed icon.
- Positions the button on the minimap’s outer edge using its actual size, instead of covering the map with fixed offsets.
- Keeps the existing click-to-open settings and visibility switch.

Use `/reload` to apply the minimap styling fix.

## 0.13.0

- Organized the unchanged 400 × 56 bar into range/ammo, combat reminders, pet, and lock blocks with subtle dividers.
- Mark icon sits above the angle in the combat block; pet health stays attached to its portrait.
- Blocks remain stable when warnings appear or disappear, avoiding text/portrait movement during combat.
- Disabling a block returns its space to the range block. Long range text scales within its own slot instead of overlapping ammo or icons.
- Existing feature toggles, position, scale, and fading are preserved.

Use `/reload` to apply the layout.

## 0.12.1

- Settings window is draggable by default using its title or background, without unlocking the hunter bar.
- Reopening settings retains its position during the session. Closing while dragging stops movement cleanly.

Use `/reload` to apply the update.

## 0.12.0

- Added an upper-right minimap button that opens Hunter’s Friend settings, even when the bar is disabled.
- Added a small padlock on the bar to toggle movement. Green means unlocked; tooltips explain the action.
- Added separate visibility switches for both buttons and arranged settings into two columns.
- Locking retains normal fading and live updates; the bar remains 400 × 56.

Use `/reload` to enable the new buttons.

## 0.11.0

- Replaced Hunter’s Mark wording with the learned spell’s icon and a bright gold border when missing.
- Added independent toggles for range, ammo count, low-ammo warnings, pet-health highlight, Mark reminder, and idle fading, alongside existing portrait/angle controls.
- Mark reminder and angle can now display together without enlarging the bar.
- Existing settings are preserved; new feature switches default on.

Use `/reload`, then `/fhunter` to choose features. Pet-health highlighting requires the portrait display.

## 0.10.0

- Added an orange “Hunter's Mark!” reminder for unmarked living enemy targets.
- Learns the spell from your spellbook instead of assuming a Classic spell ID.
- Any hunter’s mark clears the reminder; aura changes update it immediately.
- Stays quiet for friendly/dead targets, unlearned spells, and unavailable or restricted aura readings.
- Uses the secondary angle area while missing, keeping the compact bar and ammo readable.

Use `/reload` to apply the update.

## 0.9.0

- Highlights the target-of-target portrait with a red border when it shows your own pet at 30% health or below.
- Updates immediately on pet health changes and clears after healing, pet replacement, or target changes.
- Dead pets, other players’ pets, and restricted health readings do not trigger the reminder.
- Visual Mend Pet reminder only; no automatic spell casting.

Use `/reload` to apply the update.

## 0.8.2

- Unlocking the bar no longer forces full opacity; dragging keeps the same visibility and updates as locked mode.
- Full opacity in combat, 60% with a target outside combat, and 20% without a target outside combat.
- Combat events update visibility immediately, without adding idle polling.

Use `/reload` to apply the fix.

## 0.8.1

- Friendly targets without a distance reading show only “Friendly target”.
- Kept the main range text on one line so it cannot crowd the ammo line.
- Reclaimed the right-hand text space whenever the target-of-target portrait is absent.

Use `/reload` to apply the layout fix.

## 0.8.0

- Ammo turns red at 200 or fewer arrows/bullets.
- Shows a one-time low-ammo warning at the threshold, including if enabled with ammo already low.
- Does not repeat after each shot or target change; restocking above 200 rearms it.
- Unavailable readings do not reset the warning or create a false alert.

Use `/reload` to apply the update.

## 0.7.1

- Raised the ammo and angle line by 6 pixels, bringing it closer to the range text and away from the bottom edge.
- Keeps the original bar size and saved position.

Use `/reload` to apply the spacing adjustment.

## 0.7.0

- Rebranded as Forever - Hunter's Friend, focused exclusively on hunters.
- Removed the runtime module registry and toolbox selector; /fhunter opens one settings panel.
- Moved ammunition directly below the main white range text, with optional angle alongside it.
- Migrates existing flat or toolbox distance settings once into dedicated hunter settings.
- Non-hunter characters do not create the bar. /futils remains a compatibility alias.
- Kept the existing addon folder and saved-variable name for seamless upgrades.

Use `/reload`, then `/fhunter` for settings.

## 0.6.0

- Added a small ammo count near the right side of the compact bar, beside the portrait.
- Counts carried ammunition of the selected type, excluding bank storage.
- Inventory events refresh the count even without a target, without adding idle polling.
- Empty hunter ammo slots show a red zero; missing or restricted data clears the reading.

Use `/reload` to apply the update. The bar remains 400 × 56.

## 0.5.2

- Replaced target-of-target wording with a portrait on the right, opposite the weapon icon.
- Kept the compact bar and reclaimed central space for distance.
- Optional facing angle is now signed degrees only; unavailable readings are hidden.
- Portraits clear on target loss or API failure and refresh when the target’s target changes.

Use `/reload` to apply the update.

## 0.5.1

- Restored the original 400 × 56 distance bar footprint.
- Moved target-of-target (ToT) and angle into two compact lines on the right instead of adding rows below.
- Distance text uses the left column; disabling both context lines gives it the full available width.
- Preserves your position, scale, and feature settings.

Use `/reload` to apply the compact layout.

## 0.5.0

- Distance Checker now shows your target’s current target, with YOU when it targets you.
- Added a live horizontal facing angle: straight ahead, left/right degrees, or behind.
- Unavailable or restricted position/facing data displays “Angle unavailable”; no attack eligibility is inferred.
- Both new rows have independent toggles in the Distance Checker settings, and the indicator resizes to fit.
- Target changes, target loss, and unavailable data clear stale context. Disabled modules retain no update loop or event listeners.

Use `/reload`, then `/futils` to configure the rows. Angle readings depend on client data availability, particularly for enemies. Automated checks use mocked APIs; live gameplay validation is still needed.

## 0.4.0

- Added the shared utilities toolbox: open `/futils` to select and configure features.
- Distance Checker is now an independent module with its own enabled state, position lock, size controls, and reset button.
- Existing distance preferences migrate automatically into per-module settings.
- Disabled modules are not constructed at login. Disabling Distance Checker stops its updates and removes its event listeners.
- Existing `/futils unlock`, `lock`, `on`, `off`, `scale`, and `reset` commands remain available as distance shortcuts.

Use `/reload`, then `/futils` to open the toolbox. Only Distance Checker is included in this release; the module structure supports future utilities.

## 0.3.1

- Friendly targets without a usable distance reading now show “Friendly target — Distance unavailable” in neutral gray.
- The message uses two lines so it fits the indicator without shrinking the text.
- Available friendly-target distance readings continue to display normally.

Use `/reload` to apply the update.

## 0.3.0

- Shows a live decimal yard reading when the client provides a validated numeric target distance.
- Updates the displayed number every 0.15 seconds while a living target is selected, including friendly targets when supported.
- Retains spell-based brackets whenever numeric distance is unavailable; never invents an exact number or keeps a stale reading.
- Keeps attack-range colors independent of numeric distance, which can differ from combat reach.

Use `/reload`. Exact numeric readings are not guaranteed for enemy targets or restricted areas; `/futils status` reports availability.

## 0.2.1

- Fixed an out-of-range result remaining blue when Auto Shot metadata was unavailable and other spells supplied a bounded distance estimate.
- A confirmed negative ranged-attack check now shows red “Out of range,” even when too close versus too far cannot be determined.
- Added regression checks for the actual red icon border and accent colors.

Use `/reload`, then `/futils status` to confirm v0.2.1. Blue still means a distance bracket is known but no attack-range result is available.

## 0.2.0

- The indicator dims to 20% opacity when no target is selected.
- Selecting a target restores full visibility immediately; unlocking keeps the indicator visible for positioning.
- Out-of-range results remain red, with readable text on a dark panel.
- GitHub release notes and CurseForge build descriptions now include the maintained feature overview and version-specific changes.

Update with `/reload`. Your saved position and scale are preserved.
