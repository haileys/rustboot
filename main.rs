#![no_std]
#![allow(ctypes)]

#[derive(Copy, Clone)]
enum Color {
    Black      = 0,
    Blue       = 1,
    Green      = 2,
    Cyan       = 3,
    Red        = 4,
    Pink       = 5,
    Brown      = 6,
    LightGray  = 7,
    DarkGray   = 8,
    LightBlue  = 9,
    LightGreen = 10,
    LightCyan  = 11,
    LightRed   = 12,
    LightPink  = 13,
    Yellow     = 14,
    White      = 15,
}

// enum Option<T> {
//     None,
//     Some(T)
// }

// struct IntRange {
//     cur: i32,
//     max: i32
// }

// impl IntRange {
//     fn next(&mut self) -> Option<i32> {
//         if self.cur < self.max {
//             self.cur += 1;
//             Some(self.cur - 1)
//         } else {
//             None
//         }
//     }
// }

// fn range(lo: i32, hi: i32) -> IntRange {
//     IntRange { cur: lo, max: hi }
// }

fn clear_screen(background: Color) {
    for i in 0..80 * 25 {
        unsafe {
            *((0xb8000 + i * 2) as *mut u16) = (background as u16) << 12;
        }
    }
}

use Color::LightRed;

#[no_mangle]
// #[no_split_stack]
pub fn main() {
    clear_screen(LightRed);
}
