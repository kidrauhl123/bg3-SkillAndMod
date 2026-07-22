---
name: bg3-weapon-mod-lessons
description: Capture and apply concise, verified lessons for Baldur's Gate 3 original-weapon mods, especially root templates, Script Extender grants, package layout, appearance reuse, reusable weapon-index caching, and inventory verification. Use when creating, debugging, or documenting a BG3 weapon mod.
---

# BG3 Weapon Mod Lessons

Keep only concrete, reusable findings from BG3 weapon-mod work. Prefer a tested fact or failure cause over general modding advice.

## Verified lessons

- A custom item root template must be compiled as `.lsf`; an `.lsx` root template in the pak may appear installed but is not loaded by the game.
- Use the normal resource layout: `Public/<mod-folder>/RootTemplates/*.lsf` and `Public/<mod-folder>/Levelmaps/LevelMapValues.lsx`.
- `Osi.TemplateAddTo` returning without an error, or a mod log saying "added", is not proof that the item persisted.
- Verify the real server inventory through `_C().InventoryOwner.Inventories[*].InventoryContainer.Items[*].Item.ServerItem.Template.Id`; check the exact root UUID and count.
- Reuse an existing crossbow root/visual or icon for appearance, while keeping the custom weapon stat entry for damage, range, passives, and level scaling.
- Keep `modsettings.lsx` MD5 values attached to the matching module node; do not replace another mod's hash.
- Vanilla `MAG_Sarevok_OfChaos_Greatsword_Leeching_Passive` is a stable fixed-heal donor: `OnDamage`, `AttackedWithPassiveSourceWeapon() and not Item()`, and `RegainHitPoints(SELF, 1d6)`.

## Weapon index workflow

- Treat the BG3 Script Extender API as the runtime source of truth: use `Ext.Stats.GetStats("Weapon")`/`Ext.Stats.Get(name)` for weapon stats and `Ext.Template.GetAllRootTemplates()`/`Ext.Template.GetRootTemplate(uuid)` for root, icon, parent, and visual-template data. Export scans with `Ext.IO.SaveFile` and `Ext.DumpExport`.
- Use [references/bg3-weapon-index.json](references/bg3-weapon-index.json) as a small, curated cache of known-good roots and appearance donors. An absent entry is not proof that the game lacks the weapon.
- Keep reusable vanilla effect IDs and their short roles in `references/bg3-weapon-index.json`; do not grow this Markdown file into a catalogue of every weapon or passive.
- Keep full generated dumps outside the skill (for example `BG3DataCache/weapon-index-<game-build>.json`) so the skill stays portable and fast to load.
- Refresh the cache only after a game/Script Extender update or relevant `.pak` hash change. Before packaging, re-query the live API and compare `Name`, `Stats`, `Icon`, `VisualTemplate`, and `ParentTemplateId`; then verify the real server inventory.

## Current case

- The working weapon is `da292a90-af3a-4b82-a881-d09ccb9dbbe7` (`ZGLN_ZhugeRepeatingCrossbow`).
- A compiled root template plus the corrected package layout fixed loading.
- Direct inventory verification found one real item after a qualified `TemplateAddTo` call; the earlier rescue log alone was insufficient.
- The first reusable index seed records generic and Gortash heavy-crossbow roots; the Gortash visual is a donor, not a gameplay-stat dependency.
- Vanilla stealth/assassination effect IDs are kept in the index as short, searchable pattern records; re-query them after a game patch.
- When dynamic `DamageDone` healing behaves inconsistently in a weapon passive, prefer the tested vanilla fixed-heal pattern above for the real-HP portion and keep any overflow/temp-HP logic separate.

## Extension rule

Append short entries only when a result is reproduced or a failure has a confirmed cause. Record the symptom, cause, and fix in one line.
