use anyhow::{anyhow, Result};
use std::process::Command;

// Validate if git is installed. If not, return an error message.
pub fn validate_git_command() -> Result<()> {
	Command::new("git")
		.arg("--version")
		.status()
		.map_err(|err| anyhow!("Failed to check git availability: {}", err))
		.and_then(
			|status| {
				if status.success() {
					Ok(())
				} else {
					Err(anyhow!("git command not found"))
				}
			},
		)
	// let output = Command::new("git").arg("--version").output()?;
	//
	// if output.status.success() {
	// 	Ok(())
	// } else {
	// 	Err(Error::msg("Git command not found"))
	// }
}

// #[cfg(test)]
// mod tests {
// 	use super::*;
//
// 	#[test]
// 	fn test_validate_git_command() {
// 		assert!(validate_git_command().is_ok());
// 	}
// }

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_validate_git_exists_success() {
		assert!(validate_git_command().is_ok()); // Assuming git is available
	}

	#[test]
	#[should_panic]
	fn test_validate_git_exists_fail() {
		let mut cmd = Command::new("git");
		cmd.env_remove("PATH"); // Simulate git not being available
		assert!(cmd.arg("--version").status().is_err());

		validate_git_command().unwrap(); // Should panic with a custom error
	}
}
