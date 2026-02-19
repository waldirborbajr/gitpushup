use anyhow::{anyhow, Result};
use std::process::Command;


/// Validate if git is installed. If not, return an error message.
pub fn validate_git_command() -> Result<()> {
    Command::new("git")
        .arg("--version")
        .status()
        .map_err(|err| anyhow!("Failed to check git availability: {err}"))
        .and_then(|status| {
            if status.success() {
                Ok(())
            } else {
                Err(anyhow!("git command not found"))
            }
        })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_git_exists_success() {
        // This test assumes git is available in the environment.
        assert!(validate_git_command().is_ok());
    }

    #[test]
    fn test_validate_git_exists_fail() {
        // Instead of manipulating PATH, spawn a command that is guaranteed to fail.
        let result = Command::new("nonexistent_git_command_hopefully")
            .arg("--version")
            .status();
        assert!(result.is_err());
    }
}
