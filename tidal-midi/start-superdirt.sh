#! /bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

boot_file="$script_dir/start-superdirt-midi.scd"

if [ ! -f "$boot_file" ]; then
  echo "Missing SuperCollider boot file: $boot_file" >&2
  exit 1
fi

exec sclang "$boot_file"
