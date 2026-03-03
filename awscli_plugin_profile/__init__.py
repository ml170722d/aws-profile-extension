"""AWS CLI Profile Extension - Quick profile switching with SSO support."""

__version__ = '1.0.0'


def awscli_initialize(cli):
    """
    Entry point for AWS CLI plugin system.
    This function is called by the AWS CLI to initialize the plugin.
    """
    from awscli_plugin_profile.profile import ProfileCommand
    cli.register('building-command-table.main', ProfileCommand.add_command)
