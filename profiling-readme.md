# Pre-commit Performance Profiling Scripts

This directory contains several scripts for analyzing pre-commit hook performance and identifying bottlenecks.

## Scripts Overview

### 🚀 `quick-profile.sh`

**Purpose:** Fast comparison between different execution methods  
**Best for:** Quick checks and basic performance monitoring

**What it does:**

- Compares global `lint` function vs local pre-commit
- Tests pre-commit in commit context vs direct execution
- Measures shell hook performance directly
- Provides simple timing comparisons

**Usage:**

```bash
./quick-profile.sh
```

**Sample output:**

```text
⚡ Quick Pre-commit Performance Comparison
Lint function (global config): ✅ Success: 0.837s
Local pre-commit (repo config): ✅ Success: 0.555s
Pre-commit in commit context: ✅ Success: 0.712s
Shell hook directly: ✅ Success: 0.371s
```

### 📊 `detailed-profile.sh`

**Purpose:** Comprehensive performance breakdown with multiple test runs  
**Best for:** Detailed analysis and consistent measurements

**What it does:**

- Runs each test 3 times and calculates averages
- Measures individual tool performance (shellcheck, shfmt)
- Analyzes environment setup overhead
- Compares global vs local config loading
- Tests commit simulation scenarios

**Usage:**

```bash
./detailed-profile.sh
```

**Key metrics provided:**

- Pre-commit environment initialization time
- Individual tool execution times
- Config loading differences
- Statistical averages across multiple runs

### 🏁 `compare-approaches.sh`

**Purpose:** Direct side-by-side comparison of different approaches  
**Best for:** Understanding the performance impact of each layer

**What it does:**

- Tests direct tool usage (shellcheck + shfmt)
- Compares shell hook script execution
- Measures pre-commit framework overhead
- Simulates actual commit process
- Shows cumulative overhead at each layer

**Usage:**

```bash
./compare-approaches.sh
```

**Demonstrates:**

- Raw tool performance vs framework overhead
- Step-by-step performance degradation
- Real-world commit simulation timing

### 📈 `performance-analysis.md`

**Purpose:** Detailed analysis report of profiling findings  
**Best for:** Understanding results and optimization recommendations

**Contains:**

- Performance metrics summary table
- Bottleneck analysis breakdown
- Root cause identification
- Optimization recommendations
- Visual performance comparison charts

## Usage Recommendations

### For Regular Monitoring

Use `quick-profile.sh` to check if performance has changed after configuration updates or system changes.

### For Investigation

Use `detailed-profile.sh` when you need precise measurements or want to track performance over time.

### For Optimization

Use `compare-approaches.sh` to understand exactly where time is being spent and evaluate alternative approaches.

### For Documentation

Reference `performance-analysis.md` for the complete analysis and recommendations.

## Understanding the Results

### Expected Performance Ranges

- **Direct tools**: 0.04-0.10s (shellcheck + shfmt combined)
- **Shell hook script**: 0.08-0.16s (tools + file management)
- **Pre-commit runs**: 0.5-0.6s (tools + framework overhead)
- **Commit context**: 0.6-0.8s (tools + framework + git integration)

### Performance Baseline

The pre-commit framework has an inherent ~400-500ms initialization cost. This is normal and provides:

- Consistent tool versions across environments
- Dependency management
- Output formatting and collection
- Git integration features
- Hook orchestration and error handling

### When to Investigate Further

Consider investigating if you see:

- Sudden increases in timing (>50% slower than baseline)
- Individual tools taking >0.1s consistently
- Framework overhead >1s regularly
- Significant variance between runs (>100ms difference)

## Troubleshooting Performance Issues

1. **Run all scripts** to establish current baseline
2. **Compare with expected ranges** above
3. **Check system resources** (CPU, memory, disk I/O)
4. **Review recent changes** to pre-commit config or system
5. **Test with minimal config** to isolate problematic hooks

## Script Dependencies

All scripts require:

- `bash` (GNU Bash 5.x+)
- `python3` (for timing calculations)
- `git` (for repository operations)
- `pre-commit` (installed and configured)
- Access to the configured shell linting tools (`shellcheck`, `shfmt`)

## Notes

- Scripts create temporary test files that are automatically cleaned up
- All timing uses Python's `time.time()` for consistent measurements
- Scripts are safe to run repeatedly and won't modify your actual code files
- Performance will vary based on system load and hardware specifications
