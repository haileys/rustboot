use32

global __morestack
global start

extern main

start:
    ; rust functions compare esp against [gs:0x30] as a sort of stack guard thing
    ; as long as we set [gs:0x30] to dword 0, it should be ok
    mov [gs:0x30], dword 0
    ; jump into rust
    call main
    jmp $

__morestack:
    jmp $
