# HeeHaw
Scripting Languages Project

Title: Unsupervised Machine Learning for Stealthy Hardware Trojan Detection via Temporal VCD Activity Profiling

Description: This project aims to design an architecture-agnostic security auditing tool capable of detecting dormant, stealthy Hardware Trojans inserted into digital IP cores (such as an AES-128 crypto-engine). The design involves injecting various threat models (Combinational payloads and Sequential time-bombs) into the RTL. By simulating high-entropy random workloads, we will generate Value Change Dump (VCD) logs. Instead of relying on manual heuristic filtering, we will implement an Unsupervised Machine Learning algorithm (Isolation Forest) to dynamically analyze 2D temporal data (Switching Frequency vs. Timestamp of Last Switch) to mathematically isolate malicious, low-activity trigger wires from legitimate baseline logic.

Verification Measures: 
Automation Steps: 
•	Tcl scripts to automate Siemens QuestaSim batch simulations and generate comprehensive VCD files without manual GUI interaction.
•	Python-based Data Science pipeline to parse massive VCD logs, extract features, and run the ML anomaly detection model.
Self-checking:
•	We will implement a behavioural reference model in Python (using the PyCryptodome library) to generate cryptographic Golden Vectors.
•	The SystemVerilog testbench will automatically cross-check the RTL's ciphertext output against these Golden Vectors to verify functionality and confirm Trojan payload activation.
High Coverage: 
Directed & Trigger Tests: Standard AES-128 encryption validation (NIST vectors) and precise payload activation tests to confirm Trojan behaviour.
Random Stress Tests: 1000+ cycle $random simulations to create high-entropy environments for statistical baseline generation.
Advanced Threat Models: Expanding coverage to test against multiple Trojan variants, including both Combinational (state-triggered) and Sequential (counter-based time-bombs) logic.
Cross-Abstraction Testing: Running verification not just at the RTL level but also on post-synthesis Gate-Level Netlists to ensure detection holds true in physical, noisy gate representations.
Architecture-Agnostic Validation: Testing the ML model against different IP cores to prove the algorithm works without hardcoded, architecture-specific rules.
Timeline: The timeline will be around 6 weeks.
Anticipated Steps:
•	Week 1: Trojan Library Creation. Designing and injecting both Combinational (state-triggered) and Sequential (counter-based) Trojans into the AES-128 RTL.
•	Week 2: Automated Verification Environment. Developing the Self-Checking Testbench, Python Golden Vector generator, and Tcl simulation scripts.
•	Week 3: VCD Data Extraction. Writing an optimized Python parser to process heavy VCD files and extract 2D features (Total Switches and Timestamp of Last Switch).
•	Week 4: Machine Learning Integration. Implementing the Isolation Forest algorithm using scikit-learn to cluster normal logic and flag isolated anomalies (Trojans).
•	Week 5: Advanced Threat Testing. Synthesizing the RTL into a Gate-Level Netlist to prove the ML model works on physical gate representations and noisy data.
•	Week 6: Visualization & Documentation. Building a Streamlit Web UI dashboard to visualize the Trojan clusters on a 2D scatter plot, followed by bug fixing and final report/patent drafting.
