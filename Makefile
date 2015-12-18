arch ?= x86_64
target := $(arch)-unknown-linux-gnu
kernel := build/kernel-$(arch).bin

os := build/os-$(arch).bin

boot := src/assembly/$(arch)/boot/boot.asm
linker_script := src/other/linker.ld

assembly_sources := $(wildcard src/assembly/$(arch)/*.asm)
assembly_objects := $(patsubst src/assembly/$(arch)/%.asm, build/assembly/$(arch)/%.o, $(assembly_sources))

rust_sources := $(wildcard src/rust/*.rs)
rust_objects := $(patsubst src/rust/%.rs, build/rust/%.o, $(rust_sources))

.PHONY: all clean qemu no_kernel cargocargo

all: $(os)

clean:
	@rm -rf build

qemu: all
	@qemu-system-$(arch) -hda $(os) -boot c

$(os): $(boot) $(kernel)
	@mkdir -p $(shell dirname $@)
	@nasm -f bin -o $@ $<

$(kernel): $(assembly_objects) $(rust_objects)
	@ld -n -T $(linker_script) -o $(kernel) $<

build/assembly/$(arch)/%.o: src/assembly/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 -o $@ $<

build/rust/%.o: src/rust/%.rs
	@mkdir -p $(shell dirname $@)
	@rustc --crate-type lib --target=$(target) -o $@ --emit obj $<
