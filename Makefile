BINARYNAME = main

FAMILY = STM32F7xx
FAMILY_LOWERCASE = stm32f7xx
MCU = STM32F769xx

FW_PACKAGE_DIR = /Users/jrsa/code/stm32/STM32Cube_FW_F7_V1.11.0

INCLUDES  = -I$(FW_PACKAGE_DIR)/Drivers/CMSIS/Device/ST/STM32F7xx/Include
INCLUDES += -I$(FW_PACKAGE_DIR)/Drivers/CMSIS/Include

INCLUDES += -I$(FW_PACKAGE_DIR)/Drivers/STM32F7xx_HAL_Driver/Inc
VPATH    +=   $(FW_PACKAGE_DIR)/Drivers/STM32F7xx_HAL_Driver/Src

SOURCES += $(FAMILY_LOWERCASE)_hal.c
SOURCES += $(FAMILY_LOWERCASE)_hal_cortex.c
SOURCES += $(FAMILY_LOWERCASE)_hal_i2c.c
SOURCES += $(FAMILY_LOWERCASE)_hal_dma.c
SOURCES += $(FAMILY_LOWERCASE)_hal_dma_ex.c
SOURCES += $(FAMILY_LOWERCASE)_hal_gpio.c
SOURCES += $(FAMILY_LOWERCASE)_hal_pwr_ex.c
SOURCES += $(FAMILY_LOWERCASE)_hal_rcc.c

INCLUDES += -I$(FW_PACKAGE_DIR)/Drivers/BSP
VPATH += $(FW_PACKAGE_DIR)/Drivers/BSP/STM32F769I-Discovery
SOURCES += stm32f769i_discovery.c
SOURCES += stm32f769i_discovery_audio.c

INCLUDES += -I.
SOURCES += startup_stm32f769xx.s
SOURCES += system_stm32f7xx.c
SOURCES += main.c

LDSCRIPT = $(FW_PACKAGE_DIR)/Projects/STM32F769I-Discovery/Templates_LL/SW4STM32/STM32F769I_Discovery_AXIM_FLASH/STM32F769NIHx_FLASH.ld

BUILDDIR = build

OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

ELF = $(BUILDDIR)/$(BINARYNAME).elf
HEX = $(BUILDDIR)/$(BINARYNAME).hex
BIN = $(BUILDDIR)/$(BINARYNAME).bin

ARCH = arm-none-eabi
CC = $(ARCH)-gcc 
LD = $(ARCH)-gcc
AS = $(ARCH)-as
OBJCPY = $(ARCH)-objcopy
OBJDMP = $(ARCH)-objdump
GDB = $(ARCH)-gdb

ARM_OPTIONS = -mlittle-endian -mcpu=cortex-m4 -mthumb

CFLAGS = $(ARM_OPTIONS) -std=c99 $(INCLUDES) -D$(MCU) -D__FPU_PRESENT -pedantic-errors
AFLAGS = $(ARM_OPTIONS)

# LFLAGS  = -Map main.map -nostartfiles -T$(LDSCRIPT)  -mcpu=cortex-m4  -Wl,--gc-sections
LFLAGS 	  = -std=c99 $(ARM_OPTIONS) -D$(MCU) -T$(LDSCRIPT) -Wl,--gc-sections


all: Makefile $(BIN) $(HEX)

$(BIN): $(ELF)
	$(OBJCPY) -O binary $< $@
	$(OBJDMP) -x --syms $< > $(addsuffix .dmp, $(basename $<))
	ls -l $@ $<

$(HEX): $(ELF)
	$(OBJCPY) --output-target=ihex $< $@

$(ELF): $(OBJECTS) $(wildcard *.h)
	@$(LD) $(LFLAGS) -o $@ $(OBJECTS)
	@echo "[LD] $<"


$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	@$(CC) -c $(CFLAGS) $< -o $@
	@echo "[CC] $<"

$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	@$(AS) $(AFLAGS) $< -o $@ > $(addprefix $(BUILDDIR)/, $(addsuffix .lst, $(basename $<)))
	@echo "[AS] $<"

flash: $(BIN)
	st-flash write $(BIN) 0x8000000

clean:
	rm -rf $(BUILDDIR)
