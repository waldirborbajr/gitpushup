mod git;
mod randmessage;
mod version;

use std::process::Command;

use colorful::Colorful;
use git::gitpush;
use gitpushup::find_git_command;
use randmessage::rand_message;
use version::show_version;

fn main() {
  let output = Command::new("git").output().expect("Failed to execute git command.");

  let output_string = String::from_utf8_lossy(&output.stderr);

  let cmd_to_run = find_git_command(&output_string).unwrap_or("");
  match cmd_to_run.eq("") {
    true => eprintln!("{}", "git not found. Please install before using".red().bold()),
    false => (),
  }

  let mut param = std::env::args().skip(1);

  let message = match param.next() {
    Some(content) if !content.is_empty() => content.to_string(),
    _ => rand_message().to_string(),
  };

  // Display the version from Cargo
  println!("{}", show_version().green().bold());

  // add + commit + push
  gitpush(&message);

  std::process::exit(0)
}
