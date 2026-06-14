# 🛠️ Project Setup Guide: Edge AI & FPGA Integration

This guide outlines how to set up the development environment for the project, including the FPGA hardware (Artix-7) and the software environment for the Edge AI model.

## 1. Prerequisites

* **Hardware Environment:** **Vivado** (ML Edition recommended) installed on your machine.
* **AI Environment (Raspberry Pi / PC):** **Python 3** installed with relevant libraries (e.g., OpenCV).
* **Version Control:** **Git** installed.

## 2. FPGA Project Setup (Vivado)

To avoid file path conflicts and large file transfers, we manage the Vivado project using a Tcl script. **Do not track or transfer `.xpr` files.**

1. Clone the repository to your local machine:
   ```bash
   git clone <insert_your_repository_url_here>
