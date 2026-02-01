## Automation: Nmap + Wireshark Workflow

This workflow ties Nmap discovery to a packet capture so you can review scan traffic in Wireshark without manual setup. It uses `tshark` (Wireshark CLI) to capture while Nmap runs, then opens the capture in Wireshark.

### What it does
- Starts a packet capture on a chosen interface.
- Runs an Nmap scan against your target(s).
- Stops the capture and saves:
  - Nmap text output
  - Nmap XML output (for import into other tools)
  - A `.pcapng` capture for Wireshark review

### Requirements
- `nmap`
- `tshark` and optionally the `wireshark` GUI
- Privileged access for packet capture and SYN scans (use `sudo`)

### Usage
```bash
sudo ./scripts/nmap-wireshark-automation.sh <target> <interface> [output-dir]
```

Example:
```bash
sudo ./scripts/nmap-wireshark-automation.sh 192.168.1.0/24 eth0 ./captures
```

### Notes
- Use the correct capture interface (e.g., `eth0`, `wlan0`, or `en0`).
- If you want lighter scans, edit the script and remove `-O` or change the scan flags.
- The `.pcapng` file can be opened in Wireshark and filtered (e.g., `ip.addr == 192.168.1.1`).

### Extending automation
- Add Nmap NSE scripts or custom targets to the script for repeatable scans.
- Convert the Nmap XML output to HTML using `xsltproc` if you want quick reports.
- Create a wrapper to chain additional tools after the capture finishes (e.g., Zeek, Suricata).
