# RotationSolver (patched)

Automated build of [RotationSolverReborn](https://github.com/FFXIV-CombatReborn/RotationSolverReborn)
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
   `https://raw.githubusercontent.com/IndividualGather/RotationSolverReborn-Custom/main/repo.json`.
3. Install "Rotation Solver Reborn (Custom)".

## Updating the patch

The patch lives as a commit on top of upstream `main` (branch `custom-loader` in the RSR checkout):

```sh
git format-patch origin/main..custom-loader -o <this repo>/patches
```

Bump `PATCH_REVISION` whenever the patch changes so Dalamud sees a newer version.
