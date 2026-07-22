# BG3 Oriental Legendary Weapons

An experimental Baldur's Gate 3 project containing two original weapons and a small reusable Codex skill for verified BG3 weapon-modding lessons.

## Contents

- `mod/Dist/` — ready-to-install `.pak` release.
- `mod/PakRoot/` — source layout for the module's stats, compiled root templates, localization, and Script Extender grant.
- `skill/` — the `bg3-weapon-mod-lessons` skill plus its compact reusable weapon index.

## Weapons

### Zhuge Repeating Crossbow

- 20 m ranged weapon with a crossbow appearance.
- Level scaling: enchantment +1/+2/+3 at levels 4/7/10, plus level-based first-hit piercing damage.
- Bonus-action Mechanical Volley, once per turn.
- A direct hostile kill grants a free follow-up shot; stacks are not limited per turn.

### Sha Bi

- Level-scaling assassin dagger using a dagger appearance from the original game.
- First melee hit each turn adds piercing damage equal to the wielder's level.
- The Bloodletting passive uses the vanilla Sword of Chaos pattern for the real-HP portion: weapon damage triggers a fixed `1d6` heal.
- At full HP, half of the damage dealt can become temporary HP, capped at `10 + 2 × level` until Long Rest.
- Killing blows while the dagger is equipped grant 2 turns of Invisibility, without a per-turn limit.

## Requirements

- Baldur's Gate 3.
- BG3 Script Extender v30 or newer for the automatic inventory grant.

The native weapon stats remain in the package even without Script Extender; only the automatic grant needs the extender. Existing saves receive the items in the host inventory after the session loads. Verify the actual inventory before assuming a grant succeeded.

## Install

1. Copy the `.pak` from `mod/Dist/` to the game's `Mods` directory.
2. Enable the module in the game's mod manager or BG3 Mod Manager.
3. Start or load a session as the host. The extender grants one copy of each item to the host inventory.

## Build

The `PakRoot` directory is already arranged for Divine/LSLib:

```text
Divine.exe -g bg3 -a create-package -s mod/PakRoot -d mod/Dist/<output>.pak
```

The `.lsf` root templates are the files loaded by the game. The matching editable `.lsx` files live under `mod/References/RootTemplates/` so a package build cannot accidentally include them instead of the compiled `.lsf` files.

## Scope and privacy

This repository intentionally excludes save files, logs, extracted full-game data, generated Story dumps, and machine-specific build caches. The skill's full weapon exports belong outside the skill and should be regenerated locally after a game or Script Extender update.

No reuse license has been selected yet.
