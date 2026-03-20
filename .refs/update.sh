#!/usr/bin/env sh
set -xe
# paths are relative to the project root

pnpm degit https://github.com/humanlayer/advanced-context-engineering-for-coding-agents#main .refs/github.com/humanlayer/advanced-context-engineering-for-coding-agents --force
pnpm degit https://github.com/humanlayer/humanlayer/.claude#main .refs/github.com/humanlayer/humanlayer/.claude --force
pnpm degit https://github.com/humanlayer/humanlayer/humanlayer.md#main .refs/github.com/humanlayer/humanlayer --force

git add .refs
