.PHONY: all build install clean test

all: build

build:
	@mkdir -p _build
	cd _build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make -j

install: ; cd _build && make install

clean: ; rm -rf _build

test: ; @echo TODO
