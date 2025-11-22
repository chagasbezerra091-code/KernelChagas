/* boot.S - com pré-processador C */

#define LOAD_SEG 0x1000

    .code16
    .org 0x7C00

start:
    cli
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7C00, %sp
    sti

    lea msg, %si
    call print_string

    mov $LOAD_SEG, %bx
    mov %bx, %es
    xor %bx, %bx

    mov $0x02, %ah
    mov $10, %al
    mov $0, %ch
    mov $2,  %cl
    mov $0,  %dh
    mov BOOT_DRIVE, %dl

    int $0x13
    jc disk_error

    ljmp $LOAD_SEG, $0

hang:
    cli
    hlt
    jmp hang

print_string:
    mov $0x0E, %ah
1:
    lodsb
    or %al, %al
    jz 2f
    int $0x10
    jmp 1b
2:
    ret

disk_error:
    lea disk_msg, %si
    call print_string
    jmp hang

msg:
    .asciz \"Bootloader .S rodando!\\n\"
disk_msg:
    .asciz \"Falha no disco!\\n\"

BOOT_DRIVE:
    .byte 0

    .org 510
    .word 0xAA55
