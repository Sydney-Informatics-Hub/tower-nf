#!/bin/bash

# Set the work directory
WORK_DIR="/scratch/$PROJECT/$(whoami)/work"

if [ ! -d "$WORK_DIR" ]; then
    echo "Creating work directory..."
    mkdir -p "$WORK_DIR"
    echo "Work directory created!"
fi

# Function to read a value from a file or prompt the user if it doesn't exist
read_value_or_prompt() {
  local VALUE_FILE="$1"
  local PROMPT_MESSAGE="$2"
  local VALUE=""

  if [ -f "$VALUE_FILE" ]; then
    VALUE=$(cat "$VALUE_FILE")
  else
    read -rp "$PROMPT_MESSAGE" VALUE

    # Save the value to the file
    mkdir -p "$(dirname "$VALUE_FILE")"
    echo "$VALUE" > "$VALUE_FILE"
    chmod 600 "$VALUE_FILE"
  fi

  echo "$VALUE"
}

# Read or prompt for the access token and session token
TOKEN_FILE="$HOME/.tower/token"
CONNECTION_ID_FILE=".tower/connection_id"
TOWER_ACCESS_TOKEN=$(read_value_or_prompt "$TOKEN_FILE" "Please enter your access token: ")
CONNECTION_ID=$(read_value_or_prompt "$CONNECTION_ID_FILE" "Please enter your session token: ")

# Export the access token
export TOWER_ACCESS_TOKEN

# Download the agent if it doesn't exist
if [ ! -f tw-agent ]; then
  echo "Downloading tw-agent..."
  curl -fSL https://github.com/seqeralabs/tower-agent/releases/latest/download/tw-agent-linux-x86_64 > tw-agent
  chmod +x tw-agent
else
  echo "tw-agent already exists."
fi

# Run the agent with the specified work directory and connection ID
./tw-agent "$CONNECTION_ID" -u https://tower.services.biocommons.org.au/api --work-dir="$WORK_DIR"
