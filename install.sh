# Update the system.
apt update
apt upgrade -y

# Install the tools we need.
apt install -y parallel p7zip-full

# Disable auto-mounting disks that are inserted.
gsettings set org.gnome.desktop.media-handling automount false

echo Configuration complete. You should reboot.