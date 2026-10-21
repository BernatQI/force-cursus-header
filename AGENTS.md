# ⚠️ AGENT AND DEVELOPER DIRECTIVES (ORCHESTRATOR & SDD) ⚠️

## 1. Architecture Decision Records (ADR — MANDATORY)

For any relevant architectural decision, structural change, or non-trivial technical challenge, an ADR (Architecture Decision Record) MUST be created.

- **Path:** `docs/adr/` (English for LLM token efficiency) & `docs/adr/es/` (Spanish mirror for human reference)
- **Template:** `docs/adr/0000-template.md`
- **Registry:** Update `docs/adr/index.md`
- **Minimum Content:** Context, Considered Options, Decision Outcome, Positive/Negative Consequences.

---

## 2. Agent Orchestration & Model Routing (MANDATORY)

**GOLDEN RULE:** The Main Agent acts strictly as the **Orchestrator (Tech Lead / Project Manager)**.

### 2.1. Helicopter View & Context Preservation
- Keep the main conversation context clean of low-level implementation noise.
- Understand requirements, maintain SDDs (`docs/specs/`) and ADRs (`docs/adr/`), update `TASK_CONTRACT.md`, and verify diffs/tests via `make harness-check`.
- Delegate multi-file code implementation, cross-platform script writing, or deep research to subagents via `invoke_subagent` (or specialized `.github/agents/` roles).

### 2.2. Model Routing Strategy
When invoking subagents or selecting models for tasks:
- **Orchestrator / Architecture / Security Audit (`pro` / High Reasoning):** Designing SDDs, reviewing security/privacy boundaries, resolving subtle DOM/OS edge cases.
- **Focused Implementation & Refactoring (`inherit` / `flash`):** Implementing well-specified changes scoped by `TASK_CONTRACT.md` and `docs/specs/`.
- **Fast Reconnaissance & Syntax Checks (`flash_lite` / `flash`):** Grepping, file discovery, formatting, and boilerplate translations.

### 2.3. Specialized Agents (`.github/agents/`)
- **[Extension Agent](.github/agents/extension-agent.agent.md)**: WebExtension Manifest V3, Userscripts, and Radix UI / React DOM instrumentation.
- **[Installer Agent](.github/agents/installer-agent.agent.md)**: Cross-platform Linux (`bash`) and Windows (`PowerShell` / `.bat`) user-space automation.
- **[Security Agent](.github/agents/security-agent.agent.md)**: Least-privilege browser permissions, zero-telemetry enforcement, PII/credential scanning, and OS script safety.
- **[Test Agent](.github/agents/test-agent.agent.md)**: Harness validation (`make harness-check`), syntax verification, and DOM edge-case testing.
- **[Docs Agent](.github/agents/docs-agent.agent.md)**: SDDs (`docs/specs/`), ADRs (`docs/adr/`), `PROJECT_ROADMAP.md`, and `/es` human mirrors.

---

## 3. Version Control & Git Workflow (STRICT)

1. **Branching Rule:** NEVER develop directly on `main`. Always work on ephemeral task branches (`feat/<name>`, `fix/<name>`, `security/<name>`, `docs/<name>`, `chore/<name>`).
2. **Conventional Commits:** All commits MUST follow `<type>(<scope>): <description>`.
3. **Explicit Merge Confirmation:** Never merge into `main` or push without explicit user confirmation.
4. **Zero Sensitive Data in History:** Never commit personal 42 logins, internal CDN hashes, local filesystem paths (`/home/...`), or credentials.

---

## 4. Token Efficiency & Context Protection (`.aiexclude`)

- Always respect `.aiexclude` in the repository root.
- Do not read `/es` translation folders (`docs/adr/es/`, `docs/specs/es/`) as LLM context when writing code; they exist exclusively for human readers.

---

## 5. Harness Engineering (Cross-Validation)

**GOLDEN RULE:** No task involving code or script modifications is complete without passing the validation harness.

- **Pre/Post Check:** Run `make harness-check` to validate:
  1. `extension/manifest.json` JSON validity and zero privileged permissions.
  2. JavaScript syntax (`node --check`) for `extension/content.js` and `userscript/force-42cursus-header.user.js`.
  3. Bash syntax (`bash -n`) for `install.sh` and `uninstall.sh`.
  4. Automated security & privacy scan (verifying no hardcoded user paths, logins, or dangerous flags exist).

---

## 6. Spec-Driven Development (SDD — MANDATORY)

1. Identify the requirement and update/create the specification in `docs/specs/` (and its Spanish counterpart in `docs/specs/es/`).
2. Scope the autonomous execution in `TASK_CONTRACT.md` (Objective, DoD, Whitelist, Guardrails).
3. Implement strictly within the whitelisted files and verify against the SDD Acceptance Criteria and Sad Paths.

---

## 7. Communication & Autonomous Guardrails

- **Transparency:** Always output the Chain of Thought, exact commands executed (with brief technical flag explanations), and `diff` blocks for modified files.
- **Autonomous Guardrails (`.agents/rules/autonomous-scope.md`):**
  - Zero `sudo` or Administrator elevation.
  - Zero file deletion without prior user confirmation.
  - Fail-Safe circuit breaker: stop and report to the user if validation fails 3–5 consecutive times.
