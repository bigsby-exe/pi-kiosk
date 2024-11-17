#!/bin/bash

SERVICE_URL="https://raw.githubusercontent.com/geerlingguy/pi-kiosk/refs/heads/master/kiosk.service"
SCRIPT_URL="https://raw.githubusercontent.com/geerlingguy/pi-kiosk/refs/heads/master/kiosk.sh"
SERVICE_PATH="/etc/systemd/system/kiosk.service"
SCRIPT_PATH="/usr/local/bin/kiosk.sh"

# Use current user and group
USER=$(whoami)
GROUP=$(id -gn)

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

# Set the correct user and group in the service file
sed -i "s/User=pi/User=$USER/g" "$SERVICE_PATH"
sed -i "s/Group=pi/Group=$GROUP/g" "$SERVICE_PATH"

# Reload systemd to recognize new service
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting the new service..."
systemctl enable kiosk.service
systemctl start kiosk.service

echo "Deployment completed successfully!"