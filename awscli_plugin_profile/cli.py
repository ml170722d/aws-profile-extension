"""CLI entry point for standalone usage."""

import sys
from awscli_plugin_profile.profile import ProfileCommand
from botocore.session import Session


def main():
    """Main entry point for the aws-profile CLI command."""
    # Create a minimal session
    session = Session()
    
    # Create the command
    command = ProfileCommand(session)
    
    # Parse arguments manually for standalone usage
    import argparse
    parser = argparse.ArgumentParser(
        description='Switch AWS profiles with automatic SSO login',
        prog='aws-profile'
    )
    parser.add_argument('profile_name', nargs='?', help='Name of the AWS profile to switch to')
    parser.add_argument('--list', action='store_true', help='List all available AWS profiles')
    
    args = parser.parse_args()
    
    # Create a parsed_args object compatible with the command
    class ParsedArgs:
        def __init__(self, profile_name, list_profiles):
            setattr(self, 'profile-name', profile_name)
            setattr(self, 'profile_name', profile_name)
            self.list = list_profiles
    
    parsed_args = ParsedArgs(args.profile_name, args.list)
    
    # Run the command
    sys.exit(command._run_main(parsed_args, None))


if __name__ == '__main__':
    main()
