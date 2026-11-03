# Forever class audit — November 3, 2026

Reviewed all nine classes against [Blizzard’s latest launch tuning notes](https://eu.forums.blizzard.com/en/wow/t/631316/9) and the [Hunter and Druid deep dive](https://worldofwarcraft.blizzard.com/en-gb/news/24301515). The launch notes take priority over beta descriptions. This is a targeted review of Classmate’s helpers, not an exhaustive spell catalog.

| Class | Decision |
| --- | --- |
| Hunter | Keep range, ammo, marks, aspects and pet reminders. Correct Bear Swipe, Boar Charge, Carrion Bird Demoralizing Screech and Bat Sonic Blast family hints; retain the Spider Web omission because the guide cannot verify an individual pet’s skill. The shared trap cooldown needs no change to the existing range helper. |
| Druid | Replace removed Tiger’s Fury and Berserk with Primal Bite and Shifting Power. Add learned Lacerate, Rake and Poised; recognize Clearcasting for Omen of Clarity. Swiftmend relies on client usability and does not infer another player’s HoT as eligible. |
| Mage | Add Missile Barrage as a readable proc. Ice Lance and Fire Blast already read live cooldowns and share one visible ability slot. Frost Blast was never in the catalog. Ice Barrier’s new damage effect does not change the meaning of the aggregate absorb meter. |
| Paladin | Replace Twist of Light with Unsealed Wrath, add Judgement of Fury to the seal-derived effects and recognize learned Templar’s Bulwark. Do not track removed blessings or infer Unsealed Wrath stacks from swings. |
| Priest | Add learned Penance. Keep existing shield/Shadow/racial reads; Holy Binding is passive and does not belong in a readiness slot. |
| Rogue | Remove Cutthroat and Thousand Cuts. Move Venom out of mandatory upkeep into observed procs alongside Poised. Add learned Shank, personal Death Mark in the target slot, and Garrote in the DoT strip. |
| Shaman | Remove the Lava Burst and Flame Shock pairing. Use learned Lightning Mastery, Stormstrike and Totemic Call cooldowns in the helper. Keep Maelstrom stacks, native Riptide cooldown and its readable personal HoT, totem timers, and separate Totemic Recall. |
| Warlock | Add learned Amplify Curse readiness. Retain Bane of Agony, Wrack and other existing effects; tuning and shard-proc rates require no hardcoded changes. |
| Warrior | Add Reckless Swings and Slam. Keep Rend/Bloodthrill and client-reported Overpower usability; do not calculate trigger chance or infer a proc. |

No feature derives secret combat data or invents cooldown values. Proc and target slots require readable aura evidence. The addon uses the learned spellbook and existing toggles. Tests exercise the changed catalogs and supported display paths with mocked APIs; they do not establish launch-client visibility or localized aura identifiers.
