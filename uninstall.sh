#!/usr/bin/env bash
# ==============================================================================
# 42 Intra - Force 42cursus Header | Uninstaller (Linux & WSL)
# Restores any modified .desktop launchers and removes ~/.local/share artifacts.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "${SCRIPT_DIR}/uninstall.ps1")" "$@"
    exit $?
    ;;
esac
if [[ -n "${WSL_DISTRO_NAME:-}" ]] && command -v powershell.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "${SCRIPT_DIR}/uninstall.ps1")" "$@"
  exit $?
fi

INSTALL_BASE_DIR="${HOME}/.local/share/force-cursus-header"
LOCAL_APPS_DIR="${HOME}/.local/share/applications"

echo "=== Uninstalling 42 Intra - Force 42cursus Header ==="

# 1. Clean up any flags injected into ~/.local/share/applications/*.desktop
if [[ -d "${LOCAL_APPS_DIR}" ]]; then
  for desktop_file in "${LOCAL_APPS_DIR}"/*.desktop; do
    [[ -e "${desktop_file}" ]] || continue
    if grep -q "force-cursus-header" "${desktop_file}"; then
      sed -i "s| --disable-features=DisableLoadExtensionCommandLineSwitch||g; s| --load-extension=[^ ]*force-cursus-header/extension||g" "${desktop_file}"
      echo "[✓] Restored launcher: ${desktop_file}"
    fi
  done
fi

# 2. Remove local installation directory
if [[ -d "${INSTALL_BASE_DIR}" ]]; then
  rm -rf "${INSTALL_BASE_DIR}"
  echo "[✓] Removed directory: ${INSTALL_BASE_DIR}"
fi

echo "=== Uninstallation Completed ==="
