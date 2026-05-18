.PHONY: build run clear

build:
	zc build main.zc -o main --cc /usr/bin/cc

run: build
	./main

clean:
	rm -f main xoml.log
