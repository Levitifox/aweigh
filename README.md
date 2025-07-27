# Aweigh

## Installation

### Recommendations (Using `archinstall`)

* **Disk Format**: ext4
* **Bootloader**: GRUB
* **Audio**: PipeWire (with `pipewire-pulse` and `pipewire-media-session`)
* **Display Server**: X11

#### Additional Packages:

* `git`, `nano`

#### Network Configuration:

* **NetworkManager**

---

### First Run Setup

1. **Install the `yay` AUR helper**

   ```bash
   cd /opt/
   sudo git clone https://aur.archlinux.org/yay-git.git
   sudo chown -R <username>:<username> yay-git/
   cd yay-git/
   makepkg -si
   ```

2. **Update your system**

   ```bash
   yay -Suy
   ```

3. **Clone this repository and run the installer**

   ```bash
   cd /opt/
   sudo git clone https://github.com/Levitifox/aweigh.git
   sudo chown -R <username>:<username> aweigh/
   cd aweigh/
   chmod +x install.sh
   ./install.sh --install-pkgs --install-optional --disable-wifi-powersave --install-bluetooth
   ```

4. **Link your Awesome WM configs**

   ```bash
   cd /opt/aweigh/
   ./install.sh --link-configs
   ```

---

## Useful Commands and Configurations

### Set Up Auto‑login with `~/.bash_profile`

Add the following to your `~/.bash_profile` so that on tty1 you automatically log in and start X:

```bash
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  exec startx
fi
```

### Remove Password Prompt for `sudo` Commands

1. Open the sudoers file for editing:

   ```bash
   sudo visudo
   ```

2. Add the following line at the end (replacing `<username>`):

   ```plaintext
   <username> ALL=(ALL) NOPASSWD: ALL
   ```
