#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: masscan-nmap-automation.sh <target> [rate] [output-dir]

Example:
  sudo ./masscan-nmap-automation.sh 192.168.1.0/24 1000 ./captures
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

target="$1"
rate="${2:-1000}"
out_dir="${3:-./captures}"

if ! command -v masscan >/dev/null 2>&1; then
  echo "Error: masscan is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v nmap >/dev/null 2>&1; then
  echo "Error: nmap is not installed or not in PATH." >&2
  exit 1
fi

mkdir -p "$out_dir"

stamp="$(date +%Y%m%d-%H%M%S)"
base="$out_dir/masscan-${stamp}"

printf "[+] Running masscan against %s (rate=%s)\n" "$target" "$rate"
sudo masscan "$target" -p1-65535 --rate "$rate" -oG "${base}.gnmap"

ports=$(awk '/Ports:/{gsub(/,/," "); for (i=2; i<=NF; i++) if ($i ~ /open/) { split($i, p, "/"); print p[1] }}' "${base}.gnmap" | sort -n | uniq | paste -sd, -)

if [ -z "${ports}" ]; then
  echo "[!] No open ports found in masscan output."
  exit 0
fi

printf "[+] Running nmap on discovered ports: %s\n" "$ports"
sudo nmap -sS -sV -p "$ports" -oN "${base}.txt" -oX "${base}.xml" "$target"

echo "[+] Results:"
echo "    - Masscan grepable: ${base}.gnmap"
echo "    - Nmap: ${base}.txt"
echo "    - Nmap XML: ${base}.xml"
