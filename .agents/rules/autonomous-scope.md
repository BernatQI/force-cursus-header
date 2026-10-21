# 🛡️ Autonomous Execution, Safety Rails & Scope Isolation

This file defines the inviolable rules for autonomous agent execution with Antigravity (`--auto-approve` and `--max-iterations`) in `force-cursus-header`.

---

## 1. 🛑 Anti-Sudo & Zero Elevation Rule (INVIOLABLE)
- Strictly **FORBIDDEN** to execute any command with `sudo` (Linux) or request UAC Administrator elevation (Windows).
- All installation and file operations must remain strictly in user space (`~/.local/share/` or `%LOCALAPPDATA%`).

---

## 2. 🚫 Non-Destructive File Policy
- Strictly **FORBIDDEN** to run destructive deletion commands (`rm -rf`, `unlink`, etc.) on project files without explicit prior user confirmation.

---

## 3. 🔒 Locked Browser Permissions
- Strictly **FORBIDDEN** to add `permissions` or `host_permissions` to `extension/manifest.json` or expand `@match` beyond `https://profile.intra.42.fr/*` and `https://profile-v3.intra.42.fr/*` without explicit user approval.

---

## 4. 🔁 Fail-Safe & Circuit Breaker (Attempt Limit)
- If after **3 to 5 consecutive attempts** the validation harness (`make harness-check`) continues to fail:
  1. The agent **MUST stop autonomous execution**.
  2. Return control to the user with a concise report of what was attempted and the root cause.

---

## 5. 🎯 Task Contract (`TASK_CONTRACT.md`) & `task-scoper` Skill
During autonomous execution, the agent treats `TASK_CONTRACT.md` as the **definitive safety lock** (Strict Objective, DoD verified by `make harness-check`, Whitelist of allowed files, and Blocked Zones).

---

## 6. 🔄 Autonomous Loop & Git Branch Protocol
1. **Auto-Scoping:** Update `TASK_CONTRACT.md` when starting a new task.
2. **Git Branch Control:** Never work directly on `main`. Always create an ephemeral task branch (`feat/xxx`, `fix/xxx`, `security/xxx`).
3. **Harness Validation:** Run `make harness-check` before marking any task complete.
4. **Merge/Push Confirmation:** Never merge into `main` or `git push` without explicit user confirmation.
