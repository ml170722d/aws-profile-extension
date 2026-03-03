# Oh My Zsh Plugin - AWS Profile Switcher

## Quick Installation

If you have Oh My Zsh installed, this is the easiest installation method:

```bash
# Clone into your Oh My Zsh custom plugins directory
git clone https://github.com/ml170722d/aws-profile-extension ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/aws-profile-extension
```

## Plugin Configuration

Add `aws-profile-extension` to your plugins list in `~/.zshrc`:

```bash
plugins=(
    # your existing plugins...
    aws-profile-extension
)
```

Reload your shell:

```bash
source ~/.zshrc
```

## What this plugin provides

- **awsp** command for profile switching with autocomplete
- **aws-current-profile** to show current profile
- **aws-clear-profile** to unset profile
- **ap** and **awsprofile** aliases
- Automatic Python environment management
- Tab completion for all AWS profiles

## Usage

```bash
# List available profiles
awsp --list

# Switch to a profile (with auto SSO login if needed)
awsp my-profile

# Check current profile
aws-current-profile

# Clear profile
aws-clear-profile

# Use short alias
ap my-profile
```

## Requirements

- Python 3.7+
- AWS CLI v2 (for SSO support)
- Git (for installation)

The plugin will automatically create a Python virtual environment and install required dependencies (boto3, botocore) on first use.

## Plugin Structure

- `aws-profile-extension.plugin.zsh` - Main plugin file with shell functions
- `awscli_plugin_profile/` - Python package for profile management
- `setup.py` - Python package configuration
- `requirements.txt` - Python dependencies

## Troubleshooting

If you experience issues:

1. Ensure the plugin is in your plugins list in `~/.zshrc`
2. Reload your shell: `source ~/.zshrc`
3. Check that Python 3 is available: `python3 --version`
4. Verify AWS CLI is installed: `aws --version`

## Features

- ✅ Automatic SSO login when credentials expire
- ✅ Tab completion for profile names
- ✅ Profile validation and status checking
- ✅ Convenient aliases and shortcuts
- ✅ Oh My Zsh integration with load message
- ✅ Isolated Python environment (no conflicts)

## See Also

- Main repository: <https://github.com/ml170722d/aws-profile-extension>
- Standalone installation instructions
- Development setup guide
