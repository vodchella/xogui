.PHONY: build run clear

build:
	zc build src/main.zc -o xogui --cc $(CC)

run: build
	./xogui

clean:
	rm -f xogui xoml.log
