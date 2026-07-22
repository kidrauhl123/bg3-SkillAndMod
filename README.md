# bg3-SkillAndMod

A small Baldur's Gate 3 project containing two original weapons and a concise reusable skill for verified BG3 weapon-modding lessons.

## Contents

- `mod/MysticOrientalWeapons.pak` — ready-to-install release package.
- `skill/` — the `bg3-weapon-mod-lessons` skill and its compact reusable weapon index.

## Weapons

### Zhuge Repeating Crossbow

- 20 m ranged weapon with a reused heavy-crossbow appearance.
- Level scaling: enchantment +1/+2/+3 at levels 4/7/10, plus level-based first-hit piercing damage.
- Bonus-action Mechanical Volley, once per turn.
- A hostile killing blow grants a free follow-up shot; stacks are not limited per turn.

### Sha Bi

- Level-scaling assassin dagger using a reused vanilla dagger appearance.
- First melee hit each turn adds piercing damage equal to the wielder's level.
- Weapon damage triggers a fixed `1d6` actual-HP heal using the vanilla Sword of Chaos pattern.
- Killing blows while the dagger is equipped grant 2 turns of Invisibility, without a per-turn limit.

## Requirements

- Baldur's Gate 3.
- BG3 Script Extender v30 or newer for the automatic inventory grant.

The native weapon stats remain in the package even without Script Extender; only the automatic grant needs the extender. Existing saves receive one copy of each item in the host inventory after the session loads.

## Install

1. Copy `mod/MysticOrientalWeapons.pak` to the game's `Mods` directory.
2. Enable the module in the game's mod manager or BG3 Mod Manager.
3. Start or load a session as the host. The extender grants one copy of each item to the host inventory.

The public repository intentionally contains the installable package and the skill, not generated extraction data or build caches. The editable package source is kept locally for continued development.

No reuse license has been selected yet.
