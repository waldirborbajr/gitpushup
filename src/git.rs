use std::process::exit;

use colorful::Colorful;
use std::process::Command;

#[warn(dead_code)]
pub fn gitpush(message: &str) {
  // TODO: use git commit -pm "message"

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

  let add_command = Command::new("git").arg("add").arg("-A").output().expect("Failed to execute git add command");

  if !add_command.status.success() {
    eprintln!("Error: Failed to add files to git repository.");
    exit(1)
  }

  let commit_command =
    Command::new("git").arg("commit").arg("-m").arg(message).output().expect("Failed to execute git commit command");

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

  println!("{}", "Successfully added, committed, and pushed changes!".yellow())
}
