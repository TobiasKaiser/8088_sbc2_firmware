# 8088_sbc2_firmware

Memory map (physical addresses):

* 0x00000 - 0x7FFFF: 512 KB SRAM
* 0x80000 - 0x8FFFF: 8 KB EEPROM
* (0x80000 - 0xFFFFF): 8 KB EEPROM (appears multiple times)

IO map:

* 0x00 - 0x1f: Read = Switches, Write = LEDs
* 0x20 - 0x3f: 16550 UART