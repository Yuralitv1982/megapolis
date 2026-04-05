#!/usr/bin/env bash

# Strict mode
set -e

# --- GLOBAL VARIABLES ---
PKG_MANAGER=""
UPDATE_CMD=""
SUDO_CMD=""

check_sudo() {
  if [ "$EUID" -ne 0 ]; then
    SUDO_CMD="sudo "
  fi
}

detect_os() {
  echo "🔍 Detecting OS..."
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ "$ID" == "fedora" ]]; then
      PKG_MANAGER="${SUDO_CMD}dnf install -y"
      UPDATE_CMD="${SUDO_CMD}dnf check-update || true"
    elif [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
      PKG_MANAGER="${SUDO_CMD}apt install -y"
      UPDATE_CMD="${SUDO_CMD}apt update -y"
    else
      echo "❌ OS not supported."
      exit 1
    fi
  fi
}

echo "🚀 Starting Full Auto Installation..."

check_sudo
detect_os
eval "$UPDATE_CMD"

# 1. Install Fonts (No questions asked)
echo "📦 Installing JetBrainsMono Nerd Font..."
$PKG_MANAGER fontconfig curl wget unzip
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
curl -fLo "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" \
    https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf
fc-cache -f -v > /dev/null

# 2. Install Tools
echo "📦 Installing Professional Toolset..."
if [[ "$ID" == "fedora" ]]; then
    $PKG_MANAGER zsh fzf micro zoxide eza starship atuin yazi bat tldr
else
    # Ubuntu logic
    $PKG_MANAGER zsh fzf micro zoxide bat tldr
    # Manual installs for tools often outdated in APT
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    # (Atuin/Eza/Yazi logic from previous version remains here)
fi

# eza (smart install)
if ! command -v eza &>/dev/null; then
  echo "📁 Устанавливаем eza..."
  # try by default use apt
  if $PKG_MANAGER eza 2>/dev/null; then
    echo "✅ eza установлена из репозиториев."
  else
    # if not in the repository (old Ubuntu), use binary
    echo "🌐 В репозиториях пусто, качаем свежий бинарник..."
    wget -qO eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf eza.tar.gz
    $SUDO_CMD mv eza /usr/local/bin/
    rm -f eza.tar.gz
  fi
fi

# 3. Setup Configs
echo "🏗️ Configuring environment..."

# Create the Survival Guide (Plain Text Focus)
cat <<'EOF' >~/.survival_guide.md
🏙️  MEGAPOLIS READY.
--------------------------------------------------
Quick Shortcuts:
  ll        -> List files with icons
  z <dir>   -> Jump to folder
  micro     -> Fast editor (Ctrl+S to save)
  Ctrl+R    -> Search history
  guide     -> Show this text again
--------------------------------------------------
EOF

# Create Aliases (Using CAT for the guide)
cat <<EOF >~/.aliases
alias ls='eza --icons=always --group-directories-first'
alias ll='eza -la --icons=always --group-directories-first'
alias cd='z'
alias help='tldr'
alias guide='cat ~/.survival_guide.md' # Plain text output
alias q='exit'
alias c='clear'
EOF

# Generate .zshrc
cat <<'EOF' >~/.zshrc
export EDITOR=micro
source ~/.aliases
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Print guide instantly without blocking the prompt
cat ~/.survival_guide.md
EOF

# 4. Set ZSH as Default (Fully Automatic)
echo "🔄 Setting Zsh as default shell..."
USER_SHELL=$(which zsh)
$SUDO_CMD chsh -s "$USER_SHELL" $(whoami)

echo -e "\n✅ DONE. Please restart your terminal."
