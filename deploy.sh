#!/bin/bash

SERVICE_URL="https://raw.githubusercontent.com/geerlingguy/pi-kiosk/refs/heads/master/kiosk.service"
SCRIPT_URL="https://raw.githubusercontent.com/geerlingguy/pi-kiosk/refs/heads/master/kiosk.sh"
SERVICE_PATH="/etc/systemd/system/kiosk.service"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Prompt for user
read -p "Enter the user to run the kiosk (default: pi): " USER
USER=${USER:-pi}

# Prompt for script path
read -p "Enter the path to save kiosk.sh (default: /home/$USER/kiosk/kiosk.sh): " SCRIPT_PATH
SCRIPT_PATH=${SCRIPT_PATH:-"/home/$USER/kiosk/kiosk.sh"}

# Ensure the directory exists
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
mkdir -p "$SCRIPT_DIR"

# Get the group of the user
GROUP=$(id -gn "$USER")

# Install necessary packages
echo "Installing necessary packages..."
apt-get update && apt-get install -y chromium-browser unclutter

# Download systemd service file
echo "Downloading systemd service file..."
curl -o "$SERVICE_PATH" "$SERVICE_URL"

# Download the kiosk script
echo "Downloading kiosk script..."
curl -o "$SCRIPT_PATH" "$SCRIPT_URL"
chmod +x "$SCRIPT_PATH"

# Update the service file
sed -i "s|ExecStart=/bin/bash /home/pi/kiosk/kiosk.sh|ExecStart=/bin/bash $SCRIPT_PATH|g" "$SERVICE_PATH"
sed -i "s/User=pi/User=$USER/g" "$SERVICE_PATH"
sed -i "s/Group=pi/Group=$GROUP/g" "$SERVICE_PATH"

# Update the ExecStart path in the service file
sed -i "s|ExecStart=/usr/local/bin/kiosk.sh|ExecStart=$SCRIPT_PATH|g" "$SERVICE_PATH"

# Reload systemd to recognize new service
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting the new service..."
systemctl enable kiosk.service
systemctl start kiosk.service

echo "Deployment completed successfully!"