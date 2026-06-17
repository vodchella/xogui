.PHONY: build run clear

BIN        := .build/xogui
ODIN_FLAGS := -out:$(BIN) -extra-linker-flags:"-static"

build:
	mkdir -p .build
	odin build ./src/ $(ODIN_FLAGS)

run: build
	$(BIN)

clean:
	rm $(BIN)
