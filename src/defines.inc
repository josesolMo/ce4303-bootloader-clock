; __________________/ Mapa de Memoria Compartida \____________

; Estado general del sistema
VAR_MODE            equ 0x0500  ; 0: Reloj, 1: Cronómetro, 2: Config. Alarma


; ______________________/ Datos RTC \_________________________

; Datos del Reloj RTC (formato BCD)
VAR_RTC_HOURS       equ 0x0501
VAR_RTC_MINS        equ 0x0502
VAR_RTC_SECS        equ 0x0503

; ___________________/ Datos Cronómetro \____________________

VAR_SW_HOURS        equ 0x0504
VAR_SW_MINS         equ 0x0505
VAR_SW_SECS         equ 0x0506

; Estado interno del cronómetro
VAR_SW_RUNNING      equ 0x050B  ; 0: Pausado, 1: Corriendo

; Última lectura del contador de ticks de BIOS
VAR_SW_LAST_LO      equ 0x050C  ; Parte baja
VAR_SW_LAST_HI      equ 0x050E  ; Parte alta

; Ticks acumulados que todavía no completan un segundo
VAR_SW_TICK_ACC     equ 0x0510
; Milisegundos calculados a partir de los ticks restantes
VAR_SW_MILLI        equ 0x0512


; _______________________/ Datos Alarma \_____________________

; Configuración y estado de la Alarma
VAR_ALARM_HOURS     equ 0x0507
VAR_ALARM_MINS      equ 0x0508
VAR_ALARM_ENABLED   equ 0x0509  ; 0: Desactivada, 1: Activada
VAR_ALARM_TRIGGERED equ 0x050A  ; 0: Inactiva, 1: Sonando