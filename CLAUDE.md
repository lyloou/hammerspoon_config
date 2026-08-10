# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Hammerspoon macOS automation config written in Lua. Hammerspoon exposes macOS APIs to Lua scripts, enabling hotkeys, window management, and system automation. The config is loaded at `~/.hammerspoon/init.lua`.

## Reloading the config

After editing any `.lua` file, reload with **Cmd+Shift+Ctrl+R** (or via the Hammerspoon menu bar icon → Reload Config). Changes are not live until reloaded. Errors appear in the Hammerspoon console (Option+Q, then Z, or menu bar → Open Console).

## Architecture

**`init.lua`** — main entry point. Loads the configuration table, initializes `ModalMgr` and configured Spoons, implements named function actions, then binds modals and global aliases. It owns runtime behavior only.

**`private/config.lua`** — personal configuration. It returns a declarative table with enabled Spoons, app launcher entries, actions, hotkeys, brightness bindings, and global aliases. It must not call `hs.*` APIs or define executable functions.

**`Spoons/`** — self-contained Hammerspoon modules (each a directory with `init.lua`). Key ones:
- `ModalMgr` — foundation for all modal modes; `spoon.ModalMgr.supervisor` is the always-on keymap
- `WinWin` — window move/resize operations called from the `resizeM` modal

## Modal pattern

All features use a two-level key structure: a **supervisor** binding (always active) activates a named modal, then keys inside that modal do work. Every modal exits on `Esc` or `Q`. The supervisor itself can be suspended with Cmd+Shift+Ctrl+Q.

Example flow for window management: `Alt+R` → enters `resizeM` modal → `H/L/K/J` snap to half-screens → `Esc` exits.

## Customization points in `private/config.lua`

| Field | Purpose |
|---|---|
| `spoons` | Spoons to load (array of name strings) |
| `apps` | App launcher entries `{key, name/id}` for appM modal |
| `actions` | Quick-action entries. `function` actions reference a handler name implemented in `init.lua`. |
| `hotkeys` | Prefix and global hotkeys. Use `false` to disable an optional binding. |
| `brightness` | BrightnessControl hotkey mapping. |
| `globalAliases` | Optional direct aliases to configured actions. |
