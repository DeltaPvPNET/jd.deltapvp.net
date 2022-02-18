#!/usr/bin/env bash

# resolve shell-specifics
case "$(echo "$SHELL" | sed -E 's|/usr(/local)?||g')" in
    "/bin/zsh")
        RCPATH="$HOME/.zshrc"
        SOURCE="${BASH_SOURCE[0]:-${(%):-%N}}"
    ;;
    *)
        RCPATH="$HOME/.bashrc"
        if [[ -f "$HOME/.bash_aliases" ]]; then
            RCPATH="$HOME/.bash_aliases"
        fi
        SOURCE="${BASH_SOURCE[0]}"
    ;;
esac

# get base dir regardless of execution location
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCE=$([[ "$SOURCE" = /* ]] && echo "$SOURCE" || echo "$PWD/${SOURCE#./}")
basedir=$(dirname "$SOURCE")
COMMAND="$1"
failed=0
BRANCH="master"
case "$COMMAND" in
    "commit" | "com")
    (
        set -e
        shift
        cd "$basedir"
        rm -rf LibraryParent/
        git add .
        git commit -m "$@" -s
        git push origin "$BRANCH"
    ) || failed=1
    ;;
    "delete-old" | "do")
    (
        set -e
        shift
        cd "$basedir"
        
        git add .
        git commit -m "Delete old versions" -s
        git push origin "$BRANCH"
    ) || failed=1
    ;;
esac

unset RCPATH
unset SOURCE
unset basedir
if [[ "$failed" == "1" ]]; then
	unset failed
	false
else
	unset failed
	true
fi