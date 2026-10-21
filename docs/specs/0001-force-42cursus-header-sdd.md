---
title: "Force 42cursus Header Selector & Cross-Platform Installer"
status: "Implemented"
date: "2026-10-21"
author: "BernatQi"
---

# 1. Context and Objective
The 42 Intra v3 profile dashboard (`profile.intra.42.fr`) defaults the header cursus selector (`button[role="combobox"]`) to *C Piscine* or *Piscine Reloaded* for many students. This specification defines a zero-privilege WebExtension (Manifest V3), a Userscript, and a cross-platform user-space installer (Linux & Windows) that automatically switches the header selector to `42cursus`.

# 2. Behavioral Specification

## 2.1. Happy Path
1. User navigates to `https://profile.intra.42.fr/*` or `https://profile-v3.intra.42.fr/*`.
2. `MutationObserver` (throttled via `requestAnimationFrame`) invokes `enforceCursusHeader()`.
3. `findCursusCombobox()` locates `button[role="combobox"]` adjacent to `a[href*="/experiences/cursus_id/"]`.
4. If the combobox label does not match `/42\s*cursus/i` (or matches `/piscine|reload/i`), the script:
   - Injects `#ft-force-cursus-hide-radix-menu` (`opacity: 0 !important`) with a 1500ms safety timeout.
   - Dispatches `pointerdown` + `ArrowDown` to open the Radix UI listbox portal.
   - Polls up to 20 times (every 40ms) for a `[role="option"]` matching `/42\s*cursus/i` and not `/piscine|reload/i`.
   - Dispatches `pointermove` → `pointerdown` → `pointerup` → `click` → `Enter` on the target option.
   - Removes the temporary CSS style after 120ms.

## 2.2. Sad Path & Edge Cases
- **Case 1 (Student only has C Piscine / no `42cursus` option):** After 20 poll ticks (800ms), sends `Escape` to close the listbox, removes the temporary CSS style, and increments `switchAttempts`. After `MAX_SWITCH_ATTEMPTS = 2` on the same pathname, stops attempting further switches (preventing infinite CPU loops).
- **Case 2 (Manual user interaction):** If the user manually clicks the combobox (`pointerdown` with `event.isTrusted === true`), sets `userInteractedManually = true` and stops auto-switching for the remainder of that view.
- **Case 3 (Windows PowerShell 5.1 Execution):** `install.ps1` runs entirely in the main thread without `Start-Job` or recursive `.lnk` scanning, preventing `StackOverflowException`.

## 2.3. Strict Security & Performance Rules
- Zero `permissions` or `host_permissions` in `extension/manifest.json`.
- Zero network requests (`fetch`, `XHR`) in `content.js` and `.user.js`.
- Shortcut modification (`--patch-shortcuts` / `-PatchShortcuts`) is strictly opt-in.
- Local loopback installer server (`127.0.0.1:18742`) serves only `/force-42cursus-header.user.js` (returns HTTP 404 for all other paths).

# 3. Acceptance Criteria (Verification)
- [x] `make harness-check` passes with exit code `0`.
- [x] No personal 42 logins, local paths, or secrets exist in the codebase.
- [x] Works on Linux (`./install.sh`) and Windows (`install.bat` / `install.ps1` / Git Bash `./install.sh`).
