mod git;
mod randmessage;
mod version;

use anyhow::Result;
use colorful::Colorful;
use git::gitpush;
use gitpushup::validate_git_command;
use randmessage::rand_message;
use version::show_version;

/// Command-line argument parser using clap
use clap::Parser;

/// GitPushUp - Automate git add, commit, and push
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Commit message (optional)
    #[arg()]
    message: Option<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    if let Err(e) = validate_git_command() {
        eprintln!("{}", format!("🛑 Error: Git command not found: {e}").red().bold());
        std::process::exit(1);
    }

    let message = args.message.filter(|m| !m.is_empty()).unwrap_or_else(rand_message);

    // Display the version from Cargo
    println!("{}", show_version().green().bold());

    // add + commit + push
    if let Err(e) = gitpush(&message) {
        eprintln!("{}", format!("🛑 Error: {e}").red().bold());
        std::process::exit(1);
    }

    Ok(())
}
