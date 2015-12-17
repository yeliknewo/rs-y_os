global protected_mode

section .text
bits 32
protected_mode:
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax

    mov esp, 0x9c00

hang:
    jmp hang
