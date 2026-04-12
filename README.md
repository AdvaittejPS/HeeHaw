[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/AdvaittejPS/HeeHaw/blob/main/HeeHaw-ML-Pipeline.ipynb)

This repository contains the Machine Learning pipeline (Isolation Forest) designed to detect stealthy Hardware Trojans hidden inside AES-128 cryptographic cores. 

Click the **Open in Colab** button above to run the AI directly in your browser against the raw hardware switching data!

# Unsupervised Anomaly Detection for Hardware Trojan Identification in Cryptographic Cores

This repository implements a non-invasive, unsupervised machine learning framework designed to detect hardware-level malicious logic (Hardware Trojans) within an AES-128 cryptographic engine. The methodology leverages temporal entropy and switching activity analysis to isolate stealthy triggers without the requirement of a golden reference model.

## Abstract
The globalization of the semiconductor supply chain has introduced vulnerabilities via third-party IP (3PIP) and untrusted foundry access. Hardware Trojans (HT) are designed to remain dormant during standard functional verification, activating only under rare trigger conditions to leak sensitive data or degrade performance. This project utilizes an **Isolation Forest** algorithm to identify these anomalies by mapping the switching behavior of every logic gate into a two-dimensional feature space.

## Technical Architecture

### 1. Hardware Design and Trojan Injection
The core is a standard AES-128 implementation written in SystemVerilog. Various Trojan variants were injected to test the robustness of the detection pipeline:
* **Time-Bomb (Infected 04):** A sequential Trojan utilizing a counter to trigger a payload after a specified temporal threshold.
* **FSM Hijack (Infected 05):** A stealthy transition-based Trojan that activates upon a specific "magic" input sequence.
* **Combinational Leak (Infected 06):** A direct leakage path that XORs the internal state with a malicious constant upon a trigger condition.

### 2. Feature Extraction and Signal Processing
The detection pipeline parses Value Change Dump (VCD) files generated from an OOP-based SystemVerilog testbench. For each signal $i$ in the netlist, a feature vector $V_i$ is constructed:
$$V_i = \begin{bmatrix} \alpha_i \\ \tau_i \end{bmatrix}$$
where:
* $\alpha_i$ (Switching Activity): The total number of signal transitions ($0 \to 1$ or $1 \to 0$) during the simulation interval.
* $\tau_i$ (Temporal Anchor): The timestamp of the final transition observed for that specific wire.

### 3. Machine Learning Pipeline (Isolation Forest)
The framework employs an unsupervised Isolation Forest model, which isolates anomalies by randomly selecting a feature and then randomly selecting a split value between the maximum and minimum values of the selected feature.
* **Contamination Factor ($c$):** Set to $0.02$ to account for the expected ratio of malicious/static logic within the 8,263 extracted signals.
* **Blacklisting Heuristic:** To improve the signal-to-noise ratio (SNR), a heuristic filter is applied to remove known architectural outliers such as the clock tree, reset signals, and AES Round Constants (RCON).

## Repository Organization
* `/rtl`: SystemVerilog source code for clean and infected AES-128 cores.
* `/tb`: Object-Oriented SystemVerilog testbench utilizing stratified random stimulus.
* `/activity_logs`: Gzip-compressed VCD files for various regression test cases.
* `HeeHaw-ML-Pipeline.ipynb`: The integrated Python/Data Science environment for model training and visualization.
