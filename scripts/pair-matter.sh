#!/bin/bash
# Operator-only secret entry. This pairs through Matter, not the Hue REST API.
set -euo pipefail
config=${1:?Usage: pair-matter.sh /private/path/moli.toml instance /path/to/moli-os}
instance=${2:?Supply the configured Matter instance id}
binary=${3:?Supply the compiled moli-os executable}
test -r "$config"
test -x "$binary"
if [[ ! -t 0 ]]; then
  echo 'Run this script yourself in a terminal; never paste a pairing code in chat.' >&2
  exit 1
fi
IFS= read -r -s -p 'Matter pairing code (hidden): ' matter_setup_code
printf '\n'
trap 'unset matter_setup_code' EXIT
test -n "$matter_setup_code"
printf '%s' "$matter_setup_code" |
  "$binary" --config "$config" secrets set "$instance" pairing_code
unset matter_setup_code
echo 'Pairing request stored in the encrypted vault. Restart this Moli instance to use it.'
