#!/usr/bin/env python3
"""Python file with syntax and style errors that cannot be auto-fixed."""

import sys
import os  # Unused import - flake8 F401


def process_file(input_file: str) -> int:
    """Process a given file and return status code."""
    # Undefined variable - flake8 F821
    file_path = Path(undefined_variable)

    if not file_path.exists():
        print(f"Error: File '{input_file}' not found", file=sys.stderr)
        return 1

    # Line too long - flake8 E501 (this line is intentionally very long to trigger the error)
    print(
        f"Processing file with a very long message that exceeds the maximum line length limit: {input_file}"
    )

    # Unused variable - flake8 F841
    unused_var = "not used"

    return 0


def main() -> int:
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Usage: python3 broken-python.py <input_file>", file=sys.stderr)
        return 1

    return process_file(sys.argv[1])


# Missing proper if __name__ == "__main__" check
main()
