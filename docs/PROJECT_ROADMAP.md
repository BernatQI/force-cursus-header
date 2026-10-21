# Project Roadmap — 42 Intra Force `42cursus` Header

**Objective:** Automatically select `42cursus` in the 42 Intra v3 profile dashboard header (`profile.intra.42.fr`), preventing it from defaulting to *C Piscine* or *Piscine Reloaded*.

---

## Milestone 1: Core DOM & Radix UI Automation (Completed)
- [x] Implement Userscript (`userscript/force-42cursus-header.user.js`) for Tampermonkey / Violentmonkey.
- [x] Implement WebExtension Manifest V3 (`extension/manifest.json`, `extension/content.js`).
- [x] Suppress visual flicker via temporary CSS portal hiding (`#ft-force-cursus-hide-radix-menu`).
- [x] Respect manual user interaction (`event.isTrusted`).

## Milestone 2: Cross-Platform User-Space Auto-Installer (Completed)
- [x] Linux auto-installer (`install.sh`, `uninstall.sh`) in `~/.local/share/force-cursus-header`.
- [x] Windows native PowerShell/Batch installer (`install.ps1`, `install.bat`, `uninstall.ps1`, `uninstall.bat`) in `%LOCALAPPDATA%\force-cursus-header`.
- [x] Automatic Git Bash / MSYS2 / WSL bridge in `install.sh`.

## Milestone 3: Security Hardening, Stability & SDD Governance (Completed)
- [x] Fix Windows PowerShell `StackOverflowException` by removing `Start-Job` and recursive `.lnk` traversal (ADR-0002).
- [x] Bound `MutationObserver` attempts (`MAX_SWITCH_ATTEMPTS = 2`) and throttle via `requestAnimationFrame`.
- [x] Restrict host matches strictly to `profile.intra.42.fr` and `profile-v3.intra.42.fr`.
- [x] Make browser shortcut patching strictly opt-in (`--patch-shortcuts` / `-PatchShortcuts`).
- [x] Establish Orchestrator pattern (`AGENTS.md`), Harness (`Makefile`), `TASK_CONTRACT.md`, ADRs, and SDDs.
