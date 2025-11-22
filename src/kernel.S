; kernel.S — entrada do kernel x86_64
; usa multiboot2 (carregado pelo GRUB)
; compilado com o GCC + pré-processador

.set ALIGN,    1<<0
.set MEMINFO,  1<<1
.set FLAGS,    ALIGN | MEMINFO
.set MAGIC,    0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

.section .text
.global _start
.type _start, @function

_start:
    ; Primeiro ponto executado pelo GRUB
    ; Ainda não tem stack → vamos criar

    lea stack_top(%rip), %rsp     ; define stack pointer

    ; chama a função C principal
    call kmain

halt:
    cli
    hlt
    jmp halt
