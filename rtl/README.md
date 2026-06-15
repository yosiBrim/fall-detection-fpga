## 🏗️ Hardware Architecture Diagram

```mermaid
graph LR
    cam[📷 Camera OV7670] -->|RGB Pixels| ip(🧠 Image Processing \n Fall Detection)
    cam -.->|SCCB / I2C| ctrl[⚙️ Camera Controller]
    
    ip -->|Alert Signal| leds[🚨 System LEDs]
    ip -->|Processed Frame| vga[🖥️ VGA Controller]
    
    vga --> monitor[Monitor Display]
    
    style cam fill:#f9f,stroke:#333,stroke-width:2px
    style ip fill:#bbf,stroke:#333,stroke-width:4px
    style vga fill:#bfb,stroke:#333,stroke-width:2px
