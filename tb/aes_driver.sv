class aes_driver;

    // Keep track of how many transactions we've driven
    int no_transactions;
    
    // The virtual interface connects the class to the physical hardware wires
    virtual aes_interface vif;
    
    // The mailbox to receive packets from the Generator
    mailbox gen2driv;

    // Constructor: gets the interface and mailbox from the Environment
    function new(virtual aes_interface vif, mailbox gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction

    // Reset task to ensure a clean slate
    task reset();
        wait(vif.reset);
        $display("[ Driver ] AES Core Reset Started...");
        vif.driver_cb.state <= '0;
        vif.driver_cb.key   <= '0;
        wait(!vif.reset);
        $display("[ Driver ] AES Core Reset Completed.");
    endtask

    // Main task to drive the hardware
    task main();
        forever begin
            aes_transaction trans;
            
            // Get the next packet from the mailbox (blocks if empty)
            gen2driv.get(trans);
            
            // Wait for the next positive clock edge using the clocking block
            @(vif.driver_cb);
            
            // Drive the signals into the chip
            vif.driver_cb.state <= trans.state;
            vif.driver_cb.key   <= trans.key;
            
            // Wait 22 clock cycles for the AES math to finish processing
            repeat(22) @(vif.driver_cb);
            
            // Capture the actual output from the chip
            trans.out = vif.driver_cb.out;
            
            // =======================================================
            // THE SELF-CHECKING TRAP (Observe & Report Mode)
            // =======================================================
            if (trans.out !== trans.expected_out) begin
                $display("\n========================================================");
                $display("        🚨 [!!! TROJAN PAYLOAD DETECTED !!!] 🚨         ");
                $display("========================================================");
                $display("Transaction #%0d was corrupted by malicious logic!", no_transactions);
                $display("Expected : %h", trans.expected_out);
                $display("Actual   : %h", trans.out);
                $display("--> Logging anomaly and continuing simulation to preserve VCD integrity...");
                $display("========================================================\n");
                
                // NOTICE: There is no $stop command here anymore.
                // The simulation will continue so the ML pipeline gets all 2000 cycles of data!
            end
            
            no_transactions++;
        end
    endtask

endclass
