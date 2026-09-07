update_stopwatch:

    pusha

    ; ______/Verificar si el cronómetro está corriendo \______

    cmp byte [VAR_SW_RUNNING], 1
    jne .done

    ; ______/Obtener los ticks actuales de la BIOS \__________

    mov ah, 0x00
    int 0x1A

    ; CX:DX = cantidad de ticks desde medianoche

    ; ______/Guardar el tiempo actual temporalmente \_________

    mov si, cx
    mov di, dx

    ; ______/Calcular diferencia desde el último ciclo \______

    sub dx, [VAR_SW_LAST_LO]
    sbb cx, [VAR_SW_LAST_HI]

    ; ______/Detectar cambio de día \_________________________

    jnc .delta_ready

    ; 0x1800B0 = ticks aproximados de un día

    add dx, 0x00B0
    adc cx, 0x0018

.delta_ready:

    ; ______/Actualizar último tick registrado \______________

    mov [VAR_SW_LAST_LO], di
    mov [VAR_SW_LAST_HI], si

    ; ______/Agregar ticks al acumulador \____________________

    add dx, [VAR_SW_TICK_ACC]
    adc cx, 0

    ; ______/Convertir ticks a segundos \_____________________

    mov ax, dx
    mov dx, cx
    mov bx, 18

    div bx                  ; AX = segundos, DX = resto

    ; ______/Guardar segundos temporalmente \________________

    push ax

    ; ______/Guardar ticks restantes \________________________

    mov [VAR_SW_TICK_ACC], dx

    ; ______/Calcular milisegundos \__________________________

    ; Resto * 1000 / 18 = milisegundos aproximados

    mov ax, dx
    mov bx, 1000
    mul bx

    mov bx, 18
    div bx

    mov [VAR_SW_MILLI], ax

    ; ______/Recuperar segundos \____________________________

    pop ax

    ; ______/Actualizar el cronómetro segundo por segundo \___

    cmp ax, 0
    je .done

    mov cx, ax

.add_seconds:
    call increment_stopwatch_second
    loop .add_seconds
    
.done:
    popa
    ret


; ______________/ Incrementar un segundo \_________________

increment_stopwatch_second:

    ; ______/Incrementar segundos \___________________________

    mov al, [VAR_SW_SECS]
    add al, 1
    daa

    cmp al, 0x60
    jb .save_seconds

    ; 59 -> 00

    mov al, 0

    mov [VAR_SW_SECS], al

    ; ______/Incrementar minutos \____________________________

    mov al, [VAR_SW_MINS]
    add al, 1
    daa

    cmp al, 0x60
    jb .save_minutes

    ; 59 -> 00

    mov al, 0

    mov [VAR_SW_MINS], al

    ; ______/Incrementar horas \______________________________

    mov al, [VAR_SW_HOURS]
    add al, 1
    daa

    cmp al, 0x24
    jb .save_hours

    ; 23 -> 00

    mov al, 0

.save_hours:
    mov [VAR_SW_HOURS], al
    ret

.save_minutes:
    mov [VAR_SW_MINS], al

.save_seconds:
    mov [VAR_SW_SECS], al

    ret


; __________________/ Control del Cronómetro \_____________

toggle_stopwatch:

    pusha

    cmp byte [VAR_SW_RUNNING], 1
    je .pause

    ; ______/Iniciar o continuar cronómetro \_________________

    mov ah, 0x00
    int 0x1A

    mov [VAR_SW_LAST_LO], dx
    mov [VAR_SW_LAST_HI], cx

    mov byte [VAR_SW_RUNNING], 1

    jmp .done

.pause:

    ; ______/Pausar cronómetro \______________________________

    mov byte [VAR_SW_RUNNING], 0

.done:
    popa
    ret


; ___________________/ Reiniciar Cronómetro \_______________

reset_stopwatch:

    pusha

    mov byte [VAR_SW_HOURS], 0
    mov byte [VAR_SW_MINS], 0
    mov byte [VAR_SW_SECS], 0

    mov byte [VAR_SW_RUNNING], 0

    mov word [VAR_SW_LAST_LO], 0
    mov word [VAR_SW_LAST_HI], 0
    mov word [VAR_SW_TICK_ACC], 0

    popa
    ret