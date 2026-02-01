#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ehtk-automation.sh <workflow> [args...]

Workflows:
  nmap-wireshark   <target> <interface> [output-dir]
  masscan-nmap     <target> [rate] [output-dir]
  web-content      <url> <wordlist> [output-dir]

Examples:
  sudo ./ehtk-automation.sh nmap-wireshark 192.168.1.0/24 eth0 ./captures
  sudo ./ehtk-automation.sh masscan-nmap 192.168.1.0/24 2000 ./captures
  ./ehtk-automation.sh web-content https://example.com /usr/share/wordlists/dirb/common.txt
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

workflow="$1"
shift

case "$workflow" in
  nmap-wireshark)
    exec "$(dirname "$0")/nmap-wireshark-automation.sh" "$@"
    ;;
  masscan-nmap)
    exec "$(dirname "$0")/masscan-nmap-automation.sh" "$@"
    ;;
  web-content)
    exec "$(dirname "$0")/web-content-discovery.sh" "$@"
    ;;
  *)
    echo "Error: unknown workflow '${workflow}'." >&2
    usage
    exit 1
    ;;
esac
