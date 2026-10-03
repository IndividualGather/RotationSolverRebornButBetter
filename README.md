# RotationSolverRebornButBetter

An unofficial fork of [Rotation Solver Reborn](https://github.com/FFXIV-CombatReborn/RotationSolverReborn)
by The Combat Reborn Team. All credit for the plugin goes to the original authors. This repo is not affiliated with
or supported by them; please don't report issues with this fork upstream.

## Why this fork exists

The official plugin only runs the rotations built into it. This fork is an automated build
with a small patch that loads extra rotation DLLs from
`%APPDATA%\XIVLauncher\pluginConfigs\RotationSolver\CustomRotations\`.

## How it works

`.github/workflows/release.yml` runs every 4 hours (and on changes to `patches/`):

1. Finds the newest upstream release tag (e.g. `7.5.6.13`).
2. Clones that tag and applies `patches/*.patch` with `git am`.
3. Builds as version `<major>.<minor>.<build>.<revision*100 + PATCH_REVISION>` (e.g. `7.5.6.1301`).
4. Publishes a GitHub release and updates `repo.json`.

If the patches stop applying, the run fails and GitHub notifies you.

## Install

1. Uninstall the official Rotation Solver Reborn (same internal name; settings are kept).
2. Dalamud Settings > Experimental > Custom Plugin Repositories, add
   `https://raw.githubusercontent.com/IndividualGather/RotationSolverRebornButBetter/main/repo.json`.
3. Install "RotationSolverRebornButBetter".

## Updating the patch

The patch lives as a commit on top of upstream `main` (branch `custom-loader` in the RSR checkout):

```sh
git format-patch origin/main..custom-loader -o <this repo>/patches
```

Bump `PATCH_REVISION` whenever the patch changes so Dalamud sees a newer version.

## Branding

`patches/0002-*` gives the settings window teal accents, the teal logo from `branding/Logo.png` and a
"RotationSolverRebornButBetter" title. The workflow also renames the plugin in its manifest. The internal
name stays `RotationSolver`, so settings and other plugins' RSR integrations are unaffected.
