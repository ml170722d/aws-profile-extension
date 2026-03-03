"""CLI entry point for standalone usage."""

import sys
import argparse
from awscli_plugin_profile.profile import ProfileManager


def main():
    """Main entry point for the aws-profile CLI command."""
    # Parse arguments
    parser = argparse.ArgumentParser(
        description='Switch AWS profiles with automatic SSO login',
        prog='aws-profile'
    )
    parser.add_argument('profile_name', nargs='?', help='Name of the AWS profile to switch to')
    parser.add_argument('--list', '-l', action='store_true', help='List all available AWS profiles')
    
    args = parser.parse_args()
    
    # Create the manager
    manager = ProfileManager()
    
    # Execute command
    if args.list:
        sys.exit(manager.list_profiles())
    elif args.profile_name:
        sys.exit(manager.switch_profile(args.profile_name))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()
