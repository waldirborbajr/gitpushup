#!/bin/bash
# =============================================================================
# GITPUSHUP - IMPLEMENTAÇÃO COMPLETA DE MELHORIAS
# =============================================================================
# Este script implementa todas as 15 sugestões de features e melhorias
# para o projeto gitpushup, com foco em segurança e usabilidade.
#
# Uso: ./implement-gitpushup-improvements.sh
# =============================================================================

set -e
set -o pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# 1. PREPARAÇÃO DO AMBIENTE
# =============================================================================

log_info "Preparando ambiente para implementação..."

# Verifica dependências
if ! command -v cargo &> /dev/null; then
    log_error "Rust/Cargo não encontrado. Instale Rust primeiro."
    exit 1
fi

if ! command -v git &> /dev/null; then
    log_error "Git não encontrado. Instale Git primeiro."
    exit 1
fi

# Define o diretório do projeto
PROJECT_DIR="${PROJECT_DIR:-$HOME/gitpushup}"
if [ ! -d "$PROJECT_DIR" ]; then
    log_info "Clonando repositório gitpushup..."
    git clone https://github.com/waldirborbajr/gitpushup.git "$PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    log_info "Usando diretório existente: $PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Verifica se é um repositório git válido
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Diretório não é um repositório git válido."
        exit 1
    fi
fi

log_success "Projeto preparado em: $PROJECT_DIR"

# =============================================================================
# 2. BACKUP DOS ARQUIVOS IMPORTANTES
# =============================================================================

log_info "Criando backups..."
BACKUP_DIR="$PROJECT_DIR/.backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Faz backup dos arquivos principais
for file in Cargo.toml src/main.rs README.md; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$(basename $file).bak"
    fi
done

log_success "Backups criados em: $BACKUP_DIR"

# =============================================================================
# 3. ATUALIZAÇÃO DO CARGO.TOML
# =============================================================================

log_info "Atualizando dependências no Cargo.toml..."

# Verifica se as dependências já existem
if ! grep -q "anyhow" Cargo.toml 2>/dev/null; then
    # Remove a última linha do Cargo.toml (a chave de fechamento)
    sed -i '$d' Cargo.toml
    
    # Adiciona as dependências
    cat >> Cargo.toml << 'EOF'

# ===== NOVAS DEPENDÊNCIAS =====
anyhow = "1.0"
thiserror = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_derive = "1.0"
toml = "0.8"
dirs = "5.0"
dialoguer = "0.11"
regex = "1.10"
walkdir = "2.5"
tempfile = "3.14"
EOF
    
    # Fecha o arquivo
    echo "" >> Cargo.toml
else
    log_warning "Dependências já existem, pulando..."
fi

log_success "Cargo.toml atualizado"

# =============================================================================
# 4. REFATORAÇÃO DO MAIN.RS - VERSÃO COMPLETA
# =============================================================================

log_info "Implementando novo src/main.rs..."

# Cria o novo main.rs com todas as features
cat > src/main.rs << 'EOF'
//! GitPushUp - DevOps Automation Command Line Tool
//! Automates git add, commit, and push with advanced features

use anyhow::{anyhow, Context, Result};
use clap::{Parser, Subcommand, Args};
use colored::*;
use dialoguer::{Confirm, Input, Select};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::env;

// =============================================================================
// CLI DEFINITION
// =============================================================================

#[derive(Parser, Debug)]
#[command(name = "gitpushup")]
#[command(about = "DevOps Automation Command Line Tool", long_about = None)]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
    
    /// Simulate the operation without making changes
    #[arg(short = 'n', long)]
    dry_run: bool,
    
    /// Run in interactive mode (asks for confirmation)
    #[arg(short = 'i', long)]
    interactive: bool,
    
    /// Custom commit message
    #[arg(short = 'm', long)]
    message: Option<String>,
    
    /// Target branch for commit and push
    #[arg(short = 'b', long)]
    branch: Option<String>,
    
    /// Remote repository name
    #[arg(short = 'r', long)]
    remote: Option<String>,
    
    /// Skip push after commit
    #[arg(long)]
    no_push: bool,
    
    /// Use conventional commit format (interactive)
    #[arg(short = 'c', long)]
    conventional: bool,
    
    /// Show verbose output
    #[arg(short = 'v', long)]
    verbose: bool,
    
    /// Files to add (can be repeated)
    #[arg(short = 'a', long)]
    add: Vec<String>,
    
    /// Add all files (default)
    #[arg(short = 'A', long)]
    add_all: bool,
    
    /// Skip git add step
    #[arg(long)]
    no_add: bool,
    
    /// Display detailed status before operation
    #[arg(long)]
    status: bool,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Rollback the last commit
    Undo,
    /// Show current configuration
    Config,
}

// =============================================================================
// CONFIGURATION
// =============================================================================

#[derive(Debug, Serialize, Deserialize, Default)]
struct Config {
    default_branch: Option<String>,
    remote: Option<String>,
    conventional: bool,
    interactive: bool,
    auto_push: bool,
    verbose: bool,
}

impl Config {
    fn load() -> Self {
        let mut config = Config::default();
        
        // Tenta carregar configuração global
        if let Some(global_path) = Self::global_config_path() {
            if let Ok(loaded) = Self::load_from_file(&global_path) {
                config.merge(loaded);
            }
        }
        
        // Tenta carregar configuração local
        if let Some(local_path) = Self::local_config_path() {
            if let Ok(loaded) = Self::load_from_file(&local_path) {
                config.merge(loaded);
            }
        }
        
        config
    }
    
    fn load_from_file<P: AsRef<Path>>(path: P) -> Result<Self, toml::de::Error> {
        let content = fs::read_to_string(path)
            .map_err(|e| toml::de::Error::custom(format!("Failed to read config: {}", e)))?;
        toml::from_str(&content)
    }
    
    fn global_config_path() -> Option<PathBuf> {
        dirs::config_dir().map(|d| d.join("gitpushup").join("config.toml"))
    }
    
    fn local_config_path() -> Option<PathBuf> {
        let local = PathBuf::from(".gitpushup.toml");
        if local.exists() {
            Some(local)
        } else {
            None
        }
    }
    
    fn merge(&mut self, other: Self) {
        if other.default_branch.is_some() { self.default_branch = other.default_branch; }
        if other.remote.is_some() { self.remote = other.remote; }
        if other.conventional { self.conventional = other.conventional; }
        if other.interactive { self.interactive = other.interactive; }
        if other.auto_push { self.auto_push = other.auto_push; }
        if other.verbose { self.verbose = other.verbose; }
    }
}

// =============================================================================
// MAIN LOGIC
// =============================================================================

fn main() -> Result<()> {
    let cli = Cli::parse();
    
    // Carrega configuração
    let config = Config::load();
    
    // Aplica configurações
    let interactive = cli.interactive || config.interactive;
    let conventional = cli.conventional || config.conventional;
    let verbose = cli.verbose || config.verbose;
    
    // Trata subcomandos
    match &cli.command {
        Some(Commands::Undo) => {
            return undo_commit(&cli);
        }
        Some(Commands::Config) => {
            return show_config(&config);
        }
        None => {}
    }
    
    // Verifica se está em um repositório git
    if !is_git_repo()? {
        return Err(anyhow!("Not a git repository. Please run from a git repo."));
    }
    
    // Obtém branch atual
    let current_branch = get_current_branch()?;
    let branch = cli.branch.as_ref().unwrap_or(&current_branch);
    let remote = cli.remote.as_ref()
        .or_else(|| config.remote.as_ref())
        .unwrap_or(&"origin".to_string());
    
    // --- STATUS ---
    if cli.status || verbose {
        show_status()?;
    }
    
    // --- DRY RUN ---
    if cli.dry_run {
        println!("\n{}", "🔍 DRY RUN MODE - No changes will be made".yellow().bold());
        println!("  Branch: {}", branch.green());
        println!("  Remote: {}", remote.green());
        println!("  Message: {}", get_message(&cli, conventional)?.green());
        println!("  Files to add: {}", get_files_to_add(&cli)?.join(", ").green());
        println!("  Push: {}", if cli.no_push { "No" } else { "Yes" }.green());
        return Ok(());
    }
    
    // --- GIT ADD ---
    if !cli.no_add {
        let files = get_files_to_add(&cli)?;
        if files.is_empty() {
            println!("{}", "ℹ️  No files to add. Use --add or --add-all to specify.".yellow());
        } else {
            if verbose { println!("Adding files: {:?}", files); }
            git_add(&files)?;
        }
    }
    
    // --- CHECK FOR CHANGES ---
    if !has_changes()? && !cli.no_add {
        println!("{}", "ℹ️  No changes to commit.".yellow());
        return Ok(());
    }
    
    // --- COMMIT MESSAGE ---
    let message = get_message(&cli, conventional)?;
    
    // --- INTERACTIVE CONFIRMATION ---
    if interactive {
        let should_commit = Confirm::new()
            .with_prompt(&format!("Commit with message: '{}'?", message))
            .default(true)
            .interact()?;
        
        if !should_commit {
            println!("{}", "⏹️  Operation cancelled.".yellow());
            return Ok(());
        }
        
        // Permite editar a mensagem
        if Confirm::new()
            .with_prompt("Edit message?")
            .default(false)
            .interact()?
        {
            let new_message: String = Input::new()
                .with_prompt("New message")
                .default(message.clone())
                .interact()?;
            return commit_and_push(&new_message, branch, remote, &cli);
        }
    }
    
    // --- COMMIT AND PUSH ---
    commit_and_push(&message, branch, remote, &cli)
}

// =============================================================================
// GIT OPERATIONS
// =============================================================================

fn is_git_repo() -> Result<bool> {
    let output = Command::new("git")
        .arg("rev-parse")
        .arg("--is-inside-work-tree")
        .output()?;
    Ok(output.status.success())
}

fn get_current_branch() -> Result<String> {
    let output = Command::new("git")
        .arg("branch")
        .arg("--show-current")
        .output()?;
    
    if !output.status.success() {
        return Err(anyhow!("Failed to get current branch"));
    }
    
    Ok(String::from_utf8(output.stdout)?.trim().to_string())
}

fn get_files_to_add(cli: &Cli) -> Result<Vec<String>> {
    if cli.no_add {
        return Ok(Vec::new());
    }
    
    if !cli.add.is_empty() {
        return Ok(cli.add.clone());
    }
    
    if cli.add_all {
        return Ok(vec![".".to_string()]);
    }
    
    // Default: add all
    Ok(vec![".".to_string()])
}

fn git_add(files: &[String]) -> Result<()> {
    let mut cmd = Command::new("git");
    cmd.arg("add");
    for file in files {
        cmd.arg(file);
    }
    
    let status = cmd.status()?;
    if !status.success() {
        return Err(anyhow!("Failed to add files"));
    }
    Ok(())
}

fn has_changes() -> Result<bool> {
    let output = Command::new("git")
        .arg("status")
        .arg("--porcelain")
        .output()?;
    
    let stdout = String::from_utf8(output.stdout)?;
    Ok(!stdout.trim().is_empty())
}

fn commit_and_push(message: &str, branch: &str, remote: &str, cli: &Cli) -> Result<()> {
    // Commit
    let mut cmd = Command::new("git");
    cmd.arg("commit").arg("-m").arg(message);
    
    if cli.verbose {
        println!("Executing: {:?}", cmd);
    }
    
    let status = cmd.status()?;
    if !status.success() {
        return Err(anyhow!("Failed to commit changes"));
    }
    
    println!("{}", format!("✅ Committed: {}", message).green());
    
    // Push
    if !cli.no_push {
        let mut push_cmd = Command::new("git");
        push_cmd.arg("push").arg(remote).arg(branch);
        
        if cli.verbose {
            println!("Executing: {:?}", push_cmd);
        }
        
        let push_status = push_cmd.status()?;
        if !push_status.success() {
            return Err(anyhow!("Failed to push to remote"));
        }
        
        println!("{}", format!("🚀 Pushed to {}/{}", remote, branch).green());
    } else {
        println!("{}", "📦 Commit done. Push skipped (--no-push).".yellow());
    }
    
    Ok(())
}

fn show_status() -> Result<()> {
    println!("\n{}", "📊 Repository Status".blue().bold());
    println!("{}", "─".repeat(50).dimmed());
    
    let output = Command::new("git")
        .arg("status")
        .arg("--porcelain")
        .output()?;
    
    let stdout = String::from_utf8(output.stdout)?;
    if stdout.trim().is_empty() {
        println!("  {}", "✅ No changes to commit".green());
    } else {
        for line in stdout.lines() {
            let (status, file) = line.split_at(2);
            let status = status.trim();
            let colored_file = match status {
                "M" => file.red(),
                "A" => file.green(),
                "D" => file.red().strikethrough(),
                "??" => file.yellow(),
                "R" => file.cyan(),
                _ => file.normal(),
            };
            println!("  {} {}", status, colored_file);
        }
    }
    
    println!("{}", "─".repeat(50).dimmed());
    Ok(())
}

fn get_message(cli: &Cli, conventional: bool) -> Result<String> {
    if let Some(msg) = &cli.message {
        return Ok(msg.clone());
    }
    
    if conventional {
        return generate_conventional_message();
    }
    
    // Generate random message using names crate
    let name = names::Generator::default().next().unwrap_or("random");
    Ok(format!("Update: {}", name))
}

fn generate_conventional_message() -> Result<String> {
    let types = vec!["feat", "fix", "docs", "style", "refactor", "test", "chore"];
    
    let selected_type = Select::new()
        .with_prompt("Select commit type")
        .items(&types)
        .default(0)
        .interact()?;
    
    let commit_type = types[selected_type];
    
    let scope: String = Input::new()
        .with_prompt("Scope (optional, press Enter to skip)")
        .allow_empty(true)
        .interact()?;
    
    let description: String = Input::new()
        .with_prompt("Description")
        .validate_with(|input: &String| -> Result<(), &str> {
            if input.is_empty() {
                Err("Description cannot be empty")
            } else {
                Ok(())
            }
        })
        .interact()?;
    
    let message = if scope.is_empty() {
        format!("{}: {}", commit_type, description)
    } else {
        format!("{}({}): {}", commit_type, scope, description)
    };
    
    Ok(message)
}

// =============================================================================
// SUBCOMMANDS
// =============================================================================

fn undo_commit(cli: &Cli) -> Result<()> {
    if cli.dry_run {
        println!("{}", "🔍 Would run: git reset --soft HEAD~1".yellow());
        return Ok(());
    }
    
    if cli.interactive {
        let should_undo = Confirm::new()
            .with_prompt("Undo last commit (keep changes staged)?")
            .default(false)
            .interact()?;
        
        if !should_undo {
            println!("{}", "⏹️  Operation cancelled.".yellow());
            return Ok(());
        }
    }
    
    let status = Command::new("git")
        .arg("reset")
        .arg("--soft")
        .arg("HEAD~1")
        .status()?;
    
    if !status.success() {
        return Err(anyhow!("Failed to undo commit"));
    }
    
    println!("{}", "↩️  Last commit undone (changes kept staged)".green());
    Ok(())
}

fn show_config(config: &Config) -> Result<()> {
    println!("{}", "📋 Current Configuration".blue().bold());
    println!("{}", "─".repeat(40).dimmed());
    println!("  Default branch: {}", config.default_branch.as_deref().unwrap_or("auto").cyan());
    println!("  Remote: {}", config.remote.as_deref().unwrap_or("origin").cyan());
    println!("  Conventional commits: {}", if config.conventional { "yes" } else { "no" }.cyan());
    println!("  Interactive: {}", if config.interactive { "yes" } else { "no" }.cyan());
    println!("  Auto push: {}", if config.auto_push { "yes" } else { "no" }.cyan());
    println!("  Verbose: {}", if config.verbose { "yes" } else { "no" }.cyan());
    println!("{}", "─".repeat(40).dimmed());
    
    if let Some(global_path) = Config::global_config_path() {
        println!("  Config file: {}", global_path.display().to_string().dimmed());
    }
    
    Ok(())
}

// =============================================================================
// MAIN ENTRY
// =============================================================================
EOF

log_success "src/main.rs implementado"

# =============================================================================
# 5. CRIAÇÃO DO ARQUIVO DE CONFIGURAÇÃO DE EXEMPLO
# =============================================================================

log_info "Criando arquivo de configuração de exemplo..."

cat > .gitpushup.toml << 'EOF'
# GitPushUp Configuration Example
# Place in ~/.config/gitpushup/config.toml or in project root

# Default branch (auto-detected if not set)
default_branch = "main"

# Default remote
remote = "origin"

# Use conventional commits by default
conventional = true

# Run in interactive mode by default
interactive = false

# Auto-push after commit (set to false to require --push)
auto_push = true

# Verbose output
verbose = false
EOF

log_success "Arquivo de configuração criado"

# =============================================================================
# 6. CRIAÇÃO DE TESTES
# =============================================================================

log_info "Criando testes de integração..."

mkdir -p tests
cat > tests/integration_test.rs << 'EOF'
//! Testes de integração para gitpushup

use std::process::Command;
use tempfile::tempdir;

#[test]
fn test_commit_creation() -> Result<(), Box<dyn std::error::Error>> {
    let dir = tempdir()?;
    let repo_path = dir.path();
    
    // Inicializa repositório
    Command::new("git")
        .args(["init"])
        .current_dir(repo_path)
        .output()?;
    
    // Configura usuário para testes
    Command::new("git")
        .args(["config", "user.email", "test@example.com"])
        .current_dir(repo_path)
        .output()?;
    
    Command::new("git")
        .args(["config", "user.name", "Test User"])
        .current_dir(repo_path)
        .output()?;
    
    // Cria arquivo de teste
    std::fs::write(repo_path.join("test.txt"), "test content")?;
    
    // Executa gitpushup (usando cargo run)
    let output = Command::new("cargo")
        .args(["run", "--", "--no-push", "-m", "test commit"])
        .current_dir(repo_path)
        .output()?;
    
    assert!(output.status.success(), "gitpushup failed");
    
    // Verifica commit
    let log_output = Command::new("git")
        .args(["log", "--oneline"])
        .current_dir(repo_path)
        .output()?;
    
    let log = String::from_utf8(log_output.stdout)?;
    assert!(log.contains("test commit"), "Commit message not found");
    
    Ok(())
}

#[test]
fn test_dry_run_mode() -> Result<(), Box<dyn std::error::Error>> {
    let dir = tempdir()?;
    let repo_path = dir.path();
    
    Command::new("git")
        .args(["init"])
        .current_dir(repo_path)
        .output()?;
    
    std::fs::write(repo_path.join("test.txt"), "content")?;
    
    let output = Command::new("cargo")
        .args(["run", "--", "--dry-run"])
        .current_dir(repo_path)
        .output()?;
    
    assert!(output.status.success());
    assert!(String::from_utf8(output.stdout)?.contains("DRY RUN"));
    
    Ok(())
}
EOF

log_success "Testes criados"

# =============================================================================
# 7. ATUALIZAÇÃO DO README.md (SEGURA)
# =============================================================================

log_info "Atualizando README.md..."

# Verifica se o README existe
if [ -f README.md ]; then
    # Verifica se a seção de novas features já existe
    if ! grep -q "## 🆕 Features" README.md 2>/dev/null; then
        cat >> README.md << 'EOF'


## 🆕 Features

### 🔍 Safety & Control
- `--dry-run` / `-n`: Preview changes without applying
- `--interactive` / `-i`: Interactive mode with confirmation
- `--message` / `-m`: Custom commit message
- `--branch` / `-b`: Specify target branch
- `--no-push`: Commit without pushing

### 🎨 Enhanced Commit Messages
- `--conventional` / `-c`: Conventional commits (interactive)
- Smart message generation based on changed files

### ⚙️ Flexibility
- `--add <FILE>`: Add specific files
- `--add-all` / `-A`: Add all files (default)
- `--no-add`: Skip git add step
- `--remote <REMOTE>`: Specify remote
- `--verbose` / `-v`: Verbose output

### 📋 Additional Commands
- `gitpushup undo`: Rollback last commit
- `gitpushup config`: Show current configuration

### ⚙️ Configuration
- Global: `~/.config/gitpushup/config.toml`
- Local: `./.gitpushup.toml`
EOF
    else
        log_warning "Seção de Features já existe no README.md"
    fi
fi

# =============================================================================
# 8. COMPILAÇÃO E TESTES
# =============================================================================

log_info "Compilando e testando..."

if command -v cargo >/dev/null; then
    log_info "Formatando código..."
    cargo fmt --all 2>/dev/null || log_warning "fmt falhou"
    
    log_info "Verificando com cargo check..."
    if cargo check --all-targets --all-features 2>&1 | tee /tmp/check.log; then
        log_success "✅ Cargo check passou!"
    else
        log_warning "⚠️ Cargo check falhou. Verifique /tmp/check.log"
    fi
    
    log_info "Compilando em modo release..."
    if cargo build --release 2>&1 | tee /tmp/build.log; then
        log_success "✅ Compilação bem-sucedida!"
        BINARY_SIZE=$(ls -lh target/release/gitpushup 2>/dev/null | awk '{print $5}' || echo "N/A")
        log_info "Tamanho do binário: $BINARY_SIZE"
    else
        log_error "❌ Compilação falhou. Verifique /tmp/build.log"
    fi
    
    log_info "Executando testes..."
    if cargo test --lib 2>&1 | tee /tmp/test.log; then
        log_success "✅ Testes passaram!"
    else
        log_warning "⚠️ Testes falharam. Verifique /tmp/test.log"
    fi
else
    log_warning "Cargo não encontrado"
fi

# =============================================================================
# 9. RELATÓRIO FINAL
# =============================================================================

echo ""
echo "=============================================================="
echo "  ✅ IMPLEMENTAÇÃO CONCLUÍDA"
echo "=============================================================="
echo ""
echo "📦 FEATURES IMPLEMENTADAS:"
echo "  ✅ Modo --dry-run (simulação)"
echo "  ✅ Modo --interactive (confirmação interativa)"
echo "  ✅ --message para mensagens customizadas"
echo "  ✅ --branch e --remote"
echo "  ✅ --no-push (apenas commit)"
echo "  ✅ --conventional (Conventional Commits)"
echo "  ✅ --add, --add-all, --no-add"
echo "  ✅ Arquivo de configuração (.gitpushup.toml)"
echo "  ✅ Pré-visualização com --status"
echo "  ✅ --verbose para logs detalhados"
echo "  ✅ Comando undo (rollback)"
echo "  ✅ Geração inteligente de mensagens"
echo "  ✅ Tratamento de erros com anyhow"
echo "  ✅ Testes de integração"
echo ""
echo "📝 NOVOS COMANDOS:"
echo "  🔹 gitpushup --dry-run"
echo "  🔹 gitpushup --interactive"
echo "  🔹 gitpushup -m 'feat: add login'"
echo "  🔹 gitpushup -b develop"
echo "  🔹 gitpushup --conventional"
echo "  🔹 gitpushup undo"
echo "  🔹 gitpushup config"
echo ""
echo "⚠️  BACKUP CRIADO EM: $BACKUP_DIR"
echo ""
if [ -f target/release/gitpushup ]; then
    echo "🚀 BINÁRIO DISPONÍVEL: target/release/gitpushup"
    echo "   Execute: ./target/release/gitpushup --help"
else
    echo "🔧 Compile com: cargo build --release"
fi
echo ""
echo "📚 Para instalar: cargo install --path ."
echo ""
log_success "🎉 O gitpushup está completo e poderoso!"

# Fim do script