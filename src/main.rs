use names::Generator;
use std::process::exit;
use std::process::Command;

fn gitpush() {
    let add_command = Command::new("git")
        .arg("add")
        .arg("-A")
        .output()
        .expect("Failed to execute git add command");

    if !add_command.status.success() {
        eprintln!("Error: Failed to add files to git repository.");
        exit(1)
    }

    let commit_command = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg(name_generator())
        .output()
        .expect("Failed to execute git commit command");

    if !commit_command.status.success() {
        eprintln!("Error: Failed to commit changes to git repository.");
        exit(1)
    }

    let push_command = Command::new("git")
        .arg("push")
        .arg("origin")
        .arg("main")
        .output()
        .expect("Failed to execute git push command");

    if !push_command.status.success() {
        eprintln!("Error: Failed to push changes to git repository.");
        exit(1)
    }

    println!("Successfully added, committed, and pushed changes!");
}

fn name_generator() -> String {
    let now = std::time::SystemTime::now();
    let now = now.duration_since(std::time::UNIX_EPOCH).unwrap();
    let now = now.as_secs();

    let mut generator = Generator::default();
    generator.next().unwrap() + now.to_string().as_str()
}

fn main() {
    gitpush();
}
