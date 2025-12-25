cat > README.md <<'EOF'
# Fall Detection on FPGA (OV7670 → BRAM → VGA + Posture Detection)

FPGA project implementing a real-time video pipeline using an OV7670 camera:
- Camera capture and configuration (SCCB/I2C)
- Frame buffering in BRAM
- VGA output
- Image processing block for posture change / fall detection (posture_detector)

## Repository Structure
- `comp_file_xdc_ip/`
  - `files/` RTL sources organized by functionality:
    - `src/top/` top-level integration
    - `src/camera/` OV7670 capture + SCCB/I2C config
    - `src/video/` VGA controller
    - `src/image_processing/` posture detection pipeline
    - `src/utils/` helper blocks (debounce, etc.)
    - `sim/` testbenches
    - `scripts/` ModelSim scripts
  - `ip/` Vivado IP cores (e.g., clk_wiz, blk_mem_gen)
  - `xdc/` constraints

## Quick Start (Vivado)
1. Open the Vivado project.
2. If file paths changed: remove old RTL file references (Remove from Project) and re-add RTL from `comp_file_xdc_ip/files/src/**`.
3. Run: Elaborate → Synthesis → Implementation → Bitstream.

## Outputs
- VGA: `VGA_R[3:0]`, `VGA_G[3:0]`, `VGA_B[3:0]`, `VGA_HS`, `VGA_VS`
- Camera control: `ov7670_xclk`, `ov7670_pwdn`, `ov7670_reset`
- Detection: `posture_change_detected` (+ `current_posture`)


