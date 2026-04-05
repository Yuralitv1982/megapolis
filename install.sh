#!/usr/bin/env bash

# Строгий режим: скрипт остановится, если где-то произойдет критическая ошибка
set -e

# --- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ---
PKG_MANAGER=""
UPDATE_CMD=""
SUDO_CMD=""

# --- ФУНКЦИИ ---

# 0. Проверка привилегий пользователя
check_sudo() {
  # EUID 0 означает, что скрипт запущен от root
  if [ "$EUID" -ne 0 ]; then
    SUDO_CMD="sudo "
  fi
}

# 1. Определение системы (Ubuntu vs Fedora)
detect_os() {
  echo "🔍 Определяем операционную систему..."
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ "$ID" == "fedora" ]]; then
      PKG_MANAGER="${SUDO_CMD}dnf install -y"
      UPDATE_CMD="${SUDO_CMD}dnf check-update || true"
      echo "✅ Найдена Fedora. Используем DNF."
    elif [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
      PKG_MANAGER="${SUDO_CMD}apt install -y"
      UPDATE_CMD="${SUDO_CMD}apt update -y"
      echo "✅ Найдена Ubuntu/Debian. Используем APT."
    else
      echo "❌ Извини, эта ОС пока не поддерживается."
      exit 1
    fi
  else
    echo "❌ Файл /etc/os-release не найден."
    exit 1
  fi
}

# 2. Движок модульности (Функция вопросов)
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

  # Если пользователь просто нажал Enter, используем значение по умолчанию
  if [[ -z "$reply" ]]; then
    reply=$default
  fi

  # Проверяем ответ
  if [[ "$reply" == [Yy]* ]]; then
    return 0 # True (согласие)
  else
    return 1 # False (отказ)
  fi
}

# --- ОСНОВНАЯ ЛОГИКА ---
echo "🚀 Запуск установки профессионального рабочего окружения..."

check_sudo
detect_os

echo "📦 Обновляем кэш пакетов перед установкой..."
eval "$UPDATE_CMD"

# --- МОДУЛЬ 1: CORE ---
if ask "Установить базовые утилиты разработчика (git, curl, wget, gcc)?" "Y"; then
  echo "⚙️ Устанавливаем Core..."
  $PKG_MANAGER git curl wget gcc
else
  echo "⏭️ Пропускаем установку Core-утилит."
fi

echo "🎉 Базовая проверка завершена."


# --- МОДУЛЬ 2: TERMINAL UX ---

# --- Install Nerd Fonts ---
echo "📦 Installing JetBrainsMono Nerd Font for icons..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Скачиваем только нужный начертание (Regular), чтобы не тянуть 500Мб архивов
curl -fLo "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" \
    https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf

# Обновляем кэш шрифтов в системе
fc-cache -f -v > /dev/null
echo "✅ Font installed. Remember to select 'JetBrainsMono Nerd Font' in your terminal settings!"

if ask "Установить Terminal UX (Zsh, Starship, fzf, zoxide, eza, yazi, atuin, bat, micro)?" "Y"; then
  echo "🎨 Устанавливаем Terminal UX..."

  if [[ "$ID" == "fedora" ]]; then
    # Для Fedora свои названия пакетов (gnupg2)
    $PKG_MANAGER zsh fzf micro unzip gnupg2
    echo "📦 Установка современных утилит из репозиториев Fedora..."
    $PKG_MANAGER zoxide eza starship atuin yazi bat || echo "⚠️ Часть пакетов может потребовать COPR."
  else
    # Для Ubuntu добавляем gnupg и unzip в базовую установку
    $PKG_MANAGER zsh fzf micro unzip gnupg
    echo "📦 Установка современных утилит для Ubuntu..."

    # Zoxide и Bat
    $PKG_MANAGER zoxide bat

    # Starship (Тихая установка)
    if ! command -v starship &>/dev/null; then
      echo "🚀 Устанавливаем Starship..."
      curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Atuin (ТИХАЯ УСТАНОВКА - качаем бинарник напрямую)
    if ! command -v atuin &>/dev/null; then
      echo "🐢 Устанавливаем Atuin (тихий режим)..."
      wget -qO atuin.tar.gz "https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz"
      tar -xzf atuin.tar.gz
      $SUDO_CMD mv atuin-*/atuin /usr/local/bin/
      rm -rf atuin.tar.gz atuin-*/
    fi
    # eza (ТИХАЯ УСТАНОВКА бинарника с GitHub)
    if ! command -v eza &>/dev/null; then
      echo "📁 Устанавливаем eza (тихий режим)..."
      wget -qO eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
      tar -xzf eza.tar.gz
      $SUDO_CMD mv eza /usr/local/bin/
      rm -f eza.tar.gz
    fi

    # Yazi (ТИХАЯ УСТАНОВКА бинарника)
    if ! command -v yazi &>/dev/null; then
      echo "📂 Устанавливаем Yazi..."
      wget -qO yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
      unzip -q yazi.zip
      $SUDO_CMD mv yazi-*/yazi yazi-*/ya /usr/local/bin/
      rm -rf yazi.zip yazi-*/
    fi
  fi
else
  echo "⏭️ Пропускаем Terminal UX."
fi
# --- МОДУЛЬ 3: КОНФИГУРАЦИЯ (СБОРКА МЕГАПОЛИСА) ---
if ask "Сгенерировать стартовые конфиги и Курс выживания?" "Y"; then
  echo "🏗️ Собираем рабочее окружение..."

  export EDITOR=micro

  # 1. Создаем Руководство по выживанию
  echo "📖 Пишем книгу выживания..."
  cat <<'EOF' >~/.survival_guide.md
# 🏙️ ДОБРО ПОЖАЛОВАТЬ В МЕГАПОЛИС

Твой терминал прокачан и готов к работе. Забудь про страх черного экрана.

## 🆘 ПЕРВАЯ ПОМОЩЬ (Если забыл команду)
- Введи `help <команда>` (например, `help ls`). Это вызовет **tldr** — простую шпаргалку с примерами, без лишней воды.
- Если утилита зависла или вывела кучу непонятного текста — жми **Ctrl + C** (это прервет процесс).

## 🚀 ГЛАВНЫЕ КОМАНДЫ-ЗАМЕНИТЕЛИ
- `ls` или `ll` — Красивый список файлов (заменяет старый ls).
- `tree` — Показать папки в виде дерева.
- `cd <папка>` — Умная навигация. Можно писать часть слова, он сам угадает путь!
- `cat <файл>` — Читать текст файла с подсветкой синтаксиса.
- `micro <файл>` — Открыть простой и понятный редактор (работает мышка!).

## ⌨️ ГОРЯЧИЕ КЛАВИШИ
- **Ctrl + Shift + V** — Вставить текст (В терминале просто Ctrl+V не работает!).
- **Ctrl + Shift + C** — Скопировать текст.
- **Ctrl + R** — Поиск по истории команд (Магия Atuin).
- **Ctrl + T** — Найти файл в текущей папке (Магия fzf).

## ⚠️ ОСТОРОЖНО: Кнопка F2
Если ты случайно нажал **F2** (особенно в Zellij или других мультиплексорах) и терминал перестал печатать буквы — не паникуй! Скорее всего, ты включил режим "переименования окна" или "блокировки". Просто нажми **Enter** или **Esc**, чтобы выйти из этого режима.

## 🛠️ КАК ИЗМЕНИТЬ НАСТРОЙКИ?
Твои алиасы (сокращения команд) лежат в файле `~/.aliases`. 
Введи `micro ~/.aliases`, добавь свои команды, сохрани (**Ctrl+S**) и закрой (**Ctrl+Q**).

---
*Чтобы снова прочитать эту шпаргалку, просто введи команду `guide`.*
EOF

  # 2. Создаем файл алиасов (учитываем разницу Ubuntu и Fedora для bat)
  echo "🔗 Прописываем алиасы..."
  cat <<EOF >~/.aliases
# Базовые перехваты
alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -la --icons=always --color=always --group-directories-first'
alias tree='eza --tree --icons=always'
alias cd='z'
alias find='fd'
EOF

  # Дописываем специфичный алиас для bat
  if [[ "$ID" == "fedora" ]]; then
    echo "alias cat='bat'" >>~/.aliases
  else
    echo "alias cat='batcat'" >>~/.aliases
  fi

  # Дописываем остальные алиасы
  cat <<'EOF' >>~/.aliases
# Удобные сокращения
alias c='clear'
alias q='exit'
alias mkdir='mkdir -p'
alias guide='cat ~/.survival_guide.md'

# Шпаргалка tldr
alias help='tldr'
EOF

  # 3. Создаем чистый .zshrc
  echo "📝 Генерируем .zshrc..."
  cat <<'EOF' >~/.zshrc
export EDITOR=micro

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Выводим руководство при первом входе (можно закомментировать позже)
guide
EOF

  # Устанавливаем tldr
  echo "📚 Устанавливаем tldr-шпаргалку..."
  $PKG_MANAGER tldr unzip
  mkdir -p ~/.local/share/tldr
  tldr --update || true

  # Меняем оболочку
  echo "🔄 Назначаем Zsh оболочкой по умолчанию..."
  if [ "$EUID" -ne 0 ]; then
    $SUDO_CMD chsh -s $(which zsh) $(whoami)
  else
    chsh -s $(which zsh)
  fi

else
  echo "⏭️ Пропускаем конфигурацию."
fi

echo -e "\n🎉 \e[1;32mУстановка завершена! Перезайди в терминал или напиши 'zsh'.\e[0m"
