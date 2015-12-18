ENTRY(rust_main)

SECTIONS {
    .text : {
        *(.text*)
    }

    .data : {
        *(.data*)
    }

    .rodata : {
        *(.rodata*)
    }
}
