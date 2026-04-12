class aes_generator;

    // The transaction packet we will be generating
    aes_transaction trans;
    
    // The mailbox to send packets to the Driver
    mailbox gen2driv;
    
    // An event to signal when we are done generating all packets
    event ended;
    
    // How many packets to generate (e.g., our 2000 cycle stress test)
    int repeat_count;
    
    // File pointer for reading our golden vectors
    int file_handle; 

    // Constructor: gets the mailbox handle from the Environment
    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    // The main task that generates the data
    task main();
        // 1. Open the golden truth file (Local path since C code is run in sim folder)
        file_handle = $fopen("golden_vectors.txt", "r");
        if (!file_handle) begin
            $fatal("Gen:: Could not open golden_vectors.txt! Did you run the C program?");
        end

        repeat (repeat_count) begin
            trans = new();
            
            // 2. Read the hex strings: [Key] [Plaintext] [Ciphertext]
            if ($fscanf(file_handle, "%h %h %h\n", trans.key, trans.state, trans.expected_out) != 3) begin
                $fatal("Gen:: Failed to read vector from file! Reached EOF early?");
            end
            
            // Put the populated packet into the mailbox
            gen2driv.put(trans);
        end
        
        $fclose(file_handle);
        
        // Trigger the 'ended' event to tell the testbench we are finished generating
        -> ended;
    endtask

endclass
