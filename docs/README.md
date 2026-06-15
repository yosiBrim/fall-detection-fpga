# 📂 Project Documentation (`/docs`)

This directory contains all the technical documentation, hardware specifications, and guides for the Real-Time Fall Detection System. The documentation is divided into dedicated files to allow for easy maintenance and seamless team synchronization.

## 🗺️ Documentation Structure

* **`SETUP.md`** - Workspace setup guide (Vivado project generation) using Tcl scripts, including Edge AI software configuration.
* **`hardware_architecture.md`** - Detailed hardware architecture on the Artix-7 board, Top-Level description, and implementations of various VHDL modules (Camera Controller, Memory blocks, and Control system).
* **`camera_interface.md`** - Connection specifications and protocol for the OV7670 camera, including timing diagrams, SCCB configuration, and pin mapping (XDC Constraints).
* **`vga_display.md`** - Specifications for the VGA controller, timing generation, and BRAM pixel fetching.
* **`edge_ai_integration.md`** *(Proposed Extension)* - Description of the MobileNet-SSD Proof of Concept (PoC) and the communication interface between the hardware processing unit and the software controller.

## 🔄 Documentation Update Routine

To ensure the documentation always reflects the current state of the code and hardware:
1. **Structural Updates:** Whenever a new hardware component is added, the corresponding documentation file must be updated (e.g., adding a clock controller should be documented in `hardware_architecture.md`).
2. **XDC Compatibility:** Any changes to pin assignments for the camera or peripherals must be updated in the camera guide and the main constraints file.
3. **Naming Conventions:** Maintain consistent file naming between the documentation and the actual VHDL/Python source files in the repository.
