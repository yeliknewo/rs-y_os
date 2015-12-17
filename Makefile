arch ?= x86_64
target ?= $(arch)-unkown-linux-gnu
kernel := build/kernel-$(arch).bin

os := build/os-$(arch).bin

boot := src/assembly/$(arch)/boot/boot.asm
rust_y_core := target/$(target)/debug/liby_core.a
linker_script := src/other/linker.ld
assembly_sources := $(wildcard src/assembly/$(arch)/*.asm)
assembly_objects := $(patsubst src/assembly/$(arch)/%.asm, build/assembly/$(arch)/%.o, $(assembly_sources))

.PHONY: all clean qemu

all: $(os)

clean:
	@rm -rf build

qemu: all
	@qemu-system-$(arch) -hda $(os) -boot c

$(os): $(boot) $(kernel)
	@nasm -f bin -o $@ $<

$(kernel): $(assembly_objects)
	@ld -n -T $(linker_script) -o $(kernel) $<

build/assembly/$(arch)/%.o: src/assembly/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 -o $@ $<
