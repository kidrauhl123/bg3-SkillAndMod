# 精灵球（Spirit Ball）

精灵球可以收纳已经死亡且可处理的 NPC，并把已收纳目标召唤为可操控随从。

- 使用“收纳尸体”记录目标；成功后原尸体会消失。
- 使用“召唤精灵”打开动态子菜单；菜单只列出当前存档中已经收纳的有效目标。
- 召唤物会加入头像栏，可独立移动和参加战斗，并保留对应模板的外观与基础数值。
- 当前包预生成了 4154 个静态召唤条目和模板映射；Script Extender 负责捕获记录、菜单更新、存档恢复和召唤物绑定。

> [!IMPORTANT]
> 这是 **PC 第三方 Mod**，不是官方游戏内 Mod 市场版本。它必须配合 **BG3 Script Extender v30 或更高版本**运行，不能只靠游戏内 Mod 管理器安装。主机和 Mac 当前不受支持。

## 下载

下载本目录中的 [`SpiritKeeper.pak`](./SpiritKeeper.pak)。

在 GitHub 文件页面中点击 **Download raw file（下载原始文件）**。最终得到的文件必须叫：

```text
SpiritKeeper.pak
```

不要解压 `.pak`，也不要同时保留多个不同版本的 `SpiritKeeper.pak`。

## 安装前准备

建议先更新到当前正式版《博德之门 3》，关闭游戏，并备份重要存档：

```text
%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public\Savegames\Story
```

需要以下组件：

1. [BG3 Script Extender（Norbyte 官方发布页）](https://github.com/Norbyte/bg3se/releases)，版本 v30 或更高；建议始终选择标记为 **Latest** 的版本。
2. [BG3 Mod Manager（LaughingLeader 官方仓库）](https://github.com/LaughingLeader/BG3ModManager)。
3. 本目录中的 `SpiritKeeper.pak`。

不需要另外安装 Mod Fixer。

## 第一步：安装 Script Extender

### 方法 A：手动安装（最容易核对）

1. 完全退出游戏和启动器。
2. 打开 [BG3 Script Extender Releases](https://github.com/Norbyte/bg3se/releases)。
3. 下载最新版本提供的压缩包并解压。
4. 把解压得到的 `DWrite.dll` 放进游戏的 `bin` 目录；它应与 `bg3.exe`、`bg3_dx11.exe` 位于同一目录。

Steam 的常见位置：

```text
C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\bin\DWrite.dll
```

如果游戏装在其他盘，例如：

```text
E:\SteamLibrary\steamapps\common\Baldurs Gate 3\bin\DWrite.dll
```

GOG 的常见位置：

```text
C:\GOG Games\Baldurs Gate 3\bin\DWrite.dll
```

最常见的错误是多套了一层目录，例如放成 `bin\bin\DWrite.dll`。这是错误的。

### 方法 B：通过 BG3 Mod Manager 安装

在 BG3 Mod Manager 中打开：

```text
Tools → Download & Extract the Script Extender
```

完成后仍建议检查游戏 `bin` 目录中是否确实存在 `DWrite.dll`。

### 验证 Script Extender

安装后联网启动一次游戏，让 Script Extender 完成自动更新。进入主菜单后，左下角应显示 Script Extender 版本信息。

也可以检查日志目录：

```text
%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\Script Extender Logs
```

如果主菜单没有版本信息，也没有生成日志，请先解决 Script Extender 安装问题，再安装精灵球。

## 第二步：安装 BG3 Mod Manager

1. 从 [BG3 Mod Manager 官方仓库](https://github.com/LaughingLeader/BG3ModManager)下载最新发行版。
2. 把管理器解压到独立目录后运行，不要放进游戏 `bin` 或 `Data` 目录。
3. 首次启动时确认它识别到正确的《博德之门 3》安装目录和玩家配置文件。

## 第三步：导入精灵球

1. 打开 BG3 Mod Manager。
2. 选择 **File → Import Mod**。
3. 选择下载好的 `SpiritKeeper.pak`。
4. 把 `Spirit Ball` 从右侧非活动列表移动到左侧活动列表。
5. 选择 **File → Export Order to Game**，或按 `Ctrl+E`。
6. 关闭管理器后启动游戏。

正常情况下，PAK 会位于：

```text
%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\Mods\SpiritKeeper.pak
```

不要把 `SpiritKeeper.pak` 放进游戏安装目录的 `Data` 文件夹。

### 手动复制 PAK

也可以把 `SpiritKeeper.pak` 手动复制到上述 `Mods` 目录，但仍建议使用 BG3 Mod Manager 启用 Mod 并导出加载顺序，否则游戏可能检测到文件却没有实际加载模块。

## 第四步：首次进入游戏

本 Mod 支持新存档和已有存档。

1. 加载存档并进入可正常控制角色的游戏场景。
2. 精灵球会发放到主机角色背包；如果已经存在，则不会重复发放。
3. 对已经死亡的 NPC 使用“收纳尸体”。
4. 收纳成功后，使用“召唤精灵”打开已捕获目标列表。
5. 选择目标，再选择可站立的地面位置进行召唤。

精灵球菜单不会一次显示全部 4154 个预设，只会显示这个存档中已经成功收纳的目标。

> [!WARNING]
> 收纳成功后原尸体会消失。请先完成搜刮、死者交谈以及其他尸体相关交互，再进行收纳。

## 如何确认 Mod 已正确加载

依次确认以下项目：

1. 主菜单左下角显示 Script Extender 版本。
2. BG3 Mod Manager 左侧活动列表中存在 `Spirit Ball`。
3. 已执行 **Export Order to Game**。
4. 进入游戏后主机角色获得精灵球。
5. 最新的 Script Extender 日志包含类似内容：

```text
Loading bootstrap script: Mods/SpiritKeeper_.../ScriptExtender/Lua/BootstrapServer.lua
[SK] Spirit Keeper direct summon bootstrap loaded
```

完整映射加载成功时还会看到：

```text
non-global mappings=3901; global mappings=253
```

## 更新 Mod

1. 关闭游戏。
2. 备份重要存档。
3. 下载新的 `SpiritKeeper.pak`。
4. 在 BG3 Mod Manager 中重新导入并允许覆盖，或替换 `Mods` 目录中的旧文件。
5. 确认目录中只保留一个 `SpiritKeeper.pak`。
6. 再次执行 **Export Order to Game**。

捕获记录保存在存档的 Script Extender 持久数据中。正常覆盖同 UUID 的新版 PAK 不会主动清空已收纳列表，但重大更新前仍应备份存档。

## 卸载

不建议在正在游玩的存档中途移除任何包含脚本和持久数据的 Mod。

如果必须卸载：

1. 备份存档。
2. 在游戏中驱逐现有召唤物，保存到新存档槽后退出。
3. 在 BG3 Mod Manager 中停用 `Spirit Ball`。
4. 再次执行 **Export Order to Game**。
5. 删除或移走 `SpiritKeeper.pak`。

如果旧存档在移除后无法加载，请恢复 PAK 并使用卸载前的备份。删除 `SpiritKeeper.pak` 不等于卸载 Script Extender；如果其他 Mod 也依赖 Script Extender，应保留 `DWrite.dll`。

## 多人联机

为了减少 Mod 校验错误，所有参与者应保持：

- 相同的游戏版本；
- 相同版本的 `SpiritKeeper.pak`；
- Script Extender 已正确安装并更新；
- 相同的 Mod 及加载顺序。

精灵球会发给主机角色，捕获记录跟随主机使用的存档。联机前建议先由主机单独加载一次存档，确认精灵球和召唤菜单正常。

## 剧情兼容性与限制

- 只允许收纳已经死亡的 NPC，不会控制或替换仍在参与剧情的活体角色。
- 召唤出的精灵是独立可操控随从，定位类似原版魔宠，主要用于移动和战斗。
- 召唤物不会继承原 NPC 的对话、交易或任务身份，也不会以原 NPC 身份重新参与剧情。
- 特殊剧情脚本、临时状态以及少数无法转换为独立 RootTemplate 的目标不保证完整保留。
- 当前 4154 条静态目录是基于已验证游戏版本生成的快照；大型游戏更新后可能需要重新生成或更新 Mod。
- 与其他修改召唤机制、角色模板、法术菜单或队伍系统的 Mod 同时使用时，可能发生冲突。

## 常见问题

### 主菜单没有 Script Extender 版本

- 检查 `DWrite.dll` 是否位于正确的游戏 `bin` 目录。
- 确认没有放成 `bin\bin\DWrite.dll`。
- 检查杀毒软件是否隔离了 DLL。
- 更新游戏后联网启动一次，让 Script Extender 自动更新。

### BG3 Mod Manager 找不到精灵球

- 确认下载的是 `SpiritKeeper.pak`，而不是仍装在 ZIP 中的文件。
- 使用 **File → Import Mod** 重新导入。
- 检查 `%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\Mods` 中是否存在 PAK。
- 确认已经启用并导出加载顺序。

### 进入游戏后没有精灵球

- 先确认 Script Extender 已加载。
- 进入一个正常游戏场景，而不是停留在主菜单或角色创建界面。
- 切换区域或保存并重新加载一次，以重新触发 `LevelGameplayStarted`。
- 在最新 Script Extender 日志中搜索 `SpiritKeeper` 或 `[SK]`。

### 无法收纳某个目标

- 目标必须已经死亡。
- 先确认目标仍有可处理的尸体实体。
- 少数剧情实体、临时生成实体或没有可用模板映射的目标可能不受支持。
- 收纳其他普通敌人进行对照测试。

### 召唤菜单为空

- 尚未成功收纳目标时，列表为空是正常现象。
- 检查捕获后是否出现成功反馈、尸体是否消失。
- 查看 Script Extender 日志中是否有 `[SK]` 错误。

### 更新后游戏无法启动或存档无法加载

- 不要删除存档。
- 确认游戏与 Script Extender 都已更新。
- 检查是否同时保留了多个同 UUID 的精灵球 PAK。
- 暂时移走新 PAK、恢复旧版并加载更新前的备份，以判断是否为版本兼容问题。
- 如果没有加载任何 Mod 时仍然崩溃，再检查游戏文件完整性。

## 报告问题时请提供

- 游戏版本；
- Script Extender 版本；
- `SpiritKeeper.pak` 的下载日期或版本；
- 单人还是联机；
- 是否为新存档；
- 可复现步骤；
- 最新的 `Extender Runtime ... .log`；
- 如有需要，附上 BG3 Mod Manager 的活动加载顺序截图。

请勿公开上传包含个人路径、账号信息或其他敏感内容的完整日志；提交前先检查并删去不相关信息。

---

## English quick installation

Spirit Ball is a third-party PC mod and requires **BG3 Script Extender v30+**.

1. Download the latest [BG3 Script Extender](https://github.com/Norbyte/bg3se/releases).
2. Extract `DWrite.dll` into `Baldurs Gate 3\bin`, next to `bg3.exe`.
3. Launch the game once and confirm that a Script Extender version appears in the lower-left corner of the main menu.
4. Download [`SpiritKeeper.pak`](./SpiritKeeper.pak).
5. In [BG3 Mod Manager](https://github.com/LaughingLeader/BG3ModManager), use **File → Import Mod**.
6. Move `Spirit Ball` to the active list and use **File → Export Order to Game**.
7. Load a save. The orb is granted to the host character after entering gameplay.

All multiplayer participants should use the same game version, PAK version, Script Extender version, and mod load order. Back up important saves before updating or removing the mod.
