# AWS Profile Extension

A powerful AWS CLI extension for quick profile switching with automatic SSO login and credential validation.

## Features

- 🚀 **Quick Profile Switching**: Switch between AWS profiles with a single command
- 🔐 **Automatic SSO Login**: Automatically logs you in via SSO when credentials are expired
- ✅ **Credential Validation**: Checks if your credentials are valid before attempting login
- 📋 **Profile Listing**: View all available profiles with their status
- ⚡ **Shell Integration**: Includes bash/zsh functions with autocomplete support
- 🎯 **Environment Variables**: Automatically sets AWS_PROFILE for use in other commands

## Installation

### 1. Install the extension

```bash
# Clone or navigate to the project directory
cd /Users/lmatovic/Work/POC/tools/aws-profile-extension

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Install the extension
pip install -e .
```

### 2. Configure AWS CLI to use the plugin

Create or edit `~/.aws/config` and add the plugin configuration:

```ini
[plugins]
profile = awscli_plugin_profile
```

### 3. (Recommended) Add shell integration for better experience

Add the following to your `~/.bashrc` or `~/.zshrc`:

```bash
# Source the AWS profile switcher
source /Users/lmatovic/Work/POC/tools/aws-profile-extension/shell-integration.sh
```

Then reload your shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

### Using the AWS CLI extension

#### Switch to a profile

```bash
aws profile dev
```

This will:

1. Check if the profile exists
2. Validate current credentials
3. If expired and SSO-enabled, automatically run `aws sso login`
4. Export the AWS_PROFILE environment variable (when using shell integration)

#### List all available profiles

```bash
aws profile --list
```

This shows all profiles with indicators:

- `(SSO)` - Profile is configured for SSO
- `✓` - Credentials are valid
- `✗` - Credentials are expired or invalid

### Using the shell helper (recommended)

Once you've sourced `shell-integration.sh`, you can use these commands:

#### Switch profiles with autocomplete

```bash
awsp dev  # Just press TAB to autocomplete profile names!
```

#### List profiles

```bash
awsp --list
# or
awsp -l
```

#### Check current profile

```bash
aws-current-profile
```

#### Clear profile

```bash
aws-clear-profile
```

### Autocomplete

The shell integration includes autocomplete support:

- Type `awsp` and press **TAB** to see all available profiles
- Start typing a profile name and press **TAB** to autocomplete

## How It Works

1. **Profile Validation**: The extension checks if the specified profile exists in your AWS config
2. **Credential Check**: It validates credentials by making a test STS call
3. **Auto SSO Login**: If credentials are expired and the profile uses SSO, it automatically runs `aws sso login`
4. **Environment Setup**: Sets the `AWS_PROFILE` environment variable for immediate use

## Requirements

- Python 3.7+
- AWS CLI 1.29.0+
- boto3 1.28.0+
- Configured AWS profiles in `~/.aws/config` or `~/.aws/credentials`

## Example Workflows

### Quick SSO login and switch

```bash
# Before: Multiple commands needed
export AWS_PROFILE=production
aws sso login --profile production

# After: Single command
awsp production
```

### Check which profiles need login

```bash
awsp --list
# Available AWS profiles:
#   - dev (SSO) ✓
#   - staging (SSO) ✗
#   - production (SSO) ✗
```

### Switch and use immediately

```bash
awsp dev
# ✓ AWS_PROFILE is now set to: dev

aws s3 ls  # Uses the 'dev' profile
```

## Troubleshooting

### Plugin not found

If you get a "plugin not found" error:

1. Ensure the extension is installed: `pip list | grep awscli-plugin-profile`
2. Check that `~/.aws/config` has the `[plugins]` section configured
3. Try running with the full path: `aws --profile dev profile test-profile`

### Autocomplete not working

1. Make sure you've sourced the shell integration script
2. Reload your shell: `source ~/.bashrc` or `source ~/.zshrc`
3. For zsh, ensure `compinit` is called in your `.zshrc`

### SSO login fails

1. Ensure your SSO configuration is correct in `~/.aws/config`
2. Check that you have the required SSO parameters: `sso_start_url`, `sso_region`, `sso_account_id`, `sso_role_name`
3. Try running `aws sso login --profile <profile-name>` manually to debug

## Development

### Setup development environment

```bash
# Create virtual environment
make venv

# Install in editable mode
make install

# Format code
make format

# Clean up
make clean
```

## License

MIT License - feel free to use and modify as needed.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
