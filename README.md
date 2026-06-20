# Raid Names Copy

A tiny, dependency-free World of Warcraft addon (Classic Era / Season of Discovery).

**One click on the minimap button grabs every raid member's name, ready to paste.**

## Why a popup instead of "real" clipboard copy?

The WoW addon API can't write to your OS clipboard. So, like every copy-paste
addon, this pops up a small box with the names already selected — just press
**Ctrl+C**, then paste wherever you like.

## Usage

- **Left-click** the minimap button (scroll icon): collects names and shows them,
  one per line, pre-highlighted. Press **Ctrl+C** to copy.
- **Drag** the button to reposition it around the minimap.

Behavior by group:

- In a **raid**: every raid member (realm suffix stripped for clean names).
- In a **party**: you plus your party members.
- **Solo**: just you.

## Install

Copy the `RaidNamesCopy` folder into:

```
World of Warcraft/_classic_era_/Interface/AddOns/
```

Then `/reload` or restart the client and enable it on the AddOns list.

## Releases

Tagged commits are packaged automatically by
[BigWigsMods/packager](https://github.com/BigWigsMods/packager) via GitHub
Actions and attached to the GitHub Release. To cut a release:

```sh
git tag v1.0
git push origin v1.0
```

Add `CF_API_KEY` / `WOWI_API_TOKEN` / `WAGO_API_TOKEN` repo secrets to also
publish to CurseForge / WoWInterface / Wago.
