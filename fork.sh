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

# checks if branch has something pending
function parse_git_dirty() {
  git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ]
}

# gets the current git branch
function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function get_current_directory() {
    IFS='/' read -ra ${basedir}
}

function output() {
    echo -e '\e[34m'$1'\e[0m';
}

function get_project_name() {
    ./gradlew :properties | awk '/^name:/ { print $2; }'
}

function get_project_version() {
    ./gradlew :properties | awk '/^version:/ { print $2; }'
}

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
PROJ_NAME=$(get_project_name)
PROJ_VERSION=$(get_project_version)
set -e
cd "$basedir"

./gradlew javadoc
cd build/docs/

mkdir $PROJ_NAME/
mkdir -p $PROJ_NAME/$PROJ_VERSION/
mv javadoc/** $PROJ_NAME/$PROJ_VERSION/
mv $PROJ_NAME/ /home/deltapvp/javadocs/

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