# Hooks: SableOS Native changes to Marathon's own files

Every change to a file outside `sable/` (and outside the SableOS-only files
`NOTICE`, `BRANDING.md`, `.github/README.md`, `.github/dependabot.yml`
and `.github/workflows/sable-*.yml`) is listed here. Keep each one small: a
signal, a setting, or a loader for SableOS QML. If a hook conflicts on two
syncs in a row, propose it upstream (`SYNC.md`).

| File | Change | Why | Upstreamable? | Added |
|---|---|---|---|---|
| `CMakeLists.txt` | `add_subdirectory(sable)` after `add_subdirectory(crates)` | Registers SableOS tests (`sable/CMakeLists.txt`) with CTest, so Marathon's CI runs them and `Lint_TestReachability` passes | No (SableOS only) | 2026-11-15 |
| `crates/**` (75 files in 18 crates) | `fix(crates): pass clippy 1.100`: all 130 `.map(f).unwrap_or_default()` chains changed to `.map_or_default(f)`, one redundant `clone()` removed in `keel-actions-codegen` | Alpine edge moved to Rust 1.100; its clippy fails Marathon's `-D warnings` step. `map_or_default` needs Rust 1.100 or newer | Yes: offer to Marathon; drop ours once merged upstream | 2026-11-15 |
