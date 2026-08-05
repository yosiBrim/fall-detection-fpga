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
```

## 🎥 Recording Execution Steps

### Step 1: Initial Arming (0:00 - 0:10)
* **Action:** Start the OBS recording. Paste the Tcl script into the Vivado Tcl Console and press **Enter**.
* **Result:** The system arms, captures the transition exactly at sample 512, and updates the waveform window.

### Step 2: Real-Time Hardware Demonstration (0:10 - 0:18)
* **Action:** Click the **Toggle Auto Re-trigger mode** button (circular arrows icon) on the ILA toolbar. Release the mouse for a few seconds.
* **Result:** The waveform will continuously update and flicker, proving to the viewer that this is live silicon debugging and not a static simulation.

### Step 3: Static Analysis Setup (0:18 - 0:25)
* **Action:** Click the **Stop trigger** button (red square) to freeze the capture. Then, click **Zoom Fit**, followed by a gentle **Zoom In** towards the center (sample 512) to clearly see the signal transitions.

### Step 4: VGA Blanking & Latency Measurement (0:25 - 0:40)
* **VGA 160-Cycle Blanking Proof:**
  1. Click exactly on sample **512** (where `in_display_area` falls to '0').
  2. Click **Add Marker** in the toolbar to lock a reference line.
  3. Drag the yellow cursor to sample **672** (where the signal rises back to '1').
  4. Hover for 2 seconds to show the **Delta: 160** measurement at the top of the window.
* **BRAM 2-Cycle Pipeline Latency Proof:**
  1. Move the yellow cursor back to the marker at sample **512**.
  2. Carefully move the cursor **two clock cycles right**, to sample **514**.
  3. Point the mouse arrow at the `doutb[11:0]` value. It will show that the pixels drop to `000` exactly at this 2nd clock cycle, proving the expected BRAM latency.

### Step 5: Professional Wrap-up (0:40 - 0:45)
* **Action:** Click the **Export ILA waveform data** button in the toolbar. When the dialog box opens, leave it as is and stop the OBS recording. This visually communicates transitioning to the data-processing phase.
