#![no_std]
#![no_main]
#![feature(lang_items)]

extern crate my;

#[no_mangle]
pub extern fn main(_argc: int, _argv: *const *const u8) -> int {
  my::get_2()
}

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}
