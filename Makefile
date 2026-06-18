.PHONY: build run clear

BIN        := .build/xogui
ODIN_FLAGS := -out:$(BIN) -extra-linker-flags:"-static" -debug

build:
	mkdir -p .build
	odin build ./src/ $(ODIN_FLAGS)

run: build
	$(BIN)

clean:
	rm $(BIN)
