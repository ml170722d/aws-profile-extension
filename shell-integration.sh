#!/bin/bash
# AWS Profile Switcher - Shell Integration
# Add this to your ~/.bashrc or ~/.zshrc

# Main function to switch AWS profiles
awsp() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        echo "Usage: awsp <profile-name>"
        echo "Or: awsp --list to see available profiles"
        return 1
    fi

    # Run the aws profile command
    if [ "$profile_name" = "--list" ] || [ "$profile_name" = "-l" ]; then
        aws profile --list
    else
        # Capture output and check if command succeeded
        output=$(aws profile "$profile_name" 2>&1)
        result=$?

        echo "$output"

        if [ $result -eq 0 ]; then
            # Set the environment variable
            export AWS_PROFILE="$profile_name"
            echo ""
            echo "✓ AWS_PROFILE is now set to: $profile_name"
        else
            return $result
        fi
    fi
}

# Autocomplete function for awsp
_awsp_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local profiles=""

    # Read profiles from config file
    if [ -f ~/.aws/config ]; then
        profiles=$(grep '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/' | tr '\n' ' ')
    fi

    # Read profiles from credentials file
    if [ -f ~/.aws/credentials ]; then
        profiles="$profiles $(grep '^\[' ~/.aws/credentials | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ')"
    fi

    # Add special options
    profiles="$profiles --list -l"

    COMPREPLY=( $(compgen -W "$profiles" -- "$cur") )
}

# Register autocomplete for bash
if [ -n "$BASH_VERSION" ]; then
    complete -F _awsp_complete awsp
fi

# Autocomplete for zsh
if [ -n "$ZSH_VERSION" ]; then
    _awsp_zsh_complete() {
        local profiles=()

        # Read profiles from config file
        if [ -f ~/.aws/config ]; then
            while IFS= read -r line; do
                profiles+=("${line}")
            done < <(grep '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/')
        fi

        # Read profiles from credentials file
        if [ -f ~/.aws/credentials ]; then
            while IFS= read -r line; do
                profiles+=("${line}")
            done < <(grep '^\[' ~/.aws/credentials | sed 's/\[\(.*\)\]/\1/')
        fi

        # Add special options
        profiles+=(--list -l)

        _describe 'AWS profiles' profiles
    }

    compdef _awsp_zsh_complete awsp
fi

# Helper function to show current profile
aws-current-profile() {
    if [ -n "$AWS_PROFILE" ]; then
        echo "Current AWS profile: $AWS_PROFILE"
    else
        echo "No AWS profile set (using default)"
    fi
}

# Alias to unset AWS profile
aws-clear-profile() {
    unset AWS_PROFILE
    echo "AWS_PROFILE cleared"
}
