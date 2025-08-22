#!/bin/bash
ISO_OUTPUT="/var/lib/libvirt/boot/shared.iso"
SOURCE_DIR="$HOME/vm-share"

echo "[+] Building ISO from $SOURCE_DIR to $ISO_OUTPUT"
genisoimage -o "$ISO_OUTPUT" -R -J "$SOURCE_DIR"

echo "[✓] ISO built successfully at $ISO_OUTPUT"
