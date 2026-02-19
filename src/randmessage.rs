use names::Generator;

/// Generate a random commit message using the `names` crate.
pub fn rand_message() -> String {
    let mut generator = Generator::default();
    let generator_output = generator.next().unwrap_or_else(|| "random-commit".into());
    format!("Rand Message: {}", generator_output)
}
