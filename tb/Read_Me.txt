tb_top.sv

--> Generates the physical clock and reset signals.
--> Instantiates the AES-128 core (DUT) and the Interface.
--> This is the file the simulator executes.

aes_interface.sv

--> Wires connecting the software classes to the hardware DUT. 
--> Includes clocking blocks for synchronization.

aes_transaction.sv

--> The data packet object.
--> Contains 'rand' fields for the 128-bit state and key to facilitate high-entropy noise generation.

aes_generator.sv

--> Creates randomized aes_transaction objects and places them into a Mailbox. 
--> Contains zero hardware-level timing logic.

aes_driver.sv

--> Pulls transactions from the Mailbox and physically drives the values onto the aes_interface pins.

aes_environment.sv

--> Instantiates the Generator, Driver, and Mailbox, wiring them all together. 
--> Manages the execution phases (reset -> drive -> finish).

aes_test.sv

--> Configures the test constraints (e.g., instructing the environment to generate 2000 cycles of random stress-test data for the ML model).

DATA FLOW FOR VCD PROFILING

Generator -> [Mailbox] -> Driver -> Interface -> AES Core

By pumping 2000 random packets through this pipeline, we force the legitimate AES gates to switch constantly (generating high-entropy VCD logs) while the stealthy Hardware Trojan remains dormant and mathematically quiet.
