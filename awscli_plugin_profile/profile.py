"""Profile switching implementation (standalone, no awscli dependency)."""

import os
import sys
import subprocess
from pathlib import Path

import boto3
import botocore
from botocore.exceptions import ClientError, ProfileNotFound, TokenRetrievalError


class ProfileManager:
    """Manages AWS profile switching and SSO login."""

    def list_profiles(self):
        """List all available AWS profiles."""
        try:
            config_path = Path.home() / '.aws' / 'config'
            credentials_path = Path.home() / '.aws' / 'credentials'
            profiles = set()

            # Parse config file
            if config_path.exists():
                with open(config_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('[profile '):
                            profile = line[9:-1].strip()  # Extract profile name
                            profiles.add(profile)
                        elif line == '[default]':
                            profiles.add('default')

            # Parse credentials file
            if credentials_path.exists():
                with open(credentials_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('[') and line.endswith(']'):
                            profile = line[1:-1].strip()
                            profiles.add(profile)

            if not profiles:
                sys.stdout.write('No AWS profiles found\n')
                return 0

            sys.stdout.write('Available AWS profiles:\n')
            for profile in sorted(profiles):
                # Check if SSO profile
                sso_indicator = ' (SSO)' if self._is_sso_profile(profile) else ''
                # Check if credentials are valid
                valid_indicator = ' ✓' if self._credentials_valid(profile) else ' ✗'
                sys.stdout.write(f'  - {profile}{sso_indicator}{valid_indicator}\n')

            sys.stdout.write('\n✓ = credentials valid, ✗ = credentials expired/invalid\n')
            return 0

        except Exception as e:
            sys.stderr.write(f'Error listing profiles: {str(e)}\n')
            return 1

    def switch_profile(self, profile_name):
        """Switch to a profile with automatic SSO login if needed."""
        try:
            # Check if profile exists
            if not self._profile_exists(profile_name):
                sys.stderr.write(f'Error: Profile "{profile_name}" not found in AWS config\n')
                sys.stderr.write('Run "aws-profile --list" to see available profiles\n')
                return 1

            # Check if credentials are valid
            if not self._credentials_valid(profile_name):
                sys.stdout.write(f'Credentials expired or not found for profile "{profile_name}"\n')

                # Check if it's an SSO profile
                if self._is_sso_profile(profile_name):
                    sys.stdout.write(f'Logging in to SSO for profile "{profile_name}"...\n')
                    if not self._sso_login(profile_name):
                        sys.stderr.write('Error: SSO login failed\n')
                        return 1
                    sys.stdout.write('SSO login successful\n')
                else:
                    sys.stderr.write('Error: Credentials are not valid and profile is not configured for SSO\n')
                    return 1
            else:
                sys.stdout.write(f'Credentials are valid for profile "{profile_name}"\n')

            # Set the environment variable
            self._set_profile_env(profile_name)

            # Output for shell evaluation
            sys.stdout.write(f'\nProfile switched to: {profile_name}\n')
            sys.stdout.write(f'\nTo use in your shell, run:\n')
            sys.stdout.write(f'  export AWS_PROFILE={profile_name}\n')
            sys.stdout.write(f'\nOr use the shell function:\n')
            sys.stdout.write(f'  awsp {profile_name}\n')

            return 0

        except Exception as e:
            sys.stderr.write(f'Error: {str(e)}\n')
            return 1

        # Handle list profiles
        if parsed_args.list:
            return self._list_profiles()

        # Get profile name
        profile_name = getattr(parsed_args, 'profile-name', None) or getattr(parsed_args, 'profile_name', None)

        if not profile_name:
            sys.stderr.write('Error: Please specify a profile name or use --list to see available profiles\n')
            return 1

        try:
            # Check if profile exists
            if not self._profile_exists(profile_name):
                sys.stderr.write(f'Error: Profile "{profile_name}" not found in AWS config\n')
                sys.stderr.write('Run "aws profile --list" to see available profiles\n')
                return 1

            # Check if credentials are valid
            if not self._credentials_valid(profile_name):
                sys.stdout.write(f'Credentials expired or not found for profile "{profile_name}"\n')

                # Check if it's an SSO profile
                if self._is_sso_profile(profile_name):
                    sys.stdout.write(f'Logging in to SSO for profile "{profile_name}"...\n')
                    if not self._sso_login(profile_name):
                        sys.stderr.write('Error: SSO login failed\n')
                        return 1
                    sys.stdout.write('SSO login successful\n')
                else:
                    sys.stderr.write('Error: Credentials are not valid and profile is not configured for SSO\n')
                    return 1
            else:
                sys.stdout.write(f'Credentials are valid for profile "{profile_name}"\n')

            # Set the environment variable
            self._set_profile_env(profile_name)

            # Output for shell evaluation
            sys.stdout.write(f'\nProfile switched to: {profile_name}\n')
            sys.stdout.write(f'\nTo use in your shell, run:\n')
            sys.stdout.write(f'  export AWS_PROFILE={profile_name}\n')
            sys.stdout.write(f'\nOr use the alias (add to your .bashrc or .zshrc):\n')
            sys.stdout.write(f'  alias awsp=\'function _aws_profile() {{ aws profile "$1" && export AWS_PROFILE="$1"; }}; _aws_profile\'\n')
            sys.stdout.write(f'\nThen you can simply run: awsp {profile_name}\n')

            return 0

        except Exception as e:
            sys.stderr.write(f'Error: {str(e)}\n')
            return 1

    def _profile_exists(self, profile_name):
        """Check if a profile exists in AWS config."""
        try:
            session = boto3.Session(profile_name=profile_name)
            # Try to get the config - if profile doesn't exist, this will raise ProfileNotFound
            session._session.get_scoped_config()
            return True
        except ProfileNotFound:
            return False
        except Exception:
            return False

    def _credentials_valid(self, profile_name):
        """Check if credentials for a profile are valid."""
        try:
            session = boto3.Session(profile_name=profile_name)
            sts = session.client('sts')

            # Try to get caller identity - this will fail if credentials are invalid
            response = sts.get_caller_identity()
            return True

        except (ClientError, TokenRetrievalError, botocore.exceptions.NoCredentialsError) as e:
            return False
        except Exception as e:
            # Other exceptions might indicate connection issues, not credential issues
            sys.stderr.write(f'Warning: Could not validate credentials: {str(e)}\n')
            return False

    def _is_sso_profile(self, profile_name):
        """Check if a profile is configured for SSO."""
        try:
            session = boto3.Session(profile_name=profile_name)
            config = session._session.get_scoped_config()

            # Check for SSO configuration
            return 'sso_start_url' in config or 'sso_session' in config

        except Exception:
            return False

    def _sso_login(self, profile_name):
        """Perform SSO login for a profile."""
        try:
            # Use subprocess to call aws sso login
            # Keep stdin attached for interactive authentication
            result = subprocess.run(
                ['aws', 'sso', 'login', '--profile', profile_name],
                stdin=None,  # Inherit parent stdin for interactivity
                text=True
            )

            return result.returncode == 0

        except Exception as e:
            sys.stderr.write(f'Error during SSO login: {str(e)}\n')
            return False

    def _set_profile_env(self, profile_name):
        """Set AWS_PROFILE environment variable."""
        os.environ['AWS_PROFILE'] = profile_name

    def _list_profiles(self):
        """List all available AWS profiles."""
        try:
            config_path = Path.home() / '.aws' / 'config'
            credentials_path = Path.home() / '.aws' / 'credentials'

            profiles = set()

            # Parse config file
            if config_path.exists():
                with open(config_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('[profile '):
                            profile = line[9:-1].strip()  # Extract profile name
                            profiles.add(profile)
                        elif line.startswith('[') and line.endswith(']') and line != '[default]':
                            # Handle [default] or other sections
                            if line == '[default]':
                                profiles.add('default')

            # Parse credentials file
            if credentials_path.exists():
                with open(credentials_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('[') and line.endswith(']'):
                            profile = line[1:-1].strip()
                            profiles.add(profile)

            if not profiles:
                sys.stdout.write('No AWS profiles found\n')
                return 0

            sys.stdout.write('Available AWS profiles:\n')
            for profile in sorted(profiles):
                # Check if SSO profile
                sso_indicator = ' (SSO)' if self._is_sso_profile(profile) else ''

                # Check if credentials are valid
                valid_indicator = ' ✓' if self._credentials_valid(profile) else ' ✗'

                sys.stdout.write(f'  - {profile}{sso_indicator}{valid_indicator}\n')

            sys.stdout.write('\n✓ = credentials valid, ✗ = credentials expired/invalid\n')
            return 0

        except Exception as e:
            sys.stderr.write(f'Error listing profiles: {str(e)}\n')
            return 1
