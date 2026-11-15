# SableOS Native coding and security rules

SableOS Native follows Marathon's rules and adds stricter ones for the code it
owns (`sable/`). Where the two differ, the SableOS rule wins inside `sable/`.

## 1. Inherited from Marathon (all code)

- **C++ and QML:** [`docs/CODING_RULES.md`](../../docs/CODING_RULES.md), sections
  A (banned patterns), B (C++ / Qt) and C (QML). Mechanical checks:
  `scripts/lint.sh` (qmllint, clazy, clang-tidy).
- **Formatting:** clang-format, qmlformat (Qt 6) and rustfmt; enforced by
  Marathon's `format.yml`.
- **Commits:** Conventional Commits (`feat`, `fix`, `perf`, `revert` appear in
  release notes; `build`, `chore`, `ci`, `docs`, `refactor`, `style`, `test`
  do not). Enforced by the `commit-subjects` job in Marathon's `ci.yml`.

## 2. Rust in `sable/crates`

Enforced by `sable/crates/Cargo.toml` lints and `.github/workflows/sable-ci.yml`:

- No `unsafe` (`unsafe_code = "forbid"`). A crate that truly needs it moves the
  unsafe part into a reviewed, separate crate with `// SAFETY:` comments.
- Clippy pedantic plus Marathon's restriction lints, as errors: no `unwrap`,
  `expect`, `panic!`, `todo!`, `dbg!`, `println!` in library or daemon code.
- Errors are typed (an `enum` per crate) and carry the field or source that
  failed. Never swallow an error; log it through `tracing` and return it.
- Every public item has a doc comment; every crate has unit tests that run in
  `cargo test` without a phone (mock D-Bus services for daemons).
- Dependencies: added with `cargo add`, must pass `cargo deny check`
  (`sable/crates/deny.toml`): no known vulnerabilities, Apache-2.0-compatible
  licences only, crates.io only.

## 3. Security rules for daemons and the shell

- **Treat every D-Bus message as untrusted.** Check sender, types, lengths and
  ranges before use; reject, don't clamp silently.
- **Least privilege.** Daemons run as the user session, never as root, with a
  systemd unit that sets `NoNewPrivileges`, `ProtectSystem=strict`,
  `PrivateTmp` and only the paths they need.
- **No network** from `sable-*` daemons unless the design doc says why; mail
  and calendar traffic stays in Marathon's `maild` and `davd`.
- **Private data stays private.** Hub previews are redacted on the lock screen;
  logs never contain message bodies, phone numbers, IMEI or serial numbers.
- **No secrets in the repository.** Keys, tokens and signing material live in
  GitHub secrets or offline; Gitleaks blocks new ones in pull requests.
- **Proprietary firmware is never committed** (see `NOTICE`).

## 4. Workflows

- Every action is pinned by full commit SHA with the version in a comment.
- `permissions:` is set at the workflow level to `contents: read`; jobs ask for
  more only when needed.
- `actions/checkout` uses `persist-credentials: false`.
- New or changed SableOS workflows must pass zizmor (`sable-security.yml`).

## 5. What CI checks

| Check | Workflow | Blocks merge? |
|---|---|---|
| Format, clippy `-D warnings`, tests for `sable/crates` | `sable-ci.yml` (`sable-rust`) | Yes |
| Secrets in the pull request's commits (Gitleaks) | `sable-security.yml` (`sable-secrets`) | Yes |
| Rust advisories, licences, sources (`cargo deny`) for `sable/crates` | `sable-security.yml` (`sable-rust-deps`) | Yes |
| Workflow security audit (zizmor) for SableOS workflows | `sable-security.yml` (`sable-workflows`) | Yes |
| CodeQL for Rust under `sable/` and all workflows | `sable-security.yml` (`sable-codeql`) | Findings in the Security tab |
| Marathon crates advisories, Marathon workflows audit, full-history secrets | `sable-security.yml` | No, report only |
| Commit subjects, build and tests, formatting (whole tree) | Marathon's `ci.yml`, `format.yml` | `commit-subjects` should; others optional |
