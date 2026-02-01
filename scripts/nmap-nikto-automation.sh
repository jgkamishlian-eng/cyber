#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: nmap-nikto-automation.sh <target> [output-dir]

Example:
  ./nmap-nikto-automation.sh 192.168.1.10 ./captures
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

target="$1"
out_dir="${2:-./captures}"

if ! command -v nmap >/dev/null 2>&1; then
  echo "Error: nmap is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v nikto >/dev/null 2>&1; then
  echo "Error: nikto is not installed or not in PATH." >&2
  exit 1
fi

mkdir -p "$out_dir"

stamp="$(date +%Y%m%d-%H%M%S)"
base="$out_dir/nmap-http-${stamp}"

echo "[+] Scanning HTTP/S ports on ${target}"
mapfile -t open_targets < <(
  nmap -p 80,443,8080,8443 --open -sV -oG - "$target" \
    | awk -F'[ /]' '/Ports:/{for(i=1;i<=NF;i++){if($i=="open"){host=$2;port=$(i-1);service=$(i+1);print host":"port":"service}}}'
)

if [ ${#open_targets[@]} -eq 0 ]; then
  echo "[!] No open HTTP/S ports found. Exiting."
  exit 0
fi

printf "%s\n" "${open_targets[@]}" > "${base}.targets"

while IFS=":" read -r host port service; do
  out_file="$out_dir/nikto-${host}-${port}-${stamp}.txt"
  echo "[+] Running nikto against ${host}:${port} (${service})"
  nikto -host "$host" -port "$port" -output "$out_file"
done < "${base}.targets"

echo "[+] Results saved in ${out_dir}"
