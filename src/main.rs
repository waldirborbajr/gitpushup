use names::Generator;
use std::fs::Permissions;
use std::process::exit;
use std::process::Command;

fn gitpush() {
    let has_commit = Command::new("git")
        .arg("diff")
        .arg("--quiet")
        .arg("--exit-code")
        .status()
        .expect("Faild to execute git diff command");

    if has_commit.success() {
        println!("Nothing to commit");
        exit(0)
    }

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

    let branch = Command::new("git")
        .arg("rev-parse")
        .arg("--abbrev-ref")
        .arg("HEAD")
        .output()
        .expect("Failed to execute git rev-parse command");

    if !branch.status.success() {
        eprintln!("Error: Failed to get current branch name.");
        exit(1)
    }

    let branch_name = String::from_utf8_lossy(&branch.stdout).trim().to_string();

    let push_command = Command::new("git")
        .arg("push")
        .arg("origin")
        .arg(branch_name)
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
    let generator_output = generator.next().unwrap().to_string();

    format!("{}/{}", now, generator_output)
}

fn show_version() -> String {
    let version = env!("CARGO_PKG_VERSION");
    format!("gitpush v{}/2023", version)
}

fn main() {
    println!("{}", show_version());
    gitpush();
}
