# My-skills

个人 AI Skill 库（单一源 / canonical source）。各 Agent 的技能目录从这里同步，避免多份副本各改各的。

## 存放规范

每个 skill 一个目录，目录名 = skill 的 `name`，内含 `SKILL.md`：

```
My-skills/
├── README.md
├── <skill-name>/
│   ├── SKILL.md          # 必需：YAML frontmatter(name, description) + Markdown 指令
│   ├── references/       # 可选：按需加载的参考文档
│   ├── scripts/          # 可选：确定性/重复性任务的脚本
│   └── assets/           # 可选：输出用的模板、图标等
```

`SKILL.md` 的 frontmatter 至少要有 `name` 和 `description`。description 决定**何时被触发**：先写「做什么」，再写「何时用」，并把触发词写具体。

## 当前收录

| skill | 作用域 | 用途 |
|---|---|---|
| `standard-commit` | 跨项目通用 | 从真实 git 改动产出规范英文 Conventional Commit + 可执行命令（不代提交） |
| `pre-commit-checklist` | 通用（流程） | 提交前检查：结构文档同步 → 校验/测试 → 扫隐私文件 → 提交信息 → 不代提交 |
| `feature-kickoff` | 通用（流程） | 新功能启动梳理：功能简述 → 关键节点 / 待确认问题 / 影响面与风险 / 测试点 / 建议分支名（不实现） |

## 与各 Agent 技能目录的关系

同一 skill 要在多个 Agent 生效，通过**软链接（junction）**指向本库——本库是**唯一维护源**，改这里即可，各 Agent 目录自动同步，永不产生副本。

| Agent | 技能目录 |
|---|---|
| WorkBuddy | `C:\Users\huawei\.workbuddy\skills\` |
| AirJelly | `C:\Users\huawei\AppData\Roaming\AirJelly\skills\` |

同步方式：**只允许软链接**（junction），**不要使用复制**——复制会各自分叉、改一处要同步多处，正是本库要消除的问题。

用 `link.ps1` 一键完成（自动扫描本库所有 skill，链到各 Agent 目录；幂等，可重复跑）：

```powershell
powershell -ExecutionPolicy Bypass -File D:\My-skills\link.ps1
```

- `-Force`：源位置变了 / 链接指歪或悬空时重指（遇真实目录只报警不删）。
- `-WhatIf`：空跑预演，不实际改动。

手动建单个链接的等价写法（Windows junction，普通 PowerShell 即可，无需管理员）：

```powershell
New-Item -ItemType Junction `
  -Path "$env:APPDATA\AirJelly\skills\standard-commit" `
  -Target "D:\My-skills\standard-commit"
```
