# 📷 OV7670 Camera Interface

This document details the configuration, communication protocols, and timing constraints for interfacing the OV7670 CMOS image sensor with the Nexys A7 board.

## ⚙️ SCCB Configuration

Before the camera can output valid video data, its internal registers must be initialized. We use an I2C-compatible protocol (SCCB) to write to the camera's registers.
* **Target Format:** RGB565 (16 bits per pixel).
* **Resolution:** VGA (640x480) or scaled down (e.g., QVGA 320x240) to fit within the available Artix-7 BRAM constraints.
* **Test Pattern:** An internal color bar test pattern can be enabled via registers to isolate capture bugs from sensor optical issues.

## ⏱️ Timing & Synchronization

The hardware must respect the sensor's strict timing signals:
1. **`PCLK` (Pixel Clock):** The fundamental clock for data capture. Data on the 8-bit parallel bus is valid on the rising edge.
2. **`VSYNC` (Vertical Sync):** Indicates the start/end of a complete frame. Used to reset the BRAM write address pointer to `0`.
3. **`HREF` (Horizontal Reference):** Active high when a row of valid pixels is being transmitted.

## 📍 Pin Mapping (XDC)

The camera module connects to the FPGA via the standard Pmod headers. Care must be taken regarding voltage levels, as the OV7670 typically expects 3.3V logic, which matches the Nexys A7 Pmod voltage.
* *Refer to `constraints/nexys_a7.xdc` for the exact pin LOC constraints (e.g., mapping `PCLK`, `VSYNC`, `HREF`, and `D[7:0]` to the specific Pmod ports).*
