# ┌───────────────────────────────────────────────────────────────┐
# │ Justfile for gitpushup                                        │
# │                                                               │
# │ Commands:                                                     │
# │   just               → show this help message                 │
# └───────────────────────────────────────────────────────────────┘

set shell := ["bash", "-euo", "pipefail"]
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load := true

# Default recipe (runs when you just type `just`)
default: help

# Show this help message
help:
    @just --list --unsorted
    @echo ""
    @echo "Development aliases:"
    @echo "  just b       → alias for build"
    @echo "  just r       → alias for run"
    @echo ""

# ─── Build & Development ─────────────────────────────────────────

# Watch + build (continuous)
build:
    cargo watch -c -w src/ -x "build --color=always"

# Watch + run (continuous)
run:
    cargo watch -c -w src/ -x "run --color=always"

# Shortcuts
b: build
r: run

# Run tests
test:
    cargo test -- --nocapture

# Clean build artifacts
clean:
    cargo clean

# Remove cargo cache directories
cache:
    cargo-cache --remove-dir all

# Build and install release version locally
release:
    cargo build --release
    cargo install --path . --locked

# ─── Tools & Session ─────────────────────────────────────────────

# Start zellij with rust project layout
layout:
    zellij --layout rust-layout.kdl

# Quick cargo fmt + clippy
lint:
    cargo fmt --all
    cargo clippy --all-targets -- -D warnings

# Update dependencies and clean cache
update:
    cargo update
    just cache
