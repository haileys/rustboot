#![feature(custom_attribute)]
#![no_std]
#![allow(dead_code)]
#![allow(unused_attributes)]
#![feature(asm)]

#[derive(Copy, Clone)]
enum Color {
    Black = 0x0,
    Blue = 0x1,
    Green = 0x2,
    Cyan = 0x3,
    Red = 0x4,
    Pink = 0x5,
    Brown = 0x6,
    LightGray = 0x7,
    DarkGray = 0x8,
    LightBlue = 0x9,
    LightGreen = 0xa,
    LightCyan = 0xb,
    LightRed = 0xc,
    LightPink = 0xd,
    Yellow = 0xe,
    White = 0xf,
}

fn write_memory<T>(addr: u32, data: T) {
    unsafe {
        *(addr as *mut T) = data;
    }
}

fn clear_screen(background: Color) {
    let base_addr = 0xb8000;
    for i in 0..80 * 25 {
        write_memory::<u32>(base_addr + i * 2, (background as u32) << 12);
    }
}

fn halt() {
    unsafe {
        asm!("hlt");
        asm!("ret");
    }
}

fn putchar(addr: u32, background_color: Color, foreground_color: Color, chr: char) {
    let data: u16 = ((background_color as u16) << 12) | ((foreground_color as u16) << 8) |
                    (chr as u16);
    write_memory::<u16>(addr, data);
}

fn print(addr: u32, background_color: Color, foreground_color: Color, msg: &[char]) {
    let mut index = 0;
    for chr in msg {
        putchar(addr + index, background_color, foreground_color, *chr);
        index += 2;
    }
}

#[no_mangle]
#[no_split_stack]
pub fn main() {
    let background_color = Color::LightBlue;
    let foreground_color = Color::White;

    clear_screen(background_color);

    let msg = ['H', 'e', 'l', 'l', 'o', ',', ' ', 'F', 'a', 'n', 'm', 'i', 'O', 'S'];
    print(0xb8000, background_color, foreground_color, &msg);

    loop {
        halt();
    }
}
