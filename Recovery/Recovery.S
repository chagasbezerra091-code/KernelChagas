;========================================================
; KernelChagas Recovery Mode - versão 1.0
; Arquivo único em assembly (.S)
; Autor: Chagas Inc./LLC
; Arquitetura: x86_64
;========================================================

.set STACK_SIZE, 16384

.section .bss
.align 16
stack_bottom:
    .skip STACK_SIZE
stack_top:

.section .rodata
menu_text:
    .asciz "\n\n====================================\n"
    .asciz "     KernelChagas Recovery v1\n"
    .asciz "====================================\n\n"
    .asciz " [1] Reiniciar normalmente\n"
    .asciz " [2] Ver logs do sistema\n"
    .asciz " [3] Resetar (factory reset)\n"
    .asciz " [4] Limpar cache\n"
    .asciz " [5] Testar gráficos\n"
    .asciz " [6] Atualizar o sistema\n"
    .asciz " [7] Fastboot Mode\n\n"
    .asciz "Selecione uma opcao: "

log_buffer:
    .space 4096

; cores simples para teste gráfico
colors:
    .byte 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF

.section .text
.global enter_recovery
.type enter_recovery, @function

;========================================================
; Entrada do modo de recuperação
;========================================================
enter_recovery:
    ; configura stack
    lea stack_top(%rip), %rsp

    call clear_screen
    call print_menu

wait_input:
    call get_key         ; retorna AL com a tecla
    cmp $'1', %al
    je reboot_normal
    cmp $'2', %al
    je show_logs
    cmp $'3', %al
    je factory_reset
    cmp $'4', %al
    je clear_cache
    cmp $'5', %al
    je graphics_test
    cmp $'6', %al
    je system_update
    cmp $'7', %al
    je enter_fastboot
    jmp wait_input

;========================================================
; Funções de cada opção
;========================================================
reboot_normal:
    call k_reboot
    jmp wait_input

show_logs:
    call k_show_logs
    jmp wait_input

factory_reset:
    call k_factory_reset
    jmp wait_input

clear_cache:
    call k_clear_cache
    jmp wait_input

graphics_test:
    call k_graphics_test
    jmp wait_input

system_update:
    call k_update
    jmp wait_input

enter_fastboot:
    call k_fastboot
    jmp wait_input

;========================================================
; Funções auxiliares em assembly
;========================================================

; limpa tela VGA (modo texto 80x25)
clear_screen:
    mov $0x03, %ax      ; modo 80x25 texto
    int $0x10
    ret

; imprime menu
print_menu:
    lea menu_text(%rip), %rsi
.print_loop:
    movzbl (%rsi), %eax
    test %al, %al
    jz .done
    mov $0x0E, %ah      ; teletype
    int $0x10
    inc %rsi
    jmp .print_loop
.done:
    ret

; lê tecla
get_key:
    mov $0x00, %ah
    int $0x16
    ret

;========================================================
; Funções do recovery real
;========================================================

k_reboot:
    mov $0xFE, %al
    out %al, $0x64
    jmp $

k_show_logs:
    ; imprime log_buffer
    lea log_buffer(%rip), %rsi
.print_log:
    movzbl (%rsi), %eax
    test %al, %al
    jz .done_log
    mov $0x0E, %ah
    int $0x10
    inc %rsi
    jmp .print_log
.done_log:
    ret

k_factory_reset:
    ; zera memória do kernel (exemplo)
    mov $0x100000, %rdi
    mov $0, %rax
    mov $1024*1024, %rcx
.rep_reset:
    movb %al, (%rdi)
    inc %rdi
    loop .rep_reset
    ret

k_clear_cache:
    mov $0x200000, %rdi
    mov $0, %rax
    mov $4096, %rcx
.clear_loop:
    movb %al, (%rdi)
    inc %rdi
    loop .clear_loop
    ret

k_graphics_test:
    mov $0xB8000, %rdi      ; framebuffer VGA text mode
    xor %rax, %rax
    mov $80*25, %rcx
.color_loop:
    mov colors(,%rax,1), %bl
    shl $8, %rbx
    movb $32, (%rdi)        ; espaço
    movb %bl, 1(%rdi)       ; cor
    add $2, %rdi
    inc %rax
    cmp $15, %rax
    jle .color_loop
    ret

k_update:
    ; Atualização simulada
    lea menu_text(%rip), %rsi
    mov $0x0E, %ah
    movb $85, (%rsi)        ; muda a primeira letra só para mostrar algo
    ret

k_fastboot:
    ; loop simples fastboot via teclado
.fastboot_loop:
    call get_key
    jmp .fastboot_loop
    ret
