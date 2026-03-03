.DEFAULT_GOAL := help

# Variables
VENV_DIR = .venv
PYTHON = $(VENV_DIR)/bin/python
PIP = $(VENV_DIR)/bin/pip
REQUIREMENTS = requirements.txt

# --- Targets ---

help: ## Display this help message
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

venv: ## Create and activate the virtual environment
	@echo "Creating virtual environment..."
	python3 -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	@echo "Virtual environment created. Run 'source $(VENV_DIR)/bin/activate' to activate it."

install: venv ## Install the AWS profile extension
	@echo "Installing dependencies..."
	$(PIP) install -r $(REQUIREMENTS)
	@echo "Installing AWS profile extension in editable mode..."
	$(PIP) install -e .
	@echo ""
	@echo "✓ Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Add the plugin to your ~/.aws/config:"
	@echo "   [plugins]"
	@echo "   profile = awscli_plugin_profile"
	@echo ""
	@echo "2. (Optional) Add shell integration to ~/.bashrc or ~/.zshrc:"
	@echo "   source $(PWD)/shell-integration.sh"
	@echo ""
	@echo "3. Test it:"
	@echo "   aws profile --list"

configure: ## Add plugin configuration to AWS CLI config
	@echo "Configuring AWS CLI plugin..."
	@if ! grep -q "^\[plugins\]" ~/.aws/config 2>/dev/null; then \
		echo "" >> ~/.aws/config; \
		echo "[plugins]" >> ~/.aws/config; \
		echo "profile = awscli_plugin_profile" >> ~/.aws/config; \
		echo "✓ Plugin configuration added to ~/.aws/config"; \
	elif ! grep -q "profile = awscli_plugin_profile" ~/.aws/config 2>/dev/null; then \
		sed -i.bak '/^\[plugins\]/a\'$$'\n''profile = awscli_plugin_profile' ~/.aws/config; \
		echo "✓ Plugin added to existing [plugins] section in ~/.aws/config"; \
	else \
		echo "✓ Plugin already configured in ~/.aws/config"; \
	fi

shell-integration: ## Add shell integration to current shell config
	@echo "Adding shell integration..."
	@if [ -n "$$BASH_VERSION" ]; then \
		SHELL_RC=~/.bashrc; \
	elif [ -n "$$ZSH_VERSION" ]; then \
		SHELL_RC=~/.zshrc; \
	else \
		echo "Unknown shell. Please manually add to your shell RC file:"; \
		echo "source $(PWD)/shell-integration.sh"; \
		exit 1; \
	fi; \
	if ! grep -q "shell-integration.sh" $$SHELL_RC 2>/dev/null; then \
		echo "" >> $$SHELL_RC; \
		echo "# AWS Profile Switcher" >> $$SHELL_RC; \
		echo "source $(PWD)/shell-integration.sh" >> $$SHELL_RC; \
		echo "✓ Shell integration added to $$SHELL_RC"; \
		echo "Run: source $$SHELL_RC"; \
	else \
		echo "✓ Shell integration already configured"; \
	fi

setup: install configure shell-integration ## Complete setup (install + configure + shell integration)
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "✓ Setup complete!"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "To start using the extension:"
	@echo "1. Reload your shell: source ~/.bashrc (or ~/.zshrc)"
	@echo "2. Try: awsp --list"
	@echo "3. Switch profiles: awsp <profile-name>"
	@echo ""

test: install ## Test the extension
	@echo "Testing AWS profile extension..."
	@$(PYTHON) -c "import awscli_plugin_profile; print('✓ Module imports successfully')"
	@echo "✓ Extension installed correctly"
	@echo ""
	@echo "Try running: aws profile --list"

format: ## Format code with black (requires black)
	@echo "Formatting code..."
	black awscli_plugin_profile/

clean: ## Remove temporary files and caches
	@echo "Cleaning up..."
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf $(VENV_DIR)
	rm -rf dist
	rm -rf build
	@echo "Clean complete."

# Phony targets to prevent conflicts with files of the same name
.PHONY: help venv install run test format lint clean
