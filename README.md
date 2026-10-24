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

## 与各 Agent 技能目录的关系

同一 skill 要在多个 Agent 生效，需分别放到各自的技能目录；本库是**唯一维护源**，改这里、再同步出去。

| Agent | 技能目录 |
|---|---|
| WorkBuddy | `C:\Users\huawei\.workbuddy\skills\` |
| AirJelly | `C:\Users\huawei\AppData\Roaming\AirJelly\skills\` |

同步方式（二选一）：
- **复制**：简单，但改一处要记得同步另一处。
- **符号链接**（推荐长期）：让各 Agent 目录指向本库，永不分叉。Windows 示例（管理员 PowerShell）：
  ```powershell
  Remove-Item "$env:APPDATA\AirJelly\skills\standard-commit" -Recurse -Force
  New-Item -ItemType SymbolicLink `
    -Path "$env:APPDATA\AirJelly\skills\standard-commit" `
    -Target "D:\My-skills\standard-commit"
  ```
