## 0.44.1

- Slot spacing on the Paladin, Warrior, Rogue, Druid, Mage, Priest and Warlock bars is rebuilt. Each slot is now a small card: the icon and its state ("Ready", "2/2", a timer) on the first row, and the name on its own row across the whole slot, so "All active", "Blood Fury" and similar names are no longer cut off.
- The resource slot is sized to what the class shows: wide enough for the Warlock shard count or the combo pips (the count no longer runs into the next slot), narrower for a single stance/form icon, and narrowest for a mana meter alone. The other four slots share the remaining width evenly.
- Slot order is now Resource, Upkeep, Ability, Racial, Target. The target slot is last, so a bar with no target no longer has an empty hole in its middle. Slots still never move during play.

Use `/reload`. Automated checks use mocked APIs; still needs in-game confirmation.

## 0.44.0

- The mail panel's **Alts** list now shows each alt's class crest, its name in class color, and its level and gold. Hover a row for "Level 60 Mage" and the gold balance, both as of that character's last login.
- The Alts heading shows the total gold of the character you're on plus its alts on the realm.
- Class, level and gold are saved for each character when you log in, level up or your money changes. Alts you haven't played since this update show just their name until you log into them once.
- Only each character's own balance is stored; mail contents and the gold you send are never read.

Use `/reload`. Automated checks use mocked APIs; still needs in-game confirmation.

## 0.43.0

- Cooldown timers are gone from the bar, since the game's Cooldown Manager already shows them. The ability slot shows a proc or a learned ability that is **Ready** (or **Context** when the game reports it unusable), and the racial slot shows a racial that is ready. An ability or racial on cooldown simply leaves its slot empty until it is ready again. The Shaman helper no longer counts down Riptide or its other cues either.
- Cooldowns are still read, so a cooling-down spell is never shown as ready.

Use `/reload`. Automated checks use mocked APIs; still needs in-game confirmation.

## 0.42.0

Everything left from the full design and class review:

**Chinese clients**
- Spell tracking now works on Simplified Chinese clients for every class. Each spell and aura the addon watches carries its Chinese name, taken from the Forever client's own spell table (no spell IDs are built in, so it still only tracks what you've learned).

**Class coverage**
- **Paladin:** your aura is tracked (a missing aura warns), and blessings and Righteous Fury are named when missing without waking the bar.
- **Warrior:** Sunder Armor, Thunder Clap, Demoralizing Shout and Hamstring on the target; Enrage and Flurry procs; Bloodrage and Berserker Rage cues.
- **Rogue:** your Deadly, Wound, Crippling and Mind-numbing Poison on the target, plus Expose Armor. A sharpening stone now reads as a weapon coating instead of a poison.
- **Druid:** combo pips in Cat Form. Omen of Clarity is upkeep, and its Clearcasting proc shows in the ability slot.
- **Mage:** Arcane Blast stacks, Arcane Concentration's Clearcasting, and Fire Vulnerability from Improved Scorch. An active Mana Shield or Ice Barrier no longer hides a missing-armor message.
- **Priest:** Shadowform shows even when the game doesn't report it as a stance; Shadow Protection upkeep; Inner Focus cue.
- **Warlock:** Nightfall's Shadow Trance proc, every curse, Siphon Life and Unstable Affliction on the target and the DoT bars, and a Demonic Sacrifice buff counts in place of your demon.
- **Hunter:** Aspect of the Cheetah or Pack left on in combat is a warning. Hunter's Mark and an unhappy pet now also appear on the compact card.
- **Shaman:** a dual-wielded off-hand weapon without an imbue warns (shields never do), and the shield's last charge shows in red.

**Improvements**
- New commands: `fold`, `expand`, `autofold on|off` and `tray on|off`.
- **Reset settings** in the panel asks for a second click.
- The settings panel fits the default screen height.
- The Shaman bar updates only while a timer is counting; between fights it no longer runs four times a second.
- The compact card redraws only when something on it changes.
- Hover checks pause during loading screens.
- Minimap buttons returned from the tray keep their original frame level.
- A mail attempt that never got a result is dropped when you reopen the mailbox.

Use `/reload`. Automated checks use mocked APIs and the Forever client's spell table; Chinese-client tracking and the new class cues still need in-game confirmation.

## 0.41.1

Fixes from a full design and class review:

- **Shaman:** a Shaman who hasn't learned an elemental shield yet no longer gets a "shield missing" warning in every fight. When exact mana is restricted, the mana display now falls back to the game's readable percentage instead of disappearing.
- **All standard classes:** abilities and racials no longer flash a 1-second cooldown after every cast. The game's own global-cooldown flag now keeps a ready ability showing "Ready".
- **Warrior and Druid:** a missing Battle Shout, Commanding Shout or Thorns between fights is still named on the bar, but no longer keeps the bar bright, pulsing and amber.
- **Upkeep icon:** the upkeep icon now always matches the first missing buff it names. Previously another, active buff's icon could appear next to "Missing / Fortitude".
- **DoT side bars:** these no longer keep showing a DoT that was removed while that enemy was your target.
- **Death fold:**
  - A fold you choose yourself is never undone when you revive.
  - Clicking the crest while dead no longer opens an empty bar; it expands when you are alive.
  - Dragging a locked crest no longer expands it.
- **Bar frame:** when the bar has nothing to show (the Hunter icon-only view without a target, for example), its frame, collapse glyph and mouse area are hidden too.
- **Compact card:** the `+N` count of extra warnings no longer fades with the warning pulse.
- **Hunter range:** a confirmed Shooting or Melee reading is kept when two range checks disagree (only the yards are dropped). A single failed short check, such as melee, now gives a lower bound like "Distance | >5 yd" instead of claiming "Out of range".
- **Minimap tray:** with no other addon buttons to group, hovering the Classmate button shows its normal tooltip again. The tray's hint offers right-click inspect only while that option is on.
- **Leveling reminders:** these now listen to your own aura changes only, not every unit's.

Use `/reload`. Automated checks use mocked APIs; these fixes still need in-game confirmation.

## 0.41.0

- The resource slot on standard class bars is now visual instead of text. A slim vertical meter shows your power in its own color: blue mana, red rage, yellow energy (the Druid meter follows the current form). Beside it, Warlocks see the Soul Shard icon with a count (red at zero), Rogues see five combo pips, and Warriors, Druids and Priests see their stance or form icon. "100%", "3 combo" and the stance name are gone from the bar; exact values and names are in the tooltip.
- A percentage the game keeps restricted still fills the meter, drawn by the game itself; the addon never reads or prints that value.

Use `/reload`. Automated checks use mocked APIs; meter colors and icons still need in-game confirmation.

## 0.40.1

- While you're dead or a ghost, the folded crest takes on a spirit look: the crest fades to a pale blue-grey inside a soft spirit glow that slowly breathes in and out, in place of the usual class-colored glow. It returns to normal the moment you're alive again. This also applies when you had already folded the bar yourself.

Use `/reload`. Automated checks use mocked events and animations; the glow still needs in-game confirmation.

## 0.40.0

- When you die, the expanded bar now folds down to your class crest instead of leaving an empty frame. It expands again once you are resurrected or back in your body. A card you folded yourself stays folded, and with **Fold outside combat, expand in combat** on, revival follows that setting. Logging out while dead still restores the bar next time.
- Refreshed the CurseForge and README descriptions for the current design: engraved bar, compact card and class stat, combat auto-fold, minimap button tray, and named slot text.

Use `/reload`. Automated checks use mocked events; death and spirit-release behavior still needs in-game confirmation.

## 0.39.0

- The compact card has a class stat slot: the one number each class watches most. Hunter shows ammo, Warlock soul shards, Shaman Ankhs (once Reincarnation is learned), Mage conjured water (every rank added up), and Rogue the shortest poison time left. Paladin, Priest and Druid show mana %, and Warrior shows health %.
- The stat sits first in the card's row in a neutral frame, ahead of any warnings, and never flashes. Zero shards, water or Ankhs and low ammo show in red. With a stat showing, up to three warnings fit, and the last one counts the rest. The card now also appears for the stat alone. Turn it off with **Show class stat in compact card**.
- Hovering the Classmate minimap button now opens the addon tray. Left-click goes straight to Classmate settings again, and right-click still inspects your target.
- Soul shards are now counted by item ID, so the count also works on Chinese and other non-English clients.

Use `/reload`. Automated checks use mocked APIs; item icons and counts still need in-game confirmation.

## 0.38.0

- Slots now name what they show instead of repeating their own label. The bottom line is the target effect, the ready ability, or your racial (for example "Ready / Overpower", "12s / Rend", "Ready / Will to Survive"). Ability tooltips are titled with the spell name.
- Upkeep names what matters. A missing buff reads "Missing / Thorns" (with "+1" when more are missing) instead of "!1". A single active buff shows its time and name ("28m / Seal of Command") instead of "1/1 OK". Several active buffs read "2/2 / All active".
- Resource lines read naturally: "3 combo" instead of "CP3", "5 shards" instead of "H80/S5" (player health stays in the tooltip), and your real stance or form name instead of "Form" or "Base". Nothing is shown when no form is active or the game doesn't report one.
- Rogue poisons are tracked per weapon: "Missing / Off-hand poison", or the poison that expires first when both are coated. The tooltip lists each hand.
- Warlock upkeep shows demon health ("Demon 80%") when armor and demon are both up.
- Shaman imbue charges appear on the weapon cell, and an imbued off hand is listed in its tooltip. The off hand never warns, because it may hold a shield.
- Shaman's "MW 3/5" is spelled out as "Maelstrom 3/5", and Hunter's bare "+12°" now reads "12° left" or "12° right".

Use `/reload`. Automated checks use mocked APIs; in-game text fit still needs confirmation, especially long spell names in narrow slots.

## 0.37.2

- The class crest now sits exactly half inside the full bar's left edge, like it breaks through the compact card's top edge.
- Each class's first content moved 10px right to make room: Hunter's range icon and text, Shaman's first totem, and the standard resource text (and Mage's mana meter). Range text still shrinks its font to fit when needed. Slot boundaries are otherwise unchanged.

Use `/reload`. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.37.1

- The class crest sticks out from the full bar's left edge again, now for every class and a little larger (44px), matching how the crest breaks out of the compact card. It stops just short of the first slot.
- Standard class bars keep the 0.37.0 fix: no duplicate class spell icon inside the bar. The resource slot is text only.
- Slots return to their original even widths: Resource 7–82, Upkeep 82–162, Target 162–242, Ability 242–322, Racial 322–398. "Context" stays spelled out.

Use `/reload`. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.37.0

- Standard class bars (Paladin, Warrior, Rogue, Druid, Mage, Priest, Warlock) now lead with your class crest inside the bar. It replaces the old fixed class spell icon in the resource slot, which duplicated the crest and could be mistaken for an active buff. The crest no longer also hangs outside the frame for these classes. Hunter and Shaman keep the outside crest because their first slot shows live range or totem state.
- Slots are rebalanced so the crest and resource text share the first slot: Resource 7–96, Upkeep 96–170, Target 170–244, Ability 244–320, Racial 320–398. Slots still never shift during play.
- Abilities and racials the client reports unusable now read **Context** in full instead of the abbreviation "Ctx".

Use `/reload`. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.36.0

- The expanded bar now matches the compact card. It uses the same engraved frame, tinted in your class color, with your class crest clasping its left edge, in place of the plain tooltip border.
- Engraved dividers replace the thin grey separators, and slot icons sit in matching engraved frames.
- Warnings use the amber frame and ember halo everywhere: missing armor and other upkeep, Hunter's Mark and aspect, and Shaman imbue and shield cells. Pet warnings stay red. The whole frame warms to amber while a warning is confirmed.
- Food and sleeping bag reminders moved out of the cramped corner by the lock into a small tab of amber cells above the bar's right end.
- Slot positions, the 426 × 56 bar size, warning rules and settings are unchanged.

Use `/reload`. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.35.0

- New: **Group addon minimap buttons** (on by default, per class). Other addons' minimap buttons move into a framed tray behind the Classmate button, so it is the only icon around the map.
- Left-click Classmate to open the tray. The first cell opens Classmate settings; the rest are your addon buttons in name order, with their own clicks and tooltips. The tray opens toward the screen center and closes on a click, Escape, or two seconds away.
- Only named, unprotected addon launchers are collected (LibDBIcon, ForeverCore and similar). Blizzard minimap controls, map pins and protected frames are never touched, and buttons only move outside combat. Buttons an addon shows, hides or re-places later are kept in the tray.
- Turn the option off, or hide the Classmate minimap button, to return every button to its original position with its own dragging restored. Right-click Inspect is unchanged.

Use `/reload`. Automated checks use mocked LibDBIcon, ForeverCore and hand-made buttons; the tray still needs confirmation with your installed addons in game.

## 0.34.0

- New option for every class: **Fold outside combat, expand in combat** (off by default). Entering combat expands the full bar; leaving combat folds it back into the compact card.
- View changes now animate. Expanding bursts the bar out with a class-colored flare across it; folding drops the card in with a flare blooming around the crest. Manual clicks get the same effect.
- A click still overrides the automatic view until the next time you enter or leave combat. If the client cannot confirm your combat state, the view stays as it is.
- The option listens for combat only while it is on and the class bar is enabled. Animations are native, one-shot effects with no extra polling, and stop when the bar is disabled or hidden.

Use `/reload`. Automated checks use mocked frames and animations; in-game rendering still needs confirmation.

## 0.33.1

- Warnings are easier to spot in the compact card. Each warning cell now has a warm ember halo and a brighter amber frame.
- With Flash missing buffs on, the halo breathes together with the cell frame; with it off, the halo stays steady. Icons, wells, the card and the crest never flash.
- The halo appears only for confirmed warnings and disappears with the card when there are none.

Use a full game restart: this release adds a new texture file. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.33.0

- The compact view is now a single framed card. A larger 48 × 48 class crest sits on top, breaking through the card's upper edge with a soft class-colored glow. An engraved divider separates it from the warning cells below.
- One engraved frame surrounds the crest and the warnings, tinted in your class color (bronze Warrior, blue Mage, violet Warlock, and so on). Each warning keeps its own amber frame, dark well and inset icon.
- With no warnings, the card disappears and only the glowing crest remains.
- The crest stays exactly where you placed it; the card grows below and around it. Saved positions carry over.
- Flash missing buffs still pulses only the warning cell frames.

Use a full game restart: this release adds new texture files. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.32.0

- The compact view is now a single strip with a painted crest for your class at the left. The crest stays visible outside combat (idle opacity never drops below 80%), so the folded bar no longer looks empty or anonymous. It identifies the class only; it does not claim any buff is active or missing.
- Warnings use one shared cell template: an engraved frame around a dark well with the icon inset. Food and sleeping bag art, with or without its own square background, now lines up with every other icon.
- Warnings appear in one row to the right of the crest. The crest stays where you placed it as warnings come and go; it no longer jumps between a large logo and a grid.
- Removed the dark background panel and outer outline behind the compact strip.
- Flash missing buffs now pulses only the cell frames, never the icons themselves.
- Crest and frame art come from the author's ForeverHUD project, downscaled to 64 × 64.

Use `/reload`. Saved positions are kept: the crest appears centered where the compact frame was. Automated checks use mocked frames; in-game rendering still needs confirmation.

## 0.31.8

- Fixed a Lua error on login in 0.31.7: `Frame:SetUserPlaced(): Frame is not movable or resizable`. The client rejects that call on a non-movable frame, which stopped the class bar from being created. The native placement flag is now cleared while the frame is movable, then the inset host is made non-movable again. Test mocks now enforce the client rule and reproduce the original error.
- Frame art now fades with the bar's actual opacity. A sleeping bag or food reminder no longer leaves bright contents inside a faint frame.
- The collapse control is a plain `<` glyph on the shared outline, without a second button border, and has a tooltip. Hiding it removes its empty 16-pixel rail (434 × 64 instead of 450 × 64).
- More than four folded warnings keep the four-icon frame; the fourth icon shows a `+N` count of the hidden ones, and the tooltip still lists every warning.
- The expanded frame outline turns amber for confirmed warnings, without a second pulse on top of the in-bar warning.
- Hover checks now run only while the bar is collapsed, hovered or faded, instead of ten times a second whenever the class is enabled.

Use `/reload`. Automated checks use mocked APIs; in-game rendering still needs confirmation.

## 0.31.7

- Fixed a second position owner left over from the pre-container implementation. Native `layout-local.txt` records for the named class host could restore it away from the anonymous shell, leaving warning icons outside their border.
- Disabled native position saving and cleared user-placed state on the shell and inset host. Only the shell can move; position remains owned by existing SavedVariables.
- Reapply the layout at player login/world entry after native startup restoration. Disabled helpers unregister those listeners and ignore queued events.
- Added regression cases using the old Warlock and Mage layout records observed locally. They check restored inset anchors, compact dimensions, preserved saved coordinates and disabled lifecycle. Warning eligibility and visual design are unchanged.

Use `/reload`. Automated checks simulate native layout restoration; live rendering still needs in-game confirmation.

## 0.31.6

- Removed the fixed square warning canvas that left unused space above and below a single row of reminders. The image-based frame and its click area now fit the visible rows, with four-pixel padding.
- All warning icons are 32 × 32. One or two reminders use one row; three or four use two rows, with the final row centered. Artwork anchors directly to the inset logical host; only the outer shell clamps to the screen.
- The neutral 64 × 64 expand logo remains when there are no confirmed warnings. Saved center position, expanded bar size, warning eligibility, independent toggles and outline flashing are preserved.
- Regression checks now measure occupied artwork bounds and frame dimensions for zero through four warnings, instead of merely checking that icons fit inside a large canvas.

Use `/reload`. Automated checks use mocked APIs; actual frame rendering still needs in-game confirmation.

## 0.31.5

- Corrected folded warning presentation: food, sleeping bag and class upkeep use equal 28 × 28 icons in a centered two-column grid. Food no longer becomes oversized main artwork while other reminders shrink underneath it.
- The compact image-based frame is now 72 × 72 with no empty footer. Its neutral Classmate logo appears only when there are no confirmed warnings and acts as the expand button; it makes no class-buff status claim.
- Fixed upkeep warning artwork when an earlier buff is active and a later buff is missing. The summary now uses the missing buff's icon, and never substitutes unrelated class artwork for unavailable warning art.
- Kept independent toggles, level limits, combat restrictions, hover reveal, full brightness for warnings and optional outline flashing. Added regressions for all four Shaman reminders, independent clearing, restricted reads, combat transitions and neutral EN/zhCN tooltip text.

Use `/reload`. Automated checks use mocked APIs; actual in-game rendering still needs confirmation.

## 0.31.4

- Replaced the patchwork folded borders with one actual image-based container shared by compact and expanded views. It uses native WoW tooltip frame artwork, one translucent background, and consistent four-pixel padding.
- Compact mode contains the main icon and warning row inside a 72 × 96 frame. Expanded mode contains the unchanged 426 × 56 bar and an internal collapse control inside a 450 × 64 frame. The control no longer floats outside the container.
- Movement, scaling and screen clamping now apply to the shared container. Its background and outline follow fading; warning pulses affect only the image outline. Cropped icon artwork reduces nested decorative borders.
- DoT sidebars anchor outside the container's control rail. Mail data, warning eligibility and class settings are preserved. Added compact/expanded container size regressions.

Use `/reload`. Automated checks use mocked APIs; actual frame rendering still needs in-game confirmation.

## 0.31.3

- Unified the folded main icon and secondary warnings under one continuous outline. The lower section is directly attached beneath the artwork, with no separate black strip or added solid backdrop. The main image remains unobscured.
- Reserved a 64 × 88 footprint for the combined control. When no secondary warnings exist, the outline shrinks to the 64 × 64 main icon without moving it. Existing click, drag, fade and warning behavior is preserved.
- Removed redundant class names from resource/ability hover labels and the class slash command from the movement hint; useful resource values, spell names and warnings remain.
- Added layout checks for the connected lower section and shared outline, plus Chinese localization for the generic resource tooltip.

Use `/reload`. Automated checks use mocked APIs; live rendering still needs confirmation.

## 0.31.2

- Moved extra folded warnings into a separate row six pixels below the main icon. The main 64 × 64 artwork stays fully visible, with no warning strip or icons covering it.
- Secondary icons are 20 × 20 with two-pixel spacing. The folded host reserves 64 × 94 pixels so the complete row stays within screen clamping. The row shares expand, hover and drag behavior with the main icon and hides when there are no additional warnings.
- Added layout regressions for the separate row, gap, icon spacing, and reserved footprint. Existing warning logic, fading, expanded layout and preferences are preserved.

Use `/reload`. Automated checks use mocked APIs; live client rendering still needs confirmation.

## 0.31.1

- Reworked the cluttered collapsed icon shown in the user screenshot. The highest-priority confirmed warning now uses large native spell/food artwork; additional warnings form one bottom row. With no confirmed warnings, the icon shows class artwork.
- Removed the oversized branding crest, solid red warning background, and floating corner controls. Only a one-pixel amber outline pulses; icons remain readable. Collapsed drag instructions are available on hover instead of sitting above the icon.
- The 64 × 64 footprint, click-to-expand, saved position, fading, warning toggles and existing warning eligibility remain intact. Added regressions for warning priority, secondary layout, thin outlines and suppressed old controls.

Use `/reload`. Automated checks use mocked APIs; live rendering still needs confirmation.

## 0.31.0

- Added a saved collapsed view for every class: a 64 × 64 Classmate icon with confirmed class upkeep badges on the left and food/sleeping-bag reminders on the right. Existing warning eligibility and unreadable-data rules are preserved.
- Click the small < control beside the expanded bar to fold it, and click the large icon to expand. Added Collapsed warning icon and Show collapse button preferences, with English/Simplified Chinese labels. Dragging the icon respects the existing lock setting.
- Missing warnings keep the icon bright and follow Flash missing buffs. Hover reveals an idle icon. The hidden full bar has no invisible hit targets; its existing updater remains live through the host while enabled and unsuspended. DoT sidebars suspend until expanded.
- Expansion restores the original class layout and scale. Class positions, warning toggles, and mail recipient records are preserved.

Use `/reload`, then click < beside the bar or enable Collapsed warning icon in `/fclassmate`. Automated checks use mocked APIs; live rendering still needs confirmation.

## 0.30.1

- Fixed missing surnames in the mail sidebar and recipient filling. Forever's complete name comes from GetUnitName; its UnitFullName tuple contains first name and surname, with realm context read separately.
- Alts sharing a first name stay distinct by their full names. Recent recipients preserve the exact successful native address, and hyphens are no longer split as supposed realm suffixes. Full names can wrap within the unchanged panel rows.
- Incomplete 0.30.0 alt records stay hidden until each alt logs in again; a matching readable GUID replaces its old record. Ambiguous old recent strings are retained in legacyRecents, outside the active list, rather than inventing a missing surname. Existing class settings are preserved.
- Added regressions for full English/Chinese names, separate surname tuple results, restricted surnames, duplicate first names, and migration from 0.30.0.

Use `/reload`, then log into each alt once to refresh its full name. Automated checks use mocked APIs; live client confirmation is still needed.

## 0.30.0

- Added a compact recipient panel beside native Send Mail, with Alts and Recent recipients visible together. Click a name to fill the recipient field; right-click to forget its saved entry. Each list has five rows and pagination.
- Logged-in characters are remembered in account-wide saved variables. Alts show other recorded characters on the current realm and faction, with readable realm IDs preventing same-name realm mixups and whole player GUIDs updating observed renames. Log into each alt once with Classmate enabled to register it.
- Recents retain the newest 20 successfully sent recipients per sending realm/faction, shared across your characters. The original recipient argument is captured before the native success handler clears its field. Failed/cancelled or ambiguous sends and restricted recipient values do not create history. Explicit cross-realm recipients keep their realm suffix.
- Added Mail recipients: alts and recents in English/Simplified Chinese settings for every class, independent of the class bar. Mail subjects, bodies, items, and amounts are not stored; selection fills the field and leaves sending to the normal game action.
- Mail integration loads lazily, uses no polling, hides in combat and outside the native Send Mail tab, and removes listeners when disabled. Existing class bars, leveling reminders, and saved preferences are preserved.

Use `/reload`, then open a mailbox and select Send Mail. Automated checks use mocked APIs; live client rendering and event behavior still need confirmation.

## 0.29.0

- Added an independent Food XP buff reminder (below level 60) for all nine classes. Levels 1–59 see a small food icon outside combat when a complete readable scan confirms Well Fed is absent; level 60 and above never warn.
- The food icon clears when Well Fed is observed. The XP effect is hidden, so this is a food-buff reminder rather than a measured XP multiplier; its tooltip recommends food explicitly granting +5% XP from kills. Client-resolved localized names and English/Simplified Chinese aliases recognize different Well Fed ranks.
- Sleeping bag and food reminders now share one event listener and aura scan. Either keeps the bar bright and follows Flash missing buffs. Their icons fit above/below the lock or beside Hunter's compact range icon without resizing the bar.
- Combat, death, world exit, disabled features, and unreadable aura data clear affected warnings. Both disabled removes listeners; reaching level 60 retires tracking even while queued events still see the previous level. Existing sleeping bag preferences are preserved.

Use `/reload`, then `/fclassmate` to configure the independent reminders. Automated checks use mocked APIs; live client behavior still needs confirmation.

## 0.28.0

- Added an independently toggleable sleeping bag reminder for all nine classes, strictly for character levels 1–59. Level 60 and above never warn.
- A small Cozy Sleeping Bag icon appears outside combat only when a complete readable aura scan confirms the actual Well-Rested buff is missing. Any active stack clears it; ordinary rested XP and the separate Legacy Well Rested effect do not satisfy it.
- The reminder keeps the bar fully visible and uses the existing Flash missing buffs preference for its pulsing border. It keeps the bar size unchanged and sits beside the Hunter range icon in compact mode.
- Combat, death, world exit, restricted aura reads, and disabled tracking clear the reminder. The service is event-driven, removes listeners at level 60 or when disabled, and adds English/Simplified Chinese settings and tooltips.

Use `/reload`, then `/fclassmate` to configure it. Automated checks use mocked APIs; live client behavior still needs confirmation.

## 0.27.0

- Confirmed missing maintained buffs pulse their warning border using a gentle 1.3-second native animation. Warlock armor, other standard-class upkeep, weapon coatings, Hunter aspects, and Shaman shields/imbues share the behavior. Icons and text stay readable.
- Added the independent Flash missing buffs setting (缺少增益时闪烁) for every class; disabling it keeps static warnings. A confirmed missing Shaman weapon imbue now also restores full bar opacity outside combat.
- Pulses stop when a buff returns, the data becomes unreadable, the feature or addon is disabled, the bar hides, the player dies, or the player leaves the world. Existing combat-only warning rules are preserved; missing pets and temporary Rogue finishers do not flash.

Use `/reload` after updating. Automated checks use mocked animation and game APIs; verify the appearance in the live client.

## 0.26.1

- Fixed Warlock armor discovery on Chinese clients when English spell-name lookup returns no metadata. Learned Demon Skin, Demon Armor and Fel Armor can now be recognized by their Chinese names without hardcoded spell IDs.
- A confirmed missing Warlock armor buff now shows Armor / Missing (护甲 / 缺失) with a red border and full bar opacity outside combat, including when demon existence is unavailable. Applying armor clears the warning; restricted reads do not invent missing status.
- Added regressions for English and localized-only armor discovery, warning clearing, combat restrictions, independent demon state, and the upkeep toggle.

Use `/reload` after updating. Automated checks use mocked APIs; live client confirmation remains necessary.

## 0.26.0

- Audited all nine classes against Blizzard’s November 3 Forever launch notes. Replaced retired Paladin, Rogue, Druid and Shaman cues with learned launch abilities, including Unsealed Wrath, Shank, Primal Bite and Lightning Mastery. Venom is a temporary proc; it no longer counts as Rogue upkeep.
- Added selected readable effects and cooldowns to existing class slots: Garrote, Death Mark, Rake, Lacerate, Reckless Swings, Slam, Missile Barrage, Penance, Amplify Curse, Stormstrike and Totemic Call. Existing layouts and settings carry forward.
- Corrected the bear, boar, carrion bird and bat family guide entries to match Blizzard’s Forever overview. Pet guide entries remain family guidance, not evidence of an individual pet’s skills.

Use `/reload` after updating. Checks use mocked APIs; live launch-client aura names and combat restrictions still need validation.

## 0.25.1

- Hunter ammo counts and low-ammo warnings now respect `UnitUsesAmmo` when the client exposes it. No-ammo weapons and unreadable eligibility hide the ammo reading; clients without the API retain the existing ammo-slot fallback. Equipment changes refresh this immediately.
- Skyborne racial discovery accepts both Read Leyline and Read Ley Line, including client-resolved localized names, and continues using the actual learned spell's cooldown.
- Added a local installer that detects the active `wowf` product and `_forever_` folder. Historical beta deployment is explicit; existing addon edits are backed up and SavedVariables are preserved.
- Added regressions for obfuscated GUID session identities, NPC matching, nameplate disappearance/reappearance, and minimap resizing without reading secret frame strata.

Use `/reload` for an existing installation; a newly installed addon may require normal first discovery when the client next starts. Checks use mocked APIs and temporary installation folders; live build 70707 combat behavior still needs in-game validation.

## 0.25.0

- Added Simplified Chinese (`zhCN`) interface text selected from the WoW client locale. Hunter range, target and ammo labels; class bars; settings; warnings; pet guidance; and tooltips now use a shared locale lookup. English remains the fallback for other locales.
- Added a localized TOC title and description. Client-provided spell and character names remain native; curated rare-pet data may still contain English names. Saved settings and slash commands are unchanged.

Use `/reload` after updating. Automated checks use mocked APIs; confirm the live Chinese client layout in game.

## 0.24.5

- Hovering any enabled class bar now reveals it at full opacity, including a locked bar and Hunter's movable compact icon. Live updates keep the bar bright under the pointer; leaving restores its combat or idle fade.
- The shared host checks hover across child controls and stops checking when the addon is disabled. Locking still prevents dragging.

Use `/reload` after updating. Automated checks use mocked APIs; confirm mouseover behavior in the live beta client.

## 0.24.4

- Applied the unreadable-state rule to Hunter and Shaman too. Unreadable totem slots, totals, Maelstrom stacks, and spec cues no longer occupy the bar as question-mark or generic status indicators. Confirmed active or inactive totems and event-observed casts still display.
- Hunter hides an unsupported range readout. The locked compact icon disappears when reach cannot be verified; unlocked it remains available as a neutral drag handle. Confirmed attack reach no longer adds a “yards unavailable” suffix when no yard estimate exists.

Use `/reload` after updating. Automated checks use mocked APIs; confirm the live beta appearance in game.

## 0.24.3

- Standard-class bars now hide unavailable target-effect, ability, racial, and resource readings instead of showing question marks or empty placeholders. Confirmed missing effects and readable cooldowns still display.
- A previously confirmed Warlock armor icon can remain dimmed in combat as an identity cue, but carries no status text or inferred active count. When one learned cue is unreadable, the bar can show another with a confirmed state.

Use `/reload` after updating. Automated checks use mocked APIs; confirm the live beta appearance in game.

## 0.24.2

- A confirmed missing maintained buff or weapon coating now keeps the standard-class bar fully visible outside combat, so its upkeep warning is readable. The bar returns to its saved fade once the upkeep is confirmed or the block is turned off.
- Unknown or restricted readings do not trigger this visibility change. Missing temporary Rogue finisher buffs do not keep the bar bright between fights; missing demons remain separate from missing buffs.

Use `/reload` after updating. Automated checks use mocked APIs; the live beta appearance still needs in-game confirmation.

## 0.24.1

- Warlock armor now uses out-of-combat aura checks. During combat, a previously confirmed Demon Skin, Demon Armor, or Fel Armor icon stays dimmed in the upkeep slot with unknown current status; the addon does not claim it remains active. A later readable absence clears that remembered identity.
- Standard-class upkeep counts disappear whenever any included aura is unavailable, so restricted combat reads no longer render a misleading `0/1` or other partial ratio. Verified missing states remain distinct from unavailable states.

Use `/reload` after updating. Regression checks use mocked Forever APIs; confirm the combat appearance in the live beta client.

## 0.24.0

- Added optional slim multi-target DoT bars beside the unchanged 426 × 56 main bar for Warrior, Rogue, Druid, Priest, and Warlock. They show the enemy, learned player-owned effect, and readable time remaining for the current target and active nameplates.
- Removed effects, expired timers, departed nameplates, restricted timings, and disabled settings clear their rows. Updating one unit's aura avoids rescanning all other enemies.

Use `/reload` after updating. The client cannot provide persistent offscreen aura state; automated tests use mocked APIs, and live beta rendering remains to be checked.

## 0.23.0

- The Classmate minimap button now supports right-click to open WoW's native Inspect window for an eligible targeted player, for every class. Left-click still opens settings; dragging still moves the button.
- The shortcut works while the Hunter uses icon-only range mode, so Inspect no longer requires the full bar. A separate per-class setting can disable the minimap Inspect shortcut. The existing optional Hunter full-bar Inspect button remains available.

Use `/reload` after updating. Client eligibility still determines whether the player can be inspected; tests use mocked APIs.

## 0.22.0

- Added a Hunter icon-only range mode. The 42-pixel icon turns green when ranged reach is confirmed, red when it is confirmed unavailable, and neutral when the client cannot decide. It hides with no valid hostile target when locked; `/fhunter unlock` keeps it visible for positioning.
- Added an optional Hunter Inspect button for inspectable player targets. It opens WoW's native Inspect window on click.
- Pet hints now identify family guidance without presenting an ability as learned by the selected beast. Spider Web is no longer listed without verification; rare-name matches on owned pets are labeled as possible origins.

Use `/reload` after updating. Automated checks use mocked APIs; live client rendering and pet facts still need beta verification.

## 0.21.19

- Replaced the Mage resource slot’s redundant Mana label with a compact vertical meter next to the live mana percentage. Restricted native percentages can still drive the meter without addon arithmetic.
- Learned Mana Shield or Ice Barrier now highlights an active shield, showing the client’s total absorb amount and a slim meter for absorption relative to maximum health. The armor state stays in the tooltip, and the shield display has its own toggle. The coverage percentage is not the fraction of that specific shield remaining; the client does not expose its original capacity.

Use `/reload` after updating. Automated checks use mocked APIs; live beta-client rendering still needs confirmation.

## 0.21.18

- Mage and the other standard classes can display a readable resource percentage when Forever restricts exact current or maximum power. When only a restricted native percentage is available, the value is sent directly to the client's font renderer; the addon does not perform arithmetic on it or invent exact values.
- Resource tooltips state when exact values are unavailable. Mana stays labeled even when the numeric reading is restricted.

Use `/reload` after updating. The screenshot case is covered by mocked API tests; the live beta client still needs confirmation.

## 0.21.17

- Mage stays readable outside combat: 75% opacity with no target, 90% with a target, and full opacity in combat. The existing fade toggle still enables or disables this behavior.
- The Mage resource slot now labels mana directly. Frost Armor artwork remains in the armor upkeep slot; empty target and ability slots no longer repeat it. Learned target and ability icons still appear when they have relevant information.
- Standard class slots use their full text width when no icon is present. No learned racial shows a text-only placeholder instead of the class icon.

Use `/reload` after updating. Automated checks use mocked client APIs; visual validation in the beta client remains necessary.

## 0.21.16

- Put Shaman cell backgrounds on a lower draw layer so they cannot cover active totem, imbue, or shield icons. Zero/invalid icon IDs now use available spell or weapon art instead of a blank texture.
- Preserve a totem's observed icon and countdown when Forever returns partial native data, including on combat exit. Handle cast success arriving before the slot updates, keep remaining-only timers counting, and discard old timing when another totem replaces it.
- Totem tooltips explicitly identify the remaining lifetime. This is separate from the spell's cast cooldown: Stoneclaw has a 15-second lifetime and a 30-second cooldown.
- Includes the Mage/all-class learned-spell event correction from 0.21.15, with startup tests that reject the removed `LEARNED_SPELL_IN_TAB` event.

Use `/reload` and check `/fclassmate status` for 0.21.16. Automated validation uses mocked APIs; live rendering and beta API behavior still need in-game confirmation.

## 0.21.15

- Reviewed all nine class helpers and the shared racial catalog. Corrected short cooldowns falsely reported as ready, nil-hole secret-value guards, malformed aura/weapon readings, base-spell overrides, and standard spell-rank selection.
- Added Paladin Seal of Fury/Justice and judgment-effect recognition, Druid Gift of the Wild and Priest prayer equivalents, learned-summon gating for Warlock, and Dwarf Find Treasure discovery. Missing optional target effects are now neutral instead of blanket rotation warnings.
- Fixed Shaman passive Maelstrom discovery, unknown stack counts, Riptide readiness, personal Flame Shock tracking, learned-only Recall hints, and totem retention when combat ends with unavailable native data.
- All classes stay suspended while dead or loading, and resume on return. Disabled standard blocks stop querying their APIs; Hunter stops polling when all target widgets are disabled.
- Startup and status now read the actual addon version from its TOC. Class initialization preserves newer shared saved-data schemas.

Use `/reload` after updating. Validation uses mocked APIs; restricted live readings remain unavailable. See `docs/class-review-2026-09-23.md` for review coverage and limits.

## 0.21.14

- Recognize a Shaman totem from the player’s successful cast spell ID even when Forever reports a different ID in the spellbook. This keeps the totem icon and bar visible when the slot API reports `?/4`.
- Keep the timer blank until that exact spell ID has a readable duration; removal events still clear the observed totem.

Use `/reload` after updating.

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
