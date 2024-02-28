build:
	cargo watch -c -w src/ -x "build "

run:
	cargo watch -c -w src/ -x "run "

clean:
	cargo clean

cache:
	cargo-cache --remove-dir all

test:
	cargo test 
		
install:
	cargo build --release
	cargo install --path .

layout:
	zellij --layout rust-layout.kdl
