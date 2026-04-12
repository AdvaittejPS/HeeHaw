[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/AdvaittejPS/HeeHaw/blob/main/HeeHaw-ML-Pipeline.ipynb)

This repository contains the Machine Learning pipeline (Isolation Forest) designed to detect stealthy Hardware Trojans hidden inside AES-128 cryptographic cores. 

Click the **Open in Colab** button above to run the AI directly in your browser against the raw hardware switching data!

# Project Hee-Haw: Unsupervised ML for Stealthy Hardware Trojan Detection
_Prepared for the Scripting Languages and Verification course instructed by Dr. Jyotishman Saikia._

Project Hee-Haw is a non-invasive, architecture-agnostic security auditing framework designed to detect dormant Hardware Trojans (HT) hidden within digital IP cores. Utilizing an AES-128 cryptographic engine as the Device Under Test (DUT), this project leverages temporal Value Change Dump (VCD) activity profiling and Unsupervised Machine Learning (Isolation Forests) to identify malicious logic without requiring a trusted "Structural Golden Model."

## The Nomenclature: Why "Hee-Haw"?

In hardware security, malicious logic insertions are termed "Trojans" because they disguise themselves within the legitimate "Horse" (the standard AES core). However, from a Machine Learning perspective, a Trojan that leaves a detectable mathematical footprint is not a stealthy warhorse—it is a donkey making a loud, intrusive noise in a high-entropy bitstream.

The name "Hee-Haw" reflects the reality that under rigorous mathematical auditing, a Trojan cannot remain silent; its anomalous structural and temporal signature "brays" its presence to the ML pipeline.

## Technical Architecture & Methodology

The framework operates on a dual-verification security architecture: Functional Verification (C-Model Truth) and Structural Verification (ML Pipeline).

**1. Hardware Threat Models**

The core is an AES-128 implementation in SystemVerilog. We engineered several stealthy threat models:

FSM Hijack (Infected 05): A "Combination Lock" trigger that activates only upon receiving a specific sequence of three 128-bit plaintexts.

Sequential Time-Bomb (Infected 04): A Trojan utilizing an internal counter to trigger a payload after exactly 1,500 clock cycles.

Combinational Leak (Infected 06): A direct trigger that corrupts ciphertext when a specific 128-bit input state is detected.

**2. Functional Verification (Closed-Loop C-Model)**

To prove that an anomaly is a malicious payload, the environment utilizes a self-checking Object-Oriented SystemVerilog (OOSV) testbench.

Golden Truth Generation: A native C-model (gen_test_case.c + aes.c) generates 2,000 high-entropy random test vectors. It calculates the absolute mathematical ciphertext and saves it to golden_vectors.txt.

The Self-Checking Trap: The SV aes_generator reads these vectors. The aes_driver feeds the hardware and performs a real-time comparison. If a Trojan activates, the driver flags the mismatch in the console but continues the simulation (Observe & Report) to ensure the VCD file remains uncorrupted for the AI.

**3. Structural Verification (ML Pipeline)**

For structural auditing, the testbench generates massive VCD logs during the 2,000-packet stress test. A custom Python parser extracts a 2D feature vector $V_i$ for every logic gate:


$$V_i = \begin{bmatrix} \alpha_i \\ \tau_i \end{bmatrix}$$

$\alpha_i$ (Switching Activity): Total signal transitions (entropy).

$\tau_i$ (Temporal Anchor): Timestamp of the final transition.

**4. Anomaly Detection (Isolation Forest)**

The framework employs an Unsupervised Isolation Forest model. By mapping signals into the $(\alpha, \tau)$ feature space, the AI target the "uncanny valley" of hardware activity. Malicious triggers—which are designed to be rare—display mathematically isolated, low-entropy signatures compared to the high-activity "cloud" of legitimate AES logic.

Directory Structure
```
Project_HeeHaw/
├── rtl/             # Infected and Clean AES variants
├── tb/              # OOSV Classes (Generator, Driver, Env, Top)
├── scripts/         # Tcl automation (simulate_all.do)
├── sim/             # Execution folder (C-Generator & SV Simulation)
└── activity_logs/   # Generated VCD profiles for ML analysis
```

## Execution Guide (Mentor Server)

**1. Generate the Mathematical Truth**

Compile and run the C-model inside the sim/ folder:
```
gcc gen_test_case.c aes.c -o generate_vectors
./generate_vectors
```

**2. Run the Automated Simulation Suite**

Run the batch simulation to generate VCDs for all 7 design variants:
```
vsim -c -do ../scripts/simulate_all.do
```

**3. Analyze via ML Pipeline**

Upload the resulting VCDs from /activity_logs to the HeeHaw ML Pipeline (Google Colab) to visualize the isolated Trojan triggers on the 2D scatter plot.
