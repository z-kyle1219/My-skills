---
name: standard-commit
description: Produce one standardized English Conventional Commit message plus a ready-to-run command from the actual Git changes, without committing or pushing. Use it when the user explicitly asks for a commit message, asks how to commit current changes, or confirms that a batch of code changes is complete and the conversation context indicates they want to prepare a commit. Inspect the actual Git status and relevant diffs before writing.
agent_created: true
---

# Standard Commit

Generate one accurate, standardized English Conventional Commit message for a batch of code changes.

By default, provide the commit message and a ready-to-run command only. Do not execute `git commit` or `git push` unless the user explicitly requests execution.

## When to Use

Use this skill when:

- The user explicitly asks for a commit message, such as "给我个 commit", "这个怎么提交", "commit 怎么写", or "帮我写个提交信息".
- The user confirms that a batch of code changes is complete, and the surrounding conversation makes it clear that they want to prepare a commit.
- The user asks to prepare a commit for a specified set of changes.

Do **not** trigger solely because the user says "ok", "可以", "行", "好了", "done", or "继续". These phrases may refer to an explanation or another action. If the context does not clearly establish that code changes are complete and a commit message is wanted, ask a brief clarifying question or continue with the current task.

Before generating a message, check that there are relevant pending changes. If the working tree has no relevant changes and the user has not specified a committed range, explain that and ask what they want to commit or review. Do not invent a change or message.

## Workflow

### 1. Inspect Git status and change scope

Run:

```bash
git status --short
git diff --stat
git diff --cached --stat
```

Use these commands to identify changed, staged, unstaged, untracked, and deleted files. Then inspect relevant diffs when needed:

```bash
git diff
git diff --cached
```

Important:

- `git diff` shows unstaged tracked changes; `git diff --cached` shows staged changes.
- Untracked files do not appear in either diff. Inspect their names and contents when needed and safe.
- Do not assume staged changes are the only intended changes merely because some files are staged.
- Determine the intended commit scope from the user's request and the repository state. If it is unclear whether staged and unstaged changes belong in the same commit, ask before suggesting commands that could include the wrong files.
- Never include secrets, credentials, local data, logs, generated files, or unrelated changes without checking whether they belong in the intended commit.
- Do not use destructive commands or modify the working tree just to prepare a commit message.

### 2. Choose the Conventional Commit type

If the target repository already has an established commit style, follow that convention instead: check recent history with `git log --oneline -20` and match it (this skill's format is the default only for repos that already use Conventional Commits or have no established style). Do not force Conventional Commits onto a repo that clearly uses another convention.

Otherwise, choose the type based on the primary purpose of the actual changes.

| Type | Use when |
|---|---|
| `feat` | Adds user-facing or otherwise meaningful functionality |
| `fix` | Fixes a bug |
| `refactor` | Restructures code without intentionally changing behavior |
| `perf` | Improves performance |
| `test` | Adds or changes tests only |
| `docs` | Changes documentation only |
| `chore` | Maintenance work, dependencies, build tooling, or configuration |
| `style` | Formatting-only changes that do not affect logic |

Do not default to `feat`. If a change has multiple effects, select the type that best represents its primary purpose. If the intent cannot be established from the diff and context, ask rather than guess.

### 3. Choose the scope

- Use a concise name for the main affected module or area, such as `auth`, `api`, `ui`, or `weather`.
- Derive the scope from the actual changed paths and content, not from examples.
- For changes spanning multiple areas, choose the dominant area or omit the scope.
- Omit the scope if it adds little useful information.

### 4. Write the subject

- Write in English.
- Use an imperative verb, such as `add`, `fix`, `handle`, `remove`, or `document`.
- Start the subject with a lowercase word after the type/scope prefix.
- Do not end the subject with a period.
- Aim for 50 characters or fewer; keep it within 72 characters where practical.
- Describe what the change does, not why it was needed. Put useful rationale in the body.
- Keep the message specific to the inspected changes.

Format:

```text
<type>(<scope>): <subject>
```

The scope is optional:

```text
<type>: <subject>
```

### 5. Add a body or footer only when useful

Add a body when the change is substantial, spans several related details, or needs rationale that the subject cannot communicate. Leave a blank line between the subject and body.

- Explain why the change was made or what important impact it has.
- Keep each body line within approximately 72 characters.
- Add a footer when relevant, such as `Closes #12` or `BREAKING CHANGE: ...`.
- Do not invent issue numbers, references, or breaking changes.

## Output

Usually provide:

1. The recommended commit message.
2. A brief explanation of the type and scope, if useful.
3. A ready-to-run command that matches the intended commit scope.

Example output:

```text
feat(auth): add token refresh
```

If the intended change is only `src/auth.js` and that file is confirmed to be the only file to commit:

```bash
git add src/auth.js
git commit -m "feat(auth): add token refresh"
```

Use real paths discovered from Git status and the diff. Do not leave placeholders such as `<相关文件>` in a command presented as ready to run.

If the user has already staged exactly the intended files, the command may be:

```bash
git commit -m "feat(auth): add token refresh"
```

If the intended files are unclear, do not produce a command that might stage unrelated changes. Ask which files or changes should be included.

## Execution and Safety

- Do not execute `git add`, `git commit`, `git push`, or other repository-changing commands unless the user explicitly asks you to execute them.
- If the user explicitly asks you to execute a commit, first inspect Git status and identify exactly which files would be included. If the intended scope is ambiguous, ask for confirmation before staging or committing.
- Do not push unless explicitly requested.
- Never claim a commit was created, a push succeeded, or tests passed unless that action was actually performed and its result verified.
- Do not discard, reset, restore, or overwrite user changes as part of this workflow.

## Examples

```text
feat(auth): add jwt refresh token rotation
fix(api): handle empty payload on create endpoint
refactor(ui): split monolithic view into components
test(parser): cover cross-day boundary
docs(readme): document env setup
chore(deps): pin pillow to 12.x
```

These are examples of the format only. Derive the actual type and scope from the current changes; do not copy example scopes blindly.

## Final Checklist

- [ ] The message reflects the actual inspected changes.
- [ ] The type matches the primary purpose; it is not automatically `feat`.
- [ ] The scope is grounded in real changed files, or omitted when unhelpful.
- [ ] The subject is English, imperative, lowercase after the prefix, and has no trailing period.
- [ ] Subject length is concise, ideally no more than 50 characters.
- [ ] Staged, unstaged, and untracked changes were considered appropriately.
- [ ] The suggested command includes only the intended files.
- [ ] No commit or push was performed without explicit authorization.
