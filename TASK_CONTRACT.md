# 📋 AUTONOMOUS EXECUTION CONTRACT (TASK CONTRACT)

## 🎯 1. STRICT OBJECTIVE
Ensure that the Manifest V3 Browser Extension (`extension/`), the Userscript (`userscript/`), and the cross-platform user-space installers (`install.sh`, `install.ps1`, `install.bat`) automatically select `42cursus` on the 42 Intra v3 dashboard without infinite loops, without `StackOverflowException` on Windows PowerShell, without mutating global browser shortcuts by default, and with zero personal data or local path leaks, governed by SDD and Harness Engineering.

## ✅ 2. DEFINITION OF DONE (DoD)
- [x] Validate JS, JSON, Bash syntax and security/privacy rules by running `make harness-check` with exit code `0`.
- [x] Eliminate `Start-Job` and recursive `.lnk` traversal in `install.ps1` to prevent `StackOverflowException` on Windows PowerShell 5.1.
- [x] Cap `MutationObserver` attempts (`MAX_SWITCH_ATTEMPTS = 2`) and throttle via `requestAnimationFrame` in `content.js` and `.user.js`.
- [x] Enforce English as the primary language for all code, comments, scripts, and primary docs, with Spanish secondary mirrors (`README.es.md`, `docs/adr/es/`, `docs/specs/es/`).
- [x] Guarantee 100% clean Git history with zero personal paths, CDN hashes, or internal 42 logins.

## 🔒 3. ALLOWED SCOPE (WHITELIST)
- `extension/manifest.json`, `extension/content.js`
- `userscript/force-42cursus-header.user.js`
- `install.sh`, `uninstall.sh`, `install.ps1`, `uninstall.ps1`, `install.bat`, `uninstall.bat`
- `AGENTS.md`, `TASK_CONTRACT.md`, `.aiexclude`, `.gitignore`, `Makefile`, `README.md`, `README.es.md`
- `.agents/**/*`, `.github/agents/**/*`, `docs/**/*`

## 🚫 4. BLOCKED ZONES (BLACK-BOX)
- Any file or directory outside the repository root or global host OS configuration (`/etc/`, `C:\Windows\`).

## 🛡️ 5. ACTIVE GUARDRAILS
- Zero `sudo` or Administrator UAC elevation.
- Zero file deletion without explicit user confirmation.
- Zero privileged browser permissions in `extension/manifest.json`.
- Maximum 5 consecutive failed validation attempts (`make harness-check`) before circuit-breaker abort.
