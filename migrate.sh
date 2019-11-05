#!/usr/bin/env bash

# Path definitions
devtools_parse_root() {
    local root
    if [ -f "$1" ]
    then
        root="$(cd "$(dirname "$1")"; pwd)"
    else
        root="$1"
    fi
    if [ -L "$root" ]
    then
        root="$(dirname "$root")/$(readlink "$root")"
        devtools_root "$root"
        return
    fi
    echo "$root"
}
devtools_root() {
    [[ $0 != $BASH_SOURCE ]] && devtools_parse_root "${BASH_SOURCE[0]}" || devtools_parse_root "$0"
}
root="$(devtools_root \"$@\")"
cwd=$(pwd)
cd "$root"

# Ensure submodules are checkedout
git submodule init
git submodule update

# Check arguments
if [ "$1" = "" ]
then
    echo "No repository type."
fi

if [ "$2" = "" ]
then
    echo "No source repository given."
fi
if [ "$3" = "" ]
then
    echo "No upstream Git repository given."
fi
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
then
    echo "Usage: $0 <type> <source_repo> <git_target_repo>"
    echo "Types:"
    for t in $(find "$root/lib/migration" -mindepth 1 -maxdepth 1 | sort)
    do
        basename "$t" | sed 's/.sh$//'
    done
    exit 1
fi

source_type=$1
source_repository=$2
target_repository=$3

tmpdir="$root/tmp"
authorfile="$root/authors"

if [ ! -e "$root/lib/migration/$1.sh" ]
then
    echo "Type is invalid."
    exit 1
fi

rm -rf "$tmpdir"
mkdir "$tmpdir"

. "$root/lib/common.sh"
. "$root/lib/migration/$1.sh"

rm -rf "$tmpdir"
