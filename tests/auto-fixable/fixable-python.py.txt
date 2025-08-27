#!/usr/bin/env python3
"""Python file with formatting issues that black can auto-fix."""

import sys
from pathlib import Path


def process_file(input_file:str)->int:
    """Process a given file and return status code."""
    file_path=Path(input_file)
    
    if not file_path.exists():
        print(f"Error: File '{input_file}' not found",file=sys.stderr)
        return 1
    
    print(f"Processing file: {input_file}")
    return 0


def main()->int:
    """Main entry point."""
    if len(sys.argv)!=2:
        print("Usage: python3 fixable-python.py <input_file>",file=sys.stderr)
        return 1
    
    return process_file(sys.argv[1])


if __name__=="__main__":
    sys.exit(main())