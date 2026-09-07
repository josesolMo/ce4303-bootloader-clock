; ______________________/ Alarma \_________________________

check_alarm_trigger:

    pusha

    ; ______/Verificar si la alarma está activada \__________

    cmp byte [VAR_ALARM_ENABLED], 1
    jne .done

    ; ______/Verificar si la alarma ya está sonando \________

    cmp byte [VAR_ALARM_TRIGGERED], 1
    je .done

    ; ______/Comparar hora y minutos \_______________________

    mov al, [VAR_RTC_HOURS]
    cmp al, [VAR_ALARM_HOURS]
    jne .done

    mov al, [VAR_RTC_MINS]
    cmp al, [VAR_ALARM_MINS]
    jne .done

    ; ______/Activar alarma \________________________________

    mov byte [VAR_ALARM_TRIGGERED], 1

    call start_speaker

.done:
    popa
    ret


; ___________________/ Configurar Alarma \_________________

configure_alarm:

    pusha

    ; ______/Mostrar mensaje de configuración \______________

    mov dh, 18
    mov dl, 25
    call set_cursor

    mov si, msg_alarm_prompt
    call print_string

    ; ______/Leer decenas de la hora \_______________________

    call read_alarm_digit
    jc .cancel

    cmp al, 2
    ja .invalid

    mov bl, al
    shl bl, 4

    ; ______/Leer unidades de la hora \______________________

    call read_alarm_digit
    jc .cancel

    cmp bl, 0x20
    jne .hour_valid

    cmp al, 3
    ja .invalid

.hour_valid:

    or bl, al
    mov [VAR_ALARM_HOURS], bl

    ; ______/Mostrar separador HH:MM \________________________

    mov al, ':'
    call print_char

    ; ______/Leer decenas de los minutos \___________________

    call read_alarm_digit
    jc .cancel

    cmp al, 5
    ja .invalid

    mov bl, al
    shl bl, 4

    ; ______/Leer unidades de los minutos \__________________

    call read_alarm_digit
    jc .cancel

    or bl, al

    mov [VAR_ALARM_MINS], bl

    ; ______/Activar la alarma \______________________________

    mov byte [VAR_ALARM_ENABLED], 1
    mov byte [VAR_ALARM_TRIGGERED], 0

    call stop_speaker

    mov byte [VAR_MODE], 2

    jmp .done

.invalid:

    mov dh, 19
    mov dl, 25
    call set_cursor

    mov si, msg_alarm_invalid
    call print_string

    jmp .done


.cancel:

    mov byte [VAR_MODE], 0

.done:

    popa
    ret


; _________________/ Leer dígito de alarma \________________

read_alarm_digit:

.wait:

    mov ah, 0x00
    int 0x16

    ; ______/ESC cancela la configuración \__________________

    cmp al, 0x1B
    je .cancel

    ; ______/Ignorar teclas que no sean números \____________

    cmp al, '0'
    jb .wait

    cmp al, '9'
    ja .wait

    ; ______/Mostrar el dígito escrito \_____________________

    push ax
    call print_char
    pop ax

    sub al, '0'

    clc
    ret

.cancel:

    stc
    ret


; _____________________/ Speaker \_________________________

start_speaker:

    ; ______/Configurar frecuencia del PIT \_________________

    mov al, 0xB6
    out 0x43, al

    ; ______/Configurar frecuencia aproximada de 1000 Hz \__

    mov ax, 0x04A9

    out 0x42, al

    mov al, ah
    out 0x42, al

    ; ______/Activar speaker del PC \________________________

    in al, 0x61
    or al, 0x03
    out 0x61, al

    ret


; ____________________/ Detener Speaker \__________________

stop_speaker:

    in al, 0x61
    and al, 0xFC
    out 0x61, al

    ret


; ___________________/ Cancelar Alarma \___________________

cancel_alarm:

    pusha

    cmp byte [VAR_ALARM_TRIGGERED], 1
    jne .done

    call stop_speaker

    mov byte [VAR_ALARM_TRIGGERED], 0
    mov byte [VAR_ALARM_ENABLED], 0

.done:

    popa
    ret


; ______________________/ Mensajes \_______________________

msg_alarm_prompt:
    db "Ingrese alarma HHMM: ", 0

msg_alarm_invalid:
    db "Hora invalida.", 0