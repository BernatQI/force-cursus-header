---
title: "Especificación (SDD): Selector Automático 42cursus e Instalador Multiplataforma"
status: "Implemented"
date: "2026-10-21"
author: "BernatQi"
---

# 1. Contexto y Objetivo
El dashboard de perfil de 42 Intra v3 (`profile.intra.42.fr`) selecciona por defecto *C Piscine* o *Piscine Reloaded* en lugar de `42cursus`. Esta especificación define la extensión Manifest V3, el Userscript y el auto-instalador multiplataforma (Linux y Windows).

# 2. Especificación de Comportamiento
- **Happy Path:** Detecta `button[role="combobox"]`, oculta temporalmente el portal Radix UI con CSS (con salvaguarda de 1500ms), abre el selector y elige `42cursus`.
- **Sad Paths:**
  1. Si el usuario no tiene `42cursus`, se detiene tras `MAX_SWITCH_ATTEMPTS = 2` intentos para no consumir CPU.
  2. Si el usuario hace clic manual (`event.isTrusted`), respeta su elección.
  3. En Windows PowerShell, corre en el hilo principal sin `Start-Job` para evitar `StackOverflowException`.
