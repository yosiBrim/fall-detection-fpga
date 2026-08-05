# 🎬 FPGA Hardware Validation: ILA Recording Procedure

This document outlines the standard operating procedure (SOP) for recording the hardware validation of the VGA and BRAM pipeline latency using Vivado's Integrated Logic Analyzer (ILA). 

The goal of this recording is to demonstrate real-time hardware execution followed by precise, static cycle-accurate measurement.

## 🛠 Prerequisites
1. Vivado Hardware Manager is open and the target FPGA is programmed with the bitstream (`.bit`) and debug probes (`.ltx`).
2. OBS Studio (or any screen recording software) is ready to capture the Vivado window.
3. Ensure no existing triggers are running (Click the red **Stop Trigger** button if necessary).
4. Clear any existing markers from the waveform window (Right-click -> **Delete All Markers**).

## 📜 Tcl Configuration Script
Copy the following Tcl commands to your clipboard. This script configures the ILA depth, sets the trigger precisely at the center (sample 512), targets the falling edge of `in_display_area`, and arms the trigger.

```tcl
set_property CONTROL.DATA_DEPTH 1024 [get_hw_ilas hw_ila_1]
set_property CONTROL.TRIGGER_POSITION 512 [get_hw_ilas hw_ila_1]
set_property TRIGGER_COMPARE_VALUE eq1'b0 [get_hw_probes vga_controller_inst/in_display_area -of_objects [get_hw_ilas hw_ila_1]]
run_hw_ila [get_hw_ilas hw_ila_1]
