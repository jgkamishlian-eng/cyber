#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: nmap-wireshark-automation.sh <target> <interface> [output-dir]

Example:
  sudo ./nmap-wireshark-automation.sh 192.168.1.0/24 eth0 ./captures
USAGE
}

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

target="$1"
iface="$2"
out_dir="${3:-./captures}"

if ! command -v nmap >/dev/null 2>&1; then
  echo "Error: nmap is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v tshark >/dev/null 2>&1; then
  echo "Error: tshark (Wireshark CLI) is not installed or not in PATH." >&2
  exit 1
fi

mkdir -p "$out_dir"

stamp="$(date +%Y%m%d-%H%M%S)"
base="$out_dir/nmap-${stamp}"
pcap_file="$out_dir/traffic-${stamp}.pcapng"

cleanup() {
  if [ -n "${capture_pid:-}" ] && kill -0 "$capture_pid" 2>/dev/null; then
    kill -INT "$capture_pid"
    wait "$capture_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "[+] Starting packet capture on ${iface} -> ${pcap_file}"
tshark -i "$iface" -w "$pcap_file" >/dev/null 2>&1 &
capture_pid=$!

sleep 2

echo "[+] Running nmap scan against ${target}"
sudo nmap -sS -sV -O -oN "${base}.txt" -oX "${base}.xml" "$target"

echo "[+] Capture complete. Results:"
echo "    - Nmap: ${base}.txt"
echo "    - Nmap XML: ${base}.xml"
echo "    - Packet capture: ${pcap_file}"

if command -v wireshark >/dev/null 2>&1; then
  echo "[+] Opening capture in Wireshark"
  wireshark "$pcap_file" >/dev/null 2>&1 &
else
  echo "[!] Wireshark GUI not found. Open ${pcap_file} manually if needed."
fi
