# 🧠 Cursor AI IDE Installer (Linux Bash Script)

A complete, bulletproof, no-nonsense installer for the [Cursor AI IDE](https://www.cursor.sh/) on Linux.  
This script ensures the smoothest installation possible — whether you’re downloading, scanning, or manually specifying the AppImage.

---

## 🚀 Features

- Automatically **downloads the latest AppImage** from Cursor's API
- Optionally **scan local directories** for existing AppImages
- Supports **manual path input** for custom setups
- Handles:
  - File validation
  - AppImage extraction
  - System-wide installation
  - Desktop integration (`.desktop` file)
  - Command-line access (`cursor`)
- Robust user prompts and colorful output for a premium terminal experience
- Cleans up after itself like a good Linux citizen 🧼

---

## 🧰 Requirements

The script will **automatically install** these if missing:

- `curl`
- `jq`
- `wget`
- `file`

It also uses:

- `realpath`
- `chmod`
- `sudo`
- `find`
- `stat`
- `du`
- `tee`
- `nohup`
- `timeout`

---

## 📦 Installation Instructions

### 1. Clone or Download the Script

```bash
git clone https://github.com/your-username/cursor-linux-installer.git
cd cursor-linux-installer
chmod +x install-cursor.sh
```

> Or download the raw file directly:
>
> ```bash
> wget https://raw.githubusercontent.com/your-username/cursor-linux-installer/main/install-cursor.sh
> chmod +x install-cursor.sh
> ```

---

### 2. Run the Installer

```bash
./install-cursor.sh
```

You'll be guided through options:

- 📥 Auto-download the latest version
- 🔍 Scan for existing AppImage files
- ⌨️ Manually enter a file path

---

## 🖥️ Usage

After installation, you can launch Cursor:

### From terminal:

```bash
cursor              # Opens Cursor
cursor .            # Opens current directory
cursor /path/to     # Opens specific folder
cursor file.txt     # Opens specific file
```

### From Applications Menu:

> Look for **“Cursor AI IDE”**

---

## 🔧 Uninstall

```bash
sudo rm -rf /opt/Cursor
sudo rm /usr/local/bin/cursor
sudo rm /usr/share/applications/cursor.desktop
```

---

## 🔍 Debugging

During execution, debug info is printed using:

```bash
echo "DEBUG: ..."
```

If anything goes wrong, just re-run the installer. It safely cleans up and allows you to reinstall/update.

---

## 📄 License

MIT License — do whatever you want, but don’t blame me if you run this on a toaster.

---

## ❤️ Acknowledgements

- [Cursor](https://cursor.sh)
- [AppImage Project](https://appimage.org/)
- ASCII Cat: `/\_/\ ( o.o ) > ^ <`

---

## 💬 Feedback

Contributions and suggestions welcome!  
Feel free to open an issue or PR.
