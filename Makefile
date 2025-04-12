.PHONY: all

all:
	@echo "Starting full setup..."
	@bash -c '\
		set -e; \
		echo "Installing Git LFS..."; \
		sudo apt install -y git-lfs && git lfs install; \
		\
		echo "Cloning the OpenPI repository (if not already cloned)..."; \
		if [ ! -d "openpi" ]; then \
			git clone --recurse-submodules https://github.com/Physical-Intelligence/openpi.git; \
		fi; \
		\
		echo "Updating system and installing Python 3.11 dependencies..."; \
		sudo apt update && sudo apt install -y python3.11 python3.11-venv python3.11-dev; \
		\
		echo "Creating and activating Python 3.11 virtual environment..."; \
		cd openpi && python3.11 -m venv py311_env && . py311_env/bin/activate; \
		\
		echo "Installing uv dependency manager..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh && . $$HOME/.local/bin/env; \
		\
		echo "Installing project dependencies..."; \
		cd openpi && GIT_LFS_SKIP_SMUDGE=1 uv sync && GIT_LFS_SKIP_SMUDGE=1 uv pip install -e .; \
		\
		echo "Starting the policy server..."; \
		cd openpi && uv run scripts/serve_policy.py policy:checkpoint --policy.config=pi0_fast_droid --policy.dir=s3://openpi-assets/checkpoints/pi0_fast_droid; \
	'
