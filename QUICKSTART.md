# Quick Start Guide

Get up and running with AWS Profile Extension in 3 minutes! ⚡

## 1. Install (1 minute)

```bash
# Navigate to the project directory
cd /Users/lmatovic/Work/POC/tools/aws-profile-extension

# Run the complete setup
make setup
```

This will:

- Create a virtual environment
- Install all dependencies
- Configure the AWS CLI plugin
- Add shell integration to your `.bashrc` or `.zshrc`

## 2. Reload Your Shell

```bash
source ~/.bashrc  # For bash
# or
source ~/.zshrc   # For zsh
```

## 3. Start Using It

### List your AWS profiles

```bash
awsp --list
```

### Switch to a profile (with autocomplete!)

```bash
awsp dev  # Press TAB to see all profiles
```

That's it! 🎉

## Usage Examples

### Quick profile switching with auto SSO login

```bash
# Just type the profile name - SSO login happens automatically if needed
awsp production
```

### Check current profile

```bash
aws-current-profile
```

### Clear profile

```bash
aws-clear-profile
```

### Use with AWS commands

```bash
awsp dev
aws s3 ls                    # Uses 'dev' profile
aws ec2 describe-instances   # Still using 'dev' profile
```

## Tab Completion

The best feature! Just type `awsp` and press TAB:

```bash
awsp <TAB>
# Shows all your profiles:
# dev  staging  production  --list  -l
```

## Troubleshooting

### Command not found: awsp

Reload your shell: `source ~/.bashrc` or `source ~/.zshrc`

### Plugin not found

Check `~/.aws/config` has:

```ini
[plugins]
profile = awscli_plugin_profile
```

## What's Next?

Read the full [README.md](README.md) for:

- Advanced configuration
- SSO profile setup
- Troubleshooting tips
- How it works under the hood
