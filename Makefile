PREFIX	= arm-none-eabi
CC		= $(PREFIX)-gcc
LINK	= $(PREFIX)-gcc
OBJCOPY = $(PREFIX)-objcopy

LINK_SCRIPT = STM32F103XB_FLASH.ld
BOARD = STM32F103xB

.SECONDEXPANSION:

H   = $(shell find ./ -name "*.h" -exec dirname {} \; | sort -u)
C   = $(subst ./,,$(shell find src -name "*.c"))
S   = $(subst ./,,$(shell find src -name "*.s"))
Supper = $(subst ./,,$(shell find src -name "*.S")) 
INCLUDES = $(addprefix -I,$(H))

OBJPATH = buildir
O  = $(C:%.c=%.o)
O += $(S:%.s=%.o)
O += $(Supper:%.S=%.o)
OBJ = $(addprefix $(OBJPATH)/, $(O))

TARGET	= bin/main.elf
MAP_FILE=$(notdir $(CURDIR)).map

DEFINES += -D$(BOARD)
CFLAGS =   -mcpu=cortex-m3 -mthumb $(DEFINES)
LDFLAGS = -T$(LINK_SCRIPT) -mthumb -mcpu=cortex-m3 -Wl,-Map=$(MAP_FILE) -nostdlib


.PHONY:  clean flash

all: clean makepath $(TARGET) flash

$(TARGET): $(OBJ) 
	@echo $< : $@
	@$(CC) $(LDFLAGS) -o $(TARGET)  $(OBJ) 
	@$(OBJCOPY) -O ihex $(TARGET) $(basename $(TARGET)).hex
	@$(OBJCOPY) -O binary $(TARGET) $(basename $(TARGET)).bin

makepath: 
	@mkdir -p buildir	
	@mkdir -p bin


$(OBJPATH)/%.o:%.c
	@echo $< : $@
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS)  $(LDFLAGS)  $(INCLUDES) -c $< -o $(basename $@).o

$(OBJPATH)/%.o:%.s
	@echo $< : $@
	@$(CC)   $(CFLAGS)  $(LDFLAGS)  $(INCLUDES) -c $< -o $(basename $@).o

$(OBJPATH)/%.o:%.S
	@echo $< : $@
	@$(CC) $(CFLAGS)   $(LDFLAGS)  $(INCLUDES)  -c $< -o $(basename $@).o

flash:
	openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c "init; reset halt; stm32f1x unlock 0; reset halt; exit"
	st-flash  write $(basename $(TARGET)).bin 0x8000000

run:
	./Tools/xPacks/openocd/0.10.0-13/bin/openocd -f Tools/xPacks/openocd/0.10.0-13/scripts/interface/stlink.cfg -f Tools/xPacks/openocd/0.10.0-13/scripts/target/stm8s.cfg -c "init" -c "reset halt; resume"

debug:
	echo $(INCLUDES)

openocd: 
	./Tools/xPacks/openocd/0.10.0-13/bin/openocd -f Tools/xPacks/openocd/0.10.0-13/scripts/interface/stlink.cfg -f Tools/xPacks/openocd/0.10.0-13/scripts/target/stm8s.cfg -c "init" -c "reset halt"


clean:
	@echo ---- CLEANING ----
	@rm -fR  $(OBJPATH)
	@rm -fR  bin/*
