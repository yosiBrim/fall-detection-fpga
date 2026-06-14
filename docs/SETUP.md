# 🛠️ FPGA Fall Detection - Environment Setup & Daily Workflow

This guide provides the exact steps for Yossi and Elad to synchronize the Vivado hardware environment between the JCT lab computers and personal laptops. 

To prevent GitHub merge conflicts and broken file paths, **we do not track or push the Vivado `.xpr` project files**. Instead, the entire project is reconstructed on the fly using a Tcl script (`build_project.tcl`).

---

## 1. Initial Setup (Cloning & Building the Project)

Follow these steps the first time you set up the project on a new computer (or if you are moving between the lab PC and your personal laptop).

### A. Directory Context
* **JCT Lab Computers:** You will typically work on the network drive. Clone the repository into your designated folder (e.g., `Z:\final project eran\fall-detection-fpga-main\fall_detection_main`).
* **Personal Laptops:** Clone the repository to any local directory (e.g., `C:\Projects\fall_detection`). The Tcl script handles the path differences automatically.

### B. Reconstructing the Vivado Project
1. Open **Vivado** (ML Edition is recommended). **Do NOT click "Open Project"**.
2. At the bottom of the Vivado welcome screen, click on the **Tcl Console** tab.
3. Use the `cd` command to navigate to the exact folder where you cloned the repository. 
   * *Example for Lab PC:* `cd {Z:/final project eran/fall-detection-fpga-main/fall_detection_main}`
   * *Example for Laptop:* `cd {C:/Projects/fall_detection/fall_detection_main}`
4. Run the build script by typing:
```tcl
   source build_project.tcl
   ```
5. Vivado will automatically build the project, select the **Artix-7 (xc7a100tcsg324-1)** board, and link all VHDL files, the OV7670 camera IPs, and the Nexys A7 XDC constraints.

---

## 2. The Daily Routine (Mandatory Workflow)

To ensure neither of you overwrites the other's progress, strictly follow this routine every day.

### 🌅 Start of the Day (Syncing Up)
1. Open your terminal (Git Bash) in your project folder.
2. Pull the latest changes from GitHub:
```bash
   git pull origin main
   ```
3. **Did the structure change?**
   * If your partner only changed VHDL/Python text files: Open your existing local `.xpr` project and start working.
   * If your partner added new IP blocks, new VHDL files, or changed the Block Design: **Do not open your old `.xpr`**. Instead, open a fresh Vivado window and run `source build_project.tcl` in the console to rebuild the updated environment.

### 💻 During the Day
Work as usual. Edit VHDL code, update the Python AI scripts, run simulations, or add new IPs to the Vivado Block Design.

### 🌇 End of the Day (Saving & Pushing)
If you made **ANY** structural changes in Vivado (added a file, modified the Block Design, generated a new IP), you **MUST** update the Tcl script before pushing to GitHub.

1. In Vivado, go to the **Tcl Console** at the bottom.
2. Ensure Vivado is looking at the correct directory (avoids saving to `C:/Windows/System32`):
```tcl
   cd [get_property DIRECTORY [current_project]]
   ```
3. Overwrite the old Tcl script with your new setup:
```tcl
   write_project_tcl -force -paths_relative_to [pwd] build_project.tcl
   ```
4. Now, open Git Bash and push everything to GitHub:
```bash
   git add .
   git commit -m "Briefly describe what you did today (e.g., Added debounce IP, updated top_2.vhd)"
   git push origin main
   ```
