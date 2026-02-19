/// Show the application name and version from Cargo metadata.
pub fn show_version() -> String {
    const NAME: &str = env!("CARGO_PKG_NAME");
    const VERSION: &str = env!("CARGO_PKG_VERSION");
    format!("{} via 🦀 v{}", NAME, VERSION)
}
