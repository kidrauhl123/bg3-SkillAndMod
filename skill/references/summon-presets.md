# Controllable summon presets

Use this reference for corpse capture, NPC-derived followers, linked summon menus, or large build-time spell catalogs.

## Verified architecture

The working design follows the vanilla summon path from the beginning:

1. Capture a dead character's source RootTemplate UUID, display name, representative spell icon, and a filtered combat snapshot.
2. Resolve the source UUID to an independently summonable package RootTemplate.
3. Select a build-time-authored child spell for that source UUID.
4. Add that child to a linked `Target` parent spell's `ContainerSpells` and call `stat:Sync()`.
5. Grant only the parent spell to the player.
6. Let `GROUND:Summon(...)` create the mapped character template directly as the controlled summon.
7. On the summon marker status, bind the new entity to its capture record and apply instance-only data.

The reliable child form is:

```text
new entry "Target_SK_NG_<source UUID without hyphens>"
type "SpellData"
using "Target_RangersCompanion"
data "SpellContainerID" "Target_SK_SummonMenu"
data "SpellProperties" "GROUND:Summon(<mapped root UUID>,Permanent,,,'<unique stack>',UNSUMMON_ABLE,SK_CAPTURED_SUMMON,SHADOWCURSE_SUMMON_CHECK)"
data "TargetConditions" "CanStand('<mapped root UUID>') and not Character() and not Item() and not Self()"
```

`Target_RangersCompanion` supplies the proven linked-target summon behavior. The engine owns the summon and attaches it to the caster's controllable portrait group. The marker status is for record binding, not for manufacturing a follower after the fact.

## Why build-time presets were required

Runtime-created or repeatedly mutated child spell stats appeared as duplicate icons, empty linked menus, non-clickable buttons, or actions that never entered ground targeting. A complete static child catalog loaded with the module fixed the UI and targeting path. Runtime code now changes only:

- the parent container's `ContainerSpells`;
- a child's atlas-backed `Icon`, followed by `stat:Sync()`;
- capture records and summon instance state.

The verified catalog contains:

| Resource | Count or purpose |
| --- | --- |
| `Spell_Target_SK_Mapped.txt` | 4154 static child spells |
| `SK_NonGlobalSummonRoots.lua` | 3901 source-to-root mappings |
| `SK_GlobalSummonRoots.lua` | 253 source-to-root mappings |
| `SK_NonGlobalSummonRoots.lsf` | compiled independent RootTemplates |
| `SK_GlobalSummonRoots.lsf` | compiled independent RootTemplates |

These are generated template/stat metadata, not copied textures, models, portrait atlases, or audio.

## Asset placement

Copy resources from `assets/spirit-summon-presets/` into a module as follows:

```text
Mods/<module>/ScriptExtender/Lua/Data/
  SK_NonGlobalSummonRoots.lua
  SK_GlobalSummonRoots.lua

Public/<module>/RootTemplates/
  SK_NonGlobalSummonRoots.lsf
  SK_GlobalSummonRoots.lsf

Public/<module>/Stats/Generated/Data/
  Spell_Target_SK_Mapped.txt
```

The receiving mod must also author:

- the linked parent `Target` spell;
- the capture `Target` spell;
- the summon marker status;
- Script Extender persistence and record binding;
- localization handles referenced by the generated children.

Rename the `SK_` stat names, status names, stack IDs, and localization handles when integrating into another published mod.

## Template mapping

A placed or level-local NPC identifier is not necessarily a package RootTemplate usable by `GROUND:Summon`. For each source:

- resolve `ServerCharacter.Template.Id`;
- follow `TemplateName` or `ParentTemplateId` to obtain a viable base;
- create a package RootTemplate with a deterministic new UUID;
- remove level placement fields such as `IsGlobal`, `TemplateName`, and `LevelName`;
- set `ParentTemplateId` to the reusable base;
- compile the generated `.lsx` to `.lsf`;
- map the captured source UUID to the generated RootTemplate UUID.

Use the generator in `scripts/generate-mapped-summon-spells.ps1` with current local game data when updating the catalog.

## Runtime record

Persist at least:

- owner;
- source character identifier for same-session inspection;
- source RootTemplate UUID;
- mapped summon RootTemplate UUID;
- assigned static summon spell;
- slot;
- display name;
- representative atlas-backed menu icon;
- filtered spells, passives, permanent boost statuses, size, and weight.

Do not copy dialogue, trade, quest identity, temporary harmful statuses, progression internals, or the dead entity itself into the summon.

## Failure map

| Symptom | Confirmed cause | Fix |
| --- | --- | --- |
| Naked idle human/NPC | Created an ordinary entity outside the summon functor | Use `GROUND:Summon` with a mapped RootTemplate |
| A bear appears | Donor summon still points at the bear template | Generate a child whose `Summon` argument is the mapped NPC root |
| Empty or inert submenu | Runtime child stats were not stable UI resources | Pre-generate every child and mutate only `ContainerSpells` |
| Duplicate top-level buttons | Child spells were granted directly | Grant only the linked parent |
| Question-mark icons | Character portrait keys are not spell-atlas icons | Use a valid icon from an NPC spell/action, with Find Familiar as fallback |
| A captured NPC is absent | Its source is level-local or has no viable mapping | Generate and compile an independent package RootTemplate |
| Distinct captures replace one another | Reused a shared summon stack ID | Derive a unique stack ID from the source UUID |
| Summon exists but is not the captured combatant | Only appearance was copied | Summon the mapped root directly, then apply the captured combat snapshot |

## Validation

- Count 4154 `new entry` records in the generated spell file.
- Confirm 3901 non-global and 253 global mapping entries.
- Verify every child references an existing mapped RootTemplate and the expected parent container.
- Reverse-extract the final pak and inspect `meta.lsx`, compiled RootTemplates, stats, and Script Extender data.
- In game, test capture, menu population, ground targeting, portrait attachment, direct control, multiple different summons, dismissal, save/reload, and resummoning after death.
