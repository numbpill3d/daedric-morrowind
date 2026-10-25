#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
cp "$ROOT/install.sh" "$work/install.sh"

if output=$(bash "$work/install.sh" --user-only --system-only 2>&1); then
    echo "conflicting modes unexpectedly succeeded" >&2
    exit 1
fi

[[ $output == *"cannot be used together"* ]] || {
    echo "conflicting modes did not explain the error" >&2
    exit 1
}

[[ ! -e $work/pieces ]] || {
    echo "conflicting modes created an installation directory" >&2
    exit 1
}

echo "install option checks passed"
