; Módulo de Pantalla / UI

show_welcome_screen:
    pusha                   ; Guarda los registros generales en la pila

    ; Limpiar la pantalla (Configura modo de texto 80x25 a color)
    mov ah, 0x00
    mov al, 0x03            ; Modo de texto estándar VGA (80 columnas x 25 filas)
    int 0x10                ; Interrupción de video del BIOS

    ; Apuntar el registro SI al mensaje de bienvenida
    mov si, msg_welcome
    call print_string

.wait_key:
    ; Esperar a que el usuario presione una tecla para continuar
    mov ah, 0x00            ; Servicio de lectura de tecla
    int 0x16                ; Interrupción de teclado del BIOS

    ; Limpiar pantalla antes de dibujar la interfaz principal
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    popa                    ; Restaura los registros
    ret                     ; Retorna al main.asm

; Dibuja el marco y textos fijos (Se llama solo 1 vez)
draw_static_ui:
    pusha
    call hide_cursor
    call draw_main_frame

    ; Dibujar Encabezado (Fila 2, Columna 25)
    mov dh, 2
    mov dl, 25
    call set_cursor
    mov si, msg_title
    call print_string

    ; Dibujar Menú de Controles al pie (Fila 21, Columna 20)
    mov dh, 21
    mov dl, 20
    call set_cursor
    mov si, msg_menu
    call print_string

    popa
    ret

; Actualiza únicamente los datos dinámicos en pantalla
render_screen:
    pusha

; Seleccionar la etiqueta del modo según VAR_MODE
    mov dh, 6
    mov dl, 30
    call set_cursor

    mov al, [VAR_MODE]
    cmp al, 1
    je .mode_sw
    cmp al, 2
    je .mode_alarm

.mode_clock:
    mov si, msg_mode_clock
    call print_string
    mov si, VAR_RTC_HOURS
    jmp .draw_time

.mode_sw:
    mov si, msg_mode_sw
    call print_string
    mov si, VAR_SW_HOURS
    jmp .draw_time

.mode_alarm:
    mov si, msg_mode_alarm
    call print_string
    mov si, VAR_ALARM_HOURS

.draw_time:
    ; Posicionar cursor (Fila 11, Columna 36)
    mov dh, 11
    mov dl, 36
    call set_cursor
    
    ; Dibujar tiempo (HH:MM:SS)
    call print_time_triplet

    popa
    ret

; *** Rutina de Maquetado (Marco ASCII en CP437) ***
draw_main_frame:
    ; Esquina superior izq (Fila 0, Columna 0)
    mov dh, 0
    mov dl, 0
    call set_cursor
    mov al, 0xDA        ; Carácter '┌'
    call print_char

    call draw_horizontal_line ; Línea superior

    ; Esquina superior der (Fila 0, Columna 79)
    mov al, 0xBF        ; Carácter '┐'
    call print_char

    ; Líneas laterales
    mov bl, 1           ; Fila inicial
.side_lines:
    ; Lateral izquierdo
    mov dh, bl
    mov dl, 0
    call set_cursor
    mov al, 0xB3        ; Carácter '│'
    call print_char

    ; Lateral derecho
    mov dh, bl
    mov dl, 79
    call set_cursor
    mov al, 0xB3        ; Carácter '│'
    call print_char

    inc bl
    cmp bl, 23
    jb .side_lines

    ; Esquina inferior izquierda (Fila 23, Columna 0)
    mov dh, 23
    mov dl, 0
    call set_cursor
    mov al, 0xC0        ; Carácter '└'
    call print_char

    call draw_horizontal_line ; Línea inferior

    ; Esquina inferior derecha (Fila 23, Columna 79)
    mov al, 0xD9        ; Carácter '┘'
    call print_char
    ret

draw_horizontal_line:
    mov cx, 78
.loop:
    mov al, 0xC4
    call print_char
    loop .loop
    ret

; *** Subrutinas Auxiliares ***

; Mueve el cursor a la posición DH = Fila (0-24), DL = Columna (0-79)
set_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

; Oculta el cursor parpadeante de texto VGA
hide_cursor:
    mov ah, 0x01
    mov ch, 0x20        ; El bit 5 en 1 oculta el cursor físicamente
    int 0x10
    ret

; Lee 3 bytes BCD consecutivos desde [SI] e imprime HH:MM:SS
print_time_triplet:
    lodsb
    call print_bcd_byte
    mov al, ':'
    call print_char
    lodsb
    call print_bcd_byte
    mov al, ':'
    call print_char
    lodsb
    jmp print_bcd_byte       ; Salto directo al último byte

; Imprime el carácter guardado en AL usando el servicio teletype
print_char:
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    ret

; Imprime la cadena terminada en cero apuntada por SI
print_string:
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

; Imprime un byte en formato BCD (ej: 0x42 -> imprime "42")
; Entrada: AL = Byte en BCD
print_bcd_byte:
    push ax                 ; Guarda AX para no alterar los datos del llamador

    ; Extraer dígito superior (Decenas)
    shr al, 4               ; Desplaza el nibble alto a la derecha (0x42 -> 0x04)
    add al, '0'             ; Convierte a carácter ASCII (+0x30)

    ; Imprimir decenas
    call print_char
    pop ax

    ; Extraer dígito inferior (Unidades)
    and al, 0x0F            ; Aísla los 4 bits bajos (0x42 -> 0x02)
    add al, '0'             ; Convierte a carácter ASCII (+0x30)
    jmp print_char          ; Imprime unidades

; *** Cadenas de Texto de la Interfaz ***
msg_welcome:          db "=== BOOTLOADER OS ===", 13, 10
                      db "Presione una tecla para iniciar...", 0

msg_title:            db "SISTEMA OS: RELOJ Y CRONOMETRO", 0
msg_mode_clock:       db "[ MODO: RELOJ RTC  ]", 0
msg_mode_sw:          db "[ MODO: CRONOMETRO ]", 0
msg_mode_alarm:       db "[ MODO: ALARMA     ]", 0
msg_menu:             db "[M] Modo  |  [A] Alarma  |  [R] Reset", 0