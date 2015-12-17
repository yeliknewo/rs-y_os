[BITS 16]                   ; 16 bit
[ORG 0x7C00]                ; start code at floppy boot location
    xor ax, ax              ; ax = 0
    mov ds, ax              ; ds = ax
    mov ss, ax              ; ss = ax
    mov sp, 0x9c00          ; sp = 0x200 past start location

    mov ax, 0xb800          ; ax = video buffer
    mov es, ax              ; es = ax

    mov si, msg             ; si points to msg
    call sprint             ; call function sprint

    mov ax, 0xb800          ; ax = video buffer
    mov gs, ax              ; gs = ax
    mov bx, 0x0000          ; bx = 0
    mov ax, [gs:bx]         ; ax = value at gs with offset of bx

    mov word[reg16], ax     ; reg16 = ax
    call printreg16         ; call function printreg16

hang:                       ; function hang
    jmp hang                ; jump to hang

dochar:                     ; function dochar
    call cprint             ; call function cprint

sprint:                     ; function sprint
    lodsb                   ; load si into al
    cmp al, 0               ; if al == 0
    jne dochar              ; if ^ is not true jump to dochar
    add byte [ypos], 1      ; ypos += 1
    mov byte [xpos], 0      ; xpos = 0
    ret                     ; return

cprint:                     ; function cprint
    mov ah, 0x0f            ; white text on black background, ah = 0x0f
    mov cx, ax              ; cx = ax, save char/attribute
    movzx ax, byte [ypos]   ; ax = ypos with trailing zeros to fill the word
    mov dx, 160             ; dx = 160, 2 bytes (char/attrib)
    mul dx                  ; ax * dx = DX:AX

    movzx bx, byte [xpos]   ; bx = xpos with trailing zeroes
    shl bx, 1               ; bx << 1, bx * 2 ^ 1

    mov di, 0               ; di = 0, start of video memory
    add di, ax              ; di += ax, ax was set to ax * dx, dx was 160, ax was ypos
    add di, bx              ; di += bx, bx was xpos * 2 ^ 1

    mov ax, cx              ; ax = cx, restore the stored value of ax from the start
    stosw                   ; store ax in video buffer
    add byte [xpos], 1      ; xpos += 1, move xpos to the right one

    ret                     ; return

printreg16:
    mov di, outstr16        ; di = pointer to outstr16
    mov ax, [reg16]         ; ax = reg16
    mov si, hexstr          ; si = pointer to hexstr
    mov cx, 4               ; cx = 4

hexloop:
    rol ax, 4               ; shift ax 4 to the left and wrap the bits
    mov bx, ax              ; bx = ax
    and bx, 0x0f            ; bx = bx and 0x0f
    mov bl, [si + bx]       ; bl = the object at si + bx
    mov [di], bl            ; bl = location of di
    inc di                  ; di ++
    dec cx                  ; cx --
    jnz hexloop             ; if cx != 0 jump to hexloop

    mov si, outstr16        ; si = outstr16
    call sprint             ; call function sprint

    ret                     ; return

xpos db 0
ypos db 0
hexstr db '0123456789ABCDEF'
outstr16 db '0000', 0
reg16 dw 0
msg db "I know where you live", 0

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
