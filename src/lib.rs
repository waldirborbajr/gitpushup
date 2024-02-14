use std::process::Command;

// Validate if git is installed. If not, return an error message.
pub fn find_git_command() -> Result<(), String> {
	let gitcommand = Command::new("git").arg("--version").output().expect("Error");

	match gitcommand.status.success() {
		true => Ok(()),
		false => Err("Error: 'git' command exited with non-zero status.".to_string()),
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_git_exists() {
		// Mock successful git execution
		Command::new("gitA").arg("--version").output().expect("Failed to mock git command");

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
