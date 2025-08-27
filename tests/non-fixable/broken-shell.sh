#!/usr/bin/env bash
set -euo pipefail

main() {
  local input_file="${1:-}"

  if [[ -z "${input_file}" ]]; then
    echo "Usage: $0 <input_file>" >&2
    return 1
  fi

  # Shellcheck will complain about this unused variable
  local unused_variable="not_used"

  # This will cause a shellcheck error - accessing undefined variable
  echo "Processing file: ${undefined_variable}"

  # This will cause another error - command not found
  nonexistent_command "${input_file}"

  return 0
}

main "$@"
