# SableOS Native

SableOS Native is the Linux edition of SableOS: a BlackBerry 10-style phone OS
built on [Marathon OS](https://github.com/patrickjquinn/Marathon-Shell), with a
Qt 6 / QML shell and system services written in Rust. The Android editions of
SableOS live in their own repositories and are not built from here.

**Status: early development. There is no SableOS Native image to install yet.**

| Device | Backend | Status |
|---|---|---|
| Zinwa Q25 | Marathon's MT6789 platform | First target; base being validated |
| Unihertz Titan 2 | Serlk's MT6878 mainline Linux | On hold: source-only assessment |

## What SableOS Native adds to Marathon

- **Flow:** one continuous gesture to minimise an app, peek at the Hub, and come back.
- **Hub:** every message, call and notification in one list, with Priority Hub and filters.
- **Frames:** running apps as live frames, next to the Hub and the app grid.
- **Keyboard first:** Call, Menu, Back and End keys with their BB10 meanings, list
  shortcuts (T, B, N, P, Space) and type-anywhere search.
- **Rust services:** `sable-hubd`, `sable-framesd`, `sable-inputd`, `sable-searchd`,
  sharing one settings crate, `sable-settings`.

## How this repository is organised

This repository carries Marathon-Shell's full history. Marathon's tree stays as
close to upstream as possible; SableOS Native work lives under [`sable/`](../sable).

| Path | What it is |
|---|---|
| `sable/shell/` | Flow engine, Hub, Frames, lock screen, status bar (QML) |
| `sable/components/` | `Sable.Components`, the BB10 control library |
| `sable/crates/` | SableOS Native's Rust workspace |
| `sable/apps/` | SableOS Phone, Messages, Mail, Calendar, Contacts |
| `sable/device/<device>/` | Per-phone backend: keys, gestures, modem, audio, image |
| `sable/docs/` | Architecture, sync policy, hooks into Marathon |
| everything else | Marathon OS, merged from `upstream` |

Branches: `main` is SableOS Native. `upstream` mirrors Marathon's
`release/q25-v1`. See [`sable/docs/SYNC.md`](../sable/docs/SYNC.md).

## Build and check locally (Ubuntu)

Scripts in `sable/scripts/` run the same checks as CI, on Ubuntu 24.04 or newer:

```sh
sable/scripts/setup-ubuntu.sh        # once: rustfmt, clippy, cargo-deny, zizmor, gitleaks, podman
sable/scripts/check.sh               # format, clippy, tests, cargo-deny, Marathon's test lint
sable/scripts/security.sh            # secrets, dependency and workflow checks (--full: whole history)
sable/scripts/build-marathon.sh      # Marathon's full build and tests in alpine:edge (--arm64 like CI)
```

Marathon's own build, simulator and image instructions are in
[`README.md`](../README.md) and [`docs/BUILDING.md`](../docs/BUILDING.md).

## Credits and licence

SableOS Native is a fork of Marathon OS by Patrick Quinn and its contributors,
used under the Apache License 2.0. "Marathon" is their name and is not used for
this product. See [`NOTICE`](../NOTICE) and [`LICENSE`](../LICENSE).
BlackBerry and BB10 are trademarks of their owners; SableOS is not affiliated with them.
