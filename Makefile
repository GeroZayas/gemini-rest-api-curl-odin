.PHONY: run build alias test

run: build
	@./builds/main

build:
	@odin build . -out:./builds/main

alias:
	@printf '%s\n' 'alias r="./builds/main"' 'alias b="odin build . -out:./builds/main"'

test:
	@odin test .