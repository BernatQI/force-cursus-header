# ADR-0002: Auto-Instalador No Intrusivo en Espacio de Usuario y HttpListener en Hilo Principal

**Estado:** Aceptado  
**Fecha:** 2026-10-21  
**Decisores:** Equipo de Arquitectura

## Contexto y Problema
En Windows PowerShell 5.1, el uso de `Start-Job` y `Get-ChildItem -Recurse` provocaba `StackOverflowException` debido a la carga recursiva del `$PROFILE` en un runspace hijo y a enlaces simbólicos circulares en Windows. Además, modificar los accesos directos `.lnk` / `.desktop` por defecto podía dejar flags huérfanos si el usuario borraba la carpeta manualmente.

## Decisión
Ejecutar `HttpListener` directamente en el hilo principal tras lanzar el navegador asíncronamente con `Start-Process` (cero `Start-Job`), servir únicamente `/force-42cursus-header.user.js`, y hacer que el parcheo de accesos directos sea estrictamente opcional (`--patch-shortcuts` / `-PatchShortcuts`).
