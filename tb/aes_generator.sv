class aes_generator;

    // The transaction packet we will be generating
    rand aes_transaction trans;
    
    // The mailbox to send packets to the Driver
    mailbox gen2driv;
    
    // An event to signal when we are done generating all packets
    event ended;
    
    // How many packets to generate (e.g., our 2000 cycle stress test)
    int repeat_count;

    // Constructor: gets the mailbox handle from the Environment
    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    // The main task that generates the data
    task main();
        repeat (repeat_count) begin
            trans = new();
            
            // Randomize the packet. If it fails, throw a fatal error.
            if (!trans.randomize()) begin
                $fatal("Gen:: Transaction randomization failed!");
            end
            
            // Uncomment the line below if you want to print every generated packet to the terminal
            // trans.display("[ Generator ]");
            
            // Put the randomized packet into the mailbox
            gen2driv.put(trans);
        end
        
        // Trigger the 'ended' event to tell the testbench we are finished generating
        -> ended;
    endtask

endclass
