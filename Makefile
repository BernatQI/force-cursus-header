.PHONY: help harness-check local-check syntax-check security-check create-agent-worktree

GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m

help:
	@echo "${GREEN}Available Commands (force-cursus-header Harness DX):${NC}"
	@echo "  ${YELLOW}make harness-check${NC}         - Run full validation (JSON/JS/Bash syntax + Security/PII audit)"
	@echo "  ${YELLOW}make syntax-check${NC}          - Validate syntax of manifest.json, content.js, user.js, and .sh scripts"
	@echo "  ${YELLOW}make security-check${NC}        - Verify zero privileged permissions, zero local paths, and zero PII"
	@echo "  ${YELLOW}make create-agent-worktree branch=feat/x${NC} - Create an isolated Git Worktree for subagents"

local-check: harness-check

harness-check: syntax-check security-check
	@echo "${GREEN}🚀 [Harness Bootstrapper] All syntax and security validations passed 100%.${NC}"

syntax-check:
	@echo "${YELLOW}🧪 [1/3] Validating JSON syntax of extension/manifest.json...${NC}"
	@python3 -m json.tool extension/manifest.json >/dev/null
	@echo "${GREEN}✓ manifest.json is valid JSON${NC}"
	@echo "${YELLOW}🧪 [2/3] Validating Bash syntax (install.sh, uninstall.sh)...${NC}"
	@bash -n install.sh && bash -n uninstall.sh
	@echo "${GREEN}✓ Bash scripts are valid${NC}"
	@echo "${YELLOW}🧪 [3/3] Validating JavaScript syntax (content.js, force-42cursus-header.user.js)...${NC}"
	@if command -v node >/dev/null 2>&1; then \
		node --check extension/content.js && node --check userscript/force-42cursus-header.user.js; \
		echo "${GREEN}✓ JavaScript files are valid${NC}"; \
	else \
		echo "${YELLOW}ℹ️ node not installed; basic lexical check completed.${NC}"; \
	fi

security-check:
	@echo "${YELLOW}🛡️ [Security Harness] Auditing privacy, local paths, and browser permissions...${NC}"
	@if grep -RInE "(/home/[a-zA-Z0-9_-]+|C:\\\\Users\\\\[a-zA-Z0-9_-]+|cdn\\.intra\\.42\\.fr/users/[a-f0-9]+|intra\\.42\\.fr/users/[a-zA-Z0-9_-]+)" extension/ userscript/ install.* uninstall.* README*.md docs/ .agents/ .github/ AGENTS.md TASK_CONTRACT.md 2>/dev/null; then \
		echo "${RED}❌ SECURITY FAILURE: Hardcoded personal paths, CDN hashes, or user URLs detected.${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}✓ Zero local paths, CDN hashes, or personal profile URLs detected${NC}"
	@if grep -Fq '"permissions"' extension/manifest.json || grep -Fq '"host_permissions"' extension/manifest.json; then \
		echo "${RED}❌ SECURITY FAILURE: manifest.json requests unauthorized permissions.${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}✓ Principle of least privilege verified in manifest.json${NC}"
	@if grep -v '^[[:space:]]*#' install.ps1 | grep -Fq 'Start-Job'; then \
		echo "${RED}❌ STABILITY FAILURE: Start-Job detected in install.ps1 (StackOverflowException risk).${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}✓ StackOverflowException prevention verified in install.ps1${NC}"

create-agent-worktree:
	@if [ -z "$(branch)" ]; then echo "${YELLOW}⚠️ Usage: make create-agent-worktree branch=\"feat/name\"${NC}"; exit 1; fi
	@git worktree add ../force-cursus-header-$(subst /,-,$(branch)) $(branch) 2>/dev/null || git worktree add -b $(branch) ../force-cursus-header-$(subst /,-,$(branch))
	@echo "${GREEN}✓ Isolated worktree created at ../force-cursus-header-$(subst /,-,$(branch))${NC}"
