#!/bin/bash

# Test script for AWS Profile Switcher
# Run this to verify your installation is working correctly

set -e

echo "🧪 Testing AWS Profile Switcher Installation"
echo "============================================="
echo ""

# Test 1: Check Python dependencies
echo "1️⃣ Testing Python environment..."
python3 -c "
import sys
try:
    import boto3
    import botocore
    print('✅ boto3 and botocore available')
except ImportError as e:
    print(f'❌ Missing Python dependency: {e}')
    sys.exit(1)
"

# Test 2: Check aws-profile command
echo "2️⃣ Testing aws-profile command..."
if command -v aws-profile >/dev/null 2>&1; then
    echo "✅ aws-profile command available"
    if aws-profile --list >/dev/null 2>&1; then
        echo "✅ aws-profile --list works"
    else
        echo "⚠️  aws-profile --list failed (may be normal if no AWS config)"
    fi
else
    echo "❌ aws-profile command not found"
    echo "   Make sure you've installed the package and activated the virtual environment"
fi

# Test 3: Check shell integration
echo "3️⃣ Testing shell integration..."
if declare -f awsp >/dev/null 2>&1; then
    echo "✅ awsp function available"
    echo "✅ Shell integration loaded"
else
    echo "❌ awsp function not found"
    echo "   Make sure you've sourced the shell integration:"
    echo "   source ./aws-profile.sh"
fi

# Test 4: Check autocomplete
echo "4️⃣ Testing autocomplete..."
if declare -f _awsp_complete >/dev/null 2>&1; then
    echo "✅ Autocomplete function available"
else
    echo "⚠️  Autocomplete function not found"
    echo "   This is normal if shell integration isn't loaded"
fi

# Test 5: Check AWS CLI
echo "5️⃣ Testing AWS CLI..."
if command -v aws >/dev/null 2>&1; then
    aws_version=$(aws --version 2>&1 | head -n1)
    echo "✅ AWS CLI found: $aws_version"

    if [[ $aws_version == *"aws-cli/2"* ]]; then
        echo "✅ AWS CLI v2 detected (recommended for SSO)"
    else
        echo "⚠️  AWS CLI v1 detected - consider upgrading to v2 for better SSO support"
    fi
else
    echo "❌ AWS CLI not found"
    echo "   Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi

# Test 6: Check AWS configuration
echo "6️⃣ Testing AWS configuration..."
if [ -f ~/.aws/config ] || [ -f ~/.aws/credentials ]; then
    if [ -f ~/.aws/config ]; then
        profile_count=$(grep -c '^\[' ~/.aws/config 2>/dev/null || echo "0")
        echo "✅ AWS config file found with $profile_count profiles"
    fi
    if [ -f ~/.aws/credentials ]; then
        cred_count=$(grep -c '^\[' ~/.aws/credentials 2>/dev/null || echo "0")
        echo "✅ AWS credentials file found with $cred_count profiles"
    fi
else
    echo "⚠️  No AWS configuration found"
    echo "   Run 'aws configure' to set up your first profile"
fi

# Test 7: Installation method detection
echo "7️⃣ Detecting installation method..."
if [ -n "$ZSH_VERSION" ] && [ -n "$ZSH_CUSTOM" ]; then
    if [ -d "${ZSH_CUSTOM}/plugins/aws-profile-extension" ]; then
        echo "✅ Oh My Zsh plugin installation detected"
    else
        echo "ℹ️  Oh My Zsh available but plugin not installed in custom directory"
    fi
elif [ -d ~/.oh-my-zsh ]; then
    echo "ℹ️  Oh My Zsh available (ZSH_CUSTOM not set)"
else
    echo "ℹ️  Standalone installation (no Oh My Zsh detected)"
fi

echo ""
echo "🏁 Test Summary"
echo "==============="

# Overall assessment
if command -v aws-profile >/dev/null 2>&1 && declare -f awsp >/dev/null 2>&1; then
    echo "🎉 Installation looks good! Try:"
    echo "   awsp --list"
    echo "   awsp your-profile-name"
elif command -v aws-profile >/dev/null 2>&1; then
    echo "⚠️  Python package installed, but shell integration missing"
    echo "   Source the shell integration: source ./aws-profile.sh"
elif declare -f awsp >/dev/null 2>&1; then
    echo "⚠️  Shell integration loaded, but Python package missing"
    echo "   Install with: pip install -e ."
else
    echo "❌ Installation incomplete - see errors above"
fi

echo ""
echo "For help:"
echo "- Full documentation: README.md"
echo "- Distribution guide: DISTRIBUTION.md"
echo "- Oh My Zsh plugin: oh-my-zsh-plugin/README.md"
