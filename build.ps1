.\clean.ps1
rustc.exe -O --target i686-unknown-linux-gnu --crate-type lib -o build\main.o --emit obj src\main.rs
bash.exe -e -c "ld -m elf_i386 -o ./build/main.bin -T linker.ld build/main.o"
nasm.exe -o .\build\loader.bin -f bin .\src\loader.asm
Get-Content build\loader.bin,build\main.bin -Encoding Byte | Set-Content dist\fanmi_os.img -Encoding Byte