# Asynchronous FIFO Design & Verification using Verilog HDL

An **Asynchronous FIFO (First-In, First-Out)** implemented in Verilog HDL and simulated using AMD Vivado. This project explores data transfer between independent write and read clock domains, pointer synchronization, FIFO status flags, and RTL waveform analysis.

## Project Overview

An asynchronous FIFO allows data to be written using one clock and read using another clock operating at a different frequency. It is commonly used in digital systems for buffering data between modules that operate in different clock domains.

This project implements a modular asynchronous FIFO architecture with separate read and write control logic, FIFO memory, synchronizer stages, and full/empty detection.

## Key Features

- Independent write and read clock domains.
- Write clock frequency: **100 MHz**.
- Read clock frequency: **40 MHz**.
- FIFO data width: **8 bits**.
- Selected FIFO depth: **8 entries**.
- Binary and Gray-code pointer logic.
- Double-flop synchronizers for cross-domain pointer synchronization.
- FIFO full and empty flag generation.
- Burst-based stimulus using a hexadecimal text file.
- RTL behavioral simulation and waveform analysis in AMD Vivado.

## Design Specifications

| Parameter | Value |
|---|---|
| Data width | 8 bits |
| Address width | 3 bits |
| FIFO depth | 8 entries |
| Pointer width | 4 bits |
| Write clock period | 10 ns |
| Read clock period | 25 ns |
| Write clock frequency | 100 MHz |
| Read clock frequency | 40 MHz |
| Burst length | 9 words |
| HDL | Verilog |
| Simulation tool | AMD Vivado 2025.2 |

### FIFO Depth Calculation

The initial depth calculation gave a required depth of **6 entries** under the assumptions used in the calculation. A depth of **8 entries** was selected for implementation.

The selected depth provides a power-of-two FIFO organization with three address bits and a four-bit pointer, including the extra pointer bit used for full/empty detection.

*Note: The exact depth requirement depends on the burst arrival pattern, read start time, clock relationship, and synchronization latency.*

## RTL Architecture

The design is organized into the following modules:

| Module | Function |
|---|---|
| `Async_fifo` | Top-level FIFO integrating the memory and control logic |
| `fifo_mem` | Stores data words and provides read data |
| `fifo_wr` | Manages write pointer, write address, and full detection |
| `fifo_rd` | Manages read pointer, read address, and empty detection |
| `DF_Sync` | Synchronizes pointer information between clock domains |

### Design Flow

1. **Write domain:** Accepts input data when a write request is valid and the FIFO is not full.
2. **FIFO memory:** Stores data at the location selected by the write address.
3. **Pointer synchronization:** Transfers Gray-coded pointer information safely between clock domains using synchronizer stages.
4. **Read domain:** Retrieves stored data when a read request is valid and the FIFO is not empty.
5. **Status flags:** Indicate whether the FIFO is full or empty.

## Burst Stimulus

The testbench loads input data from `stimulus.txt` using Verilog's `$readmemh` system task.

The nine hexadecimal data words are:

```text
AA
BB
CC
DD
EE
FF
55
44
33
```

The expected read sequence is:

`AA → BB → CC → DD → EE → FF → 55 → 44 → 33`

The testbench generates independent clocks, applies reset sequences, issues write and read requests, and observes the output data and FIFO status flags.

### Stimulus File

Keep `stimulus.txt` accessible to the Vivado simulation. For example:

```text
AA
BB
CC
DD
EE
FF
55
44
33
```

Load the file using `$readmemh`:

```verilog
$readmemh("C:/path/to/stimulus.txt", Burst_Words);
```

Replace the example path with the actual location of your file. The path must be valid in the simulator's execution environment.

## Simulation Using AMD Vivado

1. Open the Vivado project.
2. Add the RTL source files under **Design Sources**.
3. Add `Async_fifo_tb.v` under **Simulation Sources**.
4. Ensure `Async_fifo_tb` is selected as the simulation top.
5. Place `stimulus.txt` at a known location and verify the `$readmemh` path.
6. Run **Run Simulation → Run Behavioral Simulation**.
7. Observe the write and read clocks, resets, enables, input/output data, and full/empty flags in the waveform viewer.

## Waveform Analysis

The simulation waveform is used to inspect:

- Independent write and read clock operation.
- Reset assertion and release.
- Write and read enable timing.
- Sequential data storage and retrieval.
- FIFO full and empty flag transitions.
- The ordering of data across the two clock domains.

The expected functional result is that accepted data is read back in FIFO order, without loss or duplication, and that status flags correctly reflect the FIFO state.

## Technologies Used

- **Verilog HDL** — RTL implementation and testbench.
- **AMD Vivado 2025.2** — RTL elaboration and behavioral simulation.
- **XSim** — Vivado simulation engine.
- **Hexadecimal stimulus file** — Burst input data generation.

## Learning Outcomes

This project helped develop practical understanding of:

- Asynchronous FIFO architecture.
- Clock-domain crossing (CDC).
- Binary-to-Gray-code pointer conversion.
- Double-flop synchronization.
- FIFO pointer management and status flag generation.
- Testbench stimulus generation.
- RTL simulation and waveform debugging.

## Project Links

- **GitHub Repository:** https://github.com/Durgesh1029/Asyn_fifo
- **Personal Website:** https://home.iitk.ac.in/~durgesh24/

---

**Author:** Durgesh Dongre

*Exploring Digital VLSI Design, RTL Development, and Hardware Verification.*
