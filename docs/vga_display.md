# 🖥️ VGA Display Controller

This document details the operation of the VGA controller module, responsible for generating video timing signals and outputting the buffered camera frames to a standard monitor.

## ⏱️ VGA Timing Specifications
The controller generates industry-standard VGA timing to drive a 640x480 resolution display at 60Hz.
* **Pixel Clock:** 25 MHz (derived from the main 100 MHz clock via `clk_wiz_0`).
* **Horizontal Sync (`Hsync`):** Controls the drawing of individual lines, including Front Porch, Sync Pulse, and Back Porch intervals.
* **Vertical Sync (`Vsync`):** Controls the frame refresh rate, signaling the monitor to return to the top-left corner.

## 💾 Memory Fetching (BRAM to Screen)
Unlike a static image, the VGA controller must constantly read the latest pixel data from the dual-port Block RAM (`blk_mem_gen_0`). 

1. As the internal horizontal and vertical counters iterate through the visible screen area, they calculate the corresponding Read Address for the BRAM.
2. The BRAM outputs the saved pixel data on Port B.
3. The data is routed to the Nexys A7 physical VGA pins.

## 🎨 Color Depth (RGB)
The Nexys A7 board uses a 12-bit resistor-ladder DAC for VGA output. Therefore, the color depth is mapped as **RGB444** (4 bits for Red, 4 bits for Green, 4 bits for Blue).
If the camera captures in RGB565, the lowest significant bits are truncated or mapped to fit the 12-bit VGA DAC constraints before being sent to the output pins.
