# Cursor AI IDE Installer

Automated installer script for **Cursor AI IDE** on Linux. This script is designed to make installing and updating Cursor safe, reliable, and effortless.

## ✨ Features

- **Automatic Installation**: Download and install Cursor directly from official servers
- **Built-in Updates**: Update to the latest version without reinstalling
- **Multi-option Install**: Auto download, local file scan, or manual path
- **Desktop Integration**: Application shortcuts and file manager integration
- **Command Line**: `cursor` command for terminal usage
- **Installation Verification**: Automatic checks after installation
- **User-friendly**: Clear interface with progress indicators
- **Error Handling**: Robust error handling and safe cleanup

## 🚀 Quick Start

### First Installation

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/andraryandra/Cursor-AI-Ubuntu/main/cursor-installer.sh
   # or
   curl -O https://raw.githubusercontent.com/andraryandra/Cursor-AI-Ubuntu/main/cursor-installer.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x cursor-installer.sh
   ```

3. **Run the installer**:
   ```bash
   ./cursor-installer.sh
   ```

### Updating Cursor

If Cursor is already installed, the script will show a menu:
- **Option 1**: Update to the latest version
- **Option 2**: Reinstall (fresh installation)
- **Option 3**: Exit

## 📋 System Requirements

- **OS**: Ubuntu, Debian, or APT-based Linux distributions
- **Privileges**: Sudo access for system installation
- **Storage**: ~500MB free space
- **Internet**: Stable connection for downloads (optional if you have the file)

## 🛠️ Dependencies

The script will automatically install required dependencies:
- `curl` - for API calls
- `jq` - for JSON parsing
- `wget` - for file downloads
- `file` - for file verification

## 📂 Installation Locations

After installation, Cursor will be installed at:

```
/opt/Cursor/                    # Main application files
/usr/local/bin/cursor           # Command wrapper
/usr/share/applications/        # Desktop entry
```

## 🎯 How to Use Cursor

### 1. From Applications Menu
Look for "Cursor AI IDE" in your applications menu

### 2. From Terminal
```bash
cursor                    # Open Cursor
cursor .                  # Open current directory
cursor /path/to/project   # Open specific directory
cursor file.txt           # Open specific file
```

### 3. From File Manager
Right-click on folders/files → "Open with Cursor"

## 🔧 Download Options

The script provides 3 ways to get Cursor:

### 1. Automatic Download (Recommended)
- Downloads directly from Cursor servers
- Always gets the newest version available
- Size: ~250-300 MB
- Time: 2-10 minutes (depending on internet speed)

### 2. Local File Scan
- Searches for existing Cursor files on your computer
- Auto-scans Downloads, Desktop, Documents folders
- No internet connection required
- Shows file details (size, date, location)

### 3. Manual Path
- Enter file path manually
- For advanced users
- Can use files from external drives or custom locations

## 🔄 Update Process

When running an update:

1. **Installation Detection**: Checks if Cursor is already installed
2. **Settings Preservation**: System settings remain intact
3. **Latest Download**: Gets the newest version from servers
4. **File Replacement**: Replaces old files with new ones
5. **Config Preservation**: Shortcuts and commands continue working

## 🛡️ Security Features

- **No Root Execution**: Script refuses to run as root
- **Sudo On Demand**: Requests sudo only when necessary
- **File Verification**: Validates files before installation
- **Automatic Cleanup**: Removes temporary files automatically
- **Safe Error Handling**: Exits safely if errors occur

## 🐛 Troubleshooting

### "Permission denied" error
```bash
chmod +x cursor-installer.sh
```

### "sudo: command not found" error
Install sudo or run as root (not recommended):
```bash
apt update && apt install sudo
```

### Download fails
- Check internet connection
- Use option 2 (local file scan)
- Manual download from [cursor.sh](https://cursor.sh)

### Cursor doesn't appear in menu
```bash
sudo update-desktop-database
```

### 'cursor' command not found
Restart terminal or:
```bash
source ~/.bashrc
```

### AppImage extraction fails
- Check if the downloaded file is corrupted
- Try downloading again
- Verify you have enough disk space

## 📁 File Structure

```
Script Files:
├── cursor-installer.sh         # Main installer script
└── cursor.png                 # Icon file (optional)

Installation:
├── /opt/Cursor/               # Main application
│   ├── AppRun                 # Executable
│   ├── cursor-icon.png        # Application icon
│   └── ...                    # Other app files
├── /usr/local/bin/cursor      # Command wrapper
└── /usr/share/applications/   # Desktop entry
    └── cursor.desktop
```

## 🔍 Script Functions

### Core Functions
- `main()` - Main entry point and menu system
- `install_dependencies()` - Install required tools
- `get_appimage_path()` - Download method selection
- `process_appimage()` - Extract and process files
- `install_to_system()` - Install to system directories

### Download Functions
- `download_cursor()` - Download from official servers
- `find_local_cursor()` - Scan for local files
- `get_manual_path()` - Manual path input

### Update Functions
- `update_cursor()` - Update process handler
- `get_update_appimage()` - Get file for updates

### System Integration
- `setup_icon()` - Setup application icon
- `create_desktop_entry()` - Create desktop shortcut
- `create_command_wrapper()` - Create terminal command
- `verify_installation()` - Verify installation results

## 📝 Logging and Debug

The script provides detailed output:
- ✅ **SUCCESS**: Operation completed successfully
- ❌ **ERROR**: Issues that need attention
- ⚠️ **WARNING**: Non-critical warnings
- ℹ️ **INFO**: Additional information
- 🔄 **STEP**: Installation progress

## 🚀 Advanced Usage

### Silent Installation
For automated deployments:
```bash
echo "y" | ./cursor-installer.sh
```

### Custom Installation Directory
Modify the script variables:
```bash
CURSOR_EXTRACT_DIR="/custom/path/Cursor"
```

### Skip Dependencies
If dependencies are already installed:
```bash
# Comment out the install_dependencies call in main()
```

## 🤝 Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Development Guidelines
- Follow bash best practices
- Add comments for complex logic
- Test on multiple Linux distributions
- Maintain backward compatibility

## 📊 Compatibility

### Tested Distributions
- ✅ Ubuntu 20.04+
- ✅ Debian 11+
- ✅ Linux Mint 20+
- ✅ Pop!_OS 20.04+
- ✅ Elementary OS 6+

### Architecture Support
- ✅ x86_64 (AMD64)
- ❌ ARM64 (not supported by Cursor)
- ❌ i386 (deprecated)

## 📞 Support

If you encounter issues:
1. Check the Troubleshooting section
2. Open an issue on GitHub
3. Visit [Cursor Documentation](https://cursor.sh/docs)
4. Join the Cursor community forums

## 🔗 Useful Links

- [Cursor Official Website](https://cursor.sh)
- [Cursor Documentation](https://cursor.sh/docs)
- [GitHub Issues](https://github.com/andraryandra/Cursor-AI-Ubuntu/issues)
- [Release Notes](https://cursor.sh/releases)

## 📄 License

This script is available for free use. Cursor AI IDE has its own license from Cursor.sh.

## 🙏 Acknowledgments

- Cursor team for creating an amazing AI-powered IDE
- Linux community for feedback and testing
- Contributors who helped improve this script

---

**Made with ❤️ for the developer community**

*Last updated: August 2025*

## 📈 Changelog

### v2.0.0 (Current)
- ✅ Added update functionality
- ✅ Improved error handling
- ✅ Better user interface
- ✅ Multiple download options

### v1.0.0
- ✅ Initial release
- ✅ Basic installation
- ✅ Desktop integration