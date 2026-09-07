check_keyboard:

    pusha

    ; ______/Verificar si existe una tecla disponible \_______

    mov ah, 0x01
    int 0x16

    jz .done                ; No hay tecla

    ; ______/Leer la tecla disponible \______________________

    mov ah, 0x00
    int 0x16

    ; ______/Cambiar entre Reloj y Cronómetro \______________

    cmp al, 'm'
    je .mode

    cmp al, 'M'
    je .mode

    ; ______/Configurar alarma \_____________________________

    cmp al, 'a'
    je .alarm

    cmp al, 'A'
    je .alarm

    ; ______/Reiniciar cronómetro \__________________________

    cmp al, 'r'
    je .reset

    cmp al, 'R'
    je .reset

    ; ______/Iniciar o pausar cronómetro \___________________

    cmp al, ' '
    je .stopwatch

    ; ______/Cancelar alarma \_______________________________

    cmp al, 0x1B
    je .cancel_alarm

    ; ______/Salir del programa \____________________________

    cmp al, 'q'
    je .exit

    cmp al, 'Q'
    je .exit

    jmp .done


.mode:

    ; ______/Alternar entre Reloj y Cronómetro \_____________

    mov al, [VAR_MODE]

    cmp al, 0
    je .to_stopwatch

    mov byte [VAR_MODE], 0
    jmp .done

.to_stopwatch:

    mov byte [VAR_MODE], 1
    jmp .done


.alarm:

    call configure_alarm
    jmp .done


.reset:

    call reset_stopwatch
    jmp .done


.stopwatch:

    call toggle_stopwatch
    jmp .done


.cancel_alarm:

    call cancel_alarm
    jmp .done


.exit:

    popa

    ; ______/Detener ejecución del programa \________________

    cli
    hlt

.exit_loop:
    jmp .exit_loop


.done:

    popa
    ret