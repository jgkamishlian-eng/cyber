#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: automation-shortcut.sh <workflow> [args]

Workflows:
  nmap-wireshark   <target> <interface> [output-dir]
  amass-nmap       <domain> [output-dir] [-- nmap-args]
  nmap-nikto       <target> [output-dir]

Examples:
  sudo ./automation-shortcut.sh nmap-wireshark 192.168.1.0/24 eth0 ./captures
  ./automation-shortcut.sh amass-nmap example.com ./captures -- -sV -T4
  ./automation-shortcut.sh nmap-nikto 192.168.1.10 ./captures
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

workflow="$1"
shift

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$workflow" in
  nmap-wireshark)
    exec "$script_dir/nmap-wireshark-automation.sh" "$@"
    ;;
  amass-nmap)
    exec "$script_dir/amass-nmap-automation.sh" "$@"
    ;;
  nmap-nikto)
    exec "$script_dir/nmap-nikto-automation.sh" "$@"
    ;;
  *)
    echo "Error: unknown workflow '$workflow'" >&2
    usage
    exit 1
    ;;
 esac
