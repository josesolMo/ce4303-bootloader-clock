# Variables de configuración
ASM = nasm
QEMU = qemu-system-x86_64
BOOT_SRC = boot.asm
APP_SRC = src/main.asm
BOOT_BIN = boot.bin
APP_BIN = app.bin
BIN = bootloader.bin
APP_SIZE = 4096

# Regla principal
all: build run

# Compila el código NASM a binario MBR y genera el Offload de la aplicacion 
# para que no se guarde dentro del bootloader
build:
	$(ASM) -f bin $(BOOT_SRC) -o $(BOOT_BIN)
	$(ASM) -f bin $(APP_SRC) -o $(APP_BIN)

	@if [ $$(stat -c%s $(APP_BIN)) -gt $(APP_SIZE) ]; then \
		echo "ERROR: main.asm ocupa mas de 4096 bytes."; \
		exit 1; \
	fi

	truncate -s $(APP_SIZE) $(APP_BIN)
	cat $(BOOT_BIN) $(APP_BIN) > $(BIN)

	@echo "Imagen creada: $(BIN)"
	@echo "Bootloader: $$(stat -c%s $(BOOT_BIN)) bytes"
	@echo "Aplicacion: $$(stat -c%s $(APP_BIN)) bytes"
	@echo "Imagen total: $$(stat -c%s $(BIN)) bytes"


# Abre QEMU emulando la USB con el binario generado
run:
	$(QEMU) -drive format=raw,file=$(BIN)

# Elimina el ejecutable generado para limpiar el entorno
clean:
	rm -f $(BOOT_BIN) $(APP_BIN) $(BIN)