#!/usr/bin/env bash
set -euo pipefail

main() {
  local input_file="${1:-}"

  if [[ -z "${input_file}" ]]; then
    echo "Usage: $0 <input_file>" >&2
    return 1
  fi

  if [[ ! -f "${input_file}" ]]; then
    echo "Error: File '${input_file}' not found" >&2
    return 1
  fi

  echo "Processing file: ${input_file}"
  return 0
}

main "$@"
