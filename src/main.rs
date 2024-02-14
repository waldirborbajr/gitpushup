mod git;
mod randmessage;
mod version;

use anyhow::Result;
use colorful::Colorful;
use git::gitpush;
use gitpushup::find_git_command;
use randmessage::rand_message;
use version::show_version;

fn main() -> Result<()> {
	let status = find_git_command();
	match status {
		Ok(_) => (),
		Err(_) => {
			eprintln!("{} {}", "🛑 git".red().bold(), "not found. Please install before using".red());
			std::process::exit(1)
		}
	}

	let mut param = std::env::args().skip(1);

	let message: String = match param.next() {
		Some(content) if !content.is_empty() => content.to_string(),
		_ => rand_message().to_string(),
	};

	// Display the version from Cargo
	println!("{}", show_version().green().bold());

	// add + commit + push
	gitpush(&message);

	// std::process::exit(0)

	Ok(())
}
