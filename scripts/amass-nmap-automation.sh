#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: amass-nmap-automation.sh <domain> [output-dir] [-- nmap-args]

Example:
  ./amass-nmap-automation.sh example.com ./captures -- -sV -T4
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

domain="$1"
out_dir="${2:-./captures}"
shift 2 || true

if [ "${1:-}" = "--" ]; then
  shift
fi

nmap_args=("$@")

if ! command -v amass >/dev/null 2>&1; then
  echo "Error: amass is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v nmap >/dev/null 2>&1; then
  echo "Error: nmap is not installed or not in PATH." >&2
  exit 1
fi

mkdir -p "$out_dir"

stamp="$(date +%Y%m%d-%H%M%S)"
subdomains_file="$out_dir/amass-${domain}-${stamp}.txt"
base="$out_dir/nmap-${domain}-${stamp}"

echo "[+] Enumerating subdomains for ${domain}"
amass enum -d "$domain" -o "$subdomains_file"

if [ ! -s "$subdomains_file" ]; then
  echo "[!] No subdomains found. Exiting."
  exit 0
fi

echo "[+] Running nmap against discovered hosts"
if [ ${#nmap_args[@]} -eq 0 ]; then
  nmap_args=("-sV" "--open")
fi

nmap "${nmap_args[@]}" -iL "$subdomains_file" -oN "${base}.txt" -oX "${base}.xml"

echo "[+] Results:"
echo "    - Subdomains: ${subdomains_file}"
echo "    - Nmap: ${base}.txt"
echo "    - Nmap XML: ${base}.xml"
