mod git;
mod randmessage;
mod version;

use anyhow::Result;
use colorful::Colorful;
use git::gitpush;
use gitpushup::validate_git_command;
use randmessage::rand_message;
use version::show_version;

fn main() -> Result<()> {
    match validate_git_command() {
        Ok(_) => {}
        Err(_) => {
            eprintln!("{}", "🛑 Error: Git command not found".red().bold());
            std::process::exit(1)
        }
    }

    let mut param = std::env::args().skip(1);

    let message: String = match param.next() {
        Some(content) if !content.is_empty() => content.to_string(),
        _ => rand_message().to_string(),
    };

    eprintln!("PARAM = {}", message);

    // Display the version from Cargo
    println!("{}", show_version().green().bold());

    // add + commit + push
    gitpush(&message);

    Ok(())
}
