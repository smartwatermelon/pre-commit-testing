# Pre-commit Performance Analysis Results

## Summary of Findings

Based on the profiling results, here's where the time is being spent:

### Key Performance Metrics

| Operation | Time (avg) | Breakdown |
|-----------|------------|-----------|
| **Direct shell hook** | 0.082s | ⚡ Fastest - pure tool execution |
| **ShellCheck alone** | 0.029s | Core linting tool |
| **shfmt alone** | 0.013s | Core formatting tool |
| **Pre-commit overhead** | ~0.214s | Environment setup cost |
| **Local pre-commit run** | 0.506s | Tool execution + overhead |
| **Global lint function** | 0.546s | Tool execution + overhead + config |
| **Commit hook context** | 0.679s | Full commit simulation |

### Bottleneck Analysis

#### 1. Pre-commit Framework Overhead (~0.4-0.5s)

- **Environment initialization**: ~0.214s
- **Config parsing and validation**: minimal difference between local/global
- **Hook orchestration**: ~0.3s additional overhead

#### 2. Core Tool Performance (Very Fast)

- ShellCheck + shfmt combined: ~0.042s
- Direct shell hook execution: 0.082s (includes file I/O, patching)

#### 3. Context Switching Costs

- Commit context adds ~0.17s vs direct pre-commit run
- Global config vs local config: ~0.04s difference (minimal)

### Root Cause: Pre-commit Framework Overhead

The slowdown during commits vs "lint" command is **NOT** due to the tools themselves but due to:

1. **Environment Setup** (214ms baseline)
   - Python environment initialization
   - Virtual environment activation for hooks
   - Hook repository validation

2. **Hook Orchestration** (300ms+ overhead)
   - File staging/unstaging simulation
   - Hook dependency resolution
   - Output formatting and collection

3. **Commit Context Processing** (170ms additional)
   - Git integration overhead
   - Temporary file management
   - Hook stage validation

### Performance Comparison

```text
Direct tools (shellcheck + shfmt):     0.042s  ████
Shell hook script:                     0.082s  ████████
Local pre-commit:                      0.506s  ██████████████████████████████████████████████████
Global lint function:                 0.546s  ██████████████████████████████████████████████████████
Commit simulation:                     0.679s  ███████████████████████████████████████████████████████████████████
```

### Recommendations

#### For Development Speed

1. **Use direct shell hook**: `~/.config/git/hooks/lint-shell.sh file.sh` (0.082s)
2. **Use individual tools**: `shellcheck file.sh && shfmt -w file.sh` (0.042s)

#### For Commit Integration

1. **Accept the overhead**: Pre-commit framework provides consistency and reliability
2. **Optimize hook configuration**: Remove unnecessary hooks from commit-time execution
3. **Consider hook staging**: Run lightweight checks on commit, full analysis in CI

#### Configuration Optimizations

- The global vs local config difference is minimal (40ms)
- Environment setup is the primary bottleneck, not tool execution
- Tools themselves are extremely fast (< 100ms total)

### Conclusion

The "slowness" during commits is primarily due to pre-commit framework initialization (214ms) plus hook orchestration overhead (~300ms), totaling ~500ms base cost. The actual linting tools (shellcheck + shfmt) run in just 42ms.

This is a normal trade-off: convenience and consistency of the pre-commit framework vs raw execution speed.
