---
name: task-scoper
description: Interactive assistant to analyze the codebase and automatically generate the Strict Objective, Definition of Done (DoD) with make harness-check, and Allowed Scope (File Whitelist) before starting an autonomous session.
---

# 🎯 Task Scoper & Autonomous Contract Generator

This skill guides the Orchestrator and subagents in defining a precise, safe, and executable **Task Contract (`TASK_CONTRACT.md`)**.

## Workflow
1. **Codebase Recon:** Identify whether the task affects `extension/`, `userscript/`, or the cross-platform installers (`install.sh`, `install.ps1`).
2. **SDD/ADR Alignment:** Check specifications in `docs/specs/` and architectural decisions in `docs/adr/`.
3. **Update `TASK_CONTRACT.md`:** Define the Strict Objective, DoD (including `make harness-check`), Allowed Scope (Whitelist), and Active Guardrails.
