# Standalone USB (Windows)

Use this guide to make a portable USB copy of the GUI that runs on any Windows machine with Chrome.

## What this does
- Copies the GUI files to your USB drive.
- Creates a desktop-style shortcut on the USB root that launches the GUI in Chrome.
- Keeps everything self-contained on the USB (no install required).

## Requirements
- A USB drive (recommended 1 GB+ for this project).
- Google Chrome installed on the Windows machine.

## Quick setup (PowerShell)
1. Insert your USB drive and note its drive letter (example: `E:`).
2. Open **PowerShell** in this repo folder.
3. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\windows-usb-setup.ps1 -Destination "E:\"
   ```

This creates a `cyber-gui` folder on the USB and a shortcut named **Cyber GUI** at the root of the drive.

## Manual setup (no PowerShell)
1. Copy this folder to your USB (for example, `E:\cyber-gui`).
2. Double-click `launch-gui.bat` from the USB to open the GUI in Chrome.

## Notes
- Windows no longer supports auto-run for arbitrary programs on USB devices, so you must click the shortcut or `.bat` file.
- This is a portable HTML/CSS GUI; it uses the host computer’s resources and runs locally in Chrome.
