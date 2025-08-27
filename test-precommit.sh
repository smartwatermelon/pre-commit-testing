#!/usr/bin/env bash
set -euo pipefail

# Test harness for pre-commit hook system
# Tests all code paths: clean files, auto-fixable issues, non-fixable issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/tests"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
  echo -e "${BLUE}[TEST]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[TEST]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[TEST]${NC} $*"
}

log_error() {
  echo -e "${RED}[TEST]${NC} $*"
}

test_passed=0
test_failed=0
test_total=0

run_test() {
  local test_name="$1"
  local test_dir="$2"
  local expected_result="$3" # "pass", "auto-fix", "fail"

  test_total=$((test_total + 1))
  log "Running test: ${test_name}"

  # Create a temporary git repo for this test
  local temp_repo="${TEMP_DIR}/${test_name// /_}"
  mkdir -p "${temp_repo}"
  cd "${temp_repo}"

  # Initialize git repo
  git init --quiet
  git config user.name "Test User"
  git config user.email "test@example.com"

  # Copy test files
  cp -r "${test_dir}"/* . 2>/dev/null || true

  # Stage all files
  git add .

  # Run pre-commit with global config
  local result=0
  pre-commit run --config "${HOME}/.config/pre-commit/config.yaml" --all-files >/dev/null 2>&1 || result=$?

  case "${expected_result}" in
    "pass")
      if [[ ${result} -eq 0 ]]; then
        log_success "✅ ${test_name} - PASSED (clean files)"
        test_passed=$((test_passed + 1))
      else
        log_error "❌ ${test_name} - FAILED (expected clean, got errors)"
        test_failed=$((test_failed + 1))
      fi
      ;;
    "auto-fix")
      if [[ ${result} -ne 0 ]]; then
        # Check if files were modified (indicating auto-fix)
        if ! git diff --quiet; then
          log_success "✅ ${test_name} - PASSED (auto-fixed, need re-stage)"
          test_passed=$((test_passed + 1))
        else
          log_error "❌ ${test_name} - FAILED (expected auto-fix, no changes made)"
          test_failed=$((test_failed + 1))
        fi
      else
        log_error "❌ ${test_name} - FAILED (expected auto-fix, but passed clean)"
        test_failed=$((test_failed + 1))
      fi
      ;;
    "fail")
      if [[ ${result} -ne 0 ]]; then
        # Check if files were NOT modified (indicating non-fixable)
        if git diff --quiet; then
          log_success "✅ ${test_name} - PASSED (non-fixable errors detected)"
          test_passed=$((test_passed + 1))
        else
          log_warning "⚠️  ${test_name} - PARTIAL (errors detected but some fixes applied)"
          test_passed=$((test_passed + 1))
        fi
      else
        log_error "❌ ${test_name} - FAILED (expected errors, but passed clean)"
        test_failed=$((test_failed + 1))
      fi
      ;;
    *)
      log_error "❌ ${test_name} - FAILED (unknown expected result: ${expected_result})"
      test_failed=$((test_failed + 1))
      ;;
  esac

  # Return to original directory
  cd "${SCRIPT_DIR}"
}

main() {
  log "Starting pre-commit hook test suite"
  log "Test directory: ${TEST_DIR}"

  # Test 1: Valid files (should pass clean)
  run_test "Valid files test" "${TEST_DIR}/valid" "pass"

  # Test 2: Auto-fixable files (should fix and require re-stage)
  run_test "Auto-fixable files test" "${TEST_DIR}/auto-fixable" "auto-fix"

  # Test 3: Non-fixable files (should fail with errors)
  run_test "Non-fixable files test" "${TEST_DIR}/non-fixable" "fail"

  # Summary
  echo "========================================"
  log_success "Tests passed: ${test_passed}/${test_total}"
  if [[ ${test_failed} -gt 0 ]]; then
    log_error "Tests failed: ${test_failed}/${test_total}"
    exit 1
  else
    log_success "All tests passed! 🎉"
  fi
}

# Check dependencies
if ! command -v pre-commit >/dev/null; then
  log_error "pre-commit not found in PATH"
  exit 1
fi

main "$@"
