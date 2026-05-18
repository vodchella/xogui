.PHONY: build run clear

build:
	zc build src/main.zc -o main --cc /usr/bin/cc

run: build
	./main

clean:
	rm -f main xoml.log
