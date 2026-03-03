.DEFAULT_GOAL := help

# Variables
VENV_DIR = venv
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

install: venv ## Install dependencies from requirements.txt
	@echo "Installing dependencies..."
	$(PIP) install -r $(REQUIREMENTS)
	$(PIP) install -e .  # Install package in editable mode if applicable

run: install ## Run the main application (modify as needed)
	@echo "Running application..."
	$(PYTHON) main.py

test: install ## Run tests (requires pytest or similar)
	@echo "Running tests..."
	$(PYTHON) -m pytest

format: ## Format code with black (requires black)
	@echo "Formatting code..."
	black .

lint: ## Lint code with flake8 or ruff (requires linter)
	@echo "Linting code..."
	flake8 .

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
