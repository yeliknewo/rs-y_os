#![feature(lang_items, const_fn, unique)]
#![no_std]

extern crate rlibc;
extern crate spin;

#[macro_use]
mod display;

#[no_mangle]
pub extern fn rust_main() {
    println!("Hello World!");

    loop{

    }
}

#[lang = "eh_personality"]
extern fn eh_personality () {

}

#[lang = "panic_fmt"]
extern fn panic_fmt(fmt: core::fmt::Arguments, file: &str, line: u32) -> ! {
    println!("\n\nPANIC in {} at line {}:", file, line);
    println!("    {}", fmt);
    loop{
        
    }
}
