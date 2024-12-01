#!/bin/bash

# Define variables
REPO_URL="https://github.com/khantzawhein/torrent-blocker.git"
CLONE_DIR="$HOME/torrent-blocker"
SCRIPT_NAME="blocker.sh"

# Install IPSet
sudo apt install ipset

# Step 1: Clone the repository if it doesn't already exist
if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning repository to $CLONE_DIR..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "Repository already exists at $CLONE_DIR. Pulling latest changes..."
  git -C "$CLONE_DIR" pull
fi

# Step 2: Give execute permission to blocker.sh
SCRIPT_PATH="$CLONE_DIR/$SCRIPT_NAME"
if [ -f "$SCRIPT_PATH" ]; then
  echo "Granting execute permissions to $SCRIPT_NAME..."
  chmod +x "$SCRIPT_PATH"
else
  echo "Error: $SCRIPT_NAME not found in $CLONE_DIR."
  exit 1
fi

# Step 3: Add a cron job to run blocker.sh every 10 minutes
echo "Setting up cron job to run $SCRIPT_NAME every 10 minutes..."
CRON_JOB="*/10 * * * * $SCRIPT_PATH"
(crontab -l 2>/dev/null | grep -v "$SCRIPT_NAME"; echo "$CRON_JOB") | crontab -

echo "Setup complete. Cron job added to run $SCRIPT_NAME every 10 minutes."