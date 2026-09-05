; Módulo de Pantalla / UI

show_welcome_screen:
    pusha                   ; Guarda los registros generales en la pila

    ; Limpiar la pantalla (Configura modo de texto 80x25 a color)
    mov ah, 0x00
    mov al, 0x03            ; Modo de texto estándar VGA (80 columnas x 25 filas)
    int 0x10                ; Interrupción de video del BIOS

    ; Apuntar el registro SI al mensaje de bienvenida
    mov si, msg_welcome

.print_loop:
    lodsb                   ; Lee el byte apuntado por SI en AL e incrementa SI
    cmp al, 0               ; Caracter nulo (final del texto)?
    je .wait_key            ; Si es 0, termina de imprimir y va a esperar la tecla
    
    mov ah, 0x0E            ; Servicio Teletype de INT 10h (Imprime carácter en AL)
    int 0x10
    jmp .print_loop         ; Imprime el siguiente carácter

.wait_key:
    ; Esperar a que el usuario presione una tecla para continuar
    mov ah, 0x00            ; Servicio de lectura de tecla
    int 0x16                ; Interrupción de teclado del BIOS

    popa                    ; Restaura los registros
    ret                     ; Retorna al main.asm

render_screen:
    ret                     ; Se programará más adelante para el reloj/cronómetro

; Mensajes de la interfaz
msg_welcome: db "========================================", 13, 10
             db "   BIENVENIDO AL BOOTLOADER OS (TEC)    ", 13, 10
             db "========================================", 13, 10, 10
             db " Presione cualquier tecla para iniciar...", 0