#!/usr/bin/env bash
# The SableOS code checks CI runs (sable-ci.yml, plus cargo-deny and Marathon's
# test-reachability lint), run locally. Exits non-zero on the first failure.
#
#   sable/scripts/check.sh
set -euo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

pass=()
run() {
    local name=$1
    shift
    printf '\n== %s\n' "$name"
    "$@"
    pass+=("$name")
}

cd "$root/sable/crates"
run "rustfmt" cargo fmt --all --check
run "clippy" cargo clippy --all-targets --locked -- -D warnings
run "tests" cargo test --locked
run "cargo-deny" cargo deny check
cd "$root"
run "Marathon test-reachability lint" python3 tests/lint/check-test-reachability.py "$root"

printf '\nAll checks passed:'
printf ' %s;' "${pass[@]}"
printf '\n'
