#!/usr/bin/env python3
"""Test script to verify AWS Profile Extension installation."""

import sys
import os

def test_import():
    """Test if the module can be imported."""
    try:
        import awscli_plugin_profile
        print("✓ Module imports successfully")
        print(f"  Version: {awscli_plugin_profile.__version__}")
        return True
    except ImportError as e:
        print(f"✗ Failed to import module: {e}")
        return False

def test_plugin_structure():
    """Test if all required components exist."""
    try:
        from awscli_plugin_profile import awscli_initialize
        from awscli_plugin_profile.profile import ProfileCommand
        print("✓ All required components found")
        return True
    except ImportError as e:
        print(f"✗ Missing components: {e}")
        return False

def test_aws_config():
    """Check AWS config for plugin configuration."""
    aws_config = os.path.expanduser("~/.aws/config")
    if not os.path.exists(aws_config):
        print("⚠ No ~/.aws/config file found")
        print("  You'll need to create it and add:")
        print("  [plugins]")
        print("  profile = awscli_plugin_profile")
        return False

    with open(aws_config, 'r') as f:
        content = f.read()
        if '[plugins]' in content and 'profile = awscli_plugin_profile' in content:
            print("✓ Plugin configured in ~/.aws/config")
            return True
        else:
            print("⚠ Plugin not configured in ~/.aws/config")
            print("  Add these lines to ~/.aws/config:")
            print("  [plugins]")
            print("  profile = awscli_plugin_profile")
            return False

def test_profiles():
    """Check if any AWS profiles are configured."""
    config_path = os.path.expanduser("~/.aws/config")
    creds_path = os.path.expanduser("~/.aws/credentials")

    profiles = set()

    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            for line in f:
                if line.strip().startswith('[profile '):
                    profile = line.strip()[9:-1]
                    profiles.add(profile)

    if os.path.exists(creds_path):
        with open(creds_path, 'r') as f:
            for line in f:
                if line.strip().startswith('[') and line.strip().endswith(']'):
                    profile = line.strip()[1:-1]
                    profiles.add(profile)

    if profiles:
        print(f"✓ Found {len(profiles)} AWS profile(s): {', '.join(sorted(profiles))}")
        return True
    else:
        print("⚠ No AWS profiles configured")
        print("  See example-aws-config.ini for SSO profile examples")
        return False

def main():
    """Run all tests."""
    print("=" * 60)
    print("AWS Profile Extension - Installation Test")
    print("=" * 60)
    print()

    results = []

    print("1. Testing module import...")
    results.append(test_import())
    print()

    print("2. Testing plugin structure...")
    results.append(test_plugin_structure())
    print()

    print("3. Checking AWS CLI plugin configuration...")
    test_aws_config()
    print()

    print("4. Checking for AWS profiles...")
    test_profiles()
    print()

    print("=" * 60)
    if all(results):
        print("✓ All core tests passed!")
        print()
        print("Next steps:")
        print("1. Configure the plugin in ~/.aws/config (if not done)")
        print("2. Add shell integration: source shell-integration.sh")
        print("3. Try: aws profile --list")
        print("   or: awsp --list (if shell integration is active)")
    else:
        print("⚠ Some tests failed. Please review the output above.")
        sys.exit(1)
    print("=" * 60)

if __name__ == '__main__':
    main()
