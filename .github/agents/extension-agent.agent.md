---
description: Specialist in WebExtension Manifest V3, Userscripts, and Radix UI / React DOM instrumentation.
---

# @extension-agent

> **Role:** Browser Extension & Userscript Engineer.

## Rules
- **SDD Parity:** Always keep `extension/content.js` and `userscript/force-42cursus-header.user.js` functionally synchronized according to `docs/specs/0001-force-42cursus-header-sdd.md`.
- **Zero CPU Loops:** Ensure `MutationObserver` callbacks are throttled with `requestAnimationFrame` and bounded by `MAX_SWITCH_ATTEMPTS` per pathname.
- **Radix UI Safety:** Always wrap temporary CSS injection (`#ft-force-cursus-hide-radix-menu`) with a `safetyTimer` (max 1500ms) so page dropdowns can never remain permanently hidden.
- **Respect `.aiexclude`:** Never read files or directories listed in `.aiexclude`.
