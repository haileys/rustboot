use32

global _GLOBAL_OFFSET_TABLE_
global __morestack
global abort
global memcmp
global memcpy
global malloc
global free
global start

extern main

start:
    ; rust functions compare esp against [gs:0x30] as a sort of stack guard thing
    ; as long as we set [gs:0x30] to dword 0, it should be ok
    mov [gs:0x30], dword 0
    ; clear the screen a slightly different colour
    mov edi, 0xb8000
    mov ecx, 80*25*2
    mov al, 1
    rep stosb
    ; jump into rust
    jmp main

_GLOBAL_OFFSET_TABLE_:

__morestack:

abort:
    jmp $

memcmp:
    jmp $

memcpy:
    jmp $

malloc:
    jmp $

free:
    jmp $
