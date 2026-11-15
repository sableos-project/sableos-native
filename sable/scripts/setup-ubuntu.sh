#!/usr/bin/env bash
# Installs what SableOS Native's local checks need on Ubuntu 24.04 or newer
# (for example the build machine ai-g732). Safe to run again.
#
#   sable/scripts/setup-ubuntu.sh            # tools for check.sh and security.sh
#   sable/scripts/setup-ubuntu.sh --arm64    # also qemu, for build-marathon.sh --arm64
#
# Tool versions match .github/workflows/sable-*.yml; change both together.
set -euo pipefail

CARGO_DENY_VERSION=0.20.2
ZIZMOR_VERSION=1.32.0
GITLEAKS_VERSION=8.30.1

arm64=false
for arg in "$@"; do
    case "$arg" in
        --arm64) arm64=true ;;
        -h | --help) sed -n '2,9p' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

step() { printf '\n== %s\n' "$*"; }

step "Ubuntu packages"
packages=(build-essential curl git pipx python3 ca-certificates)
command -v docker >/dev/null || packages+=(podman)
$arm64 && packages+=(qemu-user-static binfmt-support)
sudo apt-get update -q
sudo apt-get install -y -q "${packages[@]}"

step "Rust toolchain (rustup) with rustfmt and clippy"
if ! command -v rustup >/dev/null; then
    echo "rustup not found: installing the stable toolchain for $USER"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi
# Adds the components to the active toolchain (ai-g732 used 1.93 without them).
rustup component add rustfmt clippy

step "cargo-deny $CARGO_DENY_VERSION"
if [[ "$(cargo deny --version 2>/dev/null)" != "cargo-deny $CARGO_DENY_VERSION" ]]; then
    cargo install --locked cargo-deny --version "$CARGO_DENY_VERSION"
fi

step "zizmor $ZIZMOR_VERSION"
pipx install --force "zizmor==$ZIZMOR_VERSION"
pipx ensurepath >/dev/null

step "gitleaks $GITLEAKS_VERSION (checksum verified)"
mkdir -p "$HOME/.local/bin"
if [[ "$("$HOME/.local/bin/gitleaks" version 2>/dev/null)" != "$GITLEAKS_VERSION" ]]; then
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    base="https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION"
    tarball="gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
    curl --proto '=https' --tlsv1.2 -sSfL -o "$tmp/$tarball" "$base/$tarball"
    curl --proto '=https' --tlsv1.2 -sSfL -o "$tmp/sums.txt" "$base/gitleaks_${GITLEAKS_VERSION}_checksums.txt"
    (cd "$tmp" && grep " $tarball\$" sums.txt | sha256sum -c -)
    tar -xzf "$tmp/$tarball" -C "$tmp" gitleaks
    install -m 0755 "$tmp/gitleaks" "$HOME/.local/bin/gitleaks"
fi

if $arm64; then
    step "arm64 emulation check"
    if [[ -e /proc/sys/fs/binfmt_misc/qemu-aarch64 ]]; then
        echo "qemu-aarch64 is registered"
    else
        echo "qemu-aarch64 is not registered yet; reboot or run: sudo systemctl restart systemd-binfmt" >&2
    fi
fi

step "Done"
echo "Open a new shell (or run: export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\") and then:"
echo "  sable/scripts/check.sh            # format, clippy, tests, cargo-deny"
echo "  sable/scripts/security.sh         # secrets, dependencies, workflows"
echo "  sable/scripts/build-marathon.sh   # Marathon's full build and tests in Alpine"
