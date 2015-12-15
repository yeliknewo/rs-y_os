#![feature(lang_items)]
#![no_std]
#![feature(const_fn)]
#![feature(unique)]

extern crate rlibc;
extern crate spin;

mod vga_buffer;

#[no_mangle]
pub extern fn rust_main(){
    let hello = b"Hello World!";
    let color_byte = 0b0000_1111;

    let mut hello_colored = [color_byte; 24];
    for (i, char_byte) in hello.into_iter().enumerate() {
        hello_colored[i * 2] = *char_byte;
    }

    let buffer_ptr = (0xb8000 + 1988) as *mut _;
    unsafe {
        *buffer_ptr = hello_colored
    };

    vga_buffer::WRITER.lock().write_bytes(b"Hello! \n");

    let mut i = 0;
    let i = i + 1;

    loop{

    }
}

#[lang = "eh_personality"] extern fn eh_personality(){

}

#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {
    loop{

    }
}
