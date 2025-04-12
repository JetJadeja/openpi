.PHONY: all update venv install-uv deps run

# The “all” target runs every step sequentially.
all: update venv deps run

# Update system packages and install Python 3.11 with required components.
update:
	@echo "Updating system and installing Python 3.11, venv, and dev packages..."
	sudo apt update
	sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Create a Python 3.11 virtual environment.
venv:
	@echo "Creating virtual environment with Python 3.11..."
	python3.11 -m venv py311_env

# Install the uv dependency manager.
install-uv:
	@echo "Installing uv dependency manager..."
	curl -LsSf https://astral.sh/uv/install.sh | sh

# Install project dependencies.
# This target first ensures uv is installed, then sources uv’s env setup and the virtual environment
# to run uv sync and the pip installation.
deps: install-uv
	@echo "Installing project dependencies using uv..."
	. $(HOME)/.local/bin/env && . py311_env/bin/activate && \
	GIT_LFS_SKIP_SMUDGE=1 uv sync && \
	GIT_LFS_SKIP_SMUDGE=1 uv pip install -e .

# Run the policy server.
# This again sources both uv’s environment and the virtual environment before starting the service.
run: deps
	@echo "Starting the policy server..."
	. $(HOME)/.local/bin/env && . py311_env/bin/activate && \
	uv run scripts/serve_policy.py policy:checkpoint --policy.config=pi0_fast_droid --policy.dir=s3://openpi-assets/checkpoints/pi0_fast_droid
