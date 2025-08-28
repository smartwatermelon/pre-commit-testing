#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Detailed Pre-commit Performance Analysis"
echo "==========================================="

# Create test file
TEST_FILE="detail-test.sh"
cat >"${TEST_FILE}" <<'EOF'
#!/usr/bin/env bash
echo "test script"
if [ "$1" = "debug" ]; then
  echo "debug mode"
fi
EOF

# Function to time with Python (more reliable than bc)
time_cmd() {
  local description="$1"
  shift
  local cmd="$*"

  echo ""
  echo "📊 ${description}"
  echo "Command: ${cmd}"
  echo "----------------------------------------"

  # Time multiple runs
  local times=()
  for i in {1..3}; do
    local result
    result=$(python3 -c "
import subprocess
import time
import sys

start = time.time()
try:
    result = subprocess.run('${cmd}', shell=True, capture_output=True, text=True)
    end = time.time()
    duration = end - start
    print(f'{duration:.3f}')
    sys.exit(result.returncode)
except Exception as e:
    end = time.time()
    duration = end - start
    print(f'{duration:.3f}')
    sys.exit(1)
        " 2>/dev/null)
    local exit_code=$?
    times+=("${result}")
    echo "  Run ${i}: ${result}s (exit: ${exit_code})"
  done

  # Calculate average
  local avg
  avg=$(python3 -c "
times = [${times[0]}, ${times[1]}, ${times[2]}]
avg = sum(times) / len(times)
print(f'{avg:.3f}')
    ")
  echo "  Average: ${avg}s"
  echo "========================================="
}

# Profile each component
echo ""
echo "🧪 Component Analysis"

# 1. Global lint function
time_cmd "Global lint function" "lint \"${TEST_FILE}\""

# 2. Local pre-commit
time_cmd "Local pre-commit run" "pre-commit run --files \"${TEST_FILE}\""

# 3. Direct shell hook
time_cmd "Shell hook directly" "/Users/andrewrich/.config/git/hooks/lint-shell.sh \"${TEST_FILE}\""

# 4. Individual tools
echo ""
echo "🔧 Individual Tool Performance"

time_cmd "ShellCheck only" "shellcheck \"${TEST_FILE}\""
time_cmd "shfmt only" "shfmt -d -i 2 -ci -bn \"${TEST_FILE}\""

# 5. Environment costs
echo ""
echo "🏗️  Environment Overhead Analysis"

time_cmd "Pre-commit environment check" "pre-commit --version"

# 6. Config loading
time_cmd "Global config access" "pre-commit run --help --config ~/.config/pre-commit/config.yaml"
time_cmd "Local config access" "pre-commit run --help"

# Test with actual commit simulation
echo ""
echo "🔄 Commit Simulation"
git add "${TEST_FILE}"
time_cmd "Commit hook simulation" "pre-commit run --hook-stage pre-commit"
git reset HEAD "${TEST_FILE}" >/dev/null 2>&1

# Cleanup
rm -f "${TEST_FILE}"

echo ""
echo "🎯 Performance Insights"
echo "======================="
echo "The detailed timing above should reveal:"
echo "1. Global vs local config loading differences"
echo "2. Environment setup overhead"
echo "3. Individual tool execution times"
echo "4. Commit context vs direct execution differences"
