# Variables de configuración
ASM = nasm
QEMU = qemu-system-x86_64
SRC = src/main.asm
BIN = bootloader.bin

# Regla principal
all: build run

# Compila el código NASM a binario MBR
build:
	$(ASM) -f bin $(SRC) -o $(BIN)

# Abre QEMU emulando la USB con el binario generado
run:
	$(QEMU) -drive format=raw,file=$(BIN)

# Elimina el ejecutable generado para limpiar el entorno
clean:
	rm -f $(BIN)