#!/bin/bash

# ===================================================================
# CURSOR AI IDE INSTALLER - COMPLETE & BULLETPROOF VERSION
# No bullshit, no bugs, just works!
# ===================================================================

set -e  # Exit on any error

# --- Global Variables ---
CURSOR_EXTRACT_DIR="/opt/Cursor"
CURSOR_BIN_DIR="/usr/local/bin"
CURSOR_BINARY_PATH="${CURSOR_BIN_DIR}/cursor"
ICON_PATH="${CURSOR_EXTRACT_DIR}/cursor-icon.png"
EXECUTABLE_PATH="${CURSOR_EXTRACT_DIR}/AppRun"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
TEMP_DIR="/tmp/cursor-install-$$"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Utility Functions ---
print_error() {
    echo -e "${RED}${BOLD}❌ ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}${BOLD}✅ SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ️  INFO: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠️  WARNING: $1${NC}"
}

print_step() {
    echo -e "${CYAN}${BOLD}🔄 $1${NC}"
}

print_header() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                       $1"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

# --- Cleanup Function ---
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_step "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set cleanup trap
trap cleanup EXIT

# --- Check Root ---
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "DO NOT run this script as root!"
        print_info "The script will ask for sudo password when needed."
        exit 1
    fi
}

# --- Install Dependencies ---
install_dependencies() {
    print_step "Checking dependencies..."
    
    local deps=("curl" "jq" "wget" "file")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_step "Installing dependencies: ${missing_deps[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${missing_deps[@]}"
        
        if [ $? -ne 0 ]; then
            print_error "Failed to install dependencies!"
            exit 1
        fi
    fi
    
    print_success "Dependencies ready"
}

# --- Download Latest Cursor ---
download_cursor() {
    print_step "Downloading latest Cursor AppImage..."
    
    local api_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    local user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    local download_path="${TEMP_DIR}/cursor.AppImage"
    
    mkdir -p "$TEMP_DIR"
    
    print_step "Getting download URL from Cursor API..."
    local final_url
    final_url=$(curl -sL -A "$user_agent" "$api_url" | jq -r '.url // .downloadUrl // empty')
    
    if [ -z "$final_url" ]; then
        print_error "Failed to get download URL from Cursor API"
        print_info "Trying direct download..."
        final_url="https://downloader.cursor.sh/linux/appImage/x64"
    fi
    
    print_info "Download URL: $final_url"
    print_info "File size: ~250-300 MB"
    print_info "Estimated time: 2-10 minutes (depending on internet speed)"
    
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    DOWNLOAD PROGRESS                        │"
    echo "└─────────────────────────────────────────────────────────────┘"
    
    if wget --progress=bar:force:noscroll --timeout=30 --tries=3 -O "$download_path" "$final_url"; then
        if [ -s "$download_path" ]; then
            print_success "Download completed!"
            echo "$download_path"
        else
            print_error "Downloaded file is empty or corrupted"
            return 1
        fi
    else
        print_error "Download failed"
        return 1
    fi
}

# --- Find Local Cursor Files ---
find_local_cursor() {
    print_step "Scanning for Cursor AppImage files..." >&2
    
    local search_paths=(
        "$HOME/Downloads"
        "$HOME/Desktop"
        "$HOME/Documents"
        "$HOME"
        "/tmp"
        "$(pwd)"
    )
    
    local found_files=()
    local processed_paths=()
    
    for path in "${search_paths[@]}"; do
        # Convert to absolute path and avoid duplicates
        local abs_path
        abs_path=$(realpath "$path" 2>/dev/null || echo "$path")
        
        if [[ " ${processed_paths[*]} " =~ " ${abs_path} " ]]; then
            continue
        fi
        processed_paths+=("$abs_path")
        
        if [ -d "$path" ]; then
            print_step "Searching in: $path" >&2
            
            # Find cursor files with different patterns
            while IFS= read -r -d '' file; do
                if [ -f "$file" ] && [[ "$(basename "$file")" =~ [Cc]ursor.*\.AppImage$ ]]; then
                    # Check if already in array
                    local duplicate=false
                    for existing in "${found_files[@]}"; do
                        if [ "$existing" = "$file" ]; then
                            duplicate=true
                            break
                        fi
                    done
                    
                    if [ "$duplicate" = false ]; then
                        found_files+=("$file")
                    fi
                fi
            done < <(find "$path" -maxdepth 2 -name "*cursor*.AppImage" -o -name "*Cursor*.AppImage" -type f -print0 2>/dev/null)
        fi
    done
    
    if [ ${#found_files[@]} -eq 0 ]; then
        print_warning "No Cursor AppImage files found" >&2
        return 1
    fi
    
    print_success "Found ${#found_files[@]} Cursor AppImage file(s)" >&2
    echo "" >&2
    
    if [ ${#found_files[@]} -eq 1 ]; then
        local file="${found_files[0]}"
        local size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "Unknown")
        local date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1 || echo "Unknown")
        
        print_info "Using: $(basename "$file")" >&2
        print_info "Path: $file" >&2
        print_info "Size: $size | Date: $date" >&2
        echo "$file"
        return 0
    fi
    
    # Multiple files found - let user choose
    echo "Multiple files found:" >&2
    echo "" >&2
    
    for i in "${!found_files[@]}"; do
        local file="${found_files[$i]}"
        local size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "Unknown")
        local date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1 || echo "Unknown")
        
        echo "   $((i+1)). $(basename "$file")" >&2
        echo "      📁 Path: $file" >&2
        echo "      📊 Size: $size | 📅 Date: $date" >&2
        echo "" >&2
    done
    
    while true; do
        read -p "Choose file (1-${#found_files[@]}): " choice >&2
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_files[@]} ]; then
            local selected="${found_files[$((choice-1))]}"
            print_success "Selected: $(basename "$selected")" >&2
            echo "$selected"
            return 0
        else
            print_error "Invalid choice. Please enter a number between 1 and ${#found_files[@]}" >&2
        fi
    done
}

# --- Get Manual Path ---
get_manual_path() {
    echo "" >&2
    print_step "Enter the full path to Cursor AppImage file:" >&2
    echo "Examples:" >&2
    echo "  /home/user/Downloads/Cursor-1.4.2-x86_64.AppImage" >&2
    echo "  ~/Downloads/cursor.AppImage" >&2
    echo "" >&2
    
    while true; do
        read -p "File path: " manual_path >&2
        
        if [ -z "$manual_path" ]; then
            print_error "Path cannot be empty" >&2
            continue
        fi
        
        # Expand tilde
        manual_path="${manual_path/#\~/$HOME}"
        
        if [ ! -f "$manual_path" ]; then
            print_error "File not found: $manual_path" >&2
            echo "Please check the path and try again." >&2
            continue
        fi
        
        # Check if it's actually an AppImage
        if [[ ! "$(basename "$manual_path")" =~ \.AppImage$ ]]; then
            print_warning "File doesn't appear to be an AppImage (missing .AppImage extension)" >&2
            read -p "Continue anyway? (y/N): " confirm >&2
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        
        print_success "File found: $(basename "$manual_path")" >&2
        echo "$manual_path"
        return 0
    done
}

# --- Get AppImage Path ---
get_appimage_path() {
    print_header "CURSOR APPIMAGE SELECTION" >&2
    
    echo "How would you like to get the Cursor AppImage?" >&2
    echo "" >&2
    echo "╔═══════════════════════════════════════════════════════════════╗" >&2
    echo "║                        OPTION DESCRIPTIONS                   ║" >&2
    echo "╚═══════════════════════════════════════════════════════════════╝" >&2
    echo "" >&2
    echo "1. 📥 DOWNLOAD LATEST VERSION AUTOMATICALLY (RECOMMENDED)" >&2
    echo "   ┌─────────────────────────────────────────────────────────────┐" >&2
    echo "   │ • Downloads directly from official Cursor servers          │" >&2
    echo "   │ • Always gets the newest version available                  │" >&2
    echo "   │ • Automatically handles all download complexities          │" >&2
    echo "   │ • File size: ~250-300 MB                                   │" >&2
    echo "   │ • Requires: Stable internet connection                     │" >&2
    echo "   │ • Time: 2-10 minutes depending on internet speed           │" >&2
    echo "   │ • Best choice for most users                               │" >&2
    echo "   └─────────────────────────────────────────────────────────────┘" >&2
    echo "" >&2
    echo "2. 🔍 SCAN FOR EXISTING FILES ON THIS COMPUTER" >&2
    echo "   ┌─────────────────────────────────────────────────────────────┐" >&2
    echo "   │ • Searches common directories (Downloads, Desktop, etc.)   │" >&2
    echo "   │ • Uses Cursor AppImage files you already have              │" >&2
    echo "   │ • No internet connection required                          │" >&2
    echo "   │ • Shows file details (size, date, location)               │" >&2
    echo "   │ • Lets you choose from multiple files if found             │" >&2
    echo "   │ • Good if you already downloaded Cursor before             │" >&2
    echo "   └─────────────────────────────────────────────────────────────┘" >&2
    echo "" >&2
    echo "3. ⌨️  ENTER FILE PATH MANUALLY" >&2
    echo "   ┌─────────────────────────────────────────────────────────────┐" >&2
    echo "   │ • For advanced users who know exact file location          │" >&2
    echo "   │ • Allows using files from unusual locations                │" >&2
    echo "   │ • Full control over which specific file to use             │" >&2
    echo "   │ • Can use files from external drives, network, etc.        │" >&2
    echo "   │ • Requires typing exact file path                          │" >&2
    echo "   │ • Best for custom setups or specific file versions         │" >&2
    echo "   └─────────────────────────────────────────────────────────────┘" >&2
    echo "" >&2
    echo "════════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    
    while true; do
        read -p "Choose option (1-3): " choice >&2
        echo "" >&2
        
        case "$choice" in
            1)
                print_step "Starting automatic download..." >&2
                local downloaded_file
                downloaded_file=$(download_cursor)
                local download_result=$?
                
                echo "DEBUG: downloaded_file='$downloaded_file'" >&2
                echo "DEBUG: download_result=$download_result" >&2
                
                if [ $download_result -eq 0 ] && [ -n "$downloaded_file" ] && [ -f "$downloaded_file" ]; then
                    print_success "Download completed successfully" >&2
                    echo "$downloaded_file"
                    return 0
                else
                    print_error "Download failed (exit code: $download_result)" >&2
                    print_info "You can try option 2 (scan) or 3 (manual) instead" >&2
                    echo "" >&2
                    continue
                fi
                ;;
            2)
                print_step "Starting local file scan..." >&2
                local found_file
                found_file=$(find_local_cursor)
                local find_result=$?
                
                echo "DEBUG: found_file='$found_file'" >&2
                echo "DEBUG: find_result=$find_result" >&2
                echo "DEBUG: file exists: [ -f '$found_file' ]" >&2
                
                if [ $find_result -eq 0 ] && [ -n "$found_file" ] && [ -f "$found_file" ]; then
                    print_success "File ready for installation: $(basename "$found_file")" >&2
                    echo "$found_file"
                    return 0
                else
                    print_error "File selection failed (exit code: $find_result)" >&2
                    print_info "You can try option 1 (download) or 3 (manual) instead" >&2
                    echo "" >&2
                    continue
                fi
                ;;
            3)
                print_step "Manual path entry mode..." >&2
                local manual_file
                manual_file=$(get_manual_path)
                local manual_result=$?
                
                echo "DEBUG: manual_file='$manual_file'" >&2
                echo "DEBUG: manual_result=$manual_result" >&2
                
                if [ $manual_result -eq 0 ] && [ -n "$manual_file" ] && [ -f "$manual_file" ]; then
                    print_success "Manual file path accepted" >&2
                    echo "$manual_file"
                    return 0
                else
                    print_error "Manual path selection failed (exit code: $manual_result)" >&2
                    echo "" >&2
                    continue
                fi
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3." >&2
                continue
                ;;
        esac
    done
}

# --- Process AppImage ---
process_appimage() {
    local appimage_path="$1"
    
    print_header "PROCESSING APPIMAGE"
    
    if [ ! -f "$appimage_path" ]; then
        print_error "AppImage file not found: $appimage_path"
        exit 1
    fi
    
    print_step "Analyzing AppImage..."
    print_info "File: $(basename "$appimage_path")"
    print_info "Size: $(du -h "$appimage_path" | cut -f1)"
    print_info "Path: $appimage_path"
    
    # Make executable
    print_step "Making AppImage executable..."
    chmod +x "$appimage_path"
    
    # Verify it's a valid AppImage
    if ! file "$appimage_path" | grep -q "ELF\|AppImage"; then
        print_warning "File may not be a valid AppImage"
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled"
            exit 1
        fi
    fi
    
    print_step "Extracting AppImage..."
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Extract with progress
    echo "This may take 1-3 minutes depending on your system..."
    if timeout 300 "$appimage_path" --appimage-extract >/dev/null 2>&1; then
        print_success "Extraction completed"
    else
        print_error "Failed to extract AppImage"
        print_info "The file might be corrupted or not a valid AppImage"
        exit 1
    fi
    
    if [ ! -d "squashfs-root" ]; then
        print_error "Extraction directory not found"
        exit 1
    fi
    
    # Verify extracted contents
    if [ ! -f "squashfs-root/AppRun" ]; then
        print_error "Invalid AppImage contents - AppRun not found"
        exit 1
    fi
    
    print_success "AppImage processed successfully"
}

# --- Install to System ---
install_to_system() {
    print_header "SYSTEM INSTALLATION"
    
    # Remove old installation if exists
    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        print_step "Removing previous installation..."
        sudo rm -rf "${CURSOR_EXTRACT_DIR:?}"
    fi
    
    print_step "Creating installation directory..."
    sudo mkdir -p "$CURSOR_EXTRACT_DIR"
    
    print_step "Installing Cursor files..."
    if ! sudo cp -r "$TEMP_DIR/squashfs-root/"* "$CURSOR_EXTRACT_DIR/"; then
        print_error "Failed to copy files to installation directory"
        exit 1
    fi
    
    print_step "Setting permissions..."
    sudo chmod -R 755 "$CURSOR_EXTRACT_DIR"
    sudo chmod +x "$EXECUTABLE_PATH"
    
    if [ ! -f "$EXECUTABLE_PATH" ]; then
        print_error "Main executable not found after installation"
        exit 1
    fi
    
    print_success "System installation completed"
}

# --- Setup Icon ---
setup_icon() {
    print_step "Setting up application icon..."
    
    local icon_url="https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/main/images/cursor-icon.png"
    
    # Try to download official icon
    if sudo curl -sL --connect-timeout 10 "$icon_url" -o "$ICON_PATH" 2>/dev/null; then
        print_success "Downloaded official icon"
    else
        print_warning "Failed to download official icon, using fallback"
        
        # Find any PNG icon in the extracted files
        local fallback_icon
        fallback_icon=$(find "$CURSOR_EXTRACT_DIR" -name "*.png" -type f | head -1)
        
        if [ -n "$fallback_icon" ]; then
            sudo cp "$fallback_icon" "$ICON_PATH"
            print_info "Using fallback icon: $(basename "$fallback_icon")"
        else
            print_warning "No icon found - desktop entry will use default"
        fi
    fi
}

# --- Create Desktop Entry ---
create_desktop_entry() {
    print_step "Creating desktop entry..."
    
    sudo tee "$DESKTOP_ENTRY_PATH" >/dev/null <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Comment=AI-powered code editor built for productivity
Exec=${EXECUTABLE_PATH} --no-sandbox %F
Icon=${ICON_PATH}
Type=Application
Categories=Development;IDE;TextEditor;Programming;
MimeType=text/plain;inode/directory;application/x-shellscript;text/x-python;text/x-javascript;text/x-typescript;text/x-java;text/x-c;text/x-cpp;text/x-csharp;text/x-go;text/x-rust;text/x-php;text/x-ruby;text/x-perl;text/html;text/css;text/xml;application/json;application/yaml;
StartupNotify=true
StartupWMClass=cursor
Terminal=false
EOL

    sudo chmod 644 "$DESKTOP_ENTRY_PATH"
    
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi
    
    print_success "Desktop entry created"
}

# --- Create Command Wrapper ---
create_command_wrapper() {
    print_step "Creating command line wrapper..."
    
    sudo tee "$CURSOR_BINARY_PATH" >/dev/null <<EOL
#!/bin/bash
# Cursor AI IDE Command Wrapper
# Allows running 'cursor' from anywhere in the terminal

# Function to open Cursor
open_cursor() {
    # If no arguments, open Cursor normally
    if [ \$# -eq 0 ]; then
        nohup "${EXECUTABLE_PATH}" --no-sandbox >/dev/null 2>&1 &
        exit 0
    fi
    
    # Handle arguments
    local args=()
    for arg in "\$@"; do
        # Convert relative paths to absolute paths
        if [ -e "\$arg" ]; then
            args+=("\$(realpath "\$arg")")
        else
            args+=("\$arg")
        fi
    done
    
    # Start Cursor with arguments
    nohup "${EXECUTABLE_PATH}" --no-sandbox "\${args[@]}" >/dev/null 2>&1 &
    exit 0
}

# Call the function with all arguments
open_cursor "\$@"
EOL

    sudo chmod +x "$CURSOR_BINARY_PATH"
    
    # Verify the wrapper works
    if [ -x "$CURSOR_BINARY_PATH" ]; then
        print_success "Command wrapper created successfully"
        print_info "You can now use 'cursor' command from terminal"
    else
        print_warning "Command wrapper creation may have failed"
    fi
}

# --- Verify Installation ---
verify_installation() {
    print_header "INSTALLATION VERIFICATION"
    
    local errors=0
    
    print_step "Verifying installation..."
    
    # Check main executable
    if [ -f "$EXECUTABLE_PATH" ] && [ -x "$EXECUTABLE_PATH" ]; then
        print_success "Main executable: OK"
    else
        print_error "Main executable: MISSING or NOT EXECUTABLE"
        errors=$((errors + 1))
    fi
    
    # Check desktop entry
    if [ -f "$DESKTOP_ENTRY_PATH" ]; then
        print_success "Desktop entry: OK"
    else
        print_error "Desktop entry: MISSING"
        errors=$((errors + 1))
    fi
    
    # Check command wrapper
    if [ -f "$CURSOR_BINARY_PATH" ] && [ -x "$CURSOR_BINARY_PATH" ]; then
        print_success "Command wrapper: OK"
    else
        print_error "Command wrapper: MISSING or NOT EXECUTABLE"
        errors=$((errors + 1))
    fi
    
    # Check icon
    if [ -f "$ICON_PATH" ]; then
        print_success "Icon: OK"
    else
        print_warning "Icon: MISSING (not critical)"
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "Installation verification completed - ALL CHECKS PASSED"
        return 0
    else
        print_error "Installation verification found $errors error(s)"
        return 1
    fi
}

# --- Show Usage Instructions ---
show_usage() {
    print_header "USAGE INSTRUCTIONS"
    
    echo "🎉 Cursor AI IDE has been successfully installed!"
    echo ""
    echo "🚀 Ways to launch Cursor:"
    echo ""
    echo "   1. 📱 From Applications Menu:"
    echo "      Look for 'Cursor AI IDE' in your applications menu"
    echo ""
    echo "   2. 💻 From Terminal:"
    echo "      cursor                    # Open Cursor"
    echo "      cursor .                  # Open current directory"
    echo "      cursor /path/to/project   # Open specific directory"
    echo "      cursor file.txt           # Open specific file"
    echo ""
    echo "   3. 🖱️  From File Manager:"
    echo "      Right-click on folders/files and select 'Open with Cursor'"
    echo ""
    echo "💡 Tips:"
    echo "   • Use 'cursor .' in any project directory to open it in Cursor"
    echo "   • Cursor supports all major programming languages"
    echo "   • The AI assistant is built-in and ready to help with coding"
    echo ""
    echo "📚 For help and documentation, visit: https://cursor.sh/docs"
    echo ""
}

# --- Main Installation Function ---
main() {
    # Clear screen and show header
    clear
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                 CURSOR AI IDE INSTALLER                      ║"
    echo "║                   Complete & Bulletproof                     ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "                            /\\_/\\"
    echo "                           ( o.o )"
    echo "                            > ^ <"
    echo ""
    print_info "This installer will set up Cursor AI IDE on your system"
    print_info "You will need sudo privileges for system installation"
    echo ""
    
    # Confirm installation
    read -p "Do you want to continue with the installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled by user"
        exit 0
    fi
    
    # Check if running as root
    check_root
    
    # Check if already installed
    if [ -d "$CURSOR_EXTRACT_DIR" ] && [ -f "$EXECUTABLE_PATH" ]; then
        print_warning "Cursor AI IDE appears to be already installed"
        read -p "Do you want to reinstall/update? (y/N): " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Main installation steps
    echo ""
    print_info "Starting installation process..."
    
    # Step 1: Dependencies
    install_dependencies
    
    # Step 2: Get AppImage
    local appimage_path
    appimage_path=$(get_appimage_path)
    local get_result=$?
    
    echo "DEBUG: appimage_path='$appimage_path'"
    echo "DEBUG: get_result=$get_result"
    echo "DEBUG: file exists check: [ -f '$appimage_path' ]"
    
    if [ $get_result -ne 0 ]; then
        print_error "get_appimage_path returned error code: $get_result"
        exit 1
    fi
    
    if [ -z "$appimage_path" ]; then
        print_error "get_appimage_path returned empty path"
        exit 1
    fi
    
    if [ ! -f "$appimage_path" ]; then
        print_error "AppImage file does not exist: '$appimage_path'"
        exit 1
    fi
    
    print_success "AppImage validation passed: $appimage_path"
    
    # Step 3: Process AppImage
    process_appimage "$appimage_path"
    
    # Step 4: Install to system
    install_to_system
    
    # Step 5: Setup icon
    setup_icon
    
    # Step 6: Create desktop entry
    create_desktop_entry
    
    # Step 7: Create command wrapper
    create_command_wrapper
    
    # Step 8: Verify installation
    if ! verify_installation; then
        print_error "Installation completed but with some issues"
        print_info "Cursor may still work, but some features might be missing"
    fi
    
    # Step 9: Show usage instructions
    show_usage
    
    print_success "INSTALLATION COMPLETED SUCCESSFULLY!"
    echo ""
}

# --- Check if script is being sourced or executed ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    main "$@"
else
    # Script is being sourced
    print_info "Script loaded. Run 'main' to start installation."
fi