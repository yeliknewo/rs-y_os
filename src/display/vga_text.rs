use spin::Mutex;

use core::ptr::Unique;
use core::fmt;

const BUFFER_HEIGHT: usize = 25;
const BUFFER_WIDTH: usize = 80;

macro_rules! println {
    ($fmt:expr) => (print!(concat!($fmt, "\n")));
    ($fmt:expr, $($arg:tt)*) => (print!(concat!($fmt, "\n"), $($arg)*));
}

macro_rules! print {
    ($($arg:tt)*) => ({
            use core::fmt::Write;
            match $crate::display::WRITER.lock().write_fmt(format_args!($($arg)*)) {
                Ok(_) => (),
                Err(_) => panic!("Unable To Write Format"),
            }
    });
}

pub static WRITER: Mutex<Writer> = Mutex::new(Writer {
    column_position: 0,
    color_code: ColorCode::new(Color::White, Color::Black),
    buffer: unsafe {
        Unique::new(0xb8000 as *mut _)
    },
});

pub struct Writer {
    column_position: usize,
    color_code: ColorCode,
    buffer: Unique<Buffer>,
}

impl Writer {
    pub fn write_byte(&mut self, byte: u8) {
        match byte {
            b'\n' => self.new_line(),
            byte => {
                if self.column_position >= BUFFER_WIDTH {
                    self.new_line();
                }
                let row = BUFFER_HEIGHT - 1;
                let col = self.column_position;

                self.get_mut_buffer().chars[row][col] = ScreenChar {
                    ascii_character: byte,
                    color_code: self.color_code,
                };
                self.column_position += 1;
            }
        }
    }

    fn new_line(&mut self) {
        for row in 0..(BUFFER_HEIGHT - 1) {
            let buffer : &mut Buffer = self.get_mut_buffer();
            buffer.chars[row] = buffer.chars[row + 1];
        }
        self.clear_row(BUFFER_HEIGHT - 1);
        self.column_position = 0;
    }

    fn clear_row(&mut self, row: usize) {
        let blank = ScreenChar {
            ascii_character: b' ',
            color_code: self.color_code,
        };
        self.get_mut_buffer().chars[row] = [blank; BUFFER_WIDTH];
    }

    fn get_buffer(&self) -> &Buffer {
        unsafe {
            self.buffer.get()
        }
    }

    fn get_mut_buffer(&mut self) -> &mut Buffer {
        unsafe{
            self.buffer.get_mut()
        }
    }
}

impl fmt::Write for Writer {
    fn write_str(&mut self, s: &str) -> ::core::fmt::Result {
        for byte in s.bytes() {
            self.write_byte(byte);
        }
        Ok(())
    }
}

struct Buffer {
    chars: [[ScreenChar; BUFFER_WIDTH]; BUFFER_HEIGHT],
}

#[derive(Clone, Copy)]
#[repr(C)]
struct ScreenChar {
    ascii_character: u8,
    color_code: ColorCode,
}

#[derive(Clone, Copy)]
struct ColorCode(u8);

impl ColorCode {
    const fn new(foreground:Color, background:Color) -> ColorCode {
        ColorCode((background as u8) << 4 | (foreground as u8))
    }
}

#[allow(dead_code)]
#[repr(u8)]
pub enum Color {
    Black       = 0x0,
    Blue        = 0x1,
    Green       = 0x2,
    Cyan        = 0x3,
    Red         = 0x4,
    Magenta     = 0x5,
    Brown       = 0x6,
    LightGrey   = 0x7,
    DarkGrey    = 0x8,
    LightBlue   = 0x9,
    LightGreen  = 0xA,
    LightCyan   = 0xB,
    LightRed    = 0xC,
    Pink        = 0xD,
    Yellow      = 0xE,
    White       = 0xF,
}
