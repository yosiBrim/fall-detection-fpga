> ⚠️ **Project Scope Disclaimer**
> The Edge AI integration described in this document is currently proposed as an **advanced Proof of Concept (PoC)** and an optional extension to the core project. 
> The primary, guaranteed deliverable of this final engineering project is the robust FPGA hardware pipeline (OV7670 Camera ➔ BRAM Buffering ➔ VGA Display). The software-based MobileNet-SSD AI layer will be pursued and fully integrated only if project timeline and hardware resource constraints permit.
> # 🧠 Edge AI & Fall Detection Integration

This document explains the software-hardware co-design used to achieve real-time posture recognition and fall detection.

## 🔄 System Flow

While the FPGA handles the heavy lifting of high-speed video acquisition and low-level processing (filtering, buffering, and display rendering), the complex inference is handled by an Edge AI model.

1. **Pre-processing (Hardware):** The FPGA captures the frame, optionally applies basic thresholding or edge detection, and prepares the data.
2. **Data Handoff:** The buffered frame or extracted features are routed to the software controller.
3. **Inference (Software):** A Python-based controller feeds the data into the detection model.
4. **Action:** If a specific posture transition (e.g., rapid transition from standing to lying down) is detected, an alert flag is raised.

## 🤖 MobileNet-SSD Model

We utilize a variant of the MobileNet-SSD (Single Shot MultiBox Detector) architecture.
* **Why MobileNet?** It uses depthwise separable convolutions, making it exceptionally lightweight and suitable for edge devices with limited computational overhead.
* **Output:** Bounding boxes and confidence scores for detected human postures.

## 🎯 Posture Classification

The system monitors state transitions rather than just static frames:
* `STATE_STANDING`
* `STATE_SITTING`
* `STATE_LYING_DOWN`

A "Fall" is classified as an abrupt geometric transition from `STANDING` or `SITTING` directly to `LYING_DOWN` within a critical time threshold.
