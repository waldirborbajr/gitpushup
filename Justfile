# Justfile for gitpushup

build:
    cargo watch -c -w src/ -x "build --color=always"

run:
    cargo watch -c -w src/ -x "run --color=always"

clean:
    cargo clean

cache:
    cargo-cache --remove-dir all

test:
    cargo test

release:
    cargo build --release
    cargo install --path .

layout:
    zellij --layout rust-layout.kdl
