[BITS 16]
[ORG 0x8000]

start:
    ; Dejeamos que este stage tenga su propio entorno
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    call show_welcome_screen ; Ejecuta pantalla de bienvenida
    call draw_static_ui      ; Dibuja el marco y títulos una única vez
    
    ; --- SIMULACIÓN DE PRUEBA ---
    ;mov byte [VAR_RTC_HOURS], 0x12       ; Hora de prueba: 12 (BCD)
    ;mov byte [VAR_RTC_MINS],  0x34       ; Minutos de prueba: 34 (BCD)
    ;mov byte [VAR_ALARM_TRIGGERED], 1    ; 1 = Activa el parpadeo VGA en pantalla

; Bucle principal de la aplicacion
main_loop:

    call check_keyboard      ; Lee teclas sin congelar el programa
    call read_rtc_time       ; Consulta el reloj del BIOS
    call update_stopwatch    ; Actualiza contadores del cronómetro
    call check_alarm_trigger ; Evalúa si debe sonar la alarma
    call render_screen       ; Pinta la interfaz en pantalla

    jmp main_loop            ; Salta al inicio del ciclo (Bucle infinito)

; Modulos y dependencias
%include "src/defines.inc"   ; Constantes globales (colores, puertos), códigos de teclado y variables de estado
%include "src/display.asm"   ; Rutinas de video con INT 10h: maquetado de pantalla, texto y atributos de color
%include "src/rtc.asm"       ; Lectura del reloj de tiempo real vía INT 1Ah y conversor de BCD a texto ASCII
%include "src/keyboard.asm"  ; Captura no bloqueante de teclado con INT 16h para alternar modos y comandos
%include "src/stopwatch.asm" ; Lógica del cronómetro: conteo independiente de tiempo, pausa, reanudación y reinicio
%include "src/alarm.asm"     ; Verificación de hora configurada, disparo de bocina (puertos 0x42/0x61) y parpadeo visual
