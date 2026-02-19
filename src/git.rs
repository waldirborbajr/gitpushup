
use std::process::Command;
use colorful::Colorful;

/// Adds, commits, and pushes changes to the current git branch.
/// Returns Ok(()) on success, or an error message on failure.
pub fn gitpush(message: &str) -> anyhow::Result<()> {
    // Check if there are changes to commit
    let has_commit = Command::new("git")
        .arg("diff")
        .arg("--quiet")
        .arg("--exit-code")
        .status()
        .map_err(|e| anyhow::anyhow!("Failed to execute git diff command: {e}"))?;

    if has_commit.success() {
        println!("Nothing to commit");
        return Ok(());
    }

    let add_status = Command::new("git")
        .arg("add")
        .arg("-A")
        .status()
        .map_err(|e| anyhow::anyhow!("Failed to execute git add command: {e}"))?;
    if !add_status.success() {
        anyhow::bail!("🛑 Error: Failed to add files to git repository.");
    }

    let commit_status = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg(message)
        .status()
        .map_err(|e| anyhow::anyhow!("Failed to execute git commit command: {e}"))?;
    if !commit_status.success() {
        anyhow::bail!("🛑 Error: Failed to commit changes to git repository.");
    }

    let branch = Command::new("git")
        .arg("rev-parse")
        .arg("--abbrev-ref")
        .arg("HEAD")
        .output()
        .map_err(|e| anyhow::anyhow!("Failed to execute git rev-parse command: {e}"))?;
    if !branch.status.success() {
        anyhow::bail!("Error: Failed to get current branch name.");
    }
    let branch_name = String::from_utf8_lossy(&branch.stdout).trim().to_string();

    let push_status = Command::new("git")
        .arg("push")
        .arg("origin")
        .arg(&branch_name)
        .status()
        .map_err(|e| anyhow::anyhow!("Failed to execute git push command: {e}"))?;
    if !push_status.success() {
        anyhow::bail!("🛑 Error: Failed to push changes to git repository.");
    }

    println!("{}", "🚀 Successfully added, committed, and pushed changes!".yellow());
    Ok(())
}
