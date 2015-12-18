arch := x86_64
target := $(arch)-unknown-linux-gnu
kernel := build/kernel-$(arch).bin
os := build/os-$(arch).iso
rust_os := target/$(target)/debug/liby_os.a
linker_script := src/$(arch)/linker.ld
grub_cfg := src/$(arch)/grub.cfg
assembly_sources := $(wildcard src/$(arch)/*.asm)
assembly_objects := $(patsubst src/$(arch)/%.asm, build/$(arch)/%.o, $(assembly_sources))

.PHONY: all clean qemu cargo

all: $(os)

clean:
	@rm -rf build
	@rm -rf target

qemu: all
	@qemu-system-$(arch) -drive format=raw,file=$(os)

cargo:
	@cargo rustc --target $(target) -- -Z no-landing-pads -C no-redzone

$(os): $(kernel) $(grub_cfg)
	@mkdir -p build/ostemp/boot/grub
	@cp $(kernel) build/ostemp/boot/kernel.bin
	@cp $(grub_cfg) build/ostemp/boot/grub
	@grub-mkrescue -o $(os) build/ostemp
	@rm -r build/ostemp

$(kernel): cargo $(rust_os) $(assembly_objects) $(linker_script)
	@ld -n --gc-sections -T $(linker_script) -o $(kernel) $(assembly_objects) $(rust_os)

build/$(arch)/%.o: src/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $< -o $@
