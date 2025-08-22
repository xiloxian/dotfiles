#!/bin/bash
TRASH_DIR="$HOME/.trash"
mkdir -p "$TRASH_DIR"
mv "$1" "$TRASH_DIR/$(basename "$1").$(date +%Y%m%d_%H%M%S)"
