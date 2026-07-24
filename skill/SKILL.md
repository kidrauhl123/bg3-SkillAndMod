---
name: bg3-mod-lessons
description: Apply verified Baldur's Gate 3 modding workflows for custom items and weapons, RootTemplates, Script Extender Lua, inventory grants, localization, corpse capture, linked spell menus, controllable summons, and build-time generation of large summon catalogues. Use when creating, debugging, packaging, or documenting BG3 mods.
---

# BG3 Mod Lessons

Prefer reproduced facts over plausible-looking APIs. Inspect the current game or Toolkit data before reusing UUIDs, stats, icons, or templates.

## Items, weapons, and packaging

- Compile custom item RootTemplates to `.lsf`; an `.lsx` RootTemplate inside a pak may look installed but is not loaded.
- Use `Public/<module>/RootTemplates/*.lsf`, `Public/<module>/Stats/Generated/Data/*`, and `Mods/<module>/meta.lsx`.
- Keep the module folder, UUID, and pak filename ASCII and stable. Put player-facing Chinese and English names in separate localization files.
- Use an ASCII `ModuleInfo/Name` for mod-manager compatibility. BG3 Mod Manager does not localize it and may display XML character entities literally.
- Update only the matching module node in `modsettings.lsx`; preserve every other mod's MD5 and metadata. Edit it only while BG3 is closed.
- Reuse an existing visual/icon donor while keeping a distinct custom stat entry for mechanics.

## Granting an item reliably

- Grant from a direct Osiris listener such as `LevelGameplayStarted`.
- Call `Osi.TemplateAddTo("<StatName>_<root-UUID>", Osi.GetHostCharacter(), 1, 1)` with the fully qualified template name.
- Do not defer the grant through `Ext.Timer.WaitFor`; tested BG3SE v32 callbacks lost a usable Osiris context and produced nil-call failures.
- A successful return or log line is not proof. Verify `_C().InventoryOwner.Inventories[*].InventoryContainer.Items[*].Item.ServerItem.Template.Id` against the exact root UUID.

## Controllable captured summons

Read [references/summon-presets.md](references/summon-presets.md) before implementing corpse capture, dynamic summon menus, or NPC-derived controllable followers.

- Build the action like vanilla Find Familiar/Ranger's Companion: a linked `Target` parent, static `Target` children, and `GROUND:Summon(...)`.
- Summon the mapped character RootTemplate directly. Do not spawn a naked NPC/bear shell and transform it afterward.
- Pre-generate summon child stats at build time. Runtime-created children repeatedly produced empty or nonfunctional linked menus; static children were reliable.
- Grant only the parent container spell. Set its `ContainerSpells` to captured children, call `stat:Sync()`, then re-grant the parent when rebuilding.
- Convert level-local/placed NPC templates into independent package RootTemplates and maintain a source UUID to summon UUID map.
- Use a unique summon stack ID per source template to allow multiple distinct summons.
- Bind the engine-created summon through a marker status, then apply instance-only state such as display name, faction, copied spells/passives, and permanent boosts.
- Use atlas-backed spell/action icons. Character portrait identifiers render as question marks in linked spell menus.

## Reusable preset resources

Use `assets/spirit-summon-presets/` when a mod needs the verified 4154-entry static catalogue. Copy only the files needed by the target module and rename prefixes/statuses to avoid conflicts.

Regenerate for a different game build with `scripts/generate-mapped-summon-spells.ps1` and local extracted game data. Treat the bundled catalogue as a tested Patch 8 snapshot, not an official API.

## Reference lookup

- Prefer current local game/Toolkit data for `RootTemplate`, `Stats`, `Icon`, `VisualTemplate`, and `ParentTemplateId`.
- At runtime use `Ext.Stats.GetStats(...)`, `Ext.Stats.Get(...)`, `Ext.Template.GetAllRootTemplates()`, and `Ext.Template.GetRootTemplate(...)`.
- Use the official BG3 Modding documentation, BG3 Wiki modding resources, and the BG3 Script Extender API documentation for schemas and current APIs.
- Do not maintain hand-written exhaustive indexes. Generate large catalogs from the installed game and bundle the deterministic generator plus validated outputs.

## Extension rule

Add a lesson only after reproducing it or confirming its failure cause. Record symptom, cause, fix, and validation in the smallest useful form.
