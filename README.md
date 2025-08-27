# Pre-commit Hook Test Suite

This project provides a comprehensive test suite for the global pre-commit hook system.

## Components

### Test Harness

- `test-precommit.sh` - Main test runner that exercises all code paths

### Test Files

- `tests/valid/` - Clean files that should pass all pre-commit checks
- `tests/auto-fixable/` - Files with formatting issues that can be automatically fixed
- `tests/non-fixable/` - Files with structural errors requiring manual intervention

### Configuration

- `.pre-commit-config.yaml` - Local config that excludes test files from pre-commit hooks
- Uses global pre-commit config at `$HOME/.config/pre-commit/config.yaml` for actual testing

## Usage

Run the complete test suite:

```bash
./test-precommit.sh
```

This will test all three scenarios:

1. Clean files (should pass without issues)
2. Auto-fixable files (should be fixed and require re-staging)
3. Non-fixable files (should fail with errors that cannot be auto-fixed)

## File Types Tested

- Shell scripts (shellcheck, shfmt)
- Python files (black, flake8)
- YAML files (yamllint)
- HTML files (tidy)
- Markdown files (markdownlint)

## Design

The test files in `auto-fixable/` and `non-fixable/` directories are excluded from
the local pre-commit hooks to preserve their intentionally broken state. The test
harness runs against these files using the global configuration to validate that
all code paths in the pre-commit system work correctly.
