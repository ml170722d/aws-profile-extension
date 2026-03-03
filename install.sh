#!/bin/bash

# AWS Profile Switcher - Universal Installer
# Supports Oh My Zsh, standalone installation, and package management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/ml170722d/aws-profile-extension"
PLUGIN_NAME="aws-profile-extension"
INSTALL_DIR="$HOME/.aws-profile-extension"
VENV_DIR="$INSTALL_DIR/venv"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect installation method
detect_installation_method() {
    if [ -n "$ZSH_CUSTOM" ] && [ -d "$ZSH_CUSTOM" ]; then
        echo "oh-my-zsh"
    elif [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh"
    else
        echo "standalone"
    fi
}

# Install Oh My Zsh plugin
install_oh_my_zsh_plugin() {
    log_info "Installing as Oh My Zsh plugin..."

    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"

    # Clone or update repository
    if [ -d "$plugin_dir" ]; then
        log_info "Plugin directory exists, updating..."
        cd "$plugin_dir" && git pull
    else
        log_info "Cloning repository to $plugin_dir"
        git clone "$REPO_URL" "$plugin_dir"
    fi

    # Install Python package in plugin directory
    cd "$plugin_dir"

    # Create virtual environment
    log_info "Creating Python virtual environment..."
    python3 -m venv venv
    source venv/bin/activate

    # Install dependencies
    pip install --upgrade pip boto3 botocore
    pip install -e .

    # Create wrapper script for aws-profile command
    log_info "Creating wrapper script..."
    cat > aws-profile-wrapper.sh << 'EOF'
#!/bin/bash
# AWS Profile Wrapper - activates venv and runs aws-profile
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PLUGIN_DIR/venv/bin/activate"
exec "$PLUGIN_DIR/venv/bin/aws-profile" "$@"
EOF
    chmod +x aws-profile-wrapper.sh

    # Copy and update plugin file (with corrected zsh completion)
    cp oh-my-zsh-plugin/aws-profile-extension.plugin.zsh aws-profile-extension.plugin.zsh

    log_success "Oh My Zsh plugin installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Add '$PLUGIN_NAME' to your plugins list in ~/.zshrc:"
    echo "   plugins=(... $PLUGIN_NAME)"
    echo "2. Reload your shell: source ~/.zshrc"
    echo "3. Test it: awsp --list"
}

# Install standalone version
install_standalone() {
    log_info "Installing standalone version to $INSTALL_DIR"

    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # Clone or update repository
    if [ -d ".git" ]; then
        log_info "Updating existing installation..."
        git pull
    else
        if [ "$(ls -A $INSTALL_DIR)" ]; then
            log_info "Directory not empty, backing up..."
            mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%s)"
            mkdir -p "$INSTALL_DIR"
            cd "$INSTALL_DIR"
        fi
        log_info "Cloning repository..."
        git clone "$REPO_URL" .
    fi

    # Create virtual environment
    log_info "Creating Python virtual environment..."
    python3 -m venv venv
    source venv/bin/activate

    # Install dependencies and package
    log_info "Installing Python dependencies..."
    pip install --upgrade pip boto3 botocore
    pip install -e .

    # Create shell integration file
    log_info "Setting up shell integration..."

    # Determine shell
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
    else
        log_warning "Unknown shell, defaulting to ~/.bashrc"
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
    fi

    # Add to shell RC if not already present
    INTEGRATION_LINE="source $INSTALL_DIR/aws-profile.sh"

    if ! grep -q "aws-profile.sh" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# AWS Profile Switcher" >> "$SHELL_RC"
        echo "$INTEGRATION_LINE" >> "$SHELL_RC"
        log_success "Added shell integration to $SHELL_RC"
    else
        log_info "Shell integration already present in $SHELL_RC"
    fi

    log_success "Standalone installation completed!"
    echo ""
    echo "Next steps:"
    echo "1. Reload your shell: source $SHELL_RC"
    echo "2. Test it: awsp --list"
}

# Uninstall function
uninstall() {
    log_info "Uninstalling AWS Profile Switcher..."

    # Remove Oh My Zsh plugin
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"
    if [ -d "$plugin_dir" ]; then
        rm -rf "$plugin_dir"
        log_success "Oh My Zsh plugin removed"
    fi

    # Remove standalone installation
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        log_success "Standalone installation removed"
    fi

    # Remove shell integration (ask user)
    for rc_file in ~/.zshrc ~/.bashrc; do
        if [ -f "$rc_file" ] && grep -q "aws-profile" "$rc_file"; then
            echo ""
            read -p "Remove shell integration from $rc_file? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Create backup
                cp "$rc_file" "${rc_file}.backup.$(date +%s)"
                # Remove lines containing aws-profile
                grep -v "aws-profile" "$rc_file" > "${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
                log_success "Shell integration removed from $rc_file"
            fi
        fi
    done

    log_success "Uninstallation completed!"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Python
    if ! command_exists python3; then
        log_error "Python 3 is required but not installed"
        exit 1
    fi

    # Check Git
    if ! command_exists git; then
        log_error "Git is required but not installed"
        exit 1
    fi

    # Check AWS CLI
    if ! command_exists aws; then
        log_warning "AWS CLI not found. Please install AWS CLI v2 for SSO support"
        log_info "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    else
        aws_version=$(aws --version 2>&1 | head -n1)
        log_info "Found: $aws_version"
    fi

    # Check for existing installation
    if command_exists aws-profile; then
        log_warning "aws-profile command already exists"
        log_info "This installation will update the existing version"
    fi
}

# Main function
main() {
    echo "🚀 AWS Profile Switcher Installer"
    echo "=================================="
    echo ""

    # Parse arguments
    case "${1:-}" in
        --uninstall)
            uninstall
            exit 0
            ;;
        --oh-my-zsh)
            INSTALL_METHOD="oh-my-zsh"
            ;;
        --standalone)
            INSTALL_METHOD="standalone"
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --oh-my-zsh      Force Oh My Zsh plugin installation"
            echo "  --standalone     Force standalone installation"
            echo "  --uninstall      Remove AWS Profile Switcher"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "Auto-detection will be used if no option is specified."
            exit 0
            ;;
        "")
            INSTALL_METHOD=$(detect_installation_method)
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac

    check_prerequisites

    echo ""
    log_info "Installation method: $INSTALL_METHOD"
    echo ""

    case "$INSTALL_METHOD" in
        oh-my-zsh)
            install_oh_my_zsh_plugin
            ;;
        standalone)
            install_standalone
            ;;
        *)
            log_error "Invalid installation method: $INSTALL_METHOD"
            exit 1
            ;;
    esac

    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "Quick start:"
    echo "  awsp --list              # List profiles"
    echo "  awsp my-profile          # Switch profiles"
    echo "  aws-current-profile      # Show current profile"
    echo ""
}

# Run main function
main "$@"
