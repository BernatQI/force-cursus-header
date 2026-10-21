# ADR-0001: Radix UI Select Synthetic Pointer/Keyboard Dispatch & Anti-Flicker CSS

**Status:** Accepted  
**Date:** 2026-10-21  
**Deciders:** Architecture Team

## Context and Problem Statement

The 42 Intra v3 dashboard header uses `@radix-ui/react-select` (`button[role="combobox"]`) to switch between the user's cursus experiences (*C Piscine*, *Piscine Reloaded*, *42cursus*). Standard `.click()` events do not open Radix UI triggers, and opening the portal visually causes an unwanted dropdown flash on page load. Furthermore, if a user only has *C Piscine* (no *42cursus*), unbounded `MutationObserver` retries could cause an infinite DOM mutation loop.

## Considered Options

1. **Direct URL redirect to `/experiences/cursus_id/21`** — Navigates away from the main dashboard view.
2. **Synthetic `PointerEvent` + `KeyboardEvent` sequence with temporary CSS portal hiding and bounded attempts (`MAX_SWITCH_ATTEMPTS = 2`)** — Updates React state in-place on the dashboard without visual flicker.

## Decision Outcome

Chosen option: **Option 2**, because it updates the React component state natively in-place, keeps the user on the dashboard, prevents visual flicker via a temporary `<style>` rule (`opacity: 0 !important` with a 1500ms safety timeout), and bounds retries to at most 2 attempts per pathname.
