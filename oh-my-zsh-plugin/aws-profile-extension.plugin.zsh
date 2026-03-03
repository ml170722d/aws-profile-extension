# AWS Profile Switcher - Oh My Zsh Plugin
# Easy AWS profile switching with SSO support

# Get the directory where this plugin is located
PLUGIN_DIR="${0:A:h}"

# Plugin main functionality
awsp() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        echo "Usage: awsp <profile-name>"
        echo "Or: awsp --list to see available profiles"
        return 1
    fi

    # Use the wrapper script that handles virtual environment
    local wrapper_script="$PLUGIN_DIR/aws-profile-wrapper.sh"

    if [ -f "$wrapper_script" ]; then
        # Use the self-contained wrapper
        if [ "$profile_name" = "--list" ] || [ "$profile_name" = "-l" ]; then
            "$wrapper_script" --list
        else
            # Run without capturing output to allow interactive SSO login
            "$wrapper_script" "$profile_name"
            result=$?

            if [ $result -eq 0 ]; then
                # Set the environment variable
                export AWS_PROFILE="$profile_name"
                echo ""
                echo "✓ AWS_PROFILE is now set to: $profile_name"
            else
                return $result
            fi
        fi
    else
        # Fallback error message
        echo "❌ AWS Profile Switcher not properly installed."
        echo "Expected wrapper script: $wrapper_script"
        echo "Try reinstalling: ./install.sh --oh-my-zsh"
        return 1
    fi
}

# Helper function to show current profile
aws-current-profile() {
    if [ -n "$AWS_PROFILE" ]; then
        echo "Current AWS profile: $AWS_PROFILE"
    else
        echo "No AWS profile set (using default)"
    fi
}

# Function to clear AWS profile
aws-clear-profile() {
    unset AWS_PROFILE
    echo "AWS_PROFILE cleared"
}

# Completion function for awsp
_awsp_complete() {
    local cur="${words[COMP_CWORD]}"
    local profiles=()

    # Read profiles from config file
    if [ -f ~/.aws/config ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^\[profile\ (.+)\] ]]; then
                profiles+=("${match[1]}")
            elif [[ $line =~ ^\[default\] ]]; then
                profiles+=("default")
            fi
        done < ~/.aws/config
    fi

    # Read profiles from credentials file
    if [ -f ~/.aws/credentials ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^\[(.+)\] ]]; then
                profiles+=("${match[1]}")
            fi
        done < ~/.aws/credentials
    fi

    # Add special options
    profiles+=(--list -l)

    # Generate completions
    compadd -a profiles
}

# Register completion function
compdef _awsp_complete awsp

# Aliases for convenience
alias awsprofile="awsp"

# # Show plugin loaded message
# if [[ -o interactive ]]; then
#     echo "🚀 AWS Profile Switcher loaded! Use: awsp --list"
# fi
