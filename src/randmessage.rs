use names::Generator;

pub fn rand_message() -> String {
    let mut generator = Generator::default();
    let generator_output = generator.next().unwrap().to_string();

    format!("{}/{}", "Rand Message: ".to_string(), generator_output).to_string()
}
