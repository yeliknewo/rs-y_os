arch ?= x86_64
target ?= $(arch)-unkown-linux-gnu
kernel := build/kernel-$(arch).bin

rust_y_core := target/$(target)/debug/liby_core.a
linker_script := src/other/linker.ld
assembly_sources := $(wildcard src/assembly/$(arch)/*.asm)
assembly_binaries := $(patsubst src/assembly/$(arch)/%.asm, build/assembly/$(arch)/%.bin, $(assembly_source))

.PHONY: all clean qemu iso

all: $(kernel)

clean:
	@rm -rf build

qemu: all
	@qemu-system-x86_64 -fda $(kernel) -boot a

$(kernel): $(assembly_binaries)
	@cp $< $@

build/assembly/$(arch)/%.bin: src/assembly/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f bin $< -o $@
