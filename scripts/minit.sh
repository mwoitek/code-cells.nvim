#!/bin/sh

command -v nvim >/dev/null 2>&1 || exit 1

scripts_dir="$(realpath "$0" | xargs dirname)"
config="${scripts_dir}/minit.lua"
test -f "$config" || exit 2

MY_PLUGIN_PATH="$(dirname "$scripts_dir")"
export MY_PLUGIN_PATH

export NVIM_LOG_FILE=/dev/null
export XDG_CONFIG_HOME=""
export XDG_DATA_HOME=""

nvim -u "$config" -n -i NONE "$@"
