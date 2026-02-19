use std::io::{self, Write};
use std::process::Command;

/// Prompt the user for a conventional commit message interactively, showing staged changes first.
pub fn prompt_commit_message() -> String {
    // Show staged changes before prompting
    println!("\n--- Staged Changes (git diff --cached) ---");
    let diff_output = Command::new("git")
        .arg("diff")
        .arg("--cached")
        .output();
    match diff_output {
        Ok(output) if !output.stdout.is_empty() => {
            println!("{}", String::from_utf8_lossy(&output.stdout));
        }
        Ok(_) => println!("(No staged changes)"),
        Err(e) => println!("Failed to show staged changes: {e}"),
    }

    let mut commit_type = String::new();
    let mut scope = String::new();
    let mut description = String::new();
    let mut body = String::new();
    let mut footer = String::new();

    println!("\n--- PushupZen Interactive Commit (Commitizen style) ---");
    print!("Type (feat, fix, chore, docs, style, refactor, test, perf): ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut commit_type).unwrap();
    let commit_type = commit_type.trim();

    print!("Scope (optional, e.g. component or file): ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut scope).unwrap();
    let scope = scope.trim();

    print!("Short description (required): ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut description).unwrap();
    let description = description.trim();

    print!("Body (optional, press Enter to skip): ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut body).unwrap();
    let body = body.trim();

    print!("Footer (optional, e.g. Closes #123): ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut footer).unwrap();
    let footer = footer.trim();

    let mut message = String::new();
    if !scope.is_empty() {
        message.push_str(&format!("{}({}): {}", commit_type, scope, description));
    } else {
        message.push_str(&format!("{}: {}", commit_type, description));
    }
    if !body.is_empty() {
        message.push_str(&format!("\n\n{}", body));
    }
    if !footer.is_empty() {
        message.push_str(&format!("\n\n{}", footer));
    }
    message
}
