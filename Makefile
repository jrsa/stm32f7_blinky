BINARYNAME = main

MCU = STM32F769xx
FW_PACKAGE_DIR = /Users/jrsa/code/stm32/STM32Cube_FW_F7_V1.11.0

# cmsis includes
INCLUDES = -I$(FW_PACKAGE_DIR)/Drivers/CMSIS/Device/ST/STM32F7xx/Include
INCLUDES += -I$(FW_PACKAGE_DIR)/Drivers/CMSIS/Include

# boilerplate initialization files copied from STM32Cube
STARTUP = startup_stm32f769xx.s
SYSTEM = system_stm32f7xx.c

# linker script lives inside STM32Cube
LOADFILE = $(FW_PACKAGE_DIR)/Projects/STM32F769I-Discovery/Templates_LL/SW4STM32/STM32F769I_Discovery_AXIM_FLASH/STM32F769NIHx_FLASH.ld

BUILDDIR = build

SOURCES += $(STARTUP)
SOURCES += $(SYSTEM)

SOURCES += main.c

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

CFLAGS += -std=c99 -mlittle-endian -mthumb $(INCLUDES) -D$(MCU) -D__FPU_PRESENT

AFLAGS  = -mlittle-endian -mthumb -mcpu=cortex-m4

LDSCRIPT = $(LOADFILE)
# LFLAGS  = -Map main.map -nostartfiles -T$(LDSCRIPT)  -mcpu=cortex-m4  -Wl,--gc-sections
LFLAGS 	  = -std=c99 -mcpu=cortex-m4 -mlittle-endian -mthumb -D$(MCU) -T$(LDSCRIPT) -Wl,--gc-sections


all: Makefile $(BIN) $(HEX)

$(BIN): $(ELF)
	$(OBJCPY) -O binary $< $@
	$(OBJDMP) -x --syms $< > $(addsuffix .dmp, $(basename $<))
	ls -l $@ $<

$(HEX): $(ELF)
	$(OBJCPY) --output-target=ihex $< $@

$(ELF): $(OBJECTS) $(wildcard *.h)
	$(LD) $(LFLAGS) -o $@ $(OBJECTS)


$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@


$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(AS) $(AFLAGS) $< -o $@ > $(addprefix $(BUILDDIR)/, $(addsuffix .lst, $(basename $<)))


flash: $(BIN)
	st-flash write $(BIN) 0x8000000

clean:
	rm -rf $(BUILDDIR)
