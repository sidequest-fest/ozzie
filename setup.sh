#!/bin/bash
# Ozzie Setup Script
# Run this on your Mac to generate the Xcode project and build

set -e

echo "=== Ozzie the Wizard - Setup ==="
echo ""

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is required. Install from https://brew.sh"
        exit 1
    fi
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
cd Ozzie
xcodegen generate

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To build and run:"
echo "  1. open Ozzie/Ozzie.xcodeproj"
echo "  2. Select your Mac as the run destination"
echo "  3. Press Cmd+R to build and run"
echo ""
echo "First run permissions needed:"
echo "  - Accessibility (System Settings > Privacy > Accessibility) — for global hotkeys"
echo "  - Screen Recording (System Settings > Privacy > Screen Recording) — for screenshots"
echo "  - Notifications — will be requested on first launch"
echo ""
echo "Hotkeys:"
echo "  Cmd+Option+N  → Create task from highlighted text"
echo "  Cmd+Option+A  → Add context to existing task"
echo "  Cmd+Option+S  → Screenshot selection + OCR"
echo ""
echo "Ozzie will appear as a wizard icon in your menu bar!"
