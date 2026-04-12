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
            
            // In your old testbench, we waited ~220ns (22 clock cycles) for the AES 
            // math to finish before sending the next packet. We do the same here.
            repeat(22) @(vif.driver_cb);
            
            no_transactions++;
            
            // Uncomment below if you want to print every driven packet
            // trans.display("[ Driver ]");
        end
    endtask

endclass
