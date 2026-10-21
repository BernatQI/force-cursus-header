# ADR-0002: Non-Intrusive User-Space Installer & PowerShell Main-Thread HTTP Listener

**Status:** Accepted  
**Date:** 2026-10-21  
**Deciders:** Architecture Team

## Context and Problem Statement

We need an automated installer for both Linux (42 cluster machines and personal PCs) and Windows without requiring `sudo` or Administrator privileges. Initial use of `Start-Job` and `Get-ChildItem -Recurse` in Windows PowerShell 5.1 triggered `StackOverflowException` due to child runspace `$PROFILE` recursion and circular NTFS junctions. Additionally, automatically mutating `.desktop` / `.lnk` browser shortcuts by default risked leaving broken `--load-extension` flags if the user manually deleted the directory.

## Considered Options

1. **Background `Start-Job` + automatic `.lnk` / `.desktop` mutation by default.**
2. **Main-thread synchronous `HttpListener` / `SingleFileHandler` + clipboard path copy + opt-in shortcut patching (`--patch-shortcuts` / `-PatchShortcuts`).**

## Decision Outcome

Chosen option: **Option 2**, because `Start-Process` launches browsers asynchronously, allowing the HTTP listener to run safely in the main PowerShell thread for 6 seconds without spawning child PowerShell runspaces (`Start-Job`). Making shortcut patching opt-in guarantees zero unwanted modifications to the user's OS browser launchers.
