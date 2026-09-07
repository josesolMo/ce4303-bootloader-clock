read_rtc_time:

    pusha

    ; ______/Obtener la hora desde la BIOS \______

    mov ah, 0x02            ; BIOS: obtener hora del RTC
    int 0x1A

    jc .done                ; Error al leer el RTC

    ; ______/Guardar los valores obtenidos \_______

    mov [VAR_RTC_HOURS], ch ; Hora en BCD
    mov [VAR_RTC_MINS], cl  ; Minutos en BCD
    mov [VAR_RTC_SECS], dh  ; Segundos en BCD

.done:
    popa
    ret