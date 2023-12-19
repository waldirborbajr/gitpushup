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
    .expect("Failed to execute git diff command");

  match has_commit.success() {
    true => {
      println!("Nothing to commit");
      std::process::exit(0);
    }
    false => (),
  }

  let add_command =
    Command::new("git").arg("add").arg("-A").output().expect("Failed to execute git add command");

  match !add_command.status.success() {
    true => {
      eprintln!("Error: Failed to add files to git repository.");
      std::process::exit(1);
    }
    false => (),
  }

  let commit_command = Command::new("git")
    .arg("commit")
    .arg("-m")
    .arg(message)
    .output()
    .expect("Failed to execute git commit command");

  match !commit_command.status.success() {
    true => {
      eprintln!("Error: Failed to commit changes to git repository.");
      std::process::exit(1);
    }
    false => (),
  }

  let branch = Command::new("git")
    .arg("rev-parse")
    .arg("--abbrev-ref")
    .arg("HEAD")
    .output()
    .expect("Failed to execute git rev-parse command");

  match !branch.status.success() {
    true => {
      eprintln!("Error: Failed to get current branch name.");
      std::process::exit(1);
    }
    false => (),
  }

  let branch_name = String::from_utf8_lossy(&branch.stdout).trim().to_string();

  let push_command = Command::new("git")
    .arg("push")
    .arg("origin")
    .arg(branch_name)
    .output()
    .expect("Failed to execute git push command");

  match !push_command.status.success() {
    true => {
      eprintln!("{}", "Error: Failed to push changes to git repository.".red().bold());
      std::process::exit(1);
    }
    false => (),
  }

  println!("{}", "Successfully added, committed, and pushed changes!".yellow())
}
