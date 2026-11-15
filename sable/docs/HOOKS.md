# Hooks: SableOS Native changes to Marathon's own files

Every change to a file outside `sable/` (and outside the SableOS-only files
`NOTICE`, `BRANDING.md`, `.github/README.md`, `.github/dependabot.yml`
and `.github/workflows/sable-*.yml`) is listed here. Keep each one small: a
signal, a setting, or a loader for SableOS QML. If a hook conflicts on two
syncs in a row, propose it upstream (`SYNC.md`).

| File | Change | Why | Upstreamable? | Added |
|---|---|---|---|---|
| `CMakeLists.txt` | `add_subdirectory(sable)` after `add_subdirectory(crates)` | Registers SableOS tests (`sable/CMakeLists.txt`) with CTest, so Marathon's CI runs them and `Lint_TestReachability` passes | No (SableOS only) | 2026-11-15 |
| `crates/**` (75 files in 18 crates) | `fix(crates): pass clippy 1.100`: all 130 `.map(f).unwrap_or_default()` chains changed to `.map_or_default(f)`, one redundant `clone()` removed in `keel-actions-codegen` | Alpine edge moved to Rust 1.100; its clippy fails Marathon's `-D warnings` step. `map_or_default` needs Rust 1.100 or newer | Yes: reported as [Marathon-Shell#58](https://github.com/patrickjquinn/Marathon-Shell/issues/58); drop ours once fixed upstream | 2026-11-15 |
| `crates/keel-mcp/Cargo.toml`, `crates/pilotd/Cargo.toml`, `crates/Cargo.lock` | `fix(crates): rmcp 3.10 for RUSTSEC-2026-0462`: require rmcp 3.9+, lockfile takes 3.10.0 | RUSTSEC-2026-0462, unbounded response buffering in rmcp 3.8.0 | Yes: PR sent to Marathon for [Marathon-Shell#59](https://github.com/patrickjquinn/Marathon-Shell/issues/59); drop ours once merged upstream | 2026-11-15 |

## Reported upstream, no SableOS change

Findings in Marathon's own code that SableOS does not patch. Check them at
each sync; nothing to remove here when they are fixed.

| Issue | What | Where it shows here |
|---|---|---|
| [Marathon-Shell#59](https://github.com/patrickjquinn/Marathon-Shell/issues/59) | Unmaintained crates (the `rmcp` advisory itself is fixed by our hook above) | Report step of `sable-rust-deps` in `sable-security.yml` |
| [Marathon-Shell#60](https://github.com/patrickjquinn/Marathon-Shell/issues/60) | Workflow actions pinned by tag, unpinned `archlinux:latest` | Report step of `sable-workflows` in `sable-security.yml` |
