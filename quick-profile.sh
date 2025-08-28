#!/usr/bin/env bash
set -euo pipefail

# Quick profiling comparison between lint command and git commit hooks

echo "⚡ Quick Pre-commit Performance Comparison"
echo "========================================="

# Create a test shell script
TEST_FILE="quick-test.sh"
cat >"${TEST_FILE}" <<'EOF'
#!/usr/bin/env bash
echo "test"
if [ "$1" = "hello" ]; then
  echo "world"
fi
EOF

echo "Testing with file: ${TEST_FILE}"

# Function to time a command
time_command() {
  local cmd="$1"
  local desc="$2"

  echo ""
  echo "🕐 ${desc}"
  echo "Command: ${cmd}"

  local start_time
  start_time=$(python3 -c "import time; print(time.time())")

  eval "${cmd}" >/dev/null 2>&1
  local exit_code=$?

  local end_time
  end_time=$(python3 -c "import time; print(time.time())")

  local duration
  duration=$(python3 -c "print(f'{${end_time} - ${start_time}:.3f}')")

  if [[ "${exit_code}" -eq 0 ]]; then
    echo "✅ Success: ${duration}s"
  else
    echo "⚠️  Issues found: ${duration}s"
  fi

  return "${exit_code}"
}

# Test 1: Lint function
time_command "lint \"${TEST_FILE}\"" "Lint function (global config)"

# Test 2: Local pre-commit
time_command "pre-commit run --files \"${TEST_FILE}\"" "Local pre-commit (repo config)"

# Test 3: Simulate git commit process
echo ""
echo "🔄 Simulating git commit process..."
git add "${TEST_FILE}"

# Time the pre-commit hook execution in commit context
time_command "pre-commit run --hook-stage pre-commit" "Pre-commit in commit context"

# Reset
git reset HEAD "${TEST_FILE}" >/dev/null 2>&1

# Test 4: Individual timing of the shell script hook
echo ""
echo "🐚 Testing shell hook specifically..."
time_command "/Users/andrewrich/.config/git/hooks/lint-shell.sh \"${TEST_FILE}\"" "Shell hook directly"

# Cleanup
rm -f "${TEST_FILE}"

echo ""
echo "🎯 Analysis Tips:"
echo "- Compare 'lint function' vs 'local pre-commit' times"
echo "- Check if 'commit context' adds significant overhead"
echo "- Shell hook timing shows core processing time"
echo ""
echo "For detailed analysis, run: ./profile-hooks.sh"
