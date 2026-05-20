//! Compiles Slint UI definitions into Rust code at build time.

fn main() -> Result<(), Box<dyn std::error::Error>> {
    slint_build::compile("ui/app-window.slint")?;
    Ok(())
}
