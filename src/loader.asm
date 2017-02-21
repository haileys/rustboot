use16

org 0x7c00

boot:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; 初始化栈
    mov sp, 0x7bfe

    ; 加载rust代码到0x7e00
    mov ah, 2       ; read
    mov al, 24      ; 24 sectors (12 KiB)
    mov ch, 0       ; cylinder & 0xff
    mov cl, 2       ; sector | ((cylinder >> 2) & 0xc0)
    mov dh, 0       ; head
    mov bx, 0x7e00  ; read buffer
    int 0x13
    jc error

    ; 加载保护模式GDT和空IDT
    cli
    lgdt [gdtr]
    lidt [idtr]

    ; 进入保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 加载CS和32位段
    jmp 0x08:protected_mode

error:
    mov si, .msg

.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp .loop

.done:
    jmp $
    .msg db "Could not read disk", 0

protected_mode:
    use32

    ; 用32位数据段加载所有其他段
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax

    ; 设置堆栈
    mov esp, 0x7bfc

    ; 进入rust代码
    call 0x7e00
    jmp $

gdtr:
    dw (gdt_end - gdt) + 1  ; size
    dd gdt                  ; offset

idtr:
    dw 0
    dd 0

gdt:
    ; null entry
    dq 0

    ; code entry
    dw 0xffff       ; limit 0:15
    dw 0x0000       ; base 0:15
    db 0x00         ; base 16:23
    db 0b10011010   ; access byte - code
    db 0x4f         ; flags/(limit 16:19). flag is set to 32 bit protected mode
    db 0x00         ; base 24:31

    ; data entry
    dw 0xffff       ; limit 0:15
    dw 0x0000       ; base 0:15
    db 0x00         ; base 16:23
    db 0b10010010   ; access byte - data
    db 0x4f         ; flags/(limit 16:19). flag is set to 32 bit protected mode
    db 0x00         ; base 24:31

gdt_end:
    times 510-($-$$) db 0    
    db 0x55, 0xaa   ; 设置为bootable device
