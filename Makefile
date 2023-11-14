build:
	cargo watch -q -c -w src/ -x "build -q"


run:
	cargo watch -q -c -w src/ -x "run -q"
