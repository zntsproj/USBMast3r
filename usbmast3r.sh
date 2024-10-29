#!/bin/bash

format_usb() {
  local device=$1
  sudo dd if=/dev/zero of="$device" bs=512 count=1
  sudo fdisk "$device" << EOF
n
p
1

w
EOF
  sudo mkfs.vfat "${device}1"
  echo "✅ USB flash drive formatted successfully!"
}

measure_speed() {
  local device=$1
  sudo hdparm -t "$device"1
}

set_label() {
  local device=$1
  local label=$2
  sudo mkfs.vfat -n "$label" "${device}1" # Added 1 to device path
  echo "✅ Volume label set: $label"
}

secure_erase() {
  local device=$1
  read -p "Are you sure you want to PERMANENTLY erase data on $device? (y/n): " confirm
  if [[ "$confirm" == "y" ]]; then
    sudo dd if=/dev/zero of="$device" bs=1M status=progress
    echo "✅ Data on $device permanently erased."
  else
    echo "Operation cancelled."
  fi
}

while true; do
  echo ""
  echo "USB-Mast3r 1.0"
  echo "1. Format/Restore USB flash drive"
  echo "2. Measure speed (hdparm)"
  echo "3. Set volume label"
  echo "4. Securely erase all data (dd)"
  echo "5. Exit"

  read -p "Choose an action: " choice

  case "$choice" in
    1)
      read -p "Enter device path (e.g., /dev/sdb): " device_path
      format_usb "$device_path"
      ;;
    2)
      read -p "Enter device path (e.g., /dev/sdb): " device_path
      measure_speed "$device_path"
      ;;
    3)
      read -p "Enter device path (e.g., /dev/sdb): " device_path
      read -p "Enter volume label: " volume_label
      set_label "$device_path" "$volume_label"
      ;;
    4)
      read -p "Enter device path (e.g., /dev/sdb): " device_path
      secure_erase "$device_path"
      ;;
    5)
      break
      ;;
    *)
      echo "❌ Invalid choice."
      ;;
  esac
done
