#!/usr/bin/env bash

# Strict mode: script stops if a critical error occurs
set -e

# --- GLOBAL VARIABLES ---
PKG_MANAGER=""
UPDATE_CMD=""
SUDO_CMD=""

# --- FUNCTIONS ---

# 0. Check user privileges
check_sudo() {
  # EUID 0 means the script is running as root
  if [ "$EUID" -ne 0 ]; then
    SUDO_CMD="sudo "
  fi
}

# 1. Detect OS (Ubuntu vs Fedora)
detect_os() {
  echo "🔍 Detecting operating system..."
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ "$ID" == "fedora" ]]; then
      PKG_MANAGER="${SUDO_CMD}dnf install -y"
      UPDATE_CMD="${SUDO_CMD}dnf check-update || true"
      echo "✅ Fedora detected. Using DNF."
    elif [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
      PKG_MANAGER="${SUDO_CMD}apt install -y"
      UPDATE_CMD="${SUDO_CMD}apt update -y"
      echo "✅ Ubuntu/Debian detected. Using APT."
    else
      echo "❌ Sorry, this OS is not supported yet."
      exit 1
    fi
  else
    echo "❌ /etc/os-release file not found."
    exit 1
  fi
}

# 2. Modularity Engine (Question Function)
ask() {
  local prompt="$1"
  local default="$2"
  local reply

  if [[ "$default" == "Y" ]]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi

  read -r -p "$prompt" reply

  # Use default value if the user just presses Enter
  if [[ -z "$reply" ]]; then
    reply=$default
  fi

  # Check response
  if [[ "$reply" == [Yy]* ]]; then
    return 0 # True (Agreed)
  else
    return 1 # False (Declined)
  fi
}

# --- MAIN LOGIC ---
echo "🚀 Launching professional environment setup..."

check_sudo
detect_os

echo "📦 Updating package cache before installation..."
eval "$UPDATE_CMD"

# --- MODULE 1: CORE ---
if ask "Install basic developer utilities (git, curl, wget, gcc)?" "Y"; then
  echo "⚙️ Installing Core..."
  $PKG_MANAGER git curl wget gcc
else
  echo "⏭️ Skipping Core utilities installation."
fi

echo "🎉 Basic check completed."

# --- MODULE 2: TERMINAL UX ---

# --- Install Nerd Fonts ---
echo "📦 Preparing system for fonts..."
# Install fontconfig so fc-cache is available
$PKG_MANAGER fontconfig

echo "📦 Installing JetBrainsMono Nerd Font for icons..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Download font
curl -fLo "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" \
    https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf

# Update font cache
echo "🔄 Updating font cache..."
fc-cache -f -v > /dev/null

if ask "Install Terminal UX (Zsh, Starship, fzf, zoxide, eza, yazi, atuin, bat, micro)?" "Y"; then
  echo "🎨 Installing Terminal UX..."

  if [[ "$ID" == "fedora" ]]; then
    $PKG_MANAGER zsh fzf micro unzip gnupg2
    echo "📦 Installing modern utilities from Fedora repositories..."
    $PKG_MANAGER zoxide eza starship atuin yazi bat || echo "⚠️ Some packages may require COPR."
  else
    $PKG_MANAGER zsh fzf micro unzip gnupg
    echo "📦 Installing modern utilities for Ubuntu..."

    # Zoxide and Bat
    $PKG_MANAGER zoxide bat

    # Starship (Silent install)
    if ! command -v starship &>/dev/null; then
      echo "🚀 Installing Starship..."
      curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Atuin (Silent install - direct binary download)
    if ! command -v atuin &>/dev/null; then
      echo "🐢 Installing Atuin..."
      wget -qO atuin.tar.gz "https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz"
      tar -xzf atuin.tar.gz
      $SUDO_CMD mv atuin-*/atuin /usr/local/bin/
      rm -rf atuin.tar.gz atuin-*/
    fi

    # eza (Silent install - direct binary download)
    if ! command -v eza &>/dev/null; then
      echo "📁 Installing eza..."
      wget -qO eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
      tar -xzf eza.tar.gz
      $SUDO_CMD mv eza /usr/local/bin/
      rm -f eza.tar.gz
    fi

    # Yazi (Silent install)
    if ! command -v yazi &>/dev/null; then
      echo "📂 Installing Yazi..."
      wget -qO yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
      unzip -q yazi.zip
      $SUDO_CMD mv yazi-*/yazi yazi-*/ya /usr/local/bin/
      rm -rf yazi.zip yazi-*/
    fi
  fi
else
  echo "⏭️ Skipping Terminal UX."
fi

# --- MODULE 3: CONFIGURATION ---
if ask "Generate startup configs and Survival Guide?" "Y"; then
  echo "🏗️ Assembling work environment..."

  export EDITOR=micro

  # 1. Create Survival Guide
  echo "📖 Writing survival guide..."
  cat <<'EOF' >~/.survival_guide.md
# 🏙️ WELCOME TO MEGAPOLIS

Your terminal is upgraded and ready to work. Forget the fear of the black screen.

## 🆘 FIRST AID (If you forgot a command)
- Type `help <command>` (e.g., `help ls`). This calls **tldr** — a simple cheat sheet with examples, no fluff.
- If a utility hangs or outputs confusing text — press **Ctrl + C** (this kills the process).

## 🚀 MAIN COMMAND REPLACEMENTS
- `ls` or `ll` — Beautiful file list (replaces old ls).
- `tree` — Show folders as a tree.
- `cd <folder>` — Smart navigation. You can type part of the word, it will guess the path!
- `cat <file>` — Read file text with syntax highlighting.
- `micro <file>` — Open a simple and intuitive editor (mouse works!).

## ⌨️ HOTKEYS
- **Ctrl + Shift + V** — Paste text (Normal Ctrl+V doesn't work in terminal!).
- **Ctrl + Shift + C** — Copy text.
- **Ctrl + R** — Search command history (Atuin Magic).
- **Ctrl + T** — Find a file in current folder (fzf Magic).

## ⚠️ CAUTION: F2 Key
If you accidentally press **F2** and the terminal stops typing — don't panic! You likely toggled a "rename" or "lock" mode. Just press **Enter** or **Esc** to exit.

## 🛠️ HOW TO CHANGE SETTINGS?
Your aliases (command shortcuts) are in `~/.aliases`.
Type `micro ~/.aliases`, add your commands, save (**Ctrl+S**), and close (**Ctrl+Q**).

---
*To read this guide again, just type the command `guide`.*
EOF

  # 2. Create Aliases file
  echo "🔗 Setting up aliases..."
  cat <<EOF >~/.aliases
# Basic Overrides
alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -la --icons=always --color=always --group-directories-first'
alias tree='eza --tree --icons=always'
alias cd='z'
alias find='fd'
EOF

  # Handle bat/batcat naming difference
  if [[ "$ID" == "fedora" ]]; then
    echo "alias cat='bat'" >>~/.aliases
  else
    echo "alias cat='batcat'" >>~/.aliases
  fi

  # Remaining aliases
  cat <<'EOF' >>~/.aliases
# Convenient shortcuts
alias c='clear'
alias q='exit'
alias mkdir='mkdir -p'
alias guide='cat ~/.survival_guide.md'

# TLDR cheat sheet
alias help='tldr'
EOF

  # 3. Create clean .zshrc
  echo "📝 Generating .zshrc..."
  cat <<'EOF' >~/.zshrc
export EDITOR=micro

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Show guide on first login
guide
EOF

  # Install tldr
  echo "📚 Installing tldr..."
  $PKG_MANAGER tldr unzip
  mkdir -p ~/.local/share/tldr
  tldr --update || true

  # Change Shell
  echo "🔄 Setting Zsh as default shell..."
  if [ "$EUID" -ne 0 ]; then
    $SUDO_CMD chsh -s $(which zsh) $(whoami)
  else
    chsh -s $(which zsh)
  fi

else
  echo "⏭️ Skipping configuration."
fi

echo -e "\n🎉 \e[1;32mInstallation complete! Restart your terminal or type 'zsh'.\e[0m"
