# Update the system.
apt update
apt upgrade -y

# Install the tools we need.
apt install -y parallel beep p7zip-full

# Un-blacklist the pc-speaker kernel module. Required for beep to work.
sed -i 's/blacklist pcspkr/#blacklist pcspkr/' /etc/modprobe.d/blacklist.conf

# Disable auto-mounting disks that are inserted.
gsettings set org.gnome.desktop.media-handling automount false

echo Configuration complete. You should reboot.