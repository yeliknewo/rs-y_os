bits 16
org 0x7C00

real_mode:
    xor ax, ax      ; set ax to 0
    mov ds, ax      ; set ds to 0
    mov ss, ax      ; set ss to 0
    mov sp, stack_bottom  ; make stack at end of this program

    cli
    lgdt [gdtr]

    mov eax, cr0    ; set eax to cr0
    or al, 1       ; set least bit of eax to 1, protected mode enabled bit
    mov cr0, eax    ; set cr0 to eax

    jmp 0x08:protected_mode

bits 32
protected_mode:
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax

    mov esp, stack_bottom

    call check_cpuid
    call check_long_mode
    call setup_page_tables
    call enable_paging

    mov dword [0xb8000], 0x2f4b2f4f

    lgdt [ gdt64.Pointer]

    mov ax, gdt64.Data
    mov ss, ax
    mov ds, ax
    mov es, ax

    jmp gdt64.Code:long_mode

error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], al
    hlt

check_cpuid:
    pushfd               ; Store the FLAGS-register.
    pop eax              ; Restore the A-register.
    mov ecx, eax         ; Set the C-register to the A-register.
    xor eax, 1 << 21     ; Flip the ID-bit, which is bit 21.
    push eax             ; Store the A-register.
    popfd                ; Restore the FLAGS-register.
    pushfd               ; Store the FLAGS-register.
    pop eax              ; Restore the A-register.
    push ecx             ; Store the C-register.
    popfd                ; Restore the FLAGS-register.
    xor eax, ecx         ; Do a XOR-operation on the A-register and the C-register.
    jz .no_cpuid         ; The zero flag is set, no CPUID.
    ret                  ; CPUID is available for use.
.no_cpuid:
    mov al, "0"
    jmp error

check_long_mode:
    mov eax, 0x80000000    ; Set the A-register to 0x80000000.
    cpuid                  ; CPU identification.
    cmp eax, 0x80000001    ; Compare the A-register with 0x80000001.
    jb .no_long_mode       ; It is less, there is no long mode.
    mov eax, 0x80000001    ; Set the A-register to 0x80000001.
    cpuid                  ; CPU identification.
    test edx, 1 << 29      ; Test if the LM-bit is set in the D-register.
    jz .no_long_mode       ; They aren't, there is no long mode.
    ret
.no_long_mode:
    mov al, "1"
    jmp error

setup_page_tables:
    mov eax, p3_table
    or eax, 0b11
    mov [p4_table], eax

    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax

    mov ecx, 0

.map_p2_table:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ret

enable_paging:
    mov eax, p4_table       ; load p4_table address into eax
    mov cr3, eax            ; load cr3 into eax

    mov eax, cr4            ; load cr4 into eax
    or eax, 1 << 5          ; set bit 5 to 1
    mov cr4, eax            ; save eax into cr4

    mov ecx, 0xC0000080     ; EFER MSR
    rdmsr                   ; read msr
    or eax, 1 << 8          ; set msr bit 8 to 1
    wrmsr                   ; write msr

    mov eax, cr0            ; load cr0 into eax
    or eax, 1 << 31         ; set bit 31 to 1
    mov cr0, eax            ; load eax into cr0

    ret


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

bits 64
long_mode:
    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax

hang:
    jmp hang

gdt64:
    .Null: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 0
    db 0
    db 0
    .Code: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 0b10011010
    db 0b00100000
    db 0
    .Data: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 0b10010010
    db 0b00000000
    db 0
    .Pointer
    dw $ - gdt64 - 1
    dq gdt64

times 510-($-$$) db 0
dw 0xAA55

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
stack_bottom:
    resb 4096
stack_top:
