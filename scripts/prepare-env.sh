#!/usr/bin/env bash
set -eu -o pipefail

export CONTAINER_PREFIX='project-39'

mkdir -p ./data/redis/data

obj_dir=./data/objs

for dir in "$obj_dir"/*/; do
    dir_name=$(basename "$dir")
    if [ "$dir_name" -gt 20 ]; then
        echo "Deleting directory: $dir_name"
        rm -r "$dir"
    fi
done
