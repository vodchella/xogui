.PHONY: default build run clean dir release

default: build

BIN := .build/xogui

dir:
	mkdir -p .build

release: dir
	odin build ./src/ -out:$(BIN) -o:size

build: dir
	odin build ./src/ -out:$(BIN) -debug

run: build
	$(BIN)

clean:
	rm $(BIN)
