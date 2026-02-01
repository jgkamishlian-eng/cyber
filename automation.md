## Automation Workflows

This page collects small, composable automation helpers that chain tools together for repeatable tasks.

### Shortcut runner
Use the unified shortcut to run any workflow from one entry point:

```bash
./scripts/ehtk-automation.sh <workflow> [args...]
```

Available workflows:
- `nmap-wireshark` — capture traffic with `tshark` while `nmap` runs.
- `masscan-nmap` — quick port discovery with `masscan`, then detailed `nmap` on those ports.
- `web-content` — run content discovery with `gobuster` and/or `ffuf`.

---

## Workflow: Nmap + Wireshark

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

---

## Workflow: Masscan + Nmap

Use `masscan` for fast port discovery, then feed the results into `nmap` for service detection.

### Requirements
- `masscan`
- `nmap`
- Privileged access for raw sockets (use `sudo`)

### Usage
```bash
sudo ./scripts/masscan-nmap-automation.sh <target> [rate] [output-dir]
```

Example:
```bash
sudo ./scripts/masscan-nmap-automation.sh 192.168.1.0/24 2000 ./captures
```

### Notes
- Adjust the `rate` to suit your network and avoid packet loss.
- The script writes both `masscan` output and `nmap` results to the output directory.

---

## Workflow: Web Content Discovery (Gobuster + FFUF)

Run multiple content discovery tools with the same wordlist and collect outputs in one place.

### Requirements
- `gobuster` and/or `ffuf`
- A wordlist (e.g., `/usr/share/wordlists/dirb/common.txt`)

### Usage
```bash
./scripts/web-content-discovery.sh <url> <wordlist> [output-dir]
```

Example:
```bash
./scripts/web-content-discovery.sh https://example.com /usr/share/wordlists/dirb/common.txt ./captures
```

### Notes
- If one tool is missing, the script skips it and continues.
- Review the results from both tools for broader coverage.
