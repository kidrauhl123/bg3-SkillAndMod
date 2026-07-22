---
name: bg3-weapon-mod-lessons
description: Capture and apply concise, verified lessons for Baldur's Gate 3 original-weapon mods, especially root templates, Script Extender grants, package layout, appearance reuse, live resource lookup, and inventory verification. Use when creating, debugging, or documenting a BG3 weapon mod.
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

## Reference sources and lookup workflow

- Use current local game/Toolkit data as the source of truth for exact `RootTemplate`, `Stats`, `Icon`, `VisualTemplate`, and `ParentTemplateId` values.
- Use the BG3 Script Extender API at runtime: `Ext.Stats.GetStats("Weapon")`/`Ext.Stats.Get(name)` for weapon stats and `Ext.Template.GetAllRootTemplates()`/`Ext.Template.GetRootTemplate(uuid)` for templates. Export temporary scans with `Ext.IO.SaveFile` and `Ext.DumpExport`.
- Use the [official BG3 Modding documentation](https://docs.baldursgate3.game/index.php?title=Main_Page) for Toolkit workflows.
- Use the community [BG3 Wiki weapon pages](https://bg3.wiki/wiki/Weapon), [modding hub](https://bg3.wiki/wiki/Modding%3AIndex), and [modding resources](https://bg3.wiki/wiki/Modding_Resources) for human-readable references and tool discovery.
- Use the [BG3 Script Extender API documentation](https://github.com/Norbyte/bg3se/blob/main/Docs/API.md) for runtime API details.
- Do not maintain a hand-curated full weapon JSON in the skill. Keep large generated dumps outside the skill and regenerate them from the current game build only when needed.

## Current case

- The working weapon is `da292a90-af3a-4b82-a881-d09ccb9dbbe7` (`ZGLN_ZhugeRepeatingCrossbow`).
- A compiled root template plus the corrected package layout fixed loading.
- Direct inventory verification found one real item after a qualified `TemplateAddTo` call; the earlier rescue log alone was insufficient.
- The Gortash heavy-crossbow visual is an appearance donor, not a gameplay-stat dependency; re-query donor data after a game patch.
- Search vanilla stealth/assassination effect IDs in current game data and re-query them after a game patch.
- When dynamic `DamageDone` healing behaves inconsistently in a weapon passive, prefer the tested vanilla fixed-heal pattern above for the real-HP portion and keep any overflow/temp-HP logic separate.

## Extension rule

Append short entries only when a result is reproduced or a failure has a confirmed cause. Record the symptom, cause, and fix in one line.
