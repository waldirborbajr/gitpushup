use std::process::Command;

use anyhow::{bail, Context};

// Validate if git is installed. If not, return an error message.
pub fn find_git_command() -> Result<(), anyhow::Error> {
	let output =
		Command::new("git").arg("--version").output().context("Failed to execute git command")?;

	match output.status.code() {
		Some(0) => Ok(()),
		Some(code) => bail!("git command not found (exit code: {})", code),
		None => bail!("Failed to determine git command exit code"),
	}
	// 	false => Err("🛑 Error: 'git' command not found.".to_string()),
	// }
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_git_exists() {
		// Mock successful git execution
		Command::new("git").arg("--version").output().expect("Failed to mock git command");

		assert!(find_git_command().is_ok());
	}

	#[test]
	fn test_git_not_found() {
		// Mock unsuccessful git execution
		Command::new("invalid_command")
			.arg("--version")
			.output()
			.expect("Failed to mock invalid command");

		assert!(find_git_command().is_err());
	}
}
