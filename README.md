# MacDuo: Lid-Driven Unfold Animation for macOS

An experimental macOS application that hooks into the MacBook's physical hardware **Lid-Angle Sensor (Hinge Sensor)** to drive an immersive 3D folding/unfolding animation (inspired by the dual-screen form factors like the Surface/iPhone Duo concept) in direct synchronization with your hand movement.

## 🚀 How It Works
Unlike traditional pre-baked animations, this utility monitors real-time geometric parameters directly from the macOS registry layer using low-level IOKit bindings:
1. **Detection:** Intercepts precise physical changes from the `AppleSmartDisplayHinge` kernel service.
2. **Capture:** Takes an atomic screenshot frame buffer partition of active spaces right as the closure sequence initializes.
3. **Projection:** Passes divided display segments to a Core Animation layer stage executing a complex `CATransform3D` conical matrix mapping governed directly by the hardware degree variables.

## 📁 Repository Structure
* `Sources/LidSensorBridge.h & .mm`: Objective-C++ interface acting as the direct IOKit communication gateway.
* `Sources/MacDuoAnimation-Bridging-Header.h`: Language compilation bridge pipeline.
* `Sources/MacDuoCoreEngine.swift`: Quartz Display Link synchronizer and Core Graphics screen splitter engine.

## 🛠️ Compilation & Local Setup
To run or build this module locally on a macOS device:
1. Clone this repository to your workstation.
2. Generate or open a standard **AppKit macOS Storyboard App** structure in Xcode.
3. Drop the `Sources` file cluster inside your compiler working directory tree.
4. Ensure you wire up the `Bridging Header` variable configuration inside Xcode's target **Build Settings** pointing to `MacDuoAnimation-Bridging-Header.h`.
5. Run the target execution scheme.

## ⚠️ Hardware Limitations
Please note that when the MacBook panel is completely closed (`0.0°`), the Apple micro-kernel forcefully drops GPU graphics processing routines and cuts display backlighting protocols to guarantee thermal integrity and battery conservation. Consequently, the visualization pipeline performs its continuous interpolation mechanics strictly within the active physical manipulation spectrum (`~15.0°` up to user base positioning angles).

## Contributions

Feel free to do it :)
