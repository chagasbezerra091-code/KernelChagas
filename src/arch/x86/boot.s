; boot.s - bootloader 16-bit real mode (BIOS)
; Deve ter exatamente 512 bytes com 0x55AA no final

BITS 16                ; modo real 16-bit

ORG 0x7C00             ; endereço onde a BIOS carrega

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00     ; stack simples

    sti

    ; mensagem na tela
    mov si, msg
    call print_string

    ; Carregar o kernel (1 setor após o bootloader)
    mov bx, 0x1000     ; onde kernel será carregado (0x1000:0000)
    mov es, bx
    xor bx, bx

    mov ah, 0x02       ; função BIOS - ler setor
    mov al, 10         ; quantos setores ler (ajuste depois)
    mov ch, 0          ; cilindro
    mov cl, 2          ; setor 2 (setor após o bootloader)
    mov dh, 0          ; cabeça
    mov dl, [BOOT_DRIVE]

    int 0x13
    jc disk_error

    ; pular para o kernel
    jmp 0x1000:0000    ; execução começa no kernel

hang:
    cli
    hlt
    jmp hang

; ---------- Funções ----------

print_string:
    mov ah, 0x0E       ; teletype
.next:
    lodsb
    or al, al
    jz .end
    int 0x10
    jmp .next
.end:
    ret

disk_error:
    mov si, disk_msg
    call print_string
    jmp hang

; ---------- Dados ----------

msg:
    db \"Bootloader iniciado!\", 0
disk_msg:
    db \"Erro ao ler disco!\", 0

BOOT_DRIVE:
    db 0               ; BIOS coloca drive aqui

; ---------- Padding + assinatura ----------

times 510-($-$$) db 0
dw 0xAA55             ; assinatura obrigatória
