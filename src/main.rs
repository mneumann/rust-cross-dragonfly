#![no_std]
#![no_main]
#![feature(lang_items)]

extern crate my;
extern crate core;

#[no_mangle]
pub extern fn main(_argc: int, _argv: *const *const u8) -> int {
  my::get_2()
}

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "begin_unwind"] extern fn rust_begin_unwind(a: &core::fmt::Arguments, b: &str, c: uint) {
  // XXX: never return
}
