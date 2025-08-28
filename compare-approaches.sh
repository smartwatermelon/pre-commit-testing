#!/usr/bin/env bash
set -euo pipefail

echo "🏁 Direct Performance Comparison"
echo "================================="
echo "This script shows the exact time difference between approaches"
echo ""

# Create a test shell script with some issues to fix
TEST_FILE="comparison-test.sh"
cat >"${TEST_FILE}" <<'EOF'
#!/usr/bin/env bash
echo "test"
if [ "$1" = "hello" ]
then
echo "world"
fi
EOF

echo "Created test file with formatting issues: ${TEST_FILE}"
echo ""

# Function to run and time commands
run_timed() {
  local name="$1"
  local cmd="$2"

  # Reset file to original state
  cat >"${TEST_FILE}" <<'EOF'
#!/usr/bin/env bash
echo "test"
if [ "$1" = "hello" ]
then
echo "world"
fi
EOF

  echo "🔥 ${name}"
  echo "Command: ${cmd}"

  local start_time
  start_time=$(python3 -c "import time; print(time.time())")

  # Run the command
  eval "${cmd}"
  local exit_code=$?

  local end_time
  end_time=$(python3 -c "import time; print(time.time())")

  local duration
  duration=$(python3 -c "print(f'{${end_time} - ${start_time}:.3f}')")

  if [[ "${exit_code}" -eq 0 ]]; then
    echo "✅ Success in ${duration}s"
  else
    echo "⚠️  Issues found in ${duration}s"
  fi
  echo ""
}

# Test different approaches
run_timed "Direct Tools (shellcheck + shfmt)" "diff=\$(shellcheck --format=diff \"${TEST_FILE}\" 2>/dev/null || true); if [[ -n \"\$diff\" ]]; then echo \"\$diff\" | patch --quiet \"${TEST_FILE}\" || true; fi; shfmt -w -i 2 -ci -bn \"${TEST_FILE}\""

run_timed "Shell Hook Script" "/Users/andrewrich/.config/git/hooks/lint-shell.sh \"${TEST_FILE}\""

run_timed "Local Pre-commit" "pre-commit run --files \"${TEST_FILE}\""

run_timed "Global Lint Function" "lint \"${TEST_FILE}\""

# Simulate actual commit
echo "🔄 Simulating actual commit process..."
git add "${TEST_FILE}"
run_timed "Pre-commit in Commit Context" "pre-commit run --hook-stage pre-commit"
git reset HEAD "${TEST_FILE}" >/dev/null 2>&1

echo "📊 Summary:"
echo "==========="
echo "• Direct tools: Fastest, but requires manual coordination"
echo "• Shell hook: Fast, with some file management overhead"
echo "• Pre-commit runs: Consistent but with framework overhead"
echo "• Commit context: Additional overhead for git integration"
echo ""
echo "💡 The ~0.4-0.5s overhead is pre-commit framework initialization"
echo "   The actual linting tools are very fast (~0.04s combined)"

# Cleanup
rm -f "${TEST_FILE}"
