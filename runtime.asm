use32

global start

extern main

start:
    ; jump into rust
    call main
    jmp $
