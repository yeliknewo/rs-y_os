#![no_std]
#![feature(lang_items)]
#![feature(const_fn)]
#![feature(unique)]

extern crate rlibc;
extern crate spin;
extern crate multiboot2;

#[macro_use]
mod vga_buffer;

#[no_mangle]
pub extern fn rust_main(multiboot_information_address: usize){

    vga_buffer::WRITER.lock().clear_screen();

    println!("Hello world!");

    loop{

    }
}

#[lang = "eh_personality"] extern fn eh_personality(){

}

#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {
    loop{

    }
}
