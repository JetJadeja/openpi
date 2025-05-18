-   **SSH into your Vast.ai instance** (preferable to do this in an IDE):
    
    ```
    ssh username@your-instance-ip -p port_number
    ```
    
-   **Install Git LFS**:
    
    ```
    sudo apt install git-lfs
    git lfs install
    ```
    
-   **Clone the OpenPI repository**:
    
    ```
    git clone --recurse-submodules https://github.com/Physical-Intelligence/openpi.git
    cd openpi
    ```

-   **Update and install Python 3.11**:
    
    ```
    sudo apt update
    sudo apt install python3.11 python3.11-venv python3.11-dev
    ```
    
-   **Create a virtual environment with Python 3.11**:
    
    ```
    python3.11 -m venv py311_env
    source py311_env/bin/activate
    ```
    
-   **Install the uv dependency manager**:
    
    ```
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
    ```
    
-   **Install the dependencies**:
    
    ```
    GIT_LFS_SKIP_SMUDGE=1 uv sync
    GIT_LFS_SKIP_SMUDGE=1 uv pip install -e .
    ```
    
-   **Start the policy server**:
    
    ```
    uv run scripts/serve_policy.py policy:checkpoint --policy.config=pi0_fast_droid --policy.dir=s3://openpi-assets/checkpoints/pi0_fast_droid
    ```

-   **Setup on local device**

    Run this
    ```
    ssh -t username@ip-address -L 9000:localhost:8000 "TERM=xterm-color bash -l"
    ```


## Part 3: Setting Up the Client on Your Robot's Control Computer

1.  **Clone the OpenPI repository on your robot's control computer**:
    
    ```
    git clone https://github.com/Physical-Intelligence/openpi.git
    ```
    
2.  **Install the client package**:
    
    ```
    cd openpi/packages/openpi-client
    pip install -e .
    ```
    
3.  **Test the connection using Python**:
    
    python
    
    ```python
    from openpi_client import websocket_client_policy
    import numpy as np
    
    # Connect to your local port
    client = websocket_client_policy.WebsocketClientPolicy(host="localhost", port=9000)
    
    # Create a mock observation with the expected keys
    mock_observation = {
        # Joint and gripper state
        "observation/joint_position": np.zeros(7),  # 7-DOF arm
        "observation/gripper_position": np.array([0.0]),  # 0.0 = open
        
        # Images - using zeros for testing
        "observation/exterior_image_1_left": np.zeros((224, 224, 3), dtype=np.uint8),
        "observation/wrist_image_left": np.zeros((224, 224, 3), dtype=np.uint8),
        
        # Additional state that might be required
        "observation/joint_velocity": np.zeros(7),
        "observation/gripper_velocity": np.array([0.0]),
        
        # Prompt
        "prompt": "test connection"
    }
    
    # Try the inference
    response = client.infer(mock_observation)
    print(response)
    ```
    
