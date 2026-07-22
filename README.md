# bg3-SkillAndMod

博德之门 3 自制 Mod 与配套开发 skill。每个 Mod 都独立放在 `mod/` 下的同名文件夹中，方便以后继续添加新的作品。

## 当前 Mod

- [`mod/MysticOrientalWeapons/`](mod/MysticOrientalWeapons/)：神秘东方武器
- [`skill/`](skill/)：BG3 武器 Mod 制作经验与可复用武器索引

## 目录约定

```text
mod/
└─ ModName/
   ├─ ModName.pak
   └─ README.md
skill/
```

新增 Mod 时，在 `mod/` 下新建一个以 Mod 名称命名的文件夹，放入对应的 `.pak` 和中文 `README.md` 即可。

## 安装

进入目标 Mod 文件夹，把其中的 `.pak` 复制到《博德之门 3》的 `Mods` 目录，然后在游戏 Mod 管理器或 BG3 Mod Manager 中启用。

本仓库只公开可直接安装的 pak 和 skill，不包含存档、日志、完整解包数据或机器专用缓存。可编辑的 Mod 源码保存在本机开发目录中。
