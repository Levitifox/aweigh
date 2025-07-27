#!/usr/bin/env bash
set -euo pipefail

# Default profile: Awesome WM on X11
WM="awesome"

# Flags
INSTALL_PKGS=false
INSTALL_OPTIONAL=false
LINK_CONFIGS=false
DISABLE_WIFI=false
INSTALL_BT=false

# Parse command‑line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --install-pkgs)
      INSTALL_PKGS=true
      shift
      ;;
    --install-optional)
      INSTALL_OPTIONAL=true
      shift
      ;;
    --link-configs)
      LINK_CONFIGS=true
      shift
      ;;
    --disable-wifi-powersave)
      DISABLE_WIFI=true
      shift
      ;;
    --install-bluetooth)
      INSTALL_BT=true
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 [options]

Options:
  --install-pkgs             Install the core package set
  --install-optional         Install additional optional applications
  --link-configs             Symlink Awesome WM configs from this repo
  --disable-wifi-powersave   Disable WiFi power‑save mode
  --install-bluetooth        Enable & start Bluetooth service
  -h, --help                 Show this help message
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Detect package manager
if command -v yay &>/dev/null; then
  PM="yay -S --noconfirm --needed"
else
  PM="sudo pacman -S --noconfirm --needed"
fi

# install_group <group‑name> <pkg1> <pkg2> …
install_group() {
  local group_name="$1"; shift
  echo -e "\n>>> Installing group: $group_name"
  $PM "$@"
}

# 1) Disable WiFi power‑save (optional)
if [[ "$DISABLE_WIFI" == true ]]; then
  echo "Disabling WiFi power‑save mode..."
  sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<EOF
[connection]
wifi.powersave = 2
EOF
  sudo systemctl restart NetworkManager
fi

# 2) Install core packages
if [[ "$INSTALL_PKGS" == true ]]; then
  install_group "X11 & Awesome WM" \
    xorg-server xorg-xinit xorg-xinput \
    awesome awesome-extra

  install_group "Compositor & Effects" \
    picom

  install_group "Launcher" \
    rofi

  install_group "Audio" \
    pipewire pipewire-pulse wireplumber \
    pavucontrol alsa-utils pamixer

  install_group "Fonts" \
    ttf-vista-fonts ttf-croscore \
    noto-fonts-emoji ttf-jetbrains-mono-nerd

  install_group "File Manager" \
    thunar thunar-archive-plugin file-roller

  install_group "Terminal & Shell" \
    kitty zsh starship

  install_group "Screenshots" \
    grim slurp

  install_group "Notifications" \
    dunst

  install_group "Power Management" \
    xfce4-power-manager brightnessctl

  install_group "Utilities" \
    neofetch btop git base-devel blueman \
    xdg-desktop-portal xdg-desktop-portal-gtk wl-clipboard
fi

# 3) Install optional applications
if [[ "$INSTALL_OPTIONAL" == true ]]; then
  install_group "Optional (browsers, office, games…)" \
    firefox google-chrome \
    libreoffice-fresh zathura-pdf-poppler \
    vlc mpv obs-studio \
    steam lutris wine winetricks \
    telegram-desktop discord \
    visual-studio-code-bin neovim docker docker-compose \
    virtualbox virt-manager \
    openvpn networkmanager-openvpn wireguard-tools syncthing \
    p7zip unzip unrar \
    conky bpytop \
    tlp thermald \
    copyq obsidian
fi

# 4) Enable & start Bluetooth service (optional)
if [[ "$INSTALL_BT" == true ]]; then
  echo "Enabling and starting Bluetooth service..."
  sudo systemctl enable --now bluetooth
fi

# 5) Symlink configs (optional)
if [[ "$LINK_CONFIGS" == true ]]; then
  echo "Creating symlinks for Awesome WM configs..."
  mkdir -p ~/.config/awesome
  ln -sf "$(pwd)/configs/awesome/rc.lua"    ~/.config/awesome/rc.lua
  ln -sf "$(pwd)/configs/awesome/themes"   ~/.config/awesome/themes
  # add more symlinks here as needed
fi

echo -e "\n Installation script completed!"

cat <<'EOF'

To enable auto‑login on tty1 and start X automatically,
add the following to your ~/.bash_profile:

  if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec startx
  fi

EOF
