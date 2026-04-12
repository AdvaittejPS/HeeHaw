`include "aes_transaction.sv"
`include "aes_generator.sv"
`include "aes_driver.sv"

class aes_environment;

    // Instances of our components
    aes_generator gen;
    aes_driver    driv;
    
    // The shared mailbox
    mailbox gen2driv;
    
    // Virtual interface to talk to the physical hardware
    virtual aes_interface vif;

    // Constructor
    function new(virtual aes_interface vif);
        this.vif = vif;
        
        // Create the mailbox first
        gen2driv = new();
        
        // Pass the mailbox to the Generator and Driver
        gen  = new(gen2driv);
        driv = new(vif, gen2driv);
    endfunction

    // Phase 1: Reset the DUT
    task pre_test();
        driv.reset();
    endtask

    // Phase 2: Run generation and driving in parallel
    task test();
        fork
            gen.main();
            driv.main();
        join_any // Wait for the generator to finish creating packets
    endtask

    // Phase 3: Wait for the driver to finish emptying the mailbox
    task post_test();
        wait(gen.ended.triggered);
        wait(gen.repeat_count == driv.no_transactions);
        $display("--------------------------------");
        $display("[ Environment ] 100%% of transactions driven. Stress Test Complete!");
        $display("--------------------------------");
    endtask

    // The master run task
    task run();
        pre_test();
        test();
        post_test();
        $stop; // End the simulation
    endtask

endclass
