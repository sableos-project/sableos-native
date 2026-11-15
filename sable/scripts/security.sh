#!/usr/bin/env bash
# The security checks of sable-security.yml, run locally (CodeQL excepted:
# it runs on GitHub and reports in the Security tab).
#
#   sable/scripts/security.sh                 # commits since origin/main
#   sable/scripts/security.sh --base <ref>    # commits since another ref
#   sable/scripts/security.sh --full          # whole history, as the weekly job
#
# Blocking checks (exit 1 if any fails): secrets in the scanned commits,
# cargo-deny for sable/crates, zizmor for SableOS workflows.
# Report-only: Marathon's crates advisories and Marathon's workflows.
set -uo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
cd "$root" || exit 2

base=origin/main
full=false
while (($#)); do
    case "$1" in
        --full) full=true ;;
        --base) base=${2:?--base needs a ref}; shift ;;
        -h | --help) sed -n '2,11p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

for tool in gitleaks cargo-deny zizmor; do
    command -v "$tool" >/dev/null || { echo "$tool missing: run sable/scripts/setup-ubuntu.sh" >&2; exit 2; }
done

failed=()
section() { printf '\n== %s\n' "$*"; }

section "Secrets (gitleaks)"
if $full; then
    gitleaks git --redact --no-banner --exit-code 0 . # report only, like the weekly job
else
    git fetch -q origin 2>/dev/null || true
    gitleaks git --redact --no-banner --exit-code 1 --log-opts="$base..HEAD" . || failed+=("secrets")
fi

section "Rust dependencies: sable/crates (cargo-deny)"
(cd sable/crates && cargo deny check) || failed+=("cargo-deny")

section "Rust dependencies: Marathon crates, advisories (report only)"
(cd crates && cargo deny --config ../sable/crates/deny.toml check advisories 2>&1 |
    grep -E "^(error|warning)\[|ID:|Solution") || true

section "Workflows: SableOS (zizmor)"
zizmor --offline .github/workflows/sable-*.yml || failed+=("zizmor")

section "Workflows: Marathon (report only)"
zizmor --offline .github/workflows/ci.yml .github/workflows/format.yml .github/workflows/release.yml 2>&1 | tail -n 5 || true

printf '\n'
if ((${#failed[@]})); then
    echo "FAILED: ${failed[*]}"
    exit 1
fi
echo "Security checks passed."
