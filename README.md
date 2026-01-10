# Edge Case Example - Parameterized FIFO

This example tests edge cases and advanced RTL features:

1. **Parameterized modules** - Generic FIFO depth and width
2. **Generate blocks** - Conditional instantiation  
3. **Complex testbench** - Coverage-driven testing

## Expected Results

```
lint:       PASSED (0 errors, 1 warning)
simulate:   PASSED (all tests pass)
synth_check: PASSED (resource report)
```

## Features Tested

- Parameterization
- Generate statements
- SystemVerilog assertions
- Waveform generation

## Files

- `src/fifo.sv` - Parameterized FIFO module
- `tb/tb_fifo.sv` - SystemVerilog testbench
- `siliconci.yaml` - Pipeline with DAG dependencies
