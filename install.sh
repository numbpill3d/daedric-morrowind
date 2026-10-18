#!/usr/bin/env bash
# Install the whole Daedric Morrowind suite.
#   ./install.sh                 everything (asks for sudo for SDDM + Plymouth)
#   ./install.sh --apply         everything, and switch the Plasma pieces on
#   ./install.sh --user-only     only the pieces that need no root
#   ./install.sh --system-only   only SDDM + Plymouth
# Run it as your normal user, not with sudo.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "run as your normal user; it calls sudo itself" >&2; exit 1; }

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PIECES=$HERE/pieces
BASE=https://github.com/numbpill3d
USER_PIECES=(aurorae splash lockscreen konsole)
SYSTEM_PIECES=(sddm plymouth)

apply=""; do_user=1; do_system=1
for arg in "$@"; do
    case $arg in
        --apply)       apply=--apply ;;
        --user-only)   do_system=0 ;;
        --system-only) do_user=0 ;;
        -h|--help)     sed -n '2,7p' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 1 ;;
    esac
done

fetch() {
    local repo=daedric-morrowind-$1 dir=$PIECES/daedric-morrowind-$1
    if [[ -d $dir/.git ]]; then
        git -C "$dir" pull --ff-only --quiet
    else
        git clone --depth 1 --quiet "$BASE/$repo" "$dir"
    fi
}

mkdir -p "$PIECES"
if (( do_user )); then
    for p in "${USER_PIECES[@]}"; do
        echo "==> $p"; fetch "$p"
        if [[ $p == konsole ]]; then bash "$PIECES/daedric-morrowind-$p/install.sh"
        else bash "$PIECES/daedric-morrowind-$p/install.sh" $apply; fi
    done
fi
if (( do_system )); then
    for p in "${SYSTEM_PIECES[@]}"; do
        echo "==> $p (sudo)"; fetch "$p"
        sudo bash "$PIECES/daedric-morrowind-$p/install.sh"
    done
fi
if (( do_system )); then
    echo "Done. The login screen shows at next logout; the boot splash at next boot."
else
    echo "Done."
fi
