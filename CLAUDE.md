# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Hammerspoon macOS automation config written in Lua. Hammerspoon exposes macOS APIs to Lua scripts, enabling hotkeys, window management, and system automation. The config is loaded at `~/.hammerspoon/init.lua`.

## Reloading the config

After editing any `.lua` file, reload with **Cmd+Shift+Ctrl+R** (or via the Hammerspoon menu bar icon → Reload Config). Changes are not live until reloaded. Errors appear in the Hammerspoon console (Alt+Z or menu bar → Open Console).

## Architecture

**`init.lua`** — main entry point. Loads `ModalMgr` first, then iterates `hspoon_list` to load each Spoon. Then binds all modal hotkeys. Variables like `hspoon_list`, `hsapp_list`, and `hs*_keys` have defaults in `init.lua` but are overridable.

**`private/config.lua`** — personal overrides. Loaded before hotkey binding in `init.lua`, so any variable set here takes precedence. This is where to customize which Spoons load, which apps get launch keys, and what the mode prefix keys are. `config-example.lua` is the template.

**`Spoons/`** — self-contained Hammerspoon modules (each a directory with `init.lua`). Key ones:
- `ModalMgr` — foundation for all modal modes; `spoon.ModalMgr.supervisor` is the always-on keymap
- `WinWin` — window move/resize operations called from the `resizeM` modal
- `QuickText` — text expansion triggered by typed abbreviations; configured via `QuickText_list` in private config
- `ClipShow` — clipboard panel with search/save actions
- `CountDown` — pomodoro timer

## Modal pattern

All features use a two-level key structure: a **supervisor** binding (always active) activates a named modal, then keys inside that modal do work. Every modal exits on `Esc` or `Q`. The supervisor itself can be suspended with Cmd+Shift+Ctrl+Q.

Example flow for window management: `Alt+R` → enters `resizeM` modal → `H/L/K/J` snap to half-screens → `Esc` exits.

## Customization points in `private/config.lua`

| Variable | Purpose |
|---|---|
| `hspoon_list` | Which Spoons to load (array of name strings) |
| `hsapp_list` | App launcher entries `{key, name/id}` for appM modal |
| `QuickText_list` | Text/URL/search expansions keyed by abbreviation |
| `hs*_keys` | Prefix key for each modal, e.g. `hsresizeM_keys = {"alt", "R"}` |
| `hsreload_keys` | Config reload hotkey |
| `hsupervisor_keys` | Supervisor suspend hotkey |
