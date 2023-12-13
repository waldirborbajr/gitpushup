use std::process::Command;

// Validate if git is installed. If not, return an error message.

pub fn find_git_command() -> Result<(), String> {
  let status = Command::new("git").arg("--version").output();

  match status {
    Ok(exit_status) => {
      if exit_status.status.success() {
        Ok(())
      } else {
        Err("Error: 'git' command exited with non-zero status.".to_string())
      }
    }
    Err(_) => Err("Error: 'git' command not found.".to_string()),
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn find_git_command_success() {
    let result = find_git_command();
    assert!(result.is_ok());
  }

  #[test]
  #[ignore]
  fn find_git_command_error() {
    let result = Command::new("nonexistentcommand").arg("--version").output();
    assert_eq!(find_git_command(), Err("Error: 'git' command not found.".to_string()));
    assert!(result.is_err());
  }
}
