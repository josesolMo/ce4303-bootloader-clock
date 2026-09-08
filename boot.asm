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

; __________________/ Firma y Tabla de Particiones MBR \________

; Relleno estricto hasta el byte 446 (Inicio de la Tabla de Particiones)
times 446-($-$$) db 0

; --- Partición 1 Activa / Booteable (16 Bytes) ---
db 0x80                 ; 0x80 = Marcada como ACTIVA
db 0x00, 0x02, 0x00     ; CHS inicio (Cabeza 0, Sector 2, Cilindro 0)
db 0x06                 ; Tipo de sistema de archivos (FAT16)
db 0x00, 0x08, 0x00     ; CHS fin
dd 0x00000001           ; Sector LBA inicial
dd 0x00000800           ; Cantidad de sectores

; --- Particiones 2, 3 y 4 vacías (48 Bytes) ---
times 48 db 0

; --- Firma de Arranque BIOS (2 Bytes) ---
dw 0xAA55