; Mapa de Memoria Compartida (RAM libre a partir de 0x0500)

; Estado general del sistema
VAR_MODE            equ 0x0500  ; 0: Reloj, 1: Cronómetro, 2: Config. Alarma

; Datos del Reloj RTC (formato BCD)
VAR_RTC_HOURS       equ 0x0501
VAR_RTC_MINS        equ 0x0502
VAR_RTC_SECS        equ 0x0503

; Datos del Cronómetro
VAR_SW_HOURS        equ 0x0504
VAR_SW_MINS         equ 0x0505
VAR_SW_SECS         equ 0x0506

; Configuración y estado de la Alarma
VAR_ALARM_HOURS     equ 0x0507
VAR_ALARM_MINS      equ 0x0508
VAR_ALARM_ENABLED   equ 0x0509  ; 0: Desactivada, 1: Activada
VAR_ALARM_TRIGGERED equ 0x050A  ; 0: Inactiva, 1: Sonando