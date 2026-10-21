#!/usr/bin/env bash
# ==============================================================================
# 42 Intra - Force 42cursus Header | Cross-Platform Auto-Installer (Linux & WSL)
# Detects installed browsers (Chrome, Brave, Chromium, Edge, Firefox) and
# installs the extension / userscript in user space (~/.local/share).
# By default, it does NOT mutate system/user .desktop launchers unless the
# explicit --patch-shortcuts flag is passed.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Delegate to install.ps1 when executed from Git Bash / MSYS2 / Cygwin / WSL on Windows
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "Windows environment (Git Bash/MSYS) detected. Delegating to install.ps1 via PowerShell..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "${SCRIPT_DIR}/install.ps1")" "$@"
    exit $?
    ;;
esac
if [[ -n "${WSL_DISTRO_NAME:-}" ]] && command -v powershell.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
  echo "Windows environment (WSL) detected. Delegating to install.ps1 on Windows host..."
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "${SCRIPT_DIR}/install.ps1")" "$@"
  exit $?
fi

INSTALL_BASE_DIR="${HOME}/.local/share/force-cursus-header"
EXT_INSTALL_DIR="${INSTALL_BASE_DIR}/extension"
USERSCRIPT_INSTALL_PATH="${INSTALL_BASE_DIR}/force-42cursus-header.user.js"
LOCAL_APPS_DIR="${HOME}/.local/share/applications"

PATCH_SHORTCUTS=0
NO_BROWSER=0
for arg in "$@"; do
  case "${arg}" in
    --patch-shortcuts) PATCH_SHORTCUTS=1 ;;
    --no-browser) NO_BROWSER=1 ;;
  esac
done

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== 42 Intra - Force 42cursus Header (Auto-Installer) ===${NC}"

# 1. Copy files to a persistent user-space directory with strict 700 permissions
mkdir -p "${EXT_INSTALL_DIR}"
chmod 700 "${INSTALL_BASE_DIR}"
cp -r "${SCRIPT_DIR}/extension/"* "${EXT_INSTALL_DIR}/"
cp "${SCRIPT_DIR}/userscript/force-42cursus-header.user.js" "${USERSCRIPT_INSTALL_PATH}"
echo -e "${GREEN}[✓]${NC} Files installed in isolated user directory: ${INSTALL_BASE_DIR}"

# 2. Detect installed browsers in PATH
CHROMIUM_BROWSERS=(
  "google-chrome:google-chrome.desktop:Google Chrome"
  "google-chrome-stable:google-chrome.desktop:Google Chrome (Stable)"
  "brave-browser:brave-browser.desktop:Brave Browser"
  "chromium:chromium.desktop:Chromium"
  "chromium-browser:chromium-browser.desktop:Chromium Browser"
  "microsoft-edge:microsoft-edge.desktop:Microsoft Edge"
)

DETECTED_BINS=()

configure_chromium_desktop() {
  local desktop_file="$1"
  local pretty_name="$2"

  mkdir -p "${LOCAL_APPS_DIR}"
  local sys_desktop=""
  if [[ -f "/usr/share/applications/${desktop_file}" ]]; then
    sys_desktop="/usr/share/applications/${desktop_file}"
  elif [[ -f "/var/lib/flatpak/exports/share/applications/${desktop_file}" ]]; then
    sys_desktop="/var/lib/flatpak/exports/share/applications/${desktop_file}"
  fi

  local target_desktop="${LOCAL_APPS_DIR}/${desktop_file}"
  local ext_flags="--load-extension=${EXT_INSTALL_DIR}"

  if [[ -n "${sys_desktop}" ]]; then
    if [[ ! -f "${target_desktop}" ]]; then
      cp "${sys_desktop}" "${target_desktop}"
    fi
    if ! grep -q "force-cursus-header" "${target_desktop}"; then
      sed -i "s|^Exec=\(/[^ ]*\) |Exec=\1 ${ext_flags} |g" "${target_desktop}"
      echo -e "${GREEN}[✓]${NC} Configured .desktop launcher for ${pretty_name}: ${target_desktop}"
    fi
  fi
}

echo ""
echo -e "${CYAN}Scanning for installed browsers...${NC}"

for entry in "${CHROMIUM_BROWSERS[@]}"; do
  IFS=":" read -r bin desktop name <<< "${entry}"
  if command -v "${bin}" >/dev/null 2>&1; then
    echo -e "${GREEN}[Detected]${NC} ${name} ($(command -v "${bin}"))"
    DETECTED_BINS+=("${bin}")
    if [[ ${PATCH_SHORTCUTS} -eq 1 ]]; then
      configure_chromium_desktop "${desktop}" "${name}"
    fi
  fi
done

if command -v firefox >/dev/null 2>&1; then
  echo -e "${GREEN}[Detected]${NC} Mozilla Firefox ($(command -v firefox))"
  DETECTED_BINS+=("firefox")
fi

if [[ ${#DETECTED_BINS[@]} -eq 0 ]]; then
  echo -e "${YELLOW}[!] No standard browsers detected in PATH.${NC}"
  exit 0
fi

# Copy extension path to clipboard if wl-copy or xclip is available
if command -v wl-copy >/dev/null 2>&1; then
  printf "%s" "${EXT_INSTALL_DIR}" | wl-copy || true
  echo -e "${GREEN}[✓]${NC} Path '${EXT_INSTALL_DIR}' copied to clipboard (Wayland)."
elif command -v xclip >/dev/null 2>&1; then
  printf "%s" "${EXT_INSTALL_DIR}" | xclip -selection clipboard || true
  echo -e "${GREEN}[✓]${NC} Path '${EXT_INSTALL_DIR}' copied to clipboard (X11)."
fi

# 3. Serve exclusively the .user.js file on loopback (no directory listing)
if [[ ${NO_BROWSER} -eq 0 ]] && command -v python3 >/dev/null 2>&1; then
  echo ""
  echo -e "${CYAN}Opening installer in detected browsers...${NC}"
  PORT=18742
  python3 - "${PORT}" "${USERSCRIPT_INSTALL_PATH}" >/dev/null 2>&1 << 'EOF' &
import http.server, socketserver, sys, time

port = int(sys.argv[1])
file_path = sys.argv[2]
with open(file_path, "rb") as f:
    payload = f.read()

class SingleFileHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/force-42cursus-header.user.js":
            self.send_response(200)
            self.send_header("Content-Type", "application/javascript; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        else:
            self.send_error(404)
    def log_message(self, format, *args):
        pass

with socketserver.TCPServer(("127.0.0.1", port), SingleFileHandler) as httpd:
    httpd.timeout = 1
    end = time.time() + 6
    while time.time() < end:
        httpd.handle_request()
EOF
  SERVER_PID=$!
  trap 'kill "${SERVER_PID}" >/dev/null 2>&1 || true' EXIT

  sleep 0.4
  USERSCRIPT_URL="http://127.0.0.1:${PORT}/force-42cursus-header.user.js"

  OPENED_CHROME=0
  for bin in "${DETECTED_BINS[@]}"; do
    if [[ "${bin}" == "firefox" ]]; then
      firefox "${USERSCRIPT_URL}" >/dev/null 2>&1 &
    elif [[ ${OPENED_CHROME} -eq 0 ]]; then
      "${bin}" --load-extension="${EXT_INSTALL_DIR}" "${USERSCRIPT_URL}" >/dev/null 2>&1 &
      OPENED_CHROME=1
    fi
  done

  echo -e "${YELLOW}[i] Serving Userscript locally for 6 seconds at '${USERSCRIPT_URL}'...${NC}"
  wait "${SERVER_PID}" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}=== Installation Completed ===${NC}"
echo -e "  • Extension folder (copied to clipboard): ${EXT_INSTALL_DIR}"
echo -e "  • In Chrome/Brave/Edge: open chrome://extensions -> Developer mode -> Load unpacked -> paste path."
echo -e "  • To uninstall at any time: ./uninstall.sh"
