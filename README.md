# Atari Breakout — 16-Bit x86 Assembly Game

A bare-metal clone of the classic **Atari Breakout Arcade Game** written entirely in **16-bit x86 Assembly Language** (Intel syntax) for real-mode x86 systems. 

This project demonstrates low-level systems programming, direct hardware manipulation, and software engineering foundations without the abstraction of modern operating systems, game engines, or high-level libraries.

---

## 🛠️ Technical Deep Dive & Architecture

Operating within a 16-bit real-mode environment requires manual management of memory segments, peripheral devices, and clock cycles. The codebase implements several core low-level computing concepts:

### 1. Direct Video Memory Mapping
Instead of utilizing standard operating system display APIs or slow BIOS interrupts for rendering, the game writes directly to the **Text-Mode Video Buffer Segment** located at memory address `0xB800`. 
* Dynamic screen clearing, visual boundaries, and text interfaces are drawn sequentially by calculating screen offsets using register arithmetic.
* The game elements—such as the multi-colored brick tiers, the paddle (`<======>`), and the ball (`*`)—are rendered with custom color attributes natively assigned to the hardware text mode.

### 2. Custom Hardware Interrupt Service Routine (ISR)
To manage asynchronous game loops, frame timing, and continuous physics tracking cleanly, the program hooks directly into the **System Timer Interrupt (`INT 0x08`)**:
* **IVT Rewriting:** On startup, the program backing up the original BIOS Interrupt Vector Table (IVT) address and replaces it with a custom `timer_isr`.
* **Deterministic Game Loop:** It tracks hardware clock ticks to regulate smooth ball movement independently of the processor's speed.
* **Unhooking Safeguard:** Upon game exit or crash, the original ISR is restored to ensure the host system or emulator remains stable.

### 3. Audio Synthesis via I/O Ports
Sound effects (impacts, paddle deflections, and life losses) are synthesized programmatically by directly interfacing with the **8253/8254 Programmable Interval Timer (PIT)** chip:
* Communicates through hardware I/O ports `0x61` (System Control Port) and `0x43` (PIT Command Register).
* Generates square-wave audio tones by manipulating the PIT frequency counter channels and the PC speaker gating.

### 4. Deterministic Collision Physics
* Evaluates 2D vector trajectories against the game boundaries (Top, Left, Right walls) and the bottom death zone.
* Features a **zonal paddle deflection system**: The ball's horizontal velocity vector alters dynamically depending on whether it strikes the left edge, center, or right edge of the paddle.
* Automatically processes 3 tier-based brick point structures (Green: 10 pts, Yellow: 20 pts, Red: 30 pts) by identifying text character attributes upon ball contact.

---

## 🎮 Game Features & Controls

* **Modular States:** Fully implemented Welcome Screen, Main Menu, Interactive Rules Screen, Real-Time Pause Menu, Game Over Screen, and Victory Screen.
* **Controls:**
  * `A` / `D` — Move paddle Left / Right
  * `P` — Pause/Resume Game
  * `R` — Restart Game (from Game Over / Win screens)
  * `Esc` — Safe Exit

---

## 🚀 How to Run

Because this is a 16-bit real-mode program, it cannot run natively on modern 64-bit operating systems. It requires an x86 assembler and an emulator.

### Prerequisites
1. **NASM** (Netwide Assembler)
2. **DOSBox** (or any alternative x86 PC emulator)

### Compilation & Execution Steps

1. **Assemble the code:**
   Compile the source code (`q820.asm`) into a standard DOS executable `.com` format using NASM:
   ```bash
   nasm -f bin game.asm -o atari.com
