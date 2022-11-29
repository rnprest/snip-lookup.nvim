// lib.rs
use nvim_oxi as oxi;

#[oxi::module]
fn snip_lookup_rust() -> oxi::Result<i32> {
    Ok(42)
}
