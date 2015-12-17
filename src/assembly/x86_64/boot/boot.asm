bits 16
org 0x7C00

real_mode:
    xor ax, ax      ; set ax to 0
    mov ds, ax      ; set ds to 0
    mov ss, ax      ; set ss to 0
    mov sp, 0x9c00  ; make stack at end of this program

    cli
    lgdt [gdtr]

    mov eax, cr0    ; set eax to cr0
    or al, 1       ; set least bit of eax to 1, protected mode enabled bit
    mov cr0, eax    ; set cr0 to eax

    jmp 0x08:protected_mode

hang:
    jmp hang

gdtr:
    dw (gdt_end - gdt) + 1  ; size
    dd gdt                  ; offset

gdt:
    ; null entry
    dq 0
    ; code entry
    dw 0xffff               ; limit low
    dw 0x0000               ; base low
    db 0x00                 ; base middle
    db 0b10011010           ; access
    db 0x4f                 ; granularity
    db 0x00                 ; base high
    ; data entry
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0b10010010
    db 0x4f
    db 0x00
gdt_end:

times 510-($-$$) db 0
dw 0xAA55
