# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/rust:1-ubuntu-24.04

# Install additional tools
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev clang && \
    rm -rf /var/lib/apt/lists/*

# Install cargo-edit for `cargo add`
RUN cargo install cargo-edit

# Set the default user to vscode
USER vscode
