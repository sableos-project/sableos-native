#!/usr/bin/env bash
# Marathon's full build and CTest run (the build-and-test job of ci.yml),
# inside an alpine:edge container, which also runs SableOS's Sable_Crates test.
#
#   sable/scripts/build-marathon.sh            # native architecture (x86_64 on a PC)
#   sable/scripts/build-marathon.sh --arm64    # arm64 like CI and the phone; slow,
#                                              # needs setup-ubuntu.sh --arm64
#
# Uses podman if installed, else docker. The source tree is mounted read-only.
set -euo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
platform=()
for arg in "$@"; do
    case "$arg" in
        --arm64) platform=(--platform linux/arm64) ;;
        -h | --help) sed -n '2,9p' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

if command -v podman >/dev/null; then
    engine=podman
elif command -v docker >/dev/null; then
    engine=docker
else
    echo "neither podman nor docker found: run sable/scripts/setup-ubuntu.sh" >&2
    exit 2
fi

echo "== $engine run alpine:edge ${platform[*]:-(native)} scripts/ci/build-and-test.sh"
start=$(date +%s)
"$engine" run --rm "${platform[@]}" -v "$root:/src:ro" docker.io/library/alpine:edge /src/scripts/ci/build-and-test.sh
echo "== Done in $(($(date +%s) - start)) s"
