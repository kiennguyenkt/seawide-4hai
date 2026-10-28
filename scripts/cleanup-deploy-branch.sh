#!/usr/bin/env bash
cd "$(dirname "$0")/.."

targets=(
    tools
    docs
    .playwright-mcp
    pyproject.toml
    README.BE.md
    uv.lock
)

for item in "${targets[@]}"; do
    if [ -e "$item" ]; then
        printf 'Delete %s ... ' "$item"
        rm -rf "$item"
        echo "Done"
    fi
done
