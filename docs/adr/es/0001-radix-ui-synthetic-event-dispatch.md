# ADR-0001: Despacho de Eventos Sintéticos en Radix UI Select y CSS Anti-Parpadeo

**Estado:** Aceptado  
**Fecha:** 2026-10-21  
**Decisores:** Equipo de Arquitectura

## Contexto y Problema
El header del dashboard de 42 Intra v3 utiliza `@radix-ui/react-select` (`button[role="combobox"]`). Un `.click()` estándar no abre el desplegable de Radix UI, y abrirlo visualmente produce un parpadeo molesto. Además, si un usuario solo tiene *C Piscine* (sin *42cursus*), reintentar indefinidamente en el `MutationObserver` provocaría un bucle infinito.

## Decisión
Emitir la secuencia sintética `PointerEvent` + `KeyboardEvent` ocultando temporalmente el portal con CSS (`opacity: 0 !important` con temporizador de seguridad de 1500ms) y limitar los intentos a `MAX_SWITCH_ATTEMPTS = 2` por ruta.
