# Hooks: SableOS Native changes to Marathon's own files

Every change to a file outside `sable/` (and outside the SableOS-only files
`NOTICE`, `BRANDING.md`, `.github/README.md`, `.github/dependabot.yml`
and `.github/workflows/sable-*.yml`) is listed here. Keep each one small: a
signal, a setting, or a loader for SableOS QML. If a hook conflicts on two
syncs in a row, propose it upstream (`SYNC.md`).

| File | Change | Why | Upstreamable? | Added |
|---|---|---|---|---|
| `CMakeLists.txt` | `add_subdirectory(sable)` after `add_subdirectory(crates)` | Registers SableOS tests (`sable/CMakeLists.txt`) with CTest, so Marathon's CI runs them and `Lint_TestReachability` passes | No (SableOS only) | 2026-11-15 |
