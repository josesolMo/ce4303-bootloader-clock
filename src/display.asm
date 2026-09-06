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

    ; Dibujar Indicador de Modo (Fila 6, Columna 30)
    mov dh, 6
    mov dl, 30
    call set_cursor
    mov si, msg_mode_clock
    call print_string

    ; Dibujar Menú de Controles al pie (Fila 21, Columna 20)
    mov dh, 21
    mov dl, 20
    call set_cursor
    mov si, msg_menu
    call print_string

    popa
    ret

; Oculta el cursor parpadeante de texto VGA
hide_cursor:
    mov ah, 0x01
    mov ch, 0x20        ; El bit 5 en 1 oculta el cursor físicamente
    int 0x10
    ret

; Actualiza únicamente los datos dinámicos en pantalla
render_screen:
    pusha

    ; Hora Placeholder (Fila 11, Columna 36)
    mov dh, 11
    mov dl, 36
    call set_cursor
    mov si, msg_time_placeholder
    call print_string

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

    ; Línea superior (Columnas 1 a 78)
    mov cx, 78
.top_line:
    mov al, 0xC4        ; Carácter '─'
    call print_char
    loop .top_line

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

    ; Línea inferior (Columnas 1 a 78)
    mov cx, 78
.bottom_line:
    mov al, 0xC4        ; Carácter '─'
    call print_char
    loop .bottom_line

    ; Esquina inferior derecha (Fila 23, Columna 79)
    mov al, 0xD9        ; Carácter '┘'
    call print_char
    ret

; *** Subrutinas Auxiliares ***

; Mueve el cursor a la posición DH = Fila (0-24), DL = Columna (0-79)
set_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

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

; *** Cadenas de Texto de la Interfaz ***
msg_welcome:          db "=== BOOTLOADER OS (TEC) ===", 13, 10, 10
                      db "Presione una tecla para iniciar...", 0

msg_title:            db "SISTEMA OS: RELOJ Y CRONOMETRO", 0
msg_mode_clock:       db "[ MODO: RELOJ RTC ]", 0
msg_time_placeholder: db "12:34:56", 0
msg_menu:             db "[M] Modo  |  [A] Alarma  |  [R] Reset", 0