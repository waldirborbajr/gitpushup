#[warn(dead_code)]
pub fn show_version() -> String {
    const NAME: &str = env!("CARGO_PKG_NAME");
    const VERSION: &str = env!("CARGO_PKG_VERSION");
    format!("{} via 🦀 v{}/2023", NAME, VERSION)
}
