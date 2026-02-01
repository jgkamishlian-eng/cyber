#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: web-content-discovery.sh <url> <wordlist> [output-dir]

Example:
  ./web-content-discovery.sh https://example.com /usr/share/wordlists/dirb/common.txt ./captures
USAGE
}

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

url="$1"
wordlist="$2"
out_dir="${3:-./captures}"

if [ ! -f "$wordlist" ]; then
  echo "Error: wordlist not found at ${wordlist}." >&2
  exit 1
fi

mkdir -p "$out_dir"

stamp="$(date +%Y%m%d-%H%M%S)"
base="$out_dir/web-content-${stamp}"

if command -v gobuster >/dev/null 2>&1; then
  echo "[+] Running gobuster directory scan"
  gobuster dir -u "$url" -w "$wordlist" -o "${base}-gobuster.txt"
else
  echo "[!] gobuster not found. Skipping gobuster scan."
fi

if command -v ffuf >/dev/null 2>&1; then
  echo "[+] Running ffuf directory scan"
  ffuf -u "${url%/}/FUZZ" -w "$wordlist" -o "${base}-ffuf.json" -of json
else
  echo "[!] ffuf not found. Skipping ffuf scan."
fi

echo "[+] Output written to ${out_dir}"
