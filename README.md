# Star-Delta Motor Starter — 8051 (EdSim51)

> Control of a three-phase AC induction motor startup using the star–delta (Y–Δ) method, implemented in Assembly for the 8051 microcontroller on the EdSim51 simulator.

---

## Table of Contents

- [Overview](#overview)
- [Motor Specifications](#motor-specifications)
- [Electrical Principle](#electrical-principle)
- [Starting Current Calculations](#starting-current-calculations)
- [I/O Mapping](#io-mapping)
- [Switching Time Selection](#switching-time-selection)
- [Program Logic](#program-logic)
- [How to Run](#how-to-run)
- [Repository Structure](#repository-structure)
- [Authors](#authors)

---

## Overview

This project implements an automatic **star–delta starter** for a three-phase induction motor using the **Intel 8051 microcontroller** simulated on **EdSim51**.

The system:
- Starts the motor in **star (Y)** configuration, reducing the phase voltage to V_L / √3 and limiting the inrush current to ~1/3 of the delta value
- Automatically switches to **delta (Δ)** configuration after a user-selectable delay (1–8 seconds)
- Supports **rotation reversal** with a 3-second safety delay
- Uses **Port P1** for relay/contactor outputs and **Port P2** for switch/button inputs

---

## Motor Specifications

| Parameter | Value |
|-----------|-------|
| Model | SEW-EURODRIVE DZ71K4 |
| Nominal power | 0.15 kW |
| Nominal voltage | 220 V / 380 V |
| Nominal current | 1.06 A / 0.61 A |
| Frequency | 60 Hz |
| Power factor (cos φ) | 0.70 |
| Speed | 1680 rpm |
| Starting ratio (I_pl / I_n) | 3.5 |

---

## Electrical Principle

In a star–delta starter, the motor windings are initially connected in **star (Y)**, which applies a reduced voltage (V_L / √3) to each winding. After a timed interval, the windings are reconnected in **delta (Δ)**, applying the full line voltage V_L.

| Configuration | Phase voltage | Line current |
|---------------|--------------|-------------|
| Star (Y) | V_L / √3 | I_L / 3 (≈ 33% of delta) |
| Delta (Δ) | V_L | √3 · V_phase |

The key relationship is:

```
I_Y / I_Δ = 1/3
```

---

## Starting Current Calculations

Using the motor nameplate data (220 V, Δ operation):

**Delta (direct-on-line) starting current:**
```
I_Δ_start = 3.5 × I_n = 3.5 × 1.06 A ≈ 3.71 A
```

**Star starting current (star–delta method):**
```
I_Y_start = I_Δ_start / 3 ≈ 3.71 / 3 ≈ 1.24 A
```

The star configuration reduces the inrush current from **3.71 A** to approximately **1.24 A**.

---

## I/O Mapping

### Port P1 — Outputs (Relays / Contactors)

| Pin | Function |
|-----|----------|
| P1.0 | K1 — forward direction contactor |
| P1.1 | K4 — reverse direction contactor |
| P1.2 | K2 — star (Y) contactor |
| P1.3 | K3 — delta (Δ) contactor |

### Port P2 — Inputs (Switches / Buttons)

| Pin | Function |
|-----|----------|
| P2.0, P2.1, P2.2 | Switching time selection bits (active low) |
| P2.3 | Start button (active low) |
| P2.4 | Rotation reversal switch (active low) |

---

## Switching Time Selection

The program reads P2, applies a bitwise complement (`CPL A`) and masks with `ANL A, #07h`, making bits P2.0–P2.2 active-low.

The switching time is counted via Timer 0 interrupts every 50 ms:

```
t = N × 50 ms
```

| Index (P2.0–P2.2) | N | Time |
|-------------------|---|------|
| 0 | 20 | 1 s |
| 1 | 40 | 2 s |
| 2 | 60 | 3 s |
| 3 | 80 | 4 s |
| 4 | 100 | 5 s |
| 5 | 120 | 6 s |
| 6 | 140 | 7 s |
| 7 | 160 | 8 s |

---

## Program Logic

```
1. Wait for START button (P2.3 = 0)
2. Read time selection from P2.0–P2.2 → load R3
3. Activate K1 (P1.0) + K2 (P1.2) → star startup
4. Start Timer 0 (50 ms interrupts, decrement R3)
5. When R3 = 0 → toggle K2 off, K3 on → switch to delta
6. Wait for reversal command (P2.4 = 0)
7. Load R4 = 60 (3 s delay) → start Timer 1
8. When R4 = 0 → toggle K1 and K4 → reverse rotation
```

**Timer configuration (12 MHz clock):**
```asm
TMOD ← 11h       ; Timer 0 and 1 in 16-bit mode
TH0/TL0 ← 3Ch/B0h  ; ~50 ms overflow
IE ← 8Ah         ; EA=1, ET0=1, ET1=1
```

---

## How to Run

1. Download and open [EdSim51](http://www.edsim51.com/)
2. Load the file `main.asm` into the editor
3. Assemble the code (F5 or "Assemble" button)
4. Configure the switches on Port P2:
   - P2.0–P2.2: select desired switching time
   - P2.3: start button
   - P2.4: reversal switch
5. Run the simulation and observe Port P1 LED outputs (K1–K4)

---

## Repository Structure

```
star-delta-motor-starter-8051/
│
├── main.asm                  # Assembly source code (8051)
├── diagrama_unifilar.png     # Single-line (unifilar) circuit diagram
├── estrela_triangulo.png     # Star vs delta winding diagram
└── README.md                 # This file
```

---

## Authors

Developed as part of the **Embedded Systems Project for Electrical Engineering** course at the **Instituto Militar de Engenharia (IME)** — Rio de Janeiro, 2026.

- CAP ROBSON NUNES RODRIGUES JÚNIOR
- 1° TEN DAVI DE OLIVEIRA RABELO

**Instructor:** Cap Gabriel da Cruz Fontenelle
