[BITS 16]
[ORG 0x7C00]

start:
    ; ______________/Confifurar Stage y Stack \_________________

    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    ; ______/Guardar el número de unidad de arranque \_________
    
    mov [boot_drive], dl  ; DL lo entrega la BIOS.

    ; ________/Cargar la aplicación desde el disco \___________
    ; La aplicación empieza en el Stage 2:
    ;   Stage 1 = bootloader
    ;   Stage 2 = aplicación
    ; Destino: 0000:8000
    ;__________________________________________________________

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x8000

    mov ah, 0x02            ; BIOS: leer sectores
    mov al, APP_SECTORS     ; cantidad de sectores
    mov ch, 0x00            ; cilindro 0
    mov cl, 0x02            ; sector inicial = 2
    mov dh, 0x00            ; cabeza 0
    mov dl, [boot_drive]    ; unidad de arranque
    int 0x13
    jc disk_error           ; Carry = error de lectura

    jmp 0x0000:0x8000       ; Saltar a la aplicación


disk_error:
    ; Mostrar mensaje de error
    mov si, msg_disk_error

.print:
    lodsb
    cmp al, 0
    je .halt

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp .print

.halt:
    cli
    hlt
    jmp .halt


; __________________________/ Datos \__________________________

boot_drive db 0

msg_disk_error db "Error al cargar la aplicacion.", 0

; -------------------------------------------------------------
; Cantidad de sectores que ocupa app.bin.
;
; Por ahora reservamos 8 sectores = 4096 bytes.
; -------------------------------------------------------------
APP_SECTORS equ 8

; __________________/ Firma del Boot Stage \___________________

times 510-($-$$) db 0
dw 0xAA55