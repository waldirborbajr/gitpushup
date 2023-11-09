use names::Generator;

pub fn rand_message() -> String {
    let now = std::time::SystemTime::now();
    let now = now.duration_since(std::time::UNIX_EPOCH).unwrap();
    let now = now.as_secs();

    let mut generator = Generator::default();
    let generator_output = generator.next().unwrap().to_string();

    format!("{}/{}", now, generator_output).to_string()
}
