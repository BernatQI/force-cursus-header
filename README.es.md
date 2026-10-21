# 42 Intra — Force `42cursus` Header (Documentación en Español)

> 🌐 **Idioma / Language:** [🇬🇧 English (Primary — README.md)](./README.md) | **🇪🇸 Español (Secundario)**

Extensión ligera de navegador (WebExtension Manifest V3), Userscript y auto-instalador multiplataforma en espacio de usuario (Linux y Windows) diseñada para forzar automáticamente que el selector de cursus en el header del dashboard de 42 Intra v3 (`profile.intra.42.fr` / `profile-v3.intra.42.fr`) muestre **`42cursus`** (p. ej. `Cadet at 42cursus`) por defecto en lugar de *C Piscine* o *Piscine Reloaded*.

---

## Inicio Rápido (Quick Start)

### En Linux (Cluster de 42 o PC personal — No requiere `sudo`)
```bash
git clone https://github.com/BernatQI/force-cursus-header.git
cd force-cursus-header
./install.sh
```
*(Para desinstalar en cualquier momento: `./uninstall.sh`)*

### En Windows (Doble clic, PowerShell o Git Bash — No requiere Administrador)
1. Clona o descarga el repositorio:
   ```powershell
   git clone https://github.com/BernatQI/force-cursus-header.git
   cd force-cursus-header
   ```
2. **Opción más rápida:** Haz **doble clic sobre `install.bat`** desde el Explorador de Windows, o ejecuta en PowerShell / CMD:
   ```powershell
   .\install.bat
   ```
   *(También puedes ejecutar `./install.sh` desde **Git Bash** o **WSL**; el script detecta Windows automáticamente y delega en `install.ps1`).*
3. *(Para desinstalar en Windows: haz doble clic en `uninstall.bat` o ejecuta `.\uninstall.bat`).*

---

## Arquitectura y Funcionamiento Técnico

### 1. El Problema en la Intra v3 de 42
El frontend del perfil de la Intra v3 está construido con **React (Next.js)**, **Tailwind CSS** y primitivas accesibles de **Radix UI** (`@radix-ui/react-select`). Al cargar el dashboard, el selector suele hidratarse con el primer cursus histórico (*C Piscine* o *Piscine Reloaded*) en lugar del cursus principal (`42cursus`, `cursus_id = 21`).

### 2. ¿Por qué no funciona un `.click()` estándar?
Los componentes `<Select.Trigger>` y `<Select.Item>` de **Radix UI** requieren eventos **`pointerdown`** (`button === 0 && ctrlKey === false`) o teclado (`ArrowDown`) para montar el portal `<div role="listbox">`, y la secuencia `pointermove` → `pointerdown` → `pointerup` → `click` / `Enter` sobre la opción `<div role="option">` para disparar `onValueChange` en React.

### 3. Garantías de Seguridad, Privacidad y Estabilidad
- **Cero permisos privilegiados:** `extension/manifest.json` no solicita `permissions` ni `host_permissions`. Solo se ejecuta en `https://profile.intra.42.fr/*` y `https://profile-v3.intra.42.fr/*`.
- **Cero llamadas de red / Cero telemetría:** 100% local en el DOM.
- **Cero bucles infinitos:** El `MutationObserver` está regulado con `requestAnimationFrame` y limitado a `MAX_SWITCH_ATTEMPTS = 2` por ruta.
- **Sin `StackOverflowException` en Windows:** `install.ps1` se ejecuta íntegramente en el hilo principal sin `Start-Job` ni escaneos recursivos de `.lnk`.
- **Instalador no intrusivo:** Por defecto no modifica los accesos directos globales del navegador (`.desktop` / `.lnk`) salvo que se indique explícitamente `--patch-shortcuts` o `-PatchShortcuts`.

---

## Instalación Manual Paso a Paso

### Método 1: Extensión Nativa (Chrome / Brave / Chromium / Edge)
1. Abre `chrome://extensions/`.
2. Activa el **Modo de desarrollador** (arriba a la derecha).
3. Haz clic en **Cargar descomprimida** (*Load unpacked*).
4. Selecciona la carpeta `extension/` del repositorio (o pega con `Ctrl+V` la ruta que `install.bat` / `install.sh` ya ha copiado a tu portapapeles).

### Método 2: Userscript en Violentmonkey / Tampermonkey
1. Instala [Violentmonkey](https://violentmonkey.github.io/) o [Tampermonkey](https://www.tampermonkey.net/).
2. Crea un nuevo script y pega el contenido de [`userscript/force-42cursus-header.user.js`](./userscript/force-42cursus-header.user.js).
